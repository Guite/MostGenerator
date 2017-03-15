package org.zikula.modulestudio.generator.cartridges.zclassic.controller.workflows

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListFieldItem
import java.util.ArrayList
import java.util.HashMap
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

/**
 * Workflow definitions in YAML format.
 */
class Definition {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    Application app
    EntityWorkflowType wfType
    ArrayList<ListFieldItem> states
    HashMap<String, ArrayList<String>> transitionsFrom
    HashMap<String, String> transitionsTo

    IFileSystemAccess fsa
    String outputPath

    /**
     * Entry point for workflow definitions.
     * This generates YML files describing the workflows used in the application.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!targets('1.5')) {
            return
        }
        app = it
        this.fsa = fsa
        outputPath = getResourcesPath + 'workflows/'

        generate(EntityWorkflowType.NONE)
        generate(EntityWorkflowType.STANDARD)
        generate(EntityWorkflowType.ENTERPRISE)
    }

    def private generate(EntityWorkflowType wfType) {
        if (!app.hasWorkflow(wfType)) {
            return
        }

        var fileName = wfType.textualName + '.yml'
        if (app.shouldBeSkipped(outputPath + fileName)) {
            return
        }

        this.wfType = wfType
        // generate only those states which are required by any entity using this workflow type
        this.states = getRequiredStateList(app, wfType)
        this.collectTransitions

        if (app.shouldBeMarked(outputPath + fileName)) {
            fileName = wfType.textualName + '.generated.yml'
        }
        fsa.generateFile(outputPath + fileName, workflowDefinition)
    }

    def private workflowDefinition() '''
        workflow:
            workflows:
                «app.appName.formatForDB»_«wfType.textualName.formatForDB»:
                    type: state_machine
                    marking_store:
                        type: single_state
                        arguments:
                            - workflowState
                    supports:
                        «FOR entity : app.getEntitiesForWorkflow(wfType)»
                            - «app.appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity
                        «ENDFOR»
                    «statesImpl»
                    «actionsImpl»
    '''

    def private statesImpl() '''
        places:
            «FOR state : states»
                - «state.value»
            «ENDFOR»
    '''

    def private actionsImpl() '''
        transitions:
            «FOR transitionKey : transitionsFrom.keySet»
                «transitionKey»:
                    from: «IF transitionsFrom.get(transitionKey).length > 1»[«transitionsFrom.get(transitionKey).join(', ')»]«ELSE»«transitionsFrom.get(transitionKey).join(', ')»«ENDIF»
                    to: «transitionsTo.get(transitionKey)»
            «ENDFOR»
    '''

    def private collectTransitions() {
        transitionsFrom = new HashMap
        transitionsTo = new HashMap
        for (state : states) {
            state.actionsForStateImpl
        }
        for (state : states) {
            state.actionsForDestructionImpl
        }
    }

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
            «addTransition('defer', it.value, 'deferred')»
        «ENDIF»
    '''

    def private submitAction(ListFieldItem it) '''
        «IF wfType == EntityWorkflowType.NONE»
            «addTransition('submit', it.value, 'approved')»
        «ELSE»
            «addTransition('submit', it.value, 'waiting')»
        «ENDIF»
    '''

    def private updateAction(ListFieldItem it) '''
        «addTransition('update' + it.value, it.value, it.value)»
    '''

    def private rejectAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'deferred')»
            «addTransition('reject', it.value, 'deferred')»
        «ENDIF»
    '''

    def private acceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «addTransition('accept', it.value, 'accepted')»
        «ENDIF»
    '''

    def private approveAction(ListFieldItem it) '''
        «addTransition('approve', it.value, 'approved')»
    '''

    def private submitAndAcceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «addTransition('accept', it.value, 'accepted')»
        «ENDIF»
    '''

    def private submitAndApproveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'waiting')»
            «addTransition('approve', it.value, 'approved')»
        «ENDIF»
    '''

    def private demoteAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'accepted')»
            «addTransition('demote', it.value, 'accepted')»
        «ENDIF»
    '''

    def private suspendAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'suspended')»
            «addTransition('unpublish', it.value, 'suspended')»
        «ENDIF»
    '''

    def private unsuspendAction(ListFieldItem it) '''
        «IF it.value == 'suspended'»
            «addTransition('publish', it.value, 'approved')»
        «ENDIF»
    '''

    def private archiveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(wfType, 'archived')»
            «addTransition('archive', it.value, 'archived')»
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
        «addTransition('trash', it.value, 'trashed')»
        «addTransition('recover', 'trashed', it.value)»
    '''

    def private deleteAction(ListFieldItem it) '''
        «addTransition('delete', it.value, 'deleted')»
    '''

    def private addTransition(String id, String state, String nextState) {
        if (!transitionsFrom.containsKey(id)) {
            transitionsFrom.put(id, newArrayList)
        }
        transitionsFrom.get(id).add(state)
        if (!transitionsTo.containsKey(id)) {
            transitionsTo.put(id, nextState)
        } else if (transitionsTo.get(id) != nextState) {
            try {
                throw new Exception('Invalid workflow structure: transition "' + id + '" has two different target states (' + nextState + ', ' + transitionsTo.get(id) + ').')
            } catch (Exception exc) {
                throw new RuntimeException('Invalid workflow structure detected: transition "' + id + '" has two different target states (' + nextState + ', ' + transitionsTo.get(id) + ').', exc)
            }
        }
    }
}
