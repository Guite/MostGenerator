package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.CommonExample;
import org.zikula.modulestudio.generator.extensions.ControllerExtensions;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class ThirdParty {
  @Extension
  private ControllerExtensions _controllerExtensions = new ControllerExtensions();
  
  @Extension
  private FormattingExtensions _formattingExtensions = new FormattingExtensions();
  
  @Extension
  private GeneratorSettingsExtensions _generatorSettingsExtensions = new GeneratorSettingsExtensions();
  
  @Extension
  private NamingExtensions _namingExtensions = new NamingExtensions();
  
  @Extension
  private Utils _utils = new Utils();
  
  @Extension
  private WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
  
  private CommonExample commonExample = new CommonExample();
  
  public CharSequence generate(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if (((isBase).booleanValue() && (this._workflowExtensions.needsApproval(it) && this._generatorSettingsExtensions.generatePendingContentSupport(it)))) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @var WorkflowHelper");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("protected $workflowHelper;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* ThirdPartyListener constructor.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param WorkflowHelper $workflowHelper WorkflowHelper service instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @return void");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public function __construct(WorkflowHelper $workflowHelper)");
        _builder.newLine();
        _builder.append("{");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("$this->workflowHelper = $workflowHelper;");
        _builder.newLine();
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
      }
    }
    final boolean needsDetailContentType = (this._generatorSettingsExtensions.generateDetailContentType(it) && this._controllerExtensions.hasDisplayActions(it));
    _builder.newLineIfNotEmpty();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Makes our handlers known to the event system.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public static function getSubscribedEvents()");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("    ");
        _builder.append("return [");
        _builder.newLine();
        {
          if ((this._workflowExtensions.needsApproval(it) && this._generatorSettingsExtensions.generatePendingContentSupport(it))) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("\'get.pending_content\'                   => [\'pendingContentListener\', 5],");
            _builder.newLine();
          }
        }
        {
          if ((this._generatorSettingsExtensions.generateListContentType(it) || needsDetailContentType)) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("\'module.content.gettypes\'               => [\'contentGetTypes\', 5],");
            _builder.newLine();
          }
        }
        {
          boolean _generateScribitePlugins = this._generatorSettingsExtensions.generateScribitePlugins(it);
          if (_generateScribitePlugins) {
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("\'module.scribite.editorhelpers\'         => [\'getEditorHelpers\', 5],");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("\'moduleplugin.tinymce.externalplugins\'  => [\'getTinyMcePlugins\', 5],");
            _builder.newLine();
            _builder.append("    ");
            _builder.append("    ");
            _builder.append("\'moduleplugin.ckeditor.externalplugins\' => [\'getCKEditorPlugins\', 5]");
            _builder.newLine();
          }
        }
        _builder.append("    ");
        _builder.append("];");
        _builder.newLine();
      } else {
        _builder.append("    ");
        _builder.append("return parent::getSubscribedEvents();");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    {
      if ((this._workflowExtensions.needsApproval(it) && this._generatorSettingsExtensions.generatePendingContentSupport(it))) {
        CharSequence _pendingContentListener = this.pendingContentListener(it, isBase);
        _builder.append(_pendingContentListener);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      if ((this._generatorSettingsExtensions.generateListContentType(it) || needsDetailContentType)) {
        _builder.newLine();
        CharSequence _contentGetTypes = this.contentGetTypes(it, isBase);
        _builder.append(_contentGetTypes);
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _generateScribitePlugins_1 = this._generatorSettingsExtensions.generateScribitePlugins(it);
      if (_generateScribitePlugins_1) {
        _builder.newLine();
        CharSequence _editorHelpers = this.getEditorHelpers(it, isBase);
        _builder.append(_editorHelpers);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _tinyMcePlugins = this.getTinyMcePlugins(it, isBase);
        _builder.append(_tinyMcePlugins);
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _cKEditorPlugins = this.getCKEditorPlugins(it, isBase);
        _builder.append(_cKEditorPlugins);
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence pendingContentListener(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the \'get.pending_content\' event with registration requests and");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* other submitted data pending approval.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* When a \'get.pending_content\' event is fired, the Users module will respond with the");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* number of registration requests that are pending administrator approval. The number");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* pending may not equal the total number of outstanding registration requests, depending");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* on how the \'moderation_order\' module configuration variable is set, and whether e-mail");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* address verification is required.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If the \'moderation_order\' variable is set to require approval after e-mail verification");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* (and e-mail verification is also required) then the number of pending registration");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* requests will equal the number of registration requested that have completed the");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* verification process but have not yet been approved. For other values of");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* \'moderation_order\', the number should equal the number of registration requests that");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* have not yet been approved, without regard to their current e-mail verification state.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If moderation of registrations is not enabled, then the value will always be 0.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* In accordance with the \'get_pending_content\' conventions, the count of pending");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* registrations, along with information necessary to access the detailed list, is");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* assemped as a {@link Zikula_Provider_AggregateItem} and added to the event");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* subject\'s collection.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param GenericEvent $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function pendingContentListener(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::pendingContentListener($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        CharSequence _pendingContentListenerImpl = this.pendingContentListenerImpl(it);
        _builder.append(_pendingContentListenerImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence pendingContentListenerImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    {
      boolean _needsApproval = this._workflowExtensions.needsApproval(it);
      boolean _not = (!_needsApproval);
      if (_not) {
        _builder.append("// nothing required here as no entities use enhanced workflows including approval actions");
        _builder.newLine();
      } else {
        boolean _generatePendingContentSupport = this._generatorSettingsExtensions.generatePendingContentSupport(it);
        boolean _not_1 = (!_generatePendingContentSupport);
        if (_not_1) {
          _builder.append("// pending content support is disabled in generator settings");
          _builder.newLine();
          _builder.append("// however, we keep this empty stub to prevent errors if the event handler");
          _builder.newLine();
          _builder.append("// was already registered before");
          _builder.newLine();
        } else {
          _builder.append("$modname = \'");
          String _appName = this._utils.appName(it);
          _builder.append(_appName);
          _builder.append("\';");
          _builder.newLineIfNotEmpty();
          _builder.append("$useJoins = false;");
          _builder.newLine();
          _builder.newLine();
          _builder.append("$collection = new Container($modname);");
          _builder.newLine();
          _builder.append("$amounts = $this->workflowHelper->collectAmountOfModerationItems();");
          _builder.newLine();
          _builder.append("if (count($amounts) > 0) {");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("foreach ($amounts as $amountInfo) {");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("$aggregateType = $amountInfo[\'aggregateType\'];");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("$description = $amountInfo[\'description\'];");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("$amount = $amountInfo[\'amount\'];");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("$viewArgs = [");
          _builder.newLine();
          _builder.append("            ");
          _builder.append("\'workflowState\' => $amountInfo[\'state\']");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("];");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("$aggregateItem = new AggregateItem($aggregateType, $description, $amount, $amountInfo[\'objectType\'], \'adminview\', $viewArgs);");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("$collection->add($aggregateItem);");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("}");
          _builder.newLine();
          _builder.newLine();
          _builder.append("    ");
          _builder.append("// add collected items for pending content");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("if ($collection->count() > 0) {");
          _builder.newLine();
          _builder.append("        ");
          _builder.append("$event->getSubject()->add($collection);");
          _builder.newLine();
          _builder.append("    ");
          _builder.append("}");
          _builder.newLine();
          _builder.append("}");
          _builder.newLine();
        }
      }
    }
    return _builder;
  }
  
  private CharSequence contentGetTypes(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `module.content.gettypes` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event occurs when the Content module is \'searching\' for Content plugins.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The subject is an instance of Content_Types.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* You can register custom content types as well as custom layout types.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param \\Zikula_Event $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function contentGetTypes(\\Zikula_Event $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::contentGetTypes($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        CharSequence _contentGetTypesImpl = this.contentGetTypesImpl(it);
        _builder.append(_contentGetTypesImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence contentGetTypesImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// intended is using the add() method to add a plugin like below");
    _builder.newLine();
    _builder.append("$types = $event->getSubject();");
    _builder.newLine();
    _builder.newLine();
    {
      if ((this._generatorSettingsExtensions.generateDetailContentType(it) && this._controllerExtensions.hasDisplayActions(it))) {
        _builder.newLine();
        _builder.append("// plugin for showing a single item");
        _builder.newLine();
        _builder.append("$types->add(\'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName);
        _builder.append("_ContentType_Item\');");
        _builder.newLineIfNotEmpty();
      }
    }
    {
      boolean _generateListContentType = this._generatorSettingsExtensions.generateListContentType(it);
      if (_generateListContentType) {
        _builder.newLine();
        _builder.append("// plugin for showing a list of multiple items");
        _builder.newLine();
        _builder.append("$types->add(\'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1);
        _builder.append("_ContentType_ItemList\');");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence getEditorHelpers(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `module.scribite.editorhelpers` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This occurs when Scribite adds pagevars to the editor page.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* ");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, " ");
        _builder.append(" will use this to add a javascript helper to add custom items.");
        _builder.newLineIfNotEmpty();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param \\Zikula_Event $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function getEditorHelpers(\\Zikula_Event $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::getEditorHelpers($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        CharSequence _editorHelpersImpl = this.getEditorHelpersImpl(it);
        _builder.append(_editorHelpersImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getEditorHelpersImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// intended is using the add() method to add a helper like below");
    _builder.newLine();
    _builder.append("$helpers = $event->getSubject();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$helpers->add(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("[");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'module\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'type\'   => \'javascript\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'path\'   => \'");
    String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(it);
    _builder.append(_relativeAppRootPath, "        ");
    _builder.append("/");
    String _appJsPath = this._namingExtensions.getAppJsPath(it);
    _builder.append(_appJsPath, "        ");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "        ");
    _builder.append(".Finder.js\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("]");
    _builder.newLine();
    _builder.append(");");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getTinyMcePlugins(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `moduleplugin.tinymce.externalplugins` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Adds external plugin to TinyMCE.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param \\Zikula_Event $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function getTinyMcePlugins(\\Zikula_Event $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::getTinyMcePlugins($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        CharSequence _tinyMcePluginsImpl = this.getTinyMcePluginsImpl(it);
        _builder.append(_tinyMcePluginsImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getTinyMcePluginsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// intended is using the add() method to add a plugin like below");
    _builder.newLine();
    _builder.append("$plugins = $event->getSubject();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$plugins->add(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("[");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'name\' => \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'path\' => \'");
    String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(it);
    _builder.append(_relativeAppRootPath, "        ");
    _builder.append("/");
    String _appDocPath = this._namingExtensions.getAppDocPath(it);
    _builder.append(_appDocPath, "        ");
    _builder.append("scribite/plugins/TinyMce/vendor/tinymce/plugins/");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "        ");
    _builder.append("/plugin.js\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("]");
    _builder.newLine();
    _builder.append(");");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCKEditorPlugins(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `moduleplugin.ckeditor.externalplugins` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Adds external plugin to CKEditor.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @param \\Zikula_Event $event The event instance");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      } else {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* @inheritDoc");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
      }
    }
    _builder.append("public function getCKEditorPlugins(\\Zikula_Event $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::getCKEditorPlugins($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties, "    ");
        _builder.newLineIfNotEmpty();
      } else {
        _builder.append("    ");
        CharSequence _cKEditorPluginsImpl = this.getCKEditorPluginsImpl(it);
        _builder.append(_cKEditorPluginsImpl, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCKEditorPluginsImpl(final Application it) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("// intended is using the add() method to add a plugin like below");
    _builder.newLine();
    _builder.append("$plugins = $event->getSubject();");
    _builder.newLine();
    _builder.newLine();
    _builder.append("$plugins->add(");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("[");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'name\' => \'");
    String _formatForDB = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB, "        ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'path\' => \'");
    String _relativeAppRootPath = this._namingExtensions.relativeAppRootPath(it);
    _builder.append(_relativeAppRootPath, "        ");
    _builder.append("/");
    String _appDocPath = this._namingExtensions.getAppDocPath(it);
    _builder.append(_appDocPath, "        ");
    _builder.append("scribite/plugins/CKEditor/vendor/ckeditor/plugins/");
    String _formatForDB_1 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_1, "        ");
    _builder.append("/\',");
    _builder.newLineIfNotEmpty();
    _builder.append("        ");
    _builder.append("\'file\' => \'plugin.js\',");
    _builder.newLine();
    _builder.append("        ");
    _builder.append("\'img\'  => \'ed_");
    String _formatForDB_2 = this._formattingExtensions.formatForDB(this._utils.appName(it));
    _builder.append(_formatForDB_2, "        ");
    _builder.append(".gif\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append("]");
    _builder.newLine();
    _builder.append(");");
    _builder.newLine();
    return _builder;
  }
}
