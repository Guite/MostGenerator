package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Core {
  @Inject
  @Extension
  private Utils _utils = new Function0<Utils>() {
    public Utils apply() {
      Utils _utils = new Utils();
      return _utils;
    }
  }.apply();
  
  public CharSequence generate(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `api.method_not_found` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Called in instances of Zikula_Api from __call().");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives arguments from __call($method, argument) as $args.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     $event[\'method\'] is the method which didn\'t exist in the main class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     $event[\'args\'] is the arguments that were passed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event subject is the class where the method was not found.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Must exit if $event[\'method\'] does not match whatever the handler expects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Modify $event->data and $event->stop");
    {
      boolean _targets = this._utils.targets(it, "1.3.5");
      boolean _not = (!_targets);
      if (_not) {
        _builder.append("Propagation");
      }
    }
    _builder.append("().");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_1 = this._utils.targets(it, "1.3.5");
      if (_targets_1) {
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
    _builder.append("public static function apiMethodNotFound(");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
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
      boolean _not_1 = (!(isBase).booleanValue());
      if (_not_1) {
        _builder.append("    ");
        _builder.append("parent::apiMethodNotFound($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `core.preinit` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs after the config.php is loaded.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param Zikula_Event $event The event instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*/");
    _builder.newLine();
    _builder.append("public static function preInit(Zikula_Event $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      boolean _not_2 = (!(isBase).booleanValue());
      if (_not_2) {
        _builder.append("    ");
        _builder.append("parent::preInit($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `core.init` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs after each `System::init()` stage, `$event[\'stage\']` contains the stage.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* To check if the handler should execute, do `if($event[\'stage\'] & System::CORE_STAGES_*)`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
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
    _builder.append("public static function init(");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
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
      boolean _not_3 = (!(isBase).booleanValue());
      if (_not_3) {
        _builder.append("    ");
        _builder.append("parent::init($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `core.postinit` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs just before System::init() exits from normal execution.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      if (_targets_5) {
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
    _builder.append("public static function postInit(");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      if (_targets_6) {
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
      boolean _not_4 = (!(isBase).booleanValue());
      if (_not_4) {
        _builder.append("    ");
        _builder.append("parent::postInit($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `controller.method_not_found` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Called in instances of `Zikula_Controller` from `__call()`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives arguments from `__call($method, argument)` as `$args`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*    `$event[\'method\']` is the method which didn\'t exist in the main class.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*    `$event[\'args\']` is the arguments that were passed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event subject is the class where the method was not found.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Must exit if `$event[\'method\']` does not match whatever the handler expects.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Modify `$event->data` and `$event->stop");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      boolean _not_5 = (!_targets_7);
      if (_not_5) {
        _builder.append("Propagation");
      }
    }
    _builder.append("()`.");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      if (_targets_8) {
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
    _builder.append("public static function controllerMethodNotFound(");
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      if (_targets_9) {
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
      boolean _not_6 = (!(isBase).booleanValue());
      if (_not_6) {
        _builder.append("    ");
        _builder.append("parent::controllerMethodNotFound($event);");
        _builder.newLine();
        _builder.newLine();
      }
    }
    _builder.append("    ");
    _builder.append("// You can have multiple of these methods.");
    _builder.newLine();
    _builder.append("    ");
    _builder.append("// See system/Extensions/");
    {
      boolean _targets_10 = this._utils.targets(it, "1.3.5");
      if (_targets_10) {
        _builder.append("lib/Extensions/");
      }
    }
    _builder.append("HookUI.php for an example.");
    _builder.newLineIfNotEmpty();
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
