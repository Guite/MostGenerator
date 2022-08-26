package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import java.util.Date
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.MostInMemoryFileSystemAccess

/**
 * Miscellaneous utility methods.
 */
class Utils {

    extension FormattingExtensions = new FormattingExtensions

    /**
     * Returns a "generated by" message.
     */
    def generatedBy(Application it, Boolean includeTimestamp, Boolean includeVersion)
        '''Generated by ModuleStudio «IF includeVersion»«msVersion» «ENDIF»(«msUrl»)«IF includeTimestamp» at «timestamp»«ENDIF».'''

    /**
     * Returns the version number of ModuleStudio.
     *
     * @return String The version number
     */
    def msVersion() {
        '1.5.0'
    }

    /**
     * Returns the website URL of ModuleStudio.
     *
     * @return String The website URL
     */
    def msUrl() {
        'https://modulestudio.de'
    }

    /**
     * Returns the application's description.
     *
     * @return String The description
     */
    def appDescription(Application it) {
        if (null !== documentation && !documentation.empty) {
            return documentation.replace('"', "'")
        }
        '''«appName» generated by ModuleStudio «msVersion».'''
    }

    /**
     * Creates a placeholder file in a given file path.
     *
     * @param it The file system access
     * @param path The file path
     */
    def createPlaceholder(IMostFileSystemAccess it, String path) {
        var fileName = 'README'
        val fileContent = '''This file is a placeholder.
        '''
        generateFile(path + fileName, fileContent)
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
        vendor.formatForCodeCapital + name.formatForCodeCapital + 'Bundle'
    }

    /**
     * Returns the base namespace of the application.
     *
     * @param it The {@link Application} instance
     *
     * @return String The formatted namespace
     */
    def appNamespace(Application it) {
        vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Bundle'
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
     * Checks whether a given Symfony version is targeted or not.
     *
     * @param it The {@link Application} instance
     * @param version The version in question
     *
     * @return Boolean The result
     */
    def Boolean targets(Application it, String version) {
        switch symfonyVersion {
            case SF70:
                #['7.0', '6.2', '6.1', '5.4'].contains(version)
            case SF62:
                #['6.2', '6.1', '5.4'].contains(version)
            case SF61:
                #['6.1', '5.4'].contains(version)
            case SF54:
                #['5.4'].contains(version)
            default:
                true
        }
    }

    /**
     * Returns the Symfony version.
     *
     * @param it The {@link Application} instance
     *
     * @return String the formatted version number
     */
    def targetSymfonyVersion(Application it) {
        switch symfonyVersion {
            case SF70:
                '7.0'
            case SF62:
                '6.2'
            case SF61:
                '6.1'
            case SF54:
                '5.4'
        }
    }

    /**
     * Returns the Zikula version.
     *
     * @param it The {@link Application} instance
     *
     * @return String the formatted version number
     */
    def targetZikulaVersion(Application it) {
        switch symfonyVersion {
            case SF70:
                '4.0'
            case SF62:
                '4.0'
            case SF61:
                '4.0'
            case SF54:
                '4.0'
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
        variables.map[fields].flatten.toList
    }

    /**
     * Returns the current timestamp to mark the generation time.
     *
     * @return String The current timestamp
     */
    def timestamp() {
        new Date(System.currentTimeMillis).toString
    }

    /**
     * Prints a message if the current generation is not for a test.
     */
    def printIfNotTesting(String it, IMostFileSystemAccess fsa) {
        if (!(fsa instanceof MostInMemoryFileSystemAccess)) {
            println(it)
        }
    }
}
