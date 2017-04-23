package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.CommonExample;

@SuppressWarnings("all")
public class UserLogin {
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
        _builder.append("AccessEvents::LOGIN_STARTED => [\'started\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("AccessEvents::LOGIN_VETO    => [\'veto\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("AccessEvents::LOGIN_SUCCESS => [\'succeeded\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("AccessEvents::LOGIN_FAILED  => [\'failed\', 5]");
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
        _builder.append("* Listener for the `module.users.ui.login.started` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs at the beginning of the log-in process, before the registration form is displayed to the user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* NOTE: This event will not fire if the log-in process is entered through any other method");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* other than visiting the log-in screen directly.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* For example, if automatic log-in is enabled following registration, then this event");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* will not fire when the system passes control from the registration process to the log-in process.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Likewise, this event will not fire if a user begins the log-in process from the log-in block or a log-in");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* plugin if the user provides valid authentication information.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event will fire, however, if invalid information is provided to the log-in block or log-in plugin,");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* resulting in the user being redirected to the full log-in screen for corrections.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event does not have any subject, arguments, or data.");
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
    _builder.append("public function started(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::started($event);");
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
        _builder.append("* Listener for the `module.users.ui.login.veto` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs immediately prior to a log-in that is expected to succeed.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* (All prerequisites for a successful login have been checked and are satisfied.)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event allows a module to intercept the login process and prevent a successful login from taking place.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* A handler that needs to veto a login attempt should call `stopPropagation()`. This will prevent other handlers");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* from receiving the event, will return to the login process, and will prevent the login from taking place.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* A handler that vetoes a login attempt should set an appropriate error message and give any additional");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* feedback to the user attempting to log in that might be appropriate.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If vetoing the login, the \'returnUrl\' argument should be set to redirect the user to an appropriate action.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Note: the user __will not__ be logged in when the event handler is executing.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Any attempt to check a user\'s permissions, his logged-in status, or any operation will");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* return a value equivalent to what an anonymous (guest) user would see.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Care should be taken to ensure that sensitive operations done within a handler for this event");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* do not introduce breaches of security.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The subject of the event will contain the UserEntity.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The arguments of the event are:");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*     `\'authentication_method\'` will contain the name of the module and the name of the method that was used to authenticated the user.");
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
    _builder.append("public function veto(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::veto($event);");
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
        _builder.append("* Listener for the `module.users.ui.login.succeeded` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs right after a successful attempt to log in, and just prior to redirecting the user to the desired page.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The event subject contains the UserEntity.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The arguments of the event are as follows:");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*     `\'authentication_module\'` will contain the alias (name) of the method that was used to authenticate the user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*     `\'redirecturl\'` will contain the value of the \'returnurl\' parameter, if one was supplied, or an empty");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*       string. This can be modified to change where the user is redirected following the login.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If a `\'redirecturl\'` is specified by any entity intercepting and processing the `module.users.ui.login.succeeded` event, then");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* the URL provided replaces the one provided by the returnurl parameter to the login process. If it is set to an empty");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* string, then the user is redirected to the site\'s home page. An event handler should carefully consider whether ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* changing the `\'redirecturl\'` argument is appropriate. First, the user may be expecting to return to the page where");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* he was when he initiated the log-in process. Being redirected to a different page might be disorienting to the user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Second, an event handler that was notified prior to the current handler may already have changed the `\'returnUrl\'`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Finally, this event only fires in the event of a \"normal\" UI-oriented log-in attempt. A module attempting to log in");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* programmatically by directly calling the core functions will not see this event fired.");
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
    _builder.append("public function succeeded(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::succeeded($event);");
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
        _builder.append("* Listener for the `module.users.ui.login.failed` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs right after an unsuccessful attempt to log in.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The event subject contains the UserEntity if it has been found, otherwise null.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The arguments of the event are as follows:");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* `\'authenticationMethod\'` will contain an instance of the authenticationMethod used that produced the failed login.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* `\'redirecturl\'` will initially contain an empty string. This can be modified to change where the user is redirected following the failed login.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If a `\'redirecturl\'` is specified by any entity intercepting and processing the `module.users.ui.login.failed` event, then");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* the user will be redirected to the URL provided.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* An event handler should carefully consider whether changing the `\'returnUrl\'` argument is appropriate.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* First, the user may be expecting to return to the log-in screen.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Being redirected to a different page might be disorienting to the user.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Second, an event handler that was notified prior to the current handler may already have changed the `\'returnUrl\'`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Finally, this event only fires in the event of a \"normal\" UI-oriented log-in attempt. A module attempting to log in");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* programmatically by directly calling core functions will not see this event fired.");
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
    _builder.append("public function failed(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::failed($event);");
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
