package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class ModuleInstaller {
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
    _builder.append("* Listener for the `installer.module.installed` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Called after a module has been successfully installed.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives `$modinfo` as args.");
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
    _builder.append("public static function moduleInstalled(");
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
        _builder.append("parent::moduleInstalled($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `installer.module.upgraded` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Called after a module has been successfully upgraded.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives `$modinfo` as args.");
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
    _builder.append("public static function moduleUpgraded(");
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
        _builder.append("parent::moduleUpgraded($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `installer.module.uninstalled` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Called after a module has been successfully uninstalled.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives `$modinfo` as args.");
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
    _builder.append("public static function moduleUninstalled(");
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
        _builder.append("parent::moduleUninstalled($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    {
      boolean _targets_6 = this._utils.targets(it, "1.3.5");
      boolean _not_3 = (!_targets_6);
      if (_not_3) {
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `installer.module.activated` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Called after a module has been successfully activated.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Receives `$modinfo` as args.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public static function moduleActivated(");
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
          boolean _not_4 = (!(isBase).booleanValue());
          if (_not_4) {
            _builder.append("    ");
            _builder.append("parent::moduleActivated($event);");
            _builder.newLine();
          }
        }
        _builder.append("}");
        _builder.newLine();
        _builder.newLine();
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `installer.module.deactivated` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Called after a module has been successfully deactivated.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Receives `$modinfo` as args.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*/");
        _builder.newLine();
        _builder.append("public static function moduleDeactivated(");
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
          boolean _not_5 = (!(isBase).booleanValue());
          if (_not_5) {
            _builder.append("    ");
            _builder.append("parent::moduleDeactivated($event);");
            _builder.newLine();
          }
        }
        _builder.append("}");
        _builder.newLine();
      }
    }
    _builder.newLine();
    _builder.append("/**");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Listener for the `installer.subscriberarea.uninstalled` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Called after a hook subscriber area has been unregistered.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Receives args[\'areaid\'] as the areaId. Use this to remove orphan data associated with this area.");
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
    _builder.append("public static function subscriberAreaUninstalled(");
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
      boolean _not_6 = (!(isBase).booleanValue());
      if (_not_6) {
        _builder.append("    ");
        _builder.append("parent::subscriberAreaUninstalled($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
