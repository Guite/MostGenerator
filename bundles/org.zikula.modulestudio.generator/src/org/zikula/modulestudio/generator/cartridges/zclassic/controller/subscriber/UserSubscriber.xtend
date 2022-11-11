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
                    protected readonly EntityFactory $entityFactory,
                    protected readonly CurrentUserApiInterface $currentUserApi,
                    protected readonly LoggerInterface $logger«IF hasUserVariables || hasLoggable»,«ENDIF»
                «ENDIF»
                «IF hasUserVariables»
                    «FOR userVar : getAllVariables.filter(UserField)»
                        protected readonly int $«userVar.name.formatForCode»,
                    «ENDFOR»«IF hasLoggable»,«ENDIF»
                «ENDIF»
                «IF hasLoggable»
                    protected readonly LoggableHelper $loggableHelper
                «ENDIF»
            ) {
            }

        «ENDIF»
        public static function getSubscribedEvents(): array
        {
            return [
                ActiveUserPostCreatedEvent::class => ['create', 5],
                ActiveUserPostUpdatedEvent::class => ['update', 5],
                ActiveUserPostDeletedEvent::class => ['delete', 5],
            ];
        }

        /**
         * Subscriber for the `ActiveUserPostCreatedEvent`.
         *
         * Occurs after a user account is created. All handlers are notified.
         * It does not apply to creation of a pending registration.
         * The full user record created is available as the subject.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         * The subject of the event is set to the user record that was created.
         *
         * You can access the user and date in the event.
         *
         * The user:
         *     `echo 'UID: ' . $event->getUser()->getUid();`
         */
        public function create(ActiveUserPostCreatedEvent $event): void
        {
        }

        /**
         * Subscriber for the `ActiveUserPostUpdatedEvent`.
         *
         * Occurs after a user is updated. All handlers are notified.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         * The User property is the *new* data. The oldUser property is the *old* data.
         *
         * You can access the user and date in the event.
         *
         * The user:
         *     `echo 'UID: ' . $event->getUser()->getUid();`
         */
        public function update(ActiveUserPostUpdatedEvent $event): void
        {
            «IF hasLoggable»
                // update changed user name in log entries if needed
                $oldUser = $event->getOldUser();
                $user = $event->getUser();
                if ($user->getUsername() === $oldUser->getUsername()) {
                    return;
                }

                «FOR entity : loggableEntities»
                    $this->loggableHelper->updateUserName('«entity.name.formatForCode»', $oldUser->getUsername(), $user->getUsername());
                «ENDFOR»
            «ENDIF»
        }

        /**
         * Subscriber for the `ActiveUserPostDeletedEvent`.
         *
         * Occurs after the deletion of a user account.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         *
         * You can access the user and date in the event.
         *
         * The user:
         *     `echo 'UID: ' . $event->getUser()->getUid();`
         *
         * Check if user is really deleted or "ghosted":
         *     `if ($event->isFullDeletion())`
         */
        public function delete(ActiveUserPostDeletedEvent $event): void
        {
            «IF hasStandardFieldEntities || hasUserFields || hasUserVariables»
                if (!$event->isFullDeletion()) {
                    return;
                }

                $userId = $event->getUser()->getUid();
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
                        $this->currentUserApi
                    );
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» created by this user
                    $repo->deleteByCreator(
                        $userId,
                        $this->logger,
                        $this->currentUserApi
                    );
                «ENDIF»

                «IF onAccountDeletionLastEditor != AccountDeletionHandler.DELETE»
                    // set last editor to «onAccountDeletionLastEditor.adhAsConstant» («application.adhUid(onAccountDeletionLastEditor)») for all «nameMultiple.formatForDisplay» updated by this user
                    $repo->updateLastEditor(
                        $userId,
                        «application.adhUid(onAccountDeletionLastEditor)»,
                        $this->logger,
                        $this->currentUserApi
                    );
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» recently updated by this user
                    $repo->deleteByLastEditor(
                        $userId,
                        $this->logger,
                        $this->currentUserApi
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
                'user' => $this->currentUserApi->get('uname'),
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
                    $this->currentUserApi
                );
            «ELSE»
                // delete all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->deleteByUserField(
                    '«name.formatForCode»',
                    $userId,
                    $this->logger,
                    $this->currentUserApi
                );
            «ENDIF»
        «ELSEIF null !== varContainer»
            if ($userId === $this->«name.formatForCode») {
                $logArgs = [
                    'app' => '«application.appName»',
                    'user' => $this->currentUserApi->get('uname'),
                ];
                $this->logger->warning(
                    '{app}: User {user} has been deleted, hence the "«name.formatForCode»" configuration definition should be changed to another user ID.',
                    $logArgs
                );
            }
        «ENDIF»
    '''
}
