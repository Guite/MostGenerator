package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field

/**
 * This class contains extension methods for building routes.
 */
class UrlExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions

    /**
     * Returns the route prefix for the given application.
     *
     * @param it The {@link Application} instance
     * @param action Name of action to link to
     *
     * @return String Route prefix
     */
    def routePrefix(Application it) {
        vendor.formatForDB + '_' + name.formatForDB
    }

    /**
     * Returns the route prefix for a given entity.
     *
     * @param it The {@link Entity} instance
     * @param action Name of action to link to
     *
     * @return String Route prefix
     */
    def route(Entity it, String action) {
        application.routePrefix + '_' + nameMultiple.formatForDisplay + '_' + action
    }

    /**
     * Collects parameters for a route relating a given entity,
     * either for a Twig template or for PHP source code.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected URL parameter string.
     */
    def routeParams(Entity it, String objName, Boolean template) '''«IF template», {«ENDIF»«IF hasSluggableFields»«appendSlug(objName, template)»«ELSE»«routePkParams(objName, template)»«ENDIF»«IF template»}«ENDIF»'''

    /**
     * Collects parameters for a route relating a given entity,
     * either for a Twig template or for PHP source code.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param customVarName Custom name for using another field name as URL parameter
     * @return String collected URL parameter string.
     */
    def routeParams(Entity it, String objName, Boolean template, String customVarName) '''«IF template», {«ENDIF»«IF hasSluggableFields»«appendSlug(objName, template)»«ELSE»«routePkParams(objName, template, customVarName)»«ENDIF»«IF template»}«ENDIF»'''

    /**
     * Collects primary key parameters for a route relating a given entity,
     * either for a Twig template or for PHP source code.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected URL parameter string.
     */
    def routePkParams(Entity it, String objName, Boolean template) {
        if (template)
            routeParamsForTemplate(getPrimaryKey, objName)
        else
            routeParamsForCode(getPrimaryKey, objName).toString.substring(2)
    }

    /**
     * Collects primary key parameters for a route relating a given entity,
     * either for a Twig template or for PHP source code.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param customVarName Custom name for using another field name as URL parameter
     * @return String collected URL parameter string.
     */
    def private routePkParams(Entity it, String objName, Boolean template, String customVarName) {
        if (template)
            routeParamsForTemplate(getPrimaryKey, objName, customVarName)
        else
            routeParamsForCode(getPrimaryKey, objName, customVarName).substring(2)
    }

    /**
     * Appends the slug parameter (if available) to URL arguments for display, edit and delete pages.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String the slug parameter assignment.
     */
    def appendSlug(Entity it, String objName, Boolean template) {
        if (hasSluggableFields) {
            if (template) {
                ''''slug': «objName».slug'''
            } else {
                ''''slug' => $«objName»['slug']'''
            }
        } else ''
    }

    /**
     * Returns a parameter pair for each given field for a route in a source code file.
     *
     * @param it Primary key field to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @return String collected URL parameter string.
     */
    def private CharSequence routeParamsForCode(Field it, String objName) {
        ", '" + name.formatForCode + "' => $" + objName + '->get' + name.formatForCodeCapital + '()'
    }

    /**
     * Returns a parameter pair for each given field for a route in a template file.
     *
     * @param it Primary key field to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @return String collected URL parameter string.
     */
    def private CharSequence routeParamsForTemplate(Field it, String objName) {
        '\'' + name.formatForCode + '\': ' + objName + '.get' + name.formatForCodeCapital + '()'
    }

    /**
     * Returns a single parameter pair for a route in a source code file.
     *
     * @param it Primary key field to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param customVarName Custom name for using another field name as URL parameter
     * @return String collected URL parameter string.
     */
    def private routeParamsForCode(Field it, String objName, String customVarName) {
        ", '" + customVarName + "' => $" + objName + '->get' + name.formatForCodeCapital + '()'
    }

    /**
     * Returns a single parameter pair for a route in a template file.
     *
     * @param it Primary key field to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param customVarName Custom name for using another field name as URL parameter
     * @return String collected URL parameter string.
     */
    def private routeParamsForTemplate(Field it, String objName, String customVarName) {
        '\'' + customVarName + '\': ' + objName + '.get' + name.formatForCodeCapital + '()'
    }
}
