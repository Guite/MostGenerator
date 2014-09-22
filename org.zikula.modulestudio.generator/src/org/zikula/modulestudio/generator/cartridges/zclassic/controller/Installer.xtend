package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityTreeType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.EventListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ExampleData
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.Interactive
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.MigrationHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ModVars
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.InstallerView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Installer {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for application installer.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        val installerPrefix = if (!targets('1.3.5')) name.formatForCodeCapital + 'Module' else ''
        generateClassPair(fsa, getAppSourceLibPath + installerPrefix + 'Installer.php',
            fh.phpFileContent(it, installerBaseClass), fh.phpFileContent(it, installerImpl)
        )

        if (interactiveInstallation == true) {
            generateClassPair(fsa, getAppSourceLibPath + 'Controller/InteractiveInstaller' + (if (targets('1.3.5')) '' else 'Controller') + '.php',
                fh.phpFileContent(it, interactiveBaseClass), fh.phpFileContent(it, interactiveImpl)
            )
            new InstallerView().generate(it, fsa)
        }
    }

    def private installerBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Base;

            «IF hasCategorisableEntities»
                use CategoryUtil;
                use CategoryRegistryUtil;
                use DBUtil;
            «ENDIF»
            use DoctrineHelper;
            use EventUtil;
            «IF hasUploads»
                use FileUtil;
            «ENDIF»
            use HookUtil;
            use ModUtil;
            use System;
            use UserUtil;
            use Zikula_AbstractInstaller;
            use Zikula_Workflow_Util;

        «ENDIF»
        /**
         * Installer base class.
         */
        class «IF targets('1.3.5')»«appName»_Base_«ELSE»«name.formatForCodeCapital»Module«ENDIF»Installer extends Zikula_AbstractInstaller
        {
            «installerBaseImpl»
        }
    '''

    def private interactiveBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Controller\Base;

            use Symfony\Component\HttpFoundation\RedirectResponse;
            use Symfony\Component\Security\Core\Exception\AccessDeniedException;

            «IF needsConfig»
                use ModUtil;
            «ENDIF»
            use SecurityUtil;
            use System;
            use Zikula_Controller_AbstractInteractiveInstaller;
            use ZLanguage;
            «IF hasCategorisableEntities»
                use Zikula\Module\CategoriesModule\Entity\CategoryRegistryEntity;
            «ENDIF»

        «ENDIF»
        /**
         * Interactive installer base class.
         */
        «IF targets('1.3.5')»
        class «appName»_Controller_Base_InteractiveInstaller extends Zikula_Controller_AbstractInteractiveInstaller
        «ELSE»
        class InteractiveInstallerController extends Zikula_Controller_AbstractInteractiveInstaller
        «ENDIF»
        {
            «new Interactive().generate(it)»
        }
    '''

    def private installerBaseImpl(Application it) '''
        «funcInit»

        «funcUpdate»

        «funcDelete»

        «funcListEntityClasses»

        «new ExampleData().generate(it)»
        «IF targets('1.3.5')»

        «new EventListener().generate(it)»
        «ENDIF»
    '''

    def private funcInit(Application it) '''
        /**
         * Install the «appName» application.
         *
         * @return boolean True on success, or false.
         «IF !targets('1.3.5')»
         *
         * @throws RuntimeException Thrown if database tables can not be created or another error occurs
         «ENDIF»
         */
        public function install«/* new base class not ready yet in the core, see MostGenerator#401 IF !targets('1.3.5')»Action«ENDIF*/»()
        {
            «processUploadFolders»
            // create all tables from according entity definitions
            try {
                DoctrineHelper::createSchema($this->entityManager, $this->listEntityClasses());
            } catch (\Exception $e) {
                if (System::isDevelopmentMode()) {
                    «IF targets('1.3.5')»
                        return LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                    «ELSE»
                        $this->request->getSession()->getFlashBag()->add('error', $this->__('Doctrine Exception: ') . $e->getMessage());
                        $logger = $this->serviceManager->get('logger');
                        $logger->error('{app}: User {user} could not create the database tables during installation. Error details: {errorMessage}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()));
                        return false;
                    «ENDIF»
                }
                $returnMessage = $this->__f('An error was encountered while creating the tables for the %s extension.', array($this->name));
                if (!System::isDevelopmentMode()) {
                    $returnMessage .= ' ' . $this->__('Please enable the development mode by editing the /config/config.php file in order to reveal the error details.');
                }
                «IF targets('1.3.5')»
                    return LogUtil::registerError($returnMessage);
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('error', $returnMessage);
                    $logger = $this->serviceManager->get('logger');
                    $logger->error('{app}: User {user} could not create the database tables during installation. Error details: {errorMessage}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()));
                    return false;
                «ENDIF»
            }
            «IF !variables.empty»

                // set up all our vars with initial values
                «val modvarHelper = new ModVars()»
                «FOR modvar : getAllVariables»
                    «IF interactiveInstallation == true»
                        «IF targets('1.3.5')»
                            $sessionValue = SessionUtil::getVar('«formatForCode(name + '_' + modvar.name)»');
                        «ELSE»
                            $sessionValue = $this->request->getSession()->get('«formatForCode(name + '_' + modvar.name)»');
                        «ENDIF»
                        $this->setVar('«modvar.name.formatForCode»', (($sessionValue != false) ? «modvarHelper.valFromSession(modvar)» : «modvarHelper.valSession2Mod(modvar)»));
                        «IF targets('1.3.5')»
                            SessionUtil::delVar(«formatForCode(name + '_' + modvar.name)»);
                        «ELSE»
                            $this->request->getSession()->del(«formatForCode(name + '_' + modvar.name)»);
                        «ENDIF»
                    «ELSE»
                        $this->setVar('«modvar.name.formatForCode»', «modvarHelper.valDirect2Mod(modvar)»);
                    «ENDIF»
                «ENDFOR»
            «ENDIF»

            $categoryRegistryIdsPerEntity = array();
            «IF hasCategorisableEntities»

                // add default entry for category registry (property named Main)
                «IF targets('1.3.5')»
                    include_once '«rootFolder»/«appName»/lib/«appName»/Api/Base/Category.php';
                    include_once '«rootFolder»/«appName»/lib/«appName»/Api/Category.php';
                    $categoryApi = new «appName»_Api_Category($this->serviceManager);
                «ELSE»
                    $categoryApi = new \«vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Api\CategoryApi($this->serviceManager);
                «ENDIF»
                $categoryGlobal = CategoryUtil::getCategoryByPath('/__SYSTEM__/Modules/Global');
                «IF targets('1.3.5')»
                    «FOR entity : getCategorisableEntities»

                        $registryData = array();
                        $registryData['modname'] = $this->name;
                        $registryData['table'] = '«entity.name.formatForCodeCapital»';
                        $registryData['property'] = $categoryApi->getPrimaryProperty(array('ot' => '«entity.name.formatForCodeCapital»'));
                        $registryData['category_id'] = $categoryGlobal['id'];
                        $registryData['id'] = false;
                        if (!DBUtil::insertObject($registryData, 'categories_registry')) {
                            LogUtil::registerError($this->__f('Error! Could not create a category registry for the %s entity.', array('«entity.name.formatForDisplay»')));
                        }
                        $categoryRegistryIdsPerEntity['«entity.name.formatForCode»'] = $registryData['id'];
                    «ENDFOR»
                «ELSE»
                    «FOR entity : getCategorisableEntities»

                        $registry = new CategoryRegistryEntity();
                        $registry->setModname($this->name);
                        $registry->setEntityname('«entity.name.formatForCodeCapital»');
                        $registry->setProperty($categoryApi->getPrimaryProperty(array('ot' => '«entity.name.formatForCodeCapital»')));
                        $registry->setCategory_Id($categoryGlobal['id']);

                        try {
                            $this->entityManager->persist($registry);
                            $this->entityManager->flush();
                        } catch (\Exception $e) {
                            $this->request->getSession()->getFlashBag()->add('error', $this->__f('Error! Could not create a category registry for the %s entity.', array('«entity.name.formatForDisplay»')));
                            $logger = $this->serviceManager->get('logger');
                            $logger->error('{app}: User {user} could not create a category registry for {entities} during installation. Error details: {errorMessage}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«entity.nameMultiple.formatForDisplay»', 'errorMessage' => $e->getMessage()));
                        }
                        $categoryRegistryIdsPerEntity['«entity.name.formatForCode»'] = $registry->getId();
                    «ENDFOR»
                «ENDIF»
            «ENDIF»

            // create the default data
            $this->createDefaultData($categoryRegistryIdsPerEntity);

            «IF targets('1.3.5')»
                // register persistent event handlers
                $this->registerPersistentEventHandlers();

            «ENDIF»
            // register hook subscriber bundles
            HookUtil::registerSubscriberBundles($this->version->getHookSubscriberBundles());
            «/*TODO see #15
                // register hook provider bundles
                HookUtil::registerProviderBundles($this->version->getHookProviderBundles());
            */»

            // initialisation successful
            return true;
        }
    '''

    def private processUploadFolders(Application it) '''
        «IF hasUploads»
            // Check if upload directories exist and if needed create them
            try {
                «IF targets('1.3.5')»
                    $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
                «ELSE»
                    $controllerHelper = $this->serviceManager->get('«appName.formatForDB».controller_helper');
                «ENDIF»
                $controllerHelper->checkAndCreateAllUploadFolders();
            } catch (\Exception $e) {
                «IF targets('1.3.5')»
                    return LogUtil::registerError($e->getMessage());
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('error', $e->getMessage());
                    $logger = $this->serviceManager->get('logger');
                    $logger->error('{app}: User {user} could not create upload folders during installation. Error details: {errorMessage}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()));
                    return false;
                «ENDIF»
            }
        «ENDIF»
    '''

    def private funcUpdate(Application it) '''
        /**
         * Upgrade the «appName» application from an older version.
         *
         * If the upgrade fails at some point, it returns the last upgraded version.
         *
         * @param integer $oldVersion Version to upgrade from.
         *
         * @return boolean True on success, false otherwise.
         «IF !targets('1.3.5')»
         *
         * @throws RuntimeException Thrown if database tables can not be updated
         «ENDIF»
         */
        public function upgrade«/* new base class not ready yet in the core, see MostGenerator#401 IF !targets('1.3.5')»Action«ENDIF*/»($oldVersion)
        {
        /*
            // Upgrade dependent on old version number
            switch ($oldVersion) {
                case '1.0.0':
                    // do something
                    // ...
                    // update the database schema
                    try {
                        DoctrineHelper::updateSchema($this->entityManager, $this->listEntityClasses());
                    } catch (\Exception $e) {
                        if (System::isDevelopmentMode()) {
                            «IF targets('1.3.5')»
                                return LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                            «ELSE»
                                $this->request->getSession()->getFlashBag()->add('error', $this->__('Doctrine Exception: ') . $e->getMessage());
                                $logger = $this->serviceManager->get('logger');
                                $logger->error('{app}: User {user} could not update the database tables during the upgrade. Error details: {errorMessage}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()));
                                return false;
                            «ENDIF»
                        }
                        «IF targets('1.3.5')»
                            return LogUtil::registerError($this->__f('An error was encountered while updating tables for the %s extension.', array($this->getName())));
                        «ELSE»
                            $this->request->getSession()->getFlashBag()->add('error', $this->__f('An error was encountered while updating tables for the %s extension.', array($this->getName())));
                            $logger = $this->serviceManager->get('logger');
                            $logger->error('{app}: User {user} could not update the database tables during the ugprade. Error details: {errorMessage}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()));
                            return false;
                        «ENDIF»
                    }
            }
            «IF !targets('1.3.5')»

                // Note there are several helpers available for making migration of your extension easier.
                // The following convenience methods are each responsible for a single aspect of upgrading to Zikula 1.4.0.

                // here is a possible usage example
                // of course 1.2.3 should match the number you used for the last stable 1.3.x module version.
                /* if ($oldVersion = '1.2.3') {
                    «new MigrationHelper().generateUsageExample(it)»
                } * /
            «ENDIF»
        */

            // update successful
            return true;
        }
        «IF !targets('1.3.5')»

            «new MigrationHelper().generate(it)»
        «ENDIF»
    '''

    def private funcDelete(Application it) '''
        /**
         * Uninstall «appName».
         *
         * @return boolean True on success, false otherwise.
         «IF !targets('1.3.5')»
         *
         * @throws RuntimeException Thrown if database tables or stored workflows can not be removed
         «ENDIF»
         */
        public function uninstall«/* new base class not ready yet in the core, see MostGenerator#401 IF !targets('1.3.5')»Action«ENDIF*/»()
        {
            // delete stored object workflows
            $result = Zikula_Workflow_Util::deleteWorkflowsForModule($this->getName());
            if ($result === false) {
                «IF targets('1.3.5')»
                    return LogUtil::registerError($this->__f('An error was encountered while removing stored object workflows for the %s extension.', array($this->getName())));
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('error', $this->__f('An error was encountered while removing stored object workflows for the %s extension.', array($this->getName())));
                    $logger = $this->serviceManager->get('logger');
                    $logger->error('{app}: User {user} could not remove stored object workflows during uninstallation.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname')));
                    return false;
                «ENDIF»
            }

            try {
                DoctrineHelper::dropSchema($this->entityManager, $this->listEntityClasses());
            } catch (\Exception $e) {
                if (System::isDevelopmentMode()) {
                    «IF targets('1.3.5')»
                        return LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                    «ELSE»
                        $this->request->getSession()->getFlashBag()->add('error', $this->__('Doctrine Exception: ') . $e->getMessage());
                        $logger = $this->serviceManager->get('logger');
                        $logger->error('{app}: User {user} could not remove the database tables during uninstallation. Error details: {errorMessage}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()));
                        return false;
                    «ENDIF»
                }
                «IF targets('1.3.5')»
                    return LogUtil::registerError($this->__f('An error was encountered while dropping tables for the %s extension.', array($this->name)));
                «ELSE»
                    $this->request->getSession()->getFlashBag()->add('error', $this->__f('An error was encountered while dropping tables for the %s extension.', array($this->name)));
                    $logger = $this->serviceManager->get('logger');
                    $logger->error('{app}: User {user} could not remove the database tables during uninstallation. Error details: {errorMessage}.', array('app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()));
                    return false;
                «ENDIF»
            }

            «IF targets('1.3.5')»
                // unregister persistent event handlers
                EventUtil::unregisterPersistentModuleHandlers($this->name);

            «ENDIF»
            // unregister hook subscriber bundles
            HookUtil::unregisterSubscriberBundles($this->version->getHookSubscriberBundles());
            «/*TODO see #15
                // unregister hook provider bundles
                HookUtil::unregisterProviderBundles($this->version->getHookProviderBundles());
            */»
            «IF !getAllVariables.empty»

                // remove all module vars
                $this->delVars();
            «ENDIF»
            «IF hasCategorisableEntities»

                // remove category registry entries
                ModUtil::dbInfoLoad('Categories');
                DBUtil::deleteWhere('categories_registry', 'modname = \'' . $this->name . '\'');
            «ENDIF»
            «IF hasUploads»

                // remove all thumbnails
                $manager = $this->getServiceManager()->get«IF targets('1.3.5')»Service«ENDIF»('systemplugin.imagine.manager');
                $manager->setModule($this->name);
                $manager->cleanupModuleThumbs();

                // remind user about upload folders not being deleted
                $uploadPath = FileUtil::getDataDirectory() . '/' . $this->name . '/';
                «IF targets('1.3.5')»
                    LogUtil::registerStatus($this->__f('The upload directories at [%s] can be removed manually.', $uploadPath));
                «ELSE»
                    $this->request->getSession()-getFlashBag()->add('status', $this->__f('The upload directories at [%s] can be removed manually.', $uploadPath));
                «ENDIF»
            «ENDIF»

            // uninstallation successful
            return true;
        }
    '''

    def private funcListEntityClasses(Application it) '''
        /**
         * Build array with all entity classes for «appName».
         *
         * @return array list of class names.
         */
        protected function listEntityClasses()
        {
            $classNames = array();
            «FOR entity : getAllEntities»
                $classNames[] = '«entity.entityClassName('', false)»';
                «IF entity.loggable»
                    $classNames[] = '«entity.entityClassName('logEntry', false)»';
                «ENDIF»
                «IF entity.tree == EntityTreeType.CLOSURE»
                    $classNames[] = '«entity.entityClassName('closure', false)»';
                «ENDIF»
                «IF entity.hasTranslatableFields»
                    $classNames[] = '«entity.entityClassName('translation', false)»';
                «ENDIF»
                «IF entity.metaData»
                    $classNames[] = '«entity.entityClassName('metaData', false)»';
                «ENDIF»
                «IF entity.attributable»
                    $classNames[] = '«entity.entityClassName('attribute', false)»';
                «ENDIF»
                «IF entity.categorisable»
                    $classNames[] = '«entity.entityClassName('category', false)»';
                «ENDIF»
            «ENDFOR»

            return $classNames;
        }
    '''

    def private installerImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»;

            use «appNamespace»\Base\«name.formatForCodeCapital»ModuleInstaller as Base«name.formatForCodeCapital»ModuleInstaller;

        «ENDIF»
        /**
         * Installer implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Installer extends «appName»_Base_Installer
        «ELSE»
        class «name.formatForCodeCapital»ModuleInstaller extends Base«name.formatForCodeCapital»ModuleInstaller
        «ENDIF»
        {
            // feel free to extend the installer here
        }
    '''

    def private interactiveImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Controller;

            use «appNamespace»\Controller\Base\InteractiveInstaller as BaseInteractiveInstaller;

        «ENDIF»
        /**
         * Interactive installer implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Controller_InteractiveInstaller extends «appName»_Controller_Base_InteractiveInstaller
        «ELSE»
        class InteractiveInstaller extends BaseInteractiveInstaller
        «ENDIF»
        {
            // feel free to extend the installer here
        }
    '''
}
