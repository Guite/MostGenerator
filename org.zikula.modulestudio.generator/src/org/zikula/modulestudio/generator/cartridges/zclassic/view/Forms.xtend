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

    def private formTemplateHeader(Entity it, Application app, String actionName) '''
        {* purpose of this template: build the Form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        «IF app.targets('1.3.5')»
            {include file="`$lct`/header.tpl"}
        «ELSE»
            {assign var='lctUc' value=$lct|ucfirst}
            {include file="`$lctUc`/header.tpl"}
        «ENDIF»
        {pageaddvar name='javascript' value='«app.rootFolder»/«app.appName»/«IF app.targets('1.3.5')»javascript/«ELSE»«app.getAppJsPath»«ENDIF»«app.appName»«IF app.targets('1.3.5')»_e«ELSE».E«ENDIF»ditFunctions.js'}
        {pageaddvar name='javascript' value='«app.rootFolder»/«app.appName»/«IF app.targets('1.3.5')»javascript/«ELSE»«app.getAppJsPath»«ENDIF»«app.appName»«IF app.targets('1.3.5')»_v«ELSE».V«ENDIF»alidation.js'}
        «IF !app.targets('1.3.5') && (hasUserFieldsEntity || !getOutgoingJoinRelations.empty || !getIncomingJoinRelations.empty)»
            {pageaddvar name='javascript' value='web/bootstrap-3-typeahead/bootstrap3-typeahead.min.js'}
        «ENDIF»

        {if $mode eq 'edit'}
            {gt text='Edit «name.formatForDisplay»' assign='templateTitle'}
            «pageIcon(if (app.targets('1.3.5')) 'edit' else 'pencil-square-o')»
        {elseif $mode eq 'create'}
            {gt text='Create «name.formatForDisplay»' assign='templateTitle'}
            «pageIcon(if (app.targets('1.3.5')) 'new' else 'plus')»
        {else}
            {gt text='Edit «name.formatForDisplay»' assign='templateTitle'}
            «pageIcon(if (app.targets('1.3.5')) 'edit' else 'pencil-square-o')»
        {/if}
        <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-edit">
            {pagesetvar name='title' value=$templateTitle}
            «templateHeader»
    '''

    def private pageIcon(Entity it, String iconName) '''
        {if $lct eq 'admin'}
            {assign var='adminPageIcon' value='«iconName»'}
        {/if}
    '''

    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            «IF application.targets('1.3.5')»
                <div class="z-admin-content-pagetitle">
                    {icon type=$adminPageIcon size='small' alt=$templateTitle}
                    <h3>{$templateTitle}</h3>
                </div>
            «ELSE»
                <h3>
                    <span class="icon icon-{$adminPageIcon}"></span>
                    {$templateTitle}
                </h3>
            «ENDIF»
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''

    def private formTemplateBody(Entity it, Application app, String actionName, IFileSystemAccess fsa) '''
        {form «IF hasUploadFieldsEntity»enctype='multipart/form-data' «ENDIF»cssClass='«IF app.targets('1.3.5')»z-form«ELSE»form-horizontal«ENDIF»'«IF !app.targets('1.3.5')» role='form'«ENDIF»}
            {* add validation summary and a <div> element for styling the form *}
            {«app.appName.formatForDB»FormFrame}
            «IF !getEditableFields.empty»
                «IF (getEditableFields.head) instanceof ListField && !(getEditableFields.head as ListField).useChecks»
                    {formsetinitialfocus inputId='«(getEditableFields.head).name.formatForCode»' doSelect=true}
                «ELSE»
                    {formsetinitialfocus inputId='«(getEditableFields.head).name.formatForCode»'}
                «ENDIF»
            «ENDIF»

            «IF useGroupingPanels('edit')»
                «IF app.targets('1.3.5')»
                    <div id="«app.appName.toFirstLower»Panel" class="z-panels">
                        <h3 id="z-panel-header-fields" class="z-panel-header z-panel-indicator «IF app.targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Fields'}</h3>
                        <div class="z-panel-content z-panel-active" style="overflow: visible">
                            «fieldDetails(app)»
                        </div>
                        «new Section().generate(it, app, fsa)»
                    </div>
                «ELSE»
                    <div class="panel-group" id="accordion">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseFields">{gt text='Fields'}</a></h3>
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
        «IF app.targets('1.3.5')»
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {include file="`$lctUc`/footer.tpl"}
        «ENDIF»

        «formTemplateJS(app, actionName)»
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
            {formvolatile}
                {assign var='useOnlyCurrentLocale' value=true}
                {if $modvars.ZConfig.multilingual}
                    {if $supportedLocales ne '' && is_array($supportedLocales) && count($supportedLocales) > 1}
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
        «ENDIF»
    '''

    def private translatableFieldSet(Entity it, String groupSuffix, String idSuffix) '''
        <fieldset>
            <legend>{$locale|getlanguagename|safehtml}</legend>
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
                    <div class="«IF app.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                        {formlabel for='«geoFieldName»' __text='«geoFieldName.toFirstUpper»'«IF !app.targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                        «IF !app.targets('1.3.5')»
                            <div class="col-lg-9">
                        «ENDIF»
                            {«app.appName.formatForDB»GeoInput group='«name.formatForDB»' id='«geoFieldName»' mandatory=false __title='Enter the «geoFieldName» of the «name.formatForDisplay»' cssClass='validate-number«IF !app.targets('1.3.5')» form-control«ENDIF»'}
                            «IF app.targets('1.3.5')»
                                {«app.appName.formatForDB»ValidationError id='«geoFieldName»' class='validate-number'}
                            «ENDIF»
                        «IF !app.targets('1.3.5')»
                            </div>
                        «ENDIF»
                    </div>
                «ENDFOR»
            «ENDIF»
        </fieldset>
    '''

    def private slugField(Entity it, String groupSuffix, String idSuffix) '''
        «IF hasSluggableFields && slugUpdatable && !application.targets('1.3.5')»
            <div class="«IF application.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for=«templateIdWithSuffix('slug', idSuffix)» __text='Permalink'«/*IF slugUnique» mandatorysym='1'«ENDIF*/»«IF !application.targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !application.targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group=«templateIdWithSuffix(name.formatForDB, groupSuffix)» id=«templateIdWithSuffix('slug', idSuffix)» mandatory=false«/*slugUnique.displayBool*/» readOnly=false __title='You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»' textMode='singleline' maxLength=255 cssClass='«IF slugUnique»«/*required */»validate-unique«ENDIF»«IF !application.targets('1.3.5')»«IF slugUnique» «ENDIF»form-control«ENDIF»'}
                    <span class="«IF application.targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»'}</span>
                «IF slugUnique && application.targets('1.3.5')»
                    «/*{«application.appName.formatForDB»ValidationError id=«templateIdWithSuffix('slug', idSuffix)» class='required'}*/»
                    {«application.appName.formatForDB»ValidationError id=«templateIdWithSuffix('slug', idSuffix)» class='validate-unique'}
                «ENDIF»
                «IF !application.targets('1.3.5')»
                    </div>
                «ENDIF»
        </div>
        «ENDIF»
    '''

    def private formTemplateJS(Entity it, Application app, String actionName) '''
        «IF app.targets('1.3.5')»
            {icon type='edit' size='extrasmall' assign='editImageArray'}
            {icon type='delete' size='extrasmall' assign='removeImageArray'}
        «ELSE»
            {assign var='editImage' value='<span class="fa fa-pencil-square-o"></span>'}
            {assign var='deleteImage' value='<span class="fa fa-trash-o"></span>'}
        «ENDIF»

        «IF geographical»
            {pageaddvarblock name='header'}
                <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
                <script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                <script type="text/javascript">
                /* <![CDATA[ */

                    var mapstraction;
                    var marker;

                    «IF app.targets('1.3.5')»
                        «newCoordinatesEventHandler»

                        Event.observe(window, 'load', function() {
                            «initGeographical(app)»
                        });
                    «ELSE»
                        ( function($) {
                            $(document).ready(function() {
                                «newCoordinatesEventHandler»

                                «initGeographical(app)»
                            });
                        })(jQuery);
                    «ENDIF»
                /* ]]> */
                </script>
            {/pageaddvarblock}
        «ENDIF»

        <script type="text/javascript">
        /* <![CDATA[ */
            «jsInitImpl(app)»
        /* ]]> */
        </script>
    '''

    def private jsInitImpl(Entity it, Application app) '''
        «IF app.targets('1.3.5')»
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

            function handleFormButton (event) {
                «application.vendorAndName»PerformCustomValidationRules('«name.formatForCode»', '{{if $mode ne 'create'}}«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$«name.formatForDB».«pkField.name.formatForCode»}}«ENDFOR»{{/if}}');
                var result = document.getElementById('{{$__formid}}').checkValidity();
                if (!result) {
                    // validation error, abort form submit
                    event.stopPropagation();
                } else {
                    // hide form buttons to prevent double submits by accident
                    formButtons.each(function (btn) {
                        btn.addClass('hidden');
                    });
                }

                return result;
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
    
                    {{* observe validation on button events instead of form submit to exclude the cancel command *}}
                    {{if $mode ne 'create'}}
                        if (!document.getElementById('{{$__formid}}').checkValidity()) {
                            document.getElementById('{{$__formid}}').submit();
                        }
                    {{/if}}
    
                    formButtons = $('#{{$__formid}}').find('div.form-buttons input');
    
                    formButtons.each(function (elem) {
                        if (elem.attr('id') != 'btnCancel') {
                            elem.click(handleFormButton);
                        }
                    });

                    $('.«app.appName.toLowerCase»-form-tooltips').tooltip();
                    «FOR field : getDerivedFields»«field.additionalInitScript»«ENDFOR»
                });
            })(jQuery);
        «ENDIF»
    '''

    def private newCoordinatesEventHandler(Entity it) '''
        function newCoordinatesEventHandler() {
            «IF application.targets('1.3.5')»
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

        var latlon = new mxn.LatLonPoint({{$«name.formatForDB».latitude|«app.appName.formatForDB»FormatGeoData}}, {{$«name.formatForDB».longitude|«app.appName.formatForDB»FormatGeoData}});

        mapstraction.setMapType(mxn.Mapstraction.SATELLITE);
        mapstraction.setCenterAndZoom(latlon, 16);
        mapstraction.mousePosition('position');

        // add a marker
        marker = new mxn.Marker(latlon);
        mapstraction.addMarker(marker, true);

        // init event handler
        «IF application.targets('1.3.5')»
            $('latitude').observe('change', newCoordinatesEventHandler);
            $('longitude').observe('change', newCoordinatesEventHandler);
        «ELSE»
            $('#latitude').change(newCoordinatesEventHandler);
            $('#longitude').change(newCoordinatesEventHandler);
        «ENDIF»
        «IF !application.targets('1.3.5')»

            $('#collapseMap').on('hidden.bs.collapse', function () {
                // redraw the map after it's panel has been opened (see also #340)
                mapstraction.resizeTo($('#mapContainer').width(), $('#mapContainer').height());
            })
        «ENDIF»

        mapstraction.click.addHandler(function(event_name, event_source, event_args) {
            var coords = event_args.location;
            «IF application.targets('1.3.5')»
                Form.Element.setValue('latitude', coords.lat.toFixed(7));
                Form.Element.setValue('longitude', coords.lng.toFixed(7));
            «ELSE»
                $('#latitude').val(coords.lat.toFixed(7));
                $('#longitude').val(coords.lng.toFixed(7));
            «ENDIF»
            newCoordinatesEventHandler();
        });

        {{if $mode eq 'create'}}
            // derive default coordinates from users position with html5 geolocation feature
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(setDefaultCoordinates, handlePositionError);
            }
        {{/if}}

        function setDefaultCoordinates(position) {
            «IF app.targets('1.3.5')»
                $('latitude').value = position.coords.latitude.toFixed(7);
                $('longitude').value = position.coords.longitude.toFixed(7);
            «ELSE»
                $('#latitude').val(position.coords.latitude.toFixed(7));
                $('#longitude').val(position.coords.longitude.toFixed(7));
            «ENDIF»
            newCoordinatesEventHandler();
        }

        function handlePositionError(evt) {
            «IF app.targets('1.3.5')»
                Zikula.UI.Alert(evt.message, Zikula.__('Error during geolocation', 'module_«app.appName.formatForDB»_js'));
            «ELSE»
                «app.vendorAndName»SimpleAlert($('#mapContainer'), Zikula.__('Error during geolocation', 'module_«app.appName.formatForDB»_js'), evt.message, 'geoLocationAlert', 'danger');
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
                    «IF app.targets('1.3.5')»
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
            <div class="«IF entity.application.targets('1.3.5')»z-formrow«IF !visible» z-hide«ENDIF»«ELSE»form-group«IF !visible» hidden«ENDIF»«ENDIF»">
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
        val templatePath = app.getViewPath + (if (app.targets('1.3.5')) name.formatForCode else name.formatForCodeCapital) + '/'
        var fileName = 'inlineRedirectHandler.tpl'
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = 'inlineRedirectHandler.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, app.inlineRedirectHandlerImpl)
        }
    }

    def private inlineRedirectHandlerFile(Controller it, Application app, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + (if (app.targets('1.3.5')) formattedName else formattedName.toFirstUpper) + '/'
        var fileName = 'inlineRedirectHandler.tpl'
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = 'inlineRedirectHandler.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, app.inlineRedirectHandlerImpl)
        }
    }

    def private inlineRedirectHandlerImpl(Application it) '''
        {* purpose of this template: close an iframe from within this iframe *}
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                {$jcssConfig}
                «IF targets('1.3.5')»
                    <script type="text/javascript" src="{$baseurl}javascript/ajax/proto_scriptaculous.combined.min.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/livepipe/livepipe.combined.min.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.UI.js"></script>
                «ELSE»
                    <link rel="stylesheet" href="web/bootstrap/css/bootstrap.min.css" type="text/css" />
                    <link rel="stylesheet" href="web/bootstrap/css/bootstrap-theme.css" type="text/css" />
                    <script type="text/javascript" src="web/jquery/jquery.min.js"></script>
                    <script type="text/javascript" src="web/bootstrap/js/bootstrap.min.js"></script>
                    <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.js"></script>«/* still required for Gettext */»
                «ENDIF»
                <script type="text/javascript" src="{$baseurl}«rootFolder»/«appName»/«IF targets('1.3.5')»javascript/«ELSE»«getAppJsPath»«ENDIF»«appName»«IF targets('1.3.5')»_e«ELSE».E«ENDIF»ditFunctions.js"></script>
            </head>
            <body>
                <script type="text/javascript">
                /* <![CDATA[ */
                    // close window from parent document
                    «IF targets('1.3.5')»
                        document.observe('dom:loaded', function() {
                            «vendorAndName»CloseWindowFromInside('{{$idPrefix}}', {{if $commandName eq 'create'}}{{$itemId}}{{else}}0{{/if}});«/*value > 0 causes the auto completion being activated*/»
                        });
                    «ELSE»
                        ( function($) {
                            $(document).ready(function() {
                                «vendorAndName»CloseWindowFromInside('{{$idPrefix}}', {{if $commandName eq 'create'}}{{$itemId}}{{else}}0{{/if}});«/*value > 0 causes the auto completion being activated*/»
                            });
                        })(jQuery);
                    «ENDIF»
                /* ]]> */
                </script>
            </body>
        </html>
    '''
}
