package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Action;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.CustomAction;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Cache {
  @Inject
  @Extension
  private ControllerExtensions _controllerExtensions = new Function0<ControllerExtensions>() {
    public ControllerExtensions apply() {
      ControllerExtensions _controllerExtensions = new ControllerExtensions();
      return _controllerExtensions;
    }
  }.apply();
  
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
  
  public void generate(final Application it, final IFileSystemAccess fsa) {
    InputOutput.<String>println("Generating cache api");
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(it);
    final String apiPath = (_appSourceLibPath + "Api/");
    String _xifexpression = null;
    boolean _targets = this._utils.targets(it, "1.3.5");
    boolean _not = (!_targets);
    if (_not) {
      _xifexpression = "Api";
    } else {
      _xifexpression = "";
    }
    final String apiClassSuffix = _xifexpression;
    String _plus = ("Cache" + apiClassSuffix);
    final String apiFileName = (_plus + ".php");
    String _plus_1 = (apiPath + "Base/");
    String _plus_2 = (_plus_1 + apiFileName);
    CharSequence _cacheApiBaseFile = this.cacheApiBaseFile(it);
    fsa.generateFile(_plus_2, _cacheApiBaseFile);
    String _plus_3 = (apiPath + apiFileName);
    CharSequence _cacheApiFile = this.cacheApiFile(it);
    fsa.generateFile(_plus_3, _cacheApiFile);
  }
  
  private CharSequence cacheApiBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _cacheApiBaseClass = this.cacheApiBaseClass(it);
    _builder.append(_cacheApiBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence cacheApiFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _cacheApiImpl = this.cacheApiImpl(it);
    _builder.append(_cacheApiImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence cacheApiBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Api\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractApi;");
        _builder.newLine();
        _builder.append("use Zikula_View;");
        _builder.newLine();
        _builder.append("use Zikula_View_Theme;");
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Cache api base class.");
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
        _builder.append("_Api_Base_Cache");
      } else {
        _builder.append("CacheApi");
      }
    }
    _builder.append(" extends Zikula_AbstractApi");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _cacheApiBaseImpl = this.cacheApiBaseImpl(it);
    _builder.append(_cacheApiBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence cacheApiBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Clear cache for given item. Can be called from other modules to clear an item cache.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param $args[\'ot\']   the treated object type");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param $args[\'item\'] the actual object");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function clearItemCache(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!isset($args[\'ot\']) || !isset($args[\'item\'])) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $args[\'ot\'];");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$item = $args[\'item\'];");
    _builder.newLine();
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
    _builder.append("$utilArgs = array(\'api\' => \'cache\', \'action\' => \'clearItemCache\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($item && !is_array($item) && !is_object($item)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$item = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $item, \'useJoins\' => false, \'slimMode\' => true));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$item) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _and = false;
      boolean _hasUserController = this._controllerExtensions.hasUserController(it);
      if (!_hasUserController) {
        _and = false;
      } else {
        UserController _mainUserController = this._controllerExtensions.getMainUserController(it);
        boolean _hasActions = this._controllerExtensions.hasActions(_mainUserController, "display");
        _and = (_hasUserController && _hasActions);
      }
      if (_and) {
        _builder.append("    ");
        _builder.append("// create full identifier (considering composite keys)");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$idFields = ModUtil::apiFunc($this->name, \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$instanceId = \'\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("foreach ($idFields as $idField) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("if (!empty($instanceId)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("$instanceId .= \'_\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$instanceId .= $item[$idField];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Clear View_cache");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$cacheIds = array();");
    _builder.newLine();
    {
      boolean _hasUserController_1 = this._controllerExtensions.hasUserController(it);
      if (_hasUserController_1) {
        {
          UserController _mainUserController_1 = this._controllerExtensions.getMainUserController(it);
          boolean _hasActions_1 = this._controllerExtensions.hasActions(_mainUserController_1, "index");
          if (_hasActions_1) {
            _builder.append("    ");
            _builder.append("$cacheIds[] = \'");
            {
              boolean _targets_2 = this._utils.targets(it, "1.3.5");
              if (_targets_2) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          UserController _mainUserController_2 = this._controllerExtensions.getMainUserController(it);
          boolean _hasActions_2 = this._controllerExtensions.hasActions(_mainUserController_2, "view");
          if (_hasActions_2) {
            _builder.append("    ");
            _builder.append("$cacheIds[] = \'view\';");
            _builder.newLine();
          }
        }
        {
          UserController _mainUserController_3 = this._controllerExtensions.getMainUserController(it);
          boolean _hasActions_3 = this._controllerExtensions.hasActions(_mainUserController_3, "display");
          if (_hasActions_3) {
            _builder.append("    ");
            _builder.append("$cacheIds[] = $instanceId;");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.newLine();
        _builder.append("    ");
        _builder.newLine();
        {
          UserController _mainUserController_4 = this._controllerExtensions.getMainUserController(it);
          boolean _hasActions_4 = this._controllerExtensions.hasActions(_mainUserController_4, "custom");
          if (_hasActions_4) {
            {
              UserController _mainUserController_5 = this._controllerExtensions.getMainUserController(it);
              EList<Action> _actions = _mainUserController_5.getActions();
              Iterable<CustomAction> _filter = Iterables.<CustomAction>filter(_actions, CustomAction.class);
              for(final CustomAction customAction : _filter) {
                _builder.append("    ");
                _builder.append("$cacheIds[] = \'");
                String _name = customAction.getName();
                String _formatForCode = this._formattingExtensions.formatForCode(_name);
                String _firstLower = StringExtensions.toFirstLower(_formatForCode);
                _builder.append(_firstLower, "    ");
                _builder.append("\';");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view = Zikula_View::getInstance(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "    ");
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("foreach ($cacheIds as $cacheId) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$view->clear_cache(null, $cacheId);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Clear Theme_cache");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$cacheIds = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$cacheIds[] = \'homepage\'; // for homepage (can be assigned in the Settings module)");
    _builder.newLine();
    {
      boolean _hasUserController_2 = this._controllerExtensions.hasUserController(it);
      if (_hasUserController_2) {
        {
          UserController _mainUserController_6 = this._controllerExtensions.getMainUserController(it);
          boolean _hasActions_5 = this._controllerExtensions.hasActions(_mainUserController_6, "index");
          if (_hasActions_5) {
            _builder.append("    ");
            _builder.append("$cacheIds[] = \'");
            String _appName_2 = this._utils.appName(it);
            _builder.append(_appName_2, "    ");
            _builder.append("/user/");
            {
              boolean _targets_3 = this._utils.targets(it, "1.3.5");
              if (_targets_3) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
            _builder.append("\'; // ");
            {
              boolean _targets_4 = this._utils.targets(it, "1.3.5");
              if (_targets_4) {
                _builder.append("main");
              } else {
                _builder.append("index");
              }
            }
            _builder.append(" function");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          UserController _mainUserController_7 = this._controllerExtensions.getMainUserController(it);
          boolean _hasActions_6 = this._controllerExtensions.hasActions(_mainUserController_7, "view");
          if (_hasActions_6) {
            _builder.append("    ");
            _builder.append("$cacheIds[] = \'");
            String _appName_3 = this._utils.appName(it);
            _builder.append(_appName_3, "    ");
            _builder.append("/user/view/\' . $objectType; // view function (list views)");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          UserController _mainUserController_8 = this._controllerExtensions.getMainUserController(it);
          boolean _hasActions_7 = this._controllerExtensions.hasActions(_mainUserController_8, "display");
          if (_hasActions_7) {
            _builder.append("    ");
            _builder.append("$cacheIds[] = \'");
            String _appName_4 = this._utils.appName(it);
            _builder.append(_appName_4, "    ");
            _builder.append("/user/display/\' . $objectType . \'|\' . $instanceId; // display function (detail views)");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("    ");
        _builder.newLine();
        _builder.append("    ");
        _builder.newLine();
        {
          UserController _mainUserController_9 = this._controllerExtensions.getMainUserController(it);
          boolean _hasActions_8 = this._controllerExtensions.hasActions(_mainUserController_9, "custom");
          if (_hasActions_8) {
            {
              UserController _mainUserController_10 = this._controllerExtensions.getMainUserController(it);
              EList<Action> _actions_1 = _mainUserController_10.getActions();
              Iterable<CustomAction> _filter_1 = Iterables.<CustomAction>filter(_actions_1, CustomAction.class);
              for(final CustomAction customAction_1 : _filter_1) {
                _builder.append("    ");
                _builder.append("$cacheIds[] = \'");
                String _appName_5 = this._utils.appName(it);
                _builder.append(_appName_5, "    ");
                _builder.append("/user/");
                String _name_1 = customAction_1.getName();
                String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
                String _firstLower_1 = StringExtensions.toFirstLower(_formatForCode_1);
                _builder.append(_firstLower_1, "    ");
                _builder.append("\'; // ");
                String _name_2 = customAction_1.getName();
                String _formatForDisplay = this._formattingExtensions.formatForDisplay(_name_2);
                _builder.append(_formatForDisplay, "    ");
                _builder.append(" function");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("$theme = Zikula_View_Theme::getInstance();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$theme->clear_cacheid_allthemes($cacheIds);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence cacheApiImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appNamespace = this._utils.appNamespace(it);
        _builder.append(_appNamespace, "");
        _builder.append("\\Api;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(it);
        _builder.append(_appNamespace_1, "");
        _builder.append("\\Api\\Base\\CacheApi as BaseCacheApi;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Cache api implementation class.");
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
        _builder.append("_Api_Cache extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Api_Base_Cache");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class CacheApi extends BaseCacheApi");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the cache api here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
