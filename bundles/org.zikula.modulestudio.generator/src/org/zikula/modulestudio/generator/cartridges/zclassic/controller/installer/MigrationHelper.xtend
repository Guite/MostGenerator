package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MigrationHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generateUsageExample(Application it) '''
        «IF !variables.empty»
            // rename module for all modvars
            $this->updateModVarsTo14();

        «ENDIF»
        // update extension information about this app
        $this->updateExtensionInfoFor14();

        // rename existing permission rules
        $this->renamePermissionsFor14();
        «IF hasCategorisableEntities»

            // rename existing category registries
            $this->renameCategoryRegistriesFor14();
        «ENDIF»

        // rename all tables
        $this->renameTablesFor14();

        // remove event handler definitions from database
        $this->dropEventHandlersFromDatabase();
        «IF hasHookSubscribers»

            // update module name in the hook tables
            $this->updateHookNamesFor14();
        «ENDIF»

        // update module name in the workflows table
        $this->updateWorkflowsFor14();
    '''

    def generate(Application it) '''
        «IF !variables.empty»
            «updateModVarsTo14»

        «ENDIF»
        «updateExtensionInfoFor14»

        «renamePermissionsFor14»

        «IF hasCategorisableEntities»
            «renameCategoryRegistriesFor14»

        «ENDIF»
        «renameTablesFor14»

        «dropEventHandlersFromDatabase»

        «IF hasHookSubscribers»
            «updateHookNamesFor14»

        «ENDIF»
        «updateWorkflowsFor14»

        «getConnection»
    '''

    def private updateModVarsTo14(Application it) '''
        /**
         * Renames the module name for variables in the module_vars table.
         */
        protected function updateModVarsTo14()
        {
            $conn = $this->getConnection();
            $conn->update('module_vars', ['modname' => '«appName»'], ['modname' => '«name.formatForCodeCapital»']);
        }
    '''

    def private updateExtensionInfoFor14(Application it) '''
        /**
         * Renames this application in the core's extensions table.
         */
        protected function updateExtensionInfoFor14()
        {
            $conn = $this->getConnection();
            $conn->update('modules', ['name' => '«appName»', 'directory' => '«vendor.formatForCodeCapital»/«name.formatForCodeCapital»Module'], ['name' => '«name.formatForCodeCapital»']);
        }
    '''

    def private renamePermissionsFor14(Application it) '''
        /**
         * Renames all permission rules stored for this app.
         */
        protected function renamePermissionsFor14()
        {
            $conn = $this->getConnection();
            $componentLength = strlen('«name.formatForCodeCapital»') + 1;

            $conn->executeQuery("
                UPDATE group_perms
                SET component = CONCAT('«appName»', SUBSTRING(component, $componentLength))
                WHERE component LIKE '«name.formatForCodeCapital»%';
            ");
        }
    '''

    def private renameCategoryRegistriesFor14(Application it) '''
        /**
         * Renames all category registries stored for this app.
         */
        protected function renameCategoryRegistriesFor14()
        {
            $conn = $this->getConnection();
            $componentLength = strlen('«name.formatForCodeCapital»') + 1;

            $conn->executeQuery("
                UPDATE categories_registry
                SET modname = CONCAT('«appName»', SUBSTRING(modname, $componentLength))
                WHERE modname LIKE '«name.formatForCodeCapital»%';
            ");
        }
    '''

    def private renameTablesFor14(Application it) '''
        /**
         * Renames all (existing) tables of this app.
         */
        protected function renameTablesFor14()
        {
            $conn = $this->getConnection();

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

                $conn->executeQuery("
                    RENAME TABLE $tableName
                    TO $newTableName;
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
            \EventUtil::unregisterPersistentModuleHandlers('«name.formatForCodeCapital»');
        }
    '''

    def private updateHookNamesFor14(Application it) '''
        /**
         * Updates the module name in the hook tables.
         */
        protected function updateHookNamesFor14()
        {
            $conn = $this->getConnection();

            $conn->update('hook_area', ['owner' => '«appName»'], ['owner' => '«name.formatForCodeCapital»']);

            $componentLength = strlen('subscriber.«name.formatForDB»') + 1;
            $conn->executeQuery("
                UPDATE hook_area
                SET areaname = CONCAT('subscriber.«appName.formatForDB»', SUBSTRING(areaname, $componentLength))
                WHERE areaname LIKE 'subscriber.«name.formatForDB»%';
            ");

            $conn->update('hook_binding', ['sowner' => '«appName»'], ['sowner' => '«name.formatForCodeCapital»']);

            $conn->update('hook_runtime', ['sowner' => '«appName»'], ['sowner' => '«name.formatForCodeCapital»']);

            $componentLength = strlen('«name.formatForDB»') + 1;
            $conn->executeQuery("
                UPDATE hook_runtime
                SET eventname = CONCAT('«appName.formatForDB»', SUBSTRING(eventname, $componentLength))
                WHERE eventname LIKE '«name.formatForDB»%';
            ");

            $conn->update('hook_subscriber', ['owner' => '«appName»'], ['owner' => '«name.formatForCodeCapital»']);

            $componentLength = strlen('«name.formatForDB»') + 1;
            $conn->executeQuery("
                UPDATE hook_subscriber
                SET eventname = CONCAT('«appName.formatForDB»', SUBSTRING(eventname, $componentLength))
                WHERE eventname LIKE '«name.formatForDB»%';
            ");
        }
    '''

    def private updateWorkflowsFor14(Application it) '''
        /**
         * Updates the module name in the workflows table.
         */
        protected function updateWorkflowsFor14()
        {
            $conn = $this->getConnection();
            $conn->update('workflows', ['module' => '«appName»'], ['module' => '«name.formatForCodeCapital»']);
            «FOR entity : getAllEntities»
                $conn->update('workflows', ['obj_table' => '«entity.name.formatForCodeCapital»Entity'], ['module' => '«appName»', 'obj_table' => '«entity.name.formatForCode»']);
            «ENDFOR»
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
            $entityManager = $this->container->get('«entityManagerService»');

            return $entityManager->getConnection();
        }
    '''
}
