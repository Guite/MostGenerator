package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

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

    FileHelper fh = new FileHelper

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for workflows')
        val helperFolder = if (targets('1.3.x')) 'Util' else 'Helper'
        generateClassPair(fsa, getAppSourceLibPath + helperFolder + '/Workflow' + (if (targets('1.3.x')) '' else 'Helper') + '.php',
            fh.phpFileContent(it, workflowFunctionsBaseImpl), fh.phpFileContent(it, workflowFunctionsImpl)
        )
    }

    def private workflowFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Helper\Base;

            use Symfony\Component\DependencyInjection\ContainerBuilder;
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Core\Doctrine\EntityAccess;
            use Zikula_Workflow_Util;

        «ENDIF»
        /**
         * Helper base class for workflow methods.
         */
        abstract class «IF targets('1.3.x')»«appName»_Util_Base_AbstractWorkflow extends Zikula_AbstractBase«ELSE»AbstractWorkflowHelper«ENDIF»
        {
            «IF !targets('1.3.x')»
                /**
                 * Name of the application.
                 *
                 * @var string
                 */
                protected $name;

                /**
                 * @var ContainerBuilder
                 */
                protected $container;

                /**
                 * @var TranslatorInterface
                 */
                protected $translator;

                /**
                 * Constructor.
                 * Initialises member vars.
                 *
                 * @param ContainerBuilder    $container  ContainerBuilder service instance
                 * @param TranslatorInterface $translator Translator service instance
                 *
                 * @return void
                 */
                public function __construct(ContainerBuilder $container, TranslatorInterface $translator)
                {
                    $this->name = '«appName»';
                    $this->container = $container;
                    $this->translator = $translator;
                }

            «ENDIF»
            «getObjectStates»
            «getStateInfo»
            «getWorkflowName»
            «getWorkflowSchema»
            «getActionsForObject»
            «executeAction»
            «IF !targets('1.3.x')»
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
            $states = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            «val states = getRequiredStateList»
            «FOR state : states»
                «stateInfo(state)»
            «ENDFOR»

            return $states;
        }

    '''

    def private stateInfo(Application it, ListFieldItem item) '''
        $states[] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
            'value' => '«item.value»',
            'text' => $this->«IF !targets('1.3.x')»translator->«ENDIF»__('«item.name»'),
            'ui' => '«uiFeedback(item)»'
        «IF targets('1.3.x')»)«ELSE»]«ENDIF»;
    '''

    def private uiFeedback(Application it, ListFieldItem item) {
        if (targets('1.3.x')) {
            return item.stateIcon135
        } else {
            return item.stateLabel
        }
    }

    def private stateIcon135(ListFieldItem it) {
        switch it.value {
            case 'initial': 'red'
            case 'deferred': 'red'
            case 'waiting': 'yellow'
            case 'accepted': 'yellow'
            case 'approved': 'green'
            case 'suspended': 'yellow'
            case 'archived': 'red'
            case 'trashed': 'red'
            case 'deleted': 'red'
            default: 'red'
        }
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
         * @param «IF targets('1.3.x')»Zikula_«ENDIF»EntityAccess $entity The given entity instance
         *
         * @return array List of available workflow actions
         */
        public function getActionsForObject($entity)
        {
            // get possible actions for this object in it's current workflow state
            $objectType = $entity['_objectType'];

            «IF targets('1.3.x')»
                // ensure the correct module name is set, even if another page is called by the user
                if (!isset($entity['__WORKFLOW__']['module'])) {
                    $workflow = $entity['__WORKFLOW__'];
                    $workflow['module'] = $this->name;
                    $entity['__WORKFLOW__'] = $workflow;
                }
            «ELSE»
                $this->normaliseWorkflowData($entity);
            «ENDIF»

            $idColumn = $entity['__WORKFLOW__']['obj_idcolumn'];
            $wfActions = Zikula_Workflow_Util::getActionsForObject($entity, $objectType, $idColumn, $this->name);

            // as we use the workflows for multiple object types we must maybe filter out some actions
            «IF targets('1.3.x')»
                $listHelper = new «appName»_Util_ListEntries($this->serviceManager);
            «ELSE»
                $listHelper = $this->container->get('«appService».listentries_helper');
            «ENDIF»
            $states = $listHelper->getEntries($objectType, 'workflowState');
            $allowedStates = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            foreach ($states as $state) {
                $allowedStates[] = $state['value'];
            }

            $actions = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            foreach ($wfActions as $actionId => $action) {
                $nextState = (isset($action['nextState']) ? $action['nextState'] : '');
                if (!in_array($nextState, «IF targets('1.3.x')»array('', 'deleted')«ELSE»['', 'deleted']«ENDIF») && !in_array($nextState, $allowedStates)) {
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
                    $buttonClass = '«IF targets('1.3.x')»ok«ELSE»success«ENDIF»';
                    break;
                case 'update':
                    $buttonClass = '«IF targets('1.3.x')»ok«ELSE»success«ENDIF»';
                    break;
                «IF hasWorkflowState('deferred')»
                    case 'reject':
                        $buttonClass = '';
                        break;
                «ENDIF»
                «IF hasWorkflowState('accepted')»
                    case 'accept':
                        $buttonClass = '«IF targets('1.3.x')»ok«ELSE»default«ENDIF»';
                        break;
                «ENDIF»
                «IF hasWorkflow(EntityWorkflowType::STANDARD) || hasWorkflow(EntityWorkflowType::ENTERPRISE)»
                    case 'approve':
                        $buttonClass = '«IF targets('1.3.x')»ok«ENDIF»';
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
                        $buttonClass = '«IF targets('1.3.x')»ok«ENDIF»';
                        break;
                «ENDIF»
                «IF hasWorkflowState('archived')»
                    case 'archive':
                        $buttonClass = '«IF targets('1.3.x')»archive«ENDIF»';
                        break;
                «ENDIF»
                «IF hasWorkflowState('trashed')»
                    case 'trash':
                        $buttonClass = '';
                        break;
                    case 'recover':
                        $buttonClass = '«IF targets('1.3.x')»ok«ENDIF»';
                        break;
                «ENDIF»
                case 'delete':
                    $buttonClass = '«IF targets('1.3.x')»delete z-btred«ELSE»danger«ENDIF»';
                    break;
            }

            «IF targets('1.3.x')»
                if (!empty($buttonClass)) {
                    $buttonClass = 'z-bt-' . $buttonClass;
                }
            «ELSE»
                if (empty($buttonClass)) {
                    $buttonClass = 'default';
                }

                $buttonClass = 'btn btn-' . $buttonClass;
            «ENDIF»

            return $buttonClass;
        }

    '''

    def private executeAction(Application it) '''
        /**
         * Executes a certain workflow action for a given entity object.
         *
         * @param «IF targets('1.3.x')»Zikula_«ENDIF»EntityAccess $entity   The given entity instance
         * @param string«IF targets('1.3.x')»       «ENDIF»        $actionId Name of action to be executed
         * @param bool«IF targets('1.3.x')»       «ENDIF»          $recursive true if the function called itself
         *
         * @return bool False on error or true if everything worked well
         */
        public function executeAction($entity, $actionId = '', $recursive = false)
        {
            $objectType = $entity['_objectType'];
            $schemaName = $this->getWorkflowName($objectType);

            $entity->initWorkflow(true);
            $idColumn = $entity['__WORKFLOW__']['obj_idcolumn'];
            «IF !targets('1.3.x')»

                $this->normaliseWorkflowData($entity);
            «ENDIF»

            $result = Zikula_Workflow_Util::executeAction($schemaName, $entity, $actionId, $objectType, «IF targets('1.3.x')»$this->name«ELSE»'«appName»'«ENDIF», $idColumn);

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
         * @param «IF targets('1.3.x')»Zikula_«ENDIF»EntityAccess $entity The given entity instance (excplicitly assigned by reference as form handlers use arrays)
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

            $entity['__WORKFLOW__'] = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»
                'module'        => '«appName»',
                'id'            => $workflow->getId(),
                'state'         => $workflow->getState(),
                'obj_table'     => $workflow->getObjTable(),
                'obj_idcolumn'  => $workflow->getObjIdcolumn(),
                'obj_id'        => $workflow->getObjId(),
                'schemaname'    => $workflow->getSchemaname()
            «IF targets('1.3.x')»)«ELSE»]«ENDIF»;

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
            $amounts = «IF targets('1.3.x')»array()«ELSE»[]«ENDIF»;

            «val entitiesStandard = getEntitiesForWorkflow(EntityWorkflowType::STANDARD)»
            «val entitiesEnterprise = getEntitiesForWorkflow(EntityWorkflowType::ENTERPRISE)»
            «val entitiesNotNone = entitiesStandard + entitiesEnterprise»
            «IF entitiesNotNone.empty»
                // nothing required here as no entities use enhanced workflows including approval actions
            «ELSE»
                «IF !targets('1.3.x')»
                    $logger = $this->container->get('logger');

                «ENDIF»
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
        «IF !application.targets('1.3.x')»
            $permissionApi = $this->container->get('zikula_permissions_module.api.permission');
        «ENDIF»
        «val permissionLevel = if (requiredAction == 'approval') 'ADD' else if (requiredAction == 'acceptance') 'EDIT' else 'MODERATE'»
        if («IF application.targets('1.3.x')»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission('«application.appName»:' . ucfirst($objectType) . ':', '::', ACCESS_«permissionLevel»)) {
            $amount = $this->getAmountOfModerationItems($objectType, $state);
            if ($amount > 0) {
                $amounts[] = «IF application.targets('1.3.x')»array(«ELSE»[«ENDIF»
                    'aggregateType' => '«nameMultiple.formatForCode»«requiredAction.toFirstUpper»',
                    'description' => $this->«IF !application.targets('1.3.x')»translator->«ENDIF»__('«nameMultiple.formatForCodeCapital» pending «requiredAction»'),
                    'amount' => $amount,
                    'objectType' => $objectType,
                    'state' => $state,
                    'message' => $this->«IF !application.targets('1.3.x')»translator->«ENDIF»_fn('One «name.formatForDisplay» is waiting for «requiredAction».', '%s «nameMultiple.formatForDisplay» are waiting for «requiredAction».', $amount, «IF application.targets('1.3.x')»array($amount)«ELSE»['%s' => $amount]«ENDIF»)
                «IF application.targets('1.3.x')»)«ELSE»]«ENDIF»;
                «IF !application.targets('1.3.x')»

                    $logger->info('{app}: There are {amount} {entities} waiting for approval.', ['app' => '«application.appName»', 'amount' => $amount, 'entities' => '«nameMultiple.formatForDisplay»']);
                «ENDIF»
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
            «IF targets('1.3.x')»
                $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
                $entityManager = $this->serviceManager->get«IF targets('1.3.x')»Service«ENDIF»('«entityManagerService»');
                $repository = $entityManager->getRepository($entityClass);

                $where = 'tbl.workflowState = \'' . $state . '\'';
            «ELSE»
                $repository = $this->container->get('«appService».' . $objectType . '_factory')->getRepository();

                $where = 'tbl.workflowState:eq:' . $state;
            «ENDIF»
            $parameters = «IF targets('1.3.x')»array(«ELSE»[«ENDIF»'workflowState' => $state«IF targets('1.3.x')»)«ELSE»]«ENDIF»;
            $useJoins = false;
            $amount = $repository->selectCount($where, $useJoins, $parameters);

            return $amount;
        }
    '''

    def private workflowFunctionsImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Helper;

            use «appNamespace»\Helper\Base\AbstractWorkflowHelper;

        «ENDIF»
        /**
         * Helper implementation class for workflow methods.
         */
        «IF targets('1.3.x')»
        class «appName»_Util_Workflow extends «appName»_Util_Base_AbstractWorkflow
        «ELSE»
        class WorkflowHelper extends AbstractWorkflowHelper
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
