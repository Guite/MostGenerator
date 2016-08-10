package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MigrationHelper {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generateUsageExample(Application it) '''
        «IF !variables.empty»
            // rename module for all modvars
            $this->updateModVarsTo140();

        «ENDIF»
        // update extension information about this app
        $this->updateExtensionInfoFor140();

        // rename existing permission rules
        $this->renamePermissionsFor140();
        «IF hasCategorisableEntities»

            // rename existing category registries
            $this->renameCategoryRegistriesFor140();
        «ENDIF»

        // rename all tables
        $this->renameTablesFor140();

        // remove event handler definitions from database
        $this->dropEventHandlersFromDatabase();
        «IF hasHookSubscribers»

            // update module name in the hook tables
            $this->updateHookNamesFor140();
        «ENDIF»

        // update module name in the workflows table
        $this->updateWorkflowsFor140();
    '''

    def generate(Application it) '''
        «IF !variables.empty»
            «updateModVarsTo140»

        «ENDIF»
        «updateExtensionInfoFor140»

        «renamePermissionsFor140»

        «IF hasCategorisableEntities»
            «renameCategoryRegistriesFor140»

        «ENDIF»
        «renameTablesFor140»

        «dropEventHandlersFromDatabase»

        «IF hasHookSubscribers»
            «updateHookNamesFor140»

        «ENDIF»
        «updateWorkflowsFor140»

        «getConnection»

        «getDbName»
    '''

    def private updateModVarsTo140(Application it) '''
        /**
         * Renames the module name for variables in the module_vars table.
         */
        protected function updateModVarsTo140()
        {
            $dbName = $this->getDbName();
            $conn = $this->getConnection();

            $conn->executeQuery("UPDATE $dbName.module_vars
                                 SET modname = '«appName»'
                                 WHERE modname = '«name.formatForCodeCapital»';
            ");
        }
    '''

    def private updateExtensionInfoFor140(Application it) '''
        /**
         * Renames this application in the core's extensions table.
         */
        protected function updateExtensionInfoFor140()
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

    def private renamePermissionsFor140(Application it) '''
        /**
         * Renames all permission rules stored for this app.
         */
        protected function renamePermissionsFor140()
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

    def private renameCategoryRegistriesFor140(Application it) '''
        /**
         * Renames all category registries stored for this app.
         */
        protected function renameCategoryRegistriesFor140()
        {
            $conn = $this->getConnection();
            $dbName = $this->getDbName();

            $componentLength = strlen('«name.formatForCodeCapital»') + 1;

            $conn->executeQuery("UPDATE $dbName.categories_registry
                                 SET modname = CONCAT('«appName»', SUBSTRING(modname, $componentLength))
                                 WHERE modname LIKE '«name.formatForCodeCapital»%';
            ");
        }
    '''

    def private renameTablesFor140(Application it) '''
        /**
         * Renames all (existing) tables of this app.
         */
        protected function renameTablesFor140()
        {
            $conn = $this->getConnection();
            $dbName = $this->getDbName();

            $oldPrefix = '«prefix()»_';
            $oldPrefixLength = strlen($oldPrefix);
            $newPrefix = '«vendor.formatForDB»_«prefix()»_';

            $sm = $conn->getSchemaManager();
            $tables = $sm->listTables();
            foreach ($tables as $table) {
                $tableName = $table->getName();
                if (substr($tableName, 0, $oldPrefixLength) != $oldPrefix) {
                    continue;
                }

                $newTableName = str_replace($oldPrefix, $newPrefix, $tableName);

                $conn->executeQuery("RENAME TABLE $dbName.$tableName
                                     TO $dbName.$newTableName;
                ");
            }
        }
    '''

    def private dropEventHandlersFromDatabase(Application it) '''
        /**
         * Removes event handlers from database as they are now described by service definitions and managed by dependency injection.
         */
        protected function dropEventHandlersFromDatabase()
        {
            EventUtil::unregisterPersistentModuleHandlers('«name.formatForCodeCapital»');
        }
    '''

    def private updateHookNamesFor140(Application it) '''
        /**
         * Updates the module name in the hook tables.
         */
        protected function updateHookNamesFor140()
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

    def private updateWorkflowsFor140(Application it) '''
        /**
         * Updates the module name in the workflows table.
         */
        protected function updateWorkflowsFor140()
        {
            $conn = $this->getConnection();
            $dbName = $this->getDbName();

            $conn->executeQuery("UPDATE $dbName.workflows
                                 SET module = '«appName»'
                                 WHERE module = '«name.formatForCodeCapital»';
            ");
        }
    '''

    def private getConnection(Application it) '''
        /**
         * Returns connection to the database.
         *
         * @return Connection the current connection
         */
        protected function getConnection()
        {
            $entityManager = $this->container->get('doctrine.entitymanager');
            $connection = $entityManager->getConnection();

            return $connection;
        }
    '''

    def private getDbName(Application it) '''
        /**
         * Returns the name of the default system database.
         *
         * @return string the database name
         */
        protected function getDbName()
        {
            return $this->container->getParameter('database_name');
        }
    '''
}