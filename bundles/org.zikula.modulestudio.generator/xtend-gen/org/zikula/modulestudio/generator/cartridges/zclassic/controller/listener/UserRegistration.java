package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import de.guite.modulestudio.metamodel.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener.CommonExample;

@SuppressWarnings("all")
public class UserRegistration {
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
        _builder.append("RegistrationEvents::REGISTRATION_STARTED        => [\'started\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("RegistrationEvents::FULL_USER_CREATE_VETO       => [\'createVeto\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("RegistrationEvents::REGISTRATION_SUCCEEDED      => [\'succeeded\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("RegistrationEvents::REGISTRATION_FAILED         => [\'failed\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("RegistrationEvents::CREATE_REGISTRATION         => [\'create\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("RegistrationEvents::UPDATE_REGISTRATION         => [\'update\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("RegistrationEvents::DELETE_REGISTRATION         => [\'delete\', 5],");
        _builder.newLine();
        _builder.append("    ");
        _builder.append("    ");
        _builder.append("RegistrationEvents::FORCE_REGISTRATION_APPROVAL => [\'forceApproval\', 5]");
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
        _builder.append("* Listener for the `module.users.ui.registration.started` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs at the beginning of the registration process, before the registration form is displayed to the user.");
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
        _builder.append("* Listener for the `full.user.create.veto` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs when the Registration process is determining whether to create a \'registration\' or a \'full user\'.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The subject of the event is the UserEntity. There are no arguments or data. If the User hasn\'t been persisted, then");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* there will be no Uid.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* A handler that needs to veto a registration should call `stopPropagation()`. This will prevent other handlers");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* from receiving the event, will return to the registration process, and will prevent the registration from");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* creating a \'full user\' record.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* For example an authentication method may veto a registration attempt if it requires a user to verify some");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* registration data by email.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* It is assumed that the authentication method will have notified the user of required steps to prevent future");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* vetoes. And provide the methods to correct the issue and process the steps.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Because this event will not necessarily notify ALL listeners (if propagation is stopped) it CANNOT be relied upon");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* to effect change of any kind with regard to the entity.");
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
    _builder.append("public function createVeto(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::createVeto($event);");
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
        _builder.append("* Listener for the `module.users.ui.registration.succeeded` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after a user has successfully registered a new account in the system. It will follow either a `user.registration.create`");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* event, or a `user.account.create` event, depending on the result of the registration process, the information provided by the user,");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* and several configuration options set in the Users module. The resultant record might be a fully activated user record,");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* or it might be a registration record pending approval, e-mail verification, or both.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If the registration record is a fully activated user, and the Users module is configured for automatic log-in,");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* then the system\'s next step (without any interaction from the user) will be the log-in process. All the customary");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* events that might fire during the log-in process could be fired at this point, including (but not limited to)");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* `module.users.ui.login.veto` (which might result in the user having to perform some action in order to proceed with the ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* log-in process), `module.users.ui.login.succeeded`, and/or `module.users.ui.login.failed`.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The event\'s subject is set to the UserEntity.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The event\'s arguments are as follows:");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*     `\'returnurl\'` A URL to which the user is redirected at the very end of the registration process.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* __The `\'redirecturl\'` argument__ controls where the user will be directed at the end of the registration process.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initially, it will be blank, indicating that the default action should be taken. The default action depends on two");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* things: first, whether the result of the registration process is a registration request record or is a full user record,");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* and second, if the record is a full user record then whether automatic log-in is enabled or not.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If a `\'redirectUrl\'` is specified by any entity intercepting and processing the `user.registration.succeeded` event, then");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* how that redirect URL is handled depends on whether the registration process produced a registration request or a full user");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* account record, and if a full user account record was produced then it depends on whether automatic log-in is enabled or");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* not.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If the result of the registration process is a registration request record, then by specifying a redirect URL on the event");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* the default action will be overridden, and the user will be redirected to the specified URL at the end of the process.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If the result of the registration process is a full user account record and automatic log-in is disabled, then by specifying");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* a redirect URL on the event the default action will be overridden, and the user will be redirected to the specified URL at");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* the end of the process.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If the result of the registration process is a full user account record and automatic log-in is enabled, then the user is");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* directed automatically into the log-in process. A redirect URL specified on the event will be passed to the log-in process");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* as the default redirect URL to be used at the end of the log-in process. Note that the user has NOT been automatically ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* redirected to the URL specified on the event. Also note that the log-in process issues its own events, and any one of them");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* could direct the user away from the log-in process and ultimately from the URL specified in this event. Note especially that");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* the log-in process issues its own `module.users.ui.login.succeeded` event that includes the opportunity to set a redirect URL.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The URL specified on this event, as mentioned previously, is passed to the log-in process as the default redirect URL, and");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* therefore is offered on the `module.users.ui.login.succeeded` event as the default. Any handler of that event, however, has");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* the opportunity to change the redirect URL offered. A `module.users.ui.registration.succeeded` handler can reliably predict ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* whether the user will be directed into the log-in process automatically by inspecting the Users module variable ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* `Users_Constant::MODVAR_REGISTRATION_AUTO_LOGIN` (which evaluates to `\'reg_autologin\'`), and by inspecting the `\'activated\'`");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* status of the registration or user object received.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* An event handler should carefully consider whether changing the `\'redirecturl\'` argument is appropriate. First, the user may ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* be expecting to return to the log-in screen . Being redirected to a different page might be disorienting to the user. Second, ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* an event handler that was notified prior to the current handler may already have changed the `\'redirectUrl\'`.");
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
        _builder.append("* Listener for the `module.users.ui.registration.failed` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after a user attempts to submit a registration request, but the request is not saved successfully.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The next step for the user is a page that displays the status, including any possible error messages.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The event subject contains null.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The arguments of the event are as follows:");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* `\'redirecturl\'` will initially contain an empty string. This can be modified to change where the user");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* is redirected following the failed login.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* __The `\'redirecturl\'` argument__ controls where the user will be directed following a failed log-in attempt.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Initially, it will be an empty string, indicating that the user will be redirected to the home page.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* If a `\'redirecturl\'` is specified by any entity intercepting and processing the `user.login.failed` event, then");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* the user will be redirected to the URL provided, instead of being redirected to the status/error display page.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* An event handler should carefully consider whether changing the `\'redirecturl\'` argument is appropriate.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* First, the user may be expecting to be directed to a page containing information on why the registration failed.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Being redirected to a different page might be disorienting to the user. Second, an event handler that was notified");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* prior to the current handler may already have changed the `\'redirectUrl\'`.");
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
    _builder.newLine();
    {
      if ((isBase).booleanValue()) {
        _builder.append("/**");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Listener for the `user.registration.create` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after a registration record is created, either through the normal user registration process, or through the ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* administration panel for the Users module. This event will not fire if the result of the registration process is a");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* full user record. Instead, a `user.account.create` event will fire.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The subject of the event is set to the UserEntity that was created.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This event occurs before the $authenticationMethod->register() method is called.");
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
    _builder.append("public function create(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::create($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_4 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_4, "    ");
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
        _builder.append("* Listener for the `user.registration.update` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after a registration record is updated (likely through the admin panel, but not guaranteed).");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The subject of the event is set to the UserEntity, with the updated values. The event data contains the");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* original UserEntity in an array `[\'oldValue\' => $originalUser]`.");
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
    _builder.append("public function update(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::update($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_5 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_5, "    ");
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
        _builder.append("* Listener for the `user.registration.delete` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs after a registration record is deleted. This could occur as a result of the administrator deleting the record ");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* through the approval/denial process, or it could happen because the registration request expired. This event");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* will not fire if a registration record is converted to a full user account record. Instead, a `user.account.create`");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* event will fire. This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* The subject of the event is set to the Uid being deleted.");
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
    _builder.append("public function delete(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::delete($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_6 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_6, "    ");
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
        _builder.append("* Listener for the `force.registration.approval` event.");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("*");
        _builder.newLine();
        _builder.append(" ");
        _builder.append("* Occurs when an administrator approves a registration. The UserEntity is the subject.");
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
    _builder.append("public function forceApproval(GenericEvent $event)");
    _builder.newLine();
    _builder.append("{");
    _builder.newLine();
    {
      if ((!(isBase).booleanValue())) {
        _builder.append("    ");
        _builder.append("parent::forceApproval($event);");
        _builder.newLine();
        _builder.newLine();
        _builder.append("    ");
        CharSequence _generalEventProperties_7 = this.commonExample.generalEventProperties(it);
        _builder.append(_generalEventProperties_7, "    ");
        _builder.newLineIfNotEmpty();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
