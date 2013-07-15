package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.FormattingExtensions;
import org.zikula.modulestudio.generator.extensions.NamingExtensions;
import org.zikula.modulestudio.generator.extensions.Utils;
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions;

@SuppressWarnings("all")
public class ThirdParty {
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
  
  @Inject
  @Extension
  private WorkflowExtensions _workflowExtensions = new Function0<WorkflowExtensions>() {
    public WorkflowExtensions apply() {
      WorkflowExtensions _workflowExtensions = new WorkflowExtensions();
      return _workflowExtensions;
    }
  }.apply();
  
  public CharSequence generate(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _pendingContentListener = this.pendingContentListener(it, isBase);
    _builder.append(_pendingContentListener, "");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    CharSequence _contentGetTypes = this.contentGetTypes(it, isBase);
    _builder.append(_contentGetTypes, "");
    _builder.newLineIfNotEmpty();
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.newLine();
        CharSequence _editorHelpers = this.getEditorHelpers(it, isBase);
        _builder.append(_editorHelpers, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _tinyMcePlugins = this.getTinyMcePlugins(it, isBase);
        _builder.append(_tinyMcePlugins, "");
        _builder.newLineIfNotEmpty();
        _builder.newLine();
        CharSequence _cKEditorPlugins = this.getCKEditorPlugins(it, isBase);
        _builder.append(_cKEditorPlugins, "");
        _builder.newLineIfNotEmpty();
      }
    }
    return _builder;
  }
  
  private CharSequence pendingContentListener(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for pending content items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function pendingContentListener(");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not = (!(isBase).booleanValue());
      if (_not) {
        _builder.append("    ");
        _builder.append("parent::pendingContentListener($event);");
        _builder.newLine();
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
        _builder.append("$serviceManager = ServiceUtil::getManager();");
        _builder.newLine();
        _builder.append("$workflowHelper = new ");
        {
          boolean _targets = this._utils.targets(it, "1.3.5");
          if (_targets) {
            String _appName = this._utils.appName(it);
            _builder.append(_appName, "");
            _builder.append("_Util_Workflow");
          } else {
            _builder.append("WorkflowUtil");
          }
        }
        _builder.append("($serviceManager);");
        _builder.newLineIfNotEmpty();
        _builder.append("$modname = \'");
        String _appName_1 = this._utils.appName(it);
        _builder.append(_appName_1, "");
        _builder.append("\';");
        _builder.newLineIfNotEmpty();
        _builder.append("$useJoins = false;");
        _builder.newLine();
        _builder.newLine();
        _builder.append("$collection = new ");
        {
          boolean _targets_1 = this._utils.targets(it, "1.3.5");
          if (_targets_1) {
            _builder.append("Zikula_Collection_");
          }
        }
        _builder.append("Container($modname);");
        _builder.newLineIfNotEmpty();
        _builder.append("$amounts = $workflowHelper->collectAmountOfModerationItems();");
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
        _builder.append("$viewArgs = array(\'ot\' => $amountInfo[\'objectType\'],");
        _builder.newLine();
        _builder.append("                          ");
        _builder.append("\'workflowState\' => $amountInfo[\'state\']);");
        _builder.newLine();
        _builder.append("        ");
        _builder.append("$aggregateItem = new ");
        {
          boolean _targets_2 = this._utils.targets(it, "1.3.5");
          if (_targets_2) {
            _builder.append("Zikula_Provider_");
          }
        }
        _builder.append("AggregateItem($aggregateType, $description, $amount, \'admin\', \'view\', $viewArgs);");
        _builder.newLineIfNotEmpty();
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
    return _builder;
  }
  
  private CharSequence contentGetTypes(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
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
    _builder.append("* @param ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function contentGetTypes(");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not = (!(isBase).booleanValue());
      if (_not) {
        _builder.append("    ");
        _builder.append("parent::contentGetTypes($event);");
        _builder.newLine();
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
    _builder.append("// plugin for showing a single item");
    _builder.newLine();
    _builder.append("$types->add(\'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "");
    _builder.append("_ContentType_Item\');");
    _builder.newLineIfNotEmpty();
    _builder.newLine();
    _builder.append("// plugin for showing a list of multiple items");
    _builder.newLine();
    _builder.append("$types->add(\'");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "");
    _builder.append("_ContentType_ItemList\');");
    _builder.newLineIfNotEmpty();
    return _builder;
  }
  
  private CharSequence getEditorHelpers(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
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
    _builder.append("* @param ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function getEditorHelpers(");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not = (!(isBase).booleanValue());
      if (_not) {
        _builder.append("    ");
        _builder.append("parent::getEditorHelpers($event);");
        _builder.newLine();
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
    _builder.append("array(\'module\' => \'");
    String _appName = this._utils.appName(it);
    _builder.append(_appName, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("          ");
    _builder.append("\'type\'   => \'javascript\',");
    _builder.newLine();
    _builder.append("          ");
    _builder.append("\'path\'   => \'modules/");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "          ");
    _builder.append("/");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("javascript/");
      } else {
        String _appJsPath = this._namingExtensions.getAppJsPath(it);
        _builder.append(_appJsPath, "          ");
      }
    }
    String _appName_2 = this._utils.appName(it);
    _builder.append(_appName_2, "          ");
    _builder.append("_finder.js\')");
    _builder.newLineIfNotEmpty();
    _builder.append(");");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getTinyMcePlugins(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
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
    _builder.append("* @param ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function getTinyMcePlugins(");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not = (!(isBase).booleanValue());
      if (_not) {
        _builder.append("    ");
        _builder.append("parent::getTinyMcePlugins($event);");
        _builder.newLine();
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
    _builder.append("array(\'name\' => \'");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("          ");
    _builder.append("\'path\' => \'modules/");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "          ");
    _builder.append("/");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("docs/");
      } else {
        String _appDocPath = this._namingExtensions.getAppDocPath(it);
        _builder.append(_appDocPath, "          ");
      }
    }
    _builder.append("scribite/plugins/TinyMce/vendor/tiny_mce/plugins/");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_1, "          ");
    _builder.append("/editor_plugin.js\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(")");
    _builder.newLine();
    _builder.append(");");
    _builder.newLine();
    return _builder;
  }
  
  private CharSequence getCKEditorPlugins(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
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
    _builder.append("* @param ");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event The event instance.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function getCKEditorPlugins(");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
        _builder.append("Zikula_Event");
      } else {
        _builder.append("GenericEvent");
      }
    }
    _builder.append(" $event)");
    _builder.newLineIfNotEmpty();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not = (!(isBase).booleanValue());
      if (_not) {
        _builder.append("    ");
        _builder.append("parent::getCKEditorPlugins($event);");
        _builder.newLine();
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
    _builder.append("array(\'name\' => \'");
    String _appName = this._utils.appName(it);
    String _formatForDB = this._formattingExtensions.formatForDB(_appName);
    _builder.append(_formatForDB, "    ");
    _builder.append("\',");
    _builder.newLineIfNotEmpty();
    _builder.append("          ");
    _builder.append("\'path\' => \'modules/");
    String _appName_1 = this._utils.appName(it);
    _builder.append(_appName_1, "          ");
    _builder.append("/");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      if (_targets) {
        _builder.append("docs/");
      } else {
        String _appDocPath = this._namingExtensions.getAppDocPath(it);
        _builder.append(_appDocPath, "          ");
      }
    }
    _builder.append("scribite/plugins/CKEditor/vendor/ckeditor/plugins/");
    String _appName_2 = this._utils.appName(it);
    String _formatForDB_1 = this._formattingExtensions.formatForDB(_appName_2);
    _builder.append(_formatForDB_1, "          ");
    _builder.append("/\',");
    _builder.newLineIfNotEmpty();
    _builder.append("          ");
    _builder.append("\'file\' => \'plugin.js\',");
    _builder.newLine();
    _builder.append("          ");
    _builder.append("\'img\'  => \'ed_");
    String _appName_3 = this._utils.appName(it);
    String _formatForDB_2 = this._formattingExtensions.formatForDB(_appName_3);
    _builder.append(_formatForDB_2, "          ");
    _builder.append(".gif\'");
    _builder.newLineIfNotEmpty();
    _builder.append("    ");
    _builder.append(")");
    _builder.newLine();
    _builder.append(");");
    _builder.newLine();
    return _builder;
  }
}
