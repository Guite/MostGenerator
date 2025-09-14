package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Relationship

/**
 * Extension methods for naming classes and building file pathes.
 */
class NamingExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    /**
     * Concatenates two strings being used for a template path.
     */
    def prepTemplatePart(String origin, String addition) {
        origin + addition.toLowerCase
    }

    /**
     * Returns the common suffix for template file names.
     */
    def templateSuffix(Application it, String format) {
        '.' + format + '.twig'
    }

    /**
     * Returns the base path for a certain template file.
     */
    def templateFileBase(Entity it, String actionName) {
        application.getViewPath + name.formatForCodeCapital + '/' + actionName
    }

    /**
     * Returns the full template file path for given controller action and entity.
     */
    def templateFile(Entity it, String actionName) {
        templateFileBase(actionName) + application.templateSuffix('html')
    }

    /**
     * Returns the full template file path for given controller action and entity,
     * using a custom template extension (like xml instead of tpl).
     */
    def templateFileWithExtension(Entity it, String actionName, String templateExtension) {
        templateFileBase(actionName) + application.templateSuffix(templateExtension)
    }

    /**
     * Returns the full template file path for given controller edit action and entity.
     */
    def editTemplateFile(Entity it, String actionName) {
        templateFile(actionName)
    }

    /**
     * Returns the alias name for one side of a given relationship.
     */
    def getRelationAliasName(Relationship it, Boolean useTarget) {
        var String result
        if (useTarget && null !== targetAlias && !targetAlias.empty) {
            result = targetAlias
        } else if (!useTarget && null !== sourceAlias && !sourceAlias.empty) {
            result = sourceAlias
        } else {
            result = (if (useTarget) target else source).entityClassName('', false)
        }

        result.formatForCode
    }

    /**
     * Returns the class name for a certain entity class.
     */
    def entityClassName(Entity it, String suffix, Boolean isBase) {
        application.appNamespace + '\\Entity\\' + (if (isBase) 'Base\\Abstract' else '') + name.formatForCodeCapital + suffix.formatForCodeCapital
    }

    /**
     * Returns the relative path to the application's root directory.
     */
    def relativeAppRootPath(Application it) {
        'extensions/' + vendor.formatForCodeCapital + '/' + name.formatForCodeCapital + 'Bundle'
    }

    /**
     * Returns the base path for any documentation.
     */
    def getAppDocPath(Application it) {
        'docs/'
    }

    /**
     * Returns the base path for the Flex recipe.
     */
    def getRecipePath(Application it) {
        getAppDocPath + 'recipe/'
    }

    /**
     * Returns the base path for any assets.
     */
    def getAssetPath(Application it) {
        'public/'
    }

    /**
     * Returns the base path for all view templates.
     */
    def getViewPath(Application it) {
        'templates/'
    }

    /**
     * Returns the base path for image files.
     */
    def getAppImagePath(Application it) {
        getAssetPath + 'images/'
    }

    /**
     * Returns the base path for css files.
     */
    def getAppCssPath(Application it) {
        getAssetPath + 'css/'
    }

    /**
     * Returns the base path for js files.
     */
    def getAppJsPath(Application it) {
        getAssetPath + 'js/'
    }

    /**
     * Returns the base path for uploaded files of the generated application.
     */
    def getAppUploadPath(Application it) {
        getRecipePath + 'public/uploads/' + appName + '/'
    }
}
