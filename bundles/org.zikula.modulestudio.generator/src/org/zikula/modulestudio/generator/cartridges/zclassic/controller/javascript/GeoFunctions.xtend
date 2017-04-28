package org.zikula.modulestudio.generator.cartridges.zclassic.controller.javascript

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GeoFunctions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
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
             * Callback method for geocoding and geolocation functionality.
             */
            function «vendorAndName»NewCoordinatesEventHandler() {
                var location = new mxn.LatLonPoint(jQuery("[id$='latitude']").val(), jQuery("[id$='longitude']").val());
                marker.hide();
                mapstraction.removeMarker(marker);
                marker = new mxn.Marker(location);
                mapstraction.addMarker(marker, true);
                mapstraction.setCenterAndZoom(location, defaultZoomLevel);
            }

            «initGeoCoding»

            «initGeoLocation»

            «initGeoEditing»
        «ENDIF»
    '''

    def private initGeoDisplay(Application it) '''
        var mapstraction;
        var marker;
        var defaultZoomLevel;

        /**
         * Initialises geographical display features.
         */
        function «vendorAndName»InitGeographicalDisplay(latitude, longitude, mapType, zoomLevel)
        {
            defaultZoomLevel = zoomLevel;

            mapstraction = new mxn.Mapstraction('mapContainer', 'googlev3');
            mapstraction.addControls({
                pan: true,
                zoom: 'small',
                map_type: true
            });

            var location = new mxn.LatLonPoint(latitude, longitude);

            if (mapType == 'roadmap') {
                mapstraction.setMapType(mxn.Mapstraction.ROAD);
            } else if (mapType == 'satellite') {
                mapstraction.setMapType(mxn.Mapstraction.SATELLITE);
            } else if (mapType == 'hybrid') {
                mapstraction.setMapType(mxn.Mapstraction.HYBRID);
            } else if (mapType == 'physical') {
                mapstraction.setMapType(mxn.Mapstraction.PHYSICAL);
            } else {
                mapstraction.setMapType(mxn.Mapstraction.ROAD);
            }

            mapstraction.setCenterAndZoom(location, defaultZoomLevel);
            mapstraction.mousePosition('position');

            // add a marker
            marker = new mxn.Marker(latlon);
            mapstraction.addMarker(marker, true);

            jQuery('#collapseMap').on('hidden.bs.collapse', function () {
                // redraw the map after it's panel has been opened (see also #340)
                mapstraction.resizeTo(jQuery('#mapContainer').width(), jQuery('#mapContainer').height());
            })
        }
    '''

    def private initGeoCoding(Application it) '''
        /**
         * Example method for initialising geo coding functionality in JavaScript.
         * In contrast to the map picker this one determines coordinates for a given address.
         * Uses a callback function for retrieving the address to be converted, so that it can be easily customised in each edit template.
         * There is also a method on PHP level available in the \«vendor.formatForCodeCapital»\«name.formatForCodeCapital»Module\Helper\ControllerHelper class.
         */
        function «vendorAndName»InitGeoCoding(addressCallback)
        {
            jQuery('#linkGetCoordinates').click( function (evt) {
                «vendorAndName»DoGeoCoding(addressCallback);
            });
        }

        /**
         * Performs the actual geo coding using Mapstraction.
         */
        function «vendorAndName»DoGeoCoding(addressCallback)
        {
            var address = {
                address : jQuery('#street').val() + ' ' + jQuery('#houseNumber').val() + ' ' + jQuery('#zipcode').val() + ' ' + jQuery('#city').val() + ' ' + jQuery('#country').val()
            };

            // Check whether the given callback is executable
            if (typeof addressCallback === 'function') {
                address = addressCallback();
            }

            var geocoder = new mxn.Geocoder('googlev3', «vendorAndName»GeoCodeReturn, «vendorAndName»GeoCodeErrorCallback);
            geocoder.geocode(address);

            function «vendorAndName»GeoCodeErrorCallback (status) {
                if (status != 'ZERO_RESULTS') {
                    «vendorAndName»SimpleAlert(jQuery('#mapContainer'), Translator.__('Error during geocoding'), status, 'geoCodingAlert', 'danger');
                }
            }

            function «vendorAndName»GeoCodeReturn (location) {
                jQuery("[id$='latitude']").val(location.point.lat.toFixed(7));
                jQuery("[id$='longitude']").val(location.point.lng.toFixed(7));
                «vendorAndName»NewCoordinatesEventHandler();
            }
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
        function «vendorAndName»InitGeographicalEditing(latitude, longitude, mapType, zoomLevel, mode, useGeoLocation)
        {
            «vendorAndName»InitGeographicalDisplay(latitude, longitude, mapType, zoomLevel);

            // init event handler
            jQuery("[id$='latitude']").change(«vendorAndName»NewCoordinatesEventHandler);
            jQuery("[id$='longitude']").change(«vendorAndName»NewCoordinatesEventHandler);

            mapstraction.click.addHandler(function(eventName, eventSource, eventArgs) {
                var coords = eventArgs.location;
                jQuery("[id$='latitude']").val(coords.lat.toFixed(7));
                jQuery("[id$='longitude']").val(coords.lng.toFixed(7));
                «vendorAndName»NewCoordinatesEventHandler();
            });

            if (mode == 'create' && true === useGeoLocation) {
                // derive default coordinates from users position with html5 geolocation feature
                if (navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(«vendorAndName»SetDefaultCoordinates, «vendorAndName»HandlePositionError, {
                        enableHighAccuracy: true,
                        maximumAge: 10000,
                        timeout: 20000
                    });
                }
            }

            /*
                Initialise geocoding functionality.
                In contrast to the map picker this one determines coordinates for a given address.
                To use this please customise the following method for assembling the address.
                Furthermore you will need a link or a button with id="linkGetCoordinates" which will
                be used by the script for adding a corresponding click event handler.

                var determineAddressForGeoCoding = function () {
                    var address = {
                        address : $('#street').val() + ' ' + $('#houseNumber').val() + ' ' + $('#zipcode').val() + ' ' + $('#city').val() + ' ' + $('#country').val()
                    };

                    return address;
                }

                «vendorAndName»InitGeoCoding(determineAddressForGeoCoding);
            */
        }
    '''
}
