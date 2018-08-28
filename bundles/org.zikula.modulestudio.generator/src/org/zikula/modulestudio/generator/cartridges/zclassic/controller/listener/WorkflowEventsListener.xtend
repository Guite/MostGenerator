package org.zikula.modulestudio.generator.cartridges.zclassic.controller.listener

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class WorkflowEventsListener {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it) '''
        /**
         * @var EntityFactory
         */
        protected $entityFactory;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;
        «IF needsApproval»

            /**
             * @var NotificationHelper
             */
            protected $notificationHelper;
        «ENDIF»

        /**
         * WorkflowEventsListener constructor.
         *
         * @param EntityFactory $entityFactory EntityFactory service instance
         * @param PermissionHelper $permissionHelper PermissionHelper service instance
         «IF needsApproval»
         * @param NotificationHelper $notificationHelper NotificationHelper service instance
         «ENDIF»
         */
        public function __construct(
            EntityFactory $entityFactory,
            PermissionHelper $permissionHelper«IF needsApproval»,
            NotificationHelper $notificationHelper«ENDIF»)
        {
            $this->entityFactory = $entityFactory;
            $this->permissionHelper = $permissionHelper;
            «IF needsApproval»
                $this->notificationHelper = $notificationHelper;
            «ENDIF»
        }

        /**
         * Makes our handlers known to the event system.
         */
        public static function getSubscribedEvents()
        {
            return [
                'workflow.guard' => ['onGuard', 5],
                'workflow.leave' => ['onLeave', 5],
                «IF targets('2.0')»
                    'workflow.entered' => ['onEntered', 5],
                «ENDIF»
                'workflow.transition' => ['onTransition', 5],
                'workflow.enter' => ['onEnter', 5]«IF targets('2.0')»,«ENDIF»
                «IF targets('2.0')»
                    'workflow.completed' => ['onCompleted', 5],
                    'workflow.announce' => ['onAnnounce', 5]
                «ENDIF»
            ];
        }

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
         «exampleCode»
         * Example for preventing a transition:
         *     `if (!$event->isBlocked()) {
         *         $event->setBlocked(true);
         *     }`
         *
         * @param GuardEvent $event The event instance
         */
        public function onGuard(GuardEvent $event)
        {
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                return;
            }

            $objectType = $entity->get_objectType();
            $permissionLevel = ACCESS_READ;
            $transitionName = $event->getTransition()->getName();
            «IF !targets('2.0')»
                if (substr($transitionName, 0, 6) == 'update') {
                    $transitionName = 'update';
                }
            «ENDIF»
            «/*not used atm $targetState = $event->getTransition()->getTos()[0];*/»
            $hasApproval = «IF needsApproval»in_array($objectType, ['«getAllEntities.filter[workflow != EntityWorkflowType.NONE].map[name.formatForCode].join('\', \'')»'])«ELSE»false«ENDIF»;

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
                    «IF !getAllEntities.filter[ownerPermission].empty»
                        $permissionLevel = in_array($objectType, ['«getAllEntities.filter[ownerPermission].map[name.formatForCode].join('\', \'')»']) ? ACCESS_EDIT : ACCESS_DELETE;
                    «ELSE»
                        $permissionLevel = ACCESS_DELETE;
                    «ENDIF»
                    break;
            }

            if (!$this->permissionHelper->hasEntityPermission($entity, $permissionLevel)) {
                // no permission for this transition, so disallow it
                $event->setBlocked(true);

                return;
            }
            «IF !getJoinRelations.empty && !getAllEntities.filter[!getOutgoingJoinRelationsWithoutDeleteCascade.empty].empty»

                if ($transitionName == 'delete') {
                    // check if deleting the entity would break related child entities
                    «FOR entity : getAllEntities.filter[!getOutgoingJoinRelationsWithoutDeleteCascade.empty]»
                        if ($objectType == '«entity.name.formatForCode»') {
                            $isBlocked = false;
                            «FOR relation : entity.getOutgoingJoinRelationsWithoutDeleteCascade»
                                «IF relation.isManySide(true)»
                                    if (count($entity->get«relation.targetAlias.formatForCodeCapital»()) > 0) {
                                        $isBlocked = true;
                                    }
                                «ELSE»
                                    if (null !== $entity->get«relation.targetAlias.formatForCodeCapital»()) {
                                        $isBlocked = true;
                                    }
                                «ENDIF»
                            «ENDFOR»
                            $event->setBlocked($isBlocked);
                        }
                    «ENDFOR»
                }
            «ENDIF»
        }

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
         «exampleCode»
         *
         * @param Event $event The event instance
         */
        public function onLeave(Event $event)
        {
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                return;
            }
        }
        «IF targets('2.0')»

            /**
             * Listener for the `workflow.entered` event.
             *
             * Occurs just before the object enters into the new state.
             * Carries the marking with the new places.
             * This is a good place to flush data in Doctrine based on the entity not being updated yet.
             *
             * This event is also triggered for each workflow individually, so you can react only to the events
             * of a specific workflow by listening to `workflow.<workflow_name>.entered` instead.
             * You can even listen to some specific transitions or states for a specific workflow
             * using `workflow.<workflow_name>.entered.<state_name>`.
             *
             «exampleCode»
             *
             * @param Event $event The event instance
             */
            public function onEntered(Event $event)
            {
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
            }
        «ENDIF»

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
         «exampleCode»
         *
         * @param Event $event The event instance
         */
        public function onTransition(Event $event)
        {
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                return;
            }
        }

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
         «exampleCode»
         *
         * @param Event $event The event instance
         */
        public function onEnter(Event $event)
        {
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
        }
        «IF targets('2.0')»

            /**
             * Listener for the `workflow.completed` event.
             *
             * Occurs after the object has completed a transition.
             *
             * This event is also triggered for each workflow individually, so you can react only to the events
             * of a specific workflow by listening to `workflow.<workflow_name>.completed` instead.
             * You can even listen to some specific transitions or states for a specific workflow
             * using `workflow.<workflow_name>.completed.<state_name>`.
             *
             «exampleCode»
             *
             * @param Event $event The event instance
             */
            public function onCompleted(Event $event)
            {
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
            }

            /**
             * Listener for the `workflow.announce` event.
             *
             * Triggered for each place that now is available for the object.
             *
             * This event is also triggered for each workflow individually, so you can react only to the events
             * of a specific workflow by listening to `workflow.<workflow_name>.announce` instead.
             * You can even listen to some specific transitions or states for a specific workflow
             * using `workflow.<workflow_name>.announce.<state_name>`.
             *
             «exampleCode»
             *
             * @param Event $event The event instance
             */
            public function onAnnounce(Event $event)
            {
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
            }
        «ENDIF»

        «isEntityManagedByThisBundle»
        «IF needsApproval»

            «sendNotifications»
        «ENDIF»
    '''

    def private exampleCode(Application it) '''
        «new CommonExample().generalEventProperties(it, false)»
        * Access the entity: `$entity = $event->getSubject();`
        * Access the marking: `$marking = $event->getMarking();`
        * Access the transition: `$transition = $event->getTransition();`
        «IF targets('2.0')»
            * Access the workflow name: `$workflowName = $event->getWorkflowName();`
        «ENDIF»
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
