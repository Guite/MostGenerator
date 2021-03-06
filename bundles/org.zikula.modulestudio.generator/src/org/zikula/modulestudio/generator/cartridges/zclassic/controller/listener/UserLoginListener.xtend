package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.Utils

class UserLoginListener {

    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it) '''
        public static function getSubscribedEvents()
        {
            return [
                «IF targets('3.0')»
                    UserPreLoginSuccessEvent::class => ['veto', 5],
                    UserPostLoginSuccessEvent::class => ['succeeded', 5],
                    UserPostLoginFailureEvent::class => ['failed', 5],
                «ELSE»
                    AccessEvents::LOGIN_STARTED => ['started', 5],
                    AccessEvents::LOGIN_VETO => ['veto', 5],
                    AccessEvents::LOGIN_SUCCESS => ['succeeded', 5],
                    AccessEvents::LOGIN_FAILED => ['failed', 5],
                «ENDIF»
            ];
        }
        «IF !targets('3.0')»

            /**
             * Listener for the `module.users.ui.login.started` event.
             *
             * Occurs at the beginning of the log-in process, before the registration form is displayed to the user.
             *
             * NOTE: This event will not fire if the log-in process is entered through any other method
             * other than visiting the log-in screen directly.
             * For example, if automatic log-in is enabled following registration, then this event
             * will not fire when the system passes control from the registration process to the log-in process.
             *
             * Likewise, this event will not fire if a user begins the log-in process from the log-in block or a log-in
             * plugin if the user provides valid authentication information.
             * This event will fire, however, if invalid information is provided to the log-in block or log-in plugin,
             * resulting in the user being redirected to the full log-in screen for corrections.
             *
             * This event does not have any subject, arguments, or data.
             *
             «commonExample.generalEventProperties(it, false)»
             */
            public function started(GenericEvent $event)«IF targets('3.0')»: void«ENDIF»
            {
            }
        «ENDIF»

        /**
         * Listener for the «IF targets('3.0')»`UserPreLoginSuccessEvent`«ELSE»`module.users.ui.login.veto` event«ENDIF».
         *
         «IF targets('3.0')»
         * Occurs immediately prior to a log-in that is expected to succeed. (All prerequisites for a
         * successful login have been checked and are satisfied.) This event allows an extension to
         * intercept the login process and prevent a successful login from taking place.
         «ELSE»
         * Occurs immediately prior to a log-in that is expected to succeed.
         * (All prerequisites for a successful login have been checked and are satisfied.)
         * This event allows a module to intercept the login process and prevent a successful login from taking place.
         «ENDIF»
         *
         «IF targets('3.0')»
         * A handler that needs to veto a login attempt should call `stopPropagation()`.
         * This will prevent other handlers from receiving the event, will
         * return to the login process, and will prevent the login from taking place. A handler that
         * vetoes a login attempt should set an appropriate session flash message and give any additional
         «ELSE»
         * A handler that needs to veto a login attempt should call `stopPropagation()`. This will prevent other handlers
         * from receiving the event, will return to the login process, and will prevent the login from taking place.
         * A handler that vetoes a login attempt should set an appropriate error message and give any additional
         «ENDIF»
         * feedback to the user attempting to log in that might be appropriate.
         *
         «IF targets('3.0')»
         * If vetoing the login, the 'returnUrl' property should be set to redirect the user to an appropriate action.
         * Also, a 'flash' property may be set to provide information to the user for the veto.
         «ELSE»
         * If vetoing the login, the 'returnUrl' argument should be set to redirect the user to an appropriate action.
         «ENDIF»
         *
         «IF targets('3.0')»
         * Note: the user __will not__ be logged in at the point where the event handler is
         * executing. Any attempt to check a user's permissions, his logged-in status, or any
         * operation will return a value equivalent to what an anonymous (guest) user would see. Care
         * should be taken to ensure that sensitive operations done within a handler for this event
         «ELSE»
         * Note: the user __will not__ be logged in when the event handler is executing.
         * Any attempt to check a user's permissions, his logged-in status, or any operation will
         * return a value equivalent to what an anonymous (guest) user would see.
         * Care should be taken to ensure that sensitive operations done within a handler for this event
         «ENDIF»
         * do not introduce breaches of security.
         «IF !targets('3.0')»
         *
         * The subject of the event will contain the UserEntity.
         * The arguments of the event are:
         *     `'authentication_method'` will contain the name of the module
         *     and the name of the method that was used to authenticated the user.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function veto(«IF targets('3.0')»UserPreLoginSuccessEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the «IF targets('3.0')»`UserPostLoginSuccessEvent`«ELSE»`module.users.ui.login.succeeded` event«ENDIF».
         *
         * Occurs right after a successful attempt to log in, and just prior to redirecting the user to the desired page.
         *
         «IF targets('3.0')»
         * If a `'returnUrl'` is specified by any entity intercepting and processing the event, then
         * the URL provided replaces the one provided by the returnUrl parameter to the login process. If it is set to an empty
         * string, then the user is redirected to the site's home page. An event handler should carefully consider whether
         * changing the `'returnUrl'` argument is appropriate. First, the user may be expecting to return to the page where
         * he was when he initiated the log-in process. Being redirected to a different page might be disorienting to the user.
         * Second, an event handler that was notified prior to the current handler may already have changed the `'returnUrl'`.
         *
         * Finally, this event only fires in the event of a "normal" UI-oriented log-in attempt. A module attempting to log in
         * programmatically by directly calling the login function will not see this event fired.
         «ELSE»
         * The event subject contains the UserEntity.
         * The arguments of the event are as follows:
         *     `'authentication_module'` will contain the alias (name) of the method that was used to authenticate the user.
         *     `'returnUrl'` will contain the value of the 'returnurl' parameter, if one was supplied, or an empty
         *       string. This can be modified to change where the user is redirected following the login.
         *
         * If a `'returnUrl'` is specified by any entity intercepting and processing the `module.users.ui.login.succeeded`
         * event, then the URL provided replaces the one provided by the returnurl parameter to the login process. If it is
         * set to an empty string, then the user is redirected to the site's home page.
         *
         * An event handler should carefully consider whether changing the `'returnUrl'` argument is appropriate. First, the
         * user may be expecting to return to the page where he was when he initiated the log-in process. Being redirected
         * to a different page might be disorienting to the user. Second, an event handler that was notified prior to the
         * current handler may already have changed the `'returnUrl'`.
         *
         * Finally, this event only fires in the event of a "normal" UI-oriented log-in attempt. A module attempting
         * to log in programmatically by directly calling the core functions will not see this event fired.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function succeeded(«IF targets('3.0')»UserPostLoginSuccessEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }

        /**
         * Listener for the «IF targets('3.0')»`UserPostLoginFailureEvent`«ELSE»`module.users.ui.login.failed` event«ENDIF».
         *
         * Occurs right after an unsuccessful attempt to log in.
         *
         «IF targets('3.0')»
         * The event contains the userEntity if it has been found, otherwise null.
         *
         * If a `'returnUrl'` is specified by any entity intercepting and processing this event, then
         * the user will be redirected to the URL provided.  An event handler
         * should carefully consider whether changing the `'returnUrl'` argument is appropriate. First, the user may be expecting
         * to return to the log-in screen . Being redirected to a different page might be disorienting to the user.
         * Second, an event handler that was notified prior to the current handler may already have changed the `'returnUrl'`.
         *
         * Finally, this event only fires in the event of a "normal" UI-oriented log-in attempt. A module attempting to log in
         * programmatically by directly calling core functions will not see this event fired.
         «ELSE»
         * The event subject contains the UserEntity if it has been found, otherwise null.
         * The arguments of the event are as follows:
         *     `'authenticationMethod'` will contain an instance of the authenticationMethod used
         *     that produced the failed login.
         *     `'returnUrl'` will initially contain an empty string. This can be modified to change
         *     where the user is redirected following the failed login.
         *
         * If a `'returnUrl'` is specified by any entity intercepting and processing the `module.users.ui.login
         * .failed` event, then the user will be redirected to the URL provided.
         *
         * An event handler should carefully consider whether changing the `'returnUrl'` argument is appropriate.
         * First, the user may be expecting to return to the log-in screen. Being redirected to a different page
         * might be disorienting to the user. Second, an event handler that was notified prior to the current handler
         * may already have changed the `'returnUrl'`.
         *
         * Finally, this event only fires in the event of a "normal" UI-oriented log-in attempt. A module attempting
         * to log in programmatically by directly calling core functions will not see this event fired.
         *
         «commonExample.generalEventProperties(it, false)»
         «ENDIF»
         */
        public function failed(«IF targets('3.0')»UserPostLoginFailureEvent«ELSE»GenericEvent«ENDIF» $event)«IF targets('3.0')»: void«ENDIF»
        {
        }
    '''
}
