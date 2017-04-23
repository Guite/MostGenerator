package org.zikula.modulestudio.generator.cartridges.zclassic.controller;

import com.google.common.collect.Iterables;
import de.guite.modulestudio.metamodel.Action;
import de.guite.modulestudio.metamodel.Application;
import de.guite.modulestudio.metamodel.DerivedField;
import de.guite.modulestudio.metamodel.DisplayAction;
import de.guite.modulestudio.metamodel.Entity;
import java.util.function.Consumer;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerAction;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.LinkContainer;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.InlineRedirect;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.LoggableHistory;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.action.MassHandling;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.AjaxController;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ConfigController;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.ExternalController;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Routing;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions.Scribite;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.QuickNavigation;
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper;
import org.zikula.modulestudio.generator.extensions.CollectionUtils;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions;
import org.zikula.modulestudio.generator.extensions.ModelExtensions;
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ControllerLayer {
  @Extension
  private CollectionUtils _collectionUtils = new CollectionUtils();
  
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private ModelExtensions _modelExtensions = new ModelExtensions();
  
  @Extension
  private ModelJoinExtensions _modelJoinExtensions = new ModelJoinExtensions();
  
  @Extension
  private ModelBehaviourExtensions _modelBehaviourExtensions = new ModelBehaviourExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  private FileHelper fh = new FileHelper();
  
  private Application app;
  
  private ControllerAction actionHelper;
  
  /**
   * Entry point for the controller creation.
   */
  public void generate(final Application it, final IFileSystemAccess fsa) {
    this.app = it;
    ControllerAction _controllerAction = new ControllerAction(this.app);
    this.actionHelper = _controllerAction;
    final Consumer<Entity> _function = (Entity it_1) -> {
      this.generateController(it_1, fsa);
    };
    this._modelExtensions.getAllEntities(it).forEach(_function);
    new AjaxController().generate(it, fsa);
    boolean _needsConfig = this._utils.needsConfig(it);
    if (_needsConfig) {
      new ConfigController().generate(it, fsa);
    }
    new LinkContainer().generate(it, fsa);
    new Routing().generate(it, fsa);
    boolean _hasViewActions = this._controllerExtensions.hasViewActions(it);
    if (_hasViewActions) {
      new QuickNavigation().generate(it, fsa);
    }
    boolean _generateExternalControllerAndFinder = this._generatorSettingsExtensions.generateExternalControllerAndFinder(it);
    if (_generateExternalControllerAndFinder) {
      new ExternalController().generate(it, fsa);
      boolean _generateScribitePlugins = this._generatorSettingsExtensions.generateScribitePlugins(it);
      if (_generateScribitePlugins) {
        new Scribite().generate(it, fsa);
      }
    }
  }
  
  /**
   * Creates controller class files for every Entity instance.
   */
  private void generateController(final Entity it, final IFileSystemAccess fsa) {
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    String _plus = ("Generating \"" + _formatForDisplay);
    String _plus_1 = (_plus + "\" controller classes");
    InputOutput.<String>println(_plus_1);
    String _appSourceLibPath = this._namingExtensions.getAppSourceLibPath(this.app);
    String _plus_2 = (_appSourceLibPath + "Controller/");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    String _plus_3 = (_plus_2 + _formatForCodeCapital);
    String _plus_4 = (_plus_3 + "Controller.php");
    this._namingExtensions.generateClassPair(this.app, fsa, _plus_4, 
      this.fh.phpFileContent(this.app, this.entityControllerBaseImpl(it)), this.fh.phpFileContent(this.app, this.entityControllerImpl(it)));
  }
  
  private CharSequence entityControllerBaseImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _entityControllerBaseImports = this.entityControllerBaseImports(it);
    _builder.append(_entityControllerBaseImports);
    _builder.newLineIfNotEmpty();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" controller base class.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("abstract class Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Controller extends AbstractController");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      EList<Action> _actions = it.getActions();
      for(final Action action : _actions) {
        _builder.append("    ");
        CharSequence _adminAndUserImpl = this.adminAndUserImpl(it, action, Boolean.valueOf(true));
        _builder.append(_adminAndUserImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generate = new MassHandling().generate(it, Boolean.valueOf(true));
        _builder.append(_generate, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generate_1 = new LoggableHistory().generate(it, Boolean.valueOf(true));
        _builder.append(_generate_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((this._controllerExtensions.hasEditAction(it) && this._modelJoinExtensions.needsAutoCompletion(this.app))) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generate_2 = new InlineRedirect().generate(it, Boolean.valueOf(true));
        _builder.append(_generate_2, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence entityControllerBaseImports(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Controller\\Base;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((this._controllerExtensions.hasEditAction(it) || this._controllerExtensions.hasDeleteAction(it))) {
        _builder.append("use RuntimeException;");
        _builder.newLine();
      }
    }
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
    _builder.newLine();
    {
      if (((this._controllerExtensions.hasDisplayAction(it) || this._controllerExtensions.hasEditAction(it)) || this._controllerExtensions.hasDeleteAction(it))) {
        _builder.append("use Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException;");
        _builder.newLine();
      }
    }
    {
      if ((((this._controllerExtensions.hasIndexAction(it) || this._controllerExtensions.hasViewAction(it)) || this._controllerExtensions.hasEditAction(it)) || this._controllerExtensions.hasDeleteAction(it))) {
        _builder.append("use Symfony\\Component\\HttpFoundation\\RedirectResponse;");
        _builder.newLine();
      }
    }
    _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\Cache;");
    _builder.newLine();
    {
      if ((this._controllerExtensions.hasDisplayAction(it) || this._controllerExtensions.hasDeleteAction(it))) {
        _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\ParamConverter;");
        _builder.newLine();
      }
    }
    _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\Route;");
    _builder.newLine();
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.append("use Zikula\\Component\\SortableColumns\\Column;");
        _builder.newLine();
        _builder.append("use Zikula\\Component\\SortableColumns\\SortableColumns;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\Core\\Controller\\AbstractController;");
    _builder.newLine();
    {
      if ((this._controllerExtensions.hasEditAction(it) && this._modelJoinExtensions.needsAutoCompletion(this.app))) {
        _builder.append("use Zikula\\Core\\Response\\PlainResponse;");
        _builder.newLine();
      }
    }
    {
      boolean _isSkipHookSubscribers = it.isSkipHookSubscribers();
      boolean _not = (!_isSkipHookSubscribers);
      if (_not) {
        _builder.append("use Zikula\\Core\\RouteUrl;");
        _builder.newLine();
      }
    }
    _builder.append("use ");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    {
      boolean _hasCategorisableEntities = this._modelBehaviourExtensions.hasCategorisableEntities(this.app);
      if (_hasCategorisableEntities) {
        _builder.append("use ");
        String _appNamespace_1 = this._utils.appNamespace(this.app);
        _builder.append(_appNamespace_1);
        _builder.append("\\Helper\\FeatureActivationHelper;");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence entityControllerImpl(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("namespace ");
    String _appNamespace = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace);
    _builder.append("\\Controller;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("use ");
    String _appNamespace_1 = this._utils.appNamespace(this.app);
    _builder.append(_appNamespace_1);
    _builder.append("\\Controller\\Base\\Abstract");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital);
    _builder.append("Controller;");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    {
      if ((this._controllerExtensions.hasEditAction(it) || this._controllerExtensions.hasDeleteAction(it))) {
        _builder.append("use RuntimeException;");
        _builder.newLine();
      }
    }
    _builder.append("use Sensio\\Bundle\\FrameworkExtraBundle\\Configuration\\Route;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\HttpFoundation\\Request;");
    _builder.newLine();
    _builder.append("use Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException;");
    _builder.newLine();
    {
      if (((this._controllerExtensions.hasDisplayAction(it) || this._controllerExtensions.hasEditAction(it)) || this._controllerExtensions.hasDeleteAction(it))) {
        _builder.append("use Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException;");
        _builder.newLine();
      }
    }
    _builder.append("use Zikula\\ThemeModule\\Engine\\Annotation\\Theme;");
    _builder.newLine();
    _builder.append("use ");
    String _entityClassName = this._namingExtensions.entityClassName(it, "", Boolean.valueOf(false));
    _builder.append(_entityClassName);
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* ");
    String _formatForDisplayCapital = this._formattingExtensions.formatForDisplayCapital(it.getName());
    _builder.append(_formatForDisplayCapital, " ");
    _builder.append(" controller class providing navigation and interaction functionality.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("class ");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1);
    _builder.append("Controller extends Abstract");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_2);
    _builder.append("Controller");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _hasSluggableFields = this._modelBehaviourExtensions.hasSluggableFields(it);
      if (_hasSluggableFields) {
        {
          Iterable<?> _exclude = this._collectionUtils.exclude(it.getActions(), DisplayAction.class);
          for(final Object action : _exclude) {
            _builder.append("    ");
            CharSequence _adminAndUserImpl = this.adminAndUserImpl(it, ((Action) action), Boolean.valueOf(false));
            _builder.append(_adminAndUserImpl, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          if ((it.isLoggable() && this._controllerExtensions.hasDisplayAction(it))) {
            _builder.append("    ");
            CharSequence _displayDeletedAction = this.displayDeletedAction(it);
            _builder.append(_displayDeletedAction, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          Iterable<DisplayAction> _filter = Iterables.<DisplayAction>filter(it.getActions(), DisplayAction.class);
          for(final DisplayAction action_1 : _filter) {
            _builder.append("    ");
            CharSequence _adminAndUserImpl_1 = this.adminAndUserImpl(it, action_1, Boolean.valueOf(false));
            _builder.append(_adminAndUserImpl_1, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      } else {
        {
          if ((it.isLoggable() && this._controllerExtensions.hasDisplayAction(it))) {
            _builder.append("    ");
            CharSequence _displayDeletedAction_1 = this.displayDeletedAction(it);
            _builder.append(_displayDeletedAction_1, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
        {
          EList<Action> _actions = it.getActions();
          for(final Action action_2 : _actions) {
            _builder.append("    ");
            CharSequence _adminAndUserImpl_2 = this.adminAndUserImpl(it, action_2, Boolean.valueOf(false));
            _builder.append(_adminAndUserImpl_2, "    ");
            _builder.newLineIfNotEmpty();
          }
        }
      }
    }
    {
      boolean _hasViewAction = this._controllerExtensions.hasViewAction(it);
      if (_hasViewAction) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generate = new MassHandling().generate(it, Boolean.valueOf(false));
        _builder.append(_generate, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _isLoggable = it.isLoggable();
      if (_isLoggable) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generate_1 = new LoggableHistory().generate(it, Boolean.valueOf(false));
        _builder.append(_generate_1, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((this._controllerExtensions.hasEditAction(it) && this._modelJoinExtensions.needsAutoCompletion(this.app))) {
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generate_2 = new InlineRedirect().generate(it, Boolean.valueOf(false));
        _builder.append(_generate_2, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// feel free to add your own controller methods here");
    _builder.newLine();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence displayDeletedAction(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _displayDeletedSingleAction = this.displayDeletedSingleAction(it, Boolean.valueOf(true));
    _builder.append(_displayDeletedSingleAction);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _displayDeletedSingleAction_1 = this.displayDeletedSingleAction(it, Boolean.valueOf(false));
    _builder.append(_displayDeletedSingleAction_1);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _restoreDeletedEntity = this.restoreDeletedEntity(it);
    _builder.append(_restoreDeletedEntity);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence displayDeletedSingleAction(final Entity it, final Boolean isAdmin) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Displays a deleted ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(".");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @Route(\"/");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("admin/");
      }
    }
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, " ");
    _builder.append("/deleted/{id}.{_format}\",");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*        requirements = {\"id\" = \"\\d+\", \"_format\" = \"html\"},");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*        defaults = {\"_format\" = \"html\"},");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*        methods = {\"GET\"}");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* )");
    _builder.newLine();
    {
      if ((isAdmin).booleanValue()) {
        _builder.append(" ");
        _builder.append("* @Theme(\"admin\")");
        _builder.newLine();
      }
    }
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Request $request Current request instance");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param integer $id      Identifier of entity");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return Response Output");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws AccessDeniedException Thrown if the user doesn\'t have required permissions");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws NotFoundHttpException Thrown if ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" to be displayed isn\'t found");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public function ");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("adminD");
      } else {
        _builder.append("d");
      }
    }
    _builder.append("isplayDeletedAction(Request $request, $id = 0)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, "    ");
    _builder.append(" = $this->restoreDeletedEntity($id);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$undelete = $request->query->getInt(\'undelete\', 0);");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if ($undelete == 1) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("$actionObject->setWorkflowState(\'initial\');");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("try {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("// execute the workflow action");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$workflowHelper = $this->get(\'");
    String _appService = this._utils.appService(it.getApplication());
    _builder.append(_appService, "            ");
    _builder.append(".workflow_helper\');");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("$success = $workflowHelper->executeAction($");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, "            ");
    _builder.append(", \'submit\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("            ");
    _builder.append("if ($success) {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->addFlash(\'status\', $this->__(\'Done! Reinserted ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "                ");
    _builder.append(".\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("} else {");
    _builder.newLine();
    _builder.append("                ");
    _builder.append("$this->addFlash(\'error\', $this->__(\'Error! Reinserting ");
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_3, "                ");
    _builder.append(" failed.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("            ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("} catch(\\Exception $e) {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$this->addFlash(\'error\', $this->__f(\'Sorry, but an error occured during the %action% action. Please apply the changes again!\', [\'%action%\' => \'submit\']) . \'  \' . $e->getMessage());");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      Iterable<DerivedField> _primaryKeyFields = this._modelExtensions.getPrimaryKeyFields(it);
      for(final DerivedField primaryKeyField : _primaryKeyFields) {
        _builder.append("        ");
        _builder.append("$request->query->set(\'");
        String _formatForCode_3 = this._formattingExtensions.formatForCode(primaryKeyField.getName());
        _builder.append(_formatForCode_3, "        ");
        _builder.append("\', $");
        String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
        _builder.append(_formatForCode_4, "        ");
        _builder.append("->get");
        String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(primaryKeyField.getName());
        _builder.append(_formatForCodeCapital, "        ");
        _builder.append("());");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("        ");
    _builder.append("$request->query->remove(\'undelete\');");
    _builder.newLine();
    _builder.newLine();
    _builder.append("        ");
    _builder.append("return $this->redirectToRoute(\'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it.getApplication()));
    _builder.append(_formatForDB, "        ");
    _builder.append("_");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(it.getName());
    _builder.append(_formatForDB_1, "        ");
    _builder.append("_");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("admin");
      }
    }
    _builder.append("display\', $request->query->all());");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return parent::");
    {
      if ((isAdmin).booleanValue()) {
        _builder.append("adminD");
      } else {
        _builder.append("d");
      }
    }
    _builder.append("isplayAction($request, $");
    String _formatForCode_5 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_5, "    ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence restoreDeletedEntity(final Entity it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Resets a deleted ");
    String _formatForDisplay = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay, " ");
    _builder.append(" back to the last version before it\'s deletion.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @return ");
    String _formatForCodeCapital = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital, " ");
    _builder.append("Entity The restored entity");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @throws NotFoundHttpException Thrown if ");
    String _formatForDisplay_1 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_1, " ");
    _builder.append(" isn\'t found");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("protected function restoreDeletedEntity($id = 0)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (!$id) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new NotFoundHttpException($this->__(\'No such ");
    String _formatForDisplay_2 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_2, "        ");
    _builder.append(" found.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$entityFactory = $this->get(\'");
    String _appService = this._utils.appService(it.getApplication());
    _builder.append(_appService, "    ");
    _builder.append(".entity_factory\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$");
    String _formatForCode = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode, "    ");
    _builder.append(" = $entityFactory->create");
    String _formatForCodeCapital_1 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_1, "    ");
    _builder.append("();");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$");
    String _formatForCode_1 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_1, "    ");
    _builder.append("->set");
    String _formatForCodeCapital_2 = this._formattingExtensions.formatForCodeCapital(this._modelExtensions.getFirstPrimaryKey(it).getName());
    _builder.append(_formatForCodeCapital_2, "    ");
    _builder.append("($id);");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$entityManager = $entityFactory->getObjectManager();");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logEntriesRepository = $entityManager->getRepository(\'");
    String _appName = this._utils.appName(it.getApplication());
    _builder.append(_appName, "    ");
    _builder.append(":");
    String _formatForCodeCapital_3 = this._formattingExtensions.formatForCodeCapital(it.getName());
    _builder.append(_formatForCodeCapital_3, "    ");
    _builder.append("LogEntryEntity\');");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$logEntries = $logEntriesRepository->getLogEntries($");
    String _formatForCode_2 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_2, "    ");
    _builder.append(");");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("$lastVersionBeforeDeletion = null;");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("foreach ($logEntries as $logEntry) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("if ($logEntry->getAction() != \'remove\') {");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("$lastVersionBeforeDeletion = $logEntry->getVersion();");
    _builder.newLine();
    _builder.append("            ");
    _builder.append("break;");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("if (null === $lastVersionBeforeDeletion) {");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("throw new NotFoundHttpException($this->__(\'No such ");
    String _formatForDisplay_3 = this._formattingExtensions.formatForDisplay(it.getName());
    _builder.append(_formatForDisplay_3, "        ");
    _builder.append(" found.\'));");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("$logEntriesRepository->revert($");
    String _formatForCode_3 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_3, "    ");
    _builder.append(", $lastVersionBeforeDeletion);");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("    ");
    _builder.append("return $");
    String _formatForCode_4 = this._formattingExtensions.formatForCode(it.getName());
    _builder.append(_formatForCode_4, "    ");
    _builder.append(";");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence adminAndUserImpl(final Entity it, final Action action, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _generate = this.actionHelper.generate(it, action, isBase, Boolean.valueOf(true));
    _builder.append(_generate);
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _generate_1 = this.actionHelper.generate(it, action, isBase, Boolean.valueOf(false));
    _builder.append(_generate_1);
    _builder.newLineIfNotEmpty();
    return _builder;
  }
}
