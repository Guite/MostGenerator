package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AdminController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Account {
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
  private ModelExtensions _modelExtensions = new Function0<ModelExtensions>() {
    public ModelExtensions apply() {
      ModelExtensions _modelExtensions = new ModelExtensions();
      return _modelExtensions;
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
    String _plus = ("Account" + apiClassSuffix);
    final String apiFileName = (_plus + ".php");
    String _plus_1 = (apiPath + "Base/");
    String _plus_2 = (_plus_1 + apiFileName);
    CharSequence _accountApiBaseFile = this.accountApiBaseFile(it);
    fsa.generateFile(_plus_2, _accountApiBaseFile);
    String _plus_3 = (apiPath + apiFileName);
    CharSequence _accountApiFile = this.accountApiFile(it);
    fsa.generateFile(_plus_3, _accountApiFile);
  }
  
  private CharSequence accountApiBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _accountApiBaseClass = this.accountApiBaseClass(it);
    _builder.append(_accountApiBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence accountApiFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _accountApiImpl = this.accountApiImpl(it);
    _builder.append(_accountApiImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence accountApiBaseClass(final Application it) {
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
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use UserUtil;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractApi;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Account api base class.");
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
        _builder.append("_Api_Base_Account");
      } else {
        _builder.append("AccountApi");
      }
    }
    _builder.append(" extends Zikula_AbstractApi");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _accountApiBaseImpl = this.accountApiBaseImpl(it);
    _builder.append(_accountApiBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence accountApiBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Return an array of items to show in the your account panel.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param array $args List of arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array List of collected account items");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getall(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// collect items in an array");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$items = array();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$useAccountPage = $this->getVar(\'useAccountPage\', true);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($useAccountPage === false) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $items;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$userName = (isset($args[\'uname\'])) ? $args[\'uname\'] : UserUtil::getVar(\'uname\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// does this user exist?");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (UserUtil::getIdFromName($userName) === false) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// user does not exist");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $items;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_OVERVIEW)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $items;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Create an array of links to return");
    _builder.newLine();
    {
      boolean _and = false;
      Iterable<UserController> _allUserControllers = this._controllerExtensions.getAllUserControllers(it);
      boolean _isEmpty = IterableExtensions.isEmpty(_allUserControllers);
      boolean _not = (!_isEmpty);
      if (!_not) {
        _and = false;
      } else {
        UserController _mainUserController = this._controllerExtensions.getMainUserController(it);
        boolean _hasActions = this._controllerExtensions.hasActions(_mainUserController, "view");
        _and = (_not && _hasActions);
      }
      if (_and) {
        {
          EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
          final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
            public Boolean apply(final Entity it) {
              boolean _and = false;
              boolean _isStandardFields = it.isStandardFields();
              if (!_isStandardFields) {
                _and = false;
              } else {
                boolean _isOwnerPermission = it.isOwnerPermission();
                _and = (_isStandardFields && _isOwnerPermission);
              }
              return Boolean.valueOf(_and);
            }
          };
          Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
          for(final Entity entity : _filter) {
            _builder.append("    ");
            _builder.append("$objectType = \'");
            String _name = entity.getName();
            String _formatForCode = this._formattingExtensions.formatForCode(_name);
            _builder.append(_formatForCode, "    ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("if (SecurityUtil::checkPermission($this->name . \':\' . ucwords($objectType) . \':\', \'::\', ACCESS_READ)) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$items[] = array(");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("\'url\' => ModUtil::url($this->name, \'user\', \'view\', array(\'ot\' => $objectType, \'own\' => 1)),");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("\'title\'   => $this->__(\'My ");
            String _nameMultiple = entity.getNameMultiple();
            String _formatForDisplay = this._formattingExtensions.formatForDisplay(_nameMultiple);
            _builder.append(_formatForDisplay, "            ");
            _builder.append("\'),");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("\'icon\'    => \'windowlist.png\',");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("\'module\'  => \'core\',");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("\'set\'     => \'icons/large\'");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append(");");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    {
      Iterable<AdminController> _allAdminControllers = this._controllerExtensions.getAllAdminControllers(it);
      boolean _isEmpty_1 = IterableExtensions.isEmpty(_allAdminControllers);
      boolean _not_1 = (!_isEmpty_1);
      if (_not_1) {
        _builder.append("    ");
        _builder.append("if (SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_ADMIN)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$items[] = array(");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'url\'   => ModUtil::url($this->name, \'admin\', \'");
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          if (_targets) {
            _builder.append("main");
          } else {
            _builder.append("index");
          }
        }
        _builder.append("\'),");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'title\' => $this->__(\'");
        String _name_1 = it.getName();
        String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(_name_1);
        _builder.append(_formatForDisplayCapital, "            ");
        _builder.append(" Backend\'),");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'icon\'   => \'configure.png\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'module\' => \'core\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("        ");
        _builder.append("\'set\'    => \'icons/large\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append(");");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return the items");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $items;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence accountApiImpl(final Application it) {
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
        _builder.append("\\Api\\Base\\AccountApi as BaseAccountApi;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Account api implementation class.");
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
        _builder.append("_Api_Account extends ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Api_Base_Account");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class AccountApi extends BaseAccountApi");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the account api here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
