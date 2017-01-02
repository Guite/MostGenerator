package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.AjaxController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EditAction
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UploadField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Section
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Forms {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    SimpleFields fieldHelper = new SimpleFields
    Relations relationHelper = new Relations

    def generate(Application it, IFileSystemAccess fsa) {
        for (controller : controllers) {
            if (!(controller instanceof AjaxController)) {
                for (action : controller.actions.filter(EditAction)) {
                    action.generate(it, fsa)
                }
            }
        }

        for (entity : getAllEntities.filter[hasActions('edit')]) {
            entity.generate(it, 'edit', fsa)
            if (needsAutoCompletion) {
                entity.entityInlineRedirectHandlerFile(it, fsa)
            }
        }
    }

    /**
     * Entry point for form templates for each edit action in legacy controllers.
     */
    def private generate(Action it, Application app, IFileSystemAccess fsa) {
        controller.inlineRedirectHandlerFile(app, fsa)
    }

    /**
     * Entry point for form templates for each entity.
     */
    def private generate(Entity it, Application app, String actionName, IFileSystemAccess fsa) {
        val templatePath = editTemplateFile(actionName)
        if (!app.shouldBeSkipped(templatePath)) {
            println('Generating edit form templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templatePath, '''
                «formTemplateHeader(app, actionName)»
                «formTemplateBody(app, actionName, fsa)»
            ''')
        }
        relationHelper.generateInclusionTemplate(it, app, fsa)
    }

    def private formTemplateHeader(Entity it, Application app, String actionName) '''
        {# purpose of this template: build the form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» #}
        {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}

        {% block header %}
            {{ parent() }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».EditFunctions.js')) }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».Validation.js')) }}
            «IF (hasUserFieldsEntity || !getOutgoingJoinRelations.empty || !getIncomingJoinRelations.empty)»
                {{ pageAddAsset('javascript', pagevars.homepath ~ 'vendor/twitter/typeahead.js/dist/typeahead.bundle.min.js') }}
            «ENDIF»
        {% endblock %}

        {% block title mode == 'create' ? __('Create «name.formatForDisplay»') : __('Edit «name.formatForDisplay»') %}
        {% block admin_page_icon mode == 'create' ? 'plus' : 'pencil-square-o' %}
        {% block content %}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-edit">
    '''

    def private formTemplateBody(Entity it, Application app, String actionName, IFileSystemAccess fsa) '''
        {% form_theme form with [
            '@«application.appName»/Form/bootstrap_3.html.twig',
            'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
        ] %}
        {{ form_start(form, {attr: {id: '«name.formatForCode»EditForm'}}) }}
        {{ form_errors(form) }}
        «IF useGroupingPanels('edit')»
            <div class="panel-group" id="accordion">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseFields">{{ __('Fields') }}</a></h3>
                    </div>
                    <div id="collapseFields" class="panel-collapse collapse in">
                        <div class="panel-body">
                            «fieldDetails(app)»
                        </div>
                    </div>
                </div>
                «new Section().generate(it, app, fsa)»
            </div>
        «ELSE»
            «fieldDetails(app)»
            «new Section().generate(it, app, fsa)»
        «ENDIF»
        {{ form_end(form) }}
        </div>
        {% endblock %}
        {% block footer %}
            {{ parent() }}

            «formTemplateJS(app, actionName)»
        {% endblock %}
    '''

    def private fieldDetails(Entity it, Application app) '''
        «translatableFieldDetails»
        «IF !hasTranslatableFields
          || (hasTranslatableFields && (!getEditableNonTranslatableFields.empty || (hasSluggableFields && !hasTranslatableSlug)))
          || geographical»
            «fieldDetailsFurtherOptions(app)»
        «ENDIF»
    '''

    def private translatableFieldDetails(Entity it) '''
        «IF hasTranslatableFields»
            {% set useOnlyCurrentLanguage = true %}
            {% if getModVar('ZConfig', 'multilingual') %}
                {% if supportedLanguages is iterable and supportedLanguages|length > 1 %}
                    {% set useOnlyCurrentLanguage = false %}
                    {% set currentLanguage = app.request.locale %}
                    {% for language in supportedLanguages %}
                        {% if language == currentLanguage %}
                            «translatableFieldSet('', '')»
                        {% endif %}
                    {% endfor %}
                    {% for language in supportedLanguages %}
                        {% if language != currentLanguage %}
                            «translatableFieldSet('', 'language')»
                        {% endif %}
                    {% endfor %}
                {% endif %}
            {% endif %}
            {% if useOnlyCurrentLanguage == true %}
                {% set language = app.request.locale %}
                «translatableFieldSet('', '')»
            {% endif %}
        «ENDIF»
    '''

    def private translatableFieldSet(Entity it, String groupSuffix, String idSuffix) '''
        <fieldset>
            <legend>{{ language|languageName|safeHtml }}</legend>
            «FOR field : getEditableTranslatableFields»«field.fieldWrapper(groupSuffix, idSuffix)»«ENDFOR»
            «IF hasTranslatableSlug»
                «slugField(groupSuffix, idSuffix)»
            «ENDIF»
        </fieldset>
    '''

    def private fieldDetailsFurtherOptions(Entity it, Application app) '''
        <fieldset>
            <legend>{{ __('«IF hasTranslatableFields»Further properties«ELSE»Content«ENDIF»') }}</legend>
            «IF hasTranslatableFields»
                «FOR field : getEditableNonTranslatableFields»«field.fieldWrapper('', '')»«ENDFOR»
            «ELSE»
                «FOR field : getEditableFields»«field.fieldWrapper('', '')»«ENDFOR»
            «ENDIF»
            «IF !hasTranslatableFields || (hasSluggableFields && !hasTranslatableSlug)»
                «slugField('', '')»
            «ENDIF»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    {{ form_row(form.«geoFieldName») }}
                «ENDFOR»
            «ENDIF»
        </fieldset>
    '''

    def private slugField(Entity it, String groupSuffix, String idSuffix) '''
        «IF hasSluggableFields && slugUpdatable»
            {{ form_row(form.«IF groupSuffix != ''»«groupSuffix».«ENDIF»slug«idSuffix») }}
        «ENDIF»
    '''

    def private formTemplateJS(Entity it, Application app, String actionName) '''
        {% set editImage = '<span class="fa fa-pencil-square-o"></span>' %}
        {% set deleteImage = '<span class="fa fa-trash-o"></span>' %}
        «IF geographical»

            {% set geoScripts %}
                <script type="text/javascript" src="https://maps.google.com/maps/api/js?sensor=false"></script>
                <script type="text/javascript" src="{{ pagevars.homepath }}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                {#<script type="text/javascript" src="{{ pagevars.homepath }}plugins/Mapstraction/lib/vendor/mxn/mxn.geocoder.js"></script>
                <script type="text/javascript" src="{{ pagevars.homepath }}plugins/Mapstraction/lib/vendor/mxn/mxn.googlev3.geocoder.js"></script>#}
                <script type="text/javascript">
                /* <![CDATA[ */

                    var mapstraction;
                    var marker;

                    ( function($) {
                        $(document).ready(function() {
                            «newCoordinatesEventHandler»

                            «initGeographical(app)»
                        });
                    })(jQuery);
                /* ]]> */
                </script>
            {% endset %}
            {{ pageAddAsset('footer', geoScripts) }}
        «ENDIF»

        <script type="text/javascript">
        /* <![CDATA[ */
            «jsInitImpl(app)»
        /* ]]> */
        </script>
    '''

    def private jsInitImpl(Entity it, Application app) '''
        «relationHelper.initJs(it, app, false)»

        var formButtons;
        var triggerValidation = true;

        function executeCustomValidationConstraints()
        {
            «application.vendorAndName»PerformCustomValidationRules('«name.formatForCode»', '{% if mode != 'create' %}{{ «FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForDB».«pkField.name.formatForCode»«ENDFOR» }}{% endif %}');
        }

        function triggerFormValidation()
        {
            executeCustomValidationConstraints();
            if (!document.getElementById('«name.formatForCode»EditForm').checkValidity()) {
                // This does not really submit the form,
                // but causes the browser to display the error message
                jQuery('#«name.formatForCode»EditForm').find(':submit').first().click();
            }
        }

        function handleFormSubmit (event) {
            if (triggerValidation) {
                triggerFormValidation();
                if (!document.getElementById('«name.formatForCode»EditForm').checkValidity()) {
                    event.preventDefault();
                    return false;
                }
            }

            // hide form buttons to prevent double submits by accident
            formButtons.each(function (index) {
                jQuery(this).addClass('hidden');
            });

            return true;
        }

        ( function($) {
            $(document).ready(function() {
                «IF hasImageFieldsEntity»
                    $('a.lightbox').lightbox();
                «ENDIF»
                «val userFields = getUserFieldsEntity»
                «IF !userFields.empty»
                    // initialise auto completion for user fields
                    «FOR userField : userFields»
                        «val realName = userField.name.formatForCode»
                        «app.vendorAndName»InitUserField('«app.appName.toLowerCase»_«name.formatForCode.toLowerCase»_«realName»', 'get«name.formatForCodeCapital»«realName.formatForCodeCapital»Users');
                    «ENDFOR»
                «ENDIF»
                «relationHelper.initJs(it, app, true)»

                var allFormFields = $('#«name.formatForCode»EditForm input, #«name.formatForCode»EditForm select, #«name.formatForCode»EditForm textarea');
                allFormFields.change(executeCustomValidationConstraints);

                formButtons = $('#«name.formatForCode»EditForm .form-buttons input');
                $('.btn-danger').first().bind('click keypress', function (event) {
                    if (!window.confirm('{{ __('Really delete this «name.formatForDisplay»?') }}')) {
                        event.preventDefault();
                    }
                });
                $('#«name.formatForCode»EditForm button[type=submit]').bind('click keypress', function (event) {
                    triggerValidation = !$(this).attr('formnovalidate');
                });
                $('#«name.formatForCode»EditForm').submit(handleFormSubmit);

                {% if mode != 'create' %}
                    triggerFormValidation();
                {% endif %}

                «FOR field : getDerivedFields»«field.additionalInitScript»«ENDFOR»
            });
        })(jQuery);
    '''

    def private newCoordinatesEventHandler(Entity it) '''
        function newCoordinatesEventHandler() {
            var location = new mxn.LatLonPoint($('#latitude').val(), $('#longitude').val());
            marker.hide();
            mapstraction.removeMarker(marker);
            marker = new mxn.Marker(location);
            mapstraction.addMarker(marker, true);
            mapstraction.setCenterAndZoom(location, 18);
        }
    '''

    def private initGeographical(Entity it, Application app) '''
        mapstraction = new mxn.Mapstraction('mapContainer', 'googlev3');
        mapstraction.addControls({
            pan: true,
            zoom: 'small',
            map_type: true
        });

        var latlon = new mxn.LatLonPoint({{ «name.formatForDB».latitude|«app.appName.formatForDB»_geoData }}, {{ «name.formatForDB».longitude|«app.appName.formatForDB»_geoData }});

        mapstraction.setMapType(mxn.Mapstraction.SATELLITE);
        mapstraction.setCenterAndZoom(latlon, 16);
        mapstraction.mousePosition('position');

        // add a marker
        marker = new mxn.Marker(latlon);
        mapstraction.addMarker(marker, true);

        // init event handler
        $('#latitude').change(newCoordinatesEventHandler);
        $('#longitude').change(newCoordinatesEventHandler);

        $('#collapseMap').on('hidden.bs.collapse', function () {
            // redraw the map after it's panel has been opened (see also #340)
            mapstraction.resizeTo($('#mapContainer').width(), $('#mapContainer').height());
        })

        mapstraction.click.addHandler(function(event_name, event_source, event_args) {
        	var coords = event_args.location;
            $("[id$='latitude']").val(coords.lat.toFixed(7));
            $("[id$='longitude']").val(coords.lng.toFixed(7));
            newCoordinatesEventHandler();
        });

        {% if mode == 'create' %}
            // derive default coordinates from users position with html5 geolocation feature
            /*if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(«app.vendorAndName»SetDefaultCoordinates, «app.vendorAndName»HandlePositionError, { enableHighAccuracy: true, maximumAge: 10000, timeout: 20000 });
            }*/
        {% endif %}

        {#
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

            «app.vendorAndName»InitGeoCoding(determineAddressForGeoCoding);
        #}
    '''

    def private fieldWrapper(DerivedField it, String groupSuffix, String idSuffix) '''
        «/* No input fields for foreign keys, relations are processed further down */»
        «IF entity.getIncomingJoinRelations.filter[e|e.getSourceFields.head == name.formatForDB].empty»
            «IF !visible»
                <div class="hidden">
                    «fieldHelper.formRow(it, groupSuffix, idSuffix)»
                </div>
            «ELSE»
                «fieldHelper.formRow(it, groupSuffix, idSuffix)»
            «ENDIF»
        «ENDIF»
    '''

    def private additionalInitScript(DerivedField it) {
        switch it {
            UploadField: additionalInitScriptUpload
            DatetimeField: additionalInitScriptCalendar
            DateField: additionalInitScriptCalendar
        }
    }

    def private additionalInitScriptUpload(UploadField it) '''
        «entity.application.vendorAndName»InitUploadField('«entity.application.appName.toLowerCase»_«entity.name.formatForCode.toLowerCase»_«name.formatForCode»_«name.formatForCode»');
    '''

    def private additionalInitScriptCalendar(AbstractDateField it) '''
        «IF !mandatory»
            «entity.application.vendorAndName»InitDateField('«entity.application.appName.toLowerCase»_«entity.name.formatForCode.toLowerCase»_«name.formatForCode»');
        «ENDIF»
    '''

    def private entityInlineRedirectHandlerFile(Entity it, Application app, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + name.formatForCodeCapital + '/'
        val templateExtension = '.html.twig'
        var fileName = 'inlineRedirectHandler' + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = 'inlineRedirectHandler.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, app.inlineRedirectHandlerImpl)
        }
    }

    def private inlineRedirectHandlerFile(Controller it, Application app, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + formattedName.toFirstUpper + '/'
        val templateExtension = '.html.twig'
        var fileName = 'inlineRedirectHandler' + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = 'inlineRedirectHandler.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, app.inlineRedirectHandlerImpl)
        }
    }

    def private inlineRedirectHandlerImpl(Application it) '''
        {# purpose of this template: close an iframe from within this iframe #}
        <!DOCTYPE html>
        <html xml:lang="{{ app.request.locale }}" lang="{{ app.request.locale }}" dir="{{ localeApi.language_direction }}">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                {{ jcssConfig }}
                {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap.min.css')) }}
                {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap-theme.min.css')) }}
                {{ pageAddAsset('javascript', asset('jquery/jquery.min.js')) }}
                {{ pageAddAsset('javascript', asset('bootstrap/js/bootstrap.min.js')) }}
                {{ pageAddAsset('javascript', zasset('@«appName»:javascript/«appName».EditFunctions.js')) }}
            </head>
            <body>
                <script type="text/javascript">
                /* <![CDATA[ */
                    // close window from parent document
                    ( function($) {
                        $(document).ready(function() {
                            «vendorAndName»CloseWindowFromInside('{{ idPrefix|e('js') }}', {% if commandName == 'create' %}{{ itemId }}{% else %}0{% endif %});«/*value > 0 causes the auto completion being activated*/»
                        });
                    })(jQuery);
                /* ]]> */
                </script>
            </body>
        </html>
    '''
}
