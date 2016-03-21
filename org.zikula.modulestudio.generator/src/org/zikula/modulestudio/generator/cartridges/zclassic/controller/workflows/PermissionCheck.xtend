package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListFieldItem
import java.util.ArrayList
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

/**
 * Workflow permission checks.
 */
class PermissionCheck {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    Application app
    EntityWorkflowType wfType
    ArrayList<ListFieldItem> states

    IFileSystemAccess fsa
    String outputPath
    FileHelper fh = new FileHelper

    /**
     * Entry point for workflow permission checks.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        app = it
        this.fsa = fsa
        outputPath = getAppSourcePath + 'workflows/'

        generate(EntityWorkflowType.NONE)
        generate(EntityWorkflowType.STANDARD)
        generate(EntityWorkflowType.ENTERPRISE)
    }

    def private generate(EntityWorkflowType wfType) {
        if (!app.hasWorkflow(wfType)) {
            return
        }

        this.wfType = wfType
        // generate only those states which are required by any entity using this workflow type
        this.states = getRequiredStateList(app, wfType)

        var fileName = 'function.' + wfType.textualName + '_permissioncheck.php'
        if (!app.shouldBeSkipped(outputPath + fileName)) {
            if (app.shouldBeMarked(outputPath + fileName)) {
                fileName = 'function.' + wfType.textualName + '_permissioncheck.generated.php'
            }
            fsa.generateFile(outputPath + fileName, fh.phpFileContent(app, permissionCheckFile))
        }
    }

    def private permissionCheckFile() '''
        «permissionCheckImpl»

        «gettextStrings»
    '''

    def private permissionCheckImpl() '''
        /**
         * Permission check for workflow schema '«wfType.textualName»'.
         * This function allows to calculate complex permission checks.
         * It receives the object the workflow engine is being asked to process and the permission level the action requires.
         *
         * @param array  $obj         The currently treated object.
         * @param int    $permLevel   The required workflow permission level.
         * @param int    $currentUser Id of current user.
         * @param string $actionId    Id of the workflow action to be executed.
         *
         * @return bool Whether the current user is allowed to execute the action or not.
         */
        function «app.appName»_workflow_«wfType.textualName»_permissioncheck($obj, $permLevel, $currentUser, $actionId)
        {
            «IF !app.getAllEntities.filter[hasArchive && null !== getEndDateField].empty»
                // every user is allowed to perform automatic archiving 
                if («IF !app.targets('1.3.x')»\«ENDIF»PageUtil::getVar('«app.appName»AutomaticArchiving', false) === true) {
                    return true;
                }
            «ENDIF»

            // calculate the permission component
            $objectType = $obj['_objectType'];
            $component = '«app.appName»:' . ucfirst($objectType) . ':';

            // calculate the permission instance
            $instance = $obj->createCompositeIdentifier() . '::';

            // now perform the permission check
            $result = SecurityUtil::checkPermission($component, $instance, $permLevel, $currentUser);
            «val entitiesWithOwnerPermission = app.getAllEntities.filter[standardFields && ownerPermission]»
            «IF !entitiesWithOwnerPermission.empty»

                // check whether the current user is the owner
                if (!$result && isset($obj['createdUserId']) && $obj['createdUserId'] == $currentUser) {
                    // allow author update operations for all states which occur before 'approved' in the object's life cycle.
                    $result = in_array($actionId, «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»'initial'«IF app.hasWorkflowState(wfType, 'deferred')», 'deferred'«ENDIF»«IF wfType != EntityWorkflowType.NONE», 'waiting'«ENDIF», 'accepted'«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»);
                }
            «ENDIF»

            return $result;
        }
    '''

    def private gettextStrings() '''
        /**
         * This helper functions cares for including the strings used in the workflow into translation.
         */
        function «app.appName»_workflow_«wfType.textualName»_gettextstrings()
        {
            «val wfDefinition = new Definition»
            «IF !app.targets('1.3.x')»
                $serviceManager = \ServiceUtil::getManager();
                $translator = $serviceManager->get('translator.default');
            «ENDIF»
            return «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                'title' => «app.gettextCall»('«wfType.textualName.formatForDisplayCapital» workflow («wfType.approvalType.formatForDisplay» approval)'),
                'description' => «app.gettextCall»('«wfDefinition.workflowDescription(wfType)»'),

                «val lastState = states.last»
                «gettextStates(lastState)»

                «gettextActionsPerState(lastState)»
            «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
        }
    '''

    def private gettextStates(ListFieldItem lastState) '''
        // state titles
        'states' => «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
            «FOR state : states»
                «gettextState(state)»«IF state != lastState»,«ENDIF»
            «ENDFOR»
        «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»,
    '''

    def private gettextState(ListFieldItem it) '''
        «app.gettextCall»('«name»') => «app.gettextCall»('«documentation»')'''

    def private gettextActionsPerState(ListFieldItem lastState) '''
        // action titles and descriptions for each state
        'actions' => «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
            «FOR state : states»
                «gettextActionsForState(state)»«IF state != lastState»,«ENDIF»
            «ENDFOR»
        «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»
    '''

    def private gettextActionsForState(ListFieldItem it) '''
        '«value»' => «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
            «actionsForStateImpl»
            «actionsForDestructionImpl»
        «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»
    '''

    def private actionsForStateImpl(ListFieldItem it) {
        switch it.value {
            case 'initial' : actionsForInitial
            case 'deferred' : actionsForDeferred
            case 'waiting' : actionsForWaiting
            case 'accepted' : actionsForAccepted
            case 'approved' : actionsForApproved
            case 'suspended' : actionsForSuspended
            case 'archived' : updateAction
            case 'trashed' : ''
            case 'deleted' : ''
        }
    }

    def private actionsForInitial(ListFieldItem it) '''
        «submitAction»
        «submitAndAcceptAction»
        «submitAndApproveAction»
        «deferAction»
    '''

    def private actionsForDeferred(ListFieldItem it) '''
        «submitAction»
        «updateAction»
    '''

    def private actionsForWaiting(ListFieldItem it) '''
        «updateAction»
        «rejectAction»
        «acceptAction»
        «approveAction»
    '''

    def private actionsForAccepted(ListFieldItem it) '''
        «updateAction»
        «approveAction»
    '''

    def private actionsForApproved(ListFieldItem it) '''
        «updateAction»
        «demoteAction»
        «suspendAction»
        «archiveAction»
    '''

    def private actionsForSuspended(ListFieldItem it) '''
        «updateAction»
        «unsuspendAction»
        «archiveAction»
    '''

    def private deferAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'deferred')»
            «actionImpl('Defer')»
        «ENDIF»
    '''

    def private submitAction(ListFieldItem it) '''
        «actionImpl('Submit')»
    '''

    def private updateAction(ListFieldItem it) '''
        «actionImpl('Update')»
    '''

    def private rejectAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'deferred')»
            «actionImpl('Reject')»
        «ENDIF»
    '''

    def private acceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «actionImpl('Accept')»
        «ENDIF»
    '''

    def private approveAction(ListFieldItem it) '''
        «actionImpl('Approve')»
    '''

    def private submitAndAcceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «actionImpl('Submit and Accept')»
        «ENDIF»
    '''

    def private submitAndApproveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'waiting')»
            «actionImpl('Submit and Approve')»
        «ENDIF»
    '''

    def private demoteAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «actionImpl('Demote')»
        «ENDIF»
    '''

    def private suspendAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'suspended')»
            «actionImpl('Unpublish')»
        «ENDIF»
    '''

    def private unsuspendAction(ListFieldItem it) '''
        «IF it.value == 'suspended'»
            «actionImpl('Publish')»
        «ENDIF»
    '''

    def private archiveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'archived')»
            «actionImpl('Archive')»
        «ENDIF»
    '''

    def private actionsForDestructionImpl(ListFieldItem it) '''
        «IF it.value != 'initial' && it.value != 'deleted'»
            «IF it.value != 'trashed' && app.hasWorkflowState(wfType, 'trashed')»
                «trashAndRecoverActions»
            «ENDIF»
            «deleteAction»
        «ENDIF»
    '''

    def private trashAndRecoverActions(ListFieldItem it) '''
        «actionImpl('Trash')»
        «actionImpl('Recover')»
    '''

    def private deleteAction(ListFieldItem it) '''
        «actionImpl('Delete')»
    '''

    def private actionImpl(String title) '''
        «app.gettextCall»('«title»') => «app.gettextCall»('«getWorkflowActionDescription(wfType, title)»')«IF title != 'Delete'»,«ENDIF»
    '''

    def private gettextCall(Application it) '''«IF targets('1.3.x')»no«ELSE»$translator->__«ENDIF»'''
}
