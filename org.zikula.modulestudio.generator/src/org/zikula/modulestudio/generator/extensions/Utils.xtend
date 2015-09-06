package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import java.util.Date

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
     * @return String The version number.
     */
    def msVersion() {
        '0.7.0'
    }

    /**
     * Returns the homepage url of ModuleStudio.
     *
     * @return String The homepage url.
     */
    def msUrl() {
        'http://modulestudio.de'
    }

    /**
     * Returns a combined title consisting of vendor and name.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     *
     * @return String The formatted name.
     */
    def String vendorAndName(Application it) {
        vendor.formatForCode + name.formatForCodeCapital
    }

    /**
     * Returns the formatted name of the application.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     *
     * @return String The formatted name.
     */
    def String appName(Application it) {
        if (targets('1.3.x')) name.formatForCodeCapital
        else vendor.formatForCodeCapital + name.formatForCodeCapital + 'Module'
    }

    /**
     * Returns the base namespace of the application.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     *
     * @return String The formatted namespace.
     */
    def appNamespace(Application it) {
        if (targets('1.3.x')) ''
        else vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module'
    }

    /**
     * Returns the lowercase application-specific prefix.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     *
     * @return String The prefix.
     */
    def prefix(Application it) {
        prefix.formatForDB
    }

    /**
     * Checks whether a given core version is targeted or not.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     * @param version The version in question
     *
     * @return Boolean The result.
     */
    def Boolean targets(Application it, String version) {
        // we query '1.3.x' for BC
        val useSymfony = (version != '1.3.x')

        switch getCoreVersion {
            case ZK135:
                !useSymfony
            case ZK136:
                !useSymfony
            case ZK20:
                useSymfony
            case ZK14:
                useSymfony
            case ZKPRE14:
                useSymfony
            default:
                useSymfony
        }
    }

    /**
     * Checks whether any variables are part of the model or not.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     *
     * @return Boolean The result.
     */
    def needsConfig(Application it) {
        !getAllVariables.empty
    }

    /**
     * Checks whether there exist multiple variables containers.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     *
     * @return Boolean The result.
     */
    def hasMultipleConfigSections(Application it) {
        variables.size > 1
    }

    /**
     * Returns the variables containers sorted by their sort order.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     *
     * @return List<Variables> The selected list.
     */
    def getSortedVariableContainers(Application it) {
        variables.sortBy[sortOrder]
    }

    /**
     * Returns all variables for a given application.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.Application} instance.
     *
     * @return List<Variable> The selected list.
     */
    def getAllVariables(Application it) {
        variables.map[vars].flatten.toList
    }

    /**
     * Helper function for building id attributes for input fields in edit templates.
     *
     * @param name The given name.
     * @param suffix The given suffix.
     *
     * @return String The concatenated identifier.
     */
    def templateIdWithSuffix(String name, String suffix) {
        if (suffix !== null && suffix != '')
            '"' + name + '`' + suffix + '`"'
        else
            "'" + name + "'"
    }

    /**
     * Returns the current timestamp to mark the generation time.
     *
     * @return String The current timestamp.
     */
    def timestamp() {
        new Date(System.currentTimeMillis).toString
    }
}
