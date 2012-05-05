package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Controllers
import de.guite.modulestudio.metamodel.modulestudio.CustomAction
import de.guite.modulestudio.metamodel.modulestudio.DeleteAction
import de.guite.modulestudio.metamodel.modulestudio.DisplayAction
import de.guite.modulestudio.metamodel.modulestudio.EditAction
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.MainAction
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.RelationEditType
import de.guite.modulestudio.metamodel.modulestudio.UserController
import de.guite.modulestudio.metamodel.modulestudio.ViewAction

/**
 * This class contains controller related extension methods.
 */
class ControllerExtensions {
    @Inject extension FormattingExtensions = new FormattingExtensions()

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
        getAllControllers.filter(typeof(UserController))
    }
    /**
     * Checks whether the application has an user controller or not.
     */
    def hasUserController(Application it) {
        !getAllUserControllers.isEmpty
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
        getAllControllers.filter(typeof(AdminController))
    }

    /**
     * Returns a list of all user controllers in the given container.
     */
    def getUserControllers(Controllers it) {
        controllers.filter(typeof(UserController))
    }

    /**
     * Returns a list of all admin controllers in the given container.
     */
    def getAdminControllers(Controllers it) {
        controllers.filter(typeof(AdminController))
    }

    /**
     * Checks whether a controller owns actions of a given type.
     */
    def hasActions(Controller it, String type) {
        switch (type) {
            case 'main'     : !actions.filter(typeof(MainAction)).isEmpty 
            case 'view'     : !actions.filter(typeof(ViewAction)).isEmpty 
            case 'display'  : !actions.filter(typeof(DisplayAction)).isEmpty 
            case 'edit'     : !actions.filter(typeof(EditAction)).isEmpty
            case 'delete'   : !actions.filter(typeof(DeleteAction)).isEmpty
            case 'custom'   : !actions.filter(typeof(CustomAction)).isEmpty 
            default : false
        }
    }

    /**
     * Checks whether the application has at least one edit action or not.
     */
    def hasEditActions(Application it) {
        !getEditActions.isEmpty
    }

    /**
     * Returns a list of all edit actions in the given application.
     */
    def getEditActions(Application it) {
    	getAllControllers.map(e|e.actions).flatten.filter(typeof(EditAction))
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
        allControllers.filter(typeof(AdminController)) + allControllers.filter(typeof(UserController))
    }

    /**
     * Checks whether a given controller is instance of AjaxController.
     */
    def isAjaxController(Controller it) {
        switch it {
            AjaxController: true
            default: false
        }
    }

    /**
     * Determines the controller in which the config action is living.
     */
    def configController(Application it) {
        if (!getAllAdminControllers.isEmpty)
            getAllAdminControllers.head.formattedName
        else
            if (!getAllUserControllers.isEmpty)
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
            case RelationEditType::ACTIVE_NONE_PASSIVE_CHOOSE:
                if (incoming) 1 else 0
            case RelationEditType::ACTIVE_NONE_PASSIVE_EDIT:
                if (incoming) 3 else 0
            case RelationEditType::ACTIVE_CHOOSE_PASSIVE_NONE:
                if (incoming) 3 else 2 // invalid --> default as fallback
            case RelationEditType::ACTIVE_EDIT_PASSIVE_CHOOSE:
                if (incoming) 1 else 2
            case RelationEditType::ACTIVE_EDIT_PASSIVE_EDIT:
                if (incoming) 3 else 2 // default
            case RelationEditType::ACTIVE_EDIT_PASSIVE_NONE:
                if (incoming) 3 else 2 // invalid --> default as fallback
            default:
                if (incoming) 3 else 2
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
            case RelationEditType::ACTIVE_NONE_PASSIVE_CHOOSE:
                if (incoming) 1 else 0
            case RelationEditType::ACTIVE_NONE_PASSIVE_EDIT:
                if (incoming) 3 else 0
            case RelationEditType::ACTIVE_CHOOSE_PASSIVE_NONE:
                if (incoming) 0 else 1
            case RelationEditType::ACTIVE_EDIT_PASSIVE_CHOOSE:
                if (incoming) 1 else 3
            case RelationEditType::ACTIVE_EDIT_PASSIVE_EDIT:
                if (incoming) 3 else 3 // default
            case RelationEditType::ACTIVE_EDIT_PASSIVE_NONE:
                if (incoming) 0 else 3
            default:
                if (incoming) 3 else 3
        }
    }
}
