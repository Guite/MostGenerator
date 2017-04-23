package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.base.Objects;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.Variable;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ExampleData;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.MigrationHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ModVars;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Installer {
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  /**
   * Entry point for application installer.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus = (_appSourceLibPath + _formatForCodeCapital);
    String _plus_1 = (_plus + "ModuleInstaller.php");
    this._namingExtensions.generateClassPair(it, fsa, _plus_1, 
      this.fh.phpFileContent(it, this.installerBaseClass(it)), this.fh.phpFileContent(it, this.installerImpl(it)));
  }
  
  private CharSequence installerBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append("\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
      boolean _not = (!_isSystemModule);
      if (_not) {
        _builder.append("use Doctrine\\DBAL\\Connection;");
        _builder.newLine();
      }
    }
    _builder.append("use RuntimeException;");
    _builder.newLine();
    _builder.append("use Zikula\\Core\\AbstractExtensionInstaller;");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      boolean _not_1 = (!(_targets).booleanValue());
      if (_not_1) {
        _builder.append("use Zikula_Workflow_Util;");
        _builder.newLine();
      }
    }
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.append("use Zikula\\CategoriesModule\\Entity\\CategoryRegistryEntity;");
        _builder.newLine();
      }
    }
    {
      if (((this._utils.targets(it, "1.5")).booleanValue() && (this._generatorSettingsExtensions.amountOfExampleRows(it) > 0))) {
        _builder.append("use Zikula\\UsersModule\\Constant as UsersConstant;");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Installer base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("ModuleInstaller extends AbstractExtensionInstaller");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _installerBaseImpl = this.installerBaseImpl(it);
    _builder.append(_installerBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence installerBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _funcInit = this.funcInit(it);
    _builder.append(_funcInit);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcUpdate = this.funcUpdate(it);
    _builder.append(_funcUpdate);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcDelete = this.funcDelete(it);
    _builder.append(_funcDelete);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcListEntityClasses = this.funcListEntityClasses(it);
    _builder.append(_funcListEntityClasses);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _generate = new ExampleData().generate(it);
    _builder.append(_generate);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence funcInit(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Install the ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(" application.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True on success, or false");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if database tables can not be created or another error occurs");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function install()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logger = $this->container->get(\'logger\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$userName = $this->container->get(\'zikula_users_module.current_user\')->get(\'uname\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    CharSequence _processUploadFolders = this.processUploadFolders(it);
    _builder.append(_processUploadFolders, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// create all tables from according entity definitions");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->schemaTool->create($this->listEntityClasses());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'error\', $this->__(\'Doctrine Exception\') . \': \' . $e->getMessage());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$logger->error(\'{app}: Could not create the database tables during installation. Error details: {errorMessage}.\', [\'app\' => \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append("\', \'errorMessage\' => $e->getMessage()]);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isEmpty = it.getVariables().isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// set up all our vars with initial values");
        _builder.newLine();
        _builder.append("    ");
        final ModVars modvarHelper = new ModVars();
        _builder.newLineIfNotEmpty();
        {
          List<Variable> _allVariables = this._utils.getAllVariables(it);
          for(final Variable modvar : _allVariables) {
            _builder.append("    ");
            _builder.append("$this->setVar(\'");
            String _formatForCode = this._formattingExtensions.formatForCode(modvar.getName());
            _builder.append(_formatForCode, "    ");
            _builder.append("\', ");
            CharSequence _valDirect2Mod = modvarHelper.valDirect2Mod(modvar);
            _builder.append(_valDirect2Mod, "    ");
            _builder.append(");");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$categoryRegistryIdsPerEntity = [];");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// add default entry for category registry (property named Main)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$categoryHelper = new \\");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\Helper\\CategoryHelper(");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->container->get(\'translator.default\'),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->container->get(\'session\'),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->container->get(\'request_stack\'),");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$logger,");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->container->get(\'zikula_users_module.current_user\'),");
        _builder.newLine();
        {
          Boolean _targets = this._utils.targets(it, "1.5");
          if ((_targets).booleanValue()) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$this->container->get(\'zikula_categories_module.category_registry_repository\'),");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$this->container->get(\'zikula_categories_module.api.category_registry\'),");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->container->get(\'zikula_categories_module.api.category_permission\')");
        _builder.newLine();
        _builder.append("    ");
        _builder.append(");");
        _builder.newLine();
        {
          Boolean _targets_1 = this._utils.targets(it, "1.5");
          if ((_targets_1).booleanValue()) {
            _builder.append("    ");
            _builder.append("$categoryGlobal = $this->container->get(\'zikula_categories_module.category_repository\')->findOneByName(\'Global\');");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$categoryGlobal = $this->container->get(\'zikula_categories_module.api.category\')->getCategoryByPath(\'/__SYSTEM__/Modules/Global\');");
            _builder.newLine();
          }
        }
        {
          Iterable<Entity> _categorisableEntities = this._modelBehaviourExtensions.getCategorisableEntities(it);
          for(final Entity entity : _categorisableEntities) {
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$registry = new CategoryRegistryEntity();");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$registry->setModname(\'");
            String _appName_2 = this._utils.appName(it);
            _builder.append(_appName_2, "    ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$registry->setEntityname(\'");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
            _builder.append(_formatForCodeCapital, "    ");
            _builder.append("Entity\');");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$registry->setProperty($categoryHelper->getPrimaryProperty(\'");
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(entity.getName());
            _builder.append(_formatForCodeCapital_1, "    ");
            _builder.append("\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$registry->setCategory_Id($categoryGlobal[\'id\']);");
            _builder.newLine();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("try {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$entityManager = $this->container->get(\'");
            String _entityManagerService = this._namingExtensions.entityManagerService(it);
            _builder.append(_entityManagerService, "        ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$entityManager->persist($registry);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$entityManager->flush();");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("} catch (\\Exception $e) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$this->addFlash(\'error\', $this->__f(\'Error! Could not create a category registry for the %entity% entity.\', [\'%entity%\' => \'");
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(entity.getName());
            _builder.append(_formatForDisplay, "        ");
            _builder.append("\']));");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$logger->error(\'{app}: User {user} could not create a category registry for {entities} during installation. Error details: {errorMessage}.\', [\'app\' => \'");
            String _appName_3 = this._utils.appName(it);
            _builder.append(_appName_3, "        ");
            _builder.append("\', \'user\' => $userName, \'entities\' => \'");
            String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(entity.getNameMultiple());
            _builder.append(_formatForDisplay_1, "        ");
            _builder.append("\', \'errorMessage\' => $e->getMessage()]);");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$categoryRegistryIdsPerEntity[\'");
            String _formatForCode_1 = this._formattingExtensions.formatForCode(entity.getName());
            _builder.append(_formatForCode_1, "    ");
            _builder.append("\'] = $registry->getId();");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// create the default data");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->createDefaultData(");
    {
      boolean _hasCategorisableEntities_1 = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities_1) {
        _builder.append("$categoryRegistryIdsPerEntity");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.append("    ");
        _builder.append("// install subscriber hooks");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->hookApi->installSubscriberHooks($this->bundle->getMetaData());");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// initialisation successful");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence processUploadFolders(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.append("// Check if upload directories exist and if needed create them");
        _builder.newLine();
        _builder.append("try {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$container = $this->container;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$uploadHelper = new \\");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "    ");
        _builder.append("\\Helper\\UploadHelper($container->get(\'translator.default\'), $container->get(\'session\'), $container->get(\'liip_imagine.cache.manager\'), $container->get(\'logger\'), $container->get(\'zikula_users_module.current_user\'), $container->get(\'zikula_extensions_module.api.variable\'), $container->getParameter(\'datadir\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$uploadHelper->checkAndCreateAllUploadFolders();");
        _builder.newLine();
        _builder.append("} catch (\\Exception $e) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->addFlash(\'error\', $e->getMessage());");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$logger->error(\'{app}: User {user} could not create upload folders during installation. Error details: {errorMessage}.\', [\'app\' => \'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("\', \'user\' => $userName, \'errorMessage\' => $e->getMessage()]);");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return false;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence funcUpdate(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Upgrade the ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(" application from an older version.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* If the upgrade fails at some point, it returns the last upgraded version.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $oldVersion Version to upgrade from");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True on success, false otherwise");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if database tables can not be updated");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function upgrade($oldVersion)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("/*");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logger = $this->container->get(\'logger\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Upgrade dependent on old version number");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($oldVersion) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'1.0.0\':");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// do something");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// ...");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// update the database schema");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->schemaTool->update($this->listEntityClasses());");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->addFlash(\'error\', $this->__(\'Doctrine Exception\') . \': \' . $e->getMessage());");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$logger->error(\'{app}: Could not update the database tables during the upgrade. Error details: {errorMessage}.\', [\'app\' => \'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "                ");
    _builder.append("\', \'errorMessage\' => $e->getMessage()]);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isSystemModule = this._generatorSettingsExtensions.isSystemModule(it);
      boolean _not = (!_isSystemModule);
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// Note there are several helpers available for making migrating your extension from Zikula 1.3 to 1.4 easier.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// The following convenience methods are each responsible for a single aspect of upgrading to Zikula 1.4.x.");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// here is a possible usage example");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// of course 1.2.3 should match the number you used for the last stable 1.3.x module version.");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("/* if ($oldVersion = \'1.2.3\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        CharSequence _generateUsageExample = new MigrationHelper().generateUsageExample(it);
        _builder.append(_generateUsageExample, "        ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("} * /");
        _builder.newLine();
      }
    }
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// update successful");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isSystemModule_1 = this._generatorSettingsExtensions.isSystemModule(it);
      boolean _not_1 = (!_isSystemModule_1);
      if (_not_1) {
        _builder.newLine();
        CharSequence _generate = new MigrationHelper().generate(it);
        _builder.append(_generate);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence funcDelete(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Uninstall ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True on success, false otherwise");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws RuntimeException Thrown if database tables or stored workflows can not be removed");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function uninstall()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logger = $this->container->get(\'logger\');");
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(it, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// delete stored object workflows");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$result = Zikula_Workflow_Util::deleteWorkflowsForModule(\'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("if (false === $result) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$this->addFlash(\'error\', $this->__f(\'An error was encountered while removing stored object workflows for the %extension% extension.\', [\'%extension%\' => \'");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "        ");
        _builder.append("\']));");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$logger->error(\'{app}: Could not remove stored object workflows during uninstallation.\', [\'app\' => \'");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "        ");
        _builder.append("\']);");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("return false;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->schemaTool->drop($this->listEntityClasses());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'error\', $this->__(\'Doctrine Exception\') . \': \' . $e->getMessage());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$logger->error(\'{app}: Could not remove the database tables during uninstallation. Error details: {errorMessage}.\', [\'app\' => \'");
    String _appName_4 = this._utils.appName(it);
    _builder.append(_appName_4, "        ");
    _builder.append("\', \'errorMessage\' => $e->getMessage()]);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(it);
      if (_hasHookSubscribers) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// uninstall subscriber hooks");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->hookApi->uninstallSubscriberHooks($this->bundle->getMetaData());");
        _builder.newLine();
      }
    }
    {
      boolean _isEmpty = this._utils.getAllVariables(it).isEmpty();
      boolean _not_1 = (!_isEmpty);
      if (_not_1) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// remove all module vars");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->delVars();");
        _builder.newLine();
      }
    }
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// remove category registry entries");
        _builder.newLine();
        {
          Boolean _targets_1 = this._utils.targets(it, "1.5");
          if ((_targets_1).booleanValue()) {
            _builder.append("    ");
            _builder.append("$entityManager = $this->container->get(\'");
            String _entityManagerService = this._namingExtensions.entityManagerService(it);
            _builder.append(_entityManagerService, "    ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$registries = $this->container->get(\'zikula_categories_module.category_registry_repository\')->findBy([\'modname\' => \'");
            String _appName_5 = this._utils.appName(it);
            _builder.append(_appName_5, "    ");
            _builder.append("\']);");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("foreach ($registries as $registry) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$entityManager->remove($registry);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$entityManager->flush();");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("$categoryRegistryApi = $this->container->get(\'zikula_categories_module.api.category_registry\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("// assume that not more than five registries exist");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("for ($i = 1; $i <= 5; $i++) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$categoryRegistryApi->deleteRegistry(\'");
            String _appName_6 = this._utils.appName(it);
            _builder.append(_appName_6, "        ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.newLine();
        {
          boolean _hasImageFields = this._modelExtensions.hasImageFields(it);
          if (_hasImageFields) {
            _builder.append("    ");
            _builder.append("// remove all thumbnails");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$manager = $this->container->get(\'systemplugin.imagine.manager\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$manager->setModule(\'");
            String _appName_7 = this._utils.appName(it);
            _builder.append(_appName_7, "    ");
            _builder.append("\');");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$manager->cleanupModuleThumbs();");
            _builder.newLine();
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("// remind user about upload folders not being deleted");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$uploadPath = $this->container->getParameter(\'datadir\') . \'/");
        String _appName_8 = this._utils.appName(it);
        _builder.append(_appName_8, "    ");
        _builder.append("/\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$this->addFlash(\'status\', $this->__f(\'The upload directories at \"%path%\" can be removed manually.\', [\'%path%\' => $uploadPath]));");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// uninstallation successful");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence funcListEntityClasses(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Build array with all entity classes for ");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array list of class names");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function listEntityClasses()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$classNames = [];");
    _builder.newLine();
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("    ");
        _builder.append("$classNames[] = \'");
        String _entityClassName = this._namingExtensions.entityClassName(entity, "", Boolean.valueOf(false));
        _builder.append(_entityClassName, "    ");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        {
          boolean _isLoggable = entity.isLoggable();
          if (_isLoggable) {
            _builder.append("    ");
            _builder.append("$classNames[] = \'");
            String _entityClassName_1 = this._namingExtensions.entityClassName(entity, "logEntry", Boolean.valueOf(false));
            _builder.append(_entityClassName_1, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          EntityTreeType _tree = entity.getTree();
          boolean _equals = Objects.equal(_tree, EntityTreeType.CLOSURE);
          if (_equals) {
            _builder.append("    ");
            _builder.append("$classNames[] = \'");
            String _entityClassName_2 = this._namingExtensions.entityClassName(entity, "closure", Boolean.valueOf(false));
            _builder.append(_entityClassName_2, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasTranslatableFields = this._modelBehaviourExtensions.hasTranslatableFields(entity);
          if (_hasTranslatableFields) {
            _builder.append("    ");
            _builder.append("$classNames[] = \'");
            String _entityClassName_3 = this._namingExtensions.entityClassName(entity, "translation", Boolean.valueOf(false));
            _builder.append(_entityClassName_3, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isAttributable = entity.isAttributable();
          if (_isAttributable) {
            _builder.append("    ");
            _builder.append("$classNames[] = \'");
            String _entityClassName_4 = this._namingExtensions.entityClassName(entity, "attribute", Boolean.valueOf(false));
            _builder.append(_entityClassName_4, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isCategorisable = entity.isCategorisable();
          if (_isCategorisable) {
            _builder.append("    ");
            _builder.append("$classNames[] = \'");
            String _entityClassName_5 = this._namingExtensions.entityClassName(entity, "category", Boolean.valueOf(false));
            _builder.append(_entityClassName_5, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $classNames;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence installerImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(it);
    _builder.append(_appNamespace);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(it);
    _builder.append(_appNamespace_1);
    _builder.append("\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("ModuleInstaller;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Installer implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("ModuleInstaller extends Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("ModuleInstaller");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the installer here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
