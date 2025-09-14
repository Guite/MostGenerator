package org.zikula.modulestudio.generator.cartridges.symfony.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GeoFunctions {

    extension ControllerExtensions = new ControllerExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with display functionality.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!hasGeographical) {
            return
        }
        'Generating JavaScript for geographical functions'.printIfNotTesting(fsa)
        var fileName = appName + '.Geo.js'
        fsa.generateFile(getAppJsPath + fileName, generate)
        if (!getGeographicalEntities.filter[hasIndexAction].empty) {
            fileName = appName + '.ViewMap.js'
            fsa.generateFile(getAppJsPath + fileName, generateViewMap)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «IF hasDetailActions || hasEditActions»
            «initGeoDisplay»
        «ENDIF»
        «IF hasEditActions»

            /**
             * Callback method for geolocation functionality.
             */
            function «vendorAndName»NewCoordinatesEventHandler() {
                var position;

                position = new L.LatLng(jQuery("[id$='latitude']").val(), jQuery("[id$='longitude']").val());
                marker.setLatLng(position);
                map.setView(position, map.getZoom());
            }

            «initGeoLocation»

            «initGeoEditing»
        «ENDIF»

        jQuery(document).ready(function () {
            var infoElem, parameters;

            infoElem = jQuery('#geographicalInfo');
            if (infoElem.length == 0) {
                return;
            }

            parameters = {
                latitude: infoElem.data('latitude'),
                longitude: infoElem.data('longitude'),
                zoomLevel: infoElem.data('zoom-level'),
                tileLayerUrl: infoElem.data('tile-layer-url'),
                tileLayerAttribution: infoElem.data('tile-layer-attribution'),
                useGeoLocation: false
            };

            if (infoElem.data('context') == 'detail') {
                «vendorAndName»InitGeographicalDisplay(parameters, false);
            } else if (infoElem.data('context') == 'edit') {
                parameters.useGeoLocation = 'true' == infoElem.attr('data-use-geolocation');
                «vendorAndName»InitGeographicalEditing(parameters);
            }
        });
    '''

    def private initGeoDisplay(Application it) '''
        var map;
        var marker;

        /**
         * Initialises geographical display features.
         */
        function «vendorAndName»InitGeographicalDisplay(parameters, isEditMode) {
            var centerLocation;

            centerLocation = new L.LatLng(parameters.latitude, parameters.longitude);

            // create map and center to given coordinates
            map = L.map('mapContainer').setView(centerLocation, parameters.zoomLevel);

            // add tile layer
            L.tileLayer(parameters.tileLayerUrl, {
                attribution: parameters.tileLayerAttribution
            }).addTo(map);

            // add a marker
            marker = new L.marker(centerLocation, {
                draggable: isEditMode
            });
            marker.addTo(map);«/*
                .bindPopup('A pretty CSS3 popup.<br> Easily customizable.')
                .openPopup();*/»

            jQuery('#mapTab').on('shown.bs.tab', function () {
                // redraw the map after it's tab has been opened
                map.invalidateSize();
            });
        }
    '''

    def private initGeoLocation(Application it) '''
        /**
         * Callback method for geolocation functionality.
         */
        function «vendorAndName»SetDefaultCoordinates (position) {
            jQuery("[id$='latitude']").val(position.coords.latitude.toFixed(7));
            jQuery("[id$='longitude']").val(position.coords.longitude.toFixed(7));
            «vendorAndName»NewCoordinatesEventHandler();
        }

        function «vendorAndName»HandlePositionError (event) {
            «vendorAndName»SimpleAlert(jQuery('#mapContainer'), Translator.trans('Error during geolocation'), event.message, 'geoLocationAlert', 'danger');
        }
    '''

    def private initGeoEditing(Application it) '''
        /**
         * Initialises geographical editing features.
         */
        function «vendorAndName»InitGeographicalEditing(parameters) {
            «vendorAndName»InitGeographicalDisplay(parameters, true);

            // init event handler
            jQuery("[id$='latitude']").change(«vendorAndName»NewCoordinatesEventHandler);
            jQuery("[id$='longitude']").change(«vendorAndName»NewCoordinatesEventHandler);

            map.on('click', function (event) {
                var coords = event.latlng;
                jQuery("[id$='latitude']").val(coords.lat.toFixed(7));
                jQuery("[id$='longitude']").val(coords.lng.toFixed(7));
                «vendorAndName»NewCoordinatesEventHandler();
            });
            marker.on('dragend', function (event) {
                var coords = event.target.getLatLng();
                jQuery("[id$='latitude']").val(coords.lat.toFixed(7));
                jQuery("[id$='longitude']").val(coords.lng.toFixed(7));
                «vendorAndName»NewCoordinatesEventHandler();
            });

            if (true === parameters.useGeoLocation) {
                // derive default coordinates from users position with html5 geolocation feature
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(«vendorAndName»SetDefaultCoordinates, «vendorAndName»HandlePositionError, {
                        enableHighAccuracy: true,
                        maximumAge: 10000,
                        timeout: 20000
                    });
                }
            }
        }
    '''

    def private generateViewMap(Application it) '''
        'use strict';

        var map;
        var objectType;
        var entityMarkers;
        var labelMarkers;

        /**
         * Reacts on map zoom change.
         */
        function handleViewMapZoom() {
            if (map.getZoom() > 10) {
                map.addLayer(labelMarkers);
                map.removeLayer(entityMarkers);
            } else {
                map.addLayer(entityMarkers);
                map.removeLayer(labelMarkers);
            }
        }

        /**
         * Collects marker data for the current map.
         */
        function collectMarkers() {
            var markerData = [];

            jQuery('.map-marker-definition').each(function (index) {
                markerData.push({
                    latitude: jQuery(this).data('latitude'),
                    longitude: jQuery(this).data('longitude'),
                    title: jQuery(this).data('title'),
                    image: jQuery(this).data('image'),
                    detailUrl: jQuery(this).data('detail-url')
                });
            });

            return markerData;
        }

        /**
         * Adds markers to the current map.
         */
        function addMarkers(markerData) {
            entityMarkers.clearLayers();
            labelMarkers.clearLayers();

            for (var i = 0; i < markerData.length; i++) {
                var marker = markerData[i];
                var markerCaption = (marker.image ? '<img src="' + marker.image + '" alt="Image" style="max-width: 100px !important" /><br />' : '') + marker.title;
                if ('undefined' !== typeof marker.detailUrl && marker.detailUrl) {
                    markerCaption += '<br /><a href="' + marker.detailUrl + '" target="_blank"><i class="fas fa-arrow-circle-right"></i> Details</a>';
                }
                L.marker([marker.latitude, marker.longitude]).bindPopup(markerCaption).addTo(entityMarkers);
                L.marker([marker.latitude, marker.longitude], {
                    icon: L.divIcon({
                        className: 'detail-marker',
                        html: markerCaption
                    })
                })/*.bindPopup(markerCaption)*/.addTo(labelMarkers);
            }

            if (entityMarkers.getLayers().length > 0) {
                map.fitBounds(entityMarkers.getBounds());
                handleViewMapZoom();
            }
        }

        /**
         * Initialises geographical view features.
         */
        function «vendorAndName»InitGeographicalView(parameters) {
            // create map and focus on DACH by default
            map = L.map('mapContainer').setView([49.210, 11.997], 5);

            // add tile layer
            L.tileLayer(parameters.tileLayerUrl, {
                attribution: parameters.tileLayerAttribution
            }).addTo(map);

            entityMarkers = L.featureGroup();
            labelMarkers = L.featureGroup().addTo(map);

            addMarkers(collectMarkers());

            map.on('zoomend', handleViewMapZoom);
        }

        jQuery(document).ready(function () {
            var infoElem, parameters;

            infoElem = jQuery('#geographicalInfo');
            if (0 == infoElem.length) {
                return;
            }

            objectType = infoElem.data('object-type');

            parameters = {
                tileLayerUrl: infoElem.data('tile-layer-url'),
                tileLayerAttribution: infoElem.data('tile-layer-attribution')
            };

            if ('index' == infoElem.data('context')) {
                «vendorAndName»InitGeographicalView(parameters);
            }
        });
    '''
}
