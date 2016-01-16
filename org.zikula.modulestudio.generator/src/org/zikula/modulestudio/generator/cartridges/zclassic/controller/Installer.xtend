package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityTreeType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.EventListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ExampleData
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.MigrationHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ModVars
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
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
        val installerPrefix = if (!targets('1.3.x')) name.formatForCodeCapital + 'Module' else ''
        generateClassPair(fsa, getAppSourceLibPath + installerPrefix + 'Installer.php',
            fh.phpFileContent(it, installerBaseClass), fh.phpFileContent(it, installerImpl)
        )
    }

    def private installerBaseClass(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Base;

            «IF hasCategorisableEntities»
                use CategoryUtil;
                use DBUtil;
            «ENDIF»
            use EventUtil;
            «IF hasUploads»
                use FileUtil;
            «ENDIF»
            «IF hasHookSubscribers/* || hasHookProviders*/»
                use HookUtil;
            «ENDIF»
            use ModUtil;
            use System;
            use UserUtil;
            use Zikula\Core\AbstractExtensionInstaller;
            use Zikula_Workflow_Util;
            «IF hasCategorisableEntities»
                use Zikula\CategoriesModule\Entity\CategoryRegistryEntity;
            «ENDIF»
            use Zikula\ExtensionsModule\Api\HookApi;

        «ENDIF»
        /**
         * Installer base class.
         */
        class «IF targets('1.3.x')»«appName»_Base_Installer extends Zikula_AbstractInstaller«ELSE»«name.formatForCodeCapital»ModuleInstaller extends AbstractExtensionInstaller«ENDIF»
        {
            «installerBaseImpl»
        }
    '''

    def private installerBaseImpl(Application it) '''
        «funcInit»

        «funcUpdate»

        «funcDelete»

        «funcListEntityClasses»

        «new ExampleData().generate(it)»
        «IF targets('1.3.x')»

        «new EventListener().generate(it)»
        «ENDIF»
    '''

    def private funcInit(Application it) '''
        /**
         * Install the «appName» application.
         *
         * @return boolean True on success, or false.
         «IF !targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if database tables can not be created or another error occurs
         «ENDIF»
         */
        public function install()
        {
            «processUploadFolders»
            «IF !targets('1.3.x')»
                $logger = $this->container->get('logger');
            «ENDIF»
            // create all tables from according entity definitions
            try {
                «IF targets('1.3.x')»
                    DoctrineHelper::createSchema($this->entityManager, $this->listEntityClasses());
                «ELSE»
                    $this->container->get('zikula.doctrine.schema_tool')->create($this->listEntityClasses());
                «ENDIF»
            } catch (\Exception $e) {
                if (System::isDevelopmentMode()) {
                    «IF targets('1.3.x')»
                        return LogUtil::registerError($this->__('Doctrine Exception') . ': ' . $e->getMessage());
                    «ELSE»
                        $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $this->__('Doctrine Exception') . ': ' . $e->getMessage());
                        $logger->error('{app}: User {user} could not create the database tables during installation. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()]);

                        return false;
                    «ENDIF»
                }
                $returnMessage = $this->__f('An error was encountered while creating the tables for the %s extension.', «IF targets('1.3.x')»array($this->getName())«ELSE»['«appName»']«ENDIF»);
                if (!System::isDevelopmentMode()) {
                    «IF targets('1.3.x')»
                        $returnMessage .= ' ' . $this->__('Please enable the development mode by editing the /config/config.php file in order to reveal the error details.');
                    «ELSE»
                        $returnMessage .= ' ' . $this->__('Please enable the development mode by editing the /app/config/parameters.yml file (change the env variable to dev) in order to reveal the error details (or look into the log files at /app/logs/).');
                    «ENDIF»
                }
                «IF targets('1.3.x')»
                    return LogUtil::registerError($returnMessage);
                «ELSE»
                    $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $returnMessage);
                    $logger->error('{app}: User {user} could not create the database tables during installation. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()]);

                    return false;
                «ENDIF»
            }
            «IF !variables.empty»

                // set up all our vars with initial values
                «val modvarHelper = new ModVars()»
                «FOR modvar : getAllVariables»
                    $this->setVar('«modvar.name.formatForCode»', «modvarHelper.valDirect2Mod(modvar)»);
                «ENDFOR»
            «ENDIF»

            $categoryRegistryIdsPerEntity = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            «IF hasCategorisableEntities»

                // add default entry for category registry (property named Main)
                «IF targets('1.3.x')»
                    include_once '«rootFolder»/«appName»/lib/«appName»/Api/Base/Category.php';
                    include_once '«rootFolder»/«appName»/lib/«appName»/Api/Category.php';
                    $categoryApi = new «appName»_Api_Category($this->serviceManager);
                «ELSE»
                    $categoryApi = new \«vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Api\CategoryApi($this->container, new \«appNamespace»\«appName»());
                «ENDIF»
                $categoryGlobal = CategoryUtil::getCategoryByPath('/__SYSTEM__/Modules/Global');
                «IF targets('1.3.x')»
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
                        $registry->setModname('«appName»');
                        $registry->setEntityname('«entity.name.formatForCodeCapital»');
                        $registry->setProperty($categoryApi->getPrimaryProperty(['ot' => '«entity.name.formatForCodeCapital»']));
                        $registry->setCategory_Id($categoryGlobal['id']);

                        try {
                            $entityManager = $this->container->get('doctrine.entitymanager');
                            $entityManager->persist($registry);
                            $entityManager->flush();
                        } catch (\Exception $e) {
                            $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $this->__f('Error! Could not create a category registry for the %s entity.', ['«entity.name.formatForDisplay»']));
                            $logger->error('{app}: User {user} could not create a category registry for {entities} during installation. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«entity.nameMultiple.formatForDisplay»', 'errorMessage' => $e->getMessage()]);
                        }
                        $categoryRegistryIdsPerEntity['«entity.name.formatForCode»'] = $registry->getId();
                    «ENDFOR»
                «ENDIF»
            «ENDIF»

            // create the default data
            $this->createDefaultData($categoryRegistryIdsPerEntity);

            «IF targets('1.3.x')»
                // register persistent event handlers
                $this->registerPersistentEventHandlers();

            «ENDIF»
            «IF hasHookSubscribers»
                // register hook subscriber bundles
                «IF targets('1.3.x')»
                    HookUtil::registerSubscriberBundles($this->version->getHookSubscriberBundles());
                «ELSE»
                    $subscriberHookContainer = $this->hookApi->getHookContainerInstance($this->bundle->getMetaData(), HookApi::SUBSCRIBER_TYPE);
                    HookUtil::registerSubscriberBundles($subscriberHookContainer->getHookSubscriberBundles());
                «ENDIF»
            «ENDIF»
            «/*TODO see #15
            «IF hasHookProviders»
                // register hook provider bundles
                «IF targets('1.3.x')»
                    HookUtil::registerProviderBundles($this->version->getHookProviderBundles());
                «ELSE»
                    $providerHookContainer = $this->hookApi->getHookContainerInstance($this->bundle->getMetaData(), HookApi::PROVIDER_TYPE);
                    HookUtil::registerProviderBundles($providerHookContainer->getHookProviderBundles());
                «ENDIF»
            «ENDIF»*/»

            // initialisation successful
            return true;
        }
    '''

    def private processUploadFolders(Application it) '''
        «IF hasUploads»
            // Check if upload directories exist and if needed create them
            try {
                «IF targets('1.3.x')»
                    $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
                «ELSE»
                    $controllerHelper = $this->container->get('«appName.formatForDB».controller_helper')
                «ENDIF»
                $controllerHelper->checkAndCreateAllUploadFolders();
            } catch (\Exception $e) {
                «IF targets('1.3.x')»
                    return LogUtil::registerError($e->getMessage());
                «ELSE»
                    $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $e->getMessage());
                    $logger->error('{app}: User {user} could not create upload folders during installation. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()]);

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
         «IF !targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if database tables can not be updated
         «ENDIF»
         */
        public function upgrade($oldVersion)
        {
        /*
            «IF !targets('1.3.x')»
                $logger = $this->container->get('logger');
            «ENDIF»
            // Upgrade dependent on old version number
            switch ($oldVersion) {
                case '1.0.0':
                    // do something
                    // ...
                    // update the database schema
                    try {
                        «IF targets('1.3.x')»
                            DoctrineHelper::updateSchema($this->entityManager, $this->listEntityClasses());
                        «ELSE»
                            $this->container->get('zikula.doctrine.schema_tool')->update($this->listEntityClasses());
                        «ENDIF»
                    } catch (\Exception $e) {
                        if (System::isDevelopmentMode()) {
                            «IF targets('1.3.x')»
                                return LogUtil::registerError($this->__('Doctrine Exception') . ': ' . $e->getMessage());
                            «ELSE»
                                $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $this->__('Doctrine Exception') . ': ' . $e->getMessage());
                                $logger->error('{app}: User {user} could not update the database tables during the upgrade. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()]);

                                return false;
                            «ENDIF»
                        }
                        «IF targets('1.3.x')»
                            return LogUtil::registerError($this->__f('An error was encountered while updating tables for the %s extension.', array($this->getName())));
                        «ELSE»
                            $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $this->__f('An error was encountered while updating tables for the %s extension.', ['«appName»']));
                            $logger->error('{app}: User {user} could not update the database tables during the ugprade. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()]);

                            return false;
                        «ENDIF»
                    }
            }
            «IF !targets('1.3.x')»

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
        «IF !targets('1.3.x')»

            «new MigrationHelper().generate(it)»
        «ENDIF»
    '''

    def private funcDelete(Application it) '''
        /**
         * Uninstall «appName».
         *
         * @return boolean True on success, false otherwise.
         «IF !targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if database tables or stored workflows can not be removed
         «ENDIF»
         */
        public function uninstall()
        {
            «IF !targets('1.3.x')»
                $logger = $this->container->get('logger');
            «ENDIF»
            // delete stored object workflows
            $result = Zikula_Workflow_Util::deleteWorkflowsForModule(«IF targets('1.3.x')»$this->getName()«ELSE»'«appName»'«ENDIF»);
            if ($result === false) {
                «IF targets('1.3.x')»
                    return LogUtil::registerError($this->__f('An error was encountered while removing stored object workflows for the %s extension.', array($this->getName())));
                «ELSE»
                    $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $this->__f('An error was encountered while removing stored object workflows for the %s extension.', ['«appName»']));
                    $logger->error('{app}: User {user} could not remove stored object workflows during uninstallation.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname')]);

                    return false;
                «ENDIF»
            }

            try {
                «IF targets('1.3.x')»
                    DoctrineHelper::dropSchema($this->entityManager, $this->listEntityClasses());
                «ELSE»
                    $this->container->get('zikula.doctrine.schema_tool')->drop($this->listEntityClasses());
                «ENDIF»
            } catch (\Exception $e) {
                if (System::isDevelopmentMode()) {
                    «IF targets('1.3.x')»
                        return LogUtil::registerError($this->__('Doctrine Exception') . ': ' . $e->getMessage());
                    «ELSE»
                        $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $this->__('Doctrine Exception') . ': ' . $e->getMessage());
                        $logger->error('{app}: User {user} could not remove the database tables during uninstallation. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()]);

                        return false;
                    «ENDIF»
                }
                «IF targets('1.3.x')»
                    return LogUtil::registerError($this->__f('An error was encountered while dropping tables for the %s extension.', array($this->getName())));
                «ELSE»
                    $this->addFlash(\Zikula_Session::MESSAGE_ERROR, $this->__f('An error was encountered while dropping tables for the %s extension.', ['«appName»']));
                    $logger->error('{app}: User {user} could not remove the database tables during uninstallation. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => UserUtil::getVar('uname'), 'errorMessage' => $e->getMessage()]);

                    return false;
                «ENDIF»
            }

            «IF targets('1.3.x')»
                // unregister persistent event handlers
                EventUtil::unregisterPersistentModuleHandlers($this->name);

            «ENDIF»
            // unregister hook subscriber bundles
            «IF targets('1.3.x')»
                HookUtil::unregisterSubscriberBundles($this->version->getHookSubscriberBundles());
                «/*TODO see #15
                    // unregister hook provider bundles
                    HookUtil::unregisterProviderBundles($this->version->getHookProviderBundles());
                */»
            «ELSE»
                $subscriberHookContainer = $this->hookApi->getHookContainerInstance($this->bundle->getMetaData(), HookApi::SUBSCRIBER_TYPE);
                HookUtil::unregisterSubscriberBundles($subscriberHookContainer->getHookSubscriberBundles());
                «/*TODO see #15
                    // unregister hook provider bundles
                    $providerHookContainer = $this->hookApi->getHookContainerInstance($this->bundle->getMetaData(), HookApi::PROVIDER_TYPE);
                    HookUtil::unregisterProviderBundles($providerHookContainer->getHookProviderBundles());
                */»
            «ENDIF»
            «IF !getAllVariables.empty»

                // remove all module vars
                $this->delVars();
            «ENDIF»
            «IF hasCategorisableEntities»

                // remove category registry entries
                ModUtil::dbInfoLoad('Categories');
                DBUtil::deleteWhere('categories_registry', 'modname = \'«IF targets('1.3.x')»' . $this->getName() . '«ELSE»«appName»«ENDIF»\'');
            «ENDIF»
            «IF hasUploads»

                // remove all thumbnails
                $manager = «IF targets('1.3.x')»$this->getServiceManager()->getService«ELSE»$this->container->get«ENDIF»('systemplugin.imagine.manager');
                $manager->setModule(«IF targets('1.3.x')»$this->getName()«ELSE»'«appName»'«ENDIF»);
                $manager->cleanupModuleThumbs();

                // remind user about upload folders not being deleted
                $uploadPath = «IF targets('1.3.x')»FileUtil::getDataDirectory()«ELSE»$this->container->getParameter('datadir')«ENDIF» . '/«IF targets('1.3.x')»' . $this->getName() . '«ELSE»«appName»«ENDIF»/';
                «IF targets('1.3.x')»
                    LogUtil::registerStatus($this->__f('The upload directories at [%s] can be removed manually.', $uploadPath));
                «ELSE»
                    $this->addFlash(\Zikula_Session::MESSAGE_STATUS, $this->__f('The upload directories at [%s] can be removed manually.', $uploadPath));
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
            $classNames = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
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
        «IF !targets('1.3.x')»
            namespace «appNamespace»;

            use «appNamespace»\Base\«name.formatForCodeCapital»ModuleInstaller as Base«name.formatForCodeCapital»ModuleInstaller;

        «ENDIF»
        /**
         * Installer implementation class.
         */
        «IF targets('1.3.x')»
        class «appName»_Installer extends «appName»_Base_Installer
        «ELSE»
        class «name.formatForCodeCapital»ModuleInstaller extends Base«name.formatForCodeCapital»ModuleInstaller
        «ENDIF»
        {
            // feel free to extend the installer here
        }
    '''
}
