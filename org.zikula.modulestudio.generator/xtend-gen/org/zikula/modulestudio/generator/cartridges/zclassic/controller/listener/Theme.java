package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class Theme {
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
    _builder.append("* Listener for the `theme.preinit` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs on the startup of the `Zikula_View_Theme#__construct()`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The subject is the Zikula_View_Theme instance.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Is useful to setup a customized theme configuration or cache_id.");
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
    _builder.append("public static function preInit(");
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
    _builder.append("* Listener for the `theme.init` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs just before `Zikula_View_Theme#__construct()` finishes.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The subject is the Zikula_View_Theme instance.");
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
    _builder.append("public static function init(");
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
    _builder.append("* Listener for the `theme.load_config` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Runs just before `Theme#load_config()` completed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Subject is the Theme instance.");
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
    _builder.append("public static function loadConfig(");
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
        _builder.append("parent::loadConfig($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `theme.prefetch` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs in `Theme::themefooter()` just after getting the `$maincontent`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event subject is `$this` (Theme instance) and has $maincontent as the event data");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* which you can modify with `$event->setData()` in the event handler.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      if (_targets_6) {
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
    _builder.append("public static function preFetch(");
    {
      boolean _targets_7 = this._utils.targets(it, "1.3.5");
      if (_targets_7) {
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
        _builder.append("parent::preFetch($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `theme.postfetch` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs in `Theme::themefooter()` just after rendering the theme.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event subject is `$this` (Theme instance) and the event data is the rendered");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* output which you can modify with `$event->setData()` in the event handler.");
    _builder.newLine();
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
    _builder.append("public static function postFetch(");
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
      boolean _not_4 = (!(isBase).booleanValue());
      if (_not_4) {
        _builder.append("    ");
        _builder.append("parent::postFetch($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
