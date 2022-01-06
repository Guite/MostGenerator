package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.AccountDeletionHandler
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class UserListener {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        «IF hasStandardFieldEntities || hasUserFields»
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var CurrentUserApiInterface
             */
            protected $currentUserApi;

            /**
             * @var LoggerInterface
             */
            protected $logger;

        «ENDIF»
        «IF hasUserVariables»
            /**
             * @var VariableApiInterface
             */
            protected $variableApi;

        «ENDIF»
        «IF hasStandardFieldEntities || hasUserFields || hasUserVariables»
            public function __construct(
                «IF hasStandardFieldEntities || hasUserFields»
                    TranslatorInterface $translator,
                    EntityFactory $entityFactory,
                    CurrentUserApiInterface $currentUserApi,
                    LoggerInterface $logger«IF hasUserVariables»,«ENDIF»
                «ENDIF»
                «IF hasUserVariables»
                    VariableApiInterface $variableApi
                «ENDIF»
            ) {
                «IF hasStandardFieldEntities || hasUserFields»
                    $this->translator = $translator;
                    $this->entityFactory = $entityFactory;
                    $this->currentUserApi = $currentUserApi;
                    $this->logger = $logger;
                «ENDIF»
                «IF hasUserVariables»
                    $this->variableApi = $variableApi;
                «ENDIF»
            }

        «ENDIF»
        public static function getSubscribedEvents()
        {
            return [
                ActiveUserPostCreatedEvent::class => ['create', 5],
                ActiveUserPostUpdatedEvent::class => ['update', 5],
                ActiveUserPostDeletedEvent::class => ['delete', 5],
            ];
        }

        /**
         * Listener for the `ActiveUserPostCreatedEvent`.
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
         * Listener for the `ActiveUserPostUpdatedEvent`.
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
        }

        /**
         * Listener for the `ActiveUserPostDeletedEvent`.
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
                        $this->translator,
                        $this->logger,
                        $this->currentUserApi
                    );
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» created by this user
                    $repo->deleteByCreator(
                        $userId,
                        $this->translator,
                        $this->logger,
                        $this->currentUserApi
                    );
                «ENDIF»

                «IF onAccountDeletionLastEditor != AccountDeletionHandler.DELETE»
                    // set last editor to «onAccountDeletionLastEditor.adhAsConstant» («application.adhUid(onAccountDeletionLastEditor)») for all «nameMultiple.formatForDisplay» updated by this user
                    $repo->updateLastEditor(
                        $userId,
                        «application.adhUid(onAccountDeletionLastEditor)»,
                        $this->translator,
                        $this->logger,
                        $this->currentUserApi
                    );
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» recently updated by this user
                    $repo->deleteByLastEditor(
                        $userId,
                        $this->translator,
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
                    $this->translator,
                    $this->logger,
                    $this->currentUserApi
                );
            «ELSE»
                // delete all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->deleteByUserField(
                    '«name.formatForCode»',
                    $userId,
                    $this->translator,
                    $this->logger,
                    $this->currentUserApi
                );
            «ENDIF»
        «ELSEIF null !== varContainer»
            // set «name.formatForDisplay» variable to «IF onAccountDeletion != AccountDeletionHandler.DELETE»«onAccountDeletion.adhAsConstant» («application.adhUid(onAccountDeletion)»)«ELSE»admin (UsersConstant::USER_ID_ADMIN)«ENDIF» if it is affected
            «IF varContainer.composite»
                $«varContainer.name.formatForCode» = $this->variableApi->get('«application.appName»', '«varContainer.name.formatForCode»');
                if (isset($«varContainer.name.formatForCode»['«name.formatForCode»']) && $userId === $«varContainer.name.formatForCode»['«name.formatForCode»']) {
                    $«varContainer.name.formatForCode»['«name.formatForCode»'] = «IF onAccountDeletion != AccountDeletionHandler.DELETE»«application.adhUid(onAccountDeletion)»«ELSE»UsersConstant::USER_ID_ADMIN«ENDIF»;
                    $this->variableApi->set('«application.appName»', '«varContainer.name.formatForCode»', $«varContainer.name.formatForCode»);
                }
            «ELSE»
                if ($userId === $this->variableApi->get('«application.appName»', '«name.formatForCode»')) {
                    $this->variableApi->set('«application.appName»', '«name.formatForCode»', «IF onAccountDeletion != AccountDeletionHandler.DELETE»«application.adhUid(onAccountDeletion)»«ELSE»UsersConstant::USER_ID_ADMIN«ENDIF»);
                }
            «ENDIF»
        «ENDIF»
    '''
}
