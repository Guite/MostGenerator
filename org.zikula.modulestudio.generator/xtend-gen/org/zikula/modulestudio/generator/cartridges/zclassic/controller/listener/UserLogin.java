package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener;

import com.google.inject.Inject;
import de.guite.modulestudio.metamodel.modulestudio.Application;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.Extension;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.zikula.modulestudio.generator.extensions.Utils;

@SuppressWarnings("all")
public class UserLogin {
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
    _builder.append("* will not fire when the system passes control from the registration process to the log-in process. ");
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
    _builder.append("* This event uses `notify()`, so handlers are called until either one vetoes the login attempt,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* or there are no more handlers for the event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* A handler that needs to veto a login attempt should call `stop");
    {
      boolean _targets_2 = this._utils.targets(it, "1.3.5");
      boolean _not_1 = (!_targets_2);
      if (_not_1) {
        _builder.append("Propagation");
      }
    }
    _builder.append("()`. This will prevent other handlers");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* from receiving the event, will return to the login process, and will prevent the login from taking place.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* A handler that vetoes a login attempt should set an appropriate error message and give any additional");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* feedback to the user attempting to log in that might be appropriate. If a handler does not");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* need to veto the login attempt, then it should simply return null (`return;` with no return value).");
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
    _builder.append("* The subject of the event will contain the user\'s account record, equivalent to `UserUtil::getVars($uid)`.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The arguments of the event are:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'authentication_method\'` will contain the name of the module and the name of the method that was used to authenticated the user.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'uid\'` will contain the user\'s uid.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* An event handler can prevent (veto) the log-in attempt by calling `stop");
    {
      boolean _targets_3 = this._utils.targets(it, "1.3.5");
      boolean _not_2 = (!_targets_3);
      if (_not_2) {
        _builder.append("Propagation");
      }
    }
    _builder.append("()` on the event. This is ");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("* enough to ensure that the log-in attempt is stopped, however this will result in a `Zikula_Exception_Forbidden`");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* exception being thrown. ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* To, instead, redirect the user back to the log-in screen (after possibly setting an error message that will");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* be displayed), then set the event data to contain an array with a single element, `retry`, having a value");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* of true (e.g., `$event->setData(array(\'retry\' => true));`).  This will signal the log-in process to go back ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* to the log-in screen for another attempt. The expectation is that the notifying event handler has set an ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* error message, and that the user will be able to log-in if the instructions in that message are followed, ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* or the conditions in that message can be met. ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The Legal module uses this method when vetoing an attempt, if the Legal module has established a hook with the");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* log-in screen. The user is redirected back to the log-in screen and now that the user is known, the");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Legal module is able to display a form fragment directly on the log-in screen which allows the user");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* to accept the policies that remain unaccepted. Assuming that the user accepts the policies, his ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* next attempt at logging in will be successful because the condition in the Legal module that caused the");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* veto no longer exists.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Another alternative is to \"break into\" the log-in process to redirect the user to a form (or something ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* similar) that allows him to correct whatever situation is causing his log-in attempt to be vetoed. The");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* expectation is that the notifying event handler will direct the user to a form to correct the situation,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* and then __redirect the user back into the log-in process to re-attempt logging in__. To accomplish this,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* instead of setting the `\'retry\'` event data, the notifying handler should set the `\'redirect_func\'` ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* event data structure. This is an array which defines the information necessary to direct the ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* user to a controller function somewhere in the Zikula system (likely, within the same module as that");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* which is vetoing the attempt). This array contains the following:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'modname\'` The name of the module where the controller function is defined.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'type\'` The library type that defines the function.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'func\'` The name of the function itself.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'args\'` An array of function argument key-value pairs to pass to the function when calling it. Since the function");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*              will be called through a redirect, any parameters will be converted to GET parameters on the URL, so");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*              the developer should consider the minimum set to include--preferably none. Session variables are an");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*              alternative to passing function arguments.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* In addition, if information from the log-in attempt is needed within the function, it can be made available in ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* session variables. To do this, add an array called `\'session\'` to the `\'redirect_func\'` array structure. The contents");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* of the `\'session\'` array must be:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'namespace\'` The session name space in which to store the variable.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'var\'` The name of the session variable.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* An array will be stored in that variable, containing information from the log-in process. The elements of this array will");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* be:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'returnurl\'` The URL where the user should be redirected upon successfully logging in.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'authentication_info\'` An array containing the authentication information entered by the user. The contents");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*                             of this array depends entirely on the authentication method.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'authentication_method\'` An array containing the `\'modname\'` (module name) of the authentication module, and");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*                               the `\'method\'` name of the authentication method being used by the user who is logging in.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'rememberme\'` A flag indicating whether the user checked the box to remain logged in.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'user_obj\'` The user object array (same as received when calling `UserUtil::getVars($uid);`) of the user who is");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*                  logging in.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* This information is also passed back to the log-in process when the user is redirected back there.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The Users module uses this method to handle users who have been forced by the administrator to change their password ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* prior to logging in. The code used for the notification might look like the following example:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     $event->stop");
    {
      boolean _targets_4 = this._utils.targets(it, "1.3.5");
      boolean _not_3 = (!_targets_4);
      if (_not_3) {
        _builder.append("Propagation");
      }
    }
    _builder.append("();");
    _builder.newLineIfNotEmpty();
    _builder.append(" ");
    _builder.append("*     $event->setData(array(");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*         \'redirect_func\'  => array(");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*             \'modname\'   => \'Users\',");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*             \'type\'      => \'user\',");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*             \'func\'      => \'changePassword\',");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*             \'args\'      => array(");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*                 \'login\'     => true,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*             ),");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*             \'session\'   => array(");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*                 \'var\'       => \'Users_Controller_User_changePassword\',");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*                 \'namespace\' => \'Zikula_Users\',");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*             )");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*         ),");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     ));");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     LogUtil::registerError(__(\"Your log-in request was not completed. You must change your web site account\'s password first.\"));");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* In this example, the user will be redirected to the URL pointing to the `changePassword` function. This URL is constructed by calling ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* `ModUtil::url()` with the modname, type, func, and args specified in the above array. The `changePassword` function also needs access");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* to the information from the log-in attempt, which will be stored in the session variable and namespace specified. This is accomplished");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* by calling `SessionUtil::setVar()` prior to the redirect, as follows:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     SessionUtil::setVar(\'Users_Controller_User_changePassword\', $sessionVars, \'Zikula_Users\' true, true);");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* where `$sessionVars` contains the information discussed previously.");
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
    _builder.append("public static function veto(");
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
        _builder.append("parent::veto($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    _builder.newLine();
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
    _builder.append("* All handlers are notified.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event subject contains the user\'s user record.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The arguments of the event are as follows:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*     `\'authentication_module\'` an array containing the authenticating module name (`\'modname\'`) and method (`\'method\'`) ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*       used to log the user in.");
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
    _builder.append("* __The `\'redirecturl\'` argument__ controls where the user will be directed at the end of the log-in process.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initially, it will be the value of the returnurl parameter provided to the log-in process, or blank if none was provided.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The action following login depends on whether WCAG compliant log-in is enabled in the Users module or not. If it is enabled,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* then the user is redirected to the returnurl immediately. If not, then the user is first displayed a log-in landing page,");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* and then meta refresh is used to redirect the user to the returnurl.");
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
    _builder.append("* Second, all event handlers are being notified of this event. This is not a `notify()` event. An event handler");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* that was notified prior to the current handler may already have changed the `\'redirecturl\'`.");
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
    _builder.append("public static function succeeded(");
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
    _builder.append("* Listener for the `module.users.ui.login.failed` event.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Occurs right after an unsuccessful attempt to log in. All handlers are notified.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The event subject contains the user\'s user record if it has been found, otherwise null.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* The arguments of the event are as follows:");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* `\'authentication_module\'` an array containing the authenticating module name (`\'modname\'`) and method (`\'method\'`) ");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*   used to log the user in.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* `\'authentication_info\'` an array containing the authentication information entered by the user (contents will vary by method).");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* `\'redirecturl\'` will initially contain an empty string. This can be modified to change where the user is redirected following the failed login.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* __The `\'redirecturl\'` argument__ controls where the user will be directed following a failed log-in attempt.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Initially, it will be an empty string, indicating that the user should continue with the log-in process and be presented");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* with the log-in form.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* If a `\'redirecturl\'` is specified by any entity intercepting and processing the `module.users.ui.login.failed` event, then");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* the user will be redirected to the URL provided, instead of being presented with the log-in form.");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("*");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* Finally, this event only fires in the event of a \"normal\" UI-oriented log-in attempt. A module attempting to log in");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* programmatically by directly calling `UserUtil::loginUsing()` will not see this event fired. Instead, the");
    _builder.newLine();
    _builder.append(" ");
    _builder.append("* `");
    {
      boolean _targets_9 = this._utils.targets(it, "1.3.5");
      if (_targets_9) {
        _builder.append("Users_Controller_User");
      } else {
        _builder.append("Users\\Controller\\UserController");
      }
    }
    _builder.append("#login()` function can be called with the appropriate parameters, if the event is desired.");
    _builder.newLineIfNotEmpty();
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
    _builder.append("public static function failed(");
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
      boolean _not_6 = (!(isBase).booleanValue());
      if (_not_6) {
        _builder.append("    ");
        _builder.append("parent::failed($event);");
        _builder.newLine();
      }
    }
    _builder.append("}");
    _builder.newLine();
    return _builder;
  }
}
