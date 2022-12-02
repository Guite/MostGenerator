package org.zikula.modulestudio.generator.cartridges.zclassic.controller.subscriber

import de.guite.modulestudio.metamodel.AccountDeletionHandler
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserSubscriber {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        «IF hasStandardFieldEntities || hasUserFields || hasUserVariables»
            public function __construct(
                «IF hasStandardFieldEntities || hasUserFields»
                    protected readonly Security $security,
                    protected readonly EntityFactory $entityFactory,
                    protected readonly LoggerInterface $logger«IF hasUserVariables»,«ENDIF»
                «ENDIF»
                «IF hasUserVariables»
                    «FOR userVar : getAllVariables.filter(UserField)»
                        protected readonly int $«userVar.name.formatForCode»,
                    «ENDFOR»
                «ENDIF»
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
            «IF hasStandardFieldEntities || hasUserFields || hasUserVariables»
                $currentUser = $this->security->getUser();
                $userId = $event->getUser()->getId();
                «IF hasStandardFieldEntities || hasUserFields»
                    «FOR entity : getAllEntities»«entity.userDelete»«ENDFOR»
                «ENDIF»
                «IF hasUserVariables»

                    «FOR userField : getAllVariables.filter(UserField)»
                        «userField.onAccountDeletionHandler»
                    «ENDFOR»
                «ENDIF»
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
        «IF standardFields || hasUserFieldsEntity»

            $repo = $this->entityFactory->getRepository('«name.formatForCode»');
            «IF standardFields»
                «IF onAccountDeletionCreator != AccountDeletionHandler.DELETE»
                    // set creator to «onAccountDeletionCreator.adhAsConstant» («application.adhUid(onAccountDeletionCreator)») for all «nameMultiple.formatForDisplay» created by this user
                    $repo->updateCreator(
                        $userId,
                        «application.adhUid(onAccountDeletionCreator)»,
                        $this->logger,
                        $currentUser
                    );
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» created by this user
                    $repo->deleteByCreator(
                        $userId,
                        $this->logger,
                        $currentUser
                    );
                «ENDIF»

                «IF onAccountDeletionLastEditor != AccountDeletionHandler.DELETE»
                    // set last editor to «onAccountDeletionLastEditor.adhAsConstant» («application.adhUid(onAccountDeletionLastEditor)») for all «nameMultiple.formatForDisplay» updated by this user
                    $repo->updateLastEditor(
                        $userId,
                        «application.adhUid(onAccountDeletionLastEditor)»,
                        $this->logger,
                        $currentUser
                    );
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» recently updated by this user
                    $repo->deleteByLastEditor(
                        $userId,
                        $this->logger,
                        $currentUser
                    );
                «ENDIF»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR userField : getUserFieldsEntity»
                    «userField.onAccountDeletionHandler»
                «ENDFOR»
            «ENDIF»

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
        «IF null !== entity && entity instanceof Entity»
            «IF onAccountDeletion != AccountDeletionHandler.DELETE»
                // set «name.formatForDisplay» to «onAccountDeletion.adhAsConstant» («application.adhUid(onAccountDeletion)») for all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->updateUserField(
                    '«name.formatForCode»',
                    $userId,
                    «application.adhUid(onAccountDeletion)»,
                    $this->logger,
                    $currentUser
                );
            «ELSE»
                // delete all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->deleteByUserField(
                    '«name.formatForCode»',
                    $userId,
                    $this->logger,
                    $currentUser
                );
            «ENDIF»
        «ELSEIF null !== varContainer»
            if ($userId === $this->«name.formatForCode») {
                $logArgs = [
                    'app' => '«application.appName»',
                    'user' => $currentUser,
                ];
                $this->logger->warning(
                    '{app}: User {user} has been deleted, hence the "«name.formatForCode»" configuration definition should be changed to another user ID.',
                    $logArgs
                );
            }
        «ENDIF»
    '''
}
