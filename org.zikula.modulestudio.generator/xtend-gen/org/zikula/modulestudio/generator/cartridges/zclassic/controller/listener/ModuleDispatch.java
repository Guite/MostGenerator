package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ModuleDispatch {
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
    _builder.append("* Listener for the `module_dispatch.postloadgeneric` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Called after a module api or controller has been loaded.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives the args `array(\'modinfo\' => $modinfo, \'type\' => $type, \'force\' => $force, \'api\' => $api)`.");
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
    _builder.append("public static function postLoadGeneric(");
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
        _builder.append("parent::postLoadGeneric($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `module_dispatch.preexecute` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs in `ModUtil::exec()` after function call with the following args:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `array(\'modname\' => $modname,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'modfunc\' => $modfunc,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'args\' => $args,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'modinfo\' => $modinfo,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'type\' => $type,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'api\' => $api)`");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* .");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      if (_targets_2) {
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
    _builder.append("public static function preExecute(");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      if (_targets_3) {
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
        _builder.append("parent::preExecute($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `module_dispatch.postexecute` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs in `ModUtil::exec()` after function call with the following args:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `array(\'modname\' => $modname,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'modfunc\' => $modfunc,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'args\' => $args,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'modinfo\' => $modinfo,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'type\' => $type,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*            \'api\' => $api)`");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* .");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives the modules output with `$event->getData();`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Can modify this output with `$event->setData($data);`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      if (_targets_4) {
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
    _builder.append("public static function postExecute(");
    {
      boolean _targets_5 = this._utils.targets(it, "1.3.5");
      if (_targets_5) {
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
      boolean _not_2 = (!(isBase).booleanValue());
      if (_not_2) {
        _builder.append("    ");
        _builder.append("parent::postExecute($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `module_dispatch.custom_classname` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* In order to override the classname calculated in `ModUtil::exec()`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* In order to override a pre-existing controller/api method, use this event type to override the class name that is loaded.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This allows to override the methods using inheritance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives no subject, args of `array(\'modname\' => $modname, \'modinfo\' => $modinfo, \'type\' => $type, \'api\' => $api)`");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* and \'event data\' of `$className`. This can be altered by setting `$event->setData()` followed by `$event->stop");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      boolean _not_3 = (!_targets_6);
      if (_not_3) {
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
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      if (_targets_7) {
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
    _builder.append("public static function customClassname(");
    {
      boolean _targets_8 = this._utils.targets(it, "1.3.5");
      if (_targets_8) {
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
        _builder.append("parent::customClassName($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `module_dispatch.service_links` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs when building admin menu items.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Adds sublinks to a Services menu that is appended to all modules if populated.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Triggered by module_dispatch.postexecute in bootstrap.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      if (_targets_9) {
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
    _builder.append("public static function serviceLinks(");
    {
      boolean _targets_10 = this._utils.targets(it, "1.3.5");
      if (_targets_10) {
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
      boolean _not_5 = (!(isBase).booleanValue());
      if (_not_5) {
        _builder.append("    ");
        _builder.append("parent::customClassName($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// Format data like so:");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("// $event->data[] = array(\'url\' => ModUtil::url(\'");
        String _appName = this._utils.appName(it);
        _builder.append(_appName, "    ");
        _builder.append("\', \'user\', \'main\'), \'text\' => __(\'Link Text\'));");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
