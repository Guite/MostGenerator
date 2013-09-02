package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.AjaxController;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import de.guite.modulestudio.metamodel.modulestudio.BooleanField;
import de.guite.modulestudio.metamodel.modulestudio.Controller;
import de.guite.modulestudio.metamodel.modulestudio.Controllers;
import de.guite.modulestudio.metamodel.modulestudio.DerivedField;
import de.guite.modulestudio.metamodel.modulestudio.Entity;
import de.guite.modulestudio.metamodel.modulestudio.EntityField;
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship;
import de.guite.modulestudio.metamodel.modulestudio.StringField;
import de.guite.modulestudio.metamodel.modulestudio.TextField;
import de.guite.modulestudio.metamodel.modulestudio.UserField;
import java.util.Arrays;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelper;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Ajax {
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
  private ModelBehaviourExtensions _modelBehaviourExtensions = new Function0<ModelBehaviourExtensions>() {
    public ModelBehaviourExtensions apply() {
      ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
      return _modelBehaviourExtensions;
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
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  protected CharSequence _additionalAjaxFunctions(final Controller it, final Application app) {
    return null;
  }
  
  protected CharSequence _additionalAjaxFunctions(final AjaxController it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _userSelectors = this.userSelectors(it, app);
    _builder.append(_userSelectors, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _itemListFinder = this.getItemListFinder(it, app);
    _builder.append(_itemListFinder, "");
    _builder.newLineIfNotEmpty();
    final Iterable<JoinRelationship> joinRelations = this._modelJoinExtensions.getJoinRelations(app);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(joinRelations);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        CharSequence _itemListAutoCompletion = this.getItemListAutoCompletion(it, app);
        _builder.append(_itemListAutoCompletion, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _or = false;
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(app);
      final Function1<Entity,Boolean> _function = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            Iterable<DerivedField> _uniqueDerivedFields = Ajax.this._modelExtensions.getUniqueDerivedFields(e);
            final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
                public Boolean apply(final DerivedField f) {
                  boolean _isPrimaryKey = f.isPrimaryKey();
                  boolean _not = (!_isPrimaryKey);
                  return Boolean.valueOf(_not);
                }
              };
            Iterable<DerivedField> _filter = IterableExtensions.<DerivedField>filter(_uniqueDerivedFields, _function);
            int _size = IterableExtensions.size(_filter);
            boolean _greaterThan = (_size > 0);
            return Boolean.valueOf(_greaterThan);
          }
        };
      boolean _exists = IterableExtensions.<Entity>exists(_allEntities, _function);
      if (_exists) {
        _or = true;
      } else {
        boolean _and = false;
        boolean _hasSluggable = this._modelBehaviourExtensions.hasSluggable(app);
        if (!_hasSluggable) {
          _and = false;
        } else {
          EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(app);
          final Function1<Entity,Boolean> _function_1 = new Function1<Entity,Boolean>() {
              public Boolean apply(final Entity e) {
                boolean _and = false;
                boolean _hasSluggableFields = Ajax.this._modelBehaviourExtensions.hasSluggableFields(e);
                if (!_hasSluggableFields) {
                  _and = false;
                } else {
                  boolean _isSlugUnique = e.isSlugUnique();
                  _and = (_hasSluggableFields && _isSlugUnique);
                }
                return Boolean.valueOf(_and);
              }
            };
          Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities_1, _function_1);
          boolean _isEmpty_1 = IterableExtensions.isEmpty(_filter);
          boolean _not_1 = (!_isEmpty_1);
          _and = (_hasSluggable && _not_1);
        }
        _or = (_exists || _and);
      }
      if (_or) {
        _builder.newLine();
        CharSequence _checkForDuplicate = this.checkForDuplicate(it, app);
        _builder.append(_checkForDuplicate, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasBooleansWithAjaxToggle = this._modelExtensions.hasBooleansWithAjaxToggle(app);
      if (_hasBooleansWithAjaxToggle) {
        _builder.newLine();
        CharSequence _ggleFlag = this.toggleFlag(it, app);
        _builder.append(_ggleFlag, "");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasTrees = this._modelBehaviourExtensions.hasTrees(app);
      if (_hasTrees) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _handleTreeOperations = this.handleTreeOperations(it, app);
        _builder.append(_handleTreeOperations, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence userSelectors(final AjaxController it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    final Iterable<UserField> userFields = this._modelExtensions.getAllUserFields(app);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(userFields);
      boolean _not = (!_isEmpty);
      if (_not) {
        {
          for(final UserField userField : userFields) {
            _builder.newLine();
            _builder.append("public function get");
            Entity _entity = userField.getEntity();
            String _name = _entity.getName();
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_name);
            _builder.append(_formatForCodeCapital, "");
            String _name_1 = userField.getName();
            String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_1);
            _builder.append(_formatForCodeCapital_1, "");
            _builder.append("Users");
            {
              boolean _targets = this._utils.targets(app, "1.3.5");
              boolean _not_1 = (!_targets);
              if (_not_1) {
                _builder.append("Action");
              }
            }
            _builder.append("()");
            _builder.newLineIfNotEmpty();
            _builder.append("{");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("return $this->getCommonUsersList();");
            _builder.newLine();
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Retrieve a general purpose list of users.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/ ");
        _builder.newLine();
        _builder.append("public function getCommonUsersList");
        {
          boolean _targets_1 = this._utils.targets(app, "1.3.5");
          boolean _not_2 = (!_targets_1);
          if (_not_2) {
            _builder.append("Action");
          }
        }
        _builder.append("()");
        _builder.newLineIfNotEmpty();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!SecurityUtil::checkPermission($this->name . \'::Ajax\', \'::\', ACCESS_EDIT)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("return true;");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$fragment = \'\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if ($this->request->");
        {
          boolean _targets_2 = this._utils.targets(app, "1.3.5");
          if (_targets_2) {
            _builder.append("isPost()");
          } else {
            _builder.append("isMethod(\'POST\')");
          }
        }
        _builder.append(" && $this->request->request->has(\'fragment\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$fragment = $this->request->request->get(\'fragment\', \'\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("} elseif ($this->request->");
        {
          boolean _targets_3 = this._utils.targets(app, "1.3.5");
          if (_targets_3) {
            _builder.append("isGet()");
          } else {
            _builder.append("isMethod(\'GET\')");
          }
        }
        _builder.append(" && $this->request->query->has(\'fragment\')) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$fragment = $this->request->query->get(\'fragment\', \'\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        {
          boolean _targets_4 = this._utils.targets(app, "1.3.5");
          if (_targets_4) {
            _builder.append("    ");
            _builder.append("ModUtil::dbInfoLoad(\'Users\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$tables = DBUtil::getTables();");
            _builder.newLine();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$usersColumn = $tables[\'users_column\'];");
            _builder.newLine();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$where = \'WHERE \' . $usersColumn[\'uname\'] . \' REGEXP \\\'(\' . DataUtil::formatForStore($fragment) . \')\\\'\';");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$results = DBUtil::selectObjectArray(\'users\', $where);");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("ModUtil::initOOModule(\'ZikulaUsersModule\');");
            _builder.newLine();
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$dql = \"SELECT u FROM Zikula\\Module\\UsersModule\\Entity\\UserEntity u WHERE u.uname LIKE \'% \" . DataUtil::formatForStore($fragment) . \"%\'\";");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$query = $this->entityManager->createQuery($dql);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("$results = $query->getResult(AbstractQuery::HYDRATE_ARRAY);");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$out = \'<ul>\';");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (is_array($results) && count($results) > 0) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("foreach($results as $result) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("$out .= \'<li>\' . DataUtil::formatForDisplay($result[\'uname\']) . \'<input type=\"hidden\" id=\"\' . DataUtil::formatForDisplay($result[\'uname\']) . \'\" value=\"\' . $result[\'uid\'] . \'\" /></li>\';");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$out .= \'</ul>\';");
        _builder.newLine();
        _builder.newLine();
        {
          boolean _targets_5 = this._utils.targets(app, "1.3.5");
          if (_targets_5) {
            _builder.append("    ");
            _builder.append("return new Zikula_Response_Ajax_Plain($out);");
            _builder.newLine();
          } else {
            _builder.append("    ");
            _builder.append("return new Plain($view->display(\'External/\' . ucwords($objectType) . \'/find.tpl\'));");
            _builder.newLine();
          }
        }
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence getItemListFinder(final AjaxController it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Retrieve item list for finder selections in Forms, Content type plugin and Scribite.");
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
    _builder.append("* @return ");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Response_Ajax");
      } else {
        _builder.append("AjaxResponse");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getItemListFinder");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("(array $args = array())");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!SecurityUtil::checkPermission($this->name . \'::Ajax\', \'::\', ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(app);
    String _name = _leadingEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($this->request->");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("isPost()");
      } else {
        _builder.append("isMethod(\'POST\')");
      }
    }
    _builder.append(" && $this->request->request->has(\'ot\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$objectType = $this->request->request->filter(\'ot\', \'");
    Entity _leadingEntity_1 = this._modelExtensions.getLeadingEntity(app);
    String _name_1 = _leadingEntity_1.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} elseif ($this->request->");
    {
      boolean _targets_3 = this._utils.targets(app, "1.3.5");
      if (_targets_3) {
        _builder.append("isGet()");
      } else {
        _builder.append("isMethod(\'GET\')");
      }
    }
    _builder.append(" && $this->request->query->has(\'ot\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$objectType = $this->request->query->filter(\'ot\', \'");
    Entity _leadingEntity_2 = this._modelExtensions.getLeadingEntity(app);
    String _name_2 = _leadingEntity_2.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "        ");
    _builder.append("\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_4 = this._utils.targets(app, "1.3.5");
      if (_targets_4) {
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_5 = this._utils.targets(app, "1.3.5");
      boolean _not_1 = (!_targets_5);
      if (_not_1) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'controller\' => \'");
    String _formattedName = this._controllerExtensions.formattedName(it);
    _builder.append(_formattedName, "    ");
    _builder.append("\', \'action\' => \'getItemListFinder\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerAction\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_6 = this._utils.targets(app, "1.3.5");
      if (_targets_6) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "    ");
        _builder.append("_Entity_\' . ucfirst($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = app.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name_3 = app.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucfirst($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->setControllerArguments($args);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idFields = ModUtil::apiFunc($this->name, \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$titleField = $repository->getTitleFieldName();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$descriptionField = $repository->getDescriptionFieldName();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sort = (isset($args[\'sort\']) && !empty($args[\'sort\'])) ? $args[\'sort\'] : $this->request->request->filter(\'sort\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sort = $repository->getDefaultSortingField();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sdir = (isset($args[\'sortdir\']) && !empty($args[\'sortdir\'])) ? $args[\'sortdir\'] : $this->request->request->filter(\'sortdir\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sdir = strtolower($sdir);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($sdir != \'asc\' && $sdir != \'desc\') {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$sdir = \'asc\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$where = \'\'; // filters are processed inside the repository class");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sortParam = $sort . \' \' . $sdir;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entities = $repository->selectWhere($where, $sortParam);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$slimItems = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$component = $this->name . \':\' . ucwords($objectType) . \':\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($entities as $item) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$itemId = \'\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$itemId .= ((!empty($itemId)) ? \'_\' : \'\') . $item[$idField];");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!SecurityUtil::checkPermission($component, $itemId . \'::\', ACCESS_READ)) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$slimItems[] = $this->prepareSlimItem($objectType, $item, $itemId, $titleField, $descriptionField);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new ");
    {
      boolean _targets_7 = this._utils.targets(app, "1.3.5");
      if (_targets_7) {
        _builder.append("Zikula_Response_Ajax");
      } else {
        _builder.append("AjaxResponse");
      }
    }
    _builder.append("($slimItems);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Builds and returns a slim data array from a given entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $objectType       The currently treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param object $item             The currently treated entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $itemid           Data item identifier(s).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $titleField       Name of item title field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $descriptionField Name of item description field.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return array The slim data representation.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function prepareSlimItem($objectType, $item, $itemId, $titleField, $descriptionField)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$view = Zikula_View::getInstance(\'");
    String _appName_2 = this._utils.appName(app);
    _builder.append(_appName_2, "    ");
    _builder.append("\', false);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$view->assign($objectType, $item);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$previewInfo = base64_encode($view->fetch(");
    {
      boolean _targets_8 = this._utils.targets(app, "1.3.5");
      if (_targets_8) {
        _builder.append("\'external/\' . $objectType");
      } else {
        _builder.append("\'External/\' . ucwords($objectType)");
      }
    }
    _builder.append(" . \'/info.tpl\'));");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$title = ($titleField != \'\') ? $item[$titleField] : \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$description = ($descriptionField != \'\') ? $item[$descriptionField] : \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return array(\'id\'           => $itemId,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'title\'        => str_replace(\'&amp;\', \'&\', $title),");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'description\'  => $description,");
    _builder.newLine();
    _builder.append("                 ");
    _builder.append("\'previewInfo\'  => $previewInfo);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getItemListAutoCompletion(final AjaxController it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Searches for entities for auto completion usage.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $ot       Treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fragment The fragment of the entered item name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $exclude  Comma separated list with ids of other items (to be excluded from search).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Response_Ajax_Plain");
      } else {
        _builder.append("Plain");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function getItemListAutoCompletion");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!SecurityUtil::checkPermission($this->name . \'::Ajax\', \'::\', ACCESS_EDIT)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(app);
    String _name = _leadingEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($this->request->");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("isPost()");
      } else {
        _builder.append("isMethod(\'POST\')");
      }
    }
    _builder.append(" && $this->request->request->has(\'ot\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$objectType = $this->request->request->filter(\'ot\', \'");
    Entity _leadingEntity_1 = this._modelExtensions.getLeadingEntity(app);
    String _name_1 = _leadingEntity_1.getName();
    String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
    _builder.append(_formatForCode_1, "        ");
    _builder.append("\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} elseif ($this->request->");
    {
      boolean _targets_3 = this._utils.targets(app, "1.3.5");
      if (_targets_3) {
        _builder.append("isGet()");
      } else {
        _builder.append("isMethod(\'GET\')");
      }
    }
    _builder.append(" && $this->request->query->has(\'ot\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$objectType = $this->request->query->filter(\'ot\', \'");
    Entity _leadingEntity_2 = this._modelExtensions.getLeadingEntity(app);
    String _name_2 = _leadingEntity_2.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "        ");
    _builder.append("\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_4 = this._utils.targets(app, "1.3.5");
      if (_targets_4) {
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_5 = this._utils.targets(app, "1.3.5");
      boolean _not_1 = (!_targets_5);
      if (_not_1) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'controller\' => \'");
    String _formattedName = this._controllerExtensions.formattedName(it);
    _builder.append(_formattedName, "    ");
    _builder.append("\', \'action\' => \'getItemListAutoCompletion\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerAction\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_6 = this._utils.targets(app, "1.3.5");
      if (_targets_6) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "    ");
        _builder.append("_Entity_\' . ucfirst($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = app.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name_3 = app.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucfirst($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$idFields = ModUtil::apiFunc($this->name, \'selection\', \'getIdFields\', array(\'ot\' => $objectType));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fragment = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$exclude = \'\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($this->request->");
    {
      boolean _targets_7 = this._utils.targets(app, "1.3.5");
      if (_targets_7) {
        _builder.append("isPost()");
      } else {
        _builder.append("isMethod(\'POST\')");
      }
    }
    _builder.append(" && $this->request->request->has(\'fragment\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$fragment = $this->request->request->get(\'fragment\', \'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$exclude = $this->request->request->get(\'exclude\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("} elseif ($this->request->");
    {
      boolean _targets_8 = this._utils.targets(app, "1.3.5");
      if (_targets_8) {
        _builder.append("isGet()");
      } else {
        _builder.append("isMethod(\'GET\')");
      }
    }
    _builder.append(" && $this->request->query->has(\'fragment\')) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$fragment = $this->request->query->get(\'fragment\', \'\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$exclude = $this->request->query->get(\'exclude\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$exclude = ((!empty($exclude)) ? array($exclude) : array());");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// parameter for used sorting field");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$sort = $this->request->query->get(\'sort\', \'\');");
    _builder.newLine();
    _builder.append("    ");
    ControllerHelper _controllerHelper = new ControllerHelper();
    CharSequence _defaultSorting = _controllerHelper.defaultSorting(it);
    _builder.append(_defaultSorting, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$sortParam = $sort . \' asc\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$currentPage = 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$resultsPerPage = 20;");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// get objects from database");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("list($entities, $objectCount) = $repository->selectSearch($fragment, $exclude, $sortParam, $currentPage, $resultsPerPage);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$out = \'<ul>\';");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ((is_array($entities) || is_object($entities)) && count($entities) > 0) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$titleFieldName = $repository->getTitleFieldName();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$descriptionFieldName = $repository->getDescriptionFieldName();");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$previewFieldName = $repository->getPreviewFieldName();");
    _builder.newLine();
    {
      boolean _hasImageFields = this._modelExtensions.hasImageFields(app);
      if (_hasImageFields) {
        _builder.append("        ");
        _builder.append("if (!empty($previewFieldName)) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$imageHelper = new ");
        {
          boolean _targets_9 = this._utils.targets(app, "1.3.5");
          if (_targets_9) {
            String _appName_2 = this._utils.appName(app);
            _builder.append(_appName_2, "            ");
            _builder.append("_Util_Image");
          } else {
            _builder.append("ImageUtil");
          }
        }
        _builder.append("($this->serviceManager");
        {
          boolean _targets_10 = this._utils.targets(app, "1.3.5");
          boolean _not_2 = (!_targets_10);
          if (_not_2) {
            _builder.append(", ModUtil::getModule($this->name)");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        _builder.append("$imagineManager = $imageHelper->getManager($objectType, $previewFieldName, \'controllerAction\', $utilArgs);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("        ");
    _builder.append("foreach ($entities as $item) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// class=\"informal\" --> show in dropdown, but do nots copy in the input field after selection");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$itemTitle = (!empty($titleFieldName)) ? $item[$titleFieldName] : $this->__(\'Item\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$itemTitleStripped = str_replace(\'\"\', \'\', $itemTitle);");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$itemDescription = (isset($item[$descriptionFieldName]) && !empty($item[$descriptionFieldName])) ? $item[$descriptionFieldName] : \'\';//$this->__(\'No description yet.\');");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$itemId = \'\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("foreach ($idFields as $idField) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$itemId .= ((!empty($itemId)) ? \'_\' : \'\') . $item[$idField];");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$out .= \'<li id=\"\' . $itemId . \'\" title=\"\' . $itemTitleStripped . \'\">\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$out .= \'<div class=\"itemtitle\">\' . $itemTitle . \'</div>\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if (!empty($itemDescription)) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$out .= \'<div class=\"itemdesc informal\">\' . substr($itemDescription, 0, 50) . \'&hellip;</div>\';");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    {
      boolean _hasImageFields_1 = this._modelExtensions.hasImageFields(app);
      if (_hasImageFields_1) {
        _builder.append("            ");
        _builder.append("// check for preview image");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("if (!empty($previewFieldName) && !empty($item[$previewFieldName]) && isset($item[$previewFieldName . \'FullPath\'])) {");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$fullObjectId = $objectType . \'-\' . $itemId;");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$thumbImagePath = $imagineManager->getThumb($item[$previewFieldName], $fullObjectId);");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$preview = \'<img src=\"\' . $thumbImagePath . \'\" width=\"\' . $thumbWidth . \'\" height=\"\' . $thumbHeight . \'\" alt=\"\' . $itemTitleStripped . \'\" />\';");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("    ");
        _builder.append("$out .= \'<div class=\"itempreview informal\" id=\"itempreview\' . $itemId . \'\">\' . $preview . \'</div>\';");
        _builder.newLine();
        _builder.append("            ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("            ");
    _builder.append("$out .= \'</li>\';");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$out .= \'</ul>\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return response");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new ");
    {
      boolean _targets_11 = this._utils.targets(app, "1.3.5");
      if (_targets_11) {
        _builder.append("Zikula_Response_Ajax_Plain");
      } else {
        _builder.append("Plain");
      }
    }
    _builder.append("($out);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence checkForDuplicate(final AjaxController it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Checks whether a field value is a duplicate or not.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $ot       Treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $fragment The fragment of the entered item name.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $exclude  Optinal identifier to be excluded from search.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws \\Zikula_Exception If something fatal occurs.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Response_Ajax");
      } else {
        _builder.append("AjaxResponse");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function checkForDuplicate");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->checkAjaxToken();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . \'::Ajax\', \'::\', ACCESS_EDIT));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->request->request->filter(\'ot\', \'");
    Entity _leadingEntity = this._modelExtensions.getLeadingEntity(app);
    String _name = _leadingEntity.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\', FILTER_SANITIZE_STRING);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$controllerHelper = new ");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("_Util_Controller");
      } else {
        _builder.append("ControllerUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_3 = this._utils.targets(app, "1.3.5");
      boolean _not_1 = (!_targets_3);
      if (_not_1) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$utilArgs = array(\'controller\' => \'");
    String _formattedName = this._controllerExtensions.formattedName(it);
    _builder.append(_formattedName, "    ");
    _builder.append("\', \'action\' => \'checkForDuplicate\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, $controllerHelper->getObjectTypes(\'controllerAction\', $utilArgs))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$objectType = $controllerHelper->getDefaultObjectType(\'controllerAction\', $utilArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$fieldName = $this->request->request->filter(\'fn\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$value = $this->request->request->get(\'v\', \'\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (empty($fieldName) || empty($value)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new ");
    {
      boolean _targets_4 = this._utils.targets(app, "1.3.5");
      if (_targets_4) {
        _builder.append("Zikula_Response_Ajax_BadData");
      } else {
        _builder.append("BadDataResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid input.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// check if the given field is existing and unique");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$uniqueFields = array();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      EList<Entity> _allEntities = this._modelExtensions.getAllEntities(app);
      for(final Entity entity : _allEntities) {
        _builder.append("        ");
        Iterable<DerivedField> _uniqueDerivedFields = this._modelExtensions.getUniqueDerivedFields(entity);
        final Function1<DerivedField,Boolean> _function = new Function1<DerivedField,Boolean>() {
            public Boolean apply(final DerivedField e) {
              boolean _isPrimaryKey = e.isPrimaryKey();
              boolean _not = (!_isPrimaryKey);
              return Boolean.valueOf(_not);
            }
          };
        final Iterable<DerivedField> uniqueFields = IterableExtensions.<DerivedField>filter(_uniqueDerivedFields, _function);
        _builder.newLineIfNotEmpty();
        {
          boolean _or = false;
          boolean _isEmpty = IterableExtensions.isEmpty(uniqueFields);
          boolean _not_2 = (!_isEmpty);
          if (_not_2) {
            _or = true;
          } else {
            boolean _and = false;
            boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(entity);
            if (!_hasSluggableFields) {
              _and = false;
            } else {
              boolean _isSlugUnique = entity.isSlugUnique();
              _and = (_hasSluggableFields && _isSlugUnique);
            }
            _or = (_not_2 || _and);
          }
          if (_or) {
            _builder.append("        ");
            _builder.append("case \'");
            String _name_1 = entity.getName();
            String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
            _builder.append(_formatForCode_1, "        ");
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("$uniqueFields = array(");
            {
              boolean _hasElements = false;
              for(final DerivedField uniqueField : uniqueFields) {
                if (!_hasElements) {
                  _hasElements = true;
                } else {
                  _builder.appendImmediate(", ", "                ");
                }
                _builder.append("\'");
                String _name_2 = uniqueField.getName();
                String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
                _builder.append(_formatForCode_2, "                ");
                _builder.append("\'");
              }
            }
            {
              boolean _and_1 = false;
              boolean _hasSluggableFields_1 = this._modelBehaviourExtensions.hasSluggableFields(entity);
              if (!_hasSluggableFields_1) {
                _and_1 = false;
              } else {
                boolean _isSlugUnique_1 = entity.isSlugUnique();
                _and_1 = (_hasSluggableFields_1 && _isSlugUnique_1);
              }
              if (_and_1) {
                {
                  boolean _isEmpty_1 = IterableExtensions.isEmpty(uniqueFields);
                  boolean _not_3 = (!_isEmpty_1);
                  if (_not_3) {
                    _builder.append(", ");
                  }
                }
                _builder.append("\'slug\'");
              }
            }
            _builder.append(");");
            _builder.newLineIfNotEmpty();
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("break;");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new ");
    {
      boolean _targets_5 = this._utils.targets(app, "1.3.5");
      if (_targets_5) {
        _builder.append("Zikula_Response_Ajax_BadData");
      } else {
        _builder.append("BadDataResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid input.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$exclude = $this->request->request->get(\'ex\', \'\');");
    _builder.newLine();
    {
      Controllers _container = it.getContainer();
      Application _application = _container.getApplication();
      EList<Entity> _allEntities_1 = this._modelExtensions.getAllEntities(_application);
      final Function1<Entity,Boolean> _function_1 = new Function1<Entity,Boolean>() {
          public Boolean apply(final Entity e) {
            boolean _hasCompositeKeys = Ajax.this._modelExtensions.hasCompositeKeys(e);
            return Boolean.valueOf(_hasCompositeKeys);
          }
        };
      Iterable<Entity> _filter = IterableExtensions.<Entity>filter(_allEntities_1, _function_1);
      boolean _isEmpty_2 = IterableExtensions.isEmpty(_filter);
      boolean _not_4 = (!_isEmpty_2);
      if (_not_4) {
        _builder.append("    ");
        _builder.append("if (strpos($exclude, \'_\') !== false) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("$exclude = explode(\'_\', $exclude);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    {
      boolean _targets_6 = this._utils.targets(app, "1.3.5");
      if (_targets_6) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "    ");
        _builder.append("_Entity_\' . ucfirst($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = app.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name_3 = app.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucfirst($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$object = new $entityClass(); ");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = false;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      EList<Entity> _allEntities_2 = this._modelExtensions.getAllEntities(app);
      for(final Entity entity_1 : _allEntities_2) {
        _builder.append("    ");
        Iterable<DerivedField> _uniqueDerivedFields_1 = this._modelExtensions.getUniqueDerivedFields(entity_1);
        final Function1<DerivedField,Boolean> _function_2 = new Function1<DerivedField,Boolean>() {
            public Boolean apply(final DerivedField e) {
              boolean _isPrimaryKey = e.isPrimaryKey();
              boolean _not = (!_isPrimaryKey);
              return Boolean.valueOf(_not);
            }
          };
        final Iterable<DerivedField> uniqueFields_1 = IterableExtensions.<DerivedField>filter(_uniqueDerivedFields_1, _function_2);
        _builder.newLineIfNotEmpty();
        {
          boolean _or_1 = false;
          boolean _isEmpty_3 = IterableExtensions.isEmpty(uniqueFields_1);
          boolean _not_5 = (!_isEmpty_3);
          if (_not_5) {
            _or_1 = true;
          } else {
            boolean _and_2 = false;
            boolean _hasSluggableFields_2 = this._modelBehaviourExtensions.hasSluggableFields(entity_1);
            if (!_hasSluggableFields_2) {
              _and_2 = false;
            } else {
              boolean _isSlugUnique_2 = entity_1.isSlugUnique();
              _and_2 = (_hasSluggableFields_2 && _isSlugUnique_2);
            }
            _or_1 = (_not_5 || _and_2);
          }
          if (_or_1) {
            _builder.append("    ");
            _builder.append("case \'");
            String _name_4 = entity_1.getName();
            String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_4);
            _builder.append(_formatForCode_3, "    ");
            _builder.append("\':");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("switch ($fieldName) {");
            _builder.newLine();
            {
              for(final DerivedField uniqueField_1 : uniqueFields_1) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("case \'");
                String _name_5 = uniqueField_1.getName();
                String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
                _builder.append(_formatForCode_4, "        ");
                _builder.append("\':");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$result = $repository->detectUniqueState(\'");
                String _name_6 = uniqueField_1.getName();
                String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
                _builder.append(_formatForCode_5, "                ");
                _builder.append("\', $value, $exclude");
                {
                  Controllers _container_1 = it.getContainer();
                  Application _application_1 = _container_1.getApplication();
                  EList<Entity> _allEntities_3 = this._modelExtensions.getAllEntities(_application_1);
                  final Function1<Entity,Boolean> _function_3 = new Function1<Entity,Boolean>() {
                      public Boolean apply(final Entity e) {
                        boolean _hasCompositeKeys = Ajax.this._modelExtensions.hasCompositeKeys(e);
                        return Boolean.valueOf(_hasCompositeKeys);
                      }
                    };
                  Iterable<Entity> _filter_1 = IterableExtensions.<Entity>filter(_allEntities_3, _function_3);
                  boolean _isEmpty_4 = IterableExtensions.isEmpty(_filter_1);
                  boolean _not_6 = (!_isEmpty_4);
                  if (_not_6) {
                    _builder.append("[0]");
                  }
                }
                _builder.append(");");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("break;");
                _builder.newLine();
              }
            }
            {
              boolean _and_3 = false;
              boolean _hasSluggableFields_3 = this._modelBehaviourExtensions.hasSluggableFields(entity_1);
              if (!_hasSluggableFields_3) {
                _and_3 = false;
              } else {
                boolean _isSlugUnique_3 = entity_1.isSlugUnique();
                _and_3 = (_hasSluggableFields_3 && _isSlugUnique_3);
              }
              if (_and_3) {
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("case \'slug\':");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$entity = $repository->selectBySlug($value, false, $exclude);");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("$result = ($entity != null && isset($entity[\'slug\']));");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("break;");
                _builder.newLine();
              }
            }
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("break;");
            _builder.newLine();
          }
        }
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return response");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = array(\'isDuplicate\' => $result);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new ");
    {
      boolean _targets_7 = this._utils.targets(app, "1.3.5");
      if (_targets_7) {
        _builder.append("Zikula_Response_Ajax");
      } else {
        _builder.append("AjaxResponse");
      }
    }
    _builder.append("($result);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence toggleFlag(final AjaxController it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Changes a given flag (boolean field) by switching between true and false.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $ot    Treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $field The field to be toggled.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param int    $id    Identifier of treated entity.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Response_Ajax");
      } else {
        _builder.append("AjaxResponse");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function toggleFlag");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets_1);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name. \'::Ajax\', \'::\', ACCESS_EDIT));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = $this->request->request->filter(\'ot\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$field = $this->request->request->filter(\'field\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$id = (int) $this->request->request->filter(\'id\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    final Iterable<Entity> entities = this._modelExtensions.getEntitiesWithAjaxToggle(app);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("if ($id == 0");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("|| (");
    {
      boolean _hasElements = false;
      for(final Entity entity : entities) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(" && ", "        ");
        }
        _builder.append("$objectType != \'");
        String _name = entity.getName();
        String _formatForCode = this._formattingExtensions.formatForCode(_name);
        _builder.append(_formatForCode, "        ");
        _builder.append("\'");
      }
    }
    _builder.append(")");
    _builder.newLineIfNotEmpty();
    {
      for(final Entity entity_1 : entities) {
        _builder.append("    ");
        _builder.append("|| ($objectType == \'");
        String _name_1 = entity_1.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\' && !in_array($field, array(");
        {
          Iterable<BooleanField> _booleansWithAjaxToggleEntity = this._modelExtensions.getBooleansWithAjaxToggleEntity(entity_1);
          boolean _hasElements_1 = false;
          for(final BooleanField field : _booleansWithAjaxToggleEntity) {
            if (!_hasElements_1) {
              _hasElements_1 = true;
            } else {
              _builder.appendImmediate(", ", "    ");
            }
            _builder.append("\'");
            String _name_2 = field.getName();
            String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
            _builder.append(_formatForCode_2, "    ");
            _builder.append("\'");
          }
        }
        _builder.append(")))");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append(") {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new ");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      if (_targets_2) {
        _builder.append("Zikula_Response_Ajax_BadData");
      } else {
        _builder.append("BadDataResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid input.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// select data from data source");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $id));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($entity == null) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return new ");
    {
      boolean _targets_3 = this._utils.targets(app, "1.3.5");
      if (_targets_3) {
        _builder.append("Zikula_Response_Ajax_NotFound");
      } else {
        _builder.append("NotFoundResponse");
      }
    }
    _builder.append("($this->__(\'No such item.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// toggle the flag");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entity[$field] = !$entity[$field];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// save entity back to database");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->entityManager->flush();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// return response");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$result = array(\'id\' => $id,");
    _builder.newLine();
    _builder.append("                    ");
    _builder.append("\'state\' => $entity[$field]);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new ");
    {
      boolean _targets_4 = this._utils.targets(app, "1.3.5");
      if (_targets_4) {
        _builder.append("Zikula_Response_Ajax");
      } else {
        _builder.append("AjaxResponse");
      }
    }
    _builder.append("($result);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence handleTreeOperations(final AjaxController it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Performs different operations on tree hierarchies.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $ot Treated object type.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param string $op The operation which should be performed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    {
      boolean _targets = this._utils.targets(app, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Response_Ajax");
      } else {
        _builder.append("AjaxResponse");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* @throws ");
    {
      boolean _targets_1 = this._utils.targets(app, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_Exception_Ajax_Fatal");
      } else {
        _builder.append("FatalResponse");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function handleTreeOperation");
    {
      boolean _targets_2 = this._utils.targets(app, "1.3.5");
      boolean _not = (!_targets_2);
      if (_not) {
        _builder.append("Action");
      }
    }
    _builder.append("()");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->throwForbiddenUnless(SecurityUtil::checkPermission($this->name . \'::Ajax\', \'::\', ACCESS_EDIT));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    final Iterable<Entity> treeEntities = this._modelBehaviourExtensions.getTreeEntities(app);
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// parameter specifying which type of objects we are treating");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType = DataUtil::convertFromUTF8($this->request->request->filter(\'ot\', \'");
    Entity _head = IterableExtensions.<Entity>head(treeEntities);
    String _name = _head.getName();
    String _formatForCode = this._formattingExtensions.formatForCode(_name);
    _builder.append(_formatForCode, "    ");
    _builder.append("\', FILTER_SANITIZE_STRING));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("// ensure that we use only object types with tree extension enabled");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($objectType, array(");
    {
      boolean _hasElements = false;
      for(final Entity treeEntity : treeEntities) {
        if (!_hasElements) {
          _hasElements = true;
        } else {
          _builder.appendImmediate(", ", "    ");
        }
        _builder.append("\'");
        String _name_1 = treeEntity.getName();
        String _formatForCode_1 = this._formattingExtensions.formatForCode(_name_1);
        _builder.append(_formatForCode_1, "    ");
        _builder.append("\'");
      }
    }
    _builder.append("))) {");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("$objectType = \'");
    Entity _head_1 = IterableExtensions.<Entity>head(treeEntities);
    String _name_2 = _head_1.getName();
    String _formatForCode_2 = this._formattingExtensions.formatForCode(_name_2);
    _builder.append(_formatForCode_2, "        ");
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue = array(");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'data\'    => array(),");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'message\' => \'\'");
    _builder.newLine();
    _builder.append("    ");
    _builder.append(");");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$op = DataUtil::convertFromUTF8($this->request->request->filter(\'op\', \'\', FILTER_SANITIZE_STRING));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($op, array(\'addRootNode\', \'addChildNode\', \'deleteNode\', \'moveNode\', \'moveNodeTo\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new ");
    {
      boolean _targets_3 = this._utils.targets(app, "1.3.5");
      if (_targets_3) {
        _builder.append("Zikula_Exception_Ajax_Fatal");
      } else {
        _builder.append("FatalResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid operation.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Get id of treated node");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$id = 0;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($op, array(\'addRootNode\', \'addChildNode\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$id = (int) $this->request->request->filter(\'id\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$id) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("throw new ");
    {
      boolean _targets_4 = this._utils.targets(app, "1.3.5");
      if (_targets_4) {
        _builder.append("Zikula_Exception_Ajax_Fatal");
      } else {
        _builder.append("FatalResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid node.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _targets_5 = this._utils.targets(app, "1.3.5");
      if (_targets_5) {
        _builder.append("    ");
        _builder.append("$entityClass = \'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append("_Entity_\' . ucfirst($objectType);");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        _builder.append("$entityClass = \'\\\\");
        String _vendor = app.getVendor();
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(_vendor);
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("\\\\");
        String _name_3 = app.getName();
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(_name_3);
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("Module\\\\Entity\\\\\' . ucfirst($objectType) . \'Entity\';");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("    ");
    _builder.append("$repository = $this->entityManager->getRepository($entityClass);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$rootId = 1;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($op, array(\'addRootNode\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$rootId = (int) $this->request->request->filter(\'root\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if (!$rootId) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("throw new ");
    {
      boolean _targets_6 = this._utils.targets(app, "1.3.5");
      if (_targets_6) {
        _builder.append("Zikula_Exception_Ajax_Fatal");
      } else {
        _builder.append("FatalResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid root node.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Select tree");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$tree = null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!in_array($op, array(\'addRootNode\'))) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$tree = ModUtil::apiFunc($this->name, \'selection\', \'getTree\', array(\'ot\' => $objectType, \'rootId\' => $rootId));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// verification and recovery of tree");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$verificationResult = $repository->verify();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (is_array($verificationResult)) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("foreach ($verificationResult as $errorMsg) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("LogUtil::registerError($errorMsg);");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$repository->recover();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->entityManager->clear(); // clear cached nodes");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$titleFieldName = $descriptionFieldName = \'\';");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($objectType) {");
    _builder.newLine();
    {
      Iterable<Entity> _treeEntities = this._modelBehaviourExtensions.getTreeEntities(app);
      for(final Entity entity : _treeEntities) {
        _builder.append("        ");
        _builder.append("case \'");
        String _name_4 = entity.getName();
        String _formatForCode_3 = this._formattingExtensions.formatForCode(_name_4);
        _builder.append(_formatForCode_3, "        ");
        _builder.append("\':");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("    ");
        EList<EntityField> _fields = entity.getFields();
        Iterable<StringField> _filter = Iterables.<StringField>filter(_fields, StringField.class);
        final Function1<StringField,Boolean> _function = new Function1<StringField,Boolean>() {
            public Boolean apply(final StringField e) {
              boolean _and = false;
              boolean _and_1 = false;
              boolean _and_2 = false;
              boolean _and_3 = false;
              int _length = e.getLength();
              boolean _greaterEqualsThan = (_length >= 20);
              if (!_greaterEqualsThan) {
                _and_3 = false;
              } else {
                boolean _isNospace = e.isNospace();
                boolean _not = (!_isNospace);
                _and_3 = (_greaterEqualsThan && _not);
              }
              if (!_and_3) {
                _and_2 = false;
              } else {
                boolean _isCountry = e.isCountry();
                boolean _not_1 = (!_isCountry);
                _and_2 = (_and_3 && _not_1);
              }
              if (!_and_2) {
                _and_1 = false;
              } else {
                boolean _isHtmlcolour = e.isHtmlcolour();
                boolean _not_2 = (!_isHtmlcolour);
                _and_1 = (_and_2 && _not_2);
              }
              if (!_and_1) {
                _and = false;
              } else {
                boolean _isLanguage = e.isLanguage();
                boolean _not_3 = (!_isLanguage);
                _and = (_and_1 && _not_3);
              }
              return Boolean.valueOf(_and);
            }
          };
        final Iterable<StringField> stringFields = IterableExtensions.<StringField>filter(_filter, _function);
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("$titleFieldName = \'");
        {
          boolean _isEmpty = IterableExtensions.isEmpty(stringFields);
          boolean _not_1 = (!_isEmpty);
          if (_not_1) {
            StringField _head_2 = IterableExtensions.<StringField>head(stringFields);
            String _name_5 = _head_2.getName();
            String _formatForCode_4 = this._formattingExtensions.formatForCode(_name_5);
            _builder.append(_formatForCode_4, "                ");
          }
        }
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("        ");
        EList<EntityField> _fields_1 = entity.getFields();
        Iterable<TextField> _filter_1 = Iterables.<TextField>filter(_fields_1, TextField.class);
        final Function1<TextField,Boolean> _function_1 = new Function1<TextField,Boolean>() {
            public Boolean apply(final TextField e) {
              boolean _and = false;
              boolean _isLeading = e.isLeading();
              boolean _not = (!_isLeading);
              if (!_not) {
                _and = false;
              } else {
                int _length = e.getLength();
                boolean _greaterEqualsThan = (_length >= 50);
                _and = (_not && _greaterEqualsThan);
              }
              return Boolean.valueOf(_and);
            }
          };
        final Iterable<TextField> textFields = IterableExtensions.<TextField>filter(_filter_1, _function_1);
        _builder.newLineIfNotEmpty();
        {
          boolean _isEmpty_1 = IterableExtensions.isEmpty(textFields);
          boolean _not_2 = (!_isEmpty_1);
          if (_not_2) {
            _builder.append("        ");
            _builder.append("        ");
            _builder.append("$descriptionFieldName = \'");
            TextField _head_3 = IterableExtensions.<TextField>head(textFields);
            String _name_6 = _head_3.getName();
            String _formatForCode_5 = this._formattingExtensions.formatForCode(_name_6);
            _builder.append(_formatForCode_5, "                ");
            _builder.append("\';");
            _builder.newLineIfNotEmpty();
          } else {
            _builder.append("        ");
            _builder.append("        ");
            EList<EntityField> _fields_2 = entity.getFields();
            Iterable<StringField> _filter_2 = Iterables.<StringField>filter(_fields_2, StringField.class);
            final Function1<StringField,Boolean> _function_2 = new Function1<StringField,Boolean>() {
                public Boolean apply(final StringField e) {
                  boolean _and = false;
                  boolean _and_1 = false;
                  boolean _and_2 = false;
                  boolean _and_3 = false;
                  boolean _and_4 = false;
                  boolean _isLeading = e.isLeading();
                  boolean _not = (!_isLeading);
                  if (!_not) {
                    _and_4 = false;
                  } else {
                    int _length = e.getLength();
                    boolean _greaterEqualsThan = (_length >= 50);
                    _and_4 = (_not && _greaterEqualsThan);
                  }
                  if (!_and_4) {
                    _and_3 = false;
                  } else {
                    boolean _isNospace = e.isNospace();
                    boolean _not_1 = (!_isNospace);
                    _and_3 = (_and_4 && _not_1);
                  }
                  if (!_and_3) {
                    _and_2 = false;
                  } else {
                    boolean _isCountry = e.isCountry();
                    boolean _not_2 = (!_isCountry);
                    _and_2 = (_and_3 && _not_2);
                  }
                  if (!_and_2) {
                    _and_1 = false;
                  } else {
                    boolean _isHtmlcolour = e.isHtmlcolour();
                    boolean _not_3 = (!_isHtmlcolour);
                    _and_1 = (_and_2 && _not_3);
                  }
                  if (!_and_1) {
                    _and = false;
                  } else {
                    boolean _isLanguage = e.isLanguage();
                    boolean _not_4 = (!_isLanguage);
                    _and = (_and_1 && _not_4);
                  }
                  return Boolean.valueOf(_and);
                }
              };
            final Iterable<StringField> textStringFields = IterableExtensions.<StringField>filter(_filter_2, _function_2);
            _builder.newLineIfNotEmpty();
            {
              boolean _isEmpty_2 = IterableExtensions.isEmpty(textStringFields);
              boolean _not_3 = (!_isEmpty_2);
              if (_not_3) {
                _builder.append("        ");
                _builder.append("        ");
                _builder.append("$descriptionFieldName = \'");
                StringField _head_4 = IterableExtensions.<StringField>head(textStringFields);
                String _name_7 = _head_4.getName();
                String _formatForCode_6 = this._formattingExtensions.formatForCode(_name_7);
                _builder.append(_formatForCode_6, "                ");
                _builder.append("\';");
                _builder.newLineIfNotEmpty();
              }
            }
          }
        }
        _builder.append("        ");
        _builder.append("        ");
        _builder.append("break;");
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("switch ($op) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'addRootNode\':");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//$this->entityManager->transactional(function($entityManager) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$entity = new $entityClass();");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$entityData = array();");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("if (!empty($titleFieldName)) {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("$entityData[$titleFieldName] = $this->__(\'New root node\');");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("if (!empty($descriptionFieldName)) {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("$entityData[$descriptionFieldName] = $this->__(\'This is a new root node\');");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$entity->merge($entityData);");
    _builder.newLine();
    _builder.append("                            ");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("// save new object to set the root id");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$action = \'submit\';");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets_7 = this._utils.targets(app, "1.3.5");
      if (_targets_7) {
        String _appName_1 = this._utils.appName(app);
        _builder.append(_appName_1, "                                ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_8 = this._utils.targets(app, "1.3.5");
      boolean _not_4 = (!_targets_8);
      if (_not_4) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("                                ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("LogUtil::registerError($this->__f(\'Sorry, but an unknown error occured during the %s action. Please apply the changes again!\', array($action)));");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//});");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'addChildNode\':");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$parentId = (int) $this->request->request->filter(\'pid\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("if (!$parentId) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("throw new ");
    {
      boolean _targets_9 = this._utils.targets(app, "1.3.5");
      if (_targets_9) {
        _builder.append("Zikula_Exception_Ajax_Fatal");
      } else {
        _builder.append("FatalResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid parent node.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//$this->entityManager->transactional(function($entityManager) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$childEntity = new $entityClass();");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$entityData = array();");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$entityData[$titleFieldName] = $this->__(\'New child node\');");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("if (!empty($descriptionFieldName)) {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("$entityData[$descriptionFieldName] = $this->__(\'This is a new child node\');");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$childEntity->merge($entityData);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("// save new object");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$action = \'submit\';");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets_10 = this._utils.targets(app, "1.3.5");
      if (_targets_10) {
        String _appName_2 = this._utils.appName(app);
        _builder.append(_appName_2, "                                ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_11 = this._utils.targets(app, "1.3.5");
      boolean _not_5 = (!_targets_11);
      if (_not_5) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("                                ");
    _builder.append("$success = $workflowHelper->executeAction($childEntity, $action);");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("LogUtil::registerError($this->__f(\'Sorry, but an unknown error occured during the %s action. Please apply the changes again!\', array($action)));");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("//$childEntity->setParent($parentEntity);");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$parentEntity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $parentId, \'useJoins\' => false));");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("if ($parentEntity == null) {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("return new ");
    {
      boolean _targets_12 = this._utils.targets(app, "1.3.5");
      if (_targets_12) {
        _builder.append("Zikula_Response_Ajax_NotFound");
      } else {
        _builder.append("NotFoundResponse");
      }
    }
    _builder.append("($this->__(\'No such item.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$repository->persistAsLastChildOf($childEntity, $parentEntity);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//});");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$this->entityManager->flush();");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'deleteNode\':");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("// remove node from tree and reparent all children");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $id, \'useJoins\' => false));");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("if ($entity == null) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("return new ");
    {
      boolean _targets_13 = this._utils.targets(app, "1.3.5");
      if (_targets_13) {
        _builder.append("Zikula_Response_Ajax_NotFound");
      } else {
        _builder.append("NotFoundResponse");
      }
    }
    _builder.append("($this->__(\'No such item.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$entity->initWorkflow();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("// delete the object");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$action = \'delete\';");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$workflowHelper = new ");
    {
      boolean _targets_14 = this._utils.targets(app, "1.3.5");
      if (_targets_14) {
        String _appName_3 = this._utils.appName(app);
        _builder.append(_appName_3, "                            ");
        _builder.append("_Util_Workflow");
      } else {
        _builder.append("WorkflowUtil");
      }
    }
    _builder.append("($this->serviceManager");
    {
      boolean _targets_15 = this._utils.targets(app, "1.3.5");
      boolean _not_6 = (!_targets_15);
      if (_not_6) {
        _builder.append(", ModUtil::getModule($this->name)");
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("                            ");
    _builder.append("$success = $workflowHelper->executeAction($entity, $action);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("LogUtil::registerError($this->__f(\'Sorry, but an unknown error occured during the %s action. Please apply the changes again!\', array($action)));");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$repository->removeFromTree($entity);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$this->entityManager->clear(); // clear cached nodes");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'moveNode\':");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$moveDirection = $this->request->request->filter(\'direction\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("if (!in_array($moveDirection, array(\'up\', \'down\'))) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("throw new ");
    {
      boolean _targets_16 = this._utils.targets(app, "1.3.5");
      if (_targets_16) {
        _builder.append("Zikula_Exception_Ajax_Fatal");
      } else {
        _builder.append("FatalResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid direction.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $id, \'useJoins\' => false));");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("if ($entity == null) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("return new ");
    {
      boolean _targets_17 = this._utils.targets(app, "1.3.5");
      if (_targets_17) {
        _builder.append("Zikula_Response_Ajax_NotFound");
      } else {
        _builder.append("NotFoundResponse");
      }
    }
    _builder.append("($this->__(\'No such item.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("if ($moveDirection == \'up\') {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$repository->moveUp($entity, 1);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("} else if ($moveDirection == \'down\') {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$repository->moveDown($entity, 1);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$this->entityManager->flush();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("case \'moveNodeTo\':");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$moveDirection = $this->request->request->filter(\'direction\', \'\', FILTER_SANITIZE_STRING);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("if (!in_array($moveDirection, array(\'after\', \'before\', \'bottom\'))) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("throw new ");
    {
      boolean _targets_18 = this._utils.targets(app, "1.3.5");
      if (_targets_18) {
        _builder.append("Zikula_Exception_Ajax_Fatal");
      } else {
        _builder.append("FatalResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid direction.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("$destId = (int) $this->request->request->filter(\'destid\', 0, FILTER_VALIDATE_INT);");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("if (!$destId) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("throw new ");
    {
      boolean _targets_19 = this._utils.targets(app, "1.3.5");
      if (_targets_19) {
        _builder.append("Zikula_Exception_Ajax_Fatal");
      } else {
        _builder.append("FatalResponse");
      }
    }
    _builder.append("($this->__(\'Error: invalid destination node.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//$this->entityManager->transactional(function($entityManager) {");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$entity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $id, \'useJoins\' => false));");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$destEntity = ModUtil::apiFunc($this->name, \'selection\', \'getEntity\', array(\'ot\' => $objectType, \'id\' => $destId, \'useJoins\' => false));");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("if ($entity == null || $destEntity == null) {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("return new ");
    {
      boolean _targets_20 = this._utils.targets(app, "1.3.5");
      if (_targets_20) {
        _builder.append("Zikula_Response_Ajax_NotFound");
      } else {
        _builder.append("NotFoundResponse");
      }
    }
    _builder.append("($this->__(\'No such item.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("                            ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("if ($moveDirection == \'after\') {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("$repository->persistAsNextSiblingOf($entity, $destEntity);");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("} elseif ($moveDirection == \'before\') {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("$repository->persistAsPrevSiblingOf($entity, $destEntity);");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("} elseif ($moveDirection == \'bottom\') {");
    _builder.newLine();
    _builder.append("                                ");
    _builder.append("$repository->persistAsLastChildOf($entity, $destEntity);");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("                            ");
    _builder.append("$this->entityManager->flush();");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("//});");
    _builder.newLine();
    _builder.append("                        ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'message\'] = $this->__(\'The operation was successful.\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// Renew tree");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("/** postponed, for now we do a page reload");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$returnValue[\'data\'] = ModUtil::apiFunc($this->name, \'selection\', \'getTree\', array(\'ot\' => $objectType, \'rootId\' => $rootId));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("*/");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return new ");
    {
      boolean _targets_21 = this._utils.targets(app, "1.3.5");
      if (_targets_21) {
        _builder.append("Zikula_Response_Ajax");
      } else {
        _builder.append("AjaxResponse");
      }
    }
    _builder.append("($returnValue);");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  public CharSequence additionalAjaxFunctions(final Controller it, final Application app) {
    if (it instanceof AjaxController) {
      return _additionalAjaxFunctions((AjaxController)it, app);
    } else if (it != null) {
      return _additionalAjaxFunctions(it, app);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, app).toString());
    }
  }
}
