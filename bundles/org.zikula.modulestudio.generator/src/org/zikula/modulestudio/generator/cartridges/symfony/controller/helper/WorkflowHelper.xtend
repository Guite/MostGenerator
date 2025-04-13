package org.zikula.modulestudio.generator.cartridges.symfony.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ListFieldItem
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class WorkflowHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for workflows'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/WorkflowHelper.php', workflowFunctionsBaseImpl, workflowFunctionsImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Exception',
            'Psr\\Log\\LoggerInterface',
            'RuntimeException',
            'Symfony\\Component\\Workflow\\Registry',
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            'Zikula\\UsersBundle\\Api\\ApiInterface\\CurrentUserApiInterface',
            appNamespace + '\\Entity\\EntityInterface',
            appNamespace + '\\Entity\\Factory\\EntityFactory',
            appNamespace + '\\Helper\\ListEntriesHelper',
            appNamespace + '\\Helper\\PermissionHelper'
        ])
        imports
    }

    def private workflowFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «collectBaseImports.print»

        /**
         * Helper base class for workflow methods.
         */
        abstract class AbstractWorkflowHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        public function __construct(
            protected readonly TranslatorInterface $translator,
            protected readonly Registry $workflowRegistry,
            protected readonly LoggerInterface $logger,
            protected readonly CurrentUserApiInterface $currentUserApi,
            protected readonly EntityFactory $entityFactory,
            protected readonly ListEntriesHelper $listEntriesHelper,
            protected readonly PermissionHelper $permissionHelper
        ) {
        }

        «getObjectStates»

        «getStateInfo»

        «getActionsForObject»

        «executeAction»
        «IF needsApproval»

            «collectAmountOfModerationItems»

            «getAmountOfModerationItems»
        «ENDIF»
    '''

    def private getObjectStates(Application it) '''
       /**
        * This method returns a list of possible object states.
        */
       public function getObjectStates(): array
       {
           $states = [];
           «val states = getRequiredStateList»
           «FOR state : states»
               «stateInfo(state)»
           «ENDFOR»

           return $states;
       }
    '''

    def private stateInfo(Application it, ListFieldItem item) '''
        $states[] = [
            'value' => '«item.value»',
            'text' => $this->translator->trans('«item.name»'),
            'ui' => '«uiFeedback(item)»',
        ];
    '''

    def private uiFeedback(Application it, ListFieldItem item) {
        item.stateLabel
    }

    def private stateLabel(ListFieldItem it) {
        switch it.value {
            case 'initial': 'danger'
            case 'deferred': 'danger'
            case 'waiting': 'warning'
            case 'approved': 'success'
            case 'archived': 'info'
            case 'deleted': 'danger'
            default: 'default'
        }
    }

    def private getStateInfo(Application it) '''
        /**
         * This method returns information about a certain state.
         */
        public function getStateInfo(string $state = 'initial'): ?array
        {
            $result = null;
            $stateList = $this->getObjectStates();
            foreach ($stateList as $singleState) {
                if ($singleState['value'] !== $state) {
                    continue;
                }
                $result = $singleState;
                break;
            }

            return $result;
        }
    '''

    def private getActionsForObject(Application it) '''
        /**
         * Retrieve the available actions for a given entity object.
         */
        public function getActionsForObject(EntityInterface $entity): array
        {
            $workflow = $this->workflowRegistry->get($entity);
            $wfActions = $workflow->getEnabledTransitions($entity);
            $currentState = $entity->getWorkflowState();

            $actions = [];
            foreach ($wfActions as $action) {
                $actionId = $action->getName();
                $actions[$actionId] = [
                    'id' => $actionId,
                    'title' => $this->getTitleForAction($currentState, $actionId),
                    'buttonClass' => $this->getButtonClassForAction($actionId),
                ];
            }

            return $actions;
        }

        /**
         * Returns a translatable title for a certain action.
         */
        protected function getTitleForAction(string $currentState, string $actionId): string
        {
            $title = '';
            switch ($actionId) {
                «IF hasWorkflowState('deferred')»
                    case 'defer':
                        $title = $this->translator->trans('Defer');
                        break;
                «ENDIF»
                case 'submit':
                    $title = $this->translator->trans('Submit');
                    break;
                «IF hasWorkflowState('deferred')»
                    case 'reject':
                        $title = $this->translator->trans('Reject');
                        break;
                «ENDIF»
                «IF hasWorkflowState('accepted')»
                    case 'accept':
                        $title = $currentState == 'initial' ? $this->translator->trans('Submit and accept') : $this->translator->trans('Accept');
                        break;
                «ENDIF»
                «IF needsApproval»
                    case 'approve':
                        $title = 'initial' === $currentState
                            ? $this->translator->trans('Submit and approve')
                            : $this->translator->trans('Approve')
                        ;
                        break;
                    case 'demote':
                        $title = $this->translator->trans('Demote');
                        break;
                «ENDIF»
                «IF hasWorkflowState('archived')»
                    case 'archive':
                        $title = $this->translator->trans('Archive');
                        break;
                    case 'unarchive':
                        $title = $this->translator->trans('Unarchive');
                        break;
                «ENDIF»
                case 'delete':
                    $title = $this->translator->trans('Delete');
                    break;
            }

            if ('' === $title) {
                if ('update' === $actionId) {
                    $title = $this->translator->trans('Update');
                } elseif ('trash' === $actionId) {
                    $title = $this->translator->trans('Trash');
                } elseif ('recover' === $actionId) {
                    $title = $this->translator->trans('Recover');
                }
            }

            return $title;
        }

        /**
         * Returns a button class for a certain action.
         */
        protected function getButtonClassForAction(string $actionId): string
        {
            $buttonClass = '';
            switch ($actionId) {
                «IF hasWorkflowState('deferred')»
                    case 'defer':
                        $buttonClass = '';
                        break;
                «ENDIF»
                case 'submit':
                    $buttonClass = 'success';
                    break;
                «IF hasWorkflowState('deferred')»
                    case 'reject':
                        $buttonClass = '';
                        break;
                «ENDIF»
                «IF needsApproval»
                    case 'approve':
                        $buttonClass = 'success';
                        break;
                    case 'demote':
                        $buttonClass = '';
                        break;
                «ENDIF»
                «IF hasWorkflowState('archived')»
                    case 'archive':
                        $buttonClass = '';
                        break;
                    case 'unarchive':
                        $buttonClass = '';
                        break;
                «ENDIF»
                case 'delete':
                    $buttonClass = 'danger';
                    break;
            }

            if ('' === $buttonClass && 'update' === $actionId) {
                $buttonClass = 'success';
            }

            if (!empty($buttonClass)) {
                $buttonClass = 'btn-' . $buttonClass;
            }

            return $buttonClass;
        }
    '''

    def private executeAction(Application it) '''
        /**
         * Executes a certain workflow action for a given entity object.
         */
        public function executeAction(EntityInterface $entity, string $actionId = '', bool $recursive = false): bool
        {
            $workflow = $this->workflowRegistry->get($entity);
            if (!$workflow->can($entity, $actionId)) {
                return false;
            }

            // get entity manager
            $entityManager = $this->entityFactory->getEntityManager();
            $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')];

            «IF hasLoggable»
                $objectType = $entity->get_objectType();
                $isLoggable = in_array($objectType, ['«getLoggableEntities.map[name.formatForCode].join('\', \'')»']);
                if ($isLoggable && !$entity->get_actionDescriptionForLogEntry()) {
                    if ('delete' === $actionId) {
                        $entity->set_actionDescriptionForLogEntry('_HISTORY_' . mb_strtoupper($objectType) . '_DELETED');
                    } elseif ('submit' === $actionId) {
                        $entity->set_actionDescriptionForLogEntry('_HISTORY_' . mb_strtoupper($objectType) . '_CREATED');
                    } else {
                        $entity->set_actionDescriptionForLogEntry('_HISTORY_' . mb_strtoupper($objectType) . '_UPDATED');
                    }
                }

            «ENDIF»
            $result = false;
            try {
                if ('delete' === $actionId) {
                    $entityManager->remove($entity);
                } else {
                    $entityManager->persist($entity);
                }
                // we flush two times on purpose to avoid a hen-egg problem with workflow post-processing
                // first we flush to ensure that the entity gets an identifier
                $entityManager->flush();
                // then we apply the workflow which causes additional actions, like notifications
                $workflow->apply($entity, $actionId);
                // then we flush again to save the new workflow state of the entity
                $entityManager->flush();

                $result = true;
                if ('delete' === $actionId) {
                    $this->logger->notice('{app}: User {user} deleted an entity.', $logArgs);
                } else {
                    $this->logger->notice('{app}: User {user} updated an entity.', $logArgs);
                }
            } catch (Exception $exception) {
                if ('delete' === $actionId) {
                    $this->logger->error('{app}: User {user} tried to delete an entity, but failed.', $logArgs);
                } else {
                    $this->logger->error('{app}: User {user} tried to update an entity, but failed.', $logArgs);
                }
                // uncomment to reveal Doctrine/SQL error
                // die($exception->getMessage());
                throw new RuntimeException($exception->getMessage());
            }

            if (false !== $result && !$recursive) {
                $entities = $entity->getRelatedObjectsToPersist();
                foreach ($entities as $rel) {
                    if ('initial' === $rel->getWorkflowState()) {
                        $this->executeAction($rel, $actionId, true);
                    }
                }
            }

            return false !== $result;
        }
    '''

    def private collectAmountOfModerationItems(Application it) '''
        /**
         * Collects amount of moderation items foreach object type.
         */
        public function collectAmountOfModerationItems(): array
        {
            $amounts = [];

            «val entitiesStandard = getEntitiesForWorkflow(true)»
            // check if objects are waiting for approval
            $state = 'waiting';
            «FOR entity : entitiesStandard»
                «entity.readAmountForObjectTypeAndState('approval')»
            «ENDFOR»

            return $amounts;
        }
    '''

    def private readAmountForObjectTypeAndState(Entity it, String requiredAction) '''
        $objectType = '«name.formatForCode»';
        «val permissionLevel = if (requiredAction == 'approval') 'ADD' else 'MODERATE'»
        if ($this->permissionHelper->hasComponentPermission($objectType, ACCESS_«permissionLevel»)) {
            $amount = $this->getAmountOfModerationItems($objectType, $state);
            if (0 < $amount) {
                $amounts[] = [
                    'title' => $this->translator->trans('«nameMultiple.formatForCodeCapital» pending «requiredAction»', [], '«name.formatForCode»'),
                    'amount' => $amount,
                    'objectType' => $objectType,
                    'state' => $state,
                ];
            }
        }
    '''

    def private getAmountOfModerationItems(Application it) '''
        /**
         * Retrieves the amount of moderation items for a given object type
         * and a certain workflow state.
         */
        public function getAmountOfModerationItems(string $objectType = '', string $state = ''): int
        {
            $repository = $this->entityFactory->getRepository($objectType);
            $collectionFilterHelper = $repository->getCollectionFilterHelper();
            $repository->setCollectionFilterHelper(null);

            $where = 'tbl.workflowState = \'' . $state . '\'';
            $parameters = ['workflowState' => $state];

            $result = $repository->selectCount($where, false, $parameters);
            $repository->setCollectionFilterHelper($collectionFilterHelper);

            return $result;
        }
    '''

    def private workflowFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractWorkflowHelper;

        /**
         * Helper implementation class for workflow methods.
         */
        class WorkflowHelper extends AbstractWorkflowHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
