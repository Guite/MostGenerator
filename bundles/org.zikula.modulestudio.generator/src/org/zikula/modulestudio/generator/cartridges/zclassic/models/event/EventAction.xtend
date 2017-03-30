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

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $this->container->get('event_dispatcher')->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_LOAD'), $event);
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
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $this->container->get('event_dispatcher')->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_PERSIST'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }
    '''

    def postPersist(Application it) '''
        $objectId = «entityVar»->createCompositeIdentifier();
        $logger = $this->container->get('logger');
        $logArgs = ['app' => '«appName»', 'user' => $this->container->get('zikula_users_module.current_user')->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => $objectId];
        $logger->debug('{app}: User {user} created the {entity} with id {id}.', $logArgs);

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $this->container->get('event_dispatcher')->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_PERSIST'), $event);
    '''

    def preRemove(Application it) '''
        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $this->container->get('event_dispatcher')->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_REMOVE'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }
        «IF !targets('1.5')»

            // delete workflow for this entity
            $workflowHelper = $this->container->get('«appService».workflow_helper');
            $workflowHelper->normaliseWorkflowData(«entityVar»);
            $workflow = «entityVar»['__WORKFLOW__'];
            if ($workflow['id'] > 0) {
                $entityManager = $this->container->get('«entityManagerService»');«/* TODO maybe $args->getObjectManager() can be used instead */»
                $result = true;
                try {
                    $workflow = $entityManager->find('Zikula\Core\Doctrine\Entity\WorkflowEntity', $workflow['id']);
                    $entityManager->remove($workflow);
                    $entityManager->flush();
                } catch (\Exception $e) {
                    $result = false;
                }
                if (false === $result) {
                    $flashBag = $this->container->get('session')->getFlashBag();
                    $flashBag->add('error', $this->container->get('translator.default')->__('Error! Could not remove stored workflow. Deletion has been aborted.'));

                    return false;
                }
            }
        «ENDIF»
    '''

    def postRemove(Application it) '''
        $objectType = «entityVar»->get_objectType();
        $objectId = «entityVar»->createCompositeIdentifier();

        «IF hasUploads»
            $uploadHelper = $this->container->get('«appService».upload_helper');
            $uploadFields = $this->getUploadFields($objectType);
            foreach ($uploadFields as $uploadField) {
                if (empty(«entityVar»[$uploadField])) {
                    continue;
                }

                // remove upload file
                $uploadHelper->deleteUploadFile(«entityVar», $uploadField);
            }
        «ENDIF»

        $logger = $this->container->get('logger');
        $logArgs = ['app' => '«appName»', 'user' => $this->container->get('zikula_users_module.current_user')->get('uname'), 'entity' => $objectType, 'id' => $objectId];
        $logger->debug('{app}: User {user} removed the {entity} with id {id}.', $logArgs);

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst($objectType) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $this->container->get('event_dispatcher')->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper($objectType) . '_POST_REMOVE'), $event);
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
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar», $args->getEntityChangeSet());
        $this->container->get('event_dispatcher')->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_PRE_UPDATE'), $event);
        if ($event->isPropagationStopped()) {
            return false;
        }
    '''

    def postUpdate(Application it) '''
        $objectId = «entityVar»->createCompositeIdentifier();
        $logger = $this->container->get('logger');
        $logArgs = ['app' => '«appName»', 'user' => $this->container->get('zikula_users_module.current_user')->get('uname'), 'entity' => «entityVar»->get_objectType(), 'id' => $objectId];
        $logger->debug('{app}: User {user} updated the {entity} with id {id}.', $logArgs);

        // create the filter event and dispatch it
        $filterEventClass = '\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Event\\Filter' . ucfirst(«entityVar»->get_objectType()) . 'Event';
        $event = new $filterEventClass(«entityVar»);
        $this->container->get('event_dispatcher')->dispatch(constant('\\«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\«name.formatForCodeCapital»Events::' . strtoupper(«entityVar»->get_objectType()) . '_POST_UPDATE'), $event);
    '''
}
