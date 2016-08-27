package org.zikula.modulestudio.generator.cartridges.zclassic.models.event

import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

// 1.3.x only
class EventListener {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    EventAction eventAction = new EventAction('$this')

    /**
     * Entry point for entity lifecycle callback methods.
     */
    def generateBase(Entity it) '''
        protected $processedPostLoad = false;

        /**
         * Post-Process the data after the entity has been constructed by the entity manager.
         * The event happens after the entity has been loaded from database or after a refresh call.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - no access to associations (not initialised yet)
         *
         * @see «entityClassName('', false)»::postLoadCallback()
         * @return boolean true if completed successfully else false
         «IF !isLegacy»
         *
         * @throws RuntimeException Thrown if upload file base path retrieval fails
         «ENDIF»
         */
        protected function performPostLoadCallback()
        {
            «eventAction.postLoad(application, it)»

            return true;
        }
        «IF isLegacy»
            «eventAction.postLoadLegacySanitizing(it)»
        «ENDIF»

        /**
         * Pre-Process the data prior to an insert operation.
         * The event happens before the entity managers persist operation is executed for this entity.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - no identifiers available if using an identity generator like sequences
         *     - Doctrine won't recognize changes on relations which are done here
         *       if this method is called by cascade persist
         *     - no creation of other entities allowed
         *
         * @see «entityClassName('', false)»::prePersistCallback()
         * @return boolean true if completed successfully else false
         */
        protected function performPrePersistCallback()
        {
            «eventAction.prePersist(application)»

            return true;
        }

        /**
         * Post-Process the data after an insert operation.
         * The event happens after the entity has been made persistant.
         * Will be called after the database insert operations.
         * The generated primary key values are available.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *
         * @see «entityClassName('', false)»::postPersistCallback()
         * @return boolean true if completed successfully else false
         */
        protected function performPostPersistCallback()
        {
            «eventAction.postPersist(application)»

            return true;
        }

        /**
         * Pre-Process the data prior a delete operation.
         * The event happens before the entity managers remove operation is executed for this entity.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - will not be called for a DQL DELETE statement
         *
         * @see «entityClassName('', false)»::preRemoveCallback()
         * @return boolean true if completed successfully else false
         «IF !isLegacy»
         *
         * @throws RuntimeException Thrown if workflow deletion fails
         «ENDIF»
         */
        protected function performPreRemoveCallback()
        {
            «eventAction.preRemove(application)»

            return true;
        }

        /**
         * Post-Process the data after a delete.
         * The event happens after the entity has been deleted.
         * Will be called after the database delete operations.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - will not be called for a DQL DELETE statement
         *
         * @see «entityClassName('', false)»::postRemoveCallback()
         * @return boolean true if completed successfully else false
         */
        protected function performPostRemoveCallback()
        {
            «eventAction.postRemove(application)»

            return true;
        }

        /**
         * Pre-Process the data prior to an update operation.
         * The event happens before the database update operations for the entity data.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - will not be called for a DQL UPDATE statement
         *     - changes on associations are not allowed and won't be recognized by flush
         *     - changes on properties won't be recognized by flush as well
         *     - no creation of other entities allowed
         *
         * @see «entityClassName('', false)»::preUpdateCallback()
         * @return boolean true if completed successfully else false
         */
        protected function performPreUpdateCallback()
        {
            «eventAction.preUpdate(application)»

            return true;
        }

        /**
         * Post-Process the data after an update operation.
         * The event happens after the database update operations for the entity data.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - will not be called for a DQL UPDATE statement
         *
         * @see «entityClassName('', false)»::postUpdateCallback()
         * @return boolean true if completed successfully else false
         */
        protected function performPostUpdateCallback()
        {
            «eventAction.postUpdate(application)»

            return true;
        }
    '''


    def generateImpl(Entity it) '''
        /**
         * Post-Process the data after the entity has been constructed by the entity manager.
         *
         * @ORM\PostLoad
         * @see «entityClassName('', false)»::performPostLoadCallback()
         * @return void
         */
        public function postLoadCallback()
        {
            $this->performPostLoadCallback();
        }

        /**
         * Pre-Process the data prior to an insert operation.
         *
         * @ORM\PrePersist
         * @see «entityClassName('', false)»::performPrePersistCallback()
         * @return void
         */
        public function prePersistCallback()
        {
            $this->performPrePersistCallback();
        }

        /**
         * Post-Process the data after an insert operation.
         *
         * @ORM\PostPersist
         * @see «entityClassName('', false)»::performPostPersistCallback()
         * @return void
         */
        public function postPersistCallback()
        {
            $this->performPostPersistCallback();
        }

        /**
         * Pre-Process the data prior a delete operation.
         *
         * @ORM\PreRemove
         * @see «entityClassName('', false)»::performPreRemoveCallback()
         * @return void
         */
        public function preRemoveCallback()
        {
            $this->performPreRemoveCallback();
        }

        /**
         * Post-Process the data after a delete.
         *
         * @ORM\PostRemove
         * @see «entityClassName('', false)»::performPostRemoveCallback()
         * @return void
         */
        public function postRemoveCallback()
        {
            $this->performPostRemoveCallback();
        }

        /**
         * Pre-Process the data prior to an update operation.
         *
         * @ORM\PreUpdate
         * @see «entityClassName('', false)»::performPreUpdateCallback()
         * @return void
         */
        public function preUpdateCallback()
        {
            $this->performPreUpdateCallback();
        }

        /**
         * Post-Process the data after an update operation.
         *
         * @ORM\PostUpdate
         * @see «entityClassName('', false)»::performPostUpdateCallback()
         * @return void
         */
        public function postUpdateCallback()
        {
            $this->performPostUpdateCallback();
        }
    '''

    def private isLegacy(DataObject it) {
        application.targets('1.3.x')
    }
}
