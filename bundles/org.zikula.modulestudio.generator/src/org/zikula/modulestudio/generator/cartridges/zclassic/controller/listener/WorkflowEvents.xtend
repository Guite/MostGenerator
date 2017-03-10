package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class WorkflowEvents {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * @var PermissionApiInterface
             */
            protected $permissionApi;
            «IF needsApproval»

                /**
                 * @var NotificationHelper
                 */
                protected $notificationHelper;
            «ENDIF»

            /**
             * WorkflowEventsListener constructor.
             *
             * @param PermissionApiInterface $permissionApi «IF needsApproval»     «ENDIF»PermissionApi service instance
             «IF needsApproval»
             * @param NotificationHelper     $notificationHelper NotificationHelper service instance
             «ENDIF»
             */
            public function __construct(PermissionApiInterface $permissionApi«IF needsApproval», NotificationHelper $notificationHelper«ENDIF»)
            {
                $this->permissionApi = $permissionApi;
                «IF needsApproval»
                    $this->notificationHelper = $notificationHelper;
                «ENDIF»
            }

            /**
             * Makes our handlers known to the event system.
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public static function getSubscribedEvents()
        {
            «IF isBase»
                return [
                    'workflow.guard' => ['onGuard', 5],
                    'workflow.leave' => ['onLeave', 5],
                    'workflow.transition' => ['onTransition', 5],
                    'workflow.enter' => ['onEnter', 5]«/* Starting from Symfony 3.3.0 there is also 'workflow.entered' available which is fired after the marking has been set */»
                ];
            «ELSE»
                return parent::getSubscribedEvents();
            «ENDIF»
        }

        «IF isBase»
            /**
             * Listener for the `workflow.guard` event.
             *
             * Occurs just before a transition is started and when testing which transitions are available.
             * Allows to define that the transition is not allowed by calling `$event->setBlocked(true);`.
             *
             * This event is also triggered for each workflow individually, so you can react only to the events
             * of a specific workflow by listening to `workflow.<workflow_name>.guard` instead.
             * You can even listen to some specific transitions or states for a specific workflow
             * using `workflow.<workflow_name>.guard.<transition_name>`.
             *
             * @param GuardEvent $event The event instance
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function onGuard(GuardEvent $event)
        {
            «IF isBase»
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }

                $permissionLevel = ACCESS_READ;
                $transitionName = $event->getTransition()->getName();
                if (substr($transitionName, 0, 6) == 'update') {
                    $transitionName = 'update';
                }
                $targetState = $event->getTransition()->getTos()[0];
                $hasApproval = «IF needsApproval»in_array($entity->get_objectType(), ['«getAllEntities.filter[workflow != EntityWorkflowType.NONE].map[name.formatForCode].join('\', \'')»'])«ELSE»false«ENDIF»;

                switch ($transitionName) {
                    case 'defer':
                    case 'submit':
                        $permissionLevel = $hasApproval ? ACCESS_COMMENT : ACCESS_EDIT;
                        break;
                    case 'update':
                    case 'reject':
                    case 'accept':
                    case 'publish':
                    case 'unpublish':
                    case 'archive':
                    case 'trash':
                    case 'recover':
                        $permissionLevel = ACCESS_EDIT;
                        break;
                    case 'approve':
                    case 'demote':
                        $permissionLevel = ACCESS_ADD;
                        break;
                    case 'delete':
                        $permissionLevel = ACCESS_DELETE;
                        break;
                }


                $instanceId = $entity->createCompositeIdentifier();
                if (!$this->permissionApi->hasPermission('«appName»:' . ucfirst($entity->get_objectType()) . ':', $instanceId . '::', $permissionLevel)) {
                    // no permission for this transition, so disallow it
                    $event->setBlocked(true);
                }
            «ELSE»
                parent::onGuard($event);

                «exampleCode»

                // example for preventing a transition
                // if (!$event->isBlocked()) {
                //     $event->setBlocked(true);
                // }
            «ENDIF»
        }

        «IF isBase»
            /**
             * Listener for the `workflow.leave` event.
             *
             * Occurs just after an object has left it's current state.
             * Carries the marking with the initial places.
             *
             * This event is also triggered for each workflow individually, so you can react only to the events
             * of a specific workflow by listening to `workflow.<workflow_name>.leave` instead.
             * You can even listen to some specific transitions or states for a specific workflow
             * using `workflow.<workflow_name>.leave.<state_name>`.
             *
             * @param Event $event The event instance
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function onLeave(Event $event)
        {
            «IF isBase»
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
            «ELSE»
                parent::onLeave($event);

                «exampleCode»
            «ENDIF»
        }

        «IF isBase»
            /**
             * Listener for the `workflow.transition` event.
             *
             * Occurs just before starting to transition to the new state.
             * Carries the marking with the current places.
             *
             * This event is also triggered for each workflow individually, so you can react only to the events
             * of a specific workflow by listening to `workflow.<workflow_name>.transition` instead.
             * You can even listen to some specific transitions or states for a specific workflow
             * using `workflow.<workflow_name>.transition.<transition_name>`.
             *
             * @param Event $event The event instance
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function onTransition(Event $event)
        {
            «IF isBase»
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
            «ELSE»
                parent::onTransition($event);

                «exampleCode»
            «ENDIF»
        }

        «IF isBase»
            /**
             * Listener for the `workflow.enter` event.
             *
             * Occurs just after the object has entered into the new state.
             * Carries the marking with the new places.
             *
             * This event is also triggered for each workflow individually, so you can react only to the events
             * of a specific workflow by listening to `workflow.<workflow_name>.enter` instead.
             * You can even listen to some specific transitions or states for a specific workflow
             * using `workflow.<workflow_name>.enter.<state_name>`.
             *
             * @param Event $event The event instance
             */
        «ELSE»
            /**
             * @inheritDoc
             */
        «ENDIF»
        public function onEnter(Event $event)
        {
            «IF isBase»
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
                «IF needsApproval»

                    $workflowShortName = 'none';
                    if (in_array($entity->get_objectType(), ['«getAllEntities.filter[workflow == EntityWorkflowType.STANDARD].map[name.formatForCode].join('\', \'')»'])) {
                        $workflowShortName = 'standard';
                    } elseif (in_array($entity->get_objectType(), ['«getAllEntities.filter[workflow == EntityWorkflowType.ENTERPRISE].map[name.formatForCode].join('\', \'')»'])) {
                        $workflowShortName = 'enterprise';
                    }
                    if ($workflowShortName != 'none') {
                        $this->sendNotifications($entity, $event->getTransition()->getName(), $workflowShortName);
                    }
                «ENDIF»
            «ELSE»
                parent::onEnter($event);

                «exampleCode»
            «ENDIF»
        }
        «IF isBase»

            «isEntityManagedByThisBundle»
            «IF needsApproval»

                «sendNotifications»
            «ENDIF»
        «ENDIF»
    '''

    def private exampleCode(Application it) '''
        «new CommonExample().generalEventProperties(it)»

        // access the entity
        // $entity = $event->getSubject();

        // access the marking
        // $entity = $event->getMarking();

        // access the transition
        // $entity = $event->getTransition();

        // starting from Symfony 3.3.0 you can also access the workflow name
        // $workflowName = $event->getWorkflowName();
    '''

    def private isEntityManagedByThisBundle(Application it) '''
        /**
         * Checks whether this listener is responsible for the given entity or not.
         *
         * @param EntityAccess $entity The given entity
         *
         * @return boolean True if entity is managed by this listener, false otherwise
         */
        protected function isEntityManagedByThisBundle($entity)
        {
            if (!($entity instanceof EntityAccess)) {
                return false;
            }

            $entityClassParts = explode('\\', get_class($entity));

            return ($entityClassParts[0] == '«vendor.formatForCodeCapital»' && $entityClassParts[1] == '«name.formatForCodeCapital»Module');
        }
    '''

    def private sendNotifications(Application it) '''
        /**
         * Sends email notifications.
         *
         * @param object $entity            Processed entity
         * @param string $actionId          Name of performed transition
         * @param string $workflowShortName Name of workflow (none, standard, enterprise)
         */
        protected function sendNotifications($entity, $actionId, $workflowShortName)
        {
            $newState = $entity->getWorkflowState();

            // by default send only to creator
            $sendToCreator = true;
            $sendToModerator = false;
            $sendToSuperModerator = false;
            if ($actionId == 'submit' && $newState == 'waiting'
                || $actionId == 'demote' && $newState == 'accepted') {
                // only to moderator
                $sendToCreator = false;
                $sendToModerator = true;
            } elseif ($actionId == 'accept' && $newState == 'accepted') {
                // to creator and super moderator
                $sendToSuperModerator = true;
            } elseif ($actionId == 'approve' && $newState == 'approved' && $workflowShortName == 'enterprise') {
                // to creator and moderator
                $sendToModerator = true;
            }
            $recipientTypes = [];
            if (true === $sendToCreator) {
                $recipientTypes[] = 'creator';
            }
            if (true === $sendToModerator) {
                $recipientTypes[] = 'moderator';
            }
            if (true === $sendToSuperModerator) {
                $recipientTypes[] = 'superModerator';
            }

            foreach ($recipientTypes as $recipientType) {
                $notifyArgs = [
                    'recipientType' => $recipientType,
                    'action' => $actionId,
                    'entity' => $entity
                ];
                $result = $this->notificationHelper->process($notifyArgs);
            }

            // example for custom recipient type using designated entity fields:
            // recipientType => 'field-email^lastname'
        }
    '''
}
