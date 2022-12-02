package org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber

import de.guite.modulestudio.metamodel.Application

class UserProfileSubscriber {

    def generate(Application it) '''
        public static function getSubscribedEvents(): array
        {
            return [
                NucleosProfileEvents::PROFILE_EDIT_INITIALIZE => 'onProfileEditInitialized',
                NucleosProfileEvents::PROFILE_EDIT_SUCCESS => 'onProfileEditSuccess',
                NucleosProfileEvents::PROFILE_EDIT_COMPLETED => 'onProfileEditCompleted',
            ];
        }

        /**
         * Subscriber for the `nucleos_profile.profile.edit.initialize` event.
         *
         * Occurs when the profile editing process is initialized.
         *
         * This event allows you to modify the default values of the user before binding the form.
         */
        public function onProfileEditInitialized(GetResponseUserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_profile.profile.edit.success` event.
         *
         * Occurs when the profile edit form is submitted successfully.
         *
         * This event allows you to set the response instead of using the default one.
         */
        public function onProfileEditSuccess(UserFormEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_profile.profile.edit.completed` event.
         *
         * Occurs after saving the user in the profile edit process.
         *
         * This event allows you to access the response which will be sent.
         */
        public function onProfileEditCompleted(FilterUserResponseEvent $event): void
        {
        }
    '''
}
