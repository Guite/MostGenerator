package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity

/**
 * This class contains extension methods for building urls, i.e. modurl calls.
 */
class UrlExtensions {

    /**
     * Extensions used for formatting element names.
     */
    @Inject extension FormattingExtensions = new FormattingExtensions

    /**
     * Extensions related to behavioural aspects of the model layer.
     */
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    /**
     * Extensions related to the model layer.
     */
    @Inject extension ModelExtensions = new ModelExtensions

    /**
     * Creates the parameters for a modurl call relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param func The function to be called by the url
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string.
     */
    def modUrlGeneric(Entity it, String func, String objName, Boolean template) {
        if (template)
            "func='" + func + "'" + modUrlPrimaryKeyParams(objName, template) + (if (func == 'display') appendSlug(objName, template) else '')
        else
            "'" + func + "', array(" + modUrlPrimaryKeyParams(objName, template) + (if (func == 'display') appendSlug(objName, template) else '') + ")"
    }

    /**
     * Creates the parameters for a modurl call relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param func The function to be called by the url
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def modUrlGeneric(Entity it, String func, String objName, Boolean template, String customVarName) {
        if (template)
            "func='" + func + "'" + modUrlPrimaryKeyParams(objName, template, customVarName)
        else
            "'" + func + "', array(" + modUrlPrimaryKeyParams(objName, template, customVarName) + ")"
    }

    /**
     * Creates the parameters for a modurl call to a display function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string.
     */
    def modUrlDisplayWithFreeOt(Entity it, String objName, Boolean template) {
        if (template) {
            "func='display'" + modUrlPrimaryKeyParams(objName, template) + appendSlug(objName, template)
        } else {
            "'display', array(" + modUrlPrimaryKeyParams(objName, template) + appendSlug(objName, template) + ')'
        }
    }

    /**
     * Creates the parameters for a modurl call to a display function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string.
     */
    def modUrlDisplay(Entity it, String objName, Boolean template) {
        modUrlGeneric('display', objName, template)
    }

    /**
     * Appends the slug parameter (if available) to display url arguments.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String the slug parameter assignment.
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
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string.
     */
    def modUrlEdit(Entity it, String objName, Boolean template) {
        modUrlGeneric('edit', objName, template)
    }

    /**
     * Creates the parameters for a modurl call to an edit function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def modUrlEdit(Entity it, String objName, Boolean template, String customVarName) {
        modUrlGeneric('edit', objName, template, customVarName)
    }

    /**
     * Creates the parameters for a modurl call to a delete function relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string.
     */
    def modUrlDelete(Entity it, String objName, Boolean template) {
        modUrlGeneric('delete', objName, template)
    }

    /**
     * Collects primary key parameters for a modurl call relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @return String collected url parameter string.
     */
    def modUrlPrimaryKeyParams(Entity it, String objName, Boolean template) {
        if (template)
            getSingleParamForTemplate(getPrimaryKeyFields, objName)
        else
            getSingleParamForCode(getPrimaryKeyFields, objName)
    }

    /**
     * Collects primary key parameters for a modurl call relating a given entity,
     * either for a Zikula_View template or for php source code.
     *
     * @param it The {@link de.guite.modulestudio.metamodel.modulestudio.Entity} to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param template Whether to create the syntax for a template (true) or for source code (false)
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def modUrlPrimaryKeyParams(Entity it, String objName, Boolean template, String customVarName) {
        if (template)
            getSingleParamForTemplate(getPrimaryKeyFields, objName, customVarName)
        else
            getSingleParamForCode(getPrimaryKeyFields, objName, customVarName)
    }

    /**
     * Returns a single parameter pair for a modurl call in a source code file.
     *
     * @param it An {@link java.lang.Iterable} of primary key fields to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @return String collected url parameter string.
     */
    def CharSequence getSingleParamForCode(Iterable<DerivedField> it, String objName) {
        if (size == 0) ''
        else ", '" + head.name.formatForCode + "' => $" + objName + "['" + head.name.formatForCode + "']"
         + getSingleParamForCode(tail, objName)
    }

    /**
     * Returns a single parameter pair for a modurl call in a template file.
     *
     * @param it An {@link java.lang.Iterable} of primary key fields to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @return String collected url parameter string.
     */
    def CharSequence getSingleParamForTemplate(Iterable<DerivedField> it, String objName) {
        if (size == 0) ''
        else ' ' + head.name.formatForCode + '=$' + objName + '.' + head.name.formatForCode
           + tail.getSingleParamForTemplate(objName)
    }

    /**
     * Returns a single parameter pair for a modurl call in a source code file.
     *
     * @param it An {@link java.lang.Iterable} of primary key fields to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def getSingleParamForCode(Iterable<DerivedField> it, String objName, String customVarName) {
        if (size == 0) ''
        else ", '" + customVarName + "' => $" + objName + "['" + head.name.formatForDB + "']"
         + getSingleParamForCode(tail, objName)
    }

    /**
     * Returns a single parameter pair for a modurl call in a template file.
     *
     * @param it An {@link java.lang.Iterable} of primary key fields to be linked to
     * @param objName The name of the object variable carrying the entity object in the output
     * @param customVarName Custom name for using another field name as url parameter
     * @return String collected url parameter string.
     */
    def getSingleParamForTemplate(Iterable<DerivedField> it, String objName, String customVarName) {
        if (size == 0) ''
        else ' ' + customVarName + '=$' + objName + '.' + head.name.formatForDB
         + tail.getSingleParamForTemplate(objName)
    }
}
