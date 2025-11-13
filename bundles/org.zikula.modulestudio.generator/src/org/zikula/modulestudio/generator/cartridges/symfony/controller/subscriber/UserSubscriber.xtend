package org.zikula.modulestudio.generator.cartridges.symfony.controller.subscriber

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserSubscriber {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        «IF hasUserFields»
            public function __construct(
                protected readonly Security $security,
                protected readonly EntityFactory $entityFactory,
                protected readonly LoggerInterface $logger
            ) {
            }

        «ENDIF»
        public static function getSubscribedEvents(): array
        {
            return [
                NucleosUserEvents::USER_CREATED => 'onUserCreated',
                NucleosUserEvents::USER_ACTIVATED => 'onUserActivated',
                NucleosUserEvents::USER_DEACTIVATED => 'onUserDeactivated',
                NucleosUserEvents::USER_PROMOTED => 'onUserPromoted',
                NucleosUserEvents::USER_DEMOTED => 'onUserDemoted',
                NucleosUserEvents::USER_LOCALE_CHANGED => 'onLocaleChanged',
                NucleosUserEvents::USER_TIMEZONE_CHANGED => 'onTimezoneChanged',
                NucleosUserEvents::ACCOUNT_DELETION_INITIALIZE => 'onAccountDeletionInitialized',
                NucleosUserEvents::ACCOUNT_DELETION => 'onAccountDeletion',
                NucleosUserEvents::ACCOUNT_DELETION_SUCCESS => 'onAccountDeletionSuccess',
            ];
        }

        /**
         * Subscriber for the `nucleos_user.user.created` event.
         *
         * Occurs when the user is created with UserManipulator.
         *
         * This event allows you to access the created user and to add some behaviour after the creation.
         */
        public function onUserCreated(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.user.activated` event.
         *
         * Occurs when the user is activated with UserManipulator.
         *
         * This event allows you to access the activated user and to add some behaviour after the activation.
         */
        public function onUserActivated(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.user.deactivated` event.
         *
         * Occurs when the user is deactivated with UserManipulator.
         *
         * This event allows you to access the deactivated user and to add some behaviour after the deactivation.
         */
        public function onUserDeactivated(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.user.promoted` event.
         *
         * Occurs when the user is promoted with UserManipulator.
         *
         * This event allows you to access the promoted user and to add some behaviour after the promotion.
         */
        public function onUserPromoted(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.user.demoted` event.
         *
         * Occurs when the user is demoted with UserManipulator.
         *
         * This event allows you to access the demoted user and to add some behaviour after the demotion.
         */
        public function onUserDemoted(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.user.locale_changed` event.
         *
         * Occurs when the user changed the locale.
         *
         * This event allows you to access the user settings and to add some behaviour after the locale change.
         */
        public function onLocaleChanged(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.user.timezone_changed` event.
         *
         * Occurs when the user changed the timezone.
         *
         * This event allows you to access the user settings and to add some behaviour after the timezone change.
         */
        public function onTimezoneChanged(UserEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.account_deletion.initialize` event.
         *
         * Occurs when the account deletion is initialized.
         *
         * This event allows you to modify the default values of the deletion request before binding the form.
         */
        public function onAccountDeletionInitialized(GetResponseAccountDeletionEvent $event): void
        {
        }

        /**
         * Subscriber for the `nucleos_user.account_deletion` event.
         *
         * Occurs when the account deletion is processed.
         *
         * This event allows you to process the user deletion request.
         */
        public function onAccountDeletion(AccountDeletionEvent $event): void
        {
            «IF hasUserFields»
                $currentUser = $this->security->getUser();
                $userId = $event->getUser()->getId();
                «FOR entity : entities»«entity.userDelete»«ENDFOR»
            «ENDIF»
        }

        /**
         * Subscriber for the `nucleos_user.account_deletion.success` event.
         *
         * Occurs when the account was deleted successfully.
         *
         * This event allows you to set the response instead of using the default one.
         */
        public function onAccountDeletionSuccess(AccountDeletionResponseEvent $event): void
        {
        }
    '''

    def private userDelete(Entity it) '''
        «IF hasUserFieldsEntity»

            $repo = $this->entityFactory->getRepository('«name.formatForCode»');
            «FOR userField : getUserFieldsEntity»
                «userField.onAccountDeletionHandler»
            «ENDFOR»

            $logArgs = [
                'app' => '«application.appName»',
                'user' => $currentUser,
                'entities' => '«nameMultiple.formatForDisplay»',
            ];
            $this->logger->notice(
                '{app}: User {user} has been deleted, so we deleted/updated corresponding {entities}, too.',
                $logArgs
            );
        «ENDIF»
    '''

    def private onAccountDeletionHandler(UserField it) '''
        // set «name.formatForDisplay» to «adhAsConstant» («adhUid») for all «entity.nameMultiple.formatForDisplay» affected by this user
        $repo->updateUserField('«name.formatForCode»', $userId, «adhUid», $this->logger, $currentUser);
        // you can also delete all «entity.nameMultiple.formatForDisplay» affected by this user
        // $repo->deleteByUserField('«name.formatForCode»', $userId, $this->logger, $currentUser);
    '''

    /**
     * Prints an output string corresponding to the given account deletion handler type.
     */
    def adhAsConstant(UserField it) {
        if (#['createdBy', 'updatedBy'].contains(name)) {
            return 'admin'
        }
        'guest'
    }

    /**
     * Returns the user identifier fitting to a certain account deletion handler type.
     */
    def adhUid(UserField it) {
        if (#['createdBy', 'updatedBy'].contains(name)) {
            return 'UsersConstant::USER_ID_ADMIN'
        }
        'UsersConstant::USER_ID_ANONYMOUS'
    }
}
