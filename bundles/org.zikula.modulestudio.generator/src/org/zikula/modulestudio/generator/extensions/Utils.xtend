package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import java.util.Date
import org.eclipse.xtext.generator.IFileSystemAccess

/**
 * Miscellaneous utility methods.
 */
class Utils {

    /**
     * Extensions used for formatting element names.
     */
    extension FormattingExtensions = new FormattingExtensions

    /**
     * Helper methods for generator settings.
     */
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions

    /**
     * Returns the version number of ModuleStudio.
     *
     * @return String The version number
     */
    def msVersion() {
        '1.0.2'
    }

    /**
     * Returns the website url of ModuleStudio.
     *
     * @return String The website url
     */
    def msUrl() {
        'https://modulestudio.de'
    }

    /**
     * Creates a placeholder file in a given file path.
     *
     * @param it The {@link Application} instance
     * @param fsa The file system access
     * @param path The file path
     */
    def createPlaceholder(Application it, IFileSystemAccess fsa, String path) {
        var fileName = 'README'
        val fileContent = '''This file is a placeholder.
        '''
        /*if (!shouldBeSkipped(path + fileName)) {
            if (shouldBeMarked(path + fileName)) {
                fileName = 'README.generated'
            }*/
            fsa.generateFile(path + fileName, fileContent)
        //}
    }

    /**
     * Returns a combined title consisting of vendor and name.
     *
     * @param it The {@link Application} instance
     *
     * @return String The formatted name
     */
    def String vendorAndName(Application it) {
        vendor.formatForCode + name.formatForCodeCapital
    }

    /**
     * Returns the formatted name of the application.
     *
     * @param it The {@link Application} instance
     *
     * @return String The formatted name
     */
    def String appName(Application it) {
        vendor.formatForCodeCapital + name.formatForCodeCapital + 'Module'
    }

    /**
     * Returns the base namespace of the application.
     *
     * @param it The {@link Application} instance
     *
     * @return String The formatted namespace
     */
    def appNamespace(Application it) {
        vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module'
    }

    /**
     * Returns prefix for service names for this application.
     *
     * @param it The {@link Application} instance
     *
     * @return String The formatted service prefix
     */
    def String appService(Application it) {
        vendor.formatForDB + '_' + name.formatForDB + '_module'
    }

    /**
     * Returns the lowercase application-specific prefix.
     *
     * @param it The {@link Application} instance
     *
     * @return String The prefix
     */
    def prefix(Application it) {
        prefix.formatForDB
    }

    /**
     * Checks whether a given core version is targeted or not.
     *
     * @param it The {@link Application} instance
     * @param version The version in question
     *
     * @return Boolean The result
     */
    def Boolean targets(Application it, String version) {
        val useStable15 = !#['1.5-dev', '2.0', '2.0-dev'].contains(version)

        switch getCoreVersion {
            case ZK2DEV:
                #['2.0-dev', '2.0', '1.5-dev'].contains(version)
            case ZK20:
                #['2.0', '1.5-dev'].contains(version)
            case ZK15:
                useStable15
            case ZK15DEV:
                version == '1.5-dev'
            default:
                useStable15
        }
    }

    /**
     * Returns the core version as semantic version number.
     *
     * @param it The {@link Application} instance
     * @param withPoint Whether to include the last part or not
     *
     * @return String the formatted version number
     */
    def targetSemVer(Application it, Boolean withPoint) {
        switch getCoreVersion {
            case ZK2DEV:
                if (!withPoint) '2.0' else '2.0.3'
            case ZK20:
                if (!withPoint) '2.0' else '2.0.2'
            case ZK15:
                if (!withPoint) '1.5' else '1.5.2'
            case ZK15DEV:
                if (!withPoint) '1.5' else '1.5.3'
            default:
                if (!withPoint) '1.5' else '2.0.2'
        }
    }

    /**
     * Checks whether any variables are part of the model or not.
     *
     * @param it The {@link Application} instance
     *
     * @return Boolean The result
     */
    def needsConfig(Application it) {
        !getAllVariables.empty
    }

    /**
     * Checks whether there exist multiple variables containers.
     *
     * @param it The {@link Application} instance
     *
     * @return Boolean The result
     */
    def hasMultipleConfigSections(Application it) {
        variables.size > 1
    }

    /**
     * Returns the variables containers sorted by their sort order.
     *
     * @param it The {@link Application} instance
     *
     * @return List<Variables> The selected list
     */
    def getSortedVariableContainers(Application it) {
        variables.sortBy[sortOrder]
    }

    /**
     * Returns all variables for a given application.
     *
     * @param it The {@link Application} instance
     *
     * @return List<Variable> The selected list
     */
    def getAllVariables(Application it) {
        variables.map[vars].flatten.toList
    }

    /**
     * Helper function for building id attributes for input fields in edit templates.
     *
     * @param name The given name
     * @param suffix The given suffix
     *
     * @return String The concatenated identifier
     */
    def templateIdWithSuffix(String name, String suffix) {
        if (null !== suffix && suffix != '')
            '"' + name + '`' + suffix + '`"'
        else
            "'" + name + "'"
    }

    /**
     * Returns the current timestamp to mark the generation time.
     *
     * @return String The current timestamp
     */
    def timestamp() {
        new Date(System.currentTimeMillis).toString
    }
}
