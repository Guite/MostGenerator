package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions
import java.util.ArrayList

/**
 * Workflow definitions in xml format.
 */
class Definition {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension WorkflowExtensions = new WorkflowExtensions

    Application app
    EntityWorkflowType wfType
    ArrayList<ListFieldItem> states

    IFileSystemAccess fsa
    String outputPath

    /**
     * Entry point for workflow definitions.
     * This generates xml files describing the workflows used in the application.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        app = it
        this.fsa = fsa
        outputPath = getAppSourcePath + 'workflows/'

        generate(EntityWorkflowType::NONE)
        generate(EntityWorkflowType::STANDARD)
        generate(EntityWorkflowType::ENTERPRISE)
    }

    def private generate(EntityWorkflowType wfType) {
        if (!app.hasWorkflow(wfType)) {
            return
        }

        this.wfType = wfType
        // generate only those states which are required by any entity using this workflow type
        this.states = getRequiredStateList(app, wfType)
        fsa.generateFile(outputPath + wfType.textualName + '.xml', xmlSchema)
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
        switch (wfType) {
            case EntityWorkflowType::NONE: 'This is like a non-existing workflow. Everything is online immediately after creation.'
            case EntityWorkflowType::STANDARD: 'This is a two staged workflow with stages for untrusted submissions and finally approved publications. It does not allow corrections of non-editors to published pages.'
            case EntityWorkflowType::ENTERPRISE: 'This is a three staged workflow with stages for untrusted submissions, acceptance by editors, and approval control by a superior editor; approved publications are handled by authors staff.'
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
        switch (it.value) {
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
            «val permission = if (wfType == EntityWorkflowType::NONE) 'edit' else 'comment'»
            «actionImpl('defer', 'Defer', permission, it.value, 'deferred')»
        «ENDIF»
    '''

    def private submitAction(ListFieldItem it) '''
        «IF wfType == EntityWorkflowType::NONE»
            «actionImpl('submit', 'Submit', 'edit', it.value, 'approved')»
        «ELSE»
            «/*operations = update + '<operation group="moderators" action="create">notify</operation>'*/»
            «actionImpl('submit', 'Submit', 'comment', it.value, 'waiting')»
        «ENDIF»
    '''

    def private updateAction(ListFieldItem it) '''
        «actionImpl('update', 'Update', 'edit', it.value, it.value)»
    '''

    def private rejectAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'deferred')»
            «/*operations = update + '<operation group="authors" action="promote">notify</operation>'*/»
            «actionImpl('reject', 'Reject', 'edit', it.value, 'deferred')»
        «ENDIF»
    '''

    def private acceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «/*operations = update + '<operation group="editors" action="promote">notify</operation>'*/»
            «actionImpl('accept', 'Accept', 'edit', it.value, 'accepted')»
        «ENDIF»
    '''

    def private approveAction(ListFieldItem it) '''
        «/*operations = update + '<operation group="authors/editors" action="promote">notify</operation>'*/»
        «actionImpl('approve', 'Approve', 'add', it.value, 'approved')»
    '''

    def private submitAndAcceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «/*operations = update + '<operation group="editors" action="create">notify</operation>'*/»
            «actionImpl('accept', 'Submit and Accept', 'edit', it.value, 'accepted')»
        «ENDIF»
    '''

    def private submitAndApproveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'waiting')»
            «/*operations = update + '<operation group="editors" action="create">notify</operation>'*/»
            «actionImpl('approve', 'Submit and Approve', 'add', it.value, 'approved')»
        «ENDIF»
    '''

    def private demoteAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «/*operations = update + '<operation group="editors" action="demote">notify</operation>'*/»
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
        «actionImpl('delete', 'Delete', 'delete', it.value, '')»
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
        </action>

    '''
}
