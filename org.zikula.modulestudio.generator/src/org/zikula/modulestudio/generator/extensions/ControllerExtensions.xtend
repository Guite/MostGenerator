package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Controllers
import de.guite.modulestudio.metamodel.modulestudio.CustomAction
import de.guite.modulestudio.metamodel.modulestudio.DeleteAction
import de.guite.modulestudio.metamodel.modulestudio.DisplayAction
import de.guite.modulestudio.metamodel.modulestudio.EditAction
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.MainAction
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.UserController
import de.guite.modulestudio.metamodel.modulestudio.ViewAction

import static de.guite.modulestudio.metamodel.modulestudio.RelationEditType.*

/**
 * This class contains controller related extension methods.
 */
class ControllerExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    /**
     * Makes a controller name lowercase. 
     */
    def formattedName(Controller it) {
        name.formatForDB
    }

    /**
     * Returns a list of all user controllers in the given application.
     */
    def getAllUserControllers(Application it) {
        getAllControllers.filter(UserController)
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
        getAllControllers.filter(AdminController)
    }
    /**
     * Checks whether the application has an admin controller or not.
     */
    def hasAdminController(Application it) {
        !getAllAdminControllers.empty
    }

    /**
     * Returns a list of all user controllers in the given container.
     */
    def getUserControllers(Controllers it) {
        controllers.filter(UserController)
    }

    /**
     * Returns a list of all admin controllers in the given container.
     */
    def getAdminControllers(Controllers it) {
        controllers.filter(AdminController)
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
     * Checks whether an entity owns actions of a given type.
     */
    def dispatch hasActions(Entity it, String type) {
        val actions = container.application.getAdminAndUserControllers.map[actions].flatten.toList
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
    def defaultAction(Entity it) '''«IF hasActions('display')»display«ELSEIF hasActions('view')»view«ELSE»«IF container.application.targets('1.3.5')»main«ELSE»index«ENDIF»«ENDIF»'''

    /**
     * Returns a unique list of actions contained in either admin or user controller.
     */
    def getActionsOfAdminAndUserControllers(Application it) {
        var actions = newArrayList
        var actionNames = newArrayList
        for (controller : getAdminAndUserControllers) {
            for (action : controller.actions) {
                if (!actionNames.contains(action.name.formatForCode)) {
                    actionNames.add(action.name.formatForCode)
                    actions.add(action)
                }
            }
        }
        actions
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
        getAllControllers.map[actions].flatten.filter(ViewAction)
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
        getAllControllers.map[actions].flatten.filter(DisplayAction)
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
        getAllControllers.map[actions].flatten.filter(EditAction)
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
        getAllControllers.map[actions].flatten.filter(DeleteAction)
    }

    /**
     * Returns a list of all controllers in the given application.
     */
    def getAllControllers(Application it) {
        var allControllers = controllers.head.controllers
        for (controllerContainer : controllers.tail)
            allControllers.addAll(controllerContainer.controllers)
        allControllers
    }

    /**
     * Get a list of only admin and user controllers.
     */
    def getAdminAndUserControllers(Application it) {
        var allControllers = getAllControllers
        allControllers.filter(AdminController) + allControllers.filter(UserController)
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
                getAllControllers.head.formattedName
    }

    /**
     * Checks for whether the given controller is responsible for the config action.
     */
    def isConfigController(Controller it) {
        container.application.configController == formattedName
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
