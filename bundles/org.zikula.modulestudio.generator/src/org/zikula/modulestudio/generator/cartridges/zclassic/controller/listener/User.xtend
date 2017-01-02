package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.AccountDeletionHandler
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class User {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    CommonExample commonExample = new CommonExample()

    def generate(Application it, Boolean isBase) '''
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
                    'user.gettheme'            => ['getTheme', 5],
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
         * Listener for the `user.gettheme` event.
         *
         * Called during UserUtil::getTheme() and is used to filter the results.
         * Receives arg['type'] with the type of result to be filtered
         * and the $themeName in the $event->data which can be modified.
         * Must $event->stopPropagation() if handler performs filter.
         *
         * @param GenericEvent $event The event instance
         */
        «ELSE»
            /**
             * {@inheritdoc}
             */
        «ENDIF»
        public function getTheme(GenericEvent $event)
        {
            «IF !isBase»
                parent::getTheme($event);

                «commonExample.generalEventProperties(it)»
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
         * Occurs after the deletion of a user account. Subject is $uid.
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
                    $uid = $event->getSubject();

                    $serviceManager = ServiceUtil::getManager();
                    $entityManager = $serviceManager->get('«entityManagerService»');
                    $translator = $serviceManager->get('translator.default');
                    $logger = $serviceManager->get('logger');
                    $currentUserApi = $serviceManager->get('zikula_users_module.current_user');
                    «FOR entity : getAllEntities»«entity.userDelete»«ENDFOR»
                «ENDIF»
            «ENDIF»
        }
    '''

    def private userDelete(Entity it) '''
        «IF standardFields || hasUserFieldsEntity»

            $repo = $entityManager->getRepository('«entityClassName('', false)»');
            «IF standardFields»
                «IF onAccountDeletionCreator != AccountDeletionHandler.DELETE»
                    // set creator to «onAccountDeletionCreator.adhAsConstant» («onAccountDeletionCreator.adhUid») for all «nameMultiple.formatForDisplay» created by this user
                    $repo->updateCreator($uid, «onAccountDeletionCreator.adhUid», $translator, $logger, $currentUserApi);
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» created by this user
                    $repo->deleteByCreator($uid, $translator, $logger, $currentUserApi);
                «ENDIF»

                «IF onAccountDeletionLastEditor != AccountDeletionHandler.DELETE»
                    // set last editor to «onAccountDeletionLastEditor.adhAsConstant» («onAccountDeletionLastEditor.adhUid») for all «nameMultiple.formatForDisplay» updated by this user
                    $repo->updateLastEditor($uid, «onAccountDeletionLastEditor.adhUid», $translator, $logger, $currentUserApi);
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» recently updated by this user
                    $repo->deleteByLastEditor($uid, $translator, $logger, $currentUserApi);
                «ENDIF»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR userField: getUserFieldsEntity»
                    «userField.onAccountDeletionHandler»
                «ENDFOR»
            «ENDIF»

            $logArgs = ['app' => '«application.appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entities' => '«nameMultiple.formatForDisplay»'];
            $logger->notice('{app}: User {user} has been deleted, so we deleted/updated corresponding {entities}, too.', $logArgs);
        «ENDIF»
    '''

    def private onAccountDeletionHandler(UserField it) '''
        «IF entity instanceof Entity»
            «IF onAccountDeletion != AccountDeletionHandler.DELETE»
                // set last editor to «onAccountDeletion.adhAsConstant» («onAccountDeletion.adhUid») for all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->updateUserField('«name.formatForCode»', $uid, «onAccountDeletion.adhUid», $translator, $logger, $currentUserApi);
            «ELSE»
                // delete all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->deleteByUserField('«name.formatForCode»', $uid, $translator, $logger, $currentUserApi);
            «ENDIF»
        «ENDIF»
    '''
}
