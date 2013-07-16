package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class UserRegistration {
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
    _builder.append("public static function started(");
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
        _builder.append("parent::started($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
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
    _builder.append("* and several configuration options set in the Users module. The resultant record might");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* be a fully activated user record, or it might be a registration record pending approval, e-mail verification,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* or both.");
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
    _builder.append("* The event\'s subject is set to the registration record (which might be a full user record).");
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
    _builder.append("* If the result of the registration process is a registration request record, then the default action is to direct the");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* user to a status display screen that informs him that the registration process has been completed, and also tells ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* him what next steps are required in order to convert that request into a full user record. (The steps to be");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* taken may be out of the user\'s control--for example, the administrator must approve the request. The steps to");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* be taken might be within the user\'s control--for example, the user must verify his e-mail address. The steps might");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* be some combination of both within and outside the user\'s control.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* If the result of the registration process is a full user record, then one of two actions will happen by default. Either ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* the user will be directed to the log-in screen, or the user will be automatically logged in. Which of these two occurs");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* is dependent on a module variable setting in the Users module. During the login process, one or more additional events may");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* fire.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* If a `\'redirecturl\'` is specified by any entity intercepting and processing the `module.users.ui.registration.succeeded` event, then");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* how that redirect URL is handled depends on whether the registration process produced a registration request or a full user");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* account record, and if a full user account record was produced then it depends on whether automatic log-in is enabled or ");
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
    _builder.append("* all event handlers are being notified of this event. This is not a `notify()` event. An event handler that was notified ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* prior to the current handler may already have changed the `\'redirecturl\'`.");
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
    _builder.append("public static function succeeded(");
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
        _builder.append("parent::succeeded($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
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
    _builder.append("* Initially, it will be an empty string, indicating that the user will be redirected to a page");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* that displays status and error information.");
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
    _builder.append("* Being redirected to a different page might be disorienting to the user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Second, all event handlers are being notified of this event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This is not a `notify()` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* An event handler that was notified prior to the current handler may already have changed the `\'redirecturl\'`.");
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
    _builder.append("public static function failed(");
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
        _builder.append("parent::failed($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
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
    _builder.append("* The subject of the event is set to the registration record that was created.");
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
    _builder.append("public static function create(");
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
        _builder.append("parent::create($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
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
    _builder.append("* The subject of the event is set to the registration record, with the updated values.");
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
    _builder.append("public static function update(");
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
        _builder.append("parent::update($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
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
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* @param ");
    {
      boolean _targets_10 = this._utils.targets(it, "1.3.5");
      if (_targets_10) {
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
    _builder.append("public static function delete(");
    {
      boolean _targets_11 = this._utils.targets(it, "1.3.5");
      if (_targets_11) {
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
        _builder.append("parent::delete($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
