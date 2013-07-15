package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.UserController;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.SearchView;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Search {
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
    String _plus = ("Search" + apiClassSuffix);
    final String apiFileName = (_plus + ".php");
    String _plus_1 = (apiPath + "Base/");
    String _plus_2 = (_plus_1 + apiFileName);
    CharSequence _searchApiBaseFile = this.searchApiBaseFile(it);
    fsa.generateFile(_plus_2, _searchApiBaseFile);
    String _plus_3 = (apiPath + apiFileName);
    CharSequence _searchApiFile = this.searchApiFile(it);
    fsa.generateFile(_plus_3, _searchApiFile);
    SearchView _searchView = new SearchView();
    _searchView.generate(it, fsa);
  }
  
  private CharSequence searchApiBaseFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _searchApiBaseClass = this.searchApiBaseClass(it);
    _builder.append(_searchApiBaseClass, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence searchApiFile(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _phpFileHeader = this.fh.phpFileHeader(it);
    _builder.append(_phpFileHeader, "");
    _builder.newLineIfNotEmpty();
    CharSequence _searchApiImpl = this.searchApiImpl(it);
    _builder.append(_searchApiImpl, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence searchApiBaseClass(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Api\\Base;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("\\Util\\ControllerUtil;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("use FormUtil;");
        _builder.newLine();
        _builder.append("use LogUtil;");
        _builder.newLine();
        _builder.append("use ModUtil;");
        _builder.newLine();
        _builder.append("use SecurityUtil;");
        _builder.newLine();
        _builder.append("use ServiceUtil;");
        _builder.newLine();
        _builder.append("use Zikula_AbstractApi;");
        _builder.newLine();
        _builder.append("use Zikula_View;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("use Users\\Entity\\SearchResultEntity;");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Search api base class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_Api_Base_Search");
      } else {
        _builder.append("SearchApi");
      }
    }
    _builder.append(" extends Zikula_AbstractApi");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    CharSequence _searchApiBaseImpl = this.searchApiBaseImpl(it);
    _builder.append(_searchApiBaseImpl, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence searchApiBaseImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _info = this.info(it);
    _builder.append(_info, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _options = this.options(it);
    _builder.append(_options, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _search = this.search(it);
    _builder.append(_search, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _searchCheck = this.searchCheck(it);
    _builder.append(_searchCheck, "");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence info(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Get search plugin information.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The search plugin information");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function info()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array(\'title\'     => $this->name,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'functions\' => array($this->name => \'search\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence options(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Display the search form.");
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
    _builder.append("* @return string template output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function options(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_READ)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view = Zikula_View::getInstance($this->name);");
    _builder.newLine();
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            boolean _hasAbstractStringFieldsEntity = Search.this._modelExtensions.hasAbstractStringFieldsEntity(e);
            return Boolean.valueOf(_hasAbstractStringFieldsEntity);
          }
        };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
      for(final Entity entity : _filter) {
        _builder.append("    ");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        final String fieldName = ("active_" + _formatForCode);
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$view->assign(\'");
        _builder.append(fieldName, "    ");
        _builder.append("\', (!isset($args[\'");
        _builder.append(fieldName, "    ");
        _builder.append("\']) || isset($args[\'active\'][\'");
        _builder.append(fieldName, "    ");
        _builder.append("\'])));");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $view->fetch(\'");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("search");
      } else {
        _builder.append("Search");
      }
    }
    _builder.append("/options.tpl\');");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence search(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Executes the actual search process.");
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
    _builder.append("* @return boolean");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function search(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!SecurityUtil::checkPermission($this->name . \'::\', \'::\', ACCESS_READ)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// ensure that database information of Search module is loaded");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("ModUtil::dbInfoLoad(\'Search\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// save session id as it is used when inserting search results below");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sessionId  = session_id();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// retrieve list of activated object types");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$searchTypes = isset($args[\'objectTypes\']) ? (array)$args[\'objectTypes\'] : (array) FormUtil::getPassedValue(\'search_");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("_types\', array(), \'GETPOST\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'api\' => \'search\', \'action\' => \'search\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$allowedTypes = $controllerHelper->getObjectTypes(\'api\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityManager = ServiceUtil::getService(\'doctrine.entitymanager\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentPage = 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = 50;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($searchTypes as $objectType) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!in_array($objectType, $allowedTypes)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$whereArray = array();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$languageField = null;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(it);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            boolean _hasAbstractStringFieldsEntity = Search.this._modelExtensions.hasAbstractStringFieldsEntity(e);
            return Boolean.valueOf(_hasAbstractStringFieldsEntity);
          }
        };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities, _function);
      for(final Entity entity : _filter) {
        _builder.append("            ");
        _builder.append("case \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "            ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        {
          Iterable<AbstractStringField> _abstractStringFieldsEntity = this._modelExtensions.getAbstractStringFieldsEntity(entity);
          for(final AbstractStringField field : _abstractStringFieldsEntity) {
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("$whereArray[] = \'tbl.");
            String _name_1 = field.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "                ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _hasLanguageFieldsEntity = this._modelExtensions.hasLanguageFieldsEntity(entity);
          if (_hasLanguageFieldsEntity) {
            _builder.append("            ");
            _builder.append("    ");
            _builder.append("$languageField = \'");
            Iterable<StringField> _languageFieldsEntity = this._modelExtensions.getLanguageFieldsEntity(entity);
            StringField _head = IterableExtensions.<StringField>head(_languageFieldsEntity);
            _builder.append(_head, "                ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          }
        }
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$where = ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("Search_Api_User");
      } else {
        _builder.append("\\Search\\Api\\UserApi");
      }
    }
    _builder.append("::construct_where($args, $whereArray, $languageField);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
        _builder.append("        ");
        _builder.append("$entityClass = $this->name . \'_Entity_\' . ucwords($objectType);");
        _builder.newLine();
      } else {
        _builder.append("        ");
        _builder.append("$entityClass = \'\\\\\' . $this->name . \'\\\\Entity\\\\\' . ucwords($objectType) . \'Entity\';");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("$repository = $entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("// get objects from database");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("list($entities, $objectCount) = $repository->selectWherePaginated($where, \'\', $currentPage, $resultsPerPage, false);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($objectCount == 0) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$idFields = ModUtil::apiFunc($this->name, \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$titleField = $repository->getTitleFieldName();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$descriptionField = $repository->getDescriptionFieldName();");
    _builder.newLine();
    _builder.append("        ");
    Iterable<UserController> _allUserControllers = this._controllerExtensions.getAllUserControllers(it);
    final Function1<UserController,Boolean> _function_1 = new Function1<UserController,Boolean>() {
        public Boolean apply(final UserController e) {
          boolean _hasActions = Search.this._controllerExtensions.hasActions(e, "display");
          return Boolean.valueOf(_hasActions);
        }
      };
    Iterable<UserController> _filter_1 = IterableExtensions.<UserController>filter(_allUserControllers, _function_1);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter_1);
    final boolean hasUserDisplay = (!_isEmpty);
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("foreach ($entities as $entity) {");
    _builder.newLine();
    {
      if (hasUserDisplay) {
        _builder.append("            ");
        _builder.append("$urlArgs = array(\'ot\' => $objectType);");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("// create identifier for permission check");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$instanceId = \'\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    {
      if (hasUserDisplay) {
        _builder.append("                ");
        _builder.append("$urlArgs[$idField] = $entity[$idField];");
        _builder.newLine();
      }
    }
    _builder.append("                ");
    _builder.append("if (!empty($instanceId)) {");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("$instanceId .= \'_\';");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$instanceId .= $entity[$idField];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    {
      if (hasUserDisplay) {
        _builder.append("            ");
        _builder.append("$urlArgs[\'id\'] = $instanceId;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("/* commented out as it could exceed the maximum length of the \'extra\' field");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("if (isset($entity[\'slug\'])) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$urlArgs[\'slug\'] = $entity[\'slug\'];");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}*/");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("if (!SecurityUtil::checkPermission($this->name . \':\' . ucfirst($objectType) . \':\', $instanceId . \'::\', ACCESS_OVERVIEW)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$title = ($titleField != \'\') ? $entity[$titleField] : $this->__(\'Item\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$description = ($descriptionField != \'\') ? $entity[$descriptionField] : \'\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$created = (isset($entity[\'createdDate\'])) ? $entity[\'createdDate\']->format(\'Y-m-d H:i:s\') : \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$searchItemData = array(");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'title\'   => $title,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'text\'    => $description,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'extra\'   => ");
    {
      if (hasUserDisplay) {
        _builder.append("serialize($urlArgs)");
      } else {
        _builder.append("\'\'");
      }
    }
    _builder.append(",");
    _builder.newLineIfNotEmpty();
    _builder.append("                ");
    _builder.append("\'created\' => $created,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'module\'  => $this->name,");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("\'session\' => $sessionId");
    _builder.newLine();
    _builder.append("            ");
    _builder.append(");");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
        _builder.append("            ");
        _builder.append("if (!DBUtil::insertObject($searchItemData, \'search_result\')) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("return LogUtil::registerError($this->__(\'Error! Could not save the search results.\'));");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
      } else {
        _builder.append("            ");
        _builder.append("$searchItem = new SearchResultEntity();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("foreach ($searchItemData as $k => $v) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$fieldName = ($k == \'session\') ? \'sesid\' : $k;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$searchItem[$fieldName] = $v;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("try {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$this->entityManager->persist($searchItem);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$this->entityManager->flush();");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("} catch (\\Exception $e) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("return LogUtil::registerError($this->__(\'Error! Could not save the search results.\'));");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence searchCheck(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Assign URL to items.");
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
    _builder.append("* @return boolean");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function search_check(array $args = array())");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    Iterable<UserController> _allUserControllers = this._controllerExtensions.getAllUserControllers(it);
    final Function1<UserController,Boolean> _function = new Function1<UserController,Boolean>() {
        public Boolean apply(final UserController e) {
          boolean _hasActions = Search.this._controllerExtensions.hasActions(e, "display");
          return Boolean.valueOf(_hasActions);
        }
      };
    Iterable<UserController> _filter = IterableExtensions.<UserController>filter(_allUserControllers, _function);
    boolean _isEmpty = IterableExtensions.isEmpty(_filter);
    final boolean hasUserDisplay = (!_isEmpty);
    _builder.newLineIfNotEmpty();
    {
      if (hasUserDisplay) {
        _builder.append("    ");
        _builder.append("$datarow = &$args[\'datarow\'];");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$urlArgs = unserialize($datarow[\'extra\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$datarow[\'url\'] = ModUtil::url($this->name, \'user\', \'display\', $urlArgs);");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("// nothing to do as we have no display pages which could be linked");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence searchApiImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("namespace ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "");
        _builder.append("\\Api;");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Search api implementation class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("class ");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("_Api_Search extends ");
        String _appName_2 = this._utils.appName(it);
        _builder.append(_appName_2, "");
        _builder.append("_Api_Base_Search");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("class SearchApi extends Base\\SearchApi");
        _builder.newLine();
      }
    }
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to extend the search api here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
