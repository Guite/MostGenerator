package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListFieldItem
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class WorkflowHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for workflows')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/WorkflowHelper.php',
            fh.phpFileContent(it, workflowFunctionsBaseImpl), fh.phpFileContent(it, workflowFunctionsImpl)
        )
    }

    def private workflowFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF targets('1.5') || needsApproval»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        «IF targets('1.5')»
            use Symfony\Component\Workflow\Registry;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\Doctrine\EntityAccess;
        «IF targets('1.5') || needsApproval»
            «IF targets('1.5')»
                use Zikula\PermissionsModule\Api\ApiInterface\PermissionApiInterface;
            «ELSE»
                use Zikula\PermissionsModule\Api\PermissionApi;
            «ENDIF»
        «ENDIF»
        «IF targets('1.5')»
            use Zikula\UsersModule\Api\CurrentUserApi;
        «ENDIF»
        «IF !targets('1.5')»
            use Zikula_Workflow_Util;
        «ENDIF»
        «IF targets('1.5') || needsApproval»
            use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;
        «ENDIF»
        use «appNamespace»\Helper\ListEntriesHelper;

        /**
         * Helper base class for workflow methods.
         */
        abstract class AbstractWorkflowHelper
        {
            /**
             * Name of the application.
             *
             * @var string
             */
            protected $name;

            /**
             * @var TranslatorInterface
             */
            protected $translator;
            «IF targets('1.5')»

                /**
                 * @var Registry
                 */
                protected $workflowRegistry;
            «ENDIF»
            «IF targets('1.5') || needsApproval»

                /**
                 * @var LoggerInterface
                 */
                protected $logger;

                /**
                 * @var PermissionApi«IF targets('1.5')»Interface«ENDIF»
                 */
                protected $permissionApi;
                «IF targets('1.5')»

                    /**
                     * @var CurrentUserApi
                     */
                    private $currentUserApi;
                «ENDIF»

                /**
                 * @var «name.formatForCodeCapital»Factory
                 */
                protected $entityFactory;
            «ENDIF»

            /**
             * @var ListEntriesHelper
             */
            protected $listEntriesHelper;

            /**
             * WorkflowHelper constructor.
             *
             * @param TranslatorInterface $translator        Translator service instance
             «IF targets('1.5')»
             * @param Registry            $registry          Workflow registry service instance
             «ENDIF»
             «IF targets('1.5') || needsApproval»
             * @param LoggerInterface     $logger            Logger service instance
             * @param PermissionApi«IF targets('1.5')»Interface«ENDIF»       $permissionApi     PermissionApi service instance
             «IF targets('1.5')»
             * @param CurrentUserApi      $currentUserApi    CurrentUserApi service instance
             «ENDIF»
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
             «ENDIF»
             * @param ListEntriesHelper   $listEntriesHelper ListEntriesHelper service instance
             *
             * @return void
             */
            public function __construct(
                TranslatorInterface $translator,
                «IF targets('1.5')»
                    «IF isSystemModule»/*Registry */«ELSE»Registry «ENDIF»$registry,
                «ENDIF»
                «IF targets('1.5') || needsApproval»
                    LoggerInterface $logger,
                    PermissionApi«IF targets('1.5')»Interface«ENDIF» $permissionApi,
                    «IF targets('1.5')»
                        CurrentUserApi $currentUserApi,
                    «ENDIF»
                    «name.formatForCodeCapital»Factory $entityFactory,
                «ENDIF»
                ListEntriesHelper $listEntriesHelper)
            {
                $this->name = '«appName»';
                $this->translator = $translator;
                «IF targets('1.5')»
                    $this->workflowRegistry = $registry;
                «ENDIF»
                «IF targets('1.5') || needsApproval»
                    $this->logger = $logger;
                    $this->permissionApi = $permissionApi;
                    «IF targets('1.5')»
                        $this->currentUserApi = $currentUserApi;
                    «ENDIF»
                    $this->entityFactory = $entityFactory;
                «ENDIF»
                $this->listEntriesHelper = $listEntriesHelper;
            }

            «getObjectStates»
            «getStateInfo»
            «IF !targets('1.5')»
                «getWorkflowName»
            «ENDIF»
            «getActionsForObject»
            «executeAction»
            «IF !targets('1.5')»
                «normaliseWorkflowData»
            «ENDIF»
            «collectAmountOfModerationItems»
            «getAmountOfModerationItems»
        }
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

    def private getWorkflowName(Application it) '''
        /**
         * This method returns the workflow name for a certain object type.
         *
         * @param string $objectType Name of treated object type
         *
         * @return string Name of the corresponding workflow
         */
        public function getWorkflowName($objectType = '')
        {
            $result = '';
            switch ($objectType) {
                «FOR entity: getAllEntities»
                    case '«entity.name.formatForCode»':
                        $result = '«entity.workflow.textualName»';
                        break;
                «ENDFOR»
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
        public function getActionsForObject($entity)
        {
            «IF targets('1.5')»
                $workflow = $this->workflowRegistry->get($entity);
                $wfActions = $workflow->getEnabledTransitions($entity);
                $currentState = $entity->getWorkflowState();
            «ELSE»
                // get possible actions for this object in it's current workflow state
                $objectType = $entity['_objectType'];

                $this->normaliseWorkflowData($entity);

                $idColumn = $entity['__WORKFLOW__']['obj_idcolumn'];
                $wfActions = Zikula_Workflow_Util::getActionsForObject($entity, $objectType, $idColumn, $this->name);
            «ENDIF»

            // as we use the workflows for multiple object types we must maybe filter out some actions
            $states = $this->listEntriesHelper->getEntries(«IF targets('1.5')»$entity->get_objectType()«ELSE»$objectType«ENDIF», 'workflowState');
            $allowedStates = [];
            foreach ($states as $state) {
                $allowedStates[] = $state['value'];
            }

            $actions = [];
            «IF targets('1.5')»
                foreach ($wfActions as $action) {
                    $actionId = $action->getName();
                    $actions[$actionId] = [
                        'id' => $actionId,
                        'title' => $this->getTitleForAction($currentState, $actionId),
                        'buttonClass' => $this->getButtonClassForAction($actionId)
                    ];
                }
            «ELSE»
                foreach ($wfActions as $actionId => $action) {
                    $nextState = (isset($action['nextState']) ? $action['nextState'] : '');
                    if (!in_array($nextState, ['', 'deleted']) && !in_array($nextState, $allowedStates)) {
                        continue;
                    }

                    $actions[$actionId] = $action;
                    $actions[$actionId]['buttonClass'] = $this->getButtonClassForAction($actionId);
                }
            «ENDIF»

            return $actions;
        }
        «IF targets('1.5')»

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

                if ($title == '' && substr($actionId, 0, 6) == 'update') {
                    $title = $this->translator->__('Update');
                }

                return $title;
            }
        «ENDIF»

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
                case 'update':
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
                        $buttonClass = '';
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
         * @param bool         $recursive True if the function called itself
         *
         * @return bool False on error or true if everything worked well
         */
        public function executeAction($entity, $actionId = '', $recursive = false)
        {
            «IF targets('1.5')»
                $workflow = $this->workflowRegistry->get($entity);
                if (!$workflow->can($entity, $actionId)) {
                    return false;
                }

                // get entity manager
                $entityManager = $this->entityFactory->getObjectManager();
                $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')];

                $result = false;

                try {
                    $workflow->apply($entity, $actionId);

                    //$entityManager->transactional(function($entityManager) {
                    if ($actionId == 'delete') {
                        $entityManager->remove($entity);
                    } else {
                        «IF hasAutomaticArchiving»
                            if ($entity->getWorkflowState() == 'archived') {
                                // bypass validator (for example an end date could have lost it's "value in future")
                                $entity->set_bypassValidation(true);
                            }
                        «ENDIF»
                        $entityManager->persist($entity);
                    }
                    $entityManager->flush();
                    //});
                    $result = true;
                    if ($actionId == 'delete') {
                        $this->logger->notice('{app}: User {user} deleted an entity.', $logArgs);
                    } else {
                        $this->logger->notice('{app}: User {user} updated an entity.', $logArgs);
                    }
                } catch (\Exception $e) {
                    if ($actionId == 'delete') {
                        $this->logger->error('{app}: User {user} tried to delete an entity, but failed.', $logArgs);
                    } else {
                        $this->logger->error('{app}: User {user} tried to update an entity, but failed.', $logArgs);
                    }
                    throw new \RuntimeException($e->getMessage());
                }
            «ELSE»
                $objectType = $entity['_objectType'];
                $schemaName = $this->getWorkflowName($objectType);

                $entity->initWorkflow(true);
                $idColumn = $entity['__WORKFLOW__']['obj_idcolumn'];

                $this->normaliseWorkflowData($entity);

                $result = Zikula_Workflow_Util::executeAction($schemaName, $entity, $actionId, $objectType, '«appName»', $idColumn);
            «ENDIF»

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

    def private normaliseWorkflowData(Application it) '''
        /**
         * Performs a conversion of the workflow object back to an array.
         *
         * @param EntityAccess $entity The given entity instance (excplicitly assigned by reference as form handlers use arrays)
         *
         * @return bool False on error or true if everything worked well
         */
        public function normaliseWorkflowData(&$entity)
        {
            $workflow = $entity['__WORKFLOW__'];
            if (!isset($workflow[0]) && isset($workflow['module'])) {
                return true;
            }

            if (isset($workflow[0])) {
                $workflow = $workflow[0];
            }

            if (!is_object($workflow)) {
                $workflow['module'] = '«appName»';
                $entity['__WORKFLOW__'] = $workflow;

                return true;
            }

            $entity['__WORKFLOW__'] = [
                'module'        => '«appName»',
                'id'            => $workflow->getId(),
                'state'         => $workflow->getState(),
                'obj_table'     => $workflow->getObjTable(),
                'obj_idcolumn'  => $workflow->getObjIdcolumn(),
                'obj_id'        => $workflow->getObjId(),
                'schemaname'    => $workflow->getSchemaname()
            ];

            return true;
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
        if ($this->permissionApi->hasPermission('«application.appName»:' . ucfirst($objectType) . ':', '::', ACCESS_«permissionLevel»)) {
            $amount = $this->getAmountOfModerationItems($objectType, $state);
            if ($amount > 0) {
                $amounts[] = [
                    'aggregateType' => '«nameMultiple.formatForCode»«requiredAction.toFirstUpper»',
                    'description' => $this->translator->__('«nameMultiple.formatForCodeCapital» pending «requiredAction»'),
                    'amount' => $amount,
                    'objectType' => $objectType,
                    'state' => $state,
                    'message' => $this->translator->_fn('One «name.formatForDisplay» is waiting for «requiredAction».', '%amount% «nameMultiple.formatForDisplay» are waiting for «requiredAction».', $amount, ['%amount%' => $amount])
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

            $where = 'tbl.workflowState:eq:' . $state;
            $parameters = ['workflowState' => $state];
            $useJoins = false;

            return $repository->selectCount($where, $useJoins, $parameters);
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
