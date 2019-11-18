package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.RelationEditMode
import de.guite.modulestudio.metamodel.ViewAction

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
        !actions.filter(MainAction).empty || (isInheriting && parentType instanceof Entity && (parentType as Entity).hasIndexAction)
    }

    /**
     * Checks whether an entity owns a view action.
     */
    def Boolean hasViewAction(Entity it) {
        !actions.filter(ViewAction).empty || (isInheriting && parentType instanceof Entity && (parentType as Entity).hasViewAction)
    }

    /**
     * Checks whether an entity owns a display action.
     */
    def Boolean hasDisplayAction(Entity it) {
        !actions.filter(DisplayAction).empty || (isInheriting && parentType instanceof Entity && (parentType as Entity).hasDisplayAction)
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
    def defaultAction(Entity it) '''«IF hasDisplayAction»display«ELSEIF hasViewAction»view«ELSEIF hasIndexAction»index«ELSE»«actions.head.name.formatForCode»«ENDIF»'''

    def getPrimaryAction(Entity it) {
        if (hasIndexAction) {
            return 'index'
        }
        if (hasViewAction) {
            return 'view'
        }

        return actions.head.name.formatForDB
    }

    /**
     * Checks whether the application has at least one view action or not.
     */
    def hasViewActions(Application it) {
        !getViewActions.empty
    }

    /**
     * Returns a list of all view actions in the given application.
     */
    def getViewActions(Application it) {
        getAllEntities.map[actions].flatten.filter(ViewAction)
    }

    /**
     * Checks whether the application has at least one display action or not.
     */
    def hasDisplayActions(Application it) {
        !getDisplayActions.empty
    }

    /**
     * Returns a list of all display actions in the given application.
     */
    def getDisplayActions(Application it) {
        getAllEntities.map[actions].flatten.filter(DisplayAction)
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
        hasUiHooksProviders || !getJoinRelations.filter[getEditStageCode(false) == 2 || getEditStageCode(true) == 2].empty
    }
}
