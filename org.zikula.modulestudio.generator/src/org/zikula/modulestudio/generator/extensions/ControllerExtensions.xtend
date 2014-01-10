package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
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
    @Inject extension FormattingExtensions = new FormattingExtensions

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
    def hasActions(Controller it, String type) {
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
     * Returns the controller instance to be used for linking to a display
     * page of a given entity.
     * The main purpose of this function is to consider joins from or to entities
     * of other models/modules properly.
     */
    def getLinkController(Application it, Controller currentController, Entity entity) {
        val Application entityApp = entity.container.application
        var Controller linkController = null
        if (it == entityApp && currentController.hasActions('display')) {
            linkController = currentController
        } else if (entityApp.hasUserController && entityApp.getMainUserController.hasActions('display')) {
            linkController = entityApp.getMainUserController
        }
        linkController
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
