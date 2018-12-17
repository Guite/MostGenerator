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

        if (attributable) weight = weight + 1
        if (categorisable) weight = weight + 1
        if (standardFields) weight = weight + 1
        if (geographical) weight = weight + 1
        //if (tree != EntityTreeType.NONE) weight = weight + 1
        weight
    }

    /**
     * Returns a list of view formats supported by an application.
     */
    def getListOfViewFormats(Application it) {
        var formats = newArrayList
        if (!hasViewActions) {
            return formats
        }
        if (generateCsvTemplates) {
            formats.add('csv')
        }
        if (generateRssTemplates) {
            formats.add('rss')
        }
        if (generateAtomTemplates) {
            formats.add('atom')
        }
        if (generateXmlTemplates) {
            formats.add('xml')
        }
        if (generateJsonTemplates) {
            formats.add('json')
        }
        if (generateKmlTemplates && hasGeographical) {
            formats.add('kml')
        }
        if (generatePdfSupport) {
            formats.add('pdf')
        }
        formats
    }

    /**
     * Returns a list of display formats supported by an application.
     */
    def getListOfDisplayFormats(Application it) {
        var formats = newArrayList
        if (!hasDisplayActions) {
            return formats
        }
        if (generateXmlTemplates) {
            formats.add('xml')
        }
        if (generateJsonTemplates) {
            formats.add('json')
        }
        if (generateKmlTemplates && hasGeographical) {
            formats.add('kml')
        }
        if (hasEntitiesWithIcsTemplates && hasDisplayActions) {
            formats.add('ics')
        }
        if (generatePdfSupport) {
            formats.add('pdf')
        }
        formats
    }

    /**
     * Returns whether jQuery UI is needed or not.
     */
    def needsJQueryUI(Application it) {
        (hasSortable && hasViewActions)
        || (!relations.empty && (hasViewActions || hasDisplayActions || hasEditActions))
    }

    /**
     * Returns the code used for including Leaflet.
     */
    def includeLeaflet(Entity it, String actionName, String objName) '''
        {% set pathToLeaflet = zasset('@«application.appName»:css/style.css')|replace({'Resources/public/css/style.css': ''}) ~ 'vendor/drmonty/leaflet/' %}
        {{ pageAddAsset('stylesheet', pathToLeaflet ~ 'css/leaflet.css') }}
        {{ pageAddAsset('javascript', pathToLeaflet ~ 'js/leaflet' ~ (app.environment == 'dev' ? '' : '.min') ~ '.js') }}
        «IF 'view' == actionName»
            <div id="geographicalInfo" class="hidden" data-context="«actionName»" data-object-type="«objName»" data-tile-layer-url="{{ getModVar('«application.appName»', 'tileLayerUrl') }}" data-tile-layer-attribution="{{ getModVar('«application.appName»', 'tileLayerAttribution') }}"></div>
        «ELSE»
            <div id="geographicalInfo" class="hidden" data-context="«actionName»" data-latitude="{{ «objName».latitude|«application.appName.formatForDB»_geoData }}" data-longitude="{{ «objName».longitude|«application.appName.formatForDB»_geoData }}" data-zoom-level="{{ getModVar('«application.appName»', 'defaultZoomLevel', 18) }}" data-tile-layer-url="{{ getModVar('«application.appName»', 'tileLayerUrl') }}" data-tile-layer-attribution="{{ getModVar('«application.appName»', 'tileLayerAttribution') }}"«IF actionName == 'edit'» data-use-geolocation="{% if mode == 'create' and getModVar('«application.appName»', 'enable«name.formatForCodeCapital»GeoLocation', false) == true %}true{% else %}false{% endif %}"«ENDIF»></div>
        «ENDIF»

    '''
}
