package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.DerivedField

/**
 * This class contains extension methods for building urls, i.e. modurl calls.
 */
class UrlExtensions {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()

    /**
     * Creates the parameters for a modurl call relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String func The function to be called by the url
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string
     */
    def modUrlGeneric(Entity it, String func, String ot, String objName, Boolean template) {
        if (template)
            "func='" + func + "' ot='" + ot.formatForCode + "'" + modUrlPrimaryKeyParams(objName, template)
        else
            "'" + func + "', array('ot' => '" + ot.formatForCode + "'" + modUrlPrimaryKeyParams(objName, template) + ")"
    }
    /**
     * Creates the parameters for a modurl call relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String func The function to be called by the url
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @param String customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string
     */
    def modUrlGeneric(Entity it, String func, String ot, String objName, Boolean template, String customVarName) {
        if (template)
            "func='" + func + "' ot='" + ot.formatForCode + "'" + modUrlPrimaryKeyParams(objName, template, customVarName)
        else
            "'" + func + "', array('ot' => '" + ot.formatForCode + "'" + modUrlPrimaryKeyParams(objName, template, customVarName) + ")"
    }
    /**
     * Creates the parameters for a modurl call to a display function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @param String otVar Custom name for the object type parameter
     * @return String collected url parameter string
     */
    def modUrlDisplayWithFreeOt(Entity it, String objName, Boolean template, String otVar) {
        if (template) {
            "func='display' ot='" + otVar + modUrlPrimaryKeyParams(objName, template) + '"' + appendSlug(objName, template)
        } else {
            "'display', array('ot' => " + otVar + modUrlPrimaryKeyParams(objName, template) + appendSlug(objName, template) + ')'
        }
    }
    /**
     * Creates the parameters for a modurl call to a display function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string
     */
    def modUrlDisplay(Entity it, String objName, Boolean template) {
        modUrlGeneric('display', name, objName, template) + appendSlug(objName, template)
    }
    /**
     * Appends the slug parameter (if available) to display url arguments.
     */
    def private appendSlug(Entity it, String objName, Boolean template) {
        if (hasSluggableFields) {
            if (template) ' slug=$' + objName + '.slug'
            else ", 'slug' => $" + objName + "['slug']"
        } else ''
    }
    /**
     * Creates the parameters for a modurl call to an edit function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string
     */
    def modUrlEdit(Entity it, String objName, Boolean template) {
        modUrlGeneric('edit', name, objName, template)
    }
    /**
     * Creates the parameters for a modurl call to an edit function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @param String customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string
     */
    def modUrlEdit(Entity it, String objName, Boolean template, String customVarName) {
        modUrlGeneric('edit', name, objName, template, customVarName)
    }
    /**
     * Creates the parameters for a modurl call to a delete function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string
     */
    def modUrlDelete(Entity it, String objName, Boolean template) {
        modUrlGeneric('delete', name, objName, template)
    }

    /**
     * Collect primary key parameters for a modurl call relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string
     */
    def modUrlPrimaryKeyParams(Entity it, String objName, Boolean template) {
        if (template)
            getSingleParamForTemplate(getPrimaryKeyFields, objName)
        else
            getSingleParamForCode(getPrimaryKeyFields, objName)
    }
    /**
     * Collect primary key parameters for a modurl call relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param Entity it The entity to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param Boolean template Whether to create the syntax for a template (true) or for source code (false)
     * @param String customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string
     */
    def modUrlPrimaryKeyParams(Entity it, String objName, Boolean template, String customVarName) {
        if (template)
            getSingleParamForTemplate(getPrimaryKeyFields, objName, customVarName)
        else
            getSingleParamForCode(getPrimaryKeyFields, objName, customVarName)
    }
/** TODO refactor using loops */

    /**
     * Return a single parameter pair for a modurl call in a source code file.
     *
     * @param Iterable<DerivedField> it The list of primary key fields to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @return String collected url parameter string
     */
    def getSingleParamForCode(Iterable<DerivedField> it, String objName) {
        if (size == 0) ''
        else ", '" + head.name.formatForDB + "' => $" + objName + "['" + head.name.formatForDB + "']"
         + getSingleParamForCode(tail, objName)
    }

    /**
     * Return a single parameter pair for a modurl call in a template file.
     *
     * @param Iterable<DerivedField> it The list of primary key fields to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @return String collected url parameter string
     */
    def getSingleParamForTemplate(Iterable<DerivedField> it, String objName) {
        if (size == 0) ''
        else ' ' + head.name.formatForDB + '=$' + objName + '.' + head.name.formatForDB
           + tail.getSingleParamForTemplate(objName)
    }

    /**
     * Return a single parameter pair for a modurl call in a source code file.
     *
     * @param Iterable<DerivedField> it The list of primary key fields to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param String customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string
     */
    def getSingleParamForCode(Iterable<DerivedField> it, String objName, String customVarName) {
        if (size == 0) ''
        else ", '" + customVarName + "' => $" + objName + "['" + head.name.formatForDB + "']"
         + getSingleParamForCode(tail, objName)
    }

    /**
     * Return a single parameter pair for a modurl call in a template file.
     *
     * @param Iterable<DerivedField> it The list of primary key fields to be linked to
     * @param String objName The name of the object variable carrying the entity object in the output
     * @param String customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string
     */
    def getSingleParamForTemplate(Iterable<DerivedField> it, String objName, String customVarName) {
        if (size == 0) ''
        else ' ' + customVarName + '=$' + objName + '.' + head.name.formatForDB
         + tail.getSingleParamForTemplate(objName);
    }
}
