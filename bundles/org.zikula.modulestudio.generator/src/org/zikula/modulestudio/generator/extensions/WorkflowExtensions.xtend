package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import java.util.ArrayList

/**
 * This class contains extension methods for workflow-related queries.
 */
class WorkflowExtensions {

    /**
     * Determines whether any entity in the given application uses a certain workflow type.
     */
    def hasWorkflow(Application it, boolean withApproval) {
        !getEntitiesForWorkflow(withApproval).empty
    }

    /**
     * Checks whether any entities need approval.
     */
    def needsApproval(Application it) {
        hasWorkflow(true)
    }

    /**
     * Returns all entities using the given workflow type.
     */
    def getEntitiesForWorkflow(Application it, boolean withApproval) {
        entities.filter[approval == withApproval]
    }

    /**
     * Returns all states using by ANY entity using the given workflow type.
     */
    def getRequiredStateList(Application it, boolean withApproval) {
        var states = new ArrayList<ListFieldItem>
        var stateIds = new ArrayList<String>
        for (entity : getEntitiesForWorkflow(withApproval)) {
            for (item : entity.getWorkflowStateField.items) {
                if (!stateIds.contains(item.value)) {
                    states.add(item)
                    stateIds.add(item.value)
                }
            }
        }
        states
    }

    /**
     * Returns all states using by ANY entity using any workflow type.
     */
    def getRequiredStateList(Application it) {
        var states = new ArrayList<ListFieldItem>
        var stateIds = new ArrayList<String>
        for (entity : entities) {
            for (item : entity.getWorkflowStateField.items) {
                if (!stateIds.contains(item.value)) {
                    states.add(item)
                    stateIds.add(item.value)
                }
            }
        }
        states
    }

    /**
     * Determines whether any entity in the given application using a certain workflow can have the given state.
     */
    def hasWorkflowState(Application it, boolean withApproval, String state) {
        hasWorkflow(withApproval) && !getEntitiesForWorkflow(withApproval).filter[hasWorkflowStateEntity(state)].empty
    }

    /**
     * Determines whether any entity in the given application can have the given state.
     */
    def hasWorkflowState(Application it, String state) {
        !entities.filter[hasWorkflowStateEntity(state)].empty
    }

    /**
     * Prints an output string corresponding to the corresponding workflow type.
     */
    def textualName(boolean approval) {
        if (approval) 'standard' else 'none'
    }

    /**
     * Returns the list field storing the possible workflow states for the given entity. 
     */
    def ListField getWorkflowStateField(Entity it) {
        fields.filter(ListField).filter[name == 'workflowState'].head
    }

    /**
     * Determines whether the given entity has the given workflow state or not.
     */
    def hasWorkflowStateEntity(Entity it, String state) {
        !getWorkflowStateItems(state).empty
    }

    /**
     * Retrieves a certain workflow state.
     */
    def getWorkflowStateItem(Entity it, String state) {
        getWorkflowStateItems(state).head
    }

    /**
     * Determines a list of desired workflow states.
     */
    def private getWorkflowStateItems(Entity it, String state) {
        getWorkflowStateField.items.filter[value == state.toLowerCase]
    }

    /**
     * Determines whether workflow state field should be visible for the given entity or not.
     */
    def hasVisibleWorkflow(Entity it) {
        approval || ownerPermission || hasArchive
    }
}
