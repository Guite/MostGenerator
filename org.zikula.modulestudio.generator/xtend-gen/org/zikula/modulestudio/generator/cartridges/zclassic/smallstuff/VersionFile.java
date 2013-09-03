package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff;

import com.google.common.base.Objects;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.ApplicationDependencyType;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.ReferredApplication;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class VersionFile {
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
  private ModelJoinExtensions _modelJoinExtensions = new Function0<ModelJoinExtensions>() {
    public ModelJoinExtensions apply() {
      ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
      return _modelJoinExtensions;
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
  
  @Inject
  @Extension
  private WorkflowExtensions _workflowExtensions = new Function0<WorkflowExtensions>() {
    public WorkflowExtensions apply() {
      WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
      return _workflowExtensions;
    }
  }.apply();
  
  private FileHelper fh = new Function0<FileHelper>() {
    public FileHelper apply() {
      FileHelper _fileHelper = new FileHelper();
      return _fileHelper;
    }
  }.apply();
  
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
    final String versionPrefix = _xifexpression;
    final String versionFileName = (versionPrefix + "Version.php");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_1 = (_appSourceLibPath + "Base/");
    String _plus_2 = (_plus_1 + versionFileName);
    CharSequence _versionBaseFile = this.versionBaseFile(it);
    fsa.generateFile(_plus_2, _versionBaseFile);
    String _appSourceLibPath_1 = this._namingExtensions.getAppSourceLibPath(it);
    String _plus_3 = (_appSourceLibPath_1 + versionFileName);
    CharSequence _versionFile = this.versionFile(it);
    fsa.generateFile(_plus_3, _versionFile);
  }
  
  private CharSequence versionBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _appInfoBaseImpl = this.appInfoBaseImpl(it);
    _builder.append(_appInfoBaseImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence versionFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _appInfoImpl = this.appInfoImpl(it);
    _builder.append(_appInfoImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence appInfoBaseImpl(final Application it) {
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
        _builder.append("use HookUtil;");
        _builder.newLine();
        {
          EList<ReferredApplication> _referredApplications = it.getReferredApplications();
          boolean _isEmpty = _referredApplications.isEmpty();
          boolean _not_1 = (!_isEmpty);
          if (_not_1) {
            _builder.append("use ModUtil;");
            _builder.newLine();
          }
        }
        _builder.append("use Zikula_AbstractVersion;");
        _builder.newLine();
        _builder.append("use Zikula\\Component\\HookDispatcher\\ProviderBundle;");
        _builder.newLine();
        _builder.append("use Zikula\\Component\\HookDispatcher\\SubscriberBundle;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Version information base class.");
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
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("Module");
      }
    }
    _builder.append("Version extends Zikula_AbstractVersion");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Retrieves meta data information for this application.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* @return array List of meta data.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("public function getMetaData()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta = array();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// the current module version");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'version\']              = \'");
    String _version = it.getVersion();
    _builder.append(_version, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// the displayed name of the module");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'displayname\']          = $this->__(\'");
    String _name_1 = it.getName();
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
    _builder.append(_formatForDisplayCapital, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// the module description");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'description\']          = $this->__(\'");
    {
      boolean _and = false;
      String _documentation = it.getDocumentation();
      boolean _tripleNotEquals = (_documentation != null);
      if (!_tripleNotEquals) {
        _and = false;
      } else {
        String _documentation_1 = it.getDocumentation();
        boolean _notEquals = (!Objects.equal(_documentation_1, ""));
        _and = (_tripleNotEquals && _notEquals);
      }
      if (_and) {
        String _documentation_2 = it.getDocumentation();
        String _replaceAll = _documentation_2.replaceAll("\'", "\\\'");
        _builder.append(_replaceAll, "        ");
      } else {
        String _name_2 = it.getName();
        String _formatForDisplayCapital_1 = this._formattingExtensions.formatForDisplayCapital(_name_2);
        _builder.append(_formatForDisplayCapital_1, "        ");
        _builder.append(" module generated by ModuleStudio ");
        String _msVersion = this._utils.msVersion();
        _builder.append(_msVersion, "        ");
        _builder.append(".");
      }
    }
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("//! url version of name, should be in lowercase without space");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'url\']                  = $this->__(\'");
    String _name_3 = it.getName();
    String _formatForDB = this._formattingExtensions.formatForDB(_name_3);
    _builder.append(_formatForDB, "        ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("// core requirement");
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("        ");
        _builder.append("$meta[\'core_min\']             = \'1.3.5\'; // requires minimum 1.3.5");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$meta[\'core_max\']             = \'1.3.5\'; // not ready for 1.3.6 yet");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$meta[\'core_min\']             = \'1.3.6\'; // requires minimum 1.3.6 or later");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$meta[\'core_max\']             = \'1.3.99\'; // not ready for 1.4.0 yet");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// define special capabilities of this module");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$meta[\'capabilities\'] = array(");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("HookUtil::SUBSCRIBER_CAPABLE => array(\'enabled\' => true)");
    _builder.newLine();
    _builder.append("/*,");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("HookUtil::PROVIDER_CAPABLE => array(\'enabled\' => true), // TODO: see #15");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("\'authentication\' => array(\'version\' => \'1.0\'),");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("\'profile\'        => array(\'version\' => \'1.0\', \'anotherkey\' => \'anothervalue\'),");
    _builder.newLine();
    _builder.append("                          ");
    _builder.append("\'message\'        => array(\'version\' => \'1.0\', \'anotherkey\' => \'anothervalue\')");
    _builder.newLine();
    _builder.append("*/");
    _builder.newLine();
    _builder.append("        ");
    _builder.append(");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// permission schema");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _permissionSchema = this.permissionSchema(it);
    _builder.append(_permissionSchema, "        ");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      EList<ReferredApplication> _referredApplications_1 = it.getReferredApplications();
      boolean _isEmpty_1 = _referredApplications_1.isEmpty();
      boolean _not_2 = (!_isEmpty_1);
      if (_not_2) {
        _builder.append("        ");
        _builder.append("// module dependencies");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$meta[\'dependencies\'] = array(");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        {
          EList<ReferredApplication> _referredApplications_2 = it.getReferredApplications();
          boolean _hasElements = false;
          for(final ReferredApplication referredApp : _referredApplications_2) {
            if (!_hasElements) {
              _hasElements = true;
            } else {
              _builder.appendImmediate(",", "            ");
            }
            CharSequence _appDependency = this.appDependency(it, referredApp);
            _builder.append(_appDependency, "            ");
          }
        }
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append(");");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $meta;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/**");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("* Define hook subscriber");
    _builder.append(" bundles.");
    _builder.newLine();
    _builder.append("     ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("protected function setupHookBundles()");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("{");
    _builder.newLine();
    String _name_4 = it.getName();
    final String appName = this._formattingExtensions.formatForDB(_name_4);
    _builder.newLineIfNotEmpty();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        _builder.append("        ");
        _builder.newLine();
        _builder.append("        ");
        String _nameMultiple = entity.getNameMultiple();
        final String areaName = this._formattingExtensions.formatForDB(_nameMultiple);
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$bundle = new ");
        {
          boolean _targets_3 = this._utils.targets(it, "1.3.5");
          if (_targets_3) {
            _builder.append("Zikula_HookManager_");
          }
        }
        _builder.append("SubscriberBundle($this->name, \'subscriber.");
        _builder.append(appName, "        ");
        _builder.append(".ui_hooks.");
        _builder.append(areaName, "        ");
        _builder.append("\', \'ui_hooks\', __(\'");
        _builder.append(appName, "        ");
        _builder.append(" ");
        String _nameMultiple_1 = entity.getNameMultiple();
        String _formatForDisplayCapital_2 = this._formattingExtensions.formatForDisplayCapital(_nameMultiple_1);
        _builder.append(_formatForDisplayCapital_2, "        ");
        _builder.append(" Display Hooks\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// Display hook for view/display templates.");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle->addEvent(\'display_view\', \'");
        _builder.append(appName, "        ");
        _builder.append(".ui_hooks.");
        _builder.append(areaName, "        ");
        _builder.append(".display_view\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("// Display hook for create/edit forms.");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle->addEvent(\'form_edit\', \'");
        _builder.append(appName, "        ");
        _builder.append(".ui_hooks.");
        _builder.append(areaName, "        ");
        _builder.append(".form_edit\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("// Display hook for delete dialogues.");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle->addEvent(\'form_delete\', \'");
        _builder.append(appName, "        ");
        _builder.append(".ui_hooks.");
        _builder.append(areaName, "        ");
        _builder.append(".form_delete\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("// Validate input from an ui create/edit form.");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle->addEvent(\'validate_edit\', \'");
        _builder.append(appName, "        ");
        _builder.append(".ui_hooks.");
        _builder.append(areaName, "        ");
        _builder.append(".validate_edit\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("// Validate input from an ui create/edit form (generally not used).");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle->addEvent(\'validate_delete\', \'");
        _builder.append(appName, "        ");
        _builder.append(".ui_hooks.");
        _builder.append(areaName, "        ");
        _builder.append(".validate_delete\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("// Perform the final update actions for a ui create/edit form.");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle->addEvent(\'process_edit\', \'");
        _builder.append(appName, "        ");
        _builder.append(".ui_hooks.");
        _builder.append(areaName, "        ");
        _builder.append(".process_edit\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("// Perform the final delete actions for a ui form.");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle->addEvent(\'process_delete\', \'");
        _builder.append(appName, "        ");
        _builder.append(".ui_hooks.");
        _builder.append(areaName, "        ");
        _builder.append(".process_delete\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$this->registerHookSubscriberBundle($bundle);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle = new ");
        {
          boolean _targets_4 = this._utils.targets(it, "1.3.5");
          if (_targets_4) {
            _builder.append("Zikula_HookManager_");
          }
        }
        _builder.append("SubscriberBundle($this->name, \'subscriber.");
        _builder.append(appName, "        ");
        _builder.append(".filter_hooks.");
        _builder.append(areaName, "        ");
        _builder.append("\', \'filter_hooks\', __(\'");
        _builder.append(appName, "        ");
        _builder.append(" ");
        String _nameMultiple_2 = entity.getNameMultiple();
        String _formatForDisplayCapital_3 = this._formattingExtensions.formatForDisplayCapital(_nameMultiple_2);
        _builder.append(_formatForDisplayCapital_3, "        ");
        _builder.append(" Filter Hooks\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("// A filter applied to the given area.");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$bundle->addEvent(\'filter\', \'");
        _builder.append(appName, "        ");
        _builder.append(".filter_hooks.");
        _builder.append(areaName, "        ");
        _builder.append(".filter\');");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$this->registerHookSubscriberBundle($bundle);");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("        ");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence appInfoImpl(final Application it) {
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
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Base\\");
        String _name = it.getName();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
        _builder.append(_formatForCodeCapital, "");
        _builder.append("ModuleVersion as Base");
        String _name_1 = it.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
        _builder.append(_formatForCodeCapital_1, "");
        _builder.append("ModuleVersion;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Version information implementation class.");
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
        _builder.append("_Version extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Base_Version");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class ");
        String _name_2 = it.getName();
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_2);
        _builder.append(_formatForCodeCapital_2, "");
        _builder.append("ModuleVersion extends Base");
        String _name_3 = it.getName();
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_3, "");
        _builder.append("ModuleVersion");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// custom enhancements can go here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  /**
   * Definition of permission schema arrays.
   */
  private CharSequence permissionSchema(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$meta[\'securityschema\'] = array(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("::\' => \'::\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("::Ajax\' => \'::\',");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("\'");
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "    ");
    _builder.append(":ItemListBlock:\' => \'Block title::\',");
    _builder.newLineIfNotEmpty();
    {
      boolean _needsApproval = this._workflowExtensions.needsApproval(it);
      if (_needsApproval) {
        _builder.append("    ");
        _builder.append("\'");
        String _appName_3 = this._utils.appName(it);
        _builder.append(_appName_3, "    ");
        _builder.append(":ModerationBlock:\' => \'Block title::\',");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      for(final Entity entity : _allEntities) {
        String _appName_4 = this._utils.appName(it);
        CharSequence _permissionSchema = this.permissionSchema(entity, _appName_4);
        _builder.append(_permissionSchema, "    ");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(");");
    _builder.newLine();
    _builder.append("// DEBUG: permission schema aspect ends");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence appDependency(final Application app, final ReferredApplication it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("array(\'modname\'    => \'");
    String _name = it.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    String _firstUpper = StringExtensions.toFirstUpper(_formatForCode);
    _builder.append(_firstUpper, "");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("      ");
    _builder.append("\'minversion\' => \'");
    String _minVersion = it.getMinVersion();
    _builder.append(_minVersion, "      ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("      ");
    _builder.append("\'maxversion\' => \'");
    String _maxVersion = it.getMaxVersion();
    _builder.append(_maxVersion, "      ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("      ");
    _builder.append("\'status\'     => ModUtil::DEPENDENCY_");
    String _appDependencyType = this.appDependencyType(it);
    _builder.append(_appDependencyType, "      ");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append(",");
        _builder.newLineIfNotEmpty();
        _builder.append("      ");
        _builder.append("\'reason\'     => \'");
        String _documentation = it.getDocumentation();
        _builder.append(_documentation, "      ");
        _builder.append("\'");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private String appDependencyType(final ReferredApplication it) {
    String _switchResult = null;
    ApplicationDependencyType _dependencyType = it.getDependencyType();
    final ApplicationDependencyType _switchValue = _dependencyType;
    boolean _matched = false;
    if (!_matched) {
      if (Objects.equal(_switchValue,ApplicationDependencyType.RECOMMENDATION)) {
        _matched=true;
        _switchResult = "RECOMMENDED";
      }
    }
    if (!_matched) {
      if (Objects.equal(_switchValue,ApplicationDependencyType.CONFLICT)) {
        _matched=true;
        _switchResult = "CONFLICTS";
      }
    }
    if (!_matched) {
      _switchResult = "REQUIRED";
    }
    return _switchResult;
  }
  
  private CharSequence permissionSchema(final Entity it, final String appName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'");
    _builder.append(appName, "");
    _builder.append(":");
    String _name = it.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
    _builder.append(_formatForCodeCapital, "");
    _builder.append(":\' => \'");
    String _name_1 = it.getName();
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
    _builder.append(_formatForCodeCapital_1, "");
    _builder.append(" ID::\',");
    _builder.newLineIfNotEmpty();
    final Iterable<JoinRelationship> incomingRelations = this._modelJoinExtensions.getIncomingJoinRelations(it);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(incomingRelations);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          for(final JoinRelationship relation : incomingRelations) {
            CharSequence _permissionSchema = this.permissionSchema(relation, appName);
            _builder.append(_permissionSchema, "");
          }
        }
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence permissionSchema(final JoinRelationship it, final String modName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("\'");
    _builder.append(modName, "");
    _builder.append(":");
    Entity _source = it.getSource();
    String _name = _source.getName();
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
    _builder.append(_formatForCodeCapital, "");
    _builder.append(":");
    Entity _target = it.getTarget();
    String _name_1 = _target.getName();
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
    _builder.append(_formatForCodeCapital_1, "");
    _builder.append("\' => \'");
    Entity _source_1 = it.getSource();
    String _name_2 = _source_1.getName();
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(_name_2);
    _builder.append(_formatForCodeCapital_2, "");
    _builder.append(" ID:");
    Entity _target_1 = it.getTarget();
    String _name_3 = _target_1.getName();
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(_name_3);
    _builder.append(_formatForCodeCapital_3, "");
    _builder.append(" ID:\',");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
