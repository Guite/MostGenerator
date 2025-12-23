package org.zikula.modulestudio.generator.cartridges.symfony.controller.subscriber

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class WorkflowSubscriber {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it) '''
        public function __construct(
            protected readonly TranslatorInterface $translator,
            protected readonly PermissionHelper $permissionHelper,
            «IF needsApproval»
                protected readonly NotificationHelper $notificationHelper,
            «ENDIF»
        ) {
        }

        public static function getSubscribedEvents(): array
        {
            return [
                WorkflowEvents::GUARD => 'onGuard',
                WorkflowEvents::LEAVE => 'onLeave',
                WorkflowEvents::TRANSITION => 'onTransition',
                WorkflowEvents::ENTER => 'onEnter',
                WorkflowEvents::ENTERED => 'onEntered',
                WorkflowEvents::COMPLETED => 'onCompleted',
                WorkflowEvents::ANNOUNCE => 'onAnnounce',
            ];
        }

        /**
         * Subscriber for the `workflow.guard` event.
         *
         * Occurs before a transition is started and when testing which transitions are available.
         * Validates whether the transition is allowed or not.
         * Allows to block it by calling `$event->setBlocked(true);`.
         «commonDocs('guard')»
         * Example for preventing a transition:
         *     `if (!$event->isBlocked()) {
         *         $event->setBlocked(true);
         *     }`
         * Example with providing a reason:
         *     `$event->addTransitionBlocker(
         *         new TransitionBlocker('You can not this because that.', '0')
         *     );`
         */
        public function onGuard(GuardEvent $event): void
        {
            «guardImpl»
        }

        /**
         * Subscriber for the `workflow.leave` event.
         *
         * Occurs after a subject has left it's current state.
         * Carries the marking with the initial places.
         «commonDocs('leave')»
         */
        public function onLeave(LeaveEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `workflow.transition` event.
         *
         * Occurs before starting to transition to the new state.
         * Carries the marking with the current places.
         «commonDocs('transition')»
         */
        public function onTransition(TransitionEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `workflow.enter` event.
         *
         * Occurs before the subject enters into the new state and places are updated.
         * This means the marking of the subject is not yet updated with the new places.
         «commonDocs('enter')»
         */
        public function onEnter(EnterEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `workflow.entered` event.
         *
         * Occurs after the subject has entered into the new state.
         * Carries the marking with the new places.
         * This is a good place to flush data in Doctrine based on the entity not being updated yet.
         «commonDocs('entered')»
         */
        public function onEntered(EnteredEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        /**
         * Subscriber for the `workflow.completed` event.
         *
         * Occurs after the subject has completed a transition.
         «commonDocs('completed')»
         */
        public function onCompleted(CompletedEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
                return;
            }
            «sendNotificationsCall»
        }

        /**
         * Subscriber for the `workflow.announce` event.
         *
         * Triggered for each place that now is available for the subject.
         «commonDocs('announce')»
         */
        public function onAnnounce(AnnounceEvent $event): void
        {
            /** @var EntityInterface $entity */
            $entity = $event->getSubject();
            if (!$this->isEntityManagedByThisBundle($entity)) {
                return;
            }
        }

        «isEntityManagedByThisBundle»
        «IF needsApproval»

            «sendNotifications»
        «ENDIF»
    '''

    def private sendNotificationsCall(Application it) '''
        «IF needsApproval»

            $workflowShortName = 'none';
            if (in_array($entity->get_objectType(), ['«entities.filter[approval].map[name.formatForCode].join('\', \'')»'], true)) {
                $workflowShortName = 'standard';
            }
            if ('none' !== $workflowShortName) {
                $action = $event->getTransition()->getName();
                $mayApprove = $this->permissionHelper->hasEntityPermission($entity/*, ACCESS_ADD*/);
                $needsNotification = 'submit' !== $action || !$mayApprove;
                if ($needsNotification) {
                    $this->sendNotifications($entity, $action, $workflowShortName);
                }
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
        * Access the workflow name: `$workflowName = $event->getWorkflowName();`
    '''

    def private guardImpl(Application it) '''
        /** @var EntityInterface $entity */
        $entity = $event->getSubject();
        if (!$this->isEntityManagedByThisBundle($entity) || !method_exists($entity, 'get_objectType')) {
            return;
        }

        «IF needsApproval || !entities.filter[ownerPermission].empty || (!relations.empty && !entities.filter[!getOutgoingRelationsWithoutDeleteCascade.empty].empty)»
            $objectType = $entity->get_objectType();
        «ENDIF»
        $permissionLevel = ACCESS_READ;
        $transitionName = $event->getTransition()->getName();
        «/*not used atm $targetState = $event->getTransition()->getTos()[0];*/»
        $hasApproval = «IF needsApproval»in_array($objectType, ['«entities.filter[approval].map[name.formatForCode].join('\', \'')»'], true)«ELSE»false«ENDIF»;

        switch ($transitionName) {
            case 'defer':
            case 'submit':
                $permissionLevel = $hasApproval ? ACCESS_COMMENT : ACCESS_EDIT;
                break;
            case 'update':
            case 'reject':
            case 'accept':
            case 'archive':
                $permissionLevel = ACCESS_EDIT;
                break;
            case 'approve':
            case 'demote':
                $permissionLevel = ACCESS_ADD;
                break;
            case 'delete':
                «IF !entities.filter[ownerPermission].empty»
                    $permissionLevel = in_array($objectType, ['«entities.filter[ownerPermission].map[name.formatForCode].join('\', \'')»'], true) ? ACCESS_EDIT : ACCESS_DELETE;
                «ELSE»
                    $permissionLevel = ACCESS_DELETE;
                «ENDIF»
                break;
        }

        if (!$this->permissionHelper->hasEntityPermission($entity/*, $permissionLevel*/)) {
            // no permission for this transition, so disallow it
            $event->setBlocked(true, $this->translator->trans('No permission for this action.'));

            return;
        }
        «IF !relations.empty && !entities.filter[!getOutgoingRelationsWithoutDeleteCascade.empty].empty»

            if ('delete' === $transitionName) {
                // check if deleting the entity would break related child entities
                «FOR entity : entities.filter[!getOutgoingRelationsWithoutDeleteCascade.empty]»
                    if ('«entity.name.formatForCode»' === $objectType) {
                        $isBlocked = false;
                        «FOR relation : entity.getOutgoingRelationsWithoutDeleteCascade»
                            «IF relation.isManySide(true)»
                                if (null !== $entity->get«relation.targetAlias.formatForCodeCapital»() && 0 < count($entity->get«relation.targetAlias.formatForCodeCapital»())) {
                                    $event->addTransitionBlocker(
                                        new TransitionBlocker(
                                            $this->translator->trans('Sorry, but you can not delete the «entity.name.formatForDisplay» yet as it still contains «relation.targetAlias.formatForDisplay»!', [], '«entity.name.formatForCode»'),
                                            '0'
                                        )
                                    );
                                    $isBlocked = true;
                                }
                            «ELSE»
                                if (null !== $entity->get«relation.targetAlias.formatForCodeCapital»()) {
                                    $event->addTransitionBlocker(
                                        new TransitionBlocker(
                                            $this->__('Sorry, but you can not delete the «entity.name.formatForDisplay» yet as it still contains a «relation.targetAlias.formatForDisplay»!', [], '«entity.name.formatForCode»'),
                                            '0'
                                        )
                                    );
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
         * Checks whether this subscriber is responsible for the given entity or not.
         */
        protected function isEntityManagedByThisBundle(object $entity): bool
        {
            return $entity instanceof EntityInterface;
        }
    '''

    def private sendNotifications(Application it) '''
        /**
         * Sends email notifications.
         */
        protected function sendNotifications($entity, string $action, string $workflowShortName): void
        {
            $newState = $entity->getWorkflowState();

            // by default send only to creator
            $sendToCreator = true;
            $sendToModerator = false;
            $sendToSuperModerator = false;
            if (
                'submit' === $action && 'waiting' === $newState
                || 'demote' === $action && 'accepted' === $newState
            ) {
                // only to moderator
                $sendToCreator = false;
                $sendToModerator = true;
            } elseif ('accept' === $action && 'accepted' === $newState) {
                // to creator and super moderator
                $sendToSuperModerator = true;
            } elseif ('approve' === $action && 'approved' === $newState && 'enterprise' === $workflowShortName) {
                // to creator and moderator
                $sendToModerator = true;
            } elseif ('update' === $action && 'waiting' === $newState) {
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
                    'action' => $action,
                    'entity' => $entity,
                ];
                $result = $this->notificationHelper->process($notifyArgs);
            }

            // example for custom recipient type using designated entity fields:
            // recipientType => 'field-email^lastname'
        }
    '''
}
