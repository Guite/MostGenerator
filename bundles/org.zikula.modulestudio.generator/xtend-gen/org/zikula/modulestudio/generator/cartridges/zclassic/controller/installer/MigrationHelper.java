package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class MigrationHelper {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence generateUsageExample(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isEmpty = it.getVariables().isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.append("// rename module for all modvars");
        _builder.newLine();
        _builder.append("$this->updateModVarsTo14();");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("// update extension information about this app");
    _builder.newLine();
    _builder.append("$this->updateExtensionInfoFor14();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// rename existing permission rules");
    _builder.newLine();
    _builder.append("$this->renamePermissionsFor14();");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("// rename existing category registries");
        _builder.newLine();
        _builder.append("$this->renameCategoryRegistriesFor14();");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("// rename all tables");
    _builder.newLine();
    _builder.append("$this->renameTablesFor14();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// remove event handler definitions from database");
    _builder.newLine();
    _builder.append("$this->dropEventHandlersFromDatabase();");
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.newLine();
        _builder.append("// update module name in the hook tables");
        _builder.newLine();
        _builder.append("$this->updateHookNamesFor14();");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("// update module name in the workflows table");
    _builder.newLine();
    _builder.append("$this->updateWorkflowsFor14();");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence generate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isEmpty = it.getVariables().isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        CharSequence _updateModVarsTo14 = this.updateModVarsTo14(it);
        _builder.append(_updateModVarsTo14);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _updateExtensionInfoFor14 = this.updateExtensionInfoFor14(it);
    _builder.append(_updateExtensionInfoFor14);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _renamePermissionsFor14 = this.renamePermissionsFor14(it);
    _builder.append(_renamePermissionsFor14);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        CharSequence _renameCategoryRegistriesFor14 = this.renameCategoryRegistriesFor14(it);
        _builder.append(_renameCategoryRegistriesFor14);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _renameTablesFor14 = this.renameTablesFor14(it);
    _builder.append(_renameTablesFor14);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _dropEventHandlersFromDatabase = this.dropEventHandlersFromDatabase(it);
    _builder.append(_dropEventHandlersFromDatabase);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        CharSequence _updateHookNamesFor14 = this.updateHookNamesFor14(it);
        _builder.append(_updateHookNamesFor14);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    CharSequence _updateWorkflowsFor14 = this.updateWorkflowsFor14(it);
    _builder.append(_updateWorkflowsFor14);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _connection = this.getConnection(it);
    _builder.append(_connection);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _dbName = this.getDbName(it);
    _builder.append(_dbName);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence updateModVarsTo14(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Renames the module name for variables in the module_vars table.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function updateModVarsTo14()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dbName = $this->getDbName();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn = $this->getConnection();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.module_vars");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET modname = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE modname = \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence updateExtensionInfoFor14(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Renames this application in the core\'s extensions table.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function updateExtensionInfoFor14()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn = $this->getConnection();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dbName = $this->getDbName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.modules");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET name = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("directory = \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getVendor());
    _builder.append(_formatForCodeCapital, "            ");
    _builder.append("/");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "            ");
    _builder.append("Module\'");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE name = \'");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence renamePermissionsFor14(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Renames all permission rules stored for this app.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function renamePermissionsFor14()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn = $this->getConnection();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dbName = $this->getDbName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$componentLength = strlen(\'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\') + 1;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.group_perms");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET component = CONCAT(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\', SUBSTRING(component, $componentLength))");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE component LIKE \'");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "        ");
    _builder.append("%\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence renameCategoryRegistriesFor14(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Renames all category registries stored for this app.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function renameCategoryRegistriesFor14()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn = $this->getConnection();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dbName = $this->getDbName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$componentLength = strlen(\'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\') + 1;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.categories_registry");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET modname = CONCAT(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\', SUBSTRING(modname, $componentLength))");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE modname LIKE \'");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "        ");
    _builder.append("%\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence renameTablesFor14(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Renames all (existing) tables of this app.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function renameTablesFor14()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn = $this->getConnection();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dbName = $this->getDbName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$oldPrefix = \'");
    String _prefix = this._utils.prefix(it);
    _builder.append(_prefix, "    ");
    _builder.append("_\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$oldPrefixLength = strlen($oldPrefix);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$newPrefix = \'");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getVendor());
    _builder.append(_formatForDB, "    ");
    _builder.append("_");
    String _prefix_1 = this._utils.prefix(it);
    _builder.append(_prefix_1, "    ");
    _builder.append("_\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sm = $conn->getSchemaManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tables = $sm->listTables();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($tables as $table) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$tableName = $table->getName();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (substr($tableName, 0, $oldPrefixLength) != $oldPrefix) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$newTableName = str_replace($oldPrefix, $newPrefix, $tableName);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("RENAME TABLE $dbName.$tableName");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("TO $dbName.$newTableName;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\");");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence dropEventHandlersFromDatabase(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Removes event handlers from database as they are now described by service definitions and managed by dependency injection.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function dropEventHandlersFromDatabase()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\\EventUtil::unregisterPersistentModuleHandlers(\'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence updateHookNamesFor14(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Updates the module name in the hook tables.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function updateHookNamesFor14()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn = $this->getConnection();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dbName = $this->getDbName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.hook_area");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET owner = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE owner = \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$componentLength = strlen(\'subscriber.");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB, "    ");
    _builder.append("\') + 1;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.hook_area");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET areaname = CONCAT(\'subscriber.");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "        ");
    _builder.append("\', SUBSTRING(areaname, $componentLength))");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE areaname LIKE \'subscriber.");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_2, "        ");
    _builder.append("%\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.hook_binding");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET sowner = \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE sowner = \'");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.hook_runtime");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET sowner = \'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "        ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE sowner = \'");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$componentLength = strlen(\'");
    String _formatForDB_3 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_3, "    ");
    _builder.append("\') + 1;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.hook_runtime");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET eventname = CONCAT(\'");
    String _formatForDB_4 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_4, "        ");
    _builder.append("\', SUBSTRING(eventname, $componentLength))");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE eventname LIKE \'");
    String _formatForDB_5 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_5, "        ");
    _builder.append("%\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.hook_subscriber");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET owner = \'");
    String _appName_3 = this._utils.appName(it);
    _builder.append(_appName_3, "        ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE owner = \'");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$componentLength = strlen(\'");
    String _formatForDB_6 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_6, "    ");
    _builder.append("\') + 1;");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.hook_subscriber");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET eventname = CONCAT(\'");
    String _formatForDB_7 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_7, "        ");
    _builder.append("\', SUBSTRING(eventname, $componentLength))");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE eventname LIKE \'");
    String _formatForDB_8 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_8, "        ");
    _builder.append("%\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence updateWorkflowsFor14(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Updates the module name in the workflows table.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function updateWorkflowsFor14()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn = $this->getConnection();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$dbName = $this->getDbName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$conn->executeQuery(\"");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("UPDATE $dbName.workflows");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("SET module = \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\'");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("WHERE module = \'");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\");");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getConnection(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns connection to the database.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Connection the current connection");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getConnection()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager = $this->container->get(\'");
    String _entityManagerService = this._namingExtensions.entityManagerService(it);
    _builder.append(_entityManagerService, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$connection = $entityManager->getConnection();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $connection;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getDbName(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Returns the name of the default system database.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return string the database name");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function getDbName()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->container->getParameter(\'database_name\');");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
