package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListFieldItem
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class WorkflowHelper {

    extension FormattingExtensions = new FormattingExtensions
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

        «IF needsApproval»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\Doctrine\EntityAccess;
        «IF needsApproval»
            use Zikula\PermissionsModule\Api\PermissionApi;
        «ENDIF»
        use Zikula_Workflow_Util;
        «IF needsApproval»
            use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;
        «ENDIF»

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
            «IF needsApproval»

                /**
                 * @var LoggerInterface
                 */
                protected $logger;

                /**
                 * @var PermissionApi
                 */
                private $permissionApi;

                /**
                 * @var «name.formatForCodeCapital»Factory
                 */
                private $entityFactory;
            «ENDIF»

            /**
             * @var ListEntriesHelper
             */
            private $listEntriesHelper;

            /**
             * WorkflowHelper constructor.
             *
             * @param TranslatorInterface $translator        Translator service instance
             «IF needsApproval»
             * @param LoggerInterface     $logger            Logger service instance
             * @param PermissionApi       $permissionApi     PermissionApi service instance
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
             «ENDIF»
             * @param ListEntriesHelper   $listEntriesHelper ListEntriesHelper service instance
             *
             * @return void
             */
            public function __construct(TranslatorInterface $translator, «IF needsApproval»LoggerInterface $logger, PermissionApi $permissionApi, «name.formatForCodeCapital»Factory $entityFactory, «ENDIF»ListEntriesHelper $listEntriesHelper)
            {
                $this->name = '«appName»';
                $this->translator = $translator;
                «IF needsApproval»
                    $this->logger = $logger;
                    $this->permissionApi = $permissionApi;
                    $this->entityFactory = $entityFactory;
                «ENDIF»
                $this->listEntriesHelper = $listEntriesHelper;
            }

            «getObjectStates»
            «getStateInfo»
            «getWorkflowName»
            «getWorkflowSchema»
            «getActionsForObject»
            «executeAction»
            «normaliseWorkflowData»
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

    def private getWorkflowSchema(Application it) '''
        /**
         * This method returns the workflow schema for a certain object type.
         *
         * @param string $objectType Name of treated object type
         *
         * @return array|null The resulting workflow schema
         */
        public function getWorkflowSchema($objectType = '')
        {
            $schema = null;
            $schemaName = $this->getWorkflowName($objectType);
            if ($schemaName != '') {
                $schema = Zikula_Workflow_Util::loadSchema($schemaName, $this->name);
            }

            return $schema;
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
            // get possible actions for this object in it's current workflow state
            $objectType = $entity['_objectType'];

            $this->normaliseWorkflowData($entity);

            $idColumn = $entity['__WORKFLOW__']['obj_idcolumn'];
            $wfActions = Zikula_Workflow_Util::getActionsForObject($entity, $objectType, $idColumn, $this->name);

            // as we use the workflows for multiple object types we must maybe filter out some actions
            $states = $this->listEntriesHelper->getEntries($objectType, 'workflowState');
            $allowedStates = [];
            foreach ($states as $state) {
                $allowedStates[] = $state['value'];
            }

            $actions = [];
            foreach ($wfActions as $actionId => $action) {
                $nextState = (isset($action['nextState']) ? $action['nextState'] : '');
                if (!in_array($nextState, ['', 'deleted']) && !in_array($nextState, $allowedStates)) {
                    continue;
                }

                $actions[$actionId] = $action;
                $actions[$actionId]['buttonClass'] = $this->getButtonClassForAction($actionId);
            }

            return $actions;
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
            $objectType = $entity['_objectType'];
            $schemaName = $this->getWorkflowName($objectType);

            $entity->initWorkflow(true);
            $idColumn = $entity['__WORKFLOW__']['obj_idcolumn'];

            $this->normaliseWorkflowData($entity);

            $result = Zikula_Workflow_Util::executeAction($schemaName, $entity, $actionId, $objectType, '«appName»', $idColumn);

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
                    'message' => $this->translator->_fn('One «name.formatForDisplay» is waiting for «requiredAction».', '%s «nameMultiple.formatForDisplay» are waiting for «requiredAction».', $amount, ['%s' => $amount])
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
