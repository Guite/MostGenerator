package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MigrationHelper {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension Utils = new Utils

    def generateUsageExample(Application it) '''
        // rename module for all modvars
        $this->updateModVarsTo136();

        // update extension information about this app
        $this->updateExtensionInfoFor136();

        // rename existing permission rules
        $this->renamePermissionsFor136();

        // rename existing category registries
        $this->renameCategoryRegistriesFor136();

        // rename all tables
        $this->renameTablesFor136();

        // drop handlers for obsolete events
        $this->unregisterEventHandlersObsoleteIn136();

        // register new event handlers
        $this->registerNewEventHandlersIn136();

        // update module name in the hook tables
        $this->updateHookNamesFor136();
    '''

    def generate(Application it) {
        updateModVarsTo136
        updateExtensionInfoFor136
        renamePermissionsFor136
        renameCategoryRegistriesFor136
        renameTablesFor136
        unregisterEventHandlersObsoleteIn136
        registerNewEventHandlersIn136
        updateHookNamesFor136
        getConnection
        getDbName
    }

    def private updateModVarsTo136(Application it) '''
        /**
         * Renames the module name for variables in the module_vars table.
         */
        protected function updateModVarsTo136()
        {
            $dbName = $this->getDbName();
            $conn = $this->getConnection();

            $conn->executeQuery("UPDATE $dbName.module_vars
                                 SET modname = '«appName»'
                                 WHERE modname = '«name.formatForCodeCapital»';
            ");
        }

    '''

    def private updateExtensionInfoFor136(Application it) '''
        /**
         * Renames this application in the core's extensions table.
         */
        protected function updateExtensionInfoFor136()
        {
            $conn = $this->getConnection();
            $dbName = $this->getDbName();

            $conn->executeQuery("UPDATE $dbName.modules
                                 SET name = '«appName»',
                                     directory = '«vendor.formatForCodeCapital»/«name.formatForCodeCapital»Module'
                                 WHERE name = '«name.formatForCodeCapital»';
            ");
        }

    '''

    def private renamePermissionsFor136(Application it) '''
        /**
         * Renames all permission rules stored for this app.
         */
        protected function renamePermissionsFor136()
        {
            $conn = $this->getConnection();
            $dbName = $this->getDbName();

            $componentLength = strlen('«name.formatForCodeCapital»') + 1;

            $conn->executeQuery("UPDATE $dbName.group_perms
                                 SET component = CONCAT('«appName»', SUBSTRING(component, $componentLength))
                                 WHERE component LIKE '«name.formatForCodeCapital»%';
            ");
        }

    '''

    def private renameCategoryRegistriesFor136(Application it) '''
        /**
         * Renames all category registries stored for this app.
         */
        protected function renameCategoryRegistriesFor136()
        {
            $conn = $this->getConnection();
            $dbName = $this->getDbName();

            $componentLength = strlen('«name.formatForCodeCapital»') + 1;

            $conn->executeQuery("UPDATE $dbName.categories_registry
                                 SET modname = CONCAT('«appName»', SUBSTRING(component, $componentLength))
                                 WHERE modname LIKE '«name.formatForCodeCapital»%';
            ");
        }

    '''

    def private renameTablesFor136(Application it) '''
        /**
         * Renames all (existing) tables of this app.
         */
        protected function renameTablesFor136()
        {
            $conn = $this->getConnection();
            $dbName = $this->getDbName();

            $oldPrefix = '«prefix»_';
            $oldPrefixLength = strlen($oldPrefix);
            $newPrefix = '«vendor.formatForDB»_«prefix()»_';

            $sm = $conn->getSchemaManager();
            $tables = $sm->listTables();
            foreach ($tables as $table) {
                $tableName = $table->getName();
                if (substr($tableName, 0, $oldPrefixLength) != $oldPrefix) {
                    continue;
                }

                $newTableName = str_replace($oldPrefix, $newPrefix, $tableName)

                $conn->executeQuery("RENAME TABLE $dbName.$tableName
                                     TO $dbName.$newTableName;
                ");
            }
        }

    '''

    def private unregisterEventHandlersObsoleteIn136(Application it) '''
        /**
         * Unregisters handlers for events which became obsolete in 1.3.6.
         */
        protected function unregisterEventHandlersObsoleteIn136()
        {
            «val listenerBase = vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Listener\\'»
            «val listenerSuffix = 'Listener'»
            «var callableClass = ''»

            // installer -> «callableClass = listenerBase + 'Installer' + listenerSuffix»
            EventUtil::unregisterPersistentModuleHandler('«appName»', 'installer.module.installed', array('«callableClass»', 'moduleInstalled'));
            EventUtil::unregisterPersistentModuleHandler('«appName»', 'installer.module.upgraded', array('«callableClass»', 'moduleUpgraded'));
            EventUtil::unregisterPersistentModuleHandler('«appName»', 'installer.module.uninstalled', array('«callableClass»', 'moduleUninstalled'));

            // errors -> «callableClass = listenerBase + 'Errors' + listenerSuffix»
            EventUtil::unregisterPersistentModuleHandler('«appName»', 'setup.errorreporting', array('«callableClass»', 'setupErrorReporting'));
            EventUtil::unregisterPersistentModuleHandler('«appName»', 'systemerror', array('«callableClass»', 'systemError'));
        }

    '''

    def private registerNewEventHandlersIn136(Application it) '''
        /**
         * Registers new event handlers introduced in 1.3.6.
         */
        protected function registerNewEventHandlersIn136()
        {
            «val listenerBase = vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Listener\\'»
            «val listenerSuffix = 'Listener'»

            // installer -> «var callableClass = listenerBase + 'Installer' + listenerSuffix»
            EventUtil::registerPersistentModuleHandler('«appName»', CoreEvents::MODULE_INSTALL, array('«callableClass»', 'moduleInstalled'));
            EventUtil::registerPersistentModuleHandler('«appName»', CoreEvents::MODULE_UPGRADE, array('«callableClass»', 'moduleUpgraded'));
            EventUtil::registerPersistentModuleHandler('«appName»', CoreEvents::MODULE_ENABLE, array('«callableClass»', 'moduleEnabled'));
            EventUtil::registerPersistentModuleHandler('«appName»', CoreEvents::MODULE_DISABLE, array('«callableClass»', 'moduleDisabled'));
            EventUtil::registerPersistentModuleHandler('«appName»', CoreEvents::MODULE_REMOVE, array('«callableClass»', 'moduleRemoved'));

            // special purposes and 3rd party api support -> «callableClass = listenerBase + 'ThirdParty' + listenerSuffix»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.scribite.editorhelpers', array('«callableClass»', 'getEditorHelpers'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'moduleplugin.tinymce.externalplugins', array('«callableClass»', 'getTinyMcePlugins'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'moduleplugin.ckeditor.externalplugins', array('«callableClass»', 'getCKEditorPlugins'));
        }

    '''

    def private updateHookNamesFor136(Application it) '''
        /**
         * Updates the module name in the hook tables.
         */
        protected function updateHookNamesFor136()
        {
            $conn = $this->getConnection();
            $dbName = $this->getDbName();

            $conn->executeQuery("UPDATE $dbName.hook_area
                                 SET owner = '«appName»'
                                 WHERE owner = '«name.formatForCodeCapital»';
            ");

            $componentLength = strlen('subscriber.«name.formatForDB»') + 1;
            $conn->executeQuery("UPDATE $dbName.hook_area
                                 SET areaname = CONCAT('subscriber.«appName.formatForDB»', SUBSTRING(areaname, $componentLength))
                                 WHERE areaname LIKE 'subscriber.«name.formatForDB»%';
            ");

            $conn->executeQuery("UPDATE $dbName.hook_binding
                                 SET sowner = '«appName»'
                                 WHERE sowner = '«name.formatForCodeCapital»';
            ");

            $conn->executeQuery("UPDATE $dbName.hook_runtime
                                 SET sowner = '«appName»'
                                 WHERE sowner = '«name.formatForCodeCapital»';
            ");

            $componentLength = strlen('«name.formatForDB»') + 1;
            $conn->executeQuery("UPDATE $dbName.hook_runtime
                                 SET eventname = CONCAT('«appName.formatForDB»', SUBSTRING(eventname, $componentLength))
                                 WHERE eventname LIKE '«name.formatForDB»%';
            ");

            $conn->executeQuery("UPDATE $dbName.hook_subscriber
                                 SET owner = '«appName»'
                                 WHERE owner = '«name.formatForCodeCapital»';
            ");

            $componentLength = strlen('«name.formatForDB»') + 1;
            $conn->executeQuery("UPDATE $dbName.hook_subscriber
                                 SET eventname = CONCAT('«appName.formatForDB»', SUBSTRING(eventname, $componentLength))
                                 WHERE eventname LIKE '«name.formatForDB»%';
            ");
        }

    '''

    def private getConnection(Application it) '''
        /**
         * Returns connection to the database.
         *
         * @return Connection the current connection.
         */
        protected function getConnection()
        {
            $em = $this->entityManager;
            $conn = $em->getConnection();

            return $conn;
        }

    '''

    def private getDbName(Application it) '''
        /**
         * Returns the name of the default system database.
         *
         * @return string the database name.
         */
        protected function getDbName()
        {
            return $this->getContainer()->getParameter('database_name');
        }

    '''
}
