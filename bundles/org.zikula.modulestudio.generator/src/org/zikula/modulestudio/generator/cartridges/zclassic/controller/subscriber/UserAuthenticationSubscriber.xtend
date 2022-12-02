package org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber

import de.guite.modulestudio.metamodel.Application

class UserAuthenticationSubscriber {

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
        {
            return [
                NucleosUserEvents::SECURITY_LOGIN_INITIALIZE => 'onLoginInitialized',
                NucleosUserEvents::SECURITY_LOGIN_COMPLETED => 'onLoginCompleted',
                NucleosUserEvents::SECURITY_IMPLICIT_LOGIN => 'onImplicitLogin',
                LogoutEvent::class => 'onLogout',
            ];
        }

        /**
         * Subscriber for the `nucleos_user.security.login.initialize` event.
         *
         * Occurs when the login process is initialized.
         *
         * This event allows you to set the response to bypass the login.
         */
        public function onLoginInitialized(GetResponseLoginEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.security.login.completed` event.
         *
         * Occurs after the user is logged in.
         *
         * This event allows you to set the response to bypass the the redirection after the user is logged in.
         */
        public function onLoginCompleted(GetResponseUserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.security.implicit_login` event.
         *
         * Occurs when the user is logged in programmatically.
         *
         * This event allows you to access the response which will be sent.
         */
        public function onImplicitLogin(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `LogoutEvent`.
         */
        public function onLogout(LogoutEvent $event): void
        {
        }
    '''
}
