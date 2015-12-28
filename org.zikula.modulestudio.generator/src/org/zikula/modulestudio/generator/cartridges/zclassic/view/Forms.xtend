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
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.UploadField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Section
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Forms {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
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
            entity.entityInlineRedirectHandlerFile(it, fsa)
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

    /* TODO migrate to Symfony forms #416 */

    def private formTemplateHeader(Entity it, Application app, String actionName) '''
        «IF app.targets('1.3.x')»
            {* purpose of this template: build the form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» *}
            {assign var='lct' value='user'}
            {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                {assign var='lct' value='admin'}
            {/if}
            {include file="`$lct`/header.tpl"}
        «ELSE»
            {# purpose of this template: build the form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» #}
            {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        «ENDIF»
        «IF app.targets('1.3.x')»
            {pageaddvar name='javascript' value='«app.rootFolder»/«app.appName»/javascript/«app.appName»_editFunctions.js'}
            {pageaddvar name='javascript' value='«app.rootFolder»/«app.appName»/javascript/«app.appName»_validation.js'}
        «ELSE»
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».EditFunctions.js')) }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».Validation.js')) }}
            «IF (hasUserFieldsEntity || !getOutgoingJoinRelations.empty || !getIncomingJoinRelations.empty)»
                {{ pageAddAsset('javascript', 'web/bootstrap-3-typeahead/bootstrap3-typeahead.min.js') }}
            «ENDIF»
        «ENDIF»

        «IF app.targets('1.3.x')»
            {if $mode ne 'create'}
                {gt text='Edit «name.formatForDisplay»' assign='templateTitle'}
                «pageIcon('edit')»
            {elseif $mode eq 'create'}
                {gt text='Create «name.formatForDisplay»' assign='templateTitle'}
                «pageIcon('new')»
            {/if}
        «ELSE»
            {% if mode != 'create' %}
                {% block title %}
                    {{ __('Edit «name.formatForDisplay»') }}
                {% endblock %}
                {% block adminPageIcon %}pencil-square-o{% endblock %}
            {% elseif mode == 'create' %}
                {% block title %}
                    {{ __('Create «name.formatForDisplay»') }}
                {% endblock %}
                {% block adminPageIcon %}plus{% endblock %}
            {% endif %}
        «ENDIF»
        «IF app.targets('1.3.x')»
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-edit">
                {pagesetvar name='title' value=$templateTitle}
                «templateHeader»
        «ELSE»
            {% block content %}
                <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-edit">
        «ENDIF»
    '''

    // 1.3.x only
    def private pageIcon(Entity it, String iconName) '''
        {if $lct eq 'admin'}
            {assign var='adminPageIcon' value='«iconName»'}
        {/if}
    '''

    // 1.3.x only
    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            <div class="z-admin-content-pagetitle">
                {icon type=$adminPageIcon size='small' alt=$templateTitle}
                <h3>{$templateTitle}</h3>
            </div>
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''

    def private formTemplateBody(Entity it, Application app, String actionName, IFileSystemAccess fsa) '''
        {form «IF hasUploadFieldsEntity»enctype='multipart/form-data' «ENDIF»cssClass='«IF app.targets('1.3.x')»z-form«ELSE»form-horizontal«ENDIF»'«IF !app.targets('1.3.x')» role='form'«ENDIF»}
            «IF app.targets('1.3.x')»
                {* add validation summary and a <div> element for styling the form *}
            «ELSE»
                {# add validation summary and a <div> element for styling the form #}
            «ENDIF»
            {«app.appName.formatForDB»FormFrame}
            «IF !getEditableFields.empty»
                «IF (getEditableFields.head) instanceof ListField && !(getEditableFields.head as ListField).useChecks»
                    {formsetinitialfocus inputId='«(getEditableFields.head).name.formatForCode»' doSelect=true}
                «ELSE»
                    {formsetinitialfocus inputId='«(getEditableFields.head).name.formatForCode»'}
                «ENDIF»
            «ENDIF»

            «IF useGroupingPanels('edit')»
                «IF app.targets('1.3.x')»
                    <div id="«app.appName.toFirstLower»Panel" class="z-panels">
                        <h3 id="z-panel-header-fields" class="z-panel-header z-panel-indicator z-pointer">{gt text='Fields'}</h3>
                        <div class="z-panel-content z-panel-active" style="overflow: visible">
                            «fieldDetails(app)»
                        </div>
                        «new Section().generate(it, app, fsa)»
                    </div>
                «ELSE»
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
                «ENDIF»
            «ELSE»
                «fieldDetails(app)»
                «new Section().generate(it, app, fsa)»
            «ENDIF»
            {/«app.appName.formatForDB»FormFrame}
        {/form}
        </div>
        «IF app.targets('1.3.x')»
            {include file="`$lct`/footer.tpl"}

            «formTemplateJS(app, actionName)»
        «ELSE»
            {% endblock %}
            {% block footer %}
                {{ parent() }}

                «formTemplateJS(app, actionName)»
            {% endblock %}
        «ENDIF»
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
            «IF application.targets('1.3.x')»
                {formvolatile}
                    {assign var='useOnlyCurrentLocale' value=true}
                    {if $modvars.ZConfig.multilingual}
                        {if $supportedLocales ne '' && is_array($supportedLocales) && count($supportedLocales) gt 1}
                            {assign var='useOnlyCurrentLocale' value=false}
                            {nocache}
                            {lang assign='currentLanguage'}
                            {foreach item='locale' from=$supportedLocales}
                                {if $locale eq $currentLanguage}
                                    «translatableFieldSet('', '')»
                                {/if}
                            {/foreach}
                            {foreach item='locale' from=$supportedLocales}
                                {if $locale ne $currentLanguage}
                                    «translatableFieldSet('$locale', '$locale')»
                                {/if}
                            {/foreach}
                            {/nocache}
                        {/if}
                    {/if}
                    {if $useOnlyCurrentLocale eq true}
                        {lang assign='locale'}
                        «translatableFieldSet('', '')»
                    {/if}
                {/formvolatile}
            «ELSE»
                {% set useOnlyCurrentLocale = true %}
                {% if getModVar('ZConfig', 'multilingual') %}
                    {% if supportedLocales != '' and supportedLocales is iterable and supportedLocales|length > 1 %}
                        {% set useOnlyCurrentLocale = false %}
                        {% set currentLanguage = lang() %}
                        {% for locale in supportedLocales %}
                            {% if locale == currentLanguage %}
                                «translatableFieldSet('', '')»
                            {% endif %}
                        {% endfor %}
                        {% for locale in supportedLocales %}
                            {% if locale != currentLanguage %}
                                «translatableFieldSet('$locale', '$locale')»
                            {% endif %}
                        {% endfor %}
                    {% endif %}
                {% endif %}
                {% if useOnlyCurrentLocale == true %}
                    {% set locale = lang() %}
                    «translatableFieldSet('', '')»
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def private translatableFieldSet(Entity it, String groupSuffix, String idSuffix) '''
        <fieldset>
            <legend>«IF application.targets('1.3.x')»{$locale|getlanguagename|safehtml}«ELSE»{{ locale|languageName|safeHtml }}«ENDIF»</legend>
            «FOR field : getEditableTranslatableFields»«field.fieldWrapper(groupSuffix, idSuffix)»«ENDFOR»
            «IF hasTranslatableSlug»
                «slugField(groupSuffix, idSuffix)»
            «ENDIF»
        </fieldset>
    '''

    def private fieldDetailsFurtherOptions(Entity it, Application app) '''
        <fieldset>
            <legend>{gt text='«IF hasTranslatableFields»Further properties«ELSE»Content«ENDIF»'}</legend>
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
                    <div class="«IF app.targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
                        {formlabel for='«geoFieldName»' __text='«geoFieldName.toFirstUpper»'«IF !app.targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
                        «IF !app.targets('1.3.x')»
                            <div class="col-sm-9">
                        «ENDIF»
                            {«app.appName.formatForDB»GeoInput group='«name.formatForDB»' id='«geoFieldName»' mandatory=false __title='Enter the «geoFieldName» of the «name.formatForDisplay»' cssClass='validate-number«IF !app.targets('1.3.x')» form-control«ENDIF»'}
                            «IF app.targets('1.3.x')»
                                {«app.appName.formatForDB»ValidationError id='«geoFieldName»' class='validate-number'}
                            «ENDIF»
                        «IF !app.targets('1.3.x')»
                            </div>
                        «ENDIF»
                    </div>
                «ENDFOR»
            «ENDIF»
        </fieldset>
    '''

    def private slugField(Entity it, String groupSuffix, String idSuffix) '''
        «IF hasSluggableFields && slugUpdatable && !application.targets('1.3.x')»
            <div class="«IF application.targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for=«templateIdWithSuffix('slug', idSuffix)» __text='Permalink'«/*IF slugUnique» mandatorysym='1'«ENDIF*/»«IF !application.targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
                «IF !application.targets('1.3.x')»
                    <div class="col-sm-9">
                «ENDIF»
                    {formtextinput group=«templateIdWithSuffix(name.formatForDB, groupSuffix)» id=«templateIdWithSuffix('slug', idSuffix)» mandatory=false«/*slugUnique.displayBool*/» readOnly=false __title='You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»' textMode='singleline' maxLength=255 cssClass='«IF slugUnique»«/*required */»validate-unique«ENDIF»«IF !application.targets('1.3.x')»«IF slugUnique» «ENDIF»form-control«ENDIF»'}
                    <span class="«IF application.targets('1.3.x')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»'}</span>
                «IF slugUnique && application.targets('1.3.x')»
                    «/*{«application.appName.formatForDB»ValidationError id=«templateIdWithSuffix('slug', idSuffix)» class='required'}*/»
                    {«application.appName.formatForDB»ValidationError id=«templateIdWithSuffix('slug', idSuffix)» class='validate-unique'}
                «ENDIF»
                «IF !application.targets('1.3.x')»
                    </div>
                «ENDIF»
        </div>
        «ENDIF»
    '''

    def private formTemplateJS(Entity it, Application app, String actionName) '''
        «IF app.targets('1.3.x')»
            {icon type='edit' size='extrasmall' assign='editImageArray'}
            {icon type='delete' size='extrasmall' assign='removeImageArray'}
        «ELSE»
            % set editImage = '<span class="fa fa-pencil-square-o"></span>' %}
            % set deleteImage = '<span class="fa fa-trash-o"></span>' %}
        «ENDIF»

        «IF geographical»
            «IF app.targets('1.3.x')»
                {pageaddvarblock name='header'}
                    <script type="text/javascript" src="https://maps.google.com/maps/api/js?sensor=false"></script>
                    <script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                    {*<script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.geocoder.js"></script>
                    <script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.googlev3.geocoder.js"></script>*}
                    <script type="text/javascript">
                    /* <![CDATA[ */

                        var mapstraction;
                        var marker;

                        «newCoordinatesEventHandler»

                        Event.observe(window, 'load', function() {
                            «initGeographical(app)»
                        });
                    /* ]]> */
                    </script>
                {/pageaddvarblock}
            «ELSE»
                {% set homePath = pageGetVar('homepath') %}
                {% set geoScripts %}
                    <script type="text/javascript" src="https://maps.google.com/maps/api/js?sensor=false"></script>
                    <script type="text/javascript" src="{{ homePath }}/plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                    {*<script type="text/javascript" src="{{ homePath }}/plugins/Mapstraction/lib/vendor/mxn/mxn.geocoder.js"></script>
                    <script type="text/javascript" src="{{ homePath }}/plugins/Mapstraction/lib/vendor/mxn/mxn.googlev3.geocoder.js"></script>*}
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
                {{ pageAddAsset('header', geoScripts) }}
            «ENDIF»
        «ENDIF»

        <script type="text/javascript">
        /* <![CDATA[ */
            «jsInitImpl(app)»
        /* ]]> */
        </script>
    '''

    def private jsInitImpl(Entity it, Application app) '''
        «IF app.targets('1.3.x')»
            «relationHelper.initJs(it, app, false)»

            var formButtons, formValidator;

            function handleFormButton (event) {
                var result = formValidator.validate();
                if (!result) {
                    // validation error, abort form submit
                    Event.stop(event);
                } else {
                    // hide form buttons to prevent double submits by accident
                    formButtons.each(function (btn) {
                        btn.addClassName('z-hide');
                    });
                }

                return result;
            }

            document.observe('dom:loaded', function() {
                «val userFields = getUserFieldsEntity»
                «IF !userFields.empty»
                    // initialise auto completion for user fields
                    «FOR userField : userFields»
                        «val realName = userField.name.formatForCode»
                        «app.vendorAndName»InitUserField('«realName»', 'get«name.formatForCodeCapital»«realName.formatForCodeCapital»Users');
                    «ENDFOR»
                «ENDIF»
                «relationHelper.initJs(it, app, true)»

                «application.vendorAndName»AddCommonValidationRules('«name.formatForCode»', '{{if $mode ne 'create'}}«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$«name.formatForDB».«pkField.name.formatForCode»}}«ENDFOR»{{/if}}');
                {{* observe validation on button events instead of form submit to exclude the cancel command *}}
                formValidator = new Validation('{{$__formid}}', {onSubmit: false, immediate: true, focusOnError: false});
                {{if $mode ne 'create'}}
                    var result = formValidator.validate();
                {{/if}}

                formButtons = $('{{$__formid}}').select('div.z-formbuttons input');

                formButtons.each(function (elem) {
                    if (elem.id != 'btnCancel') {
                        elem.observe('click', handleFormButton);
                    }
                });
                «IF useGroupingPanels('edit')»

                    var panel = new Zikula.UI.Panels('«app.appName.toFirstLower»Panel', {
                        headerSelector: 'h3',
                        headerClassName: 'z-panel-header z-panel-indicator',
                        contentClassName: 'z-panel-content',
                        active: $('z-panel-header-fields')
                    });
                «ENDIF»

                Zikula.UI.Tooltips($$('.«app.appName.toLowerCase»-form-tooltips'));
                «FOR field : getDerivedFields»«field.additionalInitScript»«ENDFOR»
            });
        «ELSE»
            «relationHelper.initJs(it, app, false)»

            var formButtons;

            function executeCustomValidationConstraints()
            {
                «application.vendorAndName»PerformCustomValidationRules('«name.formatForCode»', '{% if mode != 'create' %}{{ «FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForDB».«pkField.name.formatForCode»«ENDFOR» }}{% endif %}');
            }

            function triggerFormValidation()
            {
                executeCustomValidationConstraints();
                if (!document.getElementById('{{ __formid }}').checkValidity()) {
                    // This does not really submit the form,
                    // but causes the browser to display the error message
                    jQuery('#{{ __formid }}').find(':submit').not(jQuery('#btnDelete')).click();
                }
            }

            function handleFormSubmit (event) {
                triggerFormValidation();
                if (!document.getElementById('{{ __formid }}').checkValidity()) {
                    event.preventDefault();
                    return false;
                }

                // hide form buttons to prevent double submits by accident
                formButtons.each(function (index) {
                    jQuery(this).addClass('hidden');
                });

                return true;
            }

            ( function($) {
                $(document).ready(function() {
                    «val userFields = getUserFieldsEntity»
                    «IF !userFields.empty»
                        // initialise auto completion for user fields
                        «FOR userField : userFields»
                            «val realName = userField.name.formatForCode»
                            «app.vendorAndName»InitUserField('«realName»', 'get«name.formatForCodeCapital»«realName.formatForCodeCapital»Users');
                        «ENDFOR»
                    «ENDIF»
                    «relationHelper.initJs(it, app, true)»
    
                    var allFormFields = $('#{{ __formid }} input, #{{ __formid }} select, #{{ __formid }} textarea');
                    allFormFields.change(executeCustomValidationConstraints);

                    formButtons = $('#{{ __formid }} .form-buttons input');
                    $('#{{ __formid }}').submit(handleFormSubmit);

                    {% if mode != 'create' %}
                        triggerFormValidation();
                    {% endif %}

                    $('#{{ __formid }} label').tooltip();
                    «FOR field : getDerivedFields»«field.additionalInitScript»«ENDFOR»
                });
            })(jQuery);
        «ENDIF»
    '''

    def private newCoordinatesEventHandler(Entity it) '''
        function newCoordinatesEventHandler() {
            «IF application.targets('1.3.x')»
                var location = new mxn.LatLonPoint($F('latitude'), $F('longitude'));
            «ELSE»
                var location = new mxn.LatLonPoint($('#latitude').val(), $('#longitude').val());
            «ENDIF»
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

        var latlon = new mxn.LatLonPoint(«IF app.targets('1.3.x')»{{$«name.formatForDB».latitude|«app.appName.formatForDB»FormatGeoData}}, {{$«name.formatForDB».longitude|«app.appName.formatForDB»FormatGeoData}}«ELSE»{{ «name.formatForDB».latitude|«app.appName.formatForDB»_geoData }}, {{ «name.formatForDB».longitude|«app.appName.formatForDB»_geoData }}«ENDIF»);

        mapstraction.setMapType(mxn.Mapstraction.SATELLITE);
        mapstraction.setCenterAndZoom(latlon, 16);
        mapstraction.mousePosition('position');

        // add a marker
        marker = new mxn.Marker(latlon);
        mapstraction.addMarker(marker, true);

        // init event handler
        «IF app.targets('1.3.x')»
            $('latitude').observe('change', newCoordinatesEventHandler);
            $('longitude').observe('change', newCoordinatesEventHandler);
        «ELSE»
            $('#latitude').change(newCoordinatesEventHandler);
            $('#longitude').change(newCoordinatesEventHandler);

            $('#collapseMap').on('hidden.bs.collapse', function () {
                // redraw the map after it's panel has been opened (see also #340)
                mapstraction.resizeTo($('#mapContainer').width(), $('#mapContainer').height());
            })
        «ENDIF»

        mapstraction.click.addHandler(function(event_name, event_source, event_args) {
            var coords = event_args.location;
            «IF app.targets('1.3.x')»
                Form.Element.setValue('latitude', coords.lat.toFixed(7));
                Form.Element.setValue('longitude', coords.lng.toFixed(7));
            «ELSE»
                $('#latitude').val(coords.lat.toFixed(7));
                $('#longitude').val(coords.lng.toFixed(7));
            «ENDIF»
            newCoordinatesEventHandler();
        });

        «IF app.targets('1.3.x')»{{if $mode eq 'create'}}«ELSE»{% if mode == 'create' %}«ENDIF»
            // derive default coordinates from users position with html5 geolocation feature
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(setDefaultCoordinates, handlePositionError);
            }
        «IF app.targets('1.3.x')»{{/if}}«ELSE»{% endif %}«ENDIF»

        function setDefaultCoordinates(position) {
            «IF app.targets('1.3.x')»
                $('latitude').value = position.coords.latitude.toFixed(7);
                $('longitude').value = position.coords.longitude.toFixed(7);
            «ELSE»
                $('#latitude').val(position.coords.latitude.toFixed(7));
                $('#longitude').val(position.coords.longitude.toFixed(7));
            «ENDIF»
            newCoordinatesEventHandler();
        }

        function handlePositionError(evt) {
            «IF app.targets('1.3.x')»
                Zikula.UI.Alert(evt.message, Zikula.__('Error during geolocation', 'module_«app.appName.formatForDB»_js'));
            «ELSE»
                «app.vendorAndName»SimpleAlert($('#mapContainer'), Zikula.__('Error during geolocation', '«app.appName.formatForDB»_js'), evt.message, 'geoLocationAlert', 'danger');
            «ENDIF»
        }

        {{*
            Initialise geocoding functionality.
            In contrast to the map picker this one determines coordinates for a given address.
            To use this please customise the following method for assembling the address.
            Furthermore you will need a link or a button with id="linkGetCoordinates" which will
            be used by the script for adding a corresponding click event handler.

            var determineAddressForGeoCoding = function () {
                var address = {
                    «IF app.targets('1.3.x')»
                        address : $F('street') + ' ' + $F('houseNumber') + ' ' + $F('zipcode') + ' ' + $F('city') + ' ' + $F('country')
                    «ELSE»
                        address : $('#street').val() + ' ' + $('#houseNumber').val() + ' ' + $('#zipcode').val() + ' ' + $('#city').val() + ' ' + $('#country').val()
                    «ENDIF»
                };

                return address;
            }

            «app.vendorAndName»InitGeoCoding(determineAddressForGeoCoding);
        *}}
    '''

    def private fieldWrapper(DerivedField it, String groupSuffix, String idSuffix) '''
        «/*No input fields for foreign keys, relations are processed further down*/»
        «IF entity.getIncomingJoinRelations.filter[e|e.getSourceFields.head == name.formatForDB].empty»
            <div class="«IF entity.application.targets('1.3.x')»z-formrow«IF !visible» z-hide«ENDIF»«ELSE»form-group«IF !visible» hidden«ENDIF»«ENDIF»">
                «fieldHelper.formRow(it, groupSuffix, idSuffix)»
            </div>
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
        «entity.application.vendorAndName»InitUploadField('«name.formatForCode»');
    '''

    def private additionalInitScriptCalendar(AbstractDateField it) '''
        «IF !mandatory && nullable»
            «entity.application.vendorAndName»InitDateField('«name.formatForCode»');
        «ENDIF»
    '''

    def private entityInlineRedirectHandlerFile(Entity it, Application app, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + (if (app.targets('1.3.x')) name.formatForCode else name.formatForCodeCapital) + '/'
        val templateExtension = if (app.targets('1.3.x')) '.tpl' else '.html.twig'
        var fileName = 'inlineRedirectHandler' + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = 'inlineRedirectHandler.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, app.inlineRedirectHandlerImpl)
        }
    }

    def private inlineRedirectHandlerFile(Controller it, Application app, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + (if (app.targets('1.3.x')) formattedName else formattedName.toFirstUpper) + '/'
        val templateExtension = if (app.targets('1.3.x')) '.tpl' else '.html.twig'
        var fileName = 'inlineRedirectHandler' + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = 'inlineRedirectHandler.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, app.inlineRedirectHandlerImpl)
        }
    }

    def private inlineRedirectHandlerImpl(Application it) '''
        «IF targets('1.3.x')»
            {* purpose of this template: close an iframe from within this iframe *}
        «ELSE»
            {# purpose of this template: close an iframe from within this iframe #}
        «ENDIF»
        <!DOCTYPE html>
        <html xml:lang="«IF targets('1.3.x')»{lang}«ELSE»{{ lang() }}«ENDIF»" lang="«IF targets('1.3.x')»{lang}«ELSE»{{ lang() }}«ENDIF»" dir="«IF targets('1.3.x')»{langdirection}«ELSE»{{ langdirection() }}«ENDIF»">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                «IF targets('1.3.x')»
                    {$jcssConfig}
                    <script type="text/javascript" src="{$baseurl}javascript/ajax/proto_scriptaculous.combined.min.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/livepipe/livepipe.combined.min.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.UI.js"></script>
                    <script type="text/javascript" src="{$baseurl}«rootFolder»/«appName»/javascript/«appName»_editFunctions.js"></script>
                «ELSE»
                    {{ jcssConfig }}
                    <link rel="stylesheet" href="web/bootstrap/css/bootstrap.min.css" type="text/css" />
                    <link rel="stylesheet" href="web/bootstrap/css/bootstrap-theme.css" type="text/css" />
                    <script type="text/javascript" src="web/jquery/jquery.min.js"></script>
                    <script type="text/javascript" src="web/bootstrap/js/bootstrap.min.js"></script>
                    <script type="text/javascript" src="{{ pageGetVar('homepath') }}/javascript/helpers/Zikula.js"></script>«/* still required for Gettext */»
                    <script type="text/javascript" src="{{ pageGetVar('homepath') }}/«rootFolder»/«if (systemModule) name.formatForCode else appName»/«getAppJsPath»«appName».EditFunctions.js"></script>
                «ENDIF»
            </head>
            <body>
                <script type="text/javascript">
                /* <![CDATA[ */
                    // close window from parent document
                    «IF targets('1.3.x')»
                        document.observe('dom:loaded', function() {
                            «vendorAndName»CloseWindowFromInside('{{$idPrefix}}', {{if $commandName eq 'create'}}{{$itemId}}{{else}}0{{/if}});«/*value > 0 causes the auto completion being activated*/»
                        });
                    «ELSE»
                        ( function($) {
                            $(document).ready(function() {
                                «vendorAndName»CloseWindowFromInside('{{ idPrefix|e('js') }}', {% if commandName == 'create' %}{{ itemId }}{% else %}0{% endif %});«/*value > 0 causes the auto completion being activated*/»
                            });
                        })(jQuery);
                    «ENDIF»
                /* ]]> */
                </script>
            </body>
        </html>
    '''
}
