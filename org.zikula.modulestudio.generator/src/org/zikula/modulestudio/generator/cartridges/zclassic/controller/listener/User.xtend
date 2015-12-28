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
        «IF !targets('1.3.x')»
            /**
             * Makes our handlers known to the event system.
             */
            public static function getSubscribedEvents()
            {
                «IF isBase»
                    return array(
                        'user.gettheme'       => array('getTheme', 5),
                        'user.account.create' => array('create', 5),
                        'user.account.update' => array('update', 5),
                        'user.account.delete' => array('delete', 5)
                    );
                «ELSE»
                    return parent::getSubscribedEvents();
                «ENDIF»
            }

        «ENDIF»
        /**
         * Listener for the `user.gettheme` event.
         *
         * Called during UserUtil::getTheme() and is used to filter the results.
         * Receives arg['type'] with the type of result to be filtered
         * and the $themeName in the $event->data which can be modified.
         * Must $event->stop«IF !targets('1.3.x')»Propagation«ENDIF»() if handler performs filter.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function getTheme(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::getTheme($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `user.account.create` event.
         *
         * Occurs after a user account is created. All handlers are notified.
         * It does not apply to creation of a pending registration.
         * The full user record created is available as the subject.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         * The subject of the event is set to the user record that was created.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function create(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::create($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `user.account.update` event.
         *
         * Occurs after a user is updated. All handlers are notified.
         * The full updated user record is available as the subject.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         * The subject of the event is set to the user record, with the updated values.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function update(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::update($event);

                «commonExample.generalEventProperties(it)»
            «ENDIF»
        }

        /**
         * Listener for the `user.account.delete` event.
         *
         * Occurs after a user is deleted from the system.
         * All handlers are notified.
         * The full user record deleted is available as the subject.
         * This is a storage-level event, not a UI event. It should not be used for UI-level actions such as redirects.
         * The subject of the event is set to the user record that is being deleted.
         *
         * @param «IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event The event instance.
         */
        public «IF targets('1.3.x')»static «ENDIF»function delete(«IF targets('1.3.x')»Zikula_Event«ELSE»GenericEvent«ENDIF» $event)
        {
            «IF !isBase»
                parent::delete($event);

                «commonExample.generalEventProperties(it)»
            «ELSE»
                «IF hasStandardFieldEntities || hasUserFields»
                    «IF targets('1.3.x')»
                        ModUtil::initOOModule('«appName»');

                    «ENDIF»
                    $userRecord = $event->getSubject();
                    $uid = $userRecord['uid'];
                    $serviceManager = ServiceUtil::getManager();
                    $entityManager = $serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('doctrine.entitymanager');
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
                    $repo->updateCreator($uid, «onAccountDeletionCreator.adhUid»);
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» created by this user
                    $repo->deleteByCreator($uid);
                «ENDIF»

                «IF onAccountDeletionLastEditor != AccountDeletionHandler.DELETE»
                    // set last editor to «onAccountDeletionLastEditor.adhAsConstant» («onAccountDeletionLastEditor.adhUid») for all «nameMultiple.formatForDisplay» updated by this user
                    $repo->updateLastEditor($uid, «onAccountDeletionLastEditor.adhUid»);
                «ELSE»
                    // delete all «nameMultiple.formatForDisplay» recently updated by this user
                    $repo->deleteByLastEditor($uid);
                «ENDIF»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR userField: getUserFieldsEntity»
                    «userField.onAccountDeletionHandler»
                «ENDFOR»
            «ENDIF»
            «IF !application.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logger->notice('{app}: User {user} has been deleted, so we deleted corresponding {entities}, too.', array('app' => '«application.appName»', 'user' => UserUtil::getVar('uname'), 'entities' => '«nameMultiple.formatForDisplay»'));
            «ENDIF»
        «ENDIF»
    '''

    def private onAccountDeletionHandler(UserField it) '''
        «IF entity instanceof Entity»
            «IF onAccountDeletion != AccountDeletionHandler.DELETE»
                // set last editor to «onAccountDeletion.adhAsConstant» («onAccountDeletion.adhUid») for all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->updateUserField('«name.formatForCode»', $uid, «onAccountDeletion.adhUid»);
            «ELSE»
                // delete all «(entity as Entity).nameMultiple.formatForDisplay» affected by this user
                $repo->deleteByUserField('«name.formatForCode»', $uid);
            «ENDIF»
        «ENDIF»
    '''
}
