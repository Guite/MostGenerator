package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class WorkflowUtil {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    FileHelper fh = new FileHelper

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for workflows')
        generateClassPair(fsa, getAppSourceLibPath + 'Util/Workflow' + (if (targets('1.3.5')) '' else 'Util') + '.php',
            fh.phpFileContent(it, workflowFunctionsBaseImpl), fh.phpFileContent(it, workflowFunctionsImpl)
        )
    }

    def private workflowFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Util\Base;

            use ModUtil;
            use SecurityUtil;
            use Zikula_AbstractBase;
            use Zikula_Workflow_Util;

        «ENDIF»
        /**
         * Utility base class for workflow helper methods.
         */
        class «IF targets('1.3.5')»«appName»_Util_Base_Workflow«ELSE»WorkflowUtil«ENDIF» extends Zikula_AbstractBase
        {
            «getObjectStates»
            «getStateInfo»
            «getWorkflowName»
            «getWorkflowSchema»
            «getActionsForObject»
            «executeAction»
            «IF !targets('1.3.5')»
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
         * @return array List of collected state information.
         */
        public function getObjectStates()
        {
            $states = array();
            «val states = getRequiredStateList»
            «FOR state : states»
                «stateInfo(state)»
            «ENDFOR»

            return $states;
        }

    '''

    def private stateInfo(Application it, ListFieldItem item) '''
        $states[] = array('value' => '«item.value»',
                          'text' => $this->__('«item.name»'),
                          'ui' => '«uiFeedback(item)»');
    '''

    def private uiFeedback(Application it, ListFieldItem item) {
        if (targets('1.3.5')) {
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
         * @param string $state The given state value.
         *
         * @return array|null The corresponding state information.
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
         * @param string $objectType Name of treated object type.
         *
         * @return string Name of the corresponding workflow.
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
         * @param string $objectType Name of treated object type.
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
         * @param \Zikula_EntityAccess $entity The given entity instance.
         *
         * @return array List of available workflow actions.
         */
        public function getActionsForObject($entity)
        {
            // get possible actions for this object in it's current workflow state
            $objectType = $entity['_objectType'];
            «IF !targets('1.3.5')»

                $this->normaliseWorkflowData($entity);
            «ENDIF»

            $idcolumn = $entity['__WORKFLOW__']['«IF targets('1.3.5')»obj_idcolumn«ELSE»objIdcolumn«ENDIF»'];
            $wfActions = Zikula_Workflow_Util::getActionsForObject($entity, $objectType, $idcolumn, $this->name);

            // as we use the workflows for multiple object types we must maybe filter out some actions
            «IF targets('1.3.5')»
                $listHelper = new «appName»_Util_ListEntries($this->serviceManager);
            «ELSE»
                $listHelper = $this->serviceManager->get('«appName.formatForDB».listentries_helper');
            «ENDIF»
            $states = $listHelper->getEntries($objectType, 'workflowState');
            $allowedStates = array();
            foreach ($states as $state) {
                $allowedStates[] = $state['value'];
            }

            $actions = array();
            foreach ($wfActions as $actionId => $action) {
                $nextState = (isset($action['nextState']) ? $action['nextState'] : '');
                if ($nextState != '' && !in_array($nextState, $allowedStates)) {
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
         * @param string $actionId Id of the treated action.
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
                    $buttonClass = '«IF targets('1.3.5')»ok«ELSE»success«ENDIF»';
                    break;
                case 'update':
                    $buttonClass = '«IF targets('1.3.5')»ok«ELSE»success«ENDIF»';
                    break;
                «IF hasWorkflowState('deferred')»
                    case 'reject':
                        $buttonClass = '';
                        break;
                «ENDIF»
                «IF hasWorkflowState('accepted')»
                    case 'accept':
                        $buttonClass = '«IF targets('1.3.5')»ok«ELSE»default«ENDIF»';
                        break;
                «ENDIF»
                «IF hasWorkflow(EntityWorkflowType::STANDARD) || hasWorkflow(EntityWorkflowType::ENTERPRISE)»
                    case 'approve':
                        $buttonClass = '«IF targets('1.3.5')»ok«ENDIF»';
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
                        $buttonClass = '«IF targets('1.3.5')»ok«ENDIF»';
                        break;
                «ENDIF»
                «IF hasWorkflowState('archived')»
                    case 'archive':
                        $buttonClass = '«IF targets('1.3.5')»archive«ENDIF»';
                        break;
                «ENDIF»
                «IF hasWorkflowState('trashed')»
                    case 'trash':
                        $buttonClass = '';
                        break;
                    case 'recover':
                        $buttonClass = '«IF targets('1.3.5')»ok«ENDIF»';
                        break;
                «ENDIF»
                case 'delete':
                    $buttonClass = '«IF targets('1.3.5')»delete z-btred«ELSE»danger«ENDIF»';
                    break;
            }

            «IF targets('1.3.5')»
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
         * @param \Zikula_EntityAccess $entity   The given entity instance.
         * @param string               $actionId Name of action to be executed.
         * @param bool                 $recursive true if the function called itself.  
         *
         * @return bool False on error or true if everything worked well.
         */
        public function executeAction($entity, $actionId = '', $recursive = false)
        {
            $objectType = $entity['_objectType'];
            $schemaName = $this->getWorkflowName($objectType);

            $entity->initWorkflow(true);
            $idcolumn = $entity['__WORKFLOW__']['«IF targets('1.3.5')»obj_idcolumn«ELSE»objIdcolumn«ENDIF»'];
            «IF !targets('1.3.5')»

                $this->normaliseWorkflowData($entity);
            «ENDIF»

            $result = Zikula_Workflow_Util::executeAction($schemaName, $entity, $actionId, $objectType, $this->name, $idcolumn);

            if ($result !== false && !$recursive) {
                $entities = $entity->getRelatedObjectsToPersist();
                foreach ($entities as $rel) {
                    if ($rel->getWorkflowState() == 'initial') {
                        $this->executeAction($rel, $actionId, true);
                    }
                }
            }

            return ($result !== false);
        }
    '''

    def private normaliseWorkflowData(Application it) '''
        /**
         * Performs a conversion of the workflow object back to an array.
         *
         * @param \Zikula_EntityAccess $entity The given entity instance (excplicitly assigned by reference as form handlers use arrays).
         *
         * @return bool False on error or true if everything worked well.
         */
        public function normaliseWorkflowData(&$entity)
        {
            $workflow = $entity['__WORKFLOW__'];
            if (!isset($workflow[0]) && isset($workflow['module'])) {
                return;
            }

            if (isset($workflow[0])) {
                $workflow = $workflow[0];
            }

            if (!is_object($workflow)) {
                $workflow['module'] = '«appName»';
                $entity['__WORKFLOW__'] = $workflow;

                return true;
            }

            $entity['__WORKFLOW__'] = array(
                'module'        => '«appName»',
                'id'            => $workflow->getId(),
                'state'         => $workflow->getState(),
                «IF targets('1.3.5')»
                    'obj_table'     => $workflow->getObjTable(),
                    'obj_idcolumn'  => $workflow->getObjIdcolumn(),
                    'obj_id'        => $workflow->getObjId(),
                «ELSE»
                    'objTable'      => $workflow->getObjTable(),
                    'objIdcolumn'   => $workflow->getObjIdcolumn(),
                    'objId'         => $workflow->getObjId(),
                «ENDIF»
                'schemaname'    => $workflow->getSchemaname()
            );

            return true;
        }

    '''

    def private collectAmountOfModerationItems(Application it) '''
        /**
         * Collects amount of moderation items foreach object type.
         *
         * @return array List of collected amounts.
         */
        public function collectAmountOfModerationItems()
        {
            $amounts = array();
            $modname = '«appName»';

            «val entitiesStandard = getEntitiesForWorkflow(EntityWorkflowType::STANDARD)»
            «val entitiesEnterprise = getEntitiesForWorkflow(EntityWorkflowType::ENTERPRISE)»
            «val entitiesNotNone = entitiesStandard + entitiesEnterprise»
            «IF entitiesNotNone.empty»
                // nothing required here as no entities use enhanced workflows including approval actions
            «ELSE»
                «IF !targets('1.3.5')»
                    $logger = $serviceManager->get('logger');

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
        «val permissionLevel = if (requiredAction == 'approval') 'ADD' else if (requiredAction == 'acceptance') 'EDIT' else 'MODERATE'»
        if (SecurityUtil::checkPermission($modname . ':' . ucfirst($objectType) . ':', '::', ACCESS_«permissionLevel»)) {
            $amount = $this->getAmountOfModerationItems($objectType, $state);
            if ($amount > 0) {
                $amounts[] = array(
                    'aggregateType' => '«nameMultiple.formatForCode»«requiredAction.toFirstUpper»',
                    'description' => $this->__('«nameMultiple.formatForCodeCapital» pending «requiredAction»'),
                    'amount' => $amount,
                    'objectType' => $objectType,
                    'state' => $state,
                    'message' => $this->_fn('One «name.formatForDisplay» is waiting for «requiredAction».', '%s «nameMultiple.formatForDisplay» are waiting for «requiredAction».', $amount, array($amount))
                );
                «IF !application.targets('1.3.5')»

                    if ($amounts > 0) {
                        $logger->info('{app}: There are {amount} {entities} waiting for approval.', array('app' => '«application.appName»', 'amount' => $amount, 'entities' => '«nameMultiple.formatForDisplay»'));
                    }
                «ENDIF»
            }
        }
    '''

    def private getAmountOfModerationItems(Application it) '''
        /**
         * Retrieves the amount of moderation items for a given object type
         * and a certain workflow state.
         *
         * @param string $objectType Name of treated object type.
         * @param string $state The given state value.
         *
         * @return integer The affected amount of objects.
         */
        public function getAmountOfModerationItems($objectType, $state)
        {
            «IF targets('1.3.5')»
                $entityClass = $this->name . '_Entity_' . ucfirst($objectType);
                $entityManager = $this->serviceManager->get«IF targets('1.3.5')»Service«ENDIF»('doctrine.entitymanager');
                $repository = $entityManager->getRepository($entityClass);
            «ELSE»
                $repository = $this->serviceManager->get('«appName.formatForDB».' . $objectType . '_factory')->getRepository();
            «ENDIF»

            $where = 'tbl.workflowState = \'' . $state . '\'';
            $parameters = array('workflowState' => $state);
            $useJoins = false;
            $amount = $repository->selectCount($where, $useJoins, $parameters);

            return $amount;
        }
    '''

    def private workflowFunctionsImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Util;

            use «appNamespace»\Util\Base\WorkflowUtil as BaseWorkflowUtil;

        «ENDIF»
        /**
         * Utility implementation class for workflow helper methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_Workflow extends «appName»_Util_Base_Workflow
        «ELSE»
        class WorkflowUtil extends BaseWorkflowUtil
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
