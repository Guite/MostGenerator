package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import java.util.ArrayList
import de.guite.modulestudio.metamodel.MappedSuperClass

/**
 * This class contains extension methods for workflow-related queries.
 */
class WorkflowExtensions {

    extension ModelInheritanceExtensions = new ModelInheritanceExtensions

    /**
     * Determines whether any entity in the given application uses a certain workflow type.
     */
    def hasWorkflow(Application it, EntityWorkflowType wfType) {
        !getEntitiesForWorkflow(wfType).empty
    }

    /**
     * Returns all entities using the given workflow type.
     */
    def getEntitiesForWorkflow(Application it, EntityWorkflowType wfType) {
        entities.filter(Entity).filter[workflow == wfType]
    }

    /**
     * Checks whether any entity has another workflow than none.
     */
    def dispatch needsApproval(Application it) {
        hasWorkflow(EntityWorkflowType.STANDARD) || hasWorkflow(EntityWorkflowType.ENTERPRISE)
    }

    /**
     * Checks whether an entity has another workflow than none.
     */
    def dispatch needsApproval(Entity it) {
        #[EntityWorkflowType.STANDARD, EntityWorkflowType.ENTERPRISE].contains(workflow)
    }

    /**
     * Returns all states using by ANY entity using the given workflow type.
     */
    def getRequiredStateList(Application it, EntityWorkflowType wfType) {
        var states = new ArrayList<ListFieldItem>
        var stateIds = new ArrayList<String>
        for (entity : getEntitiesForWorkflow(wfType)) {
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
        for (entity : entities.filter(Entity).filter[!isInheriting]) {
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
    def hasWorkflowState(Application it, EntityWorkflowType wfType, String state) {
        hasWorkflow(wfType) && !getEntitiesForWorkflow(wfType).filter[hasWorkflowStateEntity(state)].empty
    }

    /**
     * Determines whether any entity in the given application can have the given state.
     */
    def hasWorkflowState(Application it, String state) {
        !entities.filter(Entity).filter[hasWorkflowStateEntity(state)].empty
    }

    /**
     * Prints an output string corresponding to the given workflow type.
     */
    def textualName(EntityWorkflowType wfType) {
        switch wfType {
            case NONE        : 'none'
            case STANDARD    : 'standard'
            case ENTERPRISE  : 'enterprise'
            default: ''
        }
    }

    /**
     * Prints an output string regarding the approvals needed by a certain workflow type.
     */
    def approvalType(EntityWorkflowType wfType) {
        switch wfType {
            case NONE        : 'no'
            case STANDARD    : 'single'
            case ENTERPRISE  : 'double'
            default: ''
        }
    }

    /**
     * Returns the list field storing the possible workflow states for the given entity. 
     */
    def ListField getWorkflowStateField(DataObject it) {
        if (isInheriting && !(parentType instanceof MappedSuperClass)) {
            parentType.getWorkflowStateField
        } else {
            fields.filter(ListField).filter[name == 'workflowState'].head
        }
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
     * Returns the description for a given workflow action.
     */
    def getWorkflowActionDescription(EntityWorkflowType wfType, String actionTitle) {
        switch actionTitle {
            case 'Defer':               return 'Defer content for later submission.'
            case 'Submit':              return if (wfType == EntityWorkflowType.NONE) 'Submit content.' else 'Submit content for acceptance by a moderator.'
            case 'Update':              return 'Update content.'
            case 'Reject':              return 'Reject content and require improvements.'
            case 'Accept':              return 'Accept content for editors approval.'
            case 'Approve':             return 'Update content and approve for immediate publishing.'
            case 'Submit and Accept':   return 'Submit content and accept immediately.'
            case 'Submit and Approve':  return 'Submit content and approve immediately.'
            case 'Demote':              return 'Disapprove content.'
            case 'Unpublish':           return 'Hide content temporarily.'
            case 'Publish':             return 'Make content available again.'
            case 'Archive':             return 'Move content into the archive.'
            case 'Unarchive':           return 'Move content out of the archive.'
            case 'Trash':               return 'Move content into the recycle bin.'
            case 'Recover':             return 'Recover content from the recycle bin.'
            case 'Delete':              return 'Delete content permanently.'
        }
        return ''
    }

    /**
     * Determines whether workflow state field should be visible for the given entity or not.
     */
    def hasVisibleWorkflow(Entity it) {
        workflow != EntityWorkflowType.NONE || ownerPermission || hasTray || hasArchive
    }
}
