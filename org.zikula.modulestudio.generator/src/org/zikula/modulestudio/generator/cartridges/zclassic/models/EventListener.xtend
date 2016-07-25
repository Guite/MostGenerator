package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityField
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EventListener {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for entity lifecycle callback methods.
     */
    def generateBase(Entity it) '''
        protected $processedLoadCallback = false;

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
         «IF !application.targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if upload file base path retrieval fails
         «ENDIF»
         */
        protected function performPostLoadCallback()
        {
            // echo 'loaded a record ...';
            if ($this->processedLoadCallback) {
                return true;
            }

            «postLoadImpl»

            $this->prepareItemActions();
            «IF !application.targets('1.3.x')»

                $serviceManager = ServiceUtil::getManager();
                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_POST_LOAD, $event);
            «ENDIF»

            $this->processedLoadCallback = true;

            return true;
        }
        «IF !getDerivedFields.filter(AbstractStringField).empty»

            /**
             * Formats a given textual field depending on it's actual kind of content.
             *
             * @param string  $fieldName     Name of field to be formatted
             * @param string  $currentFunc   Name of current controller action
             * @param string  $usesCsvOutput Whether the output is CSV or not (defaults to false)
             * @param boolean $allowZero     Whether 0 values are allowed or not (defaults to false)
             */
            protected function formatTextualField($fieldName, $currentFunc, $usesCsvOutput = false, $allowZero = false)
            {
                if ($currentFunc == 'edit') {
                    // apply no changes when editing the content
                    return;
                }

                if ($usesCsvOutput == 1) {
                    // apply no changes for CSV output
                    return;
                }

                $string = '';
                if (isset($this[$fieldName])) {
                    if (!empty($this[$fieldName]) || ($allowZero && $this[$fieldName] == 0)) {
                        $string = $this[$fieldName];
                        if ($this->containsHtml($string)) {
                            $string = DataUtil::formatForDisplayHTML($string);
                        } else {
                            $string = DataUtil::formatForDisplay($string);
                            $string = nl2br($string);
                        }
                    }
                }

                // workaround for ampersand problem (#692)
                $string = str_replace('&amp;', '&', $string);

                $this[$fieldName] = $string;
            }

            /**
             * Checks whether any html tags are contained in the given string.
             * See http://stackoverflow.com/questions/10778035/how-to-check-if-string-contents-have-any-html-in-it for implementation details.
             *
             * @param $string string The given input string
             *
             * @return boolean Whether any html tags are found or not
             */
            protected function containsHtml($string)
            {
                return preg_match("/<[^<]+>/", $string, $m) != 0;
            }
        «ENDIF»
        «IF !getDerivedFields.filter(ObjectField).empty»

            /**
             * Formats a given object field.
             *
             * @param string  $fieldName     Name of field to be formatted.
             * @param string  $currentFunc   Name of current controller action.
             * @param string  $usesCsvOutput Whether the output is CSV or not (defaults to false).
             */
            protected function formatObjectField($fieldName, $currentFunc, $usesCsvOutput = false)
            {
                if ($currentFunc == 'edit') {
                    // apply no changes when editing the content
                    return;
                }

                if ($usesCsvOutput == 1) {
                    // apply no changes for CSV output
                    return;
                }

                $this[$fieldName] = isset($this[$fieldName]) && !empty($this[$fieldName]) ? DataUtil::formatForDisplay($this[$fieldName]) : '';
            }
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
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_PRE_PERSIST, $event);
                if ($event->isPropagationStopped()) {
                    return false;
                }

            «ENDIF»
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
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $objectId = $this->createCompositeIdentifier();
                $logger = $serviceManager->get('logger');
                $logArgs = ['app' => '«application.appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $objectId];
                $logger->debug('{app}: User {user} created the {entity} with id {id}.', $logArgs);

                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_POST_PERSIST, $event);

            «ENDIF»
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
         «IF !application.targets('1.3.x')»
         *
         * @throws RuntimeException Thrown if workflow deletion fails
         «ENDIF»
         */
        protected function performPreRemoveCallback()
        {
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_PRE_REMOVE, $event);
                if ($event->isPropagationStopped()) {
                    return false;
                }

            «ENDIF»
            // delete workflow for this entity
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $workflowHelper = $serviceManager->get('«application.appService».workflow_helper');
                $workflowHelper->normaliseWorkflowData($this);
            «ENDIF»
            $workflow = $this['__WORKFLOW__'];
            if ($workflow['id'] > 0) {
                «IF application.targets('1.3.x')»
                    $result = (bool) DBUtil::deleteObjectByID('workflows', $workflow['id']);
                «ELSE»
                    $entityManager = $serviceManager->get('doctrine.entitymanager');
                    $result = true;
                    try {
                        $workflow = $entityManager->find('Zikula\Core\Doctrine\Entity\WorkflowEntity', $workflow['id']);
                        $entityManager->remove($workflow);
                        $entityManager->flush();
                    } catch (\Exception $e) {
                        $result = false;
                    }
                «ENDIF»
                if ($result === false) {
                    «IF application.targets('1.3.x')»
                        $dom = ZLanguage::getModuleDomain('«application.appName»');

                        return LogUtil::registerError(__('Error! Could not remove stored workflow. Deletion has been aborted.', $dom));
                    «ELSE»
                        $session = $serviceManager->get('session');
                        $session->getFlashBag()->add(\Zikula_Session::MESSAGE_ERROR, $serviceManager->get('translator.default')->__('Error! Could not remove stored workflow. Deletion has been aborted.'));

                        return false;
                    «ENDIF»
                }
            }

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
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();

            «ENDIF»
            «IF it.hasUploadFieldsEntity || !application.targets('1.3.x')»
                $objectId = $this->createCompositeIdentifier();

            «ENDIF»
            «IF it.hasUploadFieldsEntity»
                «IF application.targets('1.3.x')»
                    // initialise the upload handler
                    $uploadManager = new «application.appName»_UploadHandler();
                «ELSE»
                    // retrieve the upload handler
                    $uploadManager = $serviceManager->get('«application.appService».upload_handler');
                «ENDIF»

                $uploadFields = «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»«FOR uploadField : getUploadFieldsEntity SEPARATOR ', '»'«uploadField.name.formatForCode»'«ENDFOR»«IF application.targets('1.3.x')»)«ELSE»]«ENDIF»;
                foreach ($uploadFields as $uploadField) {
                    if (empty($this->$uploadField)) {
                        continue;
                    }

                    // remove upload file (and image thumbnails)
                    $uploadManager->deleteUploadFile('«it.name.formatForCode»', $this, $uploadField, $objectId);
                }
            «ENDIF»
            «IF !application.targets('1.3.x')»

                $logger = $serviceManager->get('logger');
                $logArgs = ['app' => '«application.appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $objectId];
                $logger->debug('{app}: User {user} removed the {entity} with id {id}.', $logArgs);

                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_POST_REMOVE, $event);
            «ENDIF»

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
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_PRE_UPDATE, $event);
                if ($event->isPropagationStopped()) {
                    return false;
                }

            «ENDIF»
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
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $objectId = $this->createCompositeIdentifier();
                $logger = $serviceManager->get('logger');
                $logArgs = ['app' => '«application.appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $objectId];
                $logger->debug('{app}: User {user} updated the {entity} with id {id}.', $logArgs);

                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_POST_UPDATE, $event);

            «ENDIF»
            return true;
        }

        /**
         * Pre-Process the data prior to a save operation.
         * This combines the PrePersist and PreUpdate events.
         * For more information see corresponding callback handlers.
         *
         * @see «entityClassName('', false)»::preSaveCallback()
         * @return boolean true if completed successfully else false
         */
        protected function performPreSaveCallback()
        {
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_PRE_SAVE, $event);
                if ($event->isPropagationStopped()) {
                    return false;
                }
            «ENDIF»

            return true;
        }

        /**
         * Post-Process the data after a save operation.
         * This combines the PostPersist and PostUpdate events.
         * For more information see corresponding callback handlers.
         *
         * @see «entityClassName('', false)»::postSaveCallback()
         * @return boolean true if completed successfully else false
         */
        protected function performPostSaveCallback()
        {
            «IF !application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $objectId = $this->createCompositeIdentifier();
                $logger = $serviceManager->get('logger');
                $logArgs = ['app' => '«application.appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => '«name.formatForDisplay»', 'id' => $objectId];
                $logger->debug('{app}: User {user} saved the {entity} with id {id}.', $logArgs);

                $dispatcher = $serviceManager->get('event_dispatcher');

                // create the new Filter«name.formatForCodeCapital»Event and dispatch it
                $event = new Filter«name.formatForCodeCapital»Event($this);
                $dispatcher->dispatch(«application.name.formatForCodeCapital»Events::«name.formatForDB.toUpperCase»_POST_SAVE, $event);

            «ENDIF»
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

        /**
         * Pre-Process the data prior to a save operation.
         *
         * @ORM\PrePersist
         * @ORM\PreUpdate
         * @see «entityClassName('', false)»::performPreSaveCallback()
         * @return void
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
         * @return void
         */
        public function postSaveCallback()
        {
            $this->performPostSaveCallback();
        }
    '''


    def private postLoadImpl(Entity it) '''
        $currentFunc = FormUtil::getPassedValue('func', '«IF application.targets('1.3.x')»main«ELSE»index«ENDIF»', 'GETPOST', FILTER_SANITIZE_STRING);
        «IF application.targets('1.3.x')»
            $usesCsvOutput = FormUtil::getPassedValue('usecsvext', false, 'GETPOST', FILTER_VALIDATE_BOOLEAN);
        «ELSE»
            $serviceManager = ServiceUtil::getManager();
            $requestStack = $serviceManager->get('request_stack');
            $usesCsvOutput = $requestStack->getCurrentRequest()->getRequestFormat() == 'csv' ? true : false;
        «ENDIF»
        «IF hasUploadFieldsEntity»

            // initialise the upload handler
            «IF application.targets('1.3.x')»
                $uploadManager = new «application.appName»_UploadHandler();
            «ELSE»
                $uploadManager = $serviceManager->get('«application.appService».upload_handler');
            «ENDIF»
            «IF application.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $controllerHelper = new «application.appName»_Util_Controller($serviceManager);
            «ELSE»
                $controllerHelper = $serviceManager->get('«application.appService».controller_helper');
            «ENDIF»
        «ENDIF»

        «FOR field : fields»«IF !(field instanceof ArrayField)»«field.sanitizeForOutput»«ENDIF»«ENDFOR»
    '''

    def private sanitizeForOutput(EntityField it) {
        switch it {
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
            ObjectField: '''
                            $this->formatObjectField('«it.name.formatForCode»', $currentFunc, $usesCsvOutput);
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
        $this->formatTextualField('«it.name.formatForCode»', $currentFunc, $usesCsvOutput);
    '''

    def private sanitizeForOutputHTMLWithZero(EntityField it) '''
        $this->formatTextualField('«it.name.formatForCode»', $currentFunc, $usesCsvOutput, true);
    '''

    def private sanitizeForOutputUpload(UploadField it) '''
        «val realName = name.formatForCode»
        if (!empty($this['«realName»'])) {
            try {
                $basePath = $controllerHelper->getFileBaseFolder('«entity.name.formatForCode»', '«realName»');
            } catch (\Exception $e) {
                «IF entity.application.targets('1.3.x')»
                    return LogUtil::registerError($e->getMessage());
                «ELSE»
                    $serviceManager = ServiceUtil::getManager();
                    $session = $serviceManager->get('session');
                    $session->getFlashBag()->add(\Zikula_Session::MESSAGE_ERROR, $e->getMessage());
                    return false;
                «ENDIF»
            }

            $fullPath = $basePath . $this['«realName»'];
            $this['«realName»FullPath'] = $fullPath;
            $this['«realName»FullPathURL'] = System::getBaseUrl() . $fullPath;

            // just some backwards compatibility stuff«/*TODO: remove somewhen*/»
            /*if (!isset($this['«realName»Meta']) || !is_array($this['«realName»Meta']) || !count($this['«realName»Meta'])) {
                // assign new meta data
                $this['«realName»Meta'] = $uploadManager->readMetaDataForFile($this['«realName»'], $fullPath);
            }*/
        }
    '''
}
