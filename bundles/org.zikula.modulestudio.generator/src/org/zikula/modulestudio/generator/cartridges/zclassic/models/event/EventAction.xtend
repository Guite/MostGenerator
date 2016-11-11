package org.zikula.modulestudio.generator.cartridges.zclassic.models.event

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
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
import org.zikula.modulestudio.generator.extensions.Utils

class EventAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    String entityVar

    new(String entityVar) {
        this.entityVar = entityVar
    }

    // entity argument is only assigned for 1.3.x
    def postLoad(Application it, Entity entity) '''
        «IF isLegacy»
            // echo 'loaded a record ...';
            if ($this->processedPostLoad) {
                return true;
            }

            «entity.postLoadImpl»

            «entityVar»->prepareItemActions();
        «ELSE»

            $serviceManager = ServiceUtil::getManager();
            $dispatcher = $serviceManager->get('event_dispatcher');

            // create the filter event and dispatch it
            $filterEventClass = 'Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
            $event = new $filterEventClass(«entityVar»);
            $dispatcher->dispatch(constant('«appName»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_LOAD'), $event);
        «ENDIF»

        $this->processedPostLoad = true;
    '''

    // 1.3.x only
    def postLoadLegacySanitizing(Entity it) '''
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
                if (isset(«entityVar»[$fieldName])) {
                    if (!empty(«entityVar»[$fieldName]) || ($allowZero && «entityVar»[$fieldName] == 0)) {
                        $string = «entityVar»[$fieldName];
                        if («entityVar»->containsHtml($string)) {
                            $string = DataUtil::formatForDisplayHTML($string);
                        } else {
                            $string = DataUtil::formatForDisplay($string);
                            $string = nl2br($string);
                        }
                    }
                }

                // workaround for ampersand problem (#692)
                $string = str_replace('&amp;', '&', $string);

                «entityVar»[$fieldName] = $string;
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

                «entityVar»[$fieldName] = isset(«entityVar»[$fieldName]) && !empty(«entityVar»[$fieldName]) ? DataUtil::formatForDisplay(«entityVar»[$fieldName]) : '';
            }
        «ENDIF»
    '''

    def prePersist(Application it) '''
        «IF !isLegacy»
            $serviceManager = ServiceUtil::getManager();
            $dispatcher = $serviceManager->get('event_dispatcher');

            // create the filter event and dispatch it
            $filterEventClass = 'Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
            $event = new $filterEventClass(«entityVar»);
            $dispatcher->dispatch(constant('«appName»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_PERSIST'), $event);
            if ($event->isPropagationStopped()) {
                return false;
            }
        «ENDIF»
    '''

    def postPersist(Application it) '''
        «IF !isLegacy»
            $serviceManager = ServiceUtil::getManager();
            $objectId = «entityVar»->createCompositeIdentifier();
            $logger = $serviceManager->get('logger');
            $logArgs = ['app' => '«appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => $objectId];
            $logger->debug('{app}: User {user} created the {entity} with id {id}.', $logArgs);

            $dispatcher = $serviceManager->get('event_dispatcher');

            // create the filter event and dispatch it
            $filterEventClass = 'Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
            $event = new $filterEventClass(«entityVar»);
            $dispatcher->dispatch(constant('«appName»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_PERSIST'), $event);
        «ENDIF»
    '''

    def preRemove(Application it) '''
        «IF !isLegacy»
            $serviceManager = ServiceUtil::getManager();
            $dispatcher = $serviceManager->get('event_dispatcher');

            // create the filter event and dispatch it
            $filterEventClass = 'Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
            $event = new $filterEventClass(«entityVar»);
            $dispatcher->dispatch(constant('«appName»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_REMOVE'), $event);
            if ($event->isPropagationStopped()) {
                return false;
            }

        «ENDIF»
        // delete workflow for this entity
        «IF !isLegacy»
            $workflowHelper = $serviceManager->get('«appService».workflow_helper');
            $workflowHelper->normaliseWorkflowData(«entityVar»);
        «ENDIF»
        $workflow = «entityVar»['__WORKFLOW__'];
        if ($workflow['id'] > 0) {
            «IF isLegacy»
                $result = (bool) DBUtil::deleteObjectByID('workflows', $workflow['id']);
            «ELSE»
                $entityManager = $serviceManager->get('doctrine.orm.default_entity_manager');
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
                «IF isLegacy»
                    $dom = ZLanguage::getModuleDomain('«appName»');

                    return LogUtil::registerError(__('Error! Could not remove stored workflow. Deletion has been aborted.', $dom));
                «ELSE»
                    $flashBag = $serviceManager->get('session')->getFlashBag();
                    $flashBag->add('error', $serviceManager->get('translator.default')->__('Error! Could not remove stored workflow. Deletion has been aborted.'));

                    return false;
                «ENDIF»
            }
        }
    '''

    def postRemove(Application it) '''
        «IF !isLegacy»
            $serviceManager = ServiceUtil::getManager();

        «ENDIF»
        «IF hasUploads || !isLegacy»
            $objectType = «entityVar»->get_objectType();
            $objectId = «entityVar»->createCompositeIdentifier();

        «ENDIF»
        «IF hasUploads»
            «IF isLegacy»
                // initialise the upload handler
                $uploadManager = new «appName»_UploadHandler();
            «ELSE»
                // retrieve the upload handler
                $uploadManager = $serviceManager->get('«appService».upload_handler');
            «ENDIF»

            $uploadFields = «IF isLegacy»array()«ELSE»[]«ENDIF»;
            switch ($objectType) {
                «FOR entity : entities.filter[e|e.hasUploadFieldsEntity]»
                    case '«entity.name.formatForCode»':
                        $uploadFields = «IF isLegacy»array(«ELSE»[«ENDIF»«FOR uploadField : entity.getUploadFieldsEntity SEPARATOR ', '»'«uploadField.name.formatForCode»'«ENDFOR»«IF isLegacy»)«ELSE»]«ENDIF»;
                        break;
                «ENDFOR»
            }

            foreach ($uploadFields as $uploadField) {
                if (empty(«entityVar»->$uploadField)) {
                    continue;
                }

                // remove upload file (and image thumbnails)
                $uploadManager->deleteUploadFile('«it.name.formatForCode»', «entityVar», $uploadField, $objectId);
            }
        «ENDIF»
        «IF !isLegacy»

            $logger = $serviceManager->get('logger');
            $logArgs = ['app' => '«appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => $objectType, 'id' => $objectId];
            $logger->debug('{app}: User {user} removed the {entity} with id {id}.', $logArgs);

            $dispatcher = $serviceManager->get('event_dispatcher');

            // create the filter event and dispatch it
            $filterEventClass = 'Filter' . ucfirst($objectType) . 'Event';
            $event = new $filterEventClass(«entityVar»);
            $dispatcher->dispatch(constant('«appName»Events::' . strtoupper($objectType) . '_POST_REMOVE'), $event);
        «ENDIF»
    '''

    def preUpdate(Application it) '''
        «IF !isLegacy»
            $serviceManager = ServiceUtil::getManager();
            $dispatcher = $serviceManager->get('event_dispatcher');

            // create the filter event and dispatch it
            $filterEventClass = 'Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
            $event = new $filterEventClass(«entityVar»);
            $dispatcher->dispatch(constant('«appName»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_UPDATE'), $event);
            if ($event->isPropagationStopped()) {
                return false;
            }
        «ENDIF»
    '''

    def postUpdate(Application it) '''
        «IF !isLegacy»
            $serviceManager = ServiceUtil::getManager();
            $objectId = «entityVar»->createCompositeIdentifier();
            $logger = $serviceManager->get('logger');
            $logArgs = ['app' => '«appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => $objectId];
            $logger->debug('{app}: User {user} updated the {entity} with id {id}.', $logArgs);

            $dispatcher = $serviceManager->get('event_dispatcher');

            // create the filter event and dispatch it
            $filterEventClass = 'Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
            $event = new $filterEventClass(«entityVar»);
            $dispatcher->dispatch(constant('«appName»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_UPDATE'), $event);
        «ENDIF»
    '''

    def private postLoadImpl(Entity it) '''
        $currentFunc = FormUtil::getPassedValue('func', 'main', 'GETPOST', FILTER_SANITIZE_STRING);
        $usesCsvOutput = FormUtil::getPassedValue('usecsvext', false, 'GETPOST', FILTER_VALIDATE_BOOLEAN);
        «IF hasUploadFieldsEntity»

            // initialise the upload handler
            $uploadManager = new «application.appName»_UploadHandler();
            $serviceManager = ServiceUtil::getManager();
            $controllerHelper = new «application.appName»_Util_Controller($serviceManager);
        «ENDIF»

        «FOR field : fields»«IF !(field instanceof ArrayField)»«field.sanitizeForOutput»«ENDIF»«ENDFOR»
    '''

    def private sanitizeForOutput(EntityField it) {
        switch it {
            BooleanField: '''
                             «entityVar»['«name.formatForCode»'] = (bool) «entityVar»['«name.formatForCode»'];
                         '''
            AbstractIntegerField: '''
                             «entityVar»['«name.formatForCode»'] = (int) ((isset(«entityVar»['«name.formatForCode»']) && !empty(«entityVar»['«name.formatForCode»'])) ? DataUtil::formatForDisplay(«entityVar»['«name.formatForCode»']) : 0);
                         '''
            DecimalField: '''
                             «entityVar»['«name.formatForCode»'] = (float) ((isset(«entityVar»['«name.formatForCode»']) && !empty(«entityVar»['«name.formatForCode»'])) ? DataUtil::formatForDisplay(«entityVar»['«name.formatForCode»']) : 0.00);
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
                            «entityVar»['«name.formatForCode»'] = (float) ((isset(«entityVar»['«name.formatForCode»']) && !empty(«entityVar»['«name.formatForCode»'])) ? DataUtil::formatForDisplay(«entityVar»['«name.formatForCode»']) : 0.00);
                         '''
            default: '''
                            «entityVar»['«it.name.formatForCode»'] = ((isset(«entityVar»['«it.name.formatForCode»']) && !empty(«entityVar»['«it.name.formatForCode»'])) ? DataUtil::formatForDisplay(«entityVar»['«it.name.formatForCode»']) : '');
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
        if (!empty(«entityVar»['«realName»'])) {
            try {
                $basePath = $controllerHelper->getFileBaseFolder('«entity.name.formatForCode»', '«realName»');
            } catch (\Exception $e) {
                «IF entity.application.isLegacy»
                    return LogUtil::registerError($e->getMessage());
                «ELSE»
                    $serviceManager = ServiceUtil::getManager();
                    $flashBag = $serviceManager->get('session')->getFlashBag();
                    $flashBag->add('error', $e->getMessage());

                    return false;
                «ENDIF»
            }

            $fullPath = $basePath . «entityVar»['«realName»'];
            «entityVar»['«realName»FullPath'] = $fullPath;
            «entityVar»['«realName»FullPathURL'] = System::getBaseUrl() . $fullPath;

            // just some backwards compatibility stuff«/*TODO remove on demand handling of upload meta data */»
            /*if (!isset(«entityVar»['«realName»Meta']) || !is_array(«entityVar»['«realName»Meta']) || !count(«entityVar»['«realName»Meta'])) {
                // assign new meta data
                «entityVar»['«realName»Meta'] = $uploadManager->readMetaDataForFile(«entityVar»['«realName»'], $fullPath);
            }*/
        }
    '''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}
