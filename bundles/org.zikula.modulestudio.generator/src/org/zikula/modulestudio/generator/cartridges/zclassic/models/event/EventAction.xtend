package org.zikula.modulestudio.generator.cartridges.zclassic.models.event

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EventAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    String entityVar

    new(String entityVar) {
        this.entityVar = entityVar
    }

    def postLoad(Application it) '''

        $serviceManager = ServiceUtil::getManager();
        $dispatcher = ServiceUtil::get('event_dispatcher');

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $dispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_LOAD'), $event);
    '''

    def prePersist(Application it) '''
        «IF hasUploads»
            $objectType = $entity->get_objectType();
            $uploadFields = $this->getUploadFields($objectType);

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
        $dispatcher = ServiceUtil::get('event_dispatcher');

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $dispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_PERSIST'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }
    '''

    def postPersist(Application it) '''
        $serviceManager = ServiceUtil::getManager();
        $objectId = «entityVar»->createCompositeIdentifier();
        $logger = $serviceManager->get('logger');
        $logArgs = ['app' => '«appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => $objectId];
        $logger->debug('{app}: User {user} created the {entity} with id {id}.', $logArgs);

        $dispatcher = $serviceManager->get('event_dispatcher');

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $dispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_PERSIST'), $event);
    '''

    def preRemove(Application it) '''
        $serviceManager = ServiceUtil::getManager();
        $dispatcher = $serviceManager->get('event_dispatcher');

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $dispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_REMOVE'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }

        // delete workflow for this entity
        $workflowHelper = $serviceManager->get('«appService».workflow_helper');
        $workflowHelper->normaliseWorkflowData(«entityVar»);
        $workflow = «entityVar»['__WORKFLOW__'];
        if ($workflow['id'] > 0) {
            $entityManager = $serviceManager->get('«entityManagerService»');
            $result = true;
            try {
                $workflow = $entityManager->find('Zikula\Core\Doctrine\Entity\WorkflowEntity', $workflow['id']);
                $entityManager->remove($workflow);
                $entityManager->flush();
            } catch (\Exception $e) {
                $result = false;
            }
            if (false === $result) {
                $flashBag = $serviceManager->get('session')->getFlashBag();
                $flashBag->add('error', $serviceManager->get('translator.default')->__('Error! Could not remove stored workflow. Deletion has been aborted.'));

                return false;
            }
        }
    '''

    def postRemove(Application it) '''
        $serviceManager = ServiceUtil::getManager();

        $objectType = «entityVar»->get_objectType();
        $objectId = «entityVar»->createCompositeIdentifier();

        «IF hasUploads»
            // retrieve the upload handler
            $uploadManager = $serviceManager->get('«appService».upload_handler');
            $uploadFields = $this->getUploadFields($objectType);

            foreach ($uploadFields as $uploadField) {
                if (empty(«entityVar»[$uploadField])) {
                    continue;
                }

                // remove upload file
                $uploadManager->deleteUploadFile(«entityVar», $uploadField);
            }
        «ENDIF»

        $logger = $serviceManager->get('logger');
        $logArgs = ['app' => '«appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => $objectType, 'id' => $objectId];
        $logger->debug('{app}: User {user} removed the {entity} with id {id}.', $logArgs);

        $dispatcher = $serviceManager->get('event_dispatcher');

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst($objectType) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $dispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper($objectType) . '_POST_REMOVE'), $event);
    '''

    def preUpdate(Application it) '''
        «IF hasUploads»
            $objectType = $entity->get_objectType();
            $uploadFields = $this->getUploadFields($objectType);

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
        $serviceManager = ServiceUtil::getManager();
        $dispatcher = $serviceManager->get('event_dispatcher');

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $dispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_UPDATE'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }
    '''

    def postUpdate(Application it) '''
        $serviceManager = ServiceUtil::getManager();
        $objectId = «entityVar»->createCompositeIdentifier();
        $logger = $serviceManager->get('logger');
        $logArgs = ['app' => '«appName»', 'user' => $serviceManager->get('zikula_users_module.current_user')->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => $objectId];
        $logger->debug('{app}: User {user} updated the {entity} with id {id}.', $logArgs);

        $dispatcher = $serviceManager->get('event_dispatcher');

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $dispatcher->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_UPDATE'), $event);
    '''
}
