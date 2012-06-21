package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.Controller

/**
 * Extension methods for naming classes and building file pathes.
 */
class NamingExtensions {

    /**
     * Extensions related to the controller layer.
     */
    @Inject extension ControllerExtensions = new ControllerExtensions()

    /**
     * Extensions used for formatting element names.
     */
    @Inject extension FormattingExtensions = new FormattingExtensions()

    /**
     * Additional utility methods.
     */
    @Inject extension Utils = new Utils()

    /**
     * Returns the common prefix for class names.
     */
    def classPraefix(Application it) {
        appName + '_'
  	}

    /**
     * Returns the common suffix for class names.
     */
    def classSuffix() {
        '.php'
    }

    /**
     * Converts a given class name to it's file path.
     */
    def asFile(String className) {
        'lib/' + className.replaceAll('_', '/') + classSuffix
    }


    /**
     * Returns the full class name for implementation classes.
     */
    def implClassDefault(Application it, String filling, String suffix) {
        classPraefix + filling + suffix
    }
    /**
     * Returns the full class name for base classes.
     */
    def baseClassDefault(Application it, String filling, String suffix) {
        implClassDefault(filling + 'Base_', suffix)
    }


    /**
     * Returns the part of entity class names representing the folder.
     */
    def fillingEntity() { 'Entity_' }
    /**
     * Returns the part of controller class names representing the folder.
     */
    def fillingController() { 'Controller_' }
    /**
     * Returns the part of api class names representing the folder.
     */
    def fillingApi() { 'Api_' }
    /**
     * Returns the part of form handler class names representing the folder.
     */
    def fillingFormHandler() { 'Form_Handler_' }
    /**
     * Returns the part of util class names representing the folder.
     */
    def fillingUtil() { 'Util_' }

    /**
     * Prepares a given string for being used as part of a class name.
     */
    def prepClassPart(String str) {
        str.formatForCode.toFirstUpper
    }

    /**
     * Returns the full class name for a model base class.
     */
    def baseClassModel(Entity it, String subfolder, String suffix) {
        if (subfolder != '')
            baseClassDefault(container.application, fillingEntity + subfolder.toFirstUpper + '_', prepClassPart(name + suffix.toFirstUpper))
        else
            baseClassDefault(container.application, fillingEntity, prepClassPart(name + suffix.toFirstUpper))
    }
    /**
     * Returns the full class name for a model implementation class.
     */
    def implClassModel(Entity it, String subfolder, String suffix) {
        if (subfolder != '')
	        implClassDefault(container.application, fillingEntity + subfolder.toFirstUpper + '_', prepClassPart(name + suffix.toFirstUpper))
        else
            implClassDefault(container.application, fillingEntity, prepClassPart(name + suffix.toFirstUpper))
    }

    /**
     * Returns the full class name for a model entity base class.
     */
    def baseClassModelEntity(Entity it) {
        baseClassModel('', '')
    }
    /**
     * Returns the full class name for a model entity implementation class.
     */
    def implClassModelEntity(Entity it) {
	    implClassModel('', '')
	}

    /**
     * Returns the full class name for a model link entity base class.
     */
    def baseClassModelRefEntity(ManyToManyRelationship it) {
        baseClassDefault(container.application, fillingEntity, prepClassPart(refClass))
    }
    /**
     * Returns the full class name for a model link entity implementation class.
     */
    def implClassModelRefEntity(ManyToManyRelationship it) {
        implClassDefault(container.application, fillingEntity, prepClassPart(refClass))
    }
    /**
     * Returns the full class name for a model link repository base class.
     */
    def baseClassModelRefRepository(ManyToManyRelationship it) {
        baseClassDefault(container.application, fillingEntity + 'Repository_', prepClassPart(refClass))
    }
    /**
     * Returns the full class name for a model link repository implementation class.
     */
    def implClassModelRefRepository(ManyToManyRelationship it) {
        implClassDefault(container.application, fillingEntity + 'Repository_', prepClassPart(refClass))
    }

    /**
     * Returns the full class name for a controller base class.
     */
    def baseClassController(Controller it) {
        baseClassDefault(container.application, fillingController, prepClassPart(name))
    }
    /**
     * Returns the full class name for a controller implementation class.
     */
    def implClassController(Controller it) {
        implClassDefault(container.application, fillingController, prepClassPart(name))
    }
    /**
     * Returns the full class name for an api base class.
     */
    def baseClassApi(Controller it) {
        baseClassDefault(container.application, fillingApi, prepClassPart(name))
    }
    /**
     * Returns the full class name for an api implementation class.
     */
    def implClassApi(Controller it) {
        implClassDefault(container.application, fillingApi, prepClassPart(name))
    }
    /**
     * Returns the full class name for a form handler base class collecting entity-independent common code.
     */
    def baseClassFormHandler(Controller it, String actionName) {
        baseClassDefault(container.application, fillingFormHandler + prepClassPart(name) + '_', prepClassPart(actionName))
    }
    /**
     * Returns the full class name for a form handler implementation class collecting entity-independent common code.
     */
    def implClassFormHandler(Controller it, String actionName) {
        implClassDefault(container.application, fillingFormHandler + prepClassPart(name) + '_', prepClassPart(actionName))
    }
    /**
     * Returns the full class name for a form handler base class of a given entity.
     */
    def baseClassFormHandler(Controller it, String entityName, String actionName) {
        baseClassDefault(container.application, fillingFormHandler + prepClassPart(name) + '_' + prepClassPart(entityName) + '_', prepClassPart(actionName))
    }
    /**
     * Returns the full class name for a form handler implementation class of a given entity.
     */
    def implClassFormHandler(Controller it, String entityName, String actionName) {
        implClassDefault(container.application, fillingFormHandler + prepClassPart(name) + '_' + prepClassPart(entityName) + '_', prepClassPart(actionName))
    }


    /**
     * Returns the full class name for the form handler base class of the config action.
     */
    def tempBaseClassConfigHandler(Application it) {
        baseClassDefault(fillingFormHandler + configController.toFirstUpper + '_', prepClassPart('Config'))
    }
    /**
     * Returns the full class name for the form handler implementation class of the config action.
     */
    def tempImplClassConfigHandler(Application it) {
        implClassDefault(fillingFormHandler + configController.toFirstUpper + '_', prepClassPart('Config'))
    }

    /**
     * Concatenates two strings being used for a template path.
     */
    def prepTemplatePart(String origin, String addition) {
        origin + addition.toLowerCase
    }

    /**
     * Returns the common suffix for template file names.
     */
    def templateSuffix() {
        '.tpl'
    }

    /**
     * Returns the base path for a certain template file.
     */
    def templateFileBase(Controller it, String entityName, String actionName) {
        getAppSourcePath(container.application.appName) + 'templates/' + formattedName + '/' + entityName.formatForCode + '/' + actionName
    }

    /**
     * Returns the full template file path for given controller action and entity.
     */
    def templateFile(Controller it, String entityName, String actionName) {
        templateFileBase(entityName, actionName) + templateSuffix()
    }

    /**
     * Returns the full template file path for given controller action and entity,
     * using a custom template extension (like xml instead of tpl).
     */
    def templateFileWithExtension(Controller it, String entityName, String actionName, String templateExtension) {
        templateFileBase(entityName, actionName) + '.' + templateExtension
    }

    /**
     * Returns the full template file path for given controller edit action and entity.
     */
    def editTemplateFile(Controller it, String entityName, String actionName) {
        templateFile(entityName, actionName)
    }
    

    /**
     * Returns the full file path for a view plugin file.
     */
    def viewPluginFilePath(Application it, String pluginType, String pluginName) {
        getAppSourcePath(appName) + 'templates/plugins/' + pluginType + '.' + appName.formatForDB + pluginName + '.php'
    }


    /**
     * Returns the alias name for one side of a given relationship.
     */
    def getRelationAliasName(JoinRelationship it, Boolean useTarget) {
        (if (useTarget)
            (if (targetAlias != null && targetAlias != '') targetAlias else target.implClassModelEntity)
         else
            (if (sourceAlias != null && sourceAlias != '') sourceAlias else source.implClassModelEntity)
        ).formatForCode
    }


    /**
     * Returns the base path for the generated application.
     */
    def getAppSourcePath(String appName) {
        'src/modules/' + appName + '/'
    }

    /**
     * Returns the base path for the source code of the generated application.
     */
    def getAppSourceLibPath(String appName) {
        getAppSourcePath(appName) + 'lib/' + appName + '/'
    }

    /**
     * Returns the base path for uploaded files of the generated application.
     */
    def getAppUploadPath(String appName) {
        'src/userdata/' + appName + '/'
    }

    /**
     * Returns the base path for the test source code of the generated application.
     */
    def getAppTestsPath(String appName) {
        'tests/'
    }
}
