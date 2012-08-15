package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.modulestudio.Application

class Group {

    def generate(Application it, Boolean isBase) '''
        /**
         * Listener for the `group.create` event.
         *
         * Occurs after a group is created. All handlers are notified.
         * The full group record created is available as the subject.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function create(Zikula_Event $event)
        {
            «IF !isBase»
                parent::create($event);
            «ENDIF»
        }

        /**
         * Listener for the `group.update` event.
         *
         * Occurs after a group is updated. All handlers are notified.
         * The full updated group record is available as the subject.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function update(Zikula_Event $event)
        {
            «IF !isBase»
                parent::update($event);
            «ENDIF»
        }

        /**
         * Listener for the `group.delete` event.
         *
         * Occurs after a group is deleted from the system.
         * All handlers are notified.
         * The full group record deleted is available as the subject.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function delete(Zikula_Event $event)
        {
            «IF !isBase»
                parent::delete($event);
            «ENDIF»
        }

        /**
         * Listener for the `group.adduser` event.
         *
         * Occurs after a user is added to a group.
         * All handlers are notified.
         * It does not apply to pending membership requests.
         * The uid and gid are available as the subject.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function addUser(Zikula_Event $event)
        {
            «IF !isBase»
                parent::addUser($event);
            «ENDIF»
        }

        /**
         * Listener for the `group.removeuser` event.
         *
         * Occurs after a user is removed from a group.
         * All handlers are notified.
         * The uid and gid are available as the subject.
         *
         * @param Zikula_Event $event The event instance.
         */
        public static function removeUser(Zikula_Event $event)
        {
            «IF !isBase»
                parent::removeUser($event);
            «ENDIF»
        }
    '''
}
