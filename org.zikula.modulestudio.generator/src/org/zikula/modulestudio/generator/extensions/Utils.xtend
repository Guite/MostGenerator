package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import java.util.Date

import static de.guite.modulestudio.metamodel.modulestudio.CoreVersion.*

/**
 * Miscellaneous utility methods.
 */
class Utils {

    /**
     * Extensions used for formatting element names.
     */
    @Inject extension FormattingExtensions = new FormattingExtensions

    /**
     * Helper methods for generator settings.
     */
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions

    /**
     * Returns the version number of ModuleStudio.
     *
     * @return String The version number.
     */
    def msVersion() {
        '0.6.1'
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
     * Returns the formatted name of the application.
     *
     * @param it The {@link Application} instance.
     *
     * @return String The formatted name.
     */
    def appName(Application it) {
        if (targets('1.3.5')) name.formatForCodeCapital
        else vendor.formatForCodeCapital + name.formatForCodeCapital + 'Module'
    }

    /**
     * Returns the base namespace of the application.
     *
     * @param it The {@link Application} instance.
     *
     * @return String The formatted namespace.
     */
    def appNamespace(Application it) {
        if (targets('1.3.5')) ''
        else vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module'
    }

    /**
     * Returns the lowercase application-specific prefix.
     *
     * @param it The {@link Application} instance.
     *
     * @return String The prefix.
     */
    def prefix(Application it) {
        prefix.formatForDB
    }

    /**
     * Checks whether a given core version is targeted or not.
     *
     * @param it The {@link Application} instance.
     * @param version The version in question
     *
     * @return Boolean The result.
     */
    def targets(Application it, String version) {
        // we query '1.3.5' for BC
        val useSymfony = (version != '1.3.5')

        switch (getCoreVersion) {
            case ZK135:
                !useSymfony
            case ZK136:
                !useSymfony
            case ZKPRE14:
                useSymfony
            default:
                useSymfony
        }
    }

    /**
     * Checks whether any variables are part of the model or not.
     *
     * @param it The {@link Application} instance.
     *
     * @return Boolean The result.
     */
    def needsConfig(Application it) {
        !getAllVariables.empty
    }

    /**
     * Checks whether there exist multiple variables containers.
     *
     * @param it The {@link Application} instance.
     *
     * @return Boolean The result.
     */
    def hasMultipleConfigSections(Application it) {
        getAllVariableContainers.size > 1
    }

    /**
     * Returns the variables containers sorted by their sort order.
     *
     * @param it The {@link Application} instance.
     *
     * @return List<Variables> The selected list.
     */
    def getSortedVariableContainers(Application it) {
        getAllVariableContainers.sortBy[sortOrder]
    }

    /**
     * Returns all variables containers for a given application.
     *
     * @param it The {@link Application} instance.
     *
     * @return List<Variables> The selected list.
     */
    def getAllVariableContainers(Application it) {
        models.map[variables].flatten.toList
    }

    /**
     * Returns all variables for a given application.
     *
     * @param it The {@link Application} instance.
     *
     * @return List<Variable> The selected list.
     */
    def getAllVariables(Application it) {
        getAllVariableContainers.map[vars].flatten.toList
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
