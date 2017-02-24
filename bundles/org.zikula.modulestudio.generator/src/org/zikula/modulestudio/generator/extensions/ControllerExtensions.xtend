package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.RelationEditType
import de.guite.modulestudio.metamodel.ViewAction

/**
 * This class contains controller related extension methods.
 */
class ControllerExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
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
    def hasIndexAction(Entity it) {
        !actions.filter(MainAction).empty
    }

    /**
     * Checks whether an entity owns a view action.
     */
    def hasViewAction(Entity it) {
        !actions.filter(ViewAction).empty
    }

    /**
     * Checks whether an entity owns a display action.
     */
    def hasDisplayAction(Entity it) {
        !actions.filter(DisplayAction).empty
    }

    /**
     * Checks whether an entity owns an edit action.
     */
    def hasEditAction(Entity it) {
        !actions.filter(EditAction).empty
    }

    /**
     * Checks whether an entity owns a delete action.
     */
    def hasDeleteAction(Entity it) {
        !actions.filter(DeleteAction).empty
    }

    /**
     * Checks whether an entity owns a custom action.
     */
    def hasCustomAction(Entity it) {
        !actions.filter(CustomAction).empty
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
        getAllVariables.filter(IntVar).filter[isUserGroupSelector]
    }

    /**
     * Determines whether the given integer variable instance represents a user group
     * selector for moderation purposes.
     */
    def isUserGroupSelector(IntVar it) {
        if (name.contains('moderationGroupFor')
            || name.contains('superModerationGroupFor')) {
                return true
        }

        false
    }

    /**
     * Returns a list of all custom actions contained by a given entity.
     */
    def getCustomActions(Entity it) {
        actions.filter(CustomAction)
    }

    def getEditingType(JoinRelationship it) {
        switch (it) {
            OneToOneRelationship:
                return editType
            OneToManyRelationship:
                return editType
            ManyToOneRelationship:
                return editType
            ManyToManyRelationship:
                return editType
        }

        RelationEditType.ACTIVE_NONE_PASSIVE_CHOOSE
    }

    /**
     * Retrieves an integer value defining which relation edit type will be implemented.
     * This mapping is done to have a more appropriate logic inside the generator.
     * Possible values are:
     *    0    Nothing is being done
     *    1    Select related object
     *    2    Create and edit related object
     *    3    Combination of 1 and 2
     */
    def dispatch getEditStageCode(JoinRelationship it, Boolean incoming) {
        switch getEditingType {
            case ACTIVE_NONE_PASSIVE_CHOOSE:
                if (!incoming) 0 else 1
            case ACTIVE_NONE_PASSIVE_EDIT:
                if (!incoming) 0 else 3
            case ACTIVE_CHOOSE_PASSIVE_NONE:
                if (!incoming) 2 else 3 // invalid --> default as fall-back
            case ACTIVE_EDIT_PASSIVE_CHOOSE:
                if (!incoming) 2 else 1
            case ACTIVE_EDIT_PASSIVE_EDIT:
                if (!incoming) 2 else 3 // default
            case ACTIVE_EDIT_PASSIVE_NONE:
                if (!incoming) 2 else 3 // invalid --> default as fall-back
            default:
                if (!incoming) 2 else 3
        }
    }

    /**
     * Retrieves an integer value defining which relation edit type will be implemented.
     * This mapping is done to have a more appropriate logic inside the generator.
     * Possible values are:
     *    0    Nothing is being done
     *    1    Select related object
     *    2    Create and edit related object
     *    3    Combination of 1 and 2
     */
    def dispatch getEditStageCode(ManyToManyRelationship it, Boolean incoming) {
        switch editType {
            case ACTIVE_NONE_PASSIVE_CHOOSE:
                if (!incoming) 0 else 1
            case ACTIVE_NONE_PASSIVE_EDIT:
                if (!incoming) 0 else 3
            case ACTIVE_CHOOSE_PASSIVE_NONE:
                if (!incoming) 1 else 0
            case ACTIVE_EDIT_PASSIVE_CHOOSE:
                if (!incoming) 3 else 1
            case ACTIVE_EDIT_PASSIVE_EDIT:
                if (!incoming) 3 else 3 // default
            case ACTIVE_EDIT_PASSIVE_NONE:
                if (!incoming) 3 else 0
            default:
                if (!incoming) 3 else 3
        }
    }
}
