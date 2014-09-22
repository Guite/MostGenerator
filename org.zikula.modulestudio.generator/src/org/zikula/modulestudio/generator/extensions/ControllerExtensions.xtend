package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.DeleteAction
import de.guite.modulestudio.metamodel.DisplayAction
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.MainAction
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.UserController
import de.guite.modulestudio.metamodel.ViewAction

/**
 * This class contains controller related extension methods.
 */
class ControllerExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    /**
     * Makes a controller name lowercase. 
     */
    def formattedName(Controller it) {
        name.formatForDB
    }

    /**
     * Returns name of container (controller or entity). 
     */
    def controllerName(Action it) {
        if (controller !== null) {
            controller.formattedName
        } else if (entity !== null) {
            entity.name.formatForCode
        }
        name.formatForDB
    }

    /**
     * Returns a list of all user controllers in the given application.
     */
    def getAllUserControllers(Application it) {
        controllers.filter(UserController)
    }
    /**
     * Checks whether the application has an user controller or not.
     */
    def hasUserController(Application it) {
        !getAllUserControllers.empty
    }
    /**
     * Returns the default user controller.
     */
    def getMainUserController(Application it) {
        getAllUserControllers.head
    }

    /**
     * Returns a list of all admin controllers in the given application.
     */
    def getAllAdminControllers(Application it) {
        controllers.filter(AdminController)
    }
    /**
     * Checks whether the application has an admin controller or not.
     */
    def hasAdminController(Application it) {
        !getAllAdminControllers.empty
    }

    /**
     * Checks whether a controller owns actions of a given type.
     */
    def dispatch hasActions(Controller it, String type) {
        switch type {
            case 'index'    : !actions.filter(MainAction).empty 
            case 'view'     : !actions.filter(ViewAction).empty 
            case 'display'  : !actions.filter(DisplayAction).empty 
            case 'edit'     : !actions.filter(EditAction).empty
            case 'delete'   : !actions.filter(DeleteAction).empty
            case 'custom'   : !actions.filter(CustomAction).empty 
            default : false
        }
    }

    /**
     * Temporary bridge from legacy to entity controllers.
     */
    def private hasActionsBridge(Controller it, String type) {
        val allEntityActions = application.getAllEntities.map[actions]
        switch type {
            case 'index'    : !actions.filter(MainAction).empty || allEntityActions.filter(MainAction).empty 
            case 'view'     : application.hasViewActions 
            case 'display'  : application.hasDisplayActions 
            case 'edit'     : application.hasEditActions
            case 'delete'   : application.hasDeleteActions
            case 'custom'   : !actions.filter(CustomAction).empty || !allEntityActions.filter(CustomAction).empty
            default : false
        }
    }

    def dispatch hasActions(AdminController it, String type) {
        hasActionsBridge(type)
    }

    /**
     * Temporary bridge from legacy to entity controllers.
     */
    def dispatch hasActions(UserController it, String type) {
        hasActionsBridge(type)
    }

    /**
     * Returns a list of all actions in the user controller.
     * Cares for BC by collecting all distinct entity actions, too.
     */
    def getAllUserActions(UserController it) {
        var allActions = newArrayList
        allActions += actions.map[name.formatForCode.toFirstLower]
        if (application.hasViewActions) {
            allActions += 'view'
        }
        if (application.hasDisplayActions) {
            allActions += 'display'
        }
        if (application.hasEditActions) {
            allActions += 'edit'
        }
        if (application.hasDeleteActions) {
            allActions += 'delete'
        }

        allActions
    }

    /**
     * Checks whether an entity owns actions of a given type.
     */
    def dispatch hasActions(Entity it, String type) {
        switch type {
            case 'index'    : !actions.filter(MainAction).empty 
            case 'view'     : !actions.filter(ViewAction).empty 
            case 'display'  : !actions.filter(DisplayAction).empty 
            case 'edit'     : !actions.filter(EditAction).empty
            case 'delete'   : !actions.filter(DeleteAction).empty
            case 'custom'   : !actions.filter(CustomAction).empty 
            default : false
        }
    }

    /**
     * Determines the default action used for linking to a certain entity.
     */
    def defaultAction(Entity it) '''«IF hasActions('display')»display«ELSEIF hasActions('view')»view«ELSE»«IF application.targets('1.3.5')»main«ELSE»index«ENDIF»«ENDIF»'''

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
        controllers.map[actions].flatten.filter(ViewAction) + getAllEntities.map[actions].flatten.filter(ViewAction)
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
        controllers.map[actions].flatten.filter(DisplayAction) + getAllEntities.map[actions].flatten.filter(DisplayAction)
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
        controllers.map[actions].flatten.filter(EditAction) + getAllEntities.map[actions].flatten.filter(EditAction)
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
        controllers.map[actions].flatten.filter(DeleteAction) + getAllEntities.map[actions].flatten.filter(DeleteAction)
    }

    /**
     * Get a list of only admin and user controllers.
     */
    def getAdminAndUserControllers(Application it) {
        controllers.filter(AdminController) + controllers.filter(UserController)
    }

    /**
     * Determines the controller in which the config action is living.
     */
    def configController(Application it) {
        if (!getAllAdminControllers.empty)
            getAllAdminControllers.head.formattedName
        else
            if (!getAllUserControllers.empty)
                getMainUserController.formattedName
            else
                controllers.head.formattedName
    }

    /**
     * Checks for whether the given controller is responsible for the config action.
     */
    def isConfigController(Controller it) {
        application.configController == formattedName
    }

    /**
     * Determines whether the given int var instance represents a user group selector
     * for moderation purposes.
     */
    def isUserGroupSelector(IntVar it) {
        if (name.contains('moderationGroupFor')
            || name.contains('superModerationGroupFor')) {
                return true
        }

        false
    }

    /**
     * Returns a list of all custom actions contained by a given controller.
     */
    def getCustomActions(Controller it) {
        actions.filter(CustomAction)
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
        switch editType {
            case ACTIVE_NONE_PASSIVE_CHOOSE:
                if (!incoming) 0 else 1
            case ACTIVE_NONE_PASSIVE_EDIT:
                if (!incoming) 0 else 3
            case ACTIVE_CHOOSE_PASSIVE_NONE:
                if (!incoming) 2 else 3 // invalid --> default as fallback
            case ACTIVE_EDIT_PASSIVE_CHOOSE:
                if (!incoming) 2 else 1
            case ACTIVE_EDIT_PASSIVE_EDIT:
                if (!incoming) 2 else 3 // default
            case ACTIVE_EDIT_PASSIVE_NONE:
                if (!incoming) 2 else 3 // invalid --> default as fallback
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
