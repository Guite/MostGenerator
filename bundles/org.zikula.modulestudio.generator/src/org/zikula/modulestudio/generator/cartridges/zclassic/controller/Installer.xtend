package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityTreeType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ExampleData
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.MigrationHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ModVars
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Installer {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for application installer.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        generateClassPair(fsa, getAppSourceLibPath + name.formatForCodeCapital + 'ModuleInstaller.php',
            fh.phpFileContent(it, installerBaseClass), fh.phpFileContent(it, installerImpl)
        )
    }

    def private installerBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        use Doctrine\DBAL\Connection;
        use RuntimeException;
        use Zikula\Core\AbstractExtensionInstaller;
        use Zikula_Workflow_Util;
        «IF hasCategorisableEntities»
            use Zikula\CategoriesModule\Entity\CategoryRegistryEntity;
        «ENDIF»

        /**
         * Installer base class.
         */
        abstract class Abstract«name.formatForCodeCapital»ModuleInstaller extends AbstractExtensionInstaller
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
    '''

    def private funcInit(Application it) '''
        /**
         * Install the «appName» application.
         *
         * @return boolean True on success, or false
         *
         * @throws RuntimeException Thrown if database tables can not be created or another error occurs
         */
        public function install()
        {
            $logger = $this->container->get('logger');
            $userName = $this->container->get('zikula_users_module.current_user')->get('uname');

            «processUploadFolders»
            // create all tables from according entity definitions
            try {
                $this->schemaTool->create($this->listEntityClasses());
            } catch (\Exception $e) {
                $this->addFlash('error', $this->__('Doctrine Exception') . ': ' . $e->getMessage());
                $logger->error('{app}: Could not create the database tables during installation. Error details: {errorMessage}.', ['app' => '«appName»', 'errorMessage' => $e->getMessage()]);

                return false;
            }
            «IF !variables.empty»

                // set up all our vars with initial values
                «val modvarHelper = new ModVars()»
                «FOR modvar : getAllVariables»
                    $this->setVar('«modvar.name.formatForCode»', «modvarHelper.valDirect2Mod(modvar)»);
                «ENDFOR»
            «ENDIF»
            «IF hasCategorisableEntities»

                $categoryRegistryIdsPerEntity = [];

                // add default entry for category registry (property named Main)
                $categoryHelper = new \«vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Helper\CategoryHelper(
                    $this->container,
                    $this->container->get('translator.default'),
                    $this->container->get('session'),
                    $logger,
                    $this->container->get('request_stack'),
                    $this->container->get('zikula_users_module.current_user'),
                    $this->container->get('zikula_categories_module.api.category_registry'),
                    $this->container->get('zikula_categories_module.api.category_permission')
                );
                $categoryGlobal = $this->container->get('zikula_categories_module.api.category')->getCategoryByPath('/__SYSTEM__/Modules/Global');
                «FOR entity : getCategorisableEntities»

                    $registry = new CategoryRegistryEntity();
                    $registry->setModname('«appName»');
                    $registry->setEntityname('«entity.name.formatForCodeCapital»Entity');
                    $registry->setProperty($categoryHelper->getPrimaryProperty('«entity.name.formatForCodeCapital»'));
                    $registry->setCategory_Id($categoryGlobal['id']);

                    try {
                        $entityManager = $this->container->get('«entityManagerService»');
                        $entityManager->persist($registry);
                        $entityManager->flush();
                    } catch (\Exception $e) {
                        $this->addFlash('error', $this->__f('Error! Could not create a category registry for the %s entity.', ['%s' => '«entity.name.formatForDisplay»']));
                        $logger->error('{app}: User {user} could not create a category registry for {entities} during installation. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => $userName, 'entities' => '«entity.nameMultiple.formatForDisplay»', 'errorMessage' => $e->getMessage()]);
                    }
                    $categoryRegistryIdsPerEntity['«entity.name.formatForCode»'] = $registry->getId();
                «ENDFOR»
            «ENDIF»

            // create the default data
            $this->createDefaultData(«IF hasCategorisableEntities»$categoryRegistryIdsPerEntity«ENDIF»);

            «IF hasHookSubscribers»
                // install subscriber hooks
                $this->hookApi->installSubscriberHooks($this->bundle->getMetaData());
            «ENDIF»
            «/*TODO see #15
            «IF hasHookProviders»
                // install provider hooks
                $this->hookApi->installProviderHooks($this->bundle->getMetaData());
            «ENDIF»*/»

            // initialisation successful
            return true;
        }
    '''

    def private processUploadFolders(Application it) '''
        «IF hasUploads»
            // Check if upload directories exist and if needed create them
            try {
                $container = $this->container;
                $uploadHelper = new \«appNamespace»\Helper\UploadHelper($container->get('translator.default'), $container->get('session'), $container->get('logger'), $container->get('zikula_users_module.current_user'), $container->get('zikula_extensions_module.api.variable'), $container->getParameter('%datadir%'));
                $uploadHelper->checkAndCreateAllUploadFolders();
            } catch (\Exception $e) {
                $this->addFlash('error', $e->getMessage());
                $logger->error('{app}: User {user} could not create upload folders during installation. Error details: {errorMessage}.', ['app' => '«appName»', 'user' => $userName, 'errorMessage' => $e->getMessage()]);

                return false;
            }
        «ENDIF»
    '''

    def private funcUpdate(Application it) '''
        /**
         * Upgrade the «appName» application from an older version.
         *
         * If the upgrade fails at some point, it returns the last upgraded version.
         *
         * @param integer $oldVersion Version to upgrade from
         *
         * @return boolean True on success, false otherwise
         *
         * @throws RuntimeException Thrown if database tables can not be updated
         */
        public function upgrade($oldVersion)
        {
        /*
            $logger = $this->container->get('logger');

            // Upgrade dependent on old version number
            switch ($oldVersion) {
                case '1.0.0':
                    // do something
                    // ...
                    // update the database schema
                    try {
                        $this->schemaTool->update($this->listEntityClasses());
                    } catch (\Exception $e) {
                        $this->addFlash('error', $this->__('Doctrine Exception') . ': ' . $e->getMessage());
                        $logger->error('{app}: Could not update the database tables during the upgrade. Error details: {errorMessage}.', ['app' => '«appName»', 'errorMessage' => $e->getMessage()]);

                        return false;
                    }
            }

            // Note there are several helpers available for making migrating your extension from Zikula 1.3 to 1.4 easier.
            // The following convenience methods are each responsible for a single aspect of upgrading to Zikula 1.4.x.

            // here is a possible usage example
            // of course 1.2.3 should match the number you used for the last stable 1.3.x module version.
            /* if ($oldVersion = '1.2.3') {
                «new MigrationHelper().generateUsageExample(it)»
            } * /
        */

            // update successful
            return true;
        }

        «new MigrationHelper().generate(it)»
    '''

    def private funcDelete(Application it) '''
        /**
         * Uninstall «appName».
         *
         * @return boolean True on success, false otherwise
         *
         * @throws RuntimeException Thrown if database tables or stored workflows can not be removed
         */
        public function uninstall()
        {
            $logger = $this->container->get('logger');

            // delete stored object workflows
            $result = Zikula_Workflow_Util::deleteWorkflowsForModule('«appName»');
            if (false === $result) {
                $this->addFlash('error', $this->__f('An error was encountered while removing stored object workflows for the %s extension.', ['%s' => '«appName»']));
                $logger->error('{app}: Could not remove stored object workflows during uninstallation.', ['app' => '«appName»']);

                return false;
            }

            try {
                $this->schemaTool->drop($this->listEntityClasses());
            } catch (\Exception $e) {
                $this->addFlash('error', $this->__('Doctrine Exception') . ': ' . $e->getMessage());
                $logger->error('{app}: Could not remove the database tables during uninstallation. Error details: {errorMessage}.', ['app' => '«appName»', 'errorMessage' => $e->getMessage()]);

                return false;
            }

            // uninstall subscriber hooks
            $this->hookApi->uninstallSubscriberHooks($this->bundle->getMetaData());
            «/*TODO see #15
            «IF hasHookProviders»
                // uninstall provider hooks
                $this->hookApi->uninstallProviderHooks($this->bundle->getMetaData());
            «ENDIF»*/»
            «IF !getAllVariables.empty»

                // remove all module vars
                $this->delVars();
            «ENDIF»
            «IF hasCategorisableEntities»
                // remove category registry entries
                $categoryRegistryApi = $this->container->get('zikula_categories_module.api.category_registry');
                // assume that not more than five registries exist
                for ($i = 1; $i <= 5; $i++) {
                    $categoryRegistryApi->deleteRegistry('«appName»');
                }
            «ENDIF»
            «IF hasUploads»

                «IF hasImageFields»
                    // remove all thumbnails
                    $manager = $this->container->get('systemplugin.imagine.manager');
                    $manager->setModule('«appName»');
                    $manager->cleanupModuleThumbs();

                «ENDIF»
                // remind user about upload folders not being deleted
                $uploadPath = $this->container->getParameter('datadir') . '/«appName»/';
                $this->addFlash('status', $this->__f('The upload directories at [%s] can be removed manually.', ['%s' => $uploadPath]));
            «ENDIF»

            // uninstallation successful
            return true;
        }
    '''

    def private funcListEntityClasses(Application it) '''
        /**
         * Build array with all entity classes for «appName».
         *
         * @return array list of class names
         */
        protected function listEntityClasses()
        {
            $classNames = [];
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
        namespace «appNamespace»;

        use «appNamespace»\Base\Abstract«name.formatForCodeCapital»ModuleInstaller;

        /**
         * Installer implementation class.
         */
        class «name.formatForCodeCapital»ModuleInstaller extends Abstract«name.formatForCodeCapital»ModuleInstaller
        {
            // feel free to extend the installer here
        }
    '''
}
