package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.CommonExample;

@SuppressWarnings("all")
public class Users {
  private CommonExample commonExample = new CommonExample();
  
  public CharSequence generate(final Application it, final Boolean isBase) {
    StringConcatenation _builder = new StringConcatenation();
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
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("UserEvents::CONFIG_UPDATED => [\'configUpdated\', 5]");
        _builder.newLine();
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
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `module.users.config.updated` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after the Users module configuration has been");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* updated via the administration interface.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Event data is populated by the new values.");
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
    _builder.append("public function configUpdated(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::configUpdated($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
