package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.EntityWorkflowType;
import de.guite.modulestudio.metamodel.JoinRelationship;
import de.guite.modulestudio.metamodel.ManyToManyRelationship;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.UrlExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ItemActions {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private UrlExtensions _urlExtensions = new UrlExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  public CharSequence itemActionsImpl(final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((this._controllerExtensions.hasEditActions(app) || (!app.getRelations().isEmpty()))) {
        _builder.append("$currentUserId = $currentUserApi->isLoggedIn() ? $currentUserApi->get(\'uid\') : 1;");
        _builder.newLine();
      }
    }
    {
      Iterable<Entity> _allEntities = this._modelExtensions.getAllEntities(app);
      for(final Entity entity : _allEntities) {
        _builder.append("if ($entity instanceof ");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(entity.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("Entity) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$component = \'");
        String _appName = this._utils.appName(app);
        _builder.append(_appName, "    ");
        _builder.append(":");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(entity.getName());
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append(":\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$instance = ");
        CharSequence _idFieldsAsParameterCode = this._modelExtensions.idFieldsAsParameterCode(entity, "entity");
        _builder.append(_idFieldsAsParameterCode, "    ");
        _builder.append(" . \'::\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$routePrefix = \'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
        _builder.append(_formatForDB, "    ");
        _builder.append("_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(entity.getName());
        _builder.append(_formatForDB_1, "    ");
        _builder.append("_\';");
        _builder.newLineIfNotEmpty();
        {
          boolean _isStandardFields = entity.isStandardFields();
          if (_isStandardFields) {
            _builder.append("    ");
            _builder.append("$isOwner = $currentUserId > 0 && null !== $entity->getCreatedBy() && $currentUserId == $entity->getCreatedBy()->getUid();");
            _builder.newLine();
          }
        }
        _builder.newLine();
        _builder.append("    ");
        CharSequence _itemActionsTargetingDisplay = this.itemActionsTargetingDisplay(entity, app);
        _builder.append(_itemActionsTargetingDisplay, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _itemActionsTargetingEdit = this.itemActionsTargetingEdit(entity, app);
        _builder.append(_itemActionsTargetingEdit, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _itemActionsTargetingView = this.itemActionsTargetingView(entity, app);
        _builder.append(_itemActionsTargetingView, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _itemActionsForAddingRelatedItems = this.itemActionsForAddingRelatedItems(entity, app);
        _builder.append(_itemActionsForAddingRelatedItems, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence itemActionsTargetingDisplay(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasDisplayAction = this._controllerExtensions.hasDisplayAction(it);
      if (_hasDisplayAction) {
        _builder.append("if ($routeArea == \'admin\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu->addChild($this->__(\'Preview\'), [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'route\' => $routePrefix . \'display\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'routeParameters\' => $entity->createUrlArgs()");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("])->setAttribute(\'icon\', \'fa fa-search-plus\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu[$this->__(\'Preview\')]->setLinkAttribute(\'target\', \'_blank\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu[$this->__(\'Preview\')]->setLinkAttribute(\'title\', $this->__(\'Open preview page\'));");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.append("if ($context != \'display\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu->addChild($this->__(\'Details\'), [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'route\' => $routePrefix . $routeArea . \'display\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'routeParameters\' => $entity->createUrlArgs()");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("])->setAttribute(\'icon\', \'fa fa-eye\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu[$this->__(\'Details\')]->setLinkAttribute(\'title\', str_replace(\'\"\', \'\', $entity->getTitleFromDisplayPattern()));");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence itemActionsTargetingEdit(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _hasEditAction = this._controllerExtensions.hasEditAction(it);
      if (_hasEditAction) {
        _builder.append("if ($permissionApi->hasPermission($component, $instance, ACCESS_EDIT)) {");
        _builder.newLine();
        {
          boolean _isOwnerPermission = it.isOwnerPermission();
          if (_isOwnerPermission) {
            _builder.append("    ");
            _builder.append("// only allow editing for the owner or people with higher permissions");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("if ($isOwner || $permissionApi->hasPermission($component, $instance, ACCESS_ADD)) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            CharSequence _itemActionsForEditAction = this.itemActionsForEditAction(it);
            _builder.append(_itemActionsForEditAction, "        ");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          } else {
            _builder.append("    ");
            CharSequence _itemActionsForEditAction_1 = this.itemActionsForEditAction(it);
            _builder.append(_itemActionsForEditAction_1, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          boolean _isLoggable = it.isLoggable();
          if (_isLoggable) {
            _builder.append("    ");
            _builder.append("if (in_array($context, [\'view\', \'display\'])) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$logEntriesRepo = $this->container->get(\'");
            String _appService = this._utils.appService(app);
            _builder.append(_appService, "        ");
            _builder.append(".entity_factory\')->getObjectManager()->getRepository(\'");
            String _appName = this._utils.appName(app);
            _builder.append(_appName, "        ");
            _builder.append(":");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
            _builder.append(_formatForCodeCapital, "        ");
            _builder.append("LogEntryEntity\');");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("$logEntries = $logEntriesRepo->getLogEntries($entity);");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("if (count($logEntries) > 1) {");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("$menu->addChild($this->__(\'History\'), [");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("\'route\' => $routePrefix . $routeArea . \'loggablehistory\',");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("            ");
            _builder.append("\'routeParameters\' => $entity->createUrlArgs()");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("])->setAttribute(\'icon\', \'fa fa-history\');");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("        ");
            _builder.append("$menu[$this->__(\'History\')]->setLinkAttribute(\'title\', $this->__(\'Watch version history\'));");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("}");
            _builder.newLine();
          }
        }
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _hasDeleteAction = this._controllerExtensions.hasDeleteAction(it);
      if (_hasDeleteAction) {
        _builder.append("if ($permissionApi->hasPermission($component, $instance, ACCESS_DELETE)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu->addChild($this->__(\'Delete\'), [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'route\' => $routePrefix . $routeArea . \'delete\',");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'routeParameters\' => $entity->createUrlArgs()");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("])->setAttribute(\'icon\', \'fa fa-trash-o\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu[$this->__(\'Delete\')]->setLinkAttribute(\'title\', $this->__(\'Delete this ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay, "    ");
        _builder.append("\'));");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence itemActionsTargetingView(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((this._controllerExtensions.hasDisplayAction(it) && this._controllerExtensions.hasViewAction(it))) {
        _builder.append("if ($context == \'display\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$title = $this->__(\'Back to overview\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu->addChild($title, [");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("\'route\' => $routePrefix . $routeArea . \'view\'");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("])->setAttribute(\'icon\', \'fa fa-reply\');");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$menu[$title]->setLinkAttribute(\'title\', $title);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    return _builder;
  }
  
  private CharSequence itemActionsForAddingRelatedItems(final Entity it, final Application app) {
    StringConcatenation _builder = new StringConcatenation();
    final Function1<JoinRelationship, Boolean> _function = (JoinRelationship e) -> {
      return Boolean.valueOf(((Objects.equal(e.getTarget().getApplication(), it.getApplication()) && (e.getTarget() instanceof Entity)) && this._controllerExtensions.hasEditAction(((Entity) e.getTarget()))));
    };
    Iterable<JoinRelationship> _filter = IterableExtensions.<JoinRelationship>filter(this._modelJoinExtensions.getOutgoingJoinRelations(it), _function);
    final Function1<ManyToManyRelationship, Boolean> _function_1 = (ManyToManyRelationship e) -> {
      return Boolean.valueOf(((Objects.equal(e.getSource().getApplication(), it.getApplication()) && (e.getSource() instanceof Entity)) && this._controllerExtensions.hasEditAction(((Entity) e.getSource()))));
    };
    Iterable<ManyToManyRelationship> _filter_1 = IterableExtensions.<ManyToManyRelationship>filter(Iterables.<ManyToManyRelationship>filter(it.getIncoming(), ManyToManyRelationship.class), _function_1);
    final Iterable<JoinRelationship> refedElems = Iterables.<JoinRelationship>concat(_filter, _filter_1);
    _builder.newLineIfNotEmpty();
    {
      boolean _isEmpty = IterableExtensions.isEmpty(refedElems);
      boolean _not = (!_isEmpty);
      if (_not) {
        _builder.newLine();
        _builder.append("// more actions for adding new related items");
        _builder.newLine();
        {
          for(final JoinRelationship elem : refedElems) {
            DataObject _source = elem.getSource();
            final boolean useTarget = Objects.equal(_source, it);
            _builder.newLineIfNotEmpty();
            final String relationAliasName = StringExtensions.toFirstLower(this._formattingExtensions.formatForCode(this._namingExtensions.getRelationAliasName(elem, Boolean.valueOf(useTarget))));
            _builder.newLineIfNotEmpty();
            final String relationAliasNameParam = this._formattingExtensions.formatForCodeCapital(this._namingExtensions.getRelationAliasName(elem, Boolean.valueOf((!useTarget))));
            _builder.newLineIfNotEmpty();
            DataObject _xifexpression = null;
            if ((!useTarget)) {
              _xifexpression = elem.getSource();
            } else {
              _xifexpression = elem.getTarget();
            }
            final DataObject otherEntity = _xifexpression;
            _builder.newLineIfNotEmpty();
            _builder.newLine();
            _builder.append("$relatedComponent = \'");
            String _appName = this._utils.appName(app);
            _builder.append(_appName);
            _builder.append(":");
            String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(otherEntity.getName());
            _builder.append(_formatForCodeCapital);
            _builder.append(":\';");
            _builder.newLineIfNotEmpty();
            _builder.append("$relatedInstance = ");
            CharSequence _idFieldsAsParameterCode = this._modelExtensions.idFieldsAsParameterCode(otherEntity, "entity");
            _builder.append(_idFieldsAsParameterCode);
            _builder.append(" . \'::\';");
            _builder.newLineIfNotEmpty();
            _builder.append("if ($isOwner || $permissionApi->hasPermission($relatedComponent, $relatedInstance, ACCESS_");
            {
              boolean _isOwnerPermission = ((Entity) otherEntity).isOwnerPermission();
              if (_isOwnerPermission) {
                _builder.append("ADD");
              } else {
                EntityWorkflowType _workflow = ((Entity) otherEntity).getWorkflow();
                boolean _equals = Objects.equal(_workflow, EntityWorkflowType.NONE);
                if (_equals) {
                  _builder.append("EDIT");
                } else {
                  _builder.append("COMMENT");
                }
              }
            }
            _builder.append(")) {");
            _builder.newLineIfNotEmpty();
            _builder.append("    ");
            final boolean many = this._modelJoinExtensions.isManySideDisplay(elem, useTarget);
            _builder.newLineIfNotEmpty();
            {
              if ((!many)) {
                _builder.append("    ");
                _builder.append("if (!isset($entity->");
                _builder.append(relationAliasName, "    ");
                _builder.append(") || null === $entity->");
                _builder.append(relationAliasName, "    ");
                _builder.append(") {");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$title = $this->__(\'Create ");
                String _formatForDisplay = this._formattingExtensions.formatForDisplay(otherEntity.getName());
                _builder.append(_formatForDisplay, "        ");
                _builder.append("\');");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$menu->addChild($title, [");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("\'route\' => \'");
                String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(app));
                _builder.append(_formatForDB, "            ");
                _builder.append("_");
                String _formatForDB_1 = this._formattingExtensions.formatForDB(otherEntity.getName());
                _builder.append(_formatForDB_1, "            ");
                _builder.append("_\' . $routeArea . \'edit\',");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("        ");
                _builder.append("\'routeParameters\' => [\'");
                String _formatForDB_2 = this._formattingExtensions.formatForDB(relationAliasNameParam);
                _builder.append(_formatForDB_2, "            ");
                _builder.append("\' => ");
                CharSequence _idFieldsAsParameterCode_1 = this._modelExtensions.idFieldsAsParameterCode(it, "entity");
                _builder.append(_idFieldsAsParameterCode_1, "            ");
                _builder.append("]");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("])->setAttribute(\'icon\', \'fa fa-plus\');");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("$menu[$title]->setLinkAttribute(\'title\', $title);");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("}");
                _builder.newLine();
              } else {
                _builder.append("    ");
                _builder.append("$title = $this->__(\'Create ");
                String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(otherEntity.getName());
                _builder.append(_formatForDisplay_1, "    ");
                _builder.append("\');");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("$menu->addChild($title, [");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'route\' => \'");
                String _formatForDB_3 = this._formattingExtensions.formatForDB(this._utils.appName(app));
                _builder.append(_formatForDB_3, "        ");
                _builder.append("_");
                String _formatForDB_4 = this._formattingExtensions.formatForDB(otherEntity.getName());
                _builder.append(_formatForDB_4, "        ");
                _builder.append("_\' . $routeArea . \'edit\',");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("    ");
                _builder.append("\'routeParameters\' => [\'");
                String _formatForDB_5 = this._formattingExtensions.formatForDB(relationAliasNameParam);
                _builder.append(_formatForDB_5, "        ");
                _builder.append("\' => ");
                CharSequence _idFieldsAsParameterCode_2 = this._modelExtensions.idFieldsAsParameterCode(it, "entity");
                _builder.append(_idFieldsAsParameterCode_2, "        ");
                _builder.append("]");
                _builder.newLineIfNotEmpty();
                _builder.append("    ");
                _builder.append("])->setAttribute(\'icon\', \'fa fa-plus\');");
                _builder.newLine();
                _builder.append("    ");
                _builder.append("$menu[$title]->setLinkAttribute(\'title\', $title);");
                _builder.newLine();
              }
            }
            _builder.append("}");
            _builder.newLine();
          }
        }
      }
    }
    return _builder;
  }
  
  private CharSequence itemActionsForEditAction(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isReadOnly = it.isReadOnly();
      boolean _not = (!_isReadOnly);
      if (_not) {
        _builder.append("$menu->addChild($this->__(\'Edit\'), [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'route\' => $routePrefix . $routeArea . \'edit\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'routeParameters\' => $entity->createUrlArgs()");
        _builder.newLine();
        _builder.append("])->setAttribute(\'icon\', \'fa fa-pencil-square-o\');");
        _builder.newLine();
        _builder.append("$menu[$this->__(\'Edit\')]->setLinkAttribute(\'title\', $this->__(\'Edit this ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay);
        _builder.append("\'));");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      EntityTreeType _tree = it.getTree();
      boolean _equals = Objects.equal(_tree, EntityTreeType.NONE);
      if (_equals) {
        _builder.append("$menu->addChild($this->__(\'Reuse\'), [");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'route\' => $routePrefix . $routeArea . \'edit\',");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("\'routeParameters\' => [");
        CharSequence _routeParams = this._urlExtensions.routeParams(it, "entity", Boolean.valueOf(false), "astemplate");
        _builder.append(_routeParams, "    ");
        _builder.append("]");
        _builder.newLineIfNotEmpty();
        _builder.append("])->setAttribute(\'icon\', \'fa fa-files-o\');");
        _builder.newLine();
        _builder.append("$menu[$this->__(\'Reuse\')]->setLinkAttribute(\'title\', $this->__(\'Reuse for new ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay_1);
        _builder.append("\'));");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
}
