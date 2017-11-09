package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GeoFunctions {

    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the JavaScript file with display functionality.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = appName + '.Geo.js'
        if (!shouldBeSkipped(getAppJsPath + fileName)) {
            println('Generating JavaScript for geographical functions')
            if (shouldBeMarked(getAppJsPath + fileName)) {
                fileName = appName + '.generated.js'
            }
            fsa.generateFile(getAppJsPath + fileName, generate)
        }
    }

    def private generate(Application it) '''
        'use strict';

        «IF hasDisplayActions || hasEditActions»
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

            if (infoElem.data('context') == 'display') {
                «vendorAndName»InitGeographicalDisplay(parameters, false);
            } else if (infoElem.data('context') == 'edit') {
                parameters.useGeoLocation = infoElem.data('use-geolocation');
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

            jQuery('#tabMap').on('shown.bs.tab', function () {
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
            «vendorAndName»SimpleAlert(jQuery('#mapContainer'), Translator.__('Error during geolocation'), event.message, 'geoLocationAlert', 'danger');
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
}
