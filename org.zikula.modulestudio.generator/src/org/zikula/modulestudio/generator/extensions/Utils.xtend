package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Variable
import de.guite.modulestudio.metamodel.modulestudio.Variables
import java.util.Date
import java.util.List

/**
 * Miscellaneous utility methods.
 */
class Utils {

    /**
     * Extensions used for formatting element names.
     */
    @Inject extension FormattingExtensions = new FormattingExtensions()

    /**
     * Returns the version number of ModuleStudio.
     *
     * @return String The version number.
     */
    def msVersion() {
        "0.5.5"
    }

    /**
     * Returns the homepage url of ModuleStudio.
     *
     * @return String The homepage url.
     */
    def msUrl() {
        "http://modulestudio.de"
    }

    /**
     * Returns the formatted name of the application.
     *
     * @param it The {@link Application} instance
     * @return String The formatted name.
     */
    def appName(Application it) {
    	name.formatForCode.toFirstUpper
    }

    /**
     * Returns the lowercase application-specific prefix.
     *
     * @param it The {@link Application} instance
     * @return String The prefix.
     */
    def prefix(Application it) {
        prefix.formatForDB
    }

    /**
     * Checks whether any variables are part of the model or not.
     *
     * @param it The {@link Application} instance
     * @return Boolean The result.
     */
    def needsConfig(Application it) {
    	!getAllVariables.isEmpty
    }

    /**
     * Checks whether there exist multiple variables containers.
     *
     * @param it The {@link Application} instance
     * @return Boolean The result.
     */
    def hasMultipleConfigSections(Application it) {
        getAllVariableContainers.size > 1
    }

    /**
     * Returns the variables containers sorted by their sort order.
     *
     * @param it The {@link Application} instance
     * @return List<Variables> The selected list.
     */
    def getSortedVariableContainers(Application it) {
    	getAllVariableContainers.sortBy(e|e.sortOrder)
    }

    /**
     * Returns all variables containers for a given application.
     *
     * @param it The {@link Application} instance
     * @return List<Variables> The selected list.
     */
    def getAllVariableContainers(Application it) {
        models.map(e|e.variables).flatten.toList as List<Variables>
    }

    /**
     * Returns all variables for a given application.
     *
     * @param it The {@link Application} instance
     * @return List<Variable> The selected list.
     */
    def getAllVariables(Application it) {
        getAllVariableContainers.map(e|e.vars).flatten.toList as List<Variable>
    }

    /**
     * Helper function for building id attributes for input fields in edit templates.
     *
     * @param name The given name
     * @param suffix The given suffix
     * @return String The concatenated identifier.
     */
    def templateIdWithSuffix(String name, String suffix) {
        if (suffix != null && suffix != '')
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
    	val currentTime = System::currentTimeMillis()
        val d = new Date(currentTime)
        d.toString
    }
}
