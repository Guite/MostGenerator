package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.CommonExample;

@SuppressWarnings("all")
public class Mailer {
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
        _builder.append("MailerEvents::SEND_MESSAGE_START   => [\'sendMessageStart\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("MailerEvents::SEND_MESSAGE_PERFORM => [\'sendMessagePerform\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("MailerEvents::SEND_MESSAGE_SUCCESS => [\'sendMessageSuccess\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("MailerEvents::SEND_MESSAGE_FAILURE => [\'sendMessageFailure\', 5]");
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
        _builder.append("* Listener for the `module.mailer.api.sendmessage` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs when a new message should be sent.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Invoked from `Zikula\\MailerModule\\Api\\MailerApi#sendMessage`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Subject is `Zikula\\MailerModule\\Api\\MailerApi` with `SwiftMessage $message` object.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This is a notifyUntil event so the event must `$event->stopPropagation()` and set any");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* return data into `$event->data`, or `$event->setData()`.");
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
    _builder.append("public function sendMessageStart(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::sendMessageStart($event);");
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
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `module.mailer.api.perform` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs right before a message is sent.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Invoked from `Zikula\\MailerModule\\Api\\MailerApi#sendMessage`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Subject is `Zikula\\MailerModule\\Api\\MailerApi` with `SwiftMessage $message` object.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This is a notifyUntil event so the event must `$event->stopPropagation()` and set any");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* return data into `$event->data`, or `$event->setData()`.");
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
    _builder.append("public function sendMessagePerform(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::sendMessagePerform($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_1 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_1, "    ");
        _builder.newLineIfNotEmpty();
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
        _builder.append("* Listener for the `module.mailer.api.success` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after a message has been sent successfully.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Invoked from `Zikula\\MailerModule\\Api\\MailerApi#performSending`.");
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
    _builder.append("public function sendMessageSuccess(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::sendMessageSuccess($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_2 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_2, "    ");
        _builder.newLineIfNotEmpty();
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
        _builder.append("* Listener for the `module.mailer.api.failure` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs when a message could not be sent.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Invoked from `Zikula\\MailerModule\\Api\\MailerApi#performSending`.");
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
    _builder.append("public function sendMessageFailure(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::sendMessageFailure($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_3 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_3, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
