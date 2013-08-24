package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType;
import de.guite.modulestudio.metamodel.modulestudio.Variable;
import de.guite.modulestudio.metamodel.modulestudio.Variables;
import java.util.List;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.EventListener;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ExampleData;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.Interactive;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer.ModVars;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.InstallerView;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Installer {
  @Inject
  @Extension
  private FormattingExtensions _formattingExtensions = new Function0<FormattingExtensions>() {
    public FormattingExtensions apply() {
      FormattingExtensions _formattingExtensions = new FormattingExtensions();
      return _formattingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private NamingExtensions _namingExtensions = new Function0<NamingExtensions>() {
    public NamingExtensions apply() {
      NamingExtensions _namingExtensions = new NamingExtensions();
      return _namingExtensions;
    }
  }.apply();
  
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
  /**
   * Entry point for application installer.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      String _name = it.getName();
      String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
      String _plus = (_formatForCodeCapital + "Module");
      _xifexpression = _plus;
    } else {
      _xifexpression = "";
    }
    final String installerPrefix = _xifexpression;
    final String installerFileName = (installerPrefix + "Installer.php");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath + "Base/");
    String _plus_2 = (_plus_1 + installerFileName);
    CharSequence _installerBaseFile = this.installerBaseFile(it);
    fsa.generateFile(_plus_2, _installerBaseFile);
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_3 = (_appSourceLibPath_1 + installerFileName);
    CharSequence _installerFile = this.installerFile(it);
    fsa.generateFile(_plus_3, _installerFile);
    boolean _isInteractiveInstallation = it.isInteractiveInstallation();
    boolean _equals = (_isInteractiveInstallation == true);
    if (_equals) {
      String _appSourceLibPath_2 = this._namingExtensions.getAppSourceLibPath(it);
      final String controllerPath = (_appSourceLibPath_2 + "Controller/");
      String _xifexpression_1 = null;
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_1);
      if (_not_1) {
        _xifexpression_1 = "Controller";
      } else {
        _xifexpression_1 = "";
      }
      final String controllerClassSuffix = _xifexpression_1;
      String _plus_4 = ("InteractiveInstaller" + controllerClassSuffix);
      final String controllerFileName = (_plus_4 + ".php");
      String _plus_5 = (controllerPath + "Base/");
      String _plus_6 = (_plus_5 + controllerFileName);
      CharSequence _interactiveBaseFile = this.interactiveBaseFile(it);
      fsa.generateFile(_plus_6, _interactiveBaseFile);
      String _plus_7 = (controllerPath + controllerFileName);
      CharSequence _interactiveFile = this.interactiveFile(it);
      fsa.generateFile(_plus_7, _interactiveFile);
      InstallerView _installerView = new InstallerView();
      _installerView.generate(it, fsa);
    }
  }
  
  private CharSequence installerBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _installerBaseClass = this.installerBaseClass(it);
    _builder.append(_installerBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence installerFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _installerImpl = this.installerImpl(it);
    _builder.append(_installerImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence installerBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        {
          boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
          if (_hasCategorisableEntities) {
            _builder.append("use CategoryUtil;");
            _builder.newLine();
            _builder.append("use CategoryRegistryUtil;");
            _builder.newLine();
            _builder.append("use DBUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use DoctrineHelper;");
        _builder.newLine();
        _builder.append("use EventUtil;");
        _builder.newLine();
        {
          boolean _hasUploads = this._modelExtensions.hasUploads(it);
          if (_hasUploads) {
            _builder.append("use FileUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use HookUtil;");
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use System;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractInstaller;");
        _builder.newLine();
        _builder.append("use Zikula_Workflow_Util;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Installer base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Base_");
      } else {
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
      }
    }
    _builder.append("Installer extends Zikula_AbstractInstaller");
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
  
  private CharSequence interactiveBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _interactiveBaseClass = this.interactiveBaseClass(it);
    _builder.append(_interactiveBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence interactiveFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _interactiveImpl = this.interactiveImpl(it);
    _builder.append(_interactiveImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence interactiveBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Controller\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        {
          boolean _needsConfig = this._utils.needsConfig(it);
          if (_needsConfig) {
            _builder.append("use ModUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        {
          List<Variables> _allVariableContainers = this._utils.getAllVariableContainers(it);
          boolean _isEmpty = _allVariableContainers.isEmpty();
          boolean _not_1 = (!_isEmpty);
          if (_not_1) {
            _builder.append("use SessionUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use Zikula_Controller_AbstractInteractiveInstaller;");
        _builder.newLine();
        _builder.append("use ZLanguage;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Interactive installer base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Controller_Base_InteractiveInstaller extends Zikula_Controller_AbstractInteractiveInstaller");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class InteractiveInstallerController extends Zikula_Controller_AbstractInteractiveInstaller");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Interactive _interactive = new Interactive();
    CharSequence _generate = _interactive.generate(it);
    _builder.append(_generate, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence installerBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _funcInit = this.funcInit(it);
    _builder.append(_funcInit, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcUpdate = this.funcUpdate(it);
    _builder.append(_funcUpdate, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcDelete = this.funcDelete(it);
    _builder.append(_funcDelete, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _funcListEntityClasses = this.funcListEntityClasses(it);
    _builder.append(_funcListEntityClasses, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    ExampleData _exampleData = new ExampleData();
    CharSequence _generate = _exampleData.generate(it);
    _builder.append(_generate, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    EventListener _eventListener = new EventListener();
    CharSequence _generate_1 = _eventListener.generate(it);
    _builder.append(_generate_1, "");
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
    _builder.append("* @return boolean True on success, or false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function install()");
    _builder.newLine();
    _builder.append("{");
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
    _builder.append("DoctrineHelper::createSchema($this->entityManager, $this->listEntityClasses());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (System::isDevelopmentMode()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerError($this->__(\'Doctrine Exception: \') . $e->getMessage());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$returnMessage = $this->__f(\'An error was encountered while creating the tables for the %s extension.\', array($this->name));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!System::isDevelopmentMode()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$returnMessage .= \' \' . $this->__(\'Please enable the development mode by editing the /config/config.php file in order to reveal the error details.\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError($returnMessage);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    {
      List<Variables> _allVariableContainers = this._utils.getAllVariableContainers(it);
      boolean _isEmpty = _allVariableContainers.isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// set up all our vars with initial values");
        _builder.newLine();
        _builder.append("    ");
        ModVars _modVars = new ModVars();
        final ModVars modvarHelper = _modVars;
        _builder.newLineIfNotEmpty();
        {
          List<Variable> _allVariables = this._utils.getAllVariables(it);
          for(final Variable modvar : _allVariables) {
            {
              boolean _isInteractiveInstallation = it.isInteractiveInstallation();
              boolean _equals = (_isInteractiveInstallation == true);
              if (_equals) {
                _builder.append("    ");
                _builder.append("$sessionValue = SessionUtil::getVar(\'");
                String _name = it.getName();
                String _plus = (_name + "_");
                String _name_1 = modvar.getName();
                String _plus_1 = (_plus + _name_1);
                String _formatForCode = this._formattingExtensions.formatForCode(_plus_1);
                _builder.append(_formatForCode, "    ");
                _builder.append("\');");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("$this->setVar(\'");
                String _name_2 = modvar.getName();
                String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_2);
                _builder.append(_formatForCode_1, "    ");
                _builder.append("\', (($sessionValue <> false) ? ");
                CharSequence _valFromSession = modvarHelper.valFromSession(modvar);
                _builder.append(_valFromSession, "    ");
                _builder.append(" : ");
                CharSequence _valSession2Mod = modvarHelper.valSession2Mod(modvar);
                _builder.append(_valSession2Mod, "    ");
                _builder.append("));");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("SessionUtil::delVar(");
                String _name_3 = it.getName();
                String _plus_2 = (_name_3 + "_");
                String _name_4 = modvar.getName();
                String _plus_3 = (_plus_2 + _name_4);
                String _formatForCode_2 = this._formattingExtensions.formatForCode(_plus_3);
                _builder.append(_formatForCode_2, "    ");
                _builder.append(");");
                _builder.newLineIfNotEmpty();
              } else {
                _builder.append("    ");
                _builder.append("$this->setVar(\'");
                String _name_5 = modvar.getName();
                String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_5);
                _builder.append(_formatForCode_3, "    ");
                _builder.append("\', ");
                CharSequence _valDirect2Mod = modvarHelper.valDirect2Mod(modvar);
                _builder.append(_valDirect2Mod, "    ");
                _builder.append(");");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$categoryRegistryIdsPerEntity = array();");
    _builder.newLine();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(it);
      if (_hasCategorisableEntities) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// add default entry for category registry (property named Main)");
        _builder.newLine();
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          if (_targets) {
            _builder.append("    ");
            _builder.append("include_once \'modules/");
            String _appName_1 = this._utils.appName(it);
            _builder.append(_appName_1, "    ");
            _builder.append("/lib/");
            String _appName_2 = this._utils.appName(it);
            _builder.append(_appName_2, "    ");
            _builder.append("/Api/Base/Category.php\';");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("include_once \'modules/");
            String _appName_3 = this._utils.appName(it);
            _builder.append(_appName_3, "    ");
            _builder.append("/lib/");
            String _appName_4 = this._utils.appName(it);
            _builder.append(_appName_4, "    ");
            _builder.append("/Api/Category.php\';");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$categoryApi = new ");
            String _appName_5 = this._utils.appName(it);
            _builder.append(_appName_5, "    ");
            _builder.append("_Api_Category($this->serviceManager);");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("    ");
            _builder.append("include_once \'modules/");
            String _appSourcePath = this._namingExtensions.getAppSourcePath(it);
            _builder.append(_appSourcePath, "    ");
            _builder.append("/Api/Base/CategoryApi.php\';");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("include_once \'modules/");
            String _appSourcePath_1 = this._namingExtensions.getAppSourcePath(it);
            _builder.append(_appSourcePath_1, "    ");
            _builder.append("/Api/CategoryApi.php\';");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$categoryApi = new \\");
            String _appName_6 = this._utils.appName(it);
            _builder.append(_appName_6, "    ");
            _builder.append("\\Api\\CategoryApi($this->serviceManager);");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          Iterable<Entity> _categorisableEntities = this._modelBehaviourExtensions.getCategorisableEntities(it);
          for(final Entity entity : _categorisableEntities) {
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$registryData = array();");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$registryData[\'modname\'] = $this->name;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$registryData[\'table\'] = \'");
            String _name_6 = entity.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name_6);
            _builder.append(_formatForCodeCapital, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$registryData[\'property\'] = $categoryApi->getPrimaryProperty(array(\'ot\' => \'");
            String _name_7 = entity.getName();
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_7);
            _builder.append(_formatForCodeCapital_1, "    ");
            _builder.append("\'));");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("$categoryGlobal = CategoryUtil::getCategoryByPath(\'/__SYSTEM__/Modules/Global\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$registryData[\'category_id\'] = $categoryGlobal[\'id\'];");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$registryData[\'id\'] = false;");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("if (!DBUtil::insertObject($registryData, \'categories_registry\')) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("LogUtil::registerError($this->__f(\'Error! Could not create a category registry for the %s entity.\', array(\'");
            String _name_8 = entity.getName();
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_8);
            _builder.append(_formatForDisplay, "        ");
            _builder.append("\')));");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$categoryRegistryIdsPerEntity[\'");
            String _name_9 = entity.getName();
            String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_9);
            _builder.append(_formatForCode_4, "    ");
            _builder.append("\'] = $registryData[\'id\'];");
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
    _builder.append("$this->createDefaultData($categoryRegistryIdsPerEntity);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// register persistent event handlers");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->registerPersistentEventHandlers();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// register hook subscriber bundles");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("HookUtil::registerSubscriberBundles($this->version->getHookSubscriberBundles());");
    _builder.newLine();
    _builder.append("    ");
    _builder.newLine();
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
        _builder.append("$controllerHelper = new ");
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          if (_targets) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "    ");
            _builder.append("_Util_Controller");
          } else {
            _builder.append("ControllerUtil");
          }
        }
        _builder.append("($this->serviceManager");
        {
          boolean _targets_1 = this._utils.targets(it, "1.3.5");
          boolean _not = (!_targets_1);
          if (_not) {
            _builder.append(", ModUtil::getModule($this->name)");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$controllerHelper->checkAndCreateAllUploadFolders();");
        _builder.newLine();
        _builder.append("} catch (\\Exception $e) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return LogUtil::registerError($e->getMessage());");
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
    _builder.append("* @param integer $oldVersion Version to upgrade from.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return boolean True on success, false otherwise.");
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
    _builder.append("// Upgrade dependent on old version number");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($oldVersion) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case 1.0.0:");
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
    _builder.append("DoctrineHelper::updateSchema($this->entityManager, $this->listEntityClasses());");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("if (System::isDevelopmentMode()) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("LogUtil::registerError($this->__(\'Doctrine Exception: \') . $e->getMessage());");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("return LogUtil::registerError($this->__f(\'An error was encountered while dropping the tables for the %s extension.\', array($this->getName())));");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
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
    _builder.append("* @return boolean True on success, false otherwise.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function uninstall()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// delete stored object workflows");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = Zikula_Workflow_Util::deleteWorkflowsForModule($this->getName());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($result === false) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError($this->__f(\'An error was encountered while removing stored object workflows for the %s extension.\', array($this->getName())));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("DoctrineHelper::dropSchema($this->entityManager, $this->listEntityClasses());");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} catch (\\Exception $e) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (System::isDevelopmentMode()) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerError($this->__(\'Doctrine Exception: \') . $e->getMessage());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return LogUtil::registerError($this->__f(\'An error was encountered while dropping the tables for the %s extension.\', array($this->name)));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// unregister persistent event handlers");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("EventUtil::unregisterPersistentModuleHandlers($this->name);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// unregister hook subscriber bundles");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("HookUtil::unregisterSubscriberBundles($this->version->getHookSubscriberBundles());");
    _builder.newLine();
    _builder.append("    ");
    _builder.newLine();
    {
      List<Variable> _allVariables = this._utils.getAllVariables(it);
      boolean _isEmpty = _allVariables.isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
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
        _builder.append("    ");
        _builder.append("ModUtil::dbInfoLoad(\'Categories\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("DBUtil::deleteWhere(\'categories_registry\', \'modname = \\\'\' . $this->name . \'\\\'\');");
        _builder.newLine();
      }
    }
    {
      boolean _hasUploads = this._modelExtensions.hasUploads(it);
      if (_hasUploads) {
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// remove all thumbnails");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$manager = $this->getServiceManager()->getService(\'systemplugin.imagine.manager\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$manager->setModule($this->name);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$manager->cleanupModuleThumbs();");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// remind user about upload folders not being deleted");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$uploadPath = FileUtil::getDataDirectory() . \'/\' . $this->name . \'/\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("LogUtil::registerStatus($this->__f(\'The upload directories at [%s] can be removed manually.\', $uploadPath));");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// deletion successful");
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
    _builder.append("* @return array list of class names.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function listEntityClasses()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$classNames = array();");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
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
          boolean _isMetaData = entity.isMetaData();
          if (_isMetaData) {
            _builder.append("    ");
            _builder.append("$classNames[] = \'");
            String _entityClassName_4 = this._namingExtensions.entityClassName(entity, "metaData", Boolean.valueOf(false));
            _builder.append(_entityClassName_4, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isAttributable = entity.isAttributable();
          if (_isAttributable) {
            _builder.append("    ");
            _builder.append("$classNames[] = \'");
            String _entityClassName_5 = this._namingExtensions.entityClassName(entity, "attribute", Boolean.valueOf(false));
            _builder.append(_entityClassName_5, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isCategorisable = entity.isCategorisable();
          if (_isCategorisable) {
            _builder.append("    ");
            _builder.append("$classNames[] = \'");
            String _entityClassName_6 = this._namingExtensions.entityClassName(entity, "category", Boolean.valueOf(false));
            _builder.append(_entityClassName_6, "    ");
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
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Installer implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Installer extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Base_Installer");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("Installer extends Base\\");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "");
        _builder.append("Installer");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the installer here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence interactiveImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Controller;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Interactive installer implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("_Controller_InteractiveInstaller extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Controller_Base_InteractiveInstaller");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class InteractiveInstaller extends Base\\InteractiveInstaller");
        _builder.newLine();
      }
    }
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
