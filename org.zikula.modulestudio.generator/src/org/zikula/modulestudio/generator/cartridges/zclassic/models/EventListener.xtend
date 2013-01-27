package org.zikula.modulestudio.generator.cartridges.zclassic.models

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EventListener {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for entity lifecycle callback methods.
     */
    def generateBase(Entity it) {
        // Temporary hack
        stubMethodsForNowBaseImpl
        /*for (listener : listeners) listener.eventListenerBaseImpl */
    }
    def generateImpl(Entity it) {
        // Temporary hack
        stubMethodsForNowImpl
        /*for (listener : listeners) listener.eventListenerImpl */
    }
/*
    def private dispatch eventListenerBaseImpl(EntityEventListener it) {
    }
    def private dispatch eventListenerBaseImpl(PreProcess it) {
    }
    def private dispatch eventListenerBaseImpl(PostProcess it) {
    }

    def private dispatch eventListenerImpl(EntityEventListener it) {
    }
    def private dispatch eventListenerImpl(PreProcess it) {
    }
    def private dispatch eventListenerImpl(PostProcess it) {
    }
*/
    def private stubMethodsForNowBaseImpl(Entity it) '''
«/*    def private eventListenerBaseImpl(PostLoad it) {*/»
        /**
         * Post-Process the data after the entity has been constructed by the entity manager.
         * The event happens after the entity has been loaded from database or after a refresh call.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - no access to associations (not initialised yet)
         *
         * @see «entityClassName('', false)»::postLoadCallback()
         * @return boolean true if completed successfully else false.
         */
        protected function performPostLoadCallback()
        {
            // echo 'loaded a record ...';
            «postLoadImpl»
            $this->prepareItemActions();
            return true;
        }
«/*}*/»«/*    def private eventListenerBaseImpl(PrePersist it) {*/»
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
         * @return boolean true if completed successfully else false.
         */
        protected function performPrePersistCallback()
        {
            // echo 'inserting a record ...';
            $this->validate();
            return true;
        }
«/*}*/»«/*    def private eventListenerBaseImpl(PostPersist it) {*/»
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
         * @return boolean true if completed successfully else false.
         */
        protected function performPostPersistCallback()
        {
            // echo 'inserted a record ...';
            return true;
        }
«/*}*/»«/*    def private eventListenerBaseImpl(PreRemove it) {*/»
        /**
         * Pre-Process the data prior a delete operation.
         * The event happens before the entity managers remove operation is executed for this entity.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - will not be called for a DQL DELETE statement
         *
         * @see «entityClassName('', false)»::preRemoveCallback()
         * @return boolean true if completed successfully else false.
         */
        protected function performPreRemoveCallback()
        {
            // delete workflow for this entity
            $workflow = $this['__WORKFLOW__'];
            $result = (bool) \DBUtil::deleteObjectByID('workflows', $workflow['id']);
            if ($result === false) {
                $dom = ZLanguage::getModuleDomain('«container.application.appName»');
                return \LogUtil::registerError(__('Error! Could not remove stored workflow. Deletion has been aborted.', $dom));
            }

            return true;
        }
«/*}*/»«/*    def private eventListenerBaseImpl(PostRemove it) {*/»
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
         * @return boolean true if completed successfully else false.
         */
        protected function performPostRemoveCallback()
        {
            // echo 'deleted a record ...';
            «IF it.hasUploadFieldsEntity»
                «IF it.hasCompositeKeys»
                    $objectIds = array();
                    «FOR pkField : it.getPrimaryKeyFields»
                        $objectIds[] = $this['«pkField.name.formatForCode»'];
                    «ENDFOR»
                    $objectId = implode('-', $objectIds);
                «ELSE»
                    $objectId = $this['«it.primaryKeyFields.head.name.formatForCode»'];
                «ENDIF»
                // initialise the upload handler
                $uploadManager = new «container.application.appName»«IF container.application.targets('1.3.5')»_«ELSE»\«ENDIF»UploadHandler();

                $uploadFields = array(«FOR uploadField : getUploadFieldsEntity SEPARATOR ', '»'«uploadField.name.formatForCode»'«ENDFOR»);
                foreach ($uploadFields as $uploadField) {
                    if (empty($this->$uploadField)) {
                        continue;
                    }

                    // remove upload file (and image thumbnails)
                    $uploadManager->deleteUploadFile('«it.name.formatForCode»', $this, $uploadField, $objectId);
                }
            «ENDIF»

            return true;
        }
«/*}*/»«/*    def private eventListenerBaseImpl(PreUpdate it) {*/»
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
         * @return boolean true if completed successfully else false.
         */
        protected function performPreUpdateCallback()
        {
            // echo 'updating a record ...';
            $this->validate();
            return true;
        }
«/*}*/»«/*    def private eventListenerBaseImpl(PostUpdate it) {*/»
        /**
         * Post-Process the data after an update operation.
         * The event happens after the database update operations for the entity data.
         *
         * Restrictions:
         *     - no access to entity manager or unit of work apis
         *     - will not be called for a DQL UPDATE statement
         *
         * @see «entityClassName('', false)»::postUpdateCallback()
         * @return boolean true if completed successfully else false.
         */
        protected function performPostUpdateCallback()
        {
            // echo 'updated a record ...';
            return true;
        }
«/*}*/»
        /**
         * Pre-Process the data prior to a save operation.
         * This combines the PrePersist and PreUpdate events.
         * For more information see corresponding callback handlers.
         *
         * @see «entityClassName('', false)»::preSaveCallback()
         * @return boolean true if completed successfully else false.
         */
        protected function performPreSaveCallback()
        {
            // echo 'saving a record ...';
            $this->validate();
            return true;
        }

        /**
         * Post-Process the data after a save operation.
         * This combines the PostPersist and PostUpdate events.
         * For more information see corresponding callback handlers.
         *
         * @see «entityClassName('', false)»::postSaveCallback()
         * @return boolean true if completed successfully else false.
         */
        protected function performPostSaveCallback()
        {
            // echo 'saved a record ...';
            return true;
        }
«/*}*/»
    '''


    def private stubMethodsForNowImpl(Entity it) '''
«/*    def private eventListenerImpl(PostLoad it) {*/»
        /**
         * Post-Process the data after the entity has been constructed by the entity manager.
         *
         * @ORM\PostLoad
         * @see «entityClassName('', false)»::performPostLoadCallback()
         * @return void.
         */
        public function postLoadCallback()
        {
            $this->performPostLoadCallback();
        }
«/*}*/»«/*    def private eventListenerImpl(PrePersist it) {*/»
        /**
         * Pre-Process the data prior to an insert operation.
         *
         * @ORM\PrePersist
         * @see «entityClassName('', false)»::performPrePersistCallback()
         * @return void.
         */
        public function prePersistCallback()
        {
            $this->performPrePersistCallback();
        }
«/*}*/»«/*    def private eventListenerImpl(PostPersist it) {*/»
        /**
         * Post-Process the data after an insert operation.
         *
         * @ORM\PostPersist
         * @see «entityClassName('', false)»::performPostPersistCallback()
         * @return void.
         */
        public function postPersistCallback()
        {
            $this->performPostPersistCallback();
        }
«/*}*/»«/*    def private eventListenerImpl(PreRemove it) {*/»
        /**
         * Pre-Process the data prior a delete operation.
         *
         * @ORM\PreRemove
         * @see «entityClassName('', false)»::performPreRemoveCallback()
         * @return void.
         */
        public function preRemoveCallback()
        {
            $this->performPreRemoveCallback();
        }
«/*}*/»«/*    def private eventListenerImpl(PostRemove it) {*/»
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
«/*}*/»«/*    def private eventListenerImpl(PreUpdate it) {*/»
        /**
         * Pre-Process the data prior to an update operation.
         *
         * @ORM\PreUpdate
         * @see «entityClassName('', false)»::performPreUpdateCallback()
         * @return void.
         */
        public function preUpdateCallback()
        {
            $this->performPreUpdateCallback();
        }
«/*}*/»«/*    def private eventListenerImpl(PostUpdate it) {*/»
        /**
         * Post-Process the data after an update operation.
         *
         * @ORM\PostUpdate
         * @see «entityClassName('', false)»::performPostUpdateCallback()
         * @return void.
         */
        public function postUpdateCallback()
        {
            $this->performPostUpdateCallback();
        }
«/*}*/»
        /**
         * Pre-Process the data prior to a save operation.
         *
         * @ORM\PrePersist
         * @ORM\PreUpdate
         * @see «entityClassName('', false)»::performPreSaveCallback()
         * @return void.
         */
        public function preSaveCallback()
        {
            $this->performPreSaveCallback();
        }

        /**
         * Post-Process the data after a save operation.
         *
         * @ORM\PostPersist
         * @ORM\PostUpdate
         * @see «entityClassName('', false)»::performPostSaveCallback()
         * @return void.
         */
        public function postSaveCallback()
        {
            $this->performPostSaveCallback();
        }
«/*}*/»
    '''


    def private postLoadImpl(Entity it/* PostLoad it */) '''
        «val app = container.application»
        $currentFunc = \FormUtil::getPassedValue('func', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'GETPOST', FILTER_SANITIZE_STRING);
        «IF hasUploadFieldsEntity»

            // initialise the upload handler
            $uploadManager = new «app.appName»«IF app.targets('1.3.5')»_«ELSE»\«ENDIF»UploadHandler();
            $serviceManager = \ServiceUtil::getManager();
            $controllerHelper = new «app.appName»«IF app.targets('1.3.5')»_Util_Controller«ELSE»\Util\ControllerUtil«ENDIF»($serviceManager);
        «ENDIF»

        $this->initWorkflow();

        «FOR field : fields»«field.sanitizeForOutput»«ENDFOR»
    '''

    def private sanitizeForOutput(EntityField it) {
        switch (it) {
            BooleanField: '''
                             $this['«name.formatForCode»'] = (bool) $this['«name.formatForCode»'];
                         '''
            AbstractIntegerField: '''
                             $this['«name.formatForCode»'] = (int) ((isset($this['«name.formatForCode»']) && !empty($this['«name.formatForCode»'])) ? DataUtil::formatForDisplay($this['«name.formatForCode»']) : 0);
                         '''
            DecimalField: '''
                             $this['«name.formatForCode»'] = (float) ((isset($this['«name.formatForCode»']) && !empty($this['«name.formatForCode»'])) ? DataUtil::formatForDisplay($this['«name.formatForCode»']) : 0.00);
                         '''
            StringField: sanitizeForOutputHTML
            TextField: sanitizeForOutputHTML
            EmailField: sanitizeForOutputHTML
            ListField: sanitizeForOutputHTMLWithZero
            UploadField: sanitizeForOutputUpload
            ArrayField: '''
                             $this['«name.formatForCode»'] = ((isset($this['«name.formatForCode»']) && is_array($this['«name.formatForCode»'])) ? DataUtil::formatForDisplay($this['«name.formatForCode»']) : array());
                         '''
            AbstractDateField: ''
            FloatField: '''
                             $this['«name.formatForCode»'] = (float) ((isset($this['«name.formatForCode»']) && !empty($this['«name.formatForCode»'])) ? DataUtil::formatForDisplay($this['«name.formatForCode»']) : 0.00);
                         '''
            default: '''
                        $this['«it.name.formatForCode»'] = ((isset($this['«it.name.formatForCode»']) && !empty($this['«it.name.formatForCode»'])) ? DataUtil::formatForDisplay($this['«it.name.formatForCode»']) : '');
                    '''
        }
    }

    def private sanitizeForOutputHTML(EntityField it) '''
        if ($currentFunc != 'edit') {
            $this['«it.name.formatForCode»'] = ((isset($this['«it.name.formatForCode»']) && !empty($this['«it.name.formatForCode»'])) ? DataUtil::formatForDisplayHTML($this['«it.name.formatForCode»']) : '');
        }
    '''

    def private sanitizeForOutputHTMLWithZero(EntityField it) '''
        if ($currentFunc != 'edit') {
            $this['«it.name.formatForCode»'] = (((isset($this['«it.name.formatForCode»']) && !empty($this['«it.name.formatForCode»'])) || $this['«it.name.formatForCode»'] == 0) ? DataUtil::formatForDisplayHTML($this['«it.name.formatForCode»']) : '');
        }
    '''

    def private sanitizeForOutputUpload(UploadField it) '''
        «val realName = name.formatForCode»
        if (!empty($this['«realName»'])) {
            try {
                $basePath = $controllerHelper->getFileBaseFolder('«entity.name.formatForCode»', '«realName»');
            }
            catch (Exception $e) {
                return \LogUtil::registerError($e->getMessage());
            }
            $fullPath = $basePath .  $this['«realName»'];
            $this['«realName»FullPath'] = $fullPath;
            $this['«realName»FullPathURL'] = \System::getBaseUrl() . $fullPath;

            // just some backwards compatibility stuff«/*TODO: remove somewhen*/»
            if (!isset($this['«realName»Meta']) || !is_array($this['«realName»Meta']) || !count($this['«realName»Meta'])) {
                // assign new meta data
                $this['«realName»Meta'] = $uploadManager->readMetaDataForFile($this['«realName»'], $fullPath);
            }
        }
    '''
}
