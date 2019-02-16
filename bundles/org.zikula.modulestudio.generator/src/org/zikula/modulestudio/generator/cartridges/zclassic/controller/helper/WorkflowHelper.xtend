package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListFieldItem
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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

    def private workflowFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Psr\Log\LoggerInterface;
        use Symfony\Component\Workflow\Registry;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\ListEntriesHelper;
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Helper base class for workflow methods.
         */
        abstract class AbstractWorkflowHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var TranslatorInterface
         */
        protected $translator;

        /**
         * @var Registry
         */
        protected $workflowRegistry;

        /**
         * @var LoggerInterface
         */
        protected $logger;

        /**
         * @var CurrentUserApiInterface
         */
        protected $currentUserApi;

        /**
         * @var EntityFactory
         */
        protected $entityFactory;

        /**
         * @var ListEntriesHelper
         */
        protected $listEntriesHelper;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;

        /**
         * WorkflowHelper constructor.
         *
         * @param TranslatorInterface     $translator        Translator service instance
         * @param Registry                $registry          Workflow registry service instance
         * @param LoggerInterface         $logger            Logger service instance
         * @param CurrentUserApiInterface $currentUserApi    CurrentUserApi service instance
         * @param EntityFactory           $entityFactory     EntityFactory service instance
         * @param ListEntriesHelper       $listEntriesHelper ListEntriesHelper service instance
         * @param PermissionHelper        $permissionHelper  PermissionHelper service instance
         *
         * @return void
         */
        public function __construct(
            TranslatorInterface $translator,
            Registry $registry,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi,
            EntityFactory $entityFactory,
            ListEntriesHelper $listEntriesHelper,
            PermissionHelper $permissionHelper
        ) {
            $this->translator = $translator;
            $this->workflowRegistry = $registry;
            $this->logger = $logger;
            $this->currentUserApi = $currentUserApi;
            $this->entityFactory = $entityFactory;
            $this->listEntriesHelper = $listEntriesHelper;
            $this->permissionHelper = $permissionHelper;
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
        *
        * @return array List of collected state information
        */
       public function getObjectStates()
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
            'text' => $this->translator->__('«item.name»'),
            'ui' => '«uiFeedback(item)»'
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
            case 'accepted': 'warning'
            case 'approved': 'success'
            case 'suspended': 'primary'
            case 'archived': 'info'
            case 'trashed': 'danger'
            case 'deleted': 'danger'
            default: 'default'
        }
    }

    def private getStateInfo(Application it) '''
        /**
         * This method returns information about a certain state.
         *
         * @param string $state The given state value
         *
         * @return array|null The corresponding state information
         */
        public function getStateInfo($state = 'initial')
        {
            $result = null;
            $stateList = $this->getObjectStates();
            foreach ($stateList as $singleState) {
                if ($singleState['value'] != $state) {
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
         *
         * @param EntityAccess $entity The given entity instance
         *
         * @return array List of available workflow actions
         */
        public function getActionsForObject(EntityAccess $entity)
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
                    'buttonClass' => $this->getButtonClassForAction($actionId)
                ];
            }

            return $actions;
        }

        /**
         * Returns a translatable title for a certain action.
         *
         * @param string $currentState Current state of the entity
         * @param string $actionId     Id of the treated action
         *
         * @return string The action title
         */
        protected function getTitleForAction($currentState, $actionId)
        {
            $title = '';
            switch ($actionId) {
                «IF hasWorkflowState('deferred')»
                    case 'defer':
                        $title = $this->translator->__('Defer');
                        break;
                «ENDIF»
                case 'submit':
                    $title = $this->translator->__('Submit');
                    break;
                «IF hasWorkflowState('deferred')»
                    case 'reject':
                        $title = $this->translator->__('Reject');
                        break;
                «ENDIF»
                «IF hasWorkflowState('accepted')»
                    case 'accept':
                        $title = $currentState == 'initial' ? $this->translator->__('Submit and accept') : $this->translator->__('Accept');
                        break;
                «ENDIF»
                «IF hasWorkflow(EntityWorkflowType::STANDARD) || hasWorkflow(EntityWorkflowType::ENTERPRISE)»
                    case 'approve':
                        $title = $currentState == 'initial' ? $this->translator->__('Submit and approve') : $this->translator->__('Approve');
                        break;
                «ENDIF»
                «IF hasWorkflowState('accepted')»
                    case 'demote':
                        $title = $this->translator->__('Demote');
                        break;
                «ENDIF»
                «IF hasWorkflowState('suspended')»
                    case 'unpublish':
                        $title = $this->translator->__('Unpublish');
                        break;
                    case 'publish':
                        $title = $this->translator->__('Publish');
                        break;
                «ENDIF»
                «IF hasWorkflowState('archived')»
                    case 'archive':
                        $title = $this->translator->__('Archive');
                        break;
                    case 'unarchive':
                        $title = $this->translator->__('Unarchive');
                        break;
                «ENDIF»
                «IF hasWorkflowState('trashed')»
                    case 'trash':
                        $title = $this->translator->__('Trash');
                        break;
                    case 'recover':
                        $title = $this->translator->__('Recover');
                        break;
                «ENDIF»
                case 'delete':
                    $title = $this->translator->__('Delete');
                    break;
            }

            if ($title == '') {
                if («IF targets('2.0')»$actionId«ELSE»substr($actionId, 0, 6)«ENDIF» == 'update') {
                    $title = $this->translator->__('Update');
                } elseif («IF targets('2.0')»$actionId«ELSE»substr($actionId, 0, 5)«ENDIF» == 'trash') {
                    $title = $this->translator->__('Trash');
                } elseif («IF targets('2.0')»$actionId«ELSE»substr($actionId, 0, 7)«ENDIF» == 'recover') {
                    $title = $this->translator->__('Recover');
                }
            }

            return $title;
        }

        /**
         * Returns a button class for a certain action.
         *
         * @param string $actionId Id of the treated action
         *
         * @return string The button class
         */
        protected function getButtonClassForAction($actionId)
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
                «IF hasWorkflowState('accepted')»
                    case 'accept':
                        $buttonClass = 'default';
                        break;
                «ENDIF»
                «IF hasWorkflow(EntityWorkflowType::STANDARD) || hasWorkflow(EntityWorkflowType::ENTERPRISE)»
                    case 'approve':
                        $buttonClass = 'success';
                        break;
                «ENDIF»
                «IF hasWorkflowState('accepted')»
                    case 'demote':
                        $buttonClass = '';
                        break;
                «ENDIF»
                «IF hasWorkflowState('suspended')»
                    case 'unpublish':
                        $buttonClass = '';
                        break;
                    case 'publish':
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
                «IF hasWorkflowState('trashed')»
                    case 'trash':
                        $buttonClass = '';
                        break;
                    case 'recover':
                        $buttonClass = '';
                        break;
                «ENDIF»
                case 'delete':
                    $buttonClass = 'danger';
                    break;
            }

            if ($buttonClass == '' && «IF targets('2.0')»$actionId«ELSE»substr($actionId, 0, 6)«ENDIF» == 'update') {
                $buttonClass = 'success';
            }

            if (empty($buttonClass)) {
                $buttonClass = 'default';
            }

            return 'btn btn-' . $buttonClass;
        }
    '''

    def private executeAction(Application it) '''
        /**
         * Executes a certain workflow action for a given entity object.
         *
         * @param EntityAccess $entity    The given entity instance
         * @param string       $actionId  Name of action to be executed
         * @param boolean      $recursive True if the function called itself
         *
         * @return boolean Whether everything worked well or not
         */
        public function executeAction(EntityAccess $entity, $actionId = '', $recursive = false)
        {
            $workflow = $this->workflowRegistry->get($entity);
            if (!$workflow->can($entity, $actionId)) {
                return false;
            }

            // get entity manager
            $entityManager = $this->entityFactory->getObjectManager();
            $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')];

            «IF hasLoggable»
                $objectType = $entity->get_objectType();
                $isLoggable = in_array($objectType, ['«getLoggableEntities.map[name.formatForCode].join('\', \'')»']);
                if ($isLoggable && !$entity->get_actionDescriptionForLogEntry()) {
                    if ('delete' == $actionId) {
                        $entity->set_actionDescriptionForLogEntry('_HISTORY_' . strtoupper($objectType) . '_DELETED');
                    } elseif ('submit' == $actionId) {
                        $entity->set_actionDescriptionForLogEntry('_HISTORY_' . strtoupper($objectType) . '_CREATED');
                    } else {
                        $entity->set_actionDescriptionForLogEntry('_HISTORY_' . strtoupper($objectType) . '_UPDATED');
                    }
                }
            «ENDIF»
            $result = false;
            if (!$workflow->can($entity, $actionId)) {
                return $result;
            }

            try {
                if ('delete' == $actionId) {
                    $entityManager->remove($entity);
                } else {
                    $entityManager->persist($entity);
                }
                $workflow->apply($entity, $actionId);
                $entityManager->flush();

                $result = true;
                if ('delete' == $actionId) {
                    $this->logger->notice('{app}: User {user} deleted an entity.', $logArgs);
                } else {
                    $this->logger->notice('{app}: User {user} updated an entity.', $logArgs);
                }
            } catch (\Exception $exception) {
                if ('delete' == $actionId) {
                    $this->logger->error('{app}: User {user} tried to delete an entity, but failed.', $logArgs);
                } else {
                    $this->logger->error('{app}: User {user} tried to update an entity, but failed.', $logArgs);
                }
                throw new \RuntimeException($exception->getMessage());
            }

            if (false !== $result && !$recursive) {
                $entities = $entity->getRelatedObjectsToPersist();
                foreach ($entities as $rel) {
                    if ($rel->getWorkflowState() == 'initial') {
                        $this->executeAction($rel, $actionId, true);
                    }
                }
            }

            return (false !== $result);
        }
    '''

    def private collectAmountOfModerationItems(Application it) '''
        /**
         * Collects amount of moderation items foreach object type.
         *
         * @return array List of collected amounts
         */
        public function collectAmountOfModerationItems()
        {
            $amounts = [];

            «val entitiesStandard = getEntitiesForWorkflow(EntityWorkflowType::STANDARD)»
            «val entitiesEnterprise = getEntitiesForWorkflow(EntityWorkflowType::ENTERPRISE)»
            «val entitiesNotNone = entitiesStandard + entitiesEnterprise»
            «IF entitiesNotNone.empty»
                // nothing required here as no entities use enhanced workflows including approval actions
            «ELSE»

                // check if objects are waiting for«IF !entitiesEnterprise.empty» acceptance or«ENDIF» approval
                $state = 'waiting';
                «FOR entity : entitiesStandard»
                    «entity.readAmountForObjectTypeAndState('approval')»
                «ENDFOR»
                «FOR entity : entitiesEnterprise»
                    «entity.readAmountForObjectTypeAndState('acceptance')»
                «ENDFOR»
                «IF !entitiesEnterprise.empty»
                    // check if objects are waiting for approval
                    $state = 'accepted';
                    «FOR entity : entitiesEnterprise»
                        «entity.readAmountForObjectTypeAndState('approval')»
                    «ENDFOR»
                «ENDIF»
            «ENDIF»

            return $amounts;
        }
    '''

    def private readAmountForObjectTypeAndState(Entity it, String requiredAction) '''
        $objectType = '«name.formatForCode»';
        «val permissionLevel = if (requiredAction == 'approval') 'ADD' else if (requiredAction == 'acceptance') 'EDIT' else 'MODERATE'»
        if ($this->permissionHelper->hasComponentPermission($objectType, ACCESS_«permissionLevel»)) {
            $amount = $this->getAmountOfModerationItems($objectType, $state);
            if ($amount > 0) {
                $amounts[] = [
                    'aggregateType' => '«nameMultiple.formatForCode»«requiredAction.toFirstUpper»',
                    'description' => $this->translator->__('«nameMultiple.formatForCodeCapital» pending «requiredAction»'),
                    'amount' => $amount,
                    'objectType' => $objectType,
                    'state' => $state,
                    'message' => $this->translator->transChoice('One «name.formatForDisplay» is waiting for «requiredAction».|%count% «nameMultiple.formatForDisplay» are waiting for «requiredAction».', $amount, ['%count%' => $amount]«IF !application.isSystemModule», '«application.appName.formatForDB»'«ENDIF»)
                ];

                $this->logger->info('{app}: There are {amount} {entities} waiting for approval.', ['app' => '«application.appName»', 'amount' => $amount, 'entities' => '«nameMultiple.formatForDisplay»']);
            }
        }
    '''

    def private getAmountOfModerationItems(Application it) '''
        /**
         * Retrieves the amount of moderation items for a given object type
         * and a certain workflow state.
         *
         * @param string $objectType Name of treated object type
         * @param string $state The given state value
         *
         * @return integer The affected amount of objects
         */
        public function getAmountOfModerationItems($objectType, $state)
        {
            $repository = $this->entityFactory->getRepository($objectType);

            $where = 'tbl.workflowState = \'' . $state . '\'';
            $parameters = ['workflowState' => $state];

            return $repository->selectCount($where, false, $parameters);
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
