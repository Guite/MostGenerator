package org.zikula.modulestudio.generator.cartridges.symfony.controller.subscriber

import de.guite.modulestudio.metamodel.Application

class UserRegistrationSubscriber {

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
        {
            return [
                NucleosProfileEvents::REGISTRATION_INITIALIZE => 'onRegistrationInitialized',
                NucleosProfileEvents::REGISTRATION_SUCCESS => 'onRegistrationSuccess',
                NucleosProfileEvents::REGISTRATION_FAILURE => 'onRegistrationFailure',
                NucleosProfileEvents::REGISTRATION_COMPLETED => 'onRegistrationCompleted',
                NucleosProfileEvents::REGISTRATION_CONFIRM => 'onRegistrationConfirm',
                NucleosProfileEvents::REGISTRATION_CONFIRMED => 'onRegistrationConfirmed',
            ];
        }

        /**
         * Subscriber for the `nucleos_profile.registration.initialize` event.
         *
         * Occurs when the registration process is initialized.
         *
         * This event allows you to modify the default values of the user before binding the form.
         */
        public function onRegistrationInitialized(GetResponseRegistrationEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_profile.registration.success` event.
         *
         * Occurs when the registration form is submitted successfully.
         *
         * This event allows you to set the response instead of using the default one.
         */
        public function onRegistrationSuccess(UserFormEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_profile.registration.failure` event.
         *
         * Occurs when the registration form is not valid.
         *
         * This event allows you to set the response instead of using the default one.
         */
        public function onRegistrationFailure(FormEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_profile.registration.completed` event.
         *
         * Occurs after saving the user in the registration process.
         *
         * This event allows you to access the response which will be sent.
         */
        public function onRegistrationCompleted(FilterUserResponseEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_profile.registration.confirm` event.
         *
         * Occurs just before confirming the account.
         *
         * This event allows you to access the user which will be confirmed.
         */
        public function onRegistrationConfirm(GetResponseUserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_profile.registration.confirmed` event.
         *
         * Occurs after confirming the account.
         *
         * This event allows you to access the response which will be sent.
         */
        public function onRegistrationConfirmed(FilterUserResponseEvent $event): void
        {
        }
    '''
}
