package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListFieldItem
import java.util.ArrayList
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

/**
 * Legacy workflow definitions in XML format.
 */
class LegacyDefinition {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    Application app
    EntityWorkflowType wfType
    ArrayList<ListFieldItem> states

    IFileSystemAccess fsa
    String outputPath

    /**
     * Entry point for legacy workflow definitions.
     * This generates XML files describing the workflows used in the application.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.4-dev')) {
            return
        }
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

        var fileName = wfType.textualName + '.xml'
        if (app.shouldBeSkipped(outputPath + fileName)) {
            return
        }

        this.wfType = wfType
        // generate only those states which are required by any entity using this workflow type
        this.states = getRequiredStateList(app, wfType)

        if (app.shouldBeMarked(outputPath + fileName)) {
            fileName = wfType.textualName + '.generated.xml'
        }
        fsa.generateFile(outputPath + fileName, xmlSchema)
    }

    def private xmlSchema() '''
        <?xml version="1.0" encoding="UTF-8"?>
        <workflow>
            «workflowInfo»
            «statesImpl»
            «actionsImpl»
        </workflow>
    '''

    def private workflowInfo() '''
        <title>«wfType.textualName.formatForDisplayCapital» workflow («wfType.approvalType.formatForDisplay» approval)</title>
        <description>«workflowDescription(wfType)»</description>
    '''

    def workflowDescription(EntityWorkflowType wfType) {
        switch wfType {
            case NONE: 'This is like a non-existing workflow. Everything is online immediately after creation.'
            case STANDARD: 'This is a two staged workflow with stages for untrusted submissions and finally approved publications. It does not allow corrections of non-editors to published pages.'
            case ENTERPRISE: 'This is a three staged workflow with stages for untrusted submissions, acceptance by editors, and approval control by a superior editor; approved publications are handled by authors staff.'
        }
    }

    def private statesImpl() '''
        <!-- define the available states -->
        <states>
            «FOR state : states»
                «state.stateImpl»
            «ENDFOR»
        </states>
    '''

    def private stateImpl(ListFieldItem it) '''
        <state id="«value»">
            <title>«name»</title>
            <description>«documentation»</description>
        </state>
    '''

    def private actionsImpl() '''
        <!-- define actions and assign their availability to certain states -->
        <!-- available permissions: overview, read, comment, moderate, edit, add, delete, admin -->
        <actions>
            «FOR state : states»
                <!-- From state: «state.name» -->
                «state.actionsForStateImpl»
            «ENDFOR»

            <!-- Actions for destroying objects -->
            «FOR state : states»
                «state.actionsForDestructionImpl»
            «ENDFOR»
        </actions>
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
        «deferAction»
        «submitAction»
        «submitAndAcceptAction»
        «submitAndApproveAction»
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
            «val permission = if (wfType == EntityWorkflowType.NONE) 'edit' else 'comment'»
            «actionImpl('defer', 'Defer', permission, it.value, 'deferred')»
        «ENDIF»
    '''

    def private submitAction(ListFieldItem it) '''
        «IF wfType == EntityWorkflowType.NONE»
            «actionImpl('submit', 'Submit', 'edit', it.value, 'approved')»
        «ELSE»
            «actionImpl('submit', 'Submit', 'comment', it.value, 'waiting')»
        «ENDIF»
    '''

    def private updateAction(ListFieldItem it) '''
        «actionImpl('update', 'Update', 'edit', it.value, it.value)»
    '''

    def private rejectAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'deferred')»
            «actionImpl('reject', 'Reject', 'edit', it.value, 'deferred')»
        «ENDIF»
    '''

    def private acceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «actionImpl('accept', 'Accept', 'edit', it.value, 'accepted')»
        «ENDIF»
    '''

    def private approveAction(ListFieldItem it) '''
        «actionImpl('approve', 'Approve', 'add', it.value, 'approved')»
    '''

    def private submitAndAcceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «actionImpl('accept', 'Submit and Accept', 'edit', it.value, 'accepted')»
        «ENDIF»
    '''

    def private submitAndApproveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'waiting')»
            «actionImpl('approve', 'Submit and Approve', 'add', it.value, 'approved')»
        «ENDIF»
    '''

    def private demoteAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «actionImpl('demote', 'Demote', 'add', it.value, 'accepted')»
        «ENDIF»
    '''

    def private suspendAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'suspended')»
            «actionImpl('unpublish', 'Unpublish', 'edit', it.value, 'suspended')»
        «ENDIF»
    '''

    def private unsuspendAction(ListFieldItem it) '''
        «IF it.value == 'suspended'»
            «actionImpl('publish', 'Publish', 'edit', it.value, 'approved')»
        «ENDIF»
    '''

    def private archiveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'archived')»
            «actionImpl('archive', 'Archive', 'edit', it.value, 'archived')»
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
        «actionImpl('trash', 'Trash', 'edit', it.value, 'trashed')»
        «actionImpl('recover', 'Recover', 'edit', 'trashed', it.value)»
    '''

    def private deleteAction(ListFieldItem it) '''
        «actionImpl('delete', 'Delete', 'delete', it.value, 'deleted')»
    '''

    def private actionImpl(String id, String title, String permission, String state, String nextState) '''
        <action id="«id»">
            <title>«title»</title>
            <description>«getWorkflowActionDescription(wfType, title)»</description>
            <permission>«permission»</permission>
            «IF state != '' && state != 'initial'»
                <state>«state»</state>
            «ENDIF»
            «IF nextState != '' && nextState != state»
                <nextState>«nextState»</nextState>
            «ENDIF»

            «IF id == 'delete'»
                <operation>delete</operation>
            «ELSE»
                <operation>update</operation>
            «ENDIF»
            «IF wfType != EntityWorkflowType.NONE»
                «notifyCall(id, nextState)»
            «ENDIF»
        </action>

    '''

    def private notifyCall(String id, String state) '''
        «IF id == 'submit' && state == 'waiting'»
            <operation recipientType="moderator" action="«id»">notify</operation>
        «ELSEIF id == 'reject' && state == 'deferred'»
            <operation recipientType="creator" action="«id»">notify</operation>
        «ELSEIF id == 'accept' && state == 'accepted'»
            <operation recipientType="creator" action="«id»">notify</operation>
            <operation recipientType="superModerator" action="«id»">notify</operation>
        «ELSEIF id == 'approve' && state == 'approved'»
            <operation recipientType="creator" action="«id»">notify</operation>
            «IF wfType == EntityWorkflowType.ENTERPRISE»
                <operation recipientType="moderator" action="«id»">notify</operation>
            «ENDIF»
        «ELSEIF id == 'demote' && state == 'accepted'»
            <operation recipientType="moderator" action="«id»">notify</operation>
        «ELSEIF id == 'unpublish' && state == 'suspended'»
            <operation recipientType="creator" action="«id»">notify</operation>
        «ELSEIF id == 'publish' && state == 'approved'»
            <operation recipientType="creator" action="«id»">notify</operation>
        «ELSEIF id == 'archive' && state == 'archived'»
            <operation recipientType="creator" action="«id»">notify</operation>
        «ELSEIF id == 'trash' && state == 'trashed'»
            <operation recipientType="creator" action="«id»">notify</operation>
        «ELSEIF id == 'recover'»
            <operation recipientType="creator" action="«id»">notify</operation>
        «ELSEIF id == 'delete'»
            <operation recipientType="creator" action="«id»">notify</operation>
        «ENDIF»

        <!-- example for custom recipient type using designated entity fields: -->
        <!-- operation recipientType="field-email^lastname" action="submit">notify</operation -->
    '''
}
