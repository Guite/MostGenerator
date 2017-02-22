package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.AccountDeletionHandler
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class User {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
        «IF isBase && (hasStandardFieldEntities || hasUserFields)»
            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var «name.formatForCodeCapital»Factory
             */
            protected $entityFactory;

            /**
             * @var CurrentUserApi
             */
            protected $currentUserApi;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * UserListener constructor.
             *
             * @param TranslatorInterface $translator     Translator service instance
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
             * @param CurrentUserApi      $currentUserApi CurrentUserApi service instance
             * @param LoggerInterface     $logger         Logger service instance
             *
             * @return void
             */
            public function __construct(TranslatorInterface $translator, «name.formatForCodeCapital»Factory $entityFactory, CurrentUserApi $currentUserApi, LoggerInterface $logger)
            {
                $this->translator = $translator;
                $this->entityFactory = $entityFactory;
                $this->currentUserApi = $currentUserApi;
                $this->logger = $logger;
            }

        «ENDIF»
        «IF isBase»
            /**
             * Makes our handlers known to the event system.
             */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    UserEvents::CREATE_ACCOUNT => ['create', 5],
                    UserEvents::UPDATE_ACCOUNT => ['update', 5],
                    UserEvents::DELETE_ACCOUNT => ['delete', 5]
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `user.account.create` event.
         *
         * Occurs after a user account is created. All handlers are notified.
         * It does not apply to creation of a pending registration.
         * The full user record created is available as the subject.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         * The subject of the event is set to the user record that was created.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function create(GenericEvent $event)
        {
            «IF !isBase»
                parent::create($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `user.account.update` event.
         *
         * Occurs after a user is updated. All handlers are notified.
         * The full updated user record is available as the subject.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         * The subject of the event is set to the user record, with the updated values.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function update(GenericEvent $event)
        {
            «IF !isBase»
                parent::update($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        «IF isBase»
        /**
         * Listener for the `user.account.delete` event.
         *
         * Occurs after the deletion of a user account. Subject is $userId.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function delete(GenericEvent $event)
        {
            «IF !isBase»
                parent::delete($event);

                «commonExample.generalEventProperties(it)»
            «ELSE»
                «IF hasStandardFieldEntities || hasUserFields»
                    $userId = $event->getSubject();

                    «FOR entity : getAllEntities»«entity.userDelete»«ENDFOR»
                «ENDIF»
            «ENDIF»
        }
    '''

    def private userDelete(Entity it) '''
        «IF standardFields || hasUserFieldsEntity»

            $repo = $this->entityFactory->getRepository('«name.formatForCode»');
            «IF standardFields»
                «IF onAccountDeletionCreator != AccountDeletionHandler.DELETE»
                    // set creator to «onAccountDeletionCreator.adhAsConstant» («onAccountDeletionCreator.adhUid») for all «nameMultiple.formatForDisplay» created by this user
                    $repo->updateCreator($userId, «onAccountDeletionCreator.adhUid», $this->translator, $this->logger, $this->currentUserApi);
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» created by this user
                    $repo->deleteByCreator($userId, $this->translator, $this->logger, $this->currentUserApi);
                «ENDIF»

                «IF onAccountDeletionLastEditor != AccountDeletionHandler.DELETE»
                    // set last editor to «onAccountDeletionLastEditor.adhAsConstant» («onAccountDeletionLastEditor.adhUid») for all «nameMultiple.formatForDisplay» updated by this user
                    $repo->updateLastEditor($userId, «onAccountDeletionLastEditor.adhUid», $this->translator, $this->logger, $this->currentUserApi);
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» recently updated by this user
                    $repo->deleteByLastEditor($userId, $this->translator, $this->logger, $this->currentUserApi);
                «ENDIF»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR userField: getUserFieldsEntity»
                    «userField.onAccountDeletionHandler»
                «ENDFOR»
            «ENDIF»

            $logArgs = ['app' => '«application.appName»', 'user' => $this->currentUserApi->get('uname'), 'entities' => '«nameMultiple.formatForDisplay»'];
            $this->logger->notice('{app}: User {user} has been deleted, so we deleted/updated corresponding {entities}, too.', $logArgs);
        «ENDIF»
    '''

    def private onAccountDeletionHandler(UserField it) '''
        «IF entity instanceof Entity»
            «IF onAccountDeletion != AccountDeletionHandler.DELETE»
                // set last editor to «onAccountDeletion.adhAsConstant» («onAccountDeletion.adhUid») for all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->updateUserField('«name.formatForCode»', $userId, «onAccountDeletion.adhUid», $this->translator, $this->logger, $this->currentUserApi);
            «ELSE»
                // delete all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->deleteByUserField('«name.formatForCode»', $userId, $this->translator, $this->logger, $this->currentUserApi);
            «ENDIF»
        «ENDIF»
    '''
}
