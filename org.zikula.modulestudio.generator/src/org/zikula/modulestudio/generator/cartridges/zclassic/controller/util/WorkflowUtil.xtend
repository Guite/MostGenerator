package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
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
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()
    @Inject extension WorkflowExtensions = new WorkflowExtensions()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for workflows')
        val utilPath = getAppSourceLibPath + 'Util/'
        fsa.generateFile(utilPath + 'Base/Workflow.php', workflowFunctionsBaseFile)
        fsa.generateFile(utilPath + 'Workflow.php', workflowFunctionsFile)
    }

    def private workflowFunctionsBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «workflowFunctionsBaseImpl»
    '''

    def private workflowFunctionsFile(Application it) '''
        «fh.phpFileHeader(it)»
        «workflowFunctionsImpl»
    '''

    def private workflowFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Util\Base;

        «ENDIF»
        /**
         * Utility base class for workflow helper methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_Base_Workflow extends Zikula_AbstractBase
        «ELSE»
        class Workflow extends \Zikula_AbstractBase
        «ENDIF»
        {
            «getObjectStates»
            «getStateInfo»
            «getWorkflowName»
            «getWorkflowSchema»
            «getActionsForObject»
            «executeAction»
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

    def private stateInfo(ListFieldItem it) '''
        $states[] = array('value' => '«value»',
                          'text' => $this->__('«name»'),
                          'icon' => '«stateIcon».png');
    '''

    def private stateIcon(ListFieldItem it) {
        switch (it.value) {
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
         * @param Zikula_EntityAccess $entity The given entity instance.
         *
         * @return array List of available workflow actions.
         */
        public function getActionsForObject($entity)
        {
            // get possible actions for this object in it's current workflow state
            $objectType = $entity['_objectType'];
            $schemaName = $this->getWorkflowName($objectType);
            $idcolumn = $entity['__WORKFLOW__']['obj_idcolumn'];
            $wfActions = Zikula_Workflow_Util::getActionsForObject($entity, $objectType, $idcolumn, $this->name);

            // as we use the workflows for multiple object types we must maybe filter out some actions
            $listHelper = new «appName»«IF targets('1.3.5')»_Util_«ELSE»\Util\«ENDIF»ListEntries($this->serviceManager);
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
                if ($schemaName == 'none' && $actionId == 'submit') {
                    // call submit button 'Create' if no approval is required
                    $actions[$actionId]['title'] = $this->__('Create');
                }
                $actions[$actionId]['buttonClass'] = $this->getButtonClassForAction($actionId);
            }

            return $actions;
        }

        /**
         * Returns a button class for a certain action.
         *
         * @param string $actionId Id of the treated action.
         */
        protected getButtonClassForAction($actionId)
        {
            $buttonClass = '';
            switch ($actionId) {
            «IF hasWorkflowState('deferred')»
                case 'defer':
                    $buttonClass = '';
                    break;
            «ENDIF»
                case 'submit':
                    $buttonClass = 'ok';//'new';
                    break;
                case 'update':
                    $buttonClass = 'save';//'edit';
                    break;
            «IF hasWorkflowState('deferred')»
                case 'reject':
                    $buttonClass = '';
                    break;
            «ENDIF»
            «IF hasWorkflowState('accepted')»
                case 'accept':
                    $buttonClass = 'ok';
                    break;
            «ENDIF»
            «IF hasWorkflow(EntityWorkflowType::STANDARD) || hasWorkflow(EntityWorkflowType::ENTERPRISE)»
                case 'approve':
                    $buttonClass = 'ok';
                    break;
            «ENDIF»
            «IF hasWorkflowState('accepted')»
                case 'demote':
                    $buttonClass = '';
                    break;
            «ENDIF»
            «IF hasWorkflowState('suspended')»
                case 'unpublish':
                    $buttonClass = '';//'filter';
                    break;
                case 'publish':
                    $buttonClass = 'ok';
                    break;
            «ENDIF»
            «IF hasWorkflowState('archived')»
                case 'archive':
                    $buttonClass = 'archive';
                    break;
            «ENDIF»
            «IF hasWorkflowState('trashed')»
                case 'trash':
                    $buttonClass = '';
                    break;
                case 'recover':
                    $buttonClass = 'ok';
                    break;
            «ENDIF»
                case 'delete':
                    $buttonClass = 'delete z-btred';
                    break;
            }

            if (!empty($buttonClass)) {
                $buttonClass = 'z-bt-' . $buttonClass;
            }

            return $buttonClass;
        }

    '''

    def private executeAction(Application it) '''
        /**
         * Executes a certain workflow action for a given entity object.
         *
         * @param Zikula_EntityAccess $entity   The given entity instance.
         * @param string              $actionId Name of action to be executed. 
         *
         * @return bool False on error or true if everything worked well.
         */
        public function executeAction($entity, $actionId = '')
        {
            $objectType = $entity['_objectType'];
            $schemaName = $this->getWorkflowName($objectType);
            $idcolumn = $entity['__WORKFLOW__']['obj_idcolumn'];
            $result = Zikula_Workflow_Util::executeAction($schemaName, $entity, $actionId, $objectType, $this->name, $idcolumn);

            return $result;
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

            «val entitiesStandard = getEntitiesForWorkflow(EntityWorkflowType::STANDARD)»
            «val entitiesEnterprise = getEntitiesForWorkflow(EntityWorkflowType::ENTERPRISE)»
            «val entitiesNotNone = entitiesStandard + entitiesEnterprise»
            «IF entitiesNotNone.isEmpty»
                // nothing required here as no entities use enhanced workflows including approval actions
            «ELSE»

                // check if objects are waiting for«IF !entitiesEnterprise.isEmpty» acceptance or«ENDIF» approval
                $state = 'waiting';
                «FOR entity : entitiesStandard»
                    «entity.readAmountForObjectTypeAndState('approval')»
                «ENDFOR»
                «FOR entity : entitiesEnterprise»
                    «entity.readAmountForObjectTypeAndState('acceptance')»
                «ENDFOR»
                «IF !entitiesEnterprise.isEmpty»
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
        if (\SecurityUtil::checkPermission($modname . ':' . ucwords($objectType) . ':', '::', ACCESS_«permissionLevel»)) {
            $amount = $this->getAmountOfModerationItems($objectType, $state);
            if ($amount > 0) {
                $amounts[] = array(
                    'aggregateType' => '«nameMultiple.formatForCode»«requiredAction.toFirstUpper»',
                    'description' => $this->__('«nameMultiple.formatForCodeCapital» pending «requiredAction»'),
                    'amount' => $amount,
                    'objectType' => $objectType
                    'state' => $state,
                    'message' => $this->_fn('One «name.formatForDisplay» is waiting for «requiredAction».', '%s «nameMultiple.formatForDisplay» are waiting for «requiredAction».', $amount, array($amount))
                );
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
            $entityManager = $this->serviceManager->getService('doctrine.entitymanager');

            $repository = $entityManager->getRepository($this->name . '_Entity_' . ucfirst($objectType));

            $where = 'tbl.workflowState = \'' . $state . '\'';
            $useJoins = false;
            $amount = $repository->selectCount($where, $useJoins);

            return $amount;
        }
    '''

    def private workflowFunctionsImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Util;

        «ENDIF»
        /**
         * Utility implementation class for workflow helper methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_Workflow extends «appName»_Util_Base_Workflow
        «ELSE»
        class Workflow extends Base\Workflow
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
