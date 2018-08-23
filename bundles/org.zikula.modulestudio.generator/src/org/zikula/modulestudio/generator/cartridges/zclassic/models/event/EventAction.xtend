package org.zikula.modulestudio.generator.cartridges.zclassic.models.event

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EventAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    String entityVar

    new(String entityVar) {
        this.entityVar = entityVar
    }

    def postLoad(Application it) '''
        «IF !getUploadEntities.empty»

            // prepare helper fields for uploaded files
            $uploadFields = $this->getUploadFields(«entityVar»->get_objectType());
            if (count($uploadFields) > 0) {
                $uploadHelper = $this->container->get('«appService».upload_helper');
                $request = $this->container->get('request_stack')->getCurrentRequest();
                $baseUrl = $request->getSchemeAndHttpHost() . $request->getBasePath();

                «entityVar»->set_uploadBasePath($uploadHelper->getFileBaseFolder(«entityVar»->get_objectType()));
                «entityVar»->set_uploadBaseUrl($baseUrl);

                // determine meta data if it does not exist
                foreach ($uploadFields as $fieldName) {
                    if (empty(«entityVar»[$fieldName])) {
                        continue;
                    }

                    if (is_array(«entityVar»[$fieldName . 'Meta']) && count(«entityVar»[$fieldName . 'Meta'])) {
                        continue;
                    }
                    $basePath = $uploadHelper->getFileBaseFolder(«entityVar»->get_objectType(), $fieldName);
                    $fileName = «entityVar»[$fieldName . 'FileName'];
                    $filePath = $basePath . $fileName;
                    if (!file_exists($filePath)) {
                        continue;
                    }
                    «entityVar»[$fieldName . 'Meta'] = $uploadHelper->readMetaDataForFile($fileName, $filePath);
                }
            }
        «ENDIF»

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_LOAD'), $event);
    '''

    def prePersist(Application it) '''
        «IF hasLoggable»

            if («entityVar» instanceof AbstractLogEntry) {
                // check if a supported object has been undeleted
                if ('create' != «entityVar»->getAction()) {
                    return;
                }

                // select main entity
                if (null === «entityVar»->getObjectId()) {
                    return;
                }

                $repository = $this->container->get('«appService».entity_factory')->getObjectManager()->getRepository(«entityVar»->getObjectClass());
                $object = $repository->find(«entityVar»->getObjectId());
                if (null === $object || !method_exists($object, 'get_objectType')) {
                    return;
                }

                // set correct version after undeletion
                $logVersion = «entityVar»->getVersion();
                «FOR entity : getLoggableEntities»
                    if ('«entity.name.formatForCode»' == $object->get_objectType() && method_exists($object, 'get«entity.getVersionField.name.formatForCodeCapital»')) {
                        if ($logVersion < $object->get«entity.getVersionField.name.formatForCodeCapital»()) {
                            «entityVar»->setVersion($object->get«entity.getVersionField.name.formatForCodeCapital»());
                        }
                    }
                «ENDFOR»

                return;
            }
        «ENDIF»

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_PERSIST'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }
    '''

    def postPersist(Application it) '''

        $currentUserApi = $this->container->get('zikula_users_module.current_user');
        $logArgs = ['app' => '«appName»', 'user' => $currentUserApi->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => «entityVar»->getKey()];
        $this->logger->debug('{app}: User {user} created the {entity} with id {id}.', $logArgs);
        «IF hasLoggable»

            $this->purgeHistory(«entityVar»->get_objectType());
        «ENDIF»

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_PERSIST'), $event);
    '''

    def preRemove(Application it) '''

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_REMOVE'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }
    '''

    def postRemove(Application it) '''

        $objectType = «entityVar»->get_objectType();
        «IF !getUploadEntities.empty»

            $uploadFields = $this->getUploadFields($objectType);
            if (count($uploadFields) > 0) {
                $uploadHelper = $this->container->get('«appService».upload_helper');
                foreach ($uploadFields as $fieldName) {
                    if (empty(«entityVar»[$fieldName])) {
                        continue;
                    }

                    // remove upload file
                    $uploadHelper->deleteUploadFile(«entityVar», $fieldName);
                }
            }
        «ENDIF»
        «IF hasLoggable»

            $this->purgeHistory($objectType);
        «ENDIF»

        $currentUserApi = $this->container->get('zikula_users_module.current_user');
        $logArgs = ['app' => '«appName»', 'user' => $currentUserApi->get('uname'), 'entity' => $objectType, 'id' => «entityVar»->getKey()];
        $this->logger->debug('{app}: User {user} removed the {entity} with id {id}.', $logArgs);

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper($objectType) . '_POST_REMOVE'), $event);
    '''

    def preUpdate(Application it) '''

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_UPDATE'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }
    '''

    def postUpdate(Application it) '''

        $currentUserApi = $this->container->get('zikula_users_module.current_user');
        $logArgs = ['app' => '«appName»', 'user' => $currentUserApi->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => «entityVar»->getKey()];
        $this->logger->debug('{app}: User {user} updated the {entity} with id {id}.', $logArgs);
        «IF hasLoggable»

            $this->purgeHistory(«entityVar»->get_objectType());
        «ENDIF»

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_UPDATE'), $event);
    '''
}
