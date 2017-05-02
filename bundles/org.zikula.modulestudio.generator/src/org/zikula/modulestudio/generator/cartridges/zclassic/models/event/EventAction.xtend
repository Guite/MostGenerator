package org.zikula.modulestudio.generator.cartridges.zclassic.models.event

import de.guite.modulestudio.metamodel.Application
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

    def postLoad(Application it) '''
        «IF hasUploads»

            // prepare helper fields for uploaded files
            $uploadFields = $this->getUploadFields($entity->get_objectType());
            if (count($uploadFields) > 0) {
                $uploadHelper = $this->container->get('«appService».upload_helper');
                $request = $this->container->get('request_stack')->getCurrentRequest();
                $baseUrl = $request->getSchemeAndHttpHost() . $request->getBasePath();
                foreach ($uploadFields as $fieldName) {
                    $uploadHelper->initialiseUploadField($entity, $fieldName, $baseUrl);
                }
            }
        «ENDIF»

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_LOAD'), $event);
    '''

    def prePersist(Application it) '''
        «IF hasUploads»

            $uploadFields = $this->getUploadFields($entity->get_objectType());
            foreach ($uploadFields as $uploadField) {
                if (empty(«entityVar»[$uploadField])) {
                    continue;
                }

                if (!($entity[$uploadField] instanceof File)) {
                    $entity[$uploadField] = new File($entity[$uploadField]);
                }
                «entityVar»[$uploadField] = «entityVar»[$uploadField]->getFilename();
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
        «IF !targets('1.5')»

            // delete workflow for this entity
            $workflowHelper = $this->container->get('«appService».workflow_helper');
            $workflowHelper->normaliseWorkflowData(«entityVar»);
            $workflow = «entityVar»['__WORKFLOW__'];
            if ($workflow['id'] > 0) {
                $result = true;
                try {
                    $entityManager = $args->getEntityManager();
                    $workflow = $entityManager->find('Zikula\Core\Doctrine\Entity\WorkflowEntity', $workflow['id']);
                    $entityManager->remove($workflow);
                    $entityManager->flush();
                } catch (\Exception $e) {
                    $result = false;
                }
                if (false === $result) {
                    $session = $this->container->get('session');
                    $session->getFlashBag()->add('error', $this->translator->__('Error! Could not remove stored workflow. Deletion has been aborted.'));

                    return false;
                }
            }
        «ENDIF»
    '''

    def postRemove(Application it) '''

        $objectType = «entityVar»->get_objectType();
        «IF hasUploads»

            $uploadFields = $this->getUploadFields($objectType);
            if (count($uploadFields) > 0) {
                $uploadHelper = $this->container->get('«appService».upload_helper');
                foreach ($uploadFields as $uploadField) {
                    if (empty(«entityVar»[$uploadField])) {
                        continue;
                    }

                    // remove upload file
                    $uploadHelper->deleteUploadFile(«entityVar», $uploadField);
                }
            }
        «ENDIF»

        $currentUserApi = $this->container->get('zikula_users_module.current_user');
        $logArgs = ['app' => '«appName»', 'user' => $currentUserApi->get('uname'), 'entity' => $objectType, 'id' => «entityVar»->getKey()];
        $this->logger->debug('{app}: User {user} removed the {entity} with id {id}.', $logArgs);

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper($objectType) . '_POST_REMOVE'), $event);
    '''

    def preUpdate(Application it) '''
        «IF hasUploads»

            $uploadFields = $this->getUploadFields($entity->get_objectType());
            foreach ($uploadFields as $uploadField) {
                if (empty(«entityVar»[$uploadField])) {
                    continue;
                }

                if (!($entity[$uploadField] instanceof File)) {
                    $entity[$uploadField] = new File($entity[$uploadField]);
                }
                «entityVar»[$uploadField] = «entityVar»[$uploadField]->getFilename();
            }
        «ENDIF»

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

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_UPDATE'), $event);
    '''
}
