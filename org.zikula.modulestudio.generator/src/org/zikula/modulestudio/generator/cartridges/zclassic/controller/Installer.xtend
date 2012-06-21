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
        fsa.generateFile(getAppSourceLibPath(appName) + 'Base/Installer.php', installerBaseFile)
        fsa.generateFile(getAppSourceLibPath(appName) + 'Installer.php', installerFile)
        if (interactiveInstallation == true) {
            fsa.generateFile(getAppSourceLibPath(appName) + 'Controller/Base/InteractiveInstaller.php', interactiveBaseFile)
            fsa.generateFile(getAppSourceLibPath(appName) + 'Controller/InteractiveInstaller.php', interactiveFile)
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
        /**
         * Installer base class
         */
        class «appName»_Base_Installer extends Zikula_AbstractInstaller
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
        /**
         * Interactive installer base class
         */
        class «appName»_Controller_Base_Interactiveinstaller extends Zikula_Controller_AbstractInteractiveInstaller
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
            «checkIfUploadFoldersAreWritable»
            // create all tables from according entity definitions
            try {
                DoctrineHelper::createSchema($this->entityManager, $this->listEntityClasses());
            } catch (Exception $e) {
                if (System::isDevelopmentMode()) {
                    LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                }
                return LogUtil::registerError($this->__f('An error was encountered while creating the tables for the %s module.', array($this->getName())));
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

            // create the default data for «appName»
            $this->createDefaultData();
            «IF hasCategorisableEntities»

                // add entries to category registry
                $rootcat = CategoryUtil::getCategoryByPath('/__SYSTEM__/Modules/Global');
                «FOR entity : getCategorisableEntities»
                    CategoryRegistryUtil::insertEntry('«appName»', '«entity.name.formatForCodeCapital»', 'Main', $rootcat['id']);
                «ENDFOR»
            «ENDIF»

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

    def private checkIfUploadFoldersAreWritable(Application it) '''
        «val uploadEntities = getUploadEntities»
        «IF !uploadEntities.isEmpty»
            $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «FOR uploadEntity : uploadEntities»
            «FOR uploadField : uploadEntity.getUploadFieldsEntity»
                $basePath = $controllerHelper->getFileBaseFolder('«uploadField.entity.name.formatForCode»', '«uploadField.name.formatForCode»');
                if (!is_dir($basePath)) {
                    return LogUtil::registerError($this->__f('The upload folder "%s" does not exist. Please create it before installing this application.', array($basePath)));
                }
                if (!is_writable($basePath)) {
                    return LogUtil::registerError($this->__f('The upload folder "%s" is not writable. Please change permissions accordingly before installing this application.', array($basePath)));
                }
            «ENDFOR»
            «ENDFOR»
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
                    } catch (Exception $e) {
                        if (System::isDevelopmentMode()) {
                            LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                        }
                        return LogUtil::registerError($this->__f('An error was encountered while dropping the tables for the %s module.', array($this->getName())));
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
                return LogUtil::registerError($this->__f('An error was encountered while removing stored object workflows for the %s module.', array($this->getName())));
            }

            try {
                DoctrineHelper::dropSchema($this->entityManager, $this->listEntityClasses());
            } catch (Exception $e) {
                if (System::isDevelopmentMode()) {
                    LogUtil::registerError($this->__('Doctrine Exception: ') . $e->getMessage());
                }
                return LogUtil::registerError($this->__f('An error was encountered while dropping the tables for the %s module.', array($this->getName())));
            }

            // unregister persistent event handlers
            EventUtil::unregisterPersistentModuleHandlers('«appName»');

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
                DBUtil::deleteWhere('categories_registry', "modname = '«appName»'");
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
                $classNames[] = '«entity.implClassModelEntity»';
                «IF entity.loggable»
                    $classNames[] = '«entity.implClassModel('', 'logEntry')»';
                «ENDIF»
                «IF entity.tree == EntityTreeType::CLOSURE»
                    $classNames[] = '«entity.implClassModel('', 'closure')»';
                «ENDIF»
                «IF entity.hasTranslatableFields»
                    $classNames[] = '«entity.implClassModel('', 'translation')»';
                «ENDIF»
                «IF entity.metaData»
                    $classNames[] = '«entity.implClassModel('', 'metaData')»';
                «ENDIF»
                «IF entity.attributable»
                    $classNames[] = '«entity.implClassModel('', 'attribute')»';
                «ENDIF»
                «IF entity.categorisable»
                    $classNames[] = '«entity.implClassModel('', 'category')»';
                «ENDIF»
            «ENDFOR»

            return $classNames;
        }
    '''

    def private installerImpl(Application it) '''
        /**
         * Installer implementation class
         */
        class «appName»_Installer extends «appName»_Base_Installer
        {
            // feel free to extend the installer here
        }
    '''

    def private interactiveImpl(Application it) '''
        /**
         * Interactive installer implementation class
         */
        class «appName»_Controller_Interactiveinstaller extends «appName»_Controller_Base_Interactiveinstaller
        {
            // feel free to extend the installer here
        }
    '''
}
