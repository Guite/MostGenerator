package org.zikula.modulestudio.generator.cartridges.symfony.controller.subscriber

import de.guite.modulestudio.metamodel.Application

class UserCredentialSubscriber {

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
        {
            return [
                NucleosUserEvents::USER_PASSWORD_CHANGED => 'onPasswordChanged',
                NucleosUserEvents::UPDATE_SECURITY_INITIALIZE => 'onSecurityUpdateInitialized',
                NucleosUserEvents::UPDATE_SECURITY_SUCCESS => 'onSecurityUpdateSuccess',
                NucleosUserEvents::UPDATE_SECURITY_COMPLETED => 'onSecurityUpdateCompleted',
                NucleosUserEvents::RESETTING_RESET_REQUEST => 'onPasswordResettingRequested',
                NucleosUserEvents::RESETTING_RESET_INITIALIZE => 'onPasswordResettingInitialized',
                NucleosUserEvents::RESETTING_RESET_SUCCESS => 'onPasswordResettingSuccess',
                NucleosUserEvents::RESETTING_RESET_COMPLETED => 'onPasswordResettingCompleted',
                NucleosUserEvents::RESETTING_SEND_EMAIL_INITIALIZE => 'onPasswordResettingMailInitialized',
                NucleosUserEvents::RESETTING_SEND_EMAIL_CONFIRM => 'onPasswordResettingMailConfirmed',
                NucleosUserEvents::RESETTING_SEND_EMAIL_COMPLETED => 'onPasswordResettingMailCompleted',
            ];
        }

        /**
         * Subscriber for the `nucleos_user.user.password_changed` event.
         *
         * Occurs after the password is changed with UserManipulator.
         */
        public function onPasswordChanged(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.update_security.edit.initialize` event.
         *
         * Occurs when the security update process is initialized.
         *
         * This event allows you to modify the default values of the user before binding the form.
         */
        public function onSecurityUpdateInitialized(GetResponseUserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.update_security.edit.success` event.
         *
         * Occurs when the security update form is submitted successfully.
         *
         * This event allows you to set the response instead of using the default one.
         */
        public function onSecurityUpdateSuccess(FormEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.update_security.edit.completed` event.
         *
         * Occurs after saving the user in the security update process.
         *
         * This event allows you to access the response which will be sent.
         */
        public function onSecurityUpdateCompleted(FilterUserResponseEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.resetting.reset.request` event.
         *
         * Occurs when a user requests a password reset of the account.
         *
         * This event allows you to check if a user is locked out before requesting a password.
         */
        public function onPasswordResettingRequested(GetResponseUserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.resetting.reset.initialize` event.
         *
         * Occurs when the resetting process is initialized.
         *
         * This event allows you to set the response to bypass the processing.
         */
        public function onPasswordResettingInitialized(GetResponseUserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.resetting.reset.success` event.
         *
         * Occurs when the resetting form is submitted successfully.
         *
         * This event allows you to set the response instead of using the default one.
         */
        public function onPasswordResettingSuccess(FormEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.resetting.reset.completed` event.
         *
         * Occurs after saving the user in the resetting process.
         *
         * This event allows you to access the response which will be sent.
         */
        public function onPasswordResettingCompleted(FilterUserResponseEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.resetting.send_email.initialize` event.
         *
         * Occurs when the send email process is initialized.
         *
         * This event allows you to set the response to bypass the email confirmation processing.
         */
        public function onPasswordResettingMailInitialized(GetResponseNullableUserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.resetting.send_email.confirm` event.
         *
         * Occurs when all prerequisites to send email are confirmed and before the mail is sent.
         *
         * This event allows you to set the response to bypass the email sending.
         */
        public function onPasswordResettingMailConfirmed(GetResponseUserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.resetting.reset.completed` event.
         *
         * Occurs after the email is sent.
         *
         * This event allows you to set the response to bypass the the redirection after the email is sent.
         */
        public function onPasswordResettingMailCompleted(GetResponseUserEvent $event): void
        {
        }
    '''
}
