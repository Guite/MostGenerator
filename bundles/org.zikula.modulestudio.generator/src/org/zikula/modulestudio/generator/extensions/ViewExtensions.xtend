package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship

/**
 * This class contains view related extension methods.
 */
class ViewExtensions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    /**
     * Determines whether grouping tabs are generated or not.
     *
     * @param it Given {@link Entity} instance.
     * @param page The page template name.
     *
     * @return Boolean The result.
     */
    def useGroupingTabs(Entity it, String page) {
        // return false for geographical always until we can redraw the map after panel activation
        (!geographical && panelWeight(page) > 3)
    }

    /**
     * Determines if a given relationship is part
     * of an edit form or not.
     *
     * @param it Given {@link JoinRelationship} instance.
     * @param useTarget Whether the target side or the source side should be used.
     *
     * @return Boolean The determined result.
     */
    def private isPartOfEditForm(JoinRelationship it, Boolean useTarget) {
        (getEditStageCode(!useTarget) > 0)
    }

    /**
     * Counts the amount of visible groups of a given {@link Entity}
     * for display and edit pages.
     *
     * @param it Given {@link Entity} instance.
     * @param page The page template name.
     *
     * @return Integer The resulting panel weight.
     */
    def private panelWeight(Entity it, String page) {
        var weight = 1
        //if (fields.size > 5) weight = weight + 1
        //if (fields.size > 10) weight = weight + 1
        if (page == 'edit' && incoming.filter(JoinRelationship).filter[isPartOfEditForm(true)].size > 1) weight = weight + 1
        if (page == 'edit' && outgoing.filter(JoinRelationship).filter[isPartOfEditForm(false)].size > 1) weight = weight + 1

        if (standardFields) weight = weight + 1
        if (geographical) weight = weight + 1
        //if (tree != EntityTreeType.NONE) weight = weight + 1
        weight
    }

    /**
     * Returns whether jQuery UI is needed or not.
     */
    def needsJQueryUI(Application it) {
        (hasSortable && hasIndexActions)
        || (!relations.empty && (hasIndexActions || hasDetailActions || hasEditActions))
    }

    /**
     * Returns the code used for including Leaflet.
     */
    def includeLeaflet(Entity it, String actionName, String objName) '''
        {{ pageAddAsset('stylesheet', zasset('@«application.appName»:leaflet/css/leaflet.css')) }}
        {{ pageAddAsset('javascript', zasset('@«application.appName»:leaflet/js/leaflet' ~ (app.environment == 'dev' ? '' : '.min') ~ '.js')) }}
        «IF 'index' == actionName»
            <div id="geographicalInfo" class="d-none" data-context="«actionName»" data-object-type="«objName»" data-tile-layer-url="{{ geoConfig.tile_layer_url|e('html_attr') }}" data-tile-layer-attribution="{{ geoConfig.tile_layer_attribution|e('html_attr') }}"></div>
        «ELSE»
            <div id="geographicalInfo" class="d-none" data-context="«actionName»" data-latitude="{{ «objName».latitude|«application.appName.formatForDB»_geoData }}" data-longitude="{{ «objName».longitude|«application.appName.formatForDB»_geoData }}" data-zoom-level="{{ geoConfig.default_zoom_level|e('html_attr') }}" data-tile-layer-url="{{ geoConfig.tile_layer_url|e('html_attr') }}" data-tile-layer-attribution="{{ geoConfig.tile_layer_attribution|e('html_attr') }}"«IF actionName == 'edit'» data-use-geolocation="{% if mode == 'create' and geoConfig.enable_«name.formatForSnakeCase»_geo_location %}true{% else %}false{% endif %}"«ENDIF»></div>
        «ENDIF»

    '''
}
