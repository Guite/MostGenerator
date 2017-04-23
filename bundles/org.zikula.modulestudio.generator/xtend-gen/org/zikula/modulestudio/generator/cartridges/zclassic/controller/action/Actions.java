package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action;

import com.google.common.base.Objects;
import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Action;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.CustomAction;
import de.guite.modulestudio.metamodel.DataObject;
import de.guite.modulestudio.metamodel.DeleteAction;
import de.guite.modulestudio.metamodel.DisplayAction;
import de.guite.modulestudio.metamodel.EditAction;
import de.guite.modulestudio.metamodel.Entity;
import de.guite.modulestudio.metamodel.EntityField;
import de.guite.modulestudio.metamodel.EntityTreeType;
import de.guite.modulestudio.metamodel.MainAction;
import de.guite.modulestudio.metamodel.OneToManyRelationship;
import de.guite.modulestudio.metamodel.OneToOneRelationship;
import de.guite.modulestudio.metamodel.ViewAction;
import java.util.Arrays;
import java.util.List;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.StringExtensions;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Actions {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private Application app;
  
  public Actions(final Application app) {
    this.app = app;
  }
  
  public CharSequence actionImpl(final Entity it, final Action action) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((it instanceof MainAction)) {
        CharSequence _permissionCheck = this.permissionCheck(((MainAction)it), "", "");
        _builder.append(_permissionCheck);
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("// parameter specifying which type of objects we are treating");
        _builder.newLine();
        _builder.append("$objectType = \'");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("$permLevel = $isAdmin ? ACCESS_ADMIN : ");
        String _permissionAccessLevel = this.getPermissionAccessLevel(action);
        _builder.append(_permissionAccessLevel);
        _builder.append(";");
        _builder.newLineIfNotEmpty();
        CharSequence _permissionCheck_1 = this.permissionCheck(action, "\' . ucfirst($objectType) . \'", "");
        _builder.append(_permissionCheck_1);
        _builder.newLineIfNotEmpty();
      }
    }
    CharSequence _actionImplBody = this.actionImplBody(it, action);
    _builder.append(_actionImplBody);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  /**
   * Permission checks in system use cases.
   */
  private CharSequence permissionCheck(final Action it, final String objectTypeVar, final String instanceId) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("if (!$this->hasPermission(\'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append(":");
    _builder.append(objectTypeVar);
    _builder.append(":\', ");
    _builder.append(instanceId);
    _builder.append("\'::\', $permLevel)) {");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("throw new AccessDeniedException();");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private String getPermissionAccessLevel(final Action it) {
    String _switchResult = null;
    boolean _matched = false;
    if (it instanceof MainAction) {
      _matched=true;
      _switchResult = "ACCESS_OVERVIEW";
    }
    if (!_matched) {
      if (it instanceof ViewAction) {
        _matched=true;
        _switchResult = "ACCESS_READ";
      }
    }
    if (!_matched) {
      if (it instanceof DisplayAction) {
        _matched=true;
        _switchResult = "ACCESS_READ";
      }
    }
    if (!_matched) {
      if (it instanceof EditAction) {
        _matched=true;
        _switchResult = "ACCESS_EDIT";
      }
    }
    if (!_matched) {
      if (it instanceof DeleteAction) {
        _matched=true;
        _switchResult = "ACCESS_DELETE";
      }
    }
    if (!_matched) {
      if (it instanceof CustomAction) {
        _matched=true;
        _switchResult = "ACCESS_OVERVIEW";
      }
    }
    if (!_matched) {
      _switchResult = "ACCESS_ADMIN";
    }
    return _switchResult;
  }
  
  private CharSequence _actionImplBody(final Entity it, final Action action) {
    return null;
  }
  
  private CharSequence _actionImplBody(final Entity it, final MainAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'routeArea\' => $isAdmin ? \'admin\' : \'\'");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.append("return $this->redirectToRoute(\'");
        String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
        _builder.append(_formatForDB);
        _builder.append("_");
        String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
        _builder.append(_formatForDB_1);
        _builder.append("_\' . $templateParameters[\'routeArea\'] . \'view\');");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("// return index template");
        _builder.newLine();
        _builder.append("return $this->render(\'@");
        String _appName = this._utils.appName(this.app);
        _builder.append(_appName);
        _builder.append("/");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append("/index.html.twig\', $templateParameters);");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence _actionImplBody(final Entity it, final ViewAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'routeArea\' => $isAdmin ? \'admin\' : \'\'");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService = this._utils.appService(this.app);
    _builder.append(_appService);
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$viewHelper = $this->get(\'");
    String _appService_1 = this._utils.appService(this.app);
    _builder.append(_appService_1);
    _builder.append(".view_helper\');");
    _builder.newLineIfNotEmpty();
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.newLine();
        _builder.append("// check if deleted entities should be displayed");
        _builder.newLine();
        _builder.append("$viewDeleted = $request->query->getInt(\'deleted\', 0);");
        _builder.newLine();
        _builder.append("if ($viewDeleted == 1 && $this->hasPermission(\'");
        String _appName = this._utils.appName(it.getApplication());
        _builder.append(_appName);
        _builder.append(":");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital);
        _builder.append(":\', \'::\', ACCESS_EDIT)) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$entityFactory = $this->get(\'");
        String _appService_2 = this._utils.appService(it.getApplication());
        _builder.append(_appService_2, "    ");
        _builder.append(".entity_factory\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$entityManager = $entityFactory->getObjectManager();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$logEntriesRepository = $entityManager->getRepository(\'");
        String _appName_1 = this._utils.appName(it.getApplication());
        _builder.append(_appName_1, "    ");
        _builder.append(":");
        String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_1, "    ");
        _builder.append("LogEntryEntity\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$deletionLogEntries = $logEntriesRepository->findBy([\'action\' => \'remove\'], [\'loggedAt\' => \'DESC\']);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$templateParameters[\'deletedItems\'] = $deletionLogEntries;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $viewHelper->processTemplate($objectType, \'viewDeleted\', $templateParameters);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("// parameter for used sort order");
    _builder.newLine();
    _builder.append("$sortdir = strtolower($sortdir);");
    _builder.newLine();
    _builder.append("$request->query->set(\'sort\', $sort);");
    _builder.newLine();
    _builder.append("$request->query->set(\'sortdir\', $sortdir);");
    _builder.newLine();
    _builder.append("$request->query->set(\'pos\', $pos);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$sortableColumns = new SortableColumns($this->get(\'router\'), \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
    _builder.append(_formatForDB);
    _builder.append("_");
    String _lowerCase = it.getName().toLowerCase();
    _builder.append(_lowerCase);
    _builder.append("_\' . ($isAdmin ? \'admin\' : \'\') . \'view\', \'sort\', \'sortdir\');");
    _builder.newLineIfNotEmpty();
    {
      EntityTreeType _tree = it.getTree();
      boolean _notEquals = (!Objects.equal(_tree, EntityTreeType.NONE));
      if (_notEquals) {
        _builder.newLine();
        _builder.append("if (\'tree\' == $request->query->getAlnum(\'tpl\', \'\')) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$templateParameters = $controllerHelper->processViewActionParameters($objectType, $sortableColumns, $templateParameters");
        {
          boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(this.app);
          if (_hasHookSubscribers) {
            _builder.append(", ");
            boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
            String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((!_isSkipHookSubscribers)));
            _builder.append(_displayBool, "    ");
          }
        }
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// fetch and return the appropriate template");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("return $viewHelper->processTemplate($objectType, \'view\', $templateParameters);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    CharSequence _initSortableColumns = this.initSortableColumns(it);
    _builder.append(_initSortableColumns);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("$templateParameters = $controllerHelper->processViewActionParameters($objectType, $sortableColumns, $templateParameters");
    {
      boolean _hasHookSubscribers_1 = this._modelExtensions.hasHookSubscribers(this.app);
      if (_hasHookSubscribers_1) {
        _builder.append(", ");
        boolean _isSkipHookSubscribers_1 = it.isSkipHookSubscribers();
        String _displayBool_1 = this._formattingExtensions.displayBool(Boolean.valueOf((!_isSkipHookSubscribers_1)));
        _builder.append(_displayBool_1);
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.append("$featureActivationHelper = $this->get(\'");
        String _appService_3 = this._utils.appService(this.app);
        _builder.append(_appService_3);
        _builder.append(".feature_activation_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$templateParameters[\'items\'] = $this->get(\'");
        String _appService_4 = this._utils.appService(this.app);
        _builder.append(_appService_4, "    ");
        _builder.append(".category_helper\')->filterEntitiesByPermission($templateParameters[\'items\']);");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("foreach ($templateParameters[\'items\'] as $k => $entity) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entity->initWorkflow();");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    {
      boolean _isLoggable_1 = it.isLoggable();
      if (_isLoggable_1) {
        _builder.newLine();
        _builder.append("// check if there exist any deleted ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay);
        _builder.newLineIfNotEmpty();
        _builder.append("$templateParameters[\'hasDeletedEntities\'] = false;");
        _builder.newLine();
        _builder.append("if ($this->hasPermission(\'");
        String _appName_2 = this._utils.appName(it.getApplication());
        _builder.append(_appName_2);
        _builder.append(":");
        String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_2);
        _builder.append(":\', \'::\', ACCESS_EDIT)) {");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$entityFactory = $this->get(\'");
        String _appService_5 = this._utils.appService(it.getApplication());
        _builder.append(_appService_5, "    ");
        _builder.append(".entity_factory\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$entityManager = $entityFactory->getObjectManager();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$logEntriesRepository = $entityManager->getRepository(\'");
        String _appName_3 = this._utils.appName(it.getApplication());
        _builder.append(_appName_3, "    ");
        _builder.append(":");
        String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital_3, "    ");
        _builder.append("LogEntryEntity\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$deletionLogEntries = $logEntriesRepository->findBy([\'action\' => \'remove\'], null, 1);");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$templateParameters[\'hasDeletedEntities\'] = count($deletionLogEntries) > 0;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    _builder.append("return $viewHelper->processTemplate($objectType, \'view\', $templateParameters);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence initSortableColumns(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    final List<EntityField> listItemsFields = this._modelExtensions.getSortingFields(it);
    _builder.newLineIfNotEmpty();
    final Function1<OneToManyRelationship, Boolean> _function = (OneToManyRelationship it_1) -> {
      return Boolean.valueOf((it_1.isBidirectional() && (it_1.getSource() instanceof Entity)));
    };
    final Iterable<OneToManyRelationship> listItemsIn = IterableExtensions.<OneToManyRelationship>filter(Iterables.<OneToManyRelationship>filter(it.getIncoming(), OneToManyRelationship.class), _function);
    _builder.newLineIfNotEmpty();
    final Function1<OneToOneRelationship, Boolean> _function_1 = (OneToOneRelationship it_1) -> {
      DataObject _target = it_1.getTarget();
      return Boolean.valueOf((_target instanceof Entity));
    };
    final Iterable<OneToOneRelationship> listItemsOut = IterableExtensions.<OneToOneRelationship>filter(Iterables.<OneToOneRelationship>filter(it.getOutgoing(), OneToOneRelationship.class), _function_1);
    _builder.newLineIfNotEmpty();
    _builder.append("$sortableColumns->addColumns([");
    _builder.newLine();
    {
      for(final EntityField field : listItemsFields) {
        _builder.append("    ");
        CharSequence _addSortColumn = this.addSortColumn(it, field.getName());
        _builder.append(_addSortColumn, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      for(final OneToManyRelationship relation : listItemsIn) {
        _builder.append("    ");
        CharSequence _addSortColumn_1 = this.addSortColumn(it, this._namingExtensions.getRelationAliasName(relation, Boolean.valueOf(false)));
        _builder.append(_addSortColumn_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      for(final OneToOneRelationship relation_1 : listItemsOut) {
        _builder.append("    ");
        CharSequence _addSortColumn_2 = this.addSortColumn(it, this._namingExtensions.getRelationAliasName(relation_1, Boolean.valueOf(true)));
        _builder.append(_addSortColumn_2, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isGeographical = it.isGeographical();
      if (_isGeographical) {
        _builder.append("    ");
        CharSequence _addSortColumn_3 = this.addSortColumn(it, "latitude");
        _builder.append(_addSortColumn_3, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _addSortColumn_4 = this.addSortColumn(it, "longitude");
        _builder.append(_addSortColumn_4, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isStandardFields = it.isStandardFields();
      if (_isStandardFields) {
        _builder.append("    ");
        CharSequence _addSortColumn_5 = this.addSortColumn(it, "createdBy");
        _builder.append(_addSortColumn_5, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _addSortColumn_6 = this.addSortColumn(it, "createdDate");
        _builder.append(_addSortColumn_6, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _addSortColumn_7 = this.addSortColumn(it, "updatedBy");
        _builder.append(_addSortColumn_7, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        CharSequence _addSortColumn_8 = this.addSortColumn(it, "updatedDate");
        _builder.append(_addSortColumn_8, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("]);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence addSortColumn(final Entity it, final String columnName) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("new Column(\'");
    String _formatForCode = this._formattingExtensions.formatForCode(columnName);
    _builder.append(_formatForCode);
    _builder.append("\'),");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _actionImplBody(final Entity it, final DisplayAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// create identifier for permission check");
    _builder.newLine();
    _builder.append("$instanceId = $");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("->createCompositeIdentifier();");
    _builder.newLineIfNotEmpty();
    CharSequence _permissionCheck = this.permissionCheck(action, "\' . ucfirst($objectType) . \'", "$instanceId . ");
    _builder.append(_permissionCheck);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("$");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1);
        _builder.append("->initWorkflow();");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.append("$requestedVersion = $request->query->getInt(\'version\', 0);");
        _builder.newLine();
        _builder.append("if ($requestedVersion > 0) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// preview of a specific version is desired");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$entityManager = $this->get(\'");
        String _appService = this._utils.appService(it.getApplication());
        _builder.append(_appService, "    ");
        _builder.append(".entity_factory\')->getObjectManager();");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$logEntriesRepository = $entityManager->getRepository(\'");
        String _appName = this._utils.appName(it.getApplication());
        _builder.append(_appName, "    ");
        _builder.append(":");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
        _builder.append(_formatForCodeCapital, "    ");
        _builder.append("LogEntryEntity\');");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$logEntries = $logEntriesRepository->getLogEntries($");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_2, "    ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("if (count($logEntries) > 1) {");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("// revert to requested version but detach to avoid persisting it");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$logEntriesRepository->revert($");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_3, "        ");
        _builder.append(", $requestedVersion);");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("$entityManager->detach($");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_4, "        ");
        _builder.append(");");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'routeArea\' => $isAdmin ? \'admin\' : \'\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType => $");
    String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_5, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("];");
    _builder.newLine();
    {
      boolean _isCategorisable = it.isCategorisable();
      if (_isCategorisable) {
        _builder.newLine();
        _builder.append("$featureActivationHelper = $this->get(\'");
        String _appService_1 = this._utils.appService(this.app);
        _builder.append(_appService_1);
        _builder.append(".feature_activation_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("if (!$this->get(\'");
        String _appService_2 = this._utils.appService(this.app);
        _builder.append(_appService_2, "    ");
        _builder.append(".category_helper\')->hasPermission($");
        String _formatForCode_6 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_6, "    ");
        _builder.append(")) {");
        _builder.newLineIfNotEmpty();
        _builder.append("        ");
        _builder.append("throw new AccessDeniedException();");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("}");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService_3 = this._utils.appService(this.app);
    _builder.append(_appService_3);
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$templateParameters = $controllerHelper->processDisplayActionParameters($objectType, $templateParameters");
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(this.app);
      if (_hasHookSubscribers) {
        _builder.append(", ");
        boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((!_isSkipHookSubscribers)));
        _builder.append(_displayBool);
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _processDisplayOutput = this.processDisplayOutput(it);
    _builder.append(_processDisplayOutput);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence processDisplayOutput(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    _builder.append("$response = $this->get(\'");
    String _appService = this._utils.appService(this.app);
    _builder.append(_appService);
    _builder.append(".view_helper\')->processTemplate($objectType, \'display\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    {
      boolean _generateIcsTemplates = this._generatorSettingsExtensions.generateIcsTemplates(this.app);
      if (_generateIcsTemplates) {
        _builder.newLine();
        _builder.append("$format = $request->getRequestFormat();");
        _builder.newLine();
        _builder.append("if ($format == \'ics\') {");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$fileName = $objectType . \'_\' . (property_exists($");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode, "    ");
        _builder.append(", \'slug\') ? $");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1, "    ");
        _builder.append("[\'slug\'] : $");
        String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_2, "    ");
        _builder.append("->getTitleFromDisplayPattern()) . \'.ics\';");
        _builder.newLineIfNotEmpty();
        _builder.append("    ");
        _builder.append("$response->headers->set(\'Content-Disposition\', \'attachment; filename=\' . $fileName);");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("return $response;");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _actionImplBody(final Entity it, final EditAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'routeArea\' => $isAdmin ? \'admin\' : \'\'");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService = this._utils.appService(this.app);
    _builder.append(_appService);
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$templateParameters = $controllerHelper->processEditActionParameters($objectType, $templateParameters);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// delegate form processing to the form handler");
    _builder.newLine();
    _builder.append("$formHandler = $this->get(\'");
    String _appService_1 = this._utils.appService(this.app);
    _builder.append(_appService_1);
    _builder.append(".form.handler.");
    String _formatForDB = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB);
    _builder.append("\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$result = $formHandler->processForm($templateParameters);");
    _builder.newLine();
    _builder.append("if ($result instanceof RedirectResponse) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $result;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$templateParameters = $formHandler->getTemplateParameters();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    _builder.append("return $this->get(\'");
    String _appService_2 = this._utils.appService(this.app);
    _builder.append(_appService_2);
    _builder.append(".view_helper\')->processTemplate($objectType, \'edit\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence _actionImplBody(final Entity it, final DeleteAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("$logger = $this->get(\'logger\');");
    _builder.newLine();
    _builder.append("$logArgs = [\'app\' => \'");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("\', \'user\' => $this->get(\'zikula_users_module.current_user\')->get(\'uname\'), \'entity\' => \'");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay);
    _builder.append("\', \'id\' => $");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append("->createCompositeIdentifier()];");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      Boolean _targets = this._utils.targets(this.app, "1.5");
      boolean _not = (!(_targets).booleanValue());
      if (_not) {
        _builder.append("$");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1);
        _builder.append("->initWorkflow();");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
      }
    }
    _builder.append("// determine available workflow actions");
    _builder.newLine();
    _builder.append("$workflowHelper = $this->get(\'");
    String _appService = this._utils.appService(this.app);
    _builder.append(_appService);
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$actions = $workflowHelper->getActionsForObject($");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("if (false === $actions || !is_array($actions)) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->addFlash(\'error\', $this->__(\'Error! Could not determine workflow actions.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logger->error(\'{app}: User {user} tried to delete the {entity} with id {id}, but failed to determine available workflow actions.\', $logArgs);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("throw new \\RuntimeException($this->__(\'Error! Could not determine workflow actions.\'));");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// redirect to the ");
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.append("list of ");
        String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getNameMultiple());
        _builder.append(_formatForDisplay_1);
      } else {
        _builder.append("index page");
      }
    }
    _builder.newLineIfNotEmpty();
    _builder.append("$redirectRoute = \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(this.app));
    _builder.append(_formatForDB);
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1);
    _builder.append("_\' . ($isAdmin ? \'admin\' : \'\') . \'");
    {
      boolean _hasViewAction_1 = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction_1) {
        _builder.append("view");
      } else {
        _builder.append("index");
      }
    }
    _builder.append("\';");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("// check whether deletion is allowed");
    _builder.newLine();
    _builder.append("$deleteActionId = \'delete\';");
    _builder.newLine();
    _builder.append("$deleteAllowed = false;");
    _builder.newLine();
    _builder.append("foreach ($actions as $actionId => $action) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($actionId != $deleteActionId) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("continue;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$deleteAllowed = true;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.append("if (!$deleteAllowed) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->addFlash(\'error\', $this->__(\'Error! It is not allowed to delete this ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "    ");
    _builder.append(".\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logger->error(\'{app}: User {user} tried to delete the {entity} with id {id}, but this action was not allowed.\', $logArgs);");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $this->redirectToRoute($redirectRoute);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$form = $this->createForm(\'");
    {
      Boolean _targets_1 = this._utils.targets(this.app, "1.5");
      if ((_targets_1).booleanValue()) {
        _builder.append("Zikula\\Bundle\\FormExtensionBundle\\Form\\Type\\DeletionType");
      } else {
        String _appNamespace = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace);
        _builder.append("\\Form\\DeleteEntityType");
      }
    }
    _builder.append("\', $");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3);
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("if ($form->handleRequest($request)->isValid()) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($form->get(\'delete\')->isClicked()) {");
    _builder.newLine();
    _builder.append("        ");
    CharSequence _deletionProcess = this.deletionProcess(it, action);
    _builder.append(_deletionProcess, "        ");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("} elseif ($form->get(\'cancel\')->isClicked()) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$this->addFlash(\'status\', $this->__(\'Operation cancelled.\'));");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->redirectToRoute($redirectRoute);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'routeArea\' => $isAdmin ? \'admin\' : \'\',");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'deleteForm\' => $form->createView(),");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$objectType => $");
    String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_4, "    ");
    _builder.newLineIfNotEmpty();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$controllerHelper = $this->get(\'");
    String _appService_1 = this._utils.appService(this.app);
    _builder.append(_appService_1);
    _builder.append(".controller_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("$templateParameters = $controllerHelper->processDeleteActionParameters($objectType, $templateParameters");
    {
      boolean _hasHookSubscribers = this._modelExtensions.hasHookSubscribers(this.app);
      if (_hasHookSubscribers) {
        _builder.append(", ");
        boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
        String _displayBool = this._formattingExtensions.displayBool(Boolean.valueOf((!_isSkipHookSubscribers)));
        _builder.append(_displayBool);
      }
    }
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("// fetch and return the appropriate template");
    _builder.newLine();
    _builder.append("return $this->get(\'");
    String _appService_2 = this._utils.appService(this.app);
    _builder.append(_appService_2);
    _builder.append(".view_helper\')->processTemplate($objectType, \'delete\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence deletionProcess(final Entity it, final DeleteAction action) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("$hookHelper = $this->get(\'");
        String _appService = this._utils.appService(this.app);
        _builder.append(_appService);
        _builder.append(".hook_helper\');");
        _builder.newLineIfNotEmpty();
        _builder.append("// Let any hooks perform additional validation actions");
        _builder.newLine();
        _builder.append("$validationHooksPassed = $hookHelper->callValidationHooks($");
        String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode);
        _builder.append(", \'validate_delete\');");
        _builder.newLineIfNotEmpty();
        _builder.append("if ($validationHooksPassed) {");
        _builder.newLine();
        _builder.append("    ");
        CharSequence _performDeletionAndRedirect = this.performDeletionAndRedirect(it, action);
        _builder.append(_performDeletionAndRedirect, "    ");
        _builder.newLineIfNotEmpty();
        _builder.append("}");
        _builder.newLine();
      } else {
        CharSequence _performDeletionAndRedirect_1 = this.performDeletionAndRedirect(it, action);
        _builder.append(_performDeletionAndRedirect_1);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence performDeletionAndRedirect(final Entity it, final DeleteAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("$success = $workflowHelper->executeAction($");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode);
    _builder.append(", $deleteActionId);");
    _builder.newLineIfNotEmpty();
    _builder.append("if ($success) {");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$this->addFlash(\'status\', $this->__(\'Done! Item deleted.\'));");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logger->notice(\'{app}: User {user} deleted the {entity} with id {id}.\', $logArgs);");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.newLine();
        _builder.append("// Let any hooks know that we have deleted the ");
        String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
        _builder.append(_formatForDisplay);
        _builder.newLineIfNotEmpty();
        _builder.append("$hookHelper->callProcessHooks($");
        String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_1);
        _builder.append(", \'process_delete\', null);");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("return $this->redirectToRoute($redirectRoute);");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence _actionImplBody(final Entity it, final CustomAction action) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.newLine();
    _builder.append("$templateParameters = [");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("\'routeArea\' => $isAdmin ? \'admin\' : \'\'");
    _builder.newLine();
    _builder.append("];");
    _builder.newLine();
    _builder.newLine();
    _builder.append("// return template");
    _builder.newLine();
    _builder.append("return $this->render(\'@");
    String _appName = this._utils.appName(this.app);
    _builder.append(_appName);
    _builder.append("/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("/");
    String _firstLower = StringExtensions.toFirstLower(this._formattingExtensions.formatForCode(action.getName()));
    _builder.append(_firstLower);
    _builder.append(".html.twig\', $templateParameters);");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence actionImplBody(final Entity it, final Action action) {
    if (action instanceof CustomAction) {
      return _actionImplBody(it, (CustomAction)action);
    } else if (action instanceof DeleteAction) {
      return _actionImplBody(it, (DeleteAction)action);
    } else if (action instanceof DisplayAction) {
      return _actionImplBody(it, (DisplayAction)action);
    } else if (action instanceof EditAction) {
      return _actionImplBody(it, (EditAction)action);
    } else if (action instanceof MainAction) {
      return _actionImplBody(it, (MainAction)action);
    } else if (action instanceof ViewAction) {
      return _actionImplBody(it, (ViewAction)action);
    } else if (action != null) {
      return _actionImplBody(it, action);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(it, action).toString());
    }
  }
}
