package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.EventListener
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ExampleData
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.Interactive
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ModVars
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.InstallerView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Installer {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for application installer.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        val installerPrefix = if (!targets('1.3.5')) appName else ''
        val installerFileName = installerPrefix + 'Installer.php'
        fsa.generateFile(getAppSourceLibPath + 'Base/' + installerFileName, installerBaseFile)
        fsa.generateFile(getAppSourceLibPath + installerFileName, installerFile)

        if (interactiveInstallation == true) {
            val controllerPath = getAppSourceLibPath + 'Controller/'
            val controllerClassSuffix = if (!targets('1.3.5')) 'Controller' else ''
            val controllerFileName = 'InteractiveInstaller' + controllerClassSuffix + '.php'
            fsa.generateFile(controllerPath + 'Base/' + controllerFileName, interactiveBaseFile)
            fsa.generateFile(controllerPath + controllerFileName, interactiveFile)
            new InstallerView().generate(it, fsa)
        }
    }

    def private installerBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «installerBaseClass»
    '''

    def private installerFile(Application it) '''
        «fh.phpFileHeader(it)»
        «installerImpl»
    '''

    def private installerBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Base;

            use «appName»\Util\ControllerUtil;

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
            use LogUtil;
            «IF hasCategorisableEntities»
                use ModUtil;
            «ENDIF»
            use System;
            use Zikula_AbstractInstaller;
            use Zikula_Workflow_Util;

        «ENDIF»
        /**
         * Installer base class.
         */
        class «IF targets('1.3.5')»«appName»_Base_«ELSE»«appName»«ENDIF»Installer extends Zikula_AbstractInstaller
        {
            «installerBaseImpl»
        }
    '''

    def private interactiveBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «interactiveBaseClass»
    '''

    def private interactiveFile(Application it) '''
        «fh.phpFileHeader(it)»
        «interactiveImpl»
    '''

    def private interactiveBaseClass(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Controller\Base;

            use LogUtil;
            «IF needsConfig»
                use ModUtil;
            «ENDIF»
            use SecurityUtil;
            «IF !getAllVariableContainers.isEmpty»
                use SessionUtil;
            «ENDIF»
            use Zikula_Controller_AbstractInteractiveInstaller;
            use ZLanguage;

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

        «new EventListener().generate(it)»
    '''

    def private funcInit(Application it) '''
        /**
         * Install the «appName» application.
         *
         * @return boolean True on success, or false.
         */
        public function install()
        {
            «processUploadFolders»
            // create all tables from according entity definitions
            try {
                DoctrineHelper::createSchema($this->entityManager, $this->listEntityClasses());
            } catch (\Exception $e) {
                if (System::isDevelopmentMode()) {
                    LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                }
                $returnMessage = $this->__f('An error was encountered while creating the tables for the %s extension.', array($this->name));
                if (!System::isDevelopmentMode()) {
                    $returnMessage .= ' ' . $this->__('Please enable the development mode by editing the /config/config.php file in order to reveal the error details.');
                }
                return LogUtil::registerError($returnMessage);
            }
            «IF !getAllVariableContainers.isEmpty»

                // set up all our vars with initial values
                «val modvarHelper = new ModVars()»
                «FOR modvar : getAllVariables»
                    «IF interactiveInstallation == true»
                        $sessionValue = SessionUtil::getVar('«formatForCode(name + '_' + modvar.name)»');
                        $this->setVar('«modvar.name.formatForCode»', (($sessionValue <> false) ? «modvarHelper.valFromSession(modvar)» : «modvarHelper.valSession2Mod(modvar)»));
                        SessionUtil::delVar(«formatForCode(name + '_' + modvar.name)»);
                    «ELSE»
                        $this->setVar('«modvar.name.formatForCode»', «modvarHelper.valDirect2Mod(modvar)»);
                    «ENDIF»
                «ENDFOR»
            «ENDIF»

            $categoryRegistryIdsPerEntity = array();
            «IF hasCategorisableEntities»

                // add default entry for category registry (property named Main)
                «IF targets('1.3.5')»
                    include_once 'modules/«appName»/lib/«appName»/Api/Base/Category.php';
                    include_once 'modules/«appName»/lib/«appName»/Api/Category.php';
                    $categoryApi = new «appName»_Api_Category($this->serviceManager);
                «ELSE»
                    include_once 'modules/«appName»/Api/Base/CategoryApi.php';
                    include_once 'modules/«appName»/Api/CategoryApi.php';
                    $categoryApi = new \«appName»\Api\CategoryApi($this->serviceManager);
                «ENDIF»
                «FOR entity : getCategorisableEntities»

                    $registryData = array();
                    $registryData['modname'] = $this->name;
                    $registryData['table'] = '«entity.name.formatForCodeCapital»';
                    $registryData['property'] = $categoryApi->getPrimaryProperty(array('ot' => '«entity.name.formatForCodeCapital»'));
                    $registryData['category_id'] = CategoryUtil::getCategoryByPath('/__SYSTEM__/Modules/Global');
                    $registryData['id'] = false;
                    if (!DBUtil::insertObject($registryData, 'categories_registry')) {
                        LogUtil::registerError($this->__f('Error! Could not create a category registry for the %s entity.', array('«entity.name.formatForDisplay»')));
                    }
                    $categoryRegistryIdsPerEntity['«entity.name.formatForCode»'] = $registryData['id'];
                «ENDFOR»
            «ENDIF»

            // create the default data
            $this->createDefaultData($categoryRegistryIdsPerEntity);

            // register persistent event handlers
            $this->registerPersistentEventHandlers();

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
                $controllerHelper = new «IF targets('1.3.5')»«appName»_Util_Controller«ELSE»ControllerUtil«ENDIF»($this->serviceManager);
                $controllerHelper->checkAndCreateAllUploadFolders();
            } catch (\Exception $e) {
                return LogUtil::registerError($e->getMessage());
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
         */
        public function upgrade($oldVersion)
        {
        /*
            // Upgrade dependent on old version number
            switch ($oldVersion) {
                case 1.0.0:
                    // do something
                    // ...
                    // update the database schema
                    try {
                        DoctrineHelper::updateSchema($this->entityManager, $this->listEntityClasses());
                    } catch (\Exception $e) {
                        if (System::isDevelopmentMode()) {
                            LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                        }
                        return LogUtil::registerError($this->__f('An error was encountered while dropping the tables for the %s extension.', array($this->getName())));
                    }
            }
        */

            // update successful
            return true;
        }
    '''

    def private funcDelete(Application it) '''
        /**
         * Uninstall «appName».
         *
         * @return boolean True on success, false otherwise.
         */
        public function uninstall()
        {
            // delete stored object workflows
            $result = Zikula_Workflow_Util::deleteWorkflowsForModule($this->getName());
            if ($result === false) {
                return LogUtil::registerError($this->__f('An error was encountered while removing stored object workflows for the %s extension.', array($this->getName())));
            }

            try {
                DoctrineHelper::dropSchema($this->entityManager, $this->listEntityClasses());
            } catch (\Exception $e) {
                if (System::isDevelopmentMode()) {
                    LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                }
                return LogUtil::registerError($this->__f('An error was encountered while dropping the tables for the %s extension.', array($this->name)));
            }

            // unregister persistent event handlers
            EventUtil::unregisterPersistentModuleHandlers($this->name);

            // unregister hook subscriber bundles
            HookUtil::unregisterSubscriberBundles($this->version->getHookSubscriberBundles());
            «/*TODO see #15
                // unregister hook provider bundles
                HookUtil::unregisterProviderBundles($this->version->getHookProviderBundles());
            */»
            «IF !getAllVariables.isEmpty»

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
                $manager = $this->getServiceManager()->getService('systemplugin.imagine.manager');
                $manager->setModule($this->name);
                $manager->cleanupModuleThumbs();

                // remind user about upload folders not being deleted
                $uploadPath = FileUtil::getDataDirectory() . '/' . $this->name . '/';
                LogUtil::registerStatus($this->__f('The upload directories at [%s] can be removed manually.', $uploadPath));
            «ENDIF»

            // deletion successful
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
                «IF entity.tree == EntityTreeType::CLOSURE»
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
            namespace «appName»;

        «ENDIF»
        /**
         * Installer implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Installer extends «appName»_Base_Installer
        «ELSE»
        class «appName»Installer extends Base\«appName»Installer
        «ENDIF»
        {
            // feel free to extend the installer here
        }
    '''

    def private interactiveImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Controller;

        «ENDIF»
        /**
         * Interactive installer implementation class.
         */
        «IF targets('1.3.5')»
        class «appName»_Controller_InteractiveInstaller extends «appName»_Controller_Base_InteractiveInstaller
        «ELSE»
        class InteractiveInstaller extends Base\InteractiveInstaller
        «ENDIF»
        {
            // feel free to extend the installer here
        }
    '''
}
