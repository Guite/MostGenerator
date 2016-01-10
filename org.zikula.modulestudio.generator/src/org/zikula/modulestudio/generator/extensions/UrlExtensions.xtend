package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity

/**
 * This class contains extension methods for building routes.
 */
class UrlExtensions {

    /**
     * Extensions used for formatting element names.
     */
    extension FormattingExtensions = new FormattingExtensions

    /**
     * Extensions related to behavioural aspects of the model layer.
     */
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    /**
     * Extensions related to the model layer.
     */
    extension ModelExtensions = new ModelExtensions

    /**
     * General utility functions.
     */
    extension Utils = new Utils

    /**
     * Collects parameters for a route relating a given entity,
     * either for a Zikula_View template or for php source code.
     * Old version for ZK 1.3.x where pk fields are required also if a unique slug is present.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param withSlug Whether to append the slug or not (since in 1.3.x only display pages use it)
     * @return String collected url parameter string.
     */
    def routeParamsLegacy(Entity it, String objName, Boolean template, Boolean withSlug) '''«routePkParams(objName, template)»«IF withSlug»«appendSlug(objName, template)»«ENDIF»'''

    /**
     * Collects parameters for a route relating a given entity,
     * either for a Zikula_View template or for php source code.
     * New version for ZK 1.4.x using Symfony routing.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string.
     */
    def routeParams(Entity it, String objName, Boolean template) '''«IF template», { «ENDIF»«routePkParams(objName, template)»«appendSlug(objName, template)»«IF template» }«ENDIF»'''

    /**
     * Collects parameters for a route relating a given entity,
     * either for a Zikula_View template or for php source code.
     * Old version for ZK 1.3.x where pk fields are required also if a unique slug is present.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param withSlug Whether to append the slug or not (since in 1.3.x only display pages use it)
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def routeParamsLegacy(Entity it, String objName, Boolean template, Boolean withSlug, String customVarName) '''«routePkParams(objName, template, customVarName)»«IF withSlug»«appendSlug(objName, template)»«ENDIF»'''

    /**
     * Collects parameters for a route relating a given entity,
     * either for a Zikula_View template or for php source code.
     * New version for ZK 1.4.x using Symfony routing.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def routeParams(Entity it, String objName, Boolean template, String customVarName) ''', { «routePkParams(objName, template, customVarName)»«appendSlug(objName, template)» }'''

    /**
     * Collects primary key parameters for a route relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string.
     */
    def routePkParams(Entity it, String objName, Boolean template) {
        if (template)
            routeParamsForTemplate(getPrimaryKeyFields, objName)
        else
            routeParamsForCode(getPrimaryKeyFields, objName).toString.substring(2)
    }

    /**
     * Collects primary key parameters for a route relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def private routePkParams(Entity it, String objName, Boolean template, String customVarName) {
        if (template)
            routeParamsForTemplate(getPrimaryKeyFields, objName, customVarName)
        else
            routeParamsForCode(getPrimaryKeyFields, objName, customVarName).substring(2)
    }

    /**
     * Appends the slug parameter (if available) to url arguments for display, edit and delete pages.
     *
     * @param it The {@link Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String the slug parameter assignment.
     */
    def appendSlug(Entity it, String objName, Boolean template) {
        if (hasSluggableFields) {
            if (template) {
                if (application.targets('1.3.x')) {
                    ''', 'slug': «objName».slug'''
                } else {
                    ''' slug=$«objName».slug'''
                }
            } else {
                ''', 'slug' => $«objName»['slug']'''
            }
        } else ''
    }

    /**
     * Returns a parameter pair for each given field for a route in a source code file.
     *
     * @param it An {@link Iterable} of primary key fields to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @return String collected url parameter string.
     */
    def private CharSequence routeParamsForCode(Iterable<DerivedField> it, String objName) {
        if (size == 0) ''
        else ", '" + head.name.formatForCode + "' => $" + objName + "['" + head.name.formatForCode + "']"
         + routeParamsForCode(tail, objName)
    }

    /**
     * Returns a parameter pair for each given field for a route in a template file.
     *
     * @param it An {@link Iterable} of primary key fields to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @return String collected url parameter string.
     */
    def private CharSequence routeParamsForTemplate(Iterable<DerivedField> it, String objName) {
        if (size == 0) ''
        else {
            if (head.entity.application.targets('1.3.x')) {
                ' ' + head.name.formatForCode + '=$' + objName + '.' + head.name.formatForCode
                    + tail.routeParamsForTemplate(objName)
            } else {
                '\'' + head.name.formatForCode + '\': ' + objName + '.' + head.name.formatForCode
                    + (if (!empty) ', ' else '')
                    + tail.routeParamsForTemplate(objName)
            }
        }
    }

    /**
     * Returns a single parameter pair for a route in a source code file.
     *
     * @param it An {@link Iterable} of primary key fields to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def private routeParamsForCode(Iterable<DerivedField> it, String objName, String customVarName) {
        if (size == 0) ''
        else ", '" + customVarName + "' => $" + objName + "['" + head.name.formatForDB + "']"
         + routeParamsForCode(tail, objName)
    }

    /**
     * Returns a single parameter pair for a route in a template file.
     *
     * @param it An {@link Iterable} of primary key fields to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def private routeParamsForTemplate(Iterable<DerivedField> it, String objName, String customVarName) {
        if (size == 0) ''
        else {
            if (head.entity.application.targets('1.3.x')) {
                ' ' + customVarName + '=$' + objName + '.' + head.name.formatForCode
                    + tail.routeParamsForTemplate(objName)
            } else {
                '\'' + customVarName + '\': ' + objName + '.' + head.name.formatForCode
                    + (if (!empty) ', ' else '')
                    + tail.routeParamsForTemplate(objName)
            }
        }
    }
}
