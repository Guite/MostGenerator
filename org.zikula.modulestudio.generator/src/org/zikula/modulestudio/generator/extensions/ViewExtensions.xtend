package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.UserController

/**
 * This class contains view related extension methods.
 */
class ViewExtensions {
    /**
     * Temporary hack due to Zikula core bug with theme parameter in short urls
     * as we use the Printer theme for the quick view.
     *
     * @param it Given {@link Controller} instance.
     * @return String The output of this method.
     */
    def additionalUrlParametersForQuickViewLink(Controller it) {
        switch it {
            UserController: ' forcelongurl=true'
            default: ''
        }
    }

    /**
     * Determines whether grouping panels with JavaScript for
     * toggling their visibility state are generated or not.
     *
     * @param it Given {@link Entity} instance.
     * @param page The page template name.
     * @return Boolean The result.
     */
    def useGroupingPanels(Entity it, String page) {
        (panelWeight(page) > 3)
    }

    /**
     * Counts the amount of visible groups of a given Entity
     * for display and edit pages.
     *
     * @param it Given {@link Entity} instance.
     * @param page The page template name.
     * @return Integer The resulting panel weight.
     */
    def private panelWeight(Entity it, String page) {
        var weight = 1
        //if (fields.size > 5) weight = weight + 1
        //if (fields.size > 10) weight = weight + 1
        if (page == 'edit' && incoming.size > 1) weight = weight + 1
        if (page == 'edit' && outgoing.size > 1) weight = weight + 1

        if (attributable) weight = weight + 1
        if (categorisable) weight = weight + 1
        if (metaData) weight = weight + 1
        if (standardFields) weight = weight + 1
        if (geographical) weight = weight + 1
        weight
    }
}
