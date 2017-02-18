package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UploadField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Section
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

    Relations relationHelper = new Relations

    def generate(Application it, IFileSystemAccess fsa) {
        for (entity : getAllEntities.filter[hasEditAction]) {
            entity.generate(it, 'edit', fsa)
            if (needsAutoCompletion) {
                entity.entityInlineRedirectHandlerFile(it, fsa)
            }
        }
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
        {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : (routeArea == 'admin' ? 'adminBase' : 'base') %}
        {% extends '«application.appName»::' ~ baseTemplate ~ '.html.twig' %}

        {% block header %}
            {{ parent() }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».Validation.js', 98)) }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».EditFunctions.js', 99)) }}
            «IF (hasUserFieldsEntity || standardFields || !getOutgoingJoinRelations.empty || !getIncomingJoinRelations.empty)»
                {{ pageAddAsset('javascript', asset('typeahead/typeahead.bundle.min.js')) }}
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
        {{ form_start(form, {attr: {id: '«name.formatForCode»EditForm', class: '«app.vendorAndName.toLowerCase»-edit-form'}}) }}
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
            {% if getModVar('ZConfig', 'multilingual') and supportedLanguages is iterable and supportedLanguages|length > 1 %}
                <ul class="{{ form.vars.id|lower }}-translation-locales nav nav-tabs">
                    {% for language in supportedLanguages %}
                        <li{% if language == app.request.locale %} class="active"{% endif %}>
                            <a href="#" data-toggle="tab" data-target=".{{ form.vars.id|lower }}-translations-fields-{{ language }}">
                                {% if not form.vars.valid %}
                                    <span class="label label-danger"><i class="fa fa-warning"></i><span class="sr-only">{{ __('Errors') }}</span></span>
                                {% endif %}
                                {# TODO % set hasRequiredFields = language == app.request.locale or translationsFields.vars.required % #}
                                {% set hasRequiredFields = language == app.request.locale %}
                                {% if hasRequiredFields %}<span class="required">{% endif %}{{ language|languageName|safeHtml }}{% if hasRequiredFields %}</span>{% endif %}
                            </a>
                        </li>
                    {% endfor %}
                </ul>
                <div class="{{ form.vars.id|lower }}-translation-fields tab-content">
                    {% for language in supportedLanguages %}
                        <div class="{{ form.vars.id|lower }}-translations-fields-{{ language }} tab-pane fade{% if language == app.request.locale %} active in{% endif %}">
                            <fieldset>
                                {% if language == app.request.locale %}
                                    «translatableFieldSet('', '')»
                                {% else %}
                                    «translatableFieldSet('', 'language')»
                                {% endif %}
                            </fieldset>
                        </div>
                    {% endfor %}
                </div>
            {% else %}
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
        «IF hasSluggableFields && slugUpdatable && application.supportsSlugInputFields»
            {{ form_row(form.«IF groupSuffix != ''»«groupSuffix».«ENDIF»slug«idSuffix») }}
        «ENDIF»
    '''

    def private formTemplateJS(Entity it, Application app, String actionName) '''
        {% set editImage = '<span class="fa fa-pencil-square-o"></span>' %}
        {% set deleteImage = '<span class="fa fa-trash-o"></span>' %}
        «IF geographical»

            {% set geoScripts %}
                {% set useGeoLocation = getModVar('«app.appName»', 'enable«name.formatForCodeCapital»GeoLocation', false) %}
                {{ pageAddAsset('javascript', 'https://maps.google.com/maps/api/js?key=' ~ getModVar('«app.appName»', 'googleMapsApiKey', '') ~ '&language=' ~ app.request.locale ~ '&sensor=false') }}
                {{ pageAddAsset('javascript', app.request.basePath ~ '/plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)') }}
                {% if useGeoLocation == true %}
                    {{ pageAddAsset('javascript', app.request.basePath ~ '/plugins/Mapstraction/lib/vendor/mxn/mxn.geocoder.js') }}
                    {{ pageAddAsset('javascript', app.request.basePath ~ '/plugins/Mapstraction/lib/vendor/mxn/mxn.googlev3.geocoder.js') }}
                {% endif %}
                <script type="text/javascript">
                /* <![CDATA[ */
                    ( function($) {
                        $(document).ready(function() {
                            «app.vendorAndName»InitGeographicalEditing({{ «name.formatForDB».latitude|«app.appName.formatForDB»_geoData }}, {{ «name.formatForDB».longitude|«app.appName.formatForDB»_geoData }}, '{{ mode }}', {% if useGeoLocation == true %}true{% else %}false{% endif %});
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


        ( function($) {
            $(document).ready(function() {
                «val userFields = getUserFieldsEntity»
                «IF !userFields.empty || standardFields»
                    // initialise auto completion for user fields
                    «FOR userField : userFields»
                        «val realName = userField.name.formatForCode»
                        «app.vendorAndName»InitUserField('«app.appName.toLowerCase»_«name.formatForCode.toLowerCase»_«realName»', 'get«name.formatForCodeCapital»«realName.formatForCodeCapital»Users');
                    «ENDFOR»
                    «IF standardFields»
                        {% if form.moderationSpecificCreator is defined %}
                            «app.vendorAndName»InitUserField('«app.appName.toLowerCase»_«name.formatForCode.toLowerCase»_moderationSpecificCreator', 'getCommonUsersList');
                        {% endif %}
                    «ENDIF»
                «ENDIF»
                «relationHelper.initJs(it, app, true)»
                «app.vendorAndName»InitEditForm('{{ mode }}', '{% if mode != 'create' %}{{ «FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForDB».«pkField.name.formatForCode»«ENDFOR» }}{% endif %}');
                «FOR field : getDerivedFields»«field.additionalInitScript»«ENDFOR»
            });
        })(jQuery);
    '''

    def private fieldWrapper(DerivedField it, String groupSuffix, String idSuffix) '''
        «IF entity.getIncomingJoinRelations.filter[e|e.getSourceFields.head == name.formatForDB].empty»«/* No input fields for foreign keys, relations are processed further down */»
            «IF !visible»
                <div class="hidden">
                    «formRow(it, groupSuffix, idSuffix)»
                </div>
            «ELSE»
                «formRow(it, groupSuffix, idSuffix)»
            «ENDIF»
        «ENDIF»
    '''

    def private formRow(DerivedField it, String groupSuffix, String idSuffix) {
        if (groupSuffix != '' || idSuffix != '') {
            '''{{ form_row(attribute(form, «IF groupSuffix != ''»«groupSuffix» ~ «ENDIF»'«name.formatForCode»'«IF idSuffix != ''» ~ «idSuffix»«ENDIF»)) }}'''
        } else {
            '''{{ form_row(form.«name.formatForCode») }}'''
        }
    }

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

    def private inlineRedirectHandlerImpl(Application it) '''
        {# purpose of this template: close an iframe from within this iframe #}
        <!DOCTYPE html>
        <html xml:lang="{{ app.request.locale }}" lang="{{ app.request.locale }}" dir="auto">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap.min.css')) }}
                {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap-theme.min.css')) }}
                {{ pageAddAsset('javascript', asset('jquery/jquery.min.js')) }}
                {{ pageAddAsset('javascript', asset('bootstrap/js/bootstrap.min.js')) }}
                {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».EditFunctions.js')) }}
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
