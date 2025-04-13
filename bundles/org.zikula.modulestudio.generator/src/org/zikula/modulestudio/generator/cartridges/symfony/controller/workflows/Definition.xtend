package org.zikula.modulestudio.generator.cartridges.symfony.controller.workflows

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ListFieldItem
import java.util.ArrayList
import java.util.HashMap
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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
    boolean withApproval
    ArrayList<ListFieldItem> states
    HashMap<String, ArrayList<String>> transitionsFrom
    HashMap<String, String> transitionsTo

    IMostFileSystemAccess fsa
    String outputPath

    /**
     * Entry point for workflow definitions.
     * This generates YML files describing the workflows used in the application.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        app = it
        this.fsa = fsa
        outputPath = getResourcesPath + 'workflows/'

        generate(false)
        generate(true)
    }

    def private generate(boolean withApproval) {
        if (!app.hasWorkflow(withApproval)) {
            return
        }

        this.withApproval = withApproval
        // generate only those states which are required by any entity using this workflow type
        this.states = getRequiredStateList(app, withApproval)
        this.collectTransitions

        val fileName = withApproval.textualName + '.yaml'
        fsa.generateFile(outputPath + fileName, workflowDefinition)
    }

    def private workflowDefinition() '''
        framework:
            workflows:
                «app.appName.formatForDB»_«withApproval.textualName.formatForDB»:
                    type: state_machine
                    marking_store:
                        type: method
                        property: workflowState
                    supports:
                        «FOR entity : app.getEntitiesForWorkflow(withApproval)»
                            - «app.appNamespace»\Entity\«entity.name.formatForCodeCapital»
                        «ENDFOR»
                    «/*initial_marking: [initial]*/»«statesImpl»
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
                - name: «IF transitionKey.startsWith('update')»update«ELSEIF transitionKey.startsWith('trash')»trash«ELSEIF transitionKey.startsWith('recover')»recover«ELSE»«transitionKey»«ENDIF»
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
            case 'archived' : actionsForArchived
            // done in actionsForDestructionImpl below
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
        «archiveAction»
    '''

    def private actionsForArchived(ListFieldItem it) '''
        «updateAction»
        «unarchiveAction»
    '''

    def private deferAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(withApproval, 'deferred')»
            «addTransition('defer', it.value, 'deferred')»
        «ENDIF»
    '''

    def private submitAction(ListFieldItem it) '''
        «IF !withApproval»
            «addTransition('submit', it.value, 'approved')»
        «ELSE»
            «addTransition('submit', it.value, 'waiting')»
        «ENDIF»
    '''

    def private updateAction(ListFieldItem it) '''
        «addTransition('update', it.value, it.value)»
    '''

    def private rejectAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(withApproval, 'deferred')»
            «addTransition('reject', it.value, 'deferred')»
        «ENDIF»
    '''

    def private acceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(withApproval, 'accepted')»
            «addTransition('accept', it.value, 'accepted')»
        «ENDIF»
    '''

    def private approveAction(ListFieldItem it) '''
        «addTransition('approve', it.value, 'approved')»
    '''

    def private submitAndAcceptAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(withApproval, 'accepted')»
            «addTransition('accept', it.value, 'accepted')»
        «ENDIF»
    '''

    def private submitAndApproveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(withApproval, 'waiting')»
            «addTransition('approve', it.value, 'approved')»
        «ENDIF»
    '''

    def private demoteAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(withApproval, 'accepted')»
            «addTransition('demote', it.value, 'accepted')»
        «ENDIF»
    '''

    def private archiveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(withApproval, 'archived')»
            «addTransition('archive', it.value, 'archived')»
        «ENDIF»
    '''

    def private unarchiveAction(ListFieldItem it) '''
        «IF app.hasWorkflowState(withApproval, 'archived')»
            «addTransition('unarchive', it.value, 'approved')»
        «ENDIF»
    '''

    def private actionsForDestructionImpl(ListFieldItem it) '''
        «IF it.value != 'initial' && it.value != 'deleted'»
            «deleteAction»
        «ENDIF»
    '''

    def private deleteAction(ListFieldItem it) '''
        «addTransition('delete', it.value, 'deleted')»
    '''

    def private addTransition(String id, String state, String nextState) {
        var uniqueKey = id
        if (id.startsWith('update') || id.startsWith('trash') || id.startsWith('recover')) {
            uniqueKey = id + state
        }
        if (!transitionsFrom.containsKey(uniqueKey)) {
            transitionsFrom.put(uniqueKey, newArrayList)
        }
        transitionsFrom.get(uniqueKey).add(state)
        if (!transitionsTo.containsKey(uniqueKey)) {
            transitionsTo.put(uniqueKey, nextState)
        } else if (transitionsTo.get(uniqueKey) != nextState) {
            try {
                throw new Exception('Invalid workflow structure: transition "' + id + '" (' + uniqueKey + ') has two different target states (' + nextState + ', ' + transitionsTo.get(id) + ').')
            } catch (Exception exception) {
                throw new RuntimeException('Invalid workflow structure detected: transition "' + id + '" (' + uniqueKey + ') has two different target states (' + nextState + ', ' + transitionsTo.get(id) + ').', exception)
            }
        }
    }
}
