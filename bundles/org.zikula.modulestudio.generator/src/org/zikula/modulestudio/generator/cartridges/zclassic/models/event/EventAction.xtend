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
        $objectId = «entityVar»->createCompositeIdentifier();
        $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => $objectId];
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
            $this->workflowHelper->normaliseWorkflowData(«entityVar»);
            $workflow = «entityVar»['__WORKFLOW__'];
            if ($workflow['id'] > 0) {
                $result = true;
                try {
                    $workflow = $this->objectManager->find('Zikula\Core\Doctrine\Entity\WorkflowEntity', $workflow['id']);
                    $this->objectManager->remove($workflow);
                    $this->objectManager->flush();
                } catch (\Exception $e) {
                    $result = false;
                }
                if (false === $result) {
                    $this->session->getFlashBag()->add('error', $this->translator->__('Error! Could not remove stored workflow. Deletion has been aborted.'));

                    return false;
                }
            }
        «ENDIF»
    '''

    def postRemove(Application it) '''
        $objectType = «entityVar»->get_objectType();
        $objectId = «entityVar»->createCompositeIdentifier();

        «IF hasUploads»
            $uploadFields = $this->getUploadFields($objectType);
            foreach ($uploadFields as $uploadField) {
                if (empty(«entityVar»[$uploadField])) {
                    continue;
                }

                // remove upload file
                $this->uploadHelper->deleteUploadFile(«entityVar», $uploadField);
            }
        «ENDIF»

        $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => $objectType, 'id' => $objectId];
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
        $objectId = «entityVar»->createCompositeIdentifier();
        $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => $objectId];
        $this->logger->debug('{app}: User {user} updated the {entity} with id {id}.', $logArgs);

        // create the filter event and dispatch it
        $event = $this->createFilterEvent(«entityVar»);
        $this->eventDispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_UPDATE'), $event);
    '''
}
