package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import java.util.Arrays
import org.eclipse.xtext.generator.IFileSystemAccess

/**
 * Extension methods for naming classes and building file pathes.
 */
class NamingExtensions {

    /**
     * Extensions used for formatting element names.
     */
    extension FormattingExtensions = new FormattingExtensions

    /**
     * Helper methods for generator settings.
     */
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions

    /**
     * Additional utility methods.
     */
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
        var filePath = templateFileBase(actionName) + application.templateSuffix('html')
        if (application.shouldBeMarked(filePath)) {
            filePath = templateFileBase(actionName) + '.generated' + application.templateSuffix('html')
        }
        filePath
    }

    /**
     * Returns the full template file path for given controller action and entity,
     * using a custom template extension (like xml instead of tpl).
     */
    def templateFileWithExtension(Entity it, String actionName, String templateExtension) {
        var filePath = templateFileBase(actionName) + application.templateSuffix(templateExtension)
        if (application.shouldBeMarked(filePath)) {
            filePath = templateFileBase(actionName) +'.generated' + application.templateSuffix(templateExtension)
        }
        filePath
    }

    /**
     * Returns the full template file path for given controller edit action and entity.
     */
    def editTemplateFile(Entity it, String actionName) {
        templateFile(actionName)
    }
    

    /**
     * Returns the full file path for a view plugin file.
     */
    def viewPluginFilePath(Application it, String pluginType, String pluginName) {
        var filePath = getViewPath + 'plugins/' + pluginType + '.' + appName.formatForDB + pluginName + '.php'
        if (shouldBeMarked(filePath)) {
            filePath = getViewPath + 'plugins/' + pluginType + '.' + appName.formatForDB + pluginName + '.generated.php'
        }
        filePath
    }


    /**
     * Returns the alias name for one side of a given relationship.
     */
    def getRelationAliasName(JoinRelationship it, Boolean useTarget) {
        var String result
        if (useTarget && null !== targetAlias && targetAlias != '') {
            result = targetAlias
        } else if (!useTarget && null !== sourceAlias && sourceAlias != '') {
            result = sourceAlias
        } else {
            result = (if (useTarget) target else source).entityClassName('', false)
        }

        result.formatForCode
    }

    /**
     * Returns the class name for a certain entity class.
     */
    def entityClassName(DataObject it, String suffix, Boolean isBase) {
        application.appNamespace + '\\Entity\\' + (if (isBase) 'Base\\Abstract' else '') + name.formatForCodeCapital + suffix.formatForCodeCapital + 'Entity'
    }

    /**
     * Returns the doctrine entity manager service name.
     */
    def entityManagerService(Application it) {
        'doctrine.orm.default_entity_manager'
    }

    /**
     * Checks whether a certain file path is contained in the blacklist for files to be skipped during generation.
     */
    def shouldBeSkipped(Application it, String filePath) {
        getListOfFilesToBeSkipped.contains(filePath.replace(getAppSourcePath, ''))
    }

    /**
     * Checks whether a certain file path is contained in the list for files to be marked during generation.
     */
    def shouldBeMarked(Application it, String filePath) {
        getListOfFilesToBeMarked.contains(filePath.replace(getAppSourcePath, ''))
    }

    /**
     * Generates a base class and an inheriting concrete class with
     * the corresponding content.
     *
     * @param it              The {@link Application} instance.
     * @param fsa             Given file system access.
     * @param concretePath    Path to concrete class file.
     * @param baseContent     Content for base class file.
     * @param concreteContent Content for concrete class file.
     */
    def generateClassPair(Application it, IFileSystemAccess fsa, String concretePath, CharSequence baseContent, CharSequence concreteContent) {
        var basePathParts = concretePath.split('/') //$NON-NLS-1$
        var baseFileName = basePathParts.last
        basePathParts = Arrays.copyOf(basePathParts, basePathParts.length - 1)

        var basePathPartsChangeable = newArrayList(basePathParts)
        basePathPartsChangeable += 'Base' //$NON-NLS-1$
        basePathPartsChangeable += 'Abstract' + baseFileName //$NON-NLS-1$
        val basePath = basePathPartsChangeable.join('/') //$NON-NLS-1$

        if (!shouldBeSkipped(basePath)) {
            if (shouldBeMarked(basePath)) {
                fsa.generateFile(basePath.replace('.php', '.generated.php'), baseContent)
            } else {
                fsa.generateFile(basePath, baseContent)
            }
        }

        if (!generateOnlyBaseClasses && !shouldBeSkipped(concretePath)) {
            if (shouldBeMarked(concretePath)) {
                fsa.generateFile(concretePath.replace('.php', '.generated.php'), concreteContent)
            } else {
                fsa.generateFile(concretePath, concreteContent)
            }
        }
    }

    /**
     * Returns the base path for the generated application.
     */
    def getAppSourcePath(Application it) {
        ''
    }

    /**
     * Returns the relative path to the application's root directory.
     */
    def relativeAppRootPath(Application it) {
        if (systemModule) {
            'system/' + name.formatForCodeCapital + 'Module'
        } else {
            'modules/' + vendor.formatForCodeCapital + '/' + name.formatForCodeCapital + 'Module'
        }
    }

    /**
     * Returns the base path for the source code of the generated application.
     */
    def getAppSourceLibPath(Application it) {
        getAppSourcePath
    }

    /**
     * Returns the base path for any documentation.
     */
    def getAppDocPath(Application it) {
        getResourcesPath + 'docs/'
    }

    /**
     * Returns the base path for the licence file.
     */
    def getAppLicencePath(Application it) {
        getResourcesPath + 'meta/'
    }

    /**
     * Returns the base path for the locale artifacts.
     */
    def getAppLocalePath(Application it) {
        getResourcesPath + 'translations/'
    }

    /**
     * Returns the base path for any resources.
     */
    def getResourcesPath(Application it) {
        getAppSourcePath + 'Resources/'
    }

    /**
     * Returns the base path for any assets.
     */
    def getAssetPath(Application it) {
        getResourcesPath + 'public/'
    }

    /**
     * Returns the base path for all view templates.
     */
    def getViewPath(Application it) {
        getResourcesPath + 'views/'
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
        getResourcesPath + 'userdata/' + appName + '/'
    }

    /**
     * Returns the base path for the test source code of the generated application.
     */
    def getAppTestsPath(Application it) {
        getAppSourcePath + 'Tests/'
    }
}
