package org.zikula.modulestudio.generator.cartridges.zclassic.view

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.Action
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EditAction
import de.guite.modulestudio.metamodel.modulestudio.Entity
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
import de.guite.modulestudio.metamodel.modulestudio.AdminController

class Forms {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    SimpleFields fieldHelper = new SimpleFields()
    Relations relationHelper = new Relations()

    def generate(Application it, IFileSystemAccess fsa) {
        val editActions = getAllControllers.map(e|e.actions).filter(typeof(EditAction))
        if (!editActions.isEmpty)
            for (action : editActions) action.generate(it, fsa)
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
        println('Generating ' + controller.formattedName + ' edit form templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(editTemplateFile(controller, name, actionName), {
            formTemplateHeader(app, controller, actionName)
            formTemplateBody(app, controller, actionName, fsa)
        })
        for (relation : getBidirectionalIncomingJoinRelations) relationHelper.generate(relation, app, controller, false, true, fsa)
        for (relation : getOutgoingJoinRelations) relationHelper.generate(relation, app, controller, false, false, fsa)
    }

    def private formTemplateHeader(Entity it, Application app, Controller controller, String actionName) '''
        {* purpose of this template: build the Form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» *}
        {include file='«controller.formattedName»/header.tpl'}
        {pageaddvar name='javascript' value='modules/«app.appName»/javascript/«app.appName»_editFunctions.js'}
        {pageaddvar name='javascript' value='modules/«app.appName»/javascript/«app.appName»_validation.js'}

        {if $mode eq 'edit'}
            {gt text='Edit «name.formatForDisplay»' assign='templateTitle'}
            «controller.pageIcon('edit')»
        {elseif $mode eq 'create'}
            {gt text='Create «name.formatForDisplay»' assign='templateTitle'}
            «controller.pageIcon('new')»
        {else}
            {gt text='Edit «name.formatForDisplay»' assign='templateTitle'}
            «controller.pageIcon('edit')»
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
                <div class="z-admin-content-pagetitle">
                    {icon type=$adminPageIcon size='small' alt=$templateTitle}
                    <h3>{$templateTitle}</h3>
                </div>
            '''
            default: '''
                <div class="z-frontendcontainer">
                    <h2>{$templateTitle}</h2>
            '''
        }
    }

    def private templateFooter(Controller it) {
        switch it {
            AdminController: ''
            default: '''
                </div>
            '''
        }
    }

    def private formTemplateBody(Entity it, Application app, Controller controller, String actionName, IFileSystemAccess fsa) '''
        {form «IF hasUploadFieldsEntity»enctype='multipart/form-data' «ENDIF»cssClass='z-form'}
            {* add validation summary and a <div> element for styling the form *}
            {«app.appName.formatForDB»FormFrame}
«/*            {*formvalidationsummary*}
            {*formerrormessage id='error'*}*/»
            «IF !getEditableFields.isEmpty»
                {formsetinitialfocus inputId='«(getEditableFields.head).name.formatForCode»'}
«/*            {formsetinitialfocus inputId='PluginId' doSelect=true} <-- for dropdown lists (performs input.select())*/»
            «ENDIF»

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
            «IF !hasTranslatableFields
              || (hasTranslatableFields && !getEditableNonTranslatableFields.isEmpty || !hasTranslatableSlug)
              || geographical»
                <fieldset>
                    <legend>{gt text='«IF hasTranslatableFields»Further properties«ELSE»Content«ENDIF»'}</legend>
                    «IF hasTranslatableFields»
                        «FOR field : getEditableNonTranslatableFields»«field.fieldWrapper('', '')»«ENDFOR»
                    «ELSE»
                        «FOR field : getEditableFields»«field.fieldWrapper('', '')»«ENDFOR»
                    «ENDIF»
                    «IF !hasTranslatableFields || !hasTranslatableSlug»
                        «slugField('', '')»
                    «ENDIF»
                    «IF geographical»
                        «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                            <div class="z-formrow">
                                {formlabel for='«geoFieldName»' __text='«geoFieldName.toFirstUpper»'}
                                {«app.appName.formatForDB»GeoInput group='«name.formatForDB»' id='«geoFieldName»' mandatory=false __title='Enter the «geoFieldName» of the «name.formatForDisplay»' cssClass='validate-number'}
                                {«app.appName.formatForDB»ValidationError id='«geoFieldName»' class='validate-number'}
                            </div>
                        «ENDFOR»
                    «ENDIF»
                </fieldset>
            «ENDIF»
    
                «IF geographical»
                    <fieldset>
                        <legend>{gt text='Map'}</legend>
                        <div id="mapContainer" class="«app.appName.formatForDB»MapContainer">
                        </div>
                    </fieldset>
                «ENDIF»

                «new Section().generate(it, app, controller, fsa)»
                {/«app.appName.formatForDB»FormFrame}
            {/form}

            «controller.templateFooter»
        </div>
        {include file='«controller.formattedName»/footer.tpl'}

        «formTemplateJS(app, controller, actionName)»
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

    def private slugField(Entity it, String groupSuffix, String idSuffix) '''
        «/*no slug input element yet, see https://github.com/l3pp4rd/DoctrineExtensions/issues/140
        «IF hasSluggableFields && slugUpdatable»
            <div class="z-formrow">
                {formlabel for=«templateIdWithSuffix('slug', idSuffix)» __text='Permalink'«IF slugUnique» mandatorysym='1'«ENDIF»}
                {formtextinput group=«templateIdWithSuffix(name.formatForDB, groupSuffix)» id=«templateIdWithSuffix('slug', idSuffix)» mandatory=«slugUnique.displayBool«ENDIF» readOnly=false __title='You can input a custom permalink for the «name.formatForDisplay)»«IF !slugUnique» or let this field free to create one automatically«ENDIF»' textMode='singleline' maxLength=255«IF slugUnique» cssClass='required validate-unique'«ENDIF»}
            «IF slugUnique»
                {«container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix('slug', idSuffix)» class='required'}
                {«container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix('slug', idSuffix)» class='validate-unique'}
            «ENDIF»
        </div>
        «ENDIF»
        */»
    '''

    def private formTemplateJS(Entity it, Application app, Controller controller, String actionName) '''
        {icon type='edit' size='extrasmall' assign='editImageArray'}
        {icon type='delete' size='extrasmall' assign='deleteImageArray'}

        «IF geographical»
            {pageaddvarblock name='header'}
                <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
                <script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                <script type="text/javascript" charset="utf-8">
                /* <![CDATA[ */

                    var mapstraction;
                    var marker;
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
                        mapstraction.addMarker(marker,true);

                        $('latitude').observe('change', function() {
                            newCoordinatesEventHandler();
                        });

                        $('longitude').observe('change', function() {
                            newCoordinatesEventHandler();
                        });

                        function newCoordinatesEventHandler() {
                            var location = new mxn.LatLonPoint($F('latitude'), $F('longitude'));
                            marker.hide();
                            mapstraction.removeMarker(marker);
                            marker = new mxn.Marker(location);
                            mapstraction.addMarker(marker,true);
                            mapstraction.setCenterAndZoom(location, 18);
                        }

                        mapstraction.click.addHandler(function(event_name, event_source, event_args){
                            var coords = event_args.location;
                            Form.Element.setValue('latitude', coords.lat.toFixed(4));
                            Form.Element.setValue('longitude', coords.lng.toFixed(4));
                            newCoordinatesEventHandler();
                        });

                        {{if $mode eq 'create'}}
                            // derive default coordinates from users position with html5 geolocation feature
                            if (navigator.geolocation) {
                                navigator.geolocation.getCurrentPosition(setDefaultCoordinates, handlePositionError);
                            }
                        {{/if}}

                        function setDefaultCoordinates(position) {
                            $('latitude').value = position.coords.latitude;
                            $('longitude').value = position.coords.longitude;
                            newCoordinatesEventHandler();
                        }

                        function handlePositionError(evt) {
                            Zikula.UI.Alert(evt.message, Zikula.__('Error during geolocation', 'module_emotion'));
                        }
                    });
                /* ]]> */
                </script>
            {/pageaddvarblock}
        «ENDIF»

        <script type="text/javascript" charset="utf-8">
        /* <![CDATA[ */
            var editImage = '<img src="{{$editImageArray.src}}" width="16" height="16" alt="" />';
            var removeImage = '<img src="{{$deleteImageArray.src}}" width="16" height="16" alt="" />';
            «val incomingJoins = getBidirectionalIncomingJoinRelations»
            «val outgoingJoins = outgoingJoinRelations»
            «IF !incomingJoins.isEmpty || !outgoingJoins.isEmpty»
                var relationHandler = new Array();
                «FOR relation : incomingJoins»«relationHelper.initJs(relation, app, it, true, false)»«ENDFOR»
                «FOR relation : outgoingJoins»«relationHelper.initJs(relation, app, it, false, false)»«ENDFOR»
            «ENDIF»

            document.observe('dom:loaded', function() {
                «val userFields = getUserFieldsEntity»
                «IF !userFields.isEmpty»
                    // initialise auto completion for user fields
                    «FOR userField : userFields»
                        «val realName = userField.name.formatForCode»
                        {{if isset($«realName») && $«realName» gt 0}}
                            $('«realName»Selector').value = '{{usergetvar name='uname' uid=$«realName»}}';
                        {{/if}}
                        «app.prefix»InitUserField('«realName»', 'get«name.formatForCodeCapital»«realName.formatForCodeCapital»Users');
                    «ENDFOR»
                «ENDIF»
                «FOR relation : incomingJoins»«relationHelper.initJs(relation, app, it, true, true)»«ENDFOR»
                «FOR relation : outgoingJoins»«relationHelper.initJs(relation, app, it, false, true)»«ENDFOR»

                «container.application.prefix»AddCommonValidationRules('«name.formatForCode»', '{{if $mode eq 'create'}}{{else}}«FOR pkField : getPrimaryKeyFields»{{$«name.formatForDB».«pkField.name.formatForCode»}}«ENDFOR»{{/if}}');

                // observe button events instead of form submit
                var valid = new Validation('{{$__formid}}', {onSubmit: false, immediate: true, focusOnError: false});
                {{if $mode ne 'create'}}
                    var result = valid.validate();
                {{/if}}

                $('{{if $mode eq 'create'}}btnCreate{{else}}btnUpdate{{/if}}').observe('click', function(event) {
                    var result = valid.validate();
                    if (!result) {
                        // validation error, abort form submit
                        Event.stop(event);
                    } else {
                        // hide form buttons to prevent double submits by accident
                        $$('div.z-formbuttons input').each(function(btn) {
                            btn.hide();
                        });
                    }
                    return result;
                });

                Zikula.UI.Tooltips($$('.«app.appName.formatForDB»FormTooltips'));
                «FOR field : getDerivedFields»«field.additionalInitScript»«ENDFOR»
            });

        /* ]]> */
        </script>
    '''

    def private fieldWrapper(DerivedField it, String groupSuffix, String idSuffix) '''
        «/*No input fields for foreign keys, relations are processed further down*/»
        «IF entity.getIncomingJoinRelations.filter(e|e.getSourceFields.head == name.formatForDB).isEmpty»
            <div class="z-formrow">
                «fieldHelper.formRow(it, groupSuffix, idSuffix)»
            </div>
        «ENDIF»
    '''

    def private additionalInitScript(DerivedField it) {
        switch it {
            DatetimeField: additionalInitScriptCalendar
            DateField: additionalInitScriptCalendar
        }
    }

    def private additionalInitScriptCalendar(AbstractDateField it) '''
        «IF !mandatory»
            $('reset«name.formatForCodeCapital»Val').observe('click', function() { $('«name.formatForCode»').value = ''; $('«name.formatForCode»cal').update(Zikula.__('No date set.', 'module_«entity.container.application.appName»')); }).show();
        «ENDIF»
    '''

    def private inlineRedirectHandlerFile(Controller it, Application app, IFileSystemAccess fsa) {
        fsa.generateFile(app.appName.getAppSourcePath + 'templates/' + formattedName + '/inlineRedirectHandler.tpl', inlineRedirectHandlerImpl(app))
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
                <script type="text/javascript" src="{$baseurl}modules/«app.appName»/javascript/«app.appName»_editFunctions.js"></script>
            </head>
            <body>
                <script type="text/javascript" charset="utf-8">
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
        $attributes = {class:z-bt-ok; confirmMessage:Are you sure?}
        {formbutton commandName='delete' __text='Delete' zparameters=$attributes}
    */
}
