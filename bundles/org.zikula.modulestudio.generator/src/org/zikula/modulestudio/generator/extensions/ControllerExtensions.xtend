package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.DetailAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.IndexAction
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.RelationEditMode

/**
 * This class contains controller related extension methods.
 */
class ControllerExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension Utils = new Utils

    /**
     * Returns name of container (entity). 
     */
    def controllerName(Action it) {
        if (null !== entity) {
            entity.name.formatForCode
        }
        name.formatForDB
    }

    /**
     * Checks whether an entity owns an index action.
     */
    def Boolean hasIndexAction(Entity it) {
        !actions.filter(IndexAction).empty || (isInheriting && parentType instanceof Entity && (parentType as Entity).hasIndexAction)
    }

    /**
     * Checks whether an entity owns a display action.
     */
    def Boolean hasDetailAction(Entity it) {
        !actions.filter(DetailAction).empty || (isInheriting && parentType instanceof Entity && (parentType as Entity).hasDetailAction)
    }

    /**
     * Checks whether an entity owns an edit action.
     */
    def Boolean hasEditAction(Entity it) {
        !actions.filter(EditAction).empty || (isInheriting && parentType instanceof Entity && (parentType as Entity).hasEditAction)
    }

    /**
     * Checks whether an entity owns a delete action.
     */
    def Boolean hasDeleteAction(Entity it) {
        !actions.filter(DeleteAction).empty || (isInheriting && parentType instanceof Entity && (parentType as Entity).hasDeleteAction)
    }

    /**
     * Checks whether an entity owns a custom action.
     */
    def Boolean hasCustomAction(Entity it) {
        !actions.filter(CustomAction).empty || (isInheriting && parentType instanceof Entity && (parentType as Entity).hasCustomAction)
    }

    /**
     * Returns all actions for a given entity.
     */
    def getAllEntityActions(Entity it) {
        getSelfAndParentDataObjects.filter(Entity).map[actions].flatten
    }

    /**
     * Determines the default action used for linking to a certain entity.
     */
    def defaultAction(Entity it) '''«IF hasDetailAction»detail«ELSEIF hasIndexAction»index«ELSE»«actions.head.name.formatForCode»«ENDIF»'''

    def getPrimaryAction(Entity it) {
        if (hasIndexAction) {
            return 'index'
        }

        return actions.head.name.formatForDB
    }

    def getPermissionAccessLevel(DataObject it, Action action) {
        switch action {
            IndexAction: 'ACCESS_OVERVIEW'
            DetailAction: 'ACCESS_READ'
            EditAction: if (it instanceof Entity && (it as Entity).workflow != EntityWorkflowType.NONE) 'ACCESS_COMMENT' else 'ACCESS_EDIT'
            DeleteAction: 'ACCESS_DELETE'
            CustomAction: 'ACCESS_OVERVIEW'
            default: 'ACCESS_ADMIN'
        }
    }

    /**
     * Checks whether the application has at least one index action or not.
     */
    def hasIndexActions(Application it) {
        !getIndexActions.empty
    }

    /**
     * Returns a list of all index actions in the given application.
     */
    def getIndexActions(Application it) {
        getAllEntities.map[actions].flatten.filter(IndexAction)
    }

    /**
     * Checks whether the application has at least one detail action or not.
     */
    def hasDetailActions(Application it) {
        !getDetailActions.empty
    }

    /**
     * Returns a list of all detail actions in the given application.
     */
    def getDetailActions(Application it) {
        getAllEntities.map[actions].flatten.filter(DetailAction)
    }

    /**
     * Checks whether the application has at least one edit action or not.
     */
    def hasEditActions(Application it) {
        !getEditActions.empty
    }

    /**
     * Returns a list of all edit actions in the given application.
     */
    def getEditActions(Application it) {
        getAllEntities.map[actions].flatten.filter(EditAction)
    }

    /**
     * Checks whether the application has at least one delete action or not.
     */
    def hasDeleteActions(Application it) {
        !getDeleteActions.empty
    }

    /**
     * Returns a list of all delete actions in the given application.
     */
    def getDeleteActions(Application it) {
        getAllEntities.map[actions].flatten.filter(DeleteAction)
    }

    /**
     * Returns whether variables contain any user group selectors or not.
     */
    def hasUserGroupSelectors(Application it) {
        !getUserGroupSelectors.empty
    }

    /**
     * Returns all variables acting as user group selectors.
     */
    def getUserGroupSelectors(Application it) {
        getAllVariables.filter(IntegerField).filter[isUserGroupSelector]
    }

    /**
     * Checks if the given field is a special case where an integer field
     * may not only contain integers.
     */
    def notOnlyNumericInteger(DerivedField it) {
        it instanceof IntegerField && (it as IntegerField).isUserGroupSelector
    }

    /**
     * Determines whether the given integer field instance represents a user group
     * selector variable for moderation purposes.
     */
    def isUserGroupSelector(IntegerField it) {
        if (null !== entity) {
            return false
        }
        if (name.contains('moderationGroupFor')
            || name.contains('superModerationGroupFor')) {
                return true
        }

        false
    }

    def getSourceEditMode(JoinRelationship it) {
        switch it {
            OneToOneRelationship:
                return sourceEditing
            OneToManyRelationship:
                return sourceEditing
            ManyToOneRelationship:
                return sourceEditing
            ManyToManyRelationship:
                return sourceEditing
        }

        RelationEditMode.NONE
    }

    def getTargetEditMode(JoinRelationship it) {
        switch it {
            OneToOneRelationship:
                return targetEditing
            OneToManyRelationship:
                return targetEditing
            ManyToManyRelationship:
                return targetEditing
        }

        RelationEditMode.NONE
    }

    /**
     * Retrieves an integer value defining which relation edit type will be implemented.
     * This mapping is done to have a more appropriate logic inside the generator.
     * Possible values are:
     *    0    Nothing is being done
     *    1    Select related objects
     *    2    Select related objects including inline creation and editing
     *    3    Embedded editing
     */
    def getEditStageCode(JoinRelationship it, Boolean incoming) {
        switch if (incoming) getTargetEditMode else getSourceEditMode {
            case NONE:
                0
            case CHOOSE:
                1
            case INLINE:
                2
            case EMBEDDED:
                3
            default:
                0
        }
    }

    /**
     * Checks for whether a certain relationship side uses auto completion or not.
     */
    def usesAutoCompletion(JoinRelationship it, boolean useTarget) {
        switch it.useAutoCompletion {
            case NONE: false
            case ONLY_SOURCE_SIDE: !useTarget
            case ONLY_TARGET_SIDE: useTarget
            case BOTH_SIDES: true
            default: false
        }
    }

    /**
     * Returns an internal name for the field type used for a relationship side
     * with in-line editing enabled.
     */
    def getFieldTypeForInlineEditing(JoinRelationship it, Boolean incoming) {
        if (usesAutoCompletion(!incoming)) {
            return 'autocomplete'
        }
        val isMultiValued = isManySide(!incoming)
        if ((incoming && !expandedSource) || (!incoming && !expandedTarget)) {
            return 'select-' + (if (isMultiValued) 'multi' else 'single')
        }
        if (isMultiValued) {
            return 'checkbox'
        }
        return 'radio'
    }

    /**
     * Checks whether inline editing is required or not.
     */
    def needsInlineEditing(Application it) {
        !getJoinRelations.filter[getEditStageCode(false) == 2 || getEditStageCode(true) == 2].empty
    }
}
