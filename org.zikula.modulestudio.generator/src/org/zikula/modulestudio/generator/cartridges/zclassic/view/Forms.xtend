package org.zikula.modulestudio.generator.cartridges.zclassic.view

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.Action
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.AjaxController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EditAction
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
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
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils
    @Inject extension ViewExtensions = new ViewExtensions

    SimpleFields fieldHelper = new SimpleFields
    Relations relationHelper = new Relations

    def generate(Application it, IFileSystemAccess fsa) {
        for (controller : getAllControllers) {
            if (!(controller instanceof AjaxController)) {
                for (action : controller.actions.filter(EditAction)) action.generate(it, fsa)
            }
        }
    }

    /**
     * Entry point for form templates for each action.
     */
    def private generate(Action it, Application app, IFileSystemAccess fsa) {
        for (entity : app.getAllEntities) entity.generate(app, it.controller, 'edit', fsa)
        controller.inlineRedirectHandlerFile(app, fsa)
    }

    /**
     * Entry point for form templates for each entity.
     */
    def private generate(Entity it, Application app, Controller controller, String actionName, IFileSystemAccess fsa) {
        val templatePath = editTemplateFile(controller, name, actionName)
        if (!app.shouldBeSkipped(templatePath)) {
            println('Generating ' + controller.formattedName + ' edit form templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templatePath, '''
                «formTemplateHeader(app, controller, actionName)»
                «formTemplateBody(app, controller, actionName, fsa)»
            ''')
        }
        relationHelper.generateInclusionTemplate(it, app, controller, fsa)
    }

    def private formTemplateHeader(Entity it, Application app, Controller controller, String actionName) '''
        {* purpose of this template: build the Form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» *}
        {include file='«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/header.tpl'}
        {pageaddvar name='javascript' value='modules/«app.appName»/«IF app.targets('1.3.5')»javascript/«ELSE»«app.getAppJsPath»«ENDIF»«app.appName»_editFunctions.js'}
        {pageaddvar name='javascript' value='modules/«app.appName»/«IF app.targets('1.3.5')»javascript/«ELSE»«app.getAppJsPath»«ENDIF»«app.appName»_validation.js'}

        {if $mode eq 'edit'}
            {gt text='Edit «name.formatForDisplay»' assign='templateTitle'}
            «controller.pageIcon(if (app.targets('1.3.5')) 'edit' else 'pencil-square-o')»
        {elseif $mode eq 'create'}
            {gt text='Create «name.formatForDisplay»' assign='templateTitle'}
            «controller.pageIcon(if (app.targets('1.3.5')) 'new' else 'plus')»
        {else}
            {gt text='Edit «name.formatForDisplay»' assign='templateTitle'}
            «controller.pageIcon(if (app.targets('1.3.5')) 'edit' else 'pencil-square-o')»
        {/if}
        <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-edit">
            {pagesetvar name='title' value=$templateTitle}
            «controller.templateHeader»
    '''

    def private pageIcon(Controller it, String iconName) {
        switch it {
            AdminController: '''
                        {assign var='adminPageIcon' value='«iconName»'}
                    '''
            default: ''
        }
    }

    def private templateHeader(Controller it) {
        switch it {
            AdminController: '''
                «IF container.application.targets('1.3.5')»
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
            '''
            default: '''
                <h2>{$templateTitle}</h2>
            '''
        }
    }

    def private formTemplateBody(Entity it, Application app, Controller controller, String actionName, IFileSystemAccess fsa) '''
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
                <div id="«app.appName.toFirstLower»Panel" class="z-panels">
                    <h3 id="z-panel-header-fields" class="z-panel-header z-panel-indicator «IF app.targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Fields'}</h3>
                    <div class="z-panel-content z-panel-active" style="overflow: visible">
                        «fieldDetails(app, controller)»
                    </div>
                    «new Section().generate(it, app, controller, fsa)»
                </div>
            «ELSE»
                «fieldDetails(app, controller)»
                «new Section().generate(it, app, controller, fsa)»
            «ENDIF»
            {/«app.appName.formatForDB»FormFrame}
        {/form}
        </div>
        {include file='«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/footer.tpl'}

        «formTemplateJS(app, controller, actionName)»
    '''

    def private fieldDetails(Entity it, Application app, Controller controller) '''
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
                            {«app.appName.formatForDB»ValidationError id='«geoFieldName»' class='validate-number'}
                        «IF !app.targets('1.3.5')»
                            </div>
                        «ENDIF»
                    </div>
                «ENDFOR»
            «ENDIF»
        </fieldset>
    '''

    def private slugField(Entity it, String groupSuffix, String idSuffix) '''
        «IF hasSluggableFields && slugUpdatable && !container.application.targets('1.3.5')»
            <div class="«IF container.application.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for=«templateIdWithSuffix('slug', idSuffix)» __text='Permalink'«/*IF slugUnique» mandatorysym='1'«ENDIF*/»«IF !container.application.targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !container.application.targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                    {formtextinput group=«templateIdWithSuffix(name.formatForDB, groupSuffix)» id=«templateIdWithSuffix('slug', idSuffix)» mandatory=false«/*slugUnique.displayBool*/» readOnly=false __title='You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»' textMode='singleline' maxLength=255 cssClass='«IF slugUnique»«/*required */»validate-unique«ENDIF»«IF !container.application.targets('1.3.5')»«IF slugUnique» «ENDIF»form-control«ENDIF»'}
                    <span class="«IF container.application.targets('1.3.5')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='You can input a custom permalink for the «name.formatForDisplay»«IF !slugUnique» or let this field free to create one automatically«ENDIF»'}</span>
                «IF slugUnique»
                    «/*{«container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix('slug', idSuffix)» class='required'}*/»
                    {«container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix('slug', idSuffix)» class='validate-unique'}
                «ENDIF»
                «IF !container.application.targets('1.3.5')»
                    </div>
                «ENDIF»
        </div>
        «ENDIF»
    '''

    def private formTemplateJS(Entity it, Application app, Controller controller, String actionName) '''
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

                    function newCoordinatesEventHandler() {
                        var location = new mxn.LatLonPoint($F('latitude'), $F('longitude'));
                        marker.hide();
                        mapstraction.removeMarker(marker);
                        marker = new mxn.Marker(location);
                        mapstraction.addMarker(marker,true);
                        mapstraction.setCenterAndZoom(location, 18);
                    }

                    Event.observe(window, 'load', function() {
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

                        $('latitude').observe('change', function() {
                            newCoordinatesEventHandler();
                        });

                        $('longitude').observe('change', function() {
                            newCoordinatesEventHandler();
                        });

                        mapstraction.click.addHandler(function(event_name, event_source, event_args){
                            var coords = event_args.location;
                            Form.Element.setValue('latitude', coords.lat.toFixed(7));
                            Form.Element.setValue('longitude', coords.lng.toFixed(7));
                            newCoordinatesEventHandler();
                        });

                        {{if $mode eq 'create'}}
                            // derive default coordinates from users position with html5 geolocation feature
                            if (navigator.geolocation) {
                                navigator.geolocation.getCurrentPosition(setDefaultCoordinates, handlePositionError);
                            }
                        {{/if}}

                        function setDefaultCoordinates(position) {
                            $('latitude').value = position.coords.latitude.toFixed(7);
                            $('longitude').value = position.coords.longitude.toFixed(7);
                            newCoordinatesEventHandler();
                        }

                        function handlePositionError(evt) {
                            Zikula.UI.Alert(evt.message, Zikula.__('Error during geolocation', 'module_«app.appName.formatForDB»_js'));
                        }
                        {{*
                            Initialise geocoding functionality.
                            In contrast to the map picker this one determines coordinates for a given address.
                            To use this please customise the form field names inside the function to your needs.
                            You can find it in «app.getAppJsPath»«app.appName»_editFunctions.js
                            Furthermore you will need a link or a button with id="linkGetCoordinates" which will
                            be used by the script for adding a corresponding click event handler.
                            «app.prefix»InitGeoCoding();
                        *}}
                    });
                /* ]]> */
                </script>
            {/pageaddvarblock}
        «ENDIF»

        <script type="text/javascript">
        /* <![CDATA[ */
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
                        btn.addClassName('«IF app.targets('1.3.5')»z-hide«ELSE»hidden«ENDIF»');
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
                        «app.prefix»InitUserField('«realName»', 'get«name.formatForCodeCapital»«realName.formatForCodeCapital»Users');
                    «ENDFOR»
                «ENDIF»
                «relationHelper.initJs(it, app, true)»

                «container.application.prefix»AddCommonValidationRules('«name.formatForCode»', '{{if $mode ne 'create'}}«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$«name.formatForDB».«pkField.name.formatForCode»}}«ENDFOR»{{/if}}');
                {{* observe validation on button events instead of form submit to exclude the cancel command *}}
                formValidator = new Validation('{{$__formid}}', {onSubmit: false, immediate: true, focusOnError: false});
                {{if $mode ne 'create'}}
                    var result = formValidator.validate();
                {{/if}}

                formButtons = $('{{$__formid}}').select('div.«IF app.targets('1.3.5')»z-formbuttons«ELSE»form-buttons«ENDIF» input');

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

        /* ]]> */
        </script>
    '''

    def private fieldWrapper(DerivedField it, String groupSuffix, String idSuffix) '''
        «/*No input fields for foreign keys, relations are processed further down*/»
        «IF entity.getIncomingJoinRelations.filter[e|e.getSourceFields.head == name.formatForDB].empty»
            <div class="«IF entity.container.application.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
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
        «entity.container.application.prefix»InitUploadField('«name.formatForCode»');
    '''

    def private additionalInitScriptCalendar(AbstractDateField it) '''
        «IF !mandatory && nullable»
            «entity.container.application.prefix»InitDateField('«name.formatForCode»');
        «ENDIF»
    '''

    def private inlineRedirectHandlerFile(Controller it, Application app, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + (if (app.targets('1.3.5')) formattedName else formattedName.toFirstUpper) + '/'
        if (!app.shouldBeSkipped(templatePath + 'inlineRedirectHandler.tpl')) {
            fsa.generateFile(templatePath + 'inlineRedirectHandler.tpl', inlineRedirectHandlerImpl(app))
        }
    }

    def private inlineRedirectHandlerImpl(Controller it, Application app) '''
        {* purpose of this template: close an iframe from within this iframe *}
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                {$jcssConfig}
                <script type="text/javascript" src="{$baseurl}javascript/ajax/proto_scriptaculous.combined.min.js"></script>
                <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.js"></script>
                <script type="text/javascript" src="{$baseurl}javascript/livepipe/livepipe.combined.min.js"></script>
                <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.UI.js"></script>
                <script type="text/javascript" src="{$baseurl}modules/«app.appName»/«IF app.targets('1.3.5')»javascript/«ELSE»«app.getAppJsPath»«ENDIF»«app.appName»_editFunctions.js"></script>
            </head>
            <body>
                <script type="text/javascript">
                /* <![CDATA[ */
                    // close window from parent document
                    document.observe('dom:loaded', function() {
                        «app.prefix»CloseWindowFromInside('{{$idPrefix}}', {{if $commandName eq 'create'}}{{$itemId}}{{else}}0{{/if}});«/*value > 0 causes the auto completion being activated*/»
                    });
                /* ]]> */
                </script>
            </body>
        </html>
    '''

    /*
        A 'zparameters' parameter was added as a direct way to assign the values of
        the form plugins attributes. For instance:
        $attributes = {class:«IF app.targets('1.3.5')»z-btred«ELSE»btn btn-danger; confirmMessage:Are you sure?}
        {formbutton commandName='delete' __text='Delete' zparameters=$attributes}
    */
}
