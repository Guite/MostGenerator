package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.UserController
import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship

/**
 * This class contains view related extension methods.
 */
class ViewExtensions {
    @Inject extension ControllerExtensions = new ControllerExtensions()

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
        // return false for geographical always until we can redraw the map after panel activation
        (!geographical && panelWeight(page) > 3)
    }

    /**
     * Determines if a given relationship is part
     * of an edit form or not.
     *
     * @param it Given {@link JoinRelationship} instance.
     * @param useTarget Whether the target side or the source side should be used.
     * @return Boolean The determined result.
     */
    def private isPartOfEditForm(JoinRelationship it, Boolean useTarget) {
        (getEditStageCode(!useTarget) > 0)
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
        if (page == 'edit' && incoming.filter(JoinRelationship).filter(e|e.isPartOfEditForm(true)).size > 1) weight = weight + 1
        if (page == 'edit' && outgoing.filter(JoinRelationship).filter(e|e.isPartOfEditForm(false)).size > 1) weight = weight + 1

        if (attributable) weight = weight + 1
        if (categorisable) weight = weight + 1
        if (metaData) weight = weight + 1
        if (standardFields) weight = weight + 1
        if (geographical) weight = weight + 1
        //if (tree != EntityTreeType::NONE) weight = weight + 1
        weight
    }
}
