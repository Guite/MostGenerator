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

        public function __construct(
            EntityFactory $entityFactory,
            PermissionHelper $permissionHelper«IF needsApproval»,
            NotificationHelper $notificationHelper«ENDIF»
        ) {
            $this->entityFactory = $entityFactory;
            $this->permissionHelper = $permissionHelper;
            «IF needsApproval»
                $this->notificationHelper = $notificationHelper;
            «ENDIF»
        }

        public static function getSubscribedEvents()
        {
            return [
                'workflow.guard' => ['onGuard', 5],
                'workflow.leave' => ['onLeave', 5],
                'workflow.transition' => ['onTransition', 5],
                'workflow.enter' => ['onEnter', 5]«IF targets('2.0')»,«ENDIF»
                «IF targets('2.0')»
                    'workflow.entered' => ['onEntered', 5],
                    'workflow.completed' => ['onCompleted', 5],
                    'workflow.announce' => ['onAnnounce', 5]
                «ENDIF»
            ];
        }

        /**
         * Listener for the `workflow.guard` event.
         *
         * Occurs before a transition is started and when testing which transitions are available.
         * Validates whether the transition is allowed or not.
         * Allows to block it by calling `$event->setBlocked(true);`.
         «commonDocs('guard')»
         * Example for preventing a transition:
         *     `if (!$event->isBlocked()) {
         *         $event->setBlocked(true);
         *     }`
         */
        public function onGuard(GuardEvent $event)«IF targets('3.0')»: void«ENDIF»
        {
            «guardImpl»
        }

        /**
         * Listener for the `workflow.leave` event.
         *
         * Occurs after a subject has left it's current state.
         * Carries the marking with the initial places.
         «commonDocs('leave')»
         */
        public function onLeave(Event $event)«IF targets('3.0')»: void«ENDIF»
        {
            /** @var EntityAccess $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                return;
            }
        }

        /**
         * Listener for the `workflow.transition` event.
         *
         * Occurs before starting to transition to the new state.
         * Carries the marking with the current places.
         «commonDocs('transition')»
         */
        public function onTransition(Event $event)«IF targets('3.0')»: void«ENDIF»
        {
            /** @var EntityAccess $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                return;
            }
        }

        /**
         * Listener for the `workflow.enter` event.
         *
         * Occurs before the subject enters into the new state and places are updated.
         * This means the marking of the subject is not yet updated with the new places.
         «commonDocs('enter')»
         */
        public function onEnter(Event $event)«IF targets('3.0')»: void«ENDIF»
        {
            /** @var EntityAccess $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                return;
            }
            «IF !targets('2.0')»
                «sendNotificationsCall»
            «ENDIF»
        }
        «IF targets('2.0')»

            /**
             * Listener for the `workflow.entered` event.
             *
             * Occurs after the subject has entered into the new state.
             * Carries the marking with the new places.
             * This is a good place to flush data in Doctrine based on the entity not being updated yet.
             «commonDocs('entered')»
             */
            public function onEntered(Event $event)«IF targets('3.0')»: void«ENDIF»
            {
                /** @var EntityAccess $entity */
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
            }

            /**
             * Listener for the `workflow.completed` event.
             *
             * Occurs after the subject has completed a transition.
             «commonDocs('completed')»
             */
            public function onCompleted(Event $event)«IF targets('3.0')»: void«ENDIF»
            {
                /** @var EntityAccess $entity */
                $entity = $event->getSubject();
                if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                    return;
                }
                «sendNotificationsCall»
            }

            /**
             * Listener for the `workflow.announce` event.
             *
             * Triggered for each place that now is available for the subject.
             «commonDocs('announce')»
             */
            public function onAnnounce(Event $event)«IF targets('3.0')»: void«ENDIF»
            {
                /** @var EntityAccess $entity */
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

    def private sendNotificationsCall(Application it) '''
        «IF needsApproval»

            $workflowShortName = 'none';
            if (in_array($entity->get_objectType(), ['«getAllEntities.filter[workflow == EntityWorkflowType.STANDARD].map[name.formatForCode].join('\', \'')»'])) {
                $workflowShortName = 'standard';
            } elseif (in_array($entity->get_objectType(), ['«getAllEntities.filter[workflow == EntityWorkflowType.ENTERPRISE].map[name.formatForCode].join('\', \'')»'])) {
                $workflowShortName = 'enterprise';
            }
            if ('none' != $workflowShortName) {
                $this->sendNotifications($entity, $event->getTransition()->getName(), $workflowShortName);
            }
        «ENDIF»
    '''

    def private commonDocs(Application it, String eventName) '''
         *
         * This event is also triggered for each workflow individually, so you can react only to the events
         * of a specific workflow by listening to `workflow.<workflow_name>.«eventName»` instead.
         * You can even listen to some specific transitions or states for a specific workflow
         * using `workflow.<workflow_name>.«eventName».<state_name>`.
         *
         «exampleCode»
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

    def private guardImpl(Application it) '''
        /** @var EntityAccess $entity */
        $entity = $event->getSubject();
        if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
            return;
        }

        $objectType = $entity->get_objectType();
        $permissionLevel = ACCESS_READ;
        $transitionName = $event->getTransition()->getName();
        «IF !targets('2.0')»
            if ('update' === substr($transitionName, 0, 6)) {
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

            if ('delete' === $transitionName) {
                // check if deleting the entity would break related child entities
                «FOR entity : getAllEntities.filter[!getOutgoingJoinRelationsWithoutDeleteCascade.empty]»
                    if ('«entity.name.formatForCode»' === $objectType) {
                        $isBlocked = false;
                        «FOR relation : entity.getOutgoingJoinRelationsWithoutDeleteCascade»
                            «IF relation.isManySide(true)»
                                if (0 < count($entity->get«relation.targetAlias.formatForCodeCapital»())) {
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
    '''

    def private isEntityManagedByThisBundle(Application it) '''
        /**
         * Checks whether this listener is responsible for the given entity or not.
         *
         * @param EntityAccess $entity The given entity
         «IF !targets('3.0')»
         *
         * @return bool True if entity is managed by this listener, false otherwise
         «ENDIF»
         */
        protected function isEntityManagedByThisBundle($entity)«IF targets('3.0')»: bool«ENDIF»
        {
            if (!($entity instanceof EntityAccess)) {
                return false;
            }

            $entityClassParts = explode('\\', get_class($entity));

            if ('DoctrineProxy' === $entityClassParts[0] && '__CG__' === $entityClassParts[1]) {
                array_shift($entityClassParts);
                array_shift($entityClassParts);
            }

            return '«vendor.formatForCodeCapital»' === $entityClassParts[0] && '«name.formatForCodeCapital»Module' === $entityClassParts[1];
        }
    '''

    def private sendNotifications(Application it) '''
        /**
         * Sends email notifications.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity Processed entity
         * @param string $actionId Name of performed transition
         * @param string $workflowShortName Name of workflow (none, standard, enterprise)
         «ENDIF»
         */
        protected function sendNotifications($entity, «IF targets('3.0')»string «ENDIF»$actionId, «IF targets('3.0')»string «ENDIF»$workflowShortName)«IF targets('3.0')»: void«ENDIF»
        {
            $newState = $entity->getWorkflowState();

            // by default send only to creator
            $sendToCreator = true;
            $sendToModerator = false;
            $sendToSuperModerator = false;
            if (
                'submit' === $actionId && 'waiting' === $newState
                || 'demote' === $actionId && 'accepted' === $newState
            ) {
                // only to moderator
                $sendToCreator = false;
                $sendToModerator = true;
            } elseif ('accept' === $actionId && 'accepted' === $newState) {
                // to creator and super moderator
                $sendToSuperModerator = true;
            } elseif ('approve' === $actionId && 'approved' === $newState && 'enterprise' === $workflowShortName) {
                // to creator and moderator
                $sendToModerator = true;
            } elseif ('update' === $actionId && 'waiting' === $newState) {
                // only to moderator
                $sendToCreator = false;
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
