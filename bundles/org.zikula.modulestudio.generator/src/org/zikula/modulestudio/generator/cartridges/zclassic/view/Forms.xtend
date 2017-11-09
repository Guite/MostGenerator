package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Section
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.SharedFormElements
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
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
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension SharedFormElements = new SharedFormElements
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    IFileSystemAccess fsa
    Application app
    Boolean isSeparateAdminTemplate

    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        this.app = it
        for (entity : getAllEntities.filter[hasEditAction]) {
            entity.generate('edit')
            if (needsInlineEditing) {
                entity.entityInlineRedirectHandlerFile
            }
        }
    }

    /**
     * Entry point for form templates for each entity.
     */
    def private generate(Entity it, String actionName) {
        println('Generating edit form templates for entity "' + name.formatForDisplay + '"')
        isSeparateAdminTemplate = false
        var templatePath = editTemplateFile(actionName)
        if (!app.shouldBeSkipped(templatePath)) {
            fsa.generateFile(templatePath, formTemplate(actionName))
        }
        if (application.generateSeparateAdminTemplates) {
            isSeparateAdminTemplate = true
            templatePath = editTemplateFile('Admin/' + actionName)
            if (!app.shouldBeSkipped(templatePath)) {
                fsa.generateFile(templatePath, formTemplate(actionName))
            }
        }

        new Relations(fsa, app, false).generateInclusionTemplate(it)
        if (application.generateSeparateAdminTemplates) {
            new Relations(fsa, app, true).generateInclusionTemplate(it)
        }
    }

    def private formTemplate(Entity it, String actionName) '''
        «IF application.generateSeparateAdminTemplates»
            {# purpose of this template: build the «IF isSeparateAdminTemplate»admin«ELSE»user«ENDIF» form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» #}
            {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : «IF isSeparateAdminTemplate»'adminBase'«ELSE»'base'«ENDIF» %}
        «ELSE»
            {# purpose of this template: build the form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» #}
            {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : (routeArea == 'admin' ? 'adminBase' : 'base') %}
        «ENDIF»
        {% extends '«application.appName»::' ~ baseTemplate ~ '.html.twig' %}

        {% block title mode == 'create' ? __('Create «name.formatForDisplay»') : __('Edit «name.formatForDisplay»') %}
        «IF !application.generateSeparateAdminTemplates || isSeparateAdminTemplate»
            {% block admin_page_icon mode == 'create' ? 'plus' : 'pencil-square-o' %}
        «ENDIF»
        {% block content %}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-edit">
                «formTemplateBody(actionName)»
            </div>
        {% endblock %}
        {% block footer %}
            {{ parent() }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».Validation.js'), 98) }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».EditFunctions.js'), 99) }}
            «IF app.needsInlineEditing»
                {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».InlineEditing.js'), 99) }}
            «ENDIF»
            «IF app.needsAutoCompletion»
                {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».AutoCompletion.js'), 99) }}
            «ENDIF»
            «formTemplateJS»
        {% endblock %}
    '''

    def private formTemplateBody(Entity it, String actionName) '''
        {% form_theme form with [
            '@«application.appName»/Form/bootstrap_3.html.twig',
            'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
        ] %}
        {{ form_start(form, {attr: {id: '«name.formatForCode»EditForm', class: '«app.vendorAndName.toLowerCase»-edit-form'}}) }}
        «IF useGroupingTabs('edit')»
            <div class="zikula-bootstrap-tab-container">
                <ul class="nav nav-tabs">
                    <li role="presentation" class="active">
                        <a id="fieldsTab" href="#tabFields" title="{{ __('Fields') }}" role="tab" data-toggle="tab">{{ __('Fields') }}</a>
                    </li>
                    «IF geographical»
                        <li role="presentation">
                            <a id="mapTab" href="#tabMap" title="{{ __('Map') }}" role="tab" data-toggle="tab">{{ __('Map') }}</a>
                        </li>
                    «ENDIF»
                    «new Relations(fsa, app, isSeparateAdminTemplate).generateTabTitles(it)»
                    «IF attributable»
                        {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                            <li role="presentation">
                                <a id="attributesTab" href="#tabAttributes" title="{{ __('Attributes') }}" role="tab" data-toggle="tab">{{ __('Attributes') }}</a>
                            </li>
                        {% endif %}
                    «ENDIF»
                    «IF categorisable»
                        {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                            <li role="presentation">
                                <a id="categoriesTab" href="#tabCategories" title="{{ __('Categories') }}" role="tab" data-toggle="tab">{{ __('Categories') }}</a>
                            </li>
                        {% endif %}
                    «ENDIF»
                    «IF standardFields»
                        {% if mode != 'create' %}
                            <li role="presentation">
                                <a id="standardFieldsTab" href="#tabStandardFields" title="{{ __('Creation and update') }}" role="tab" data-toggle="tab">{{ __('Creation and update') }}</a>
                            </li>
                        {% endif %}
                    «ENDIF»
                    {% if form.moderationSpecificCreator is defined %}
                        <li role="presentation">
                            <a id="moderationTab" href="#tabModeration" title="{{ __('Moderation options') }}" role="tab" data-toggle="tab">{{ __('Moderation') }}</a>
                        </li>
                    {% endif %}
                </ul>

                {{ form_errors(form) }}
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane fade in active" id="tabFields" aria-labelledby="fieldsTab">
                        <h3>{{ __('Fields') }}</h3>
                        «fieldDetails»
                    </div>
                    «new Section().generate(it, app, fsa, isSeparateAdminTemplate)»
                </div>
            </div>
        «ELSE»
            {{ form_errors(form) }}
            «fieldDetails»
            «new Section().generate(it, app, fsa, isSeparateAdminTemplate)»
        «ENDIF»

        «submitActions»
        {{ form_end(form) }}
        «IF !skipHookSubscribers»
            «displayHooks(app)»

        «ENDIF»
    '''

    def private fieldDetails(Entity it) '''
        «translatableFieldDetails»
        «IF !hasTranslatableFields
          || (hasTranslatableFields && (!getEditableNonTranslatableFields.empty || (hasSluggableFields && !hasTranslatableSlug)))
          || geographical»
            «fieldDetailsFurtherOptions»
        «ENDIF»
    '''

    def private translatableFieldDetails(Entity it) '''
        «IF hasTranslatableFields»
            {% if translationsEnabled == true %}
                <div class="zikula-bootstrap-tab-container">
                    <ul class="{{ form.vars.id|lower }}-translation-locales nav nav-tabs">
                        {% for language in supportedLanguages %}
                            <li{% if language == app.request.locale %} class="active"{% endif %}>
                                <a href="#" data-toggle="tab" data-target=".{{ form.vars.id|lower }}-translations-fields-{{ language }}">
                                    {% if not form.vars.valid %}
                                        <span class="label label-danger"><i class="fa fa-warning"></i> <span class="sr-only">{{ __('Errors') }}</span></span>
                                    {% endif %}
                                    {% set hasRequiredFields = language in localesWithMandatoryFields %}
                                    {% if hasRequiredFields %}<span class="required">{% endif %}{{ language|languageName|safeHtml }}{% if hasRequiredFields %}</span>{% endif %}
                                </a>
                            </li>
                        {% endfor %}
                    </ul>
                    <div class="{{ form.vars.id|lower }}-translation-fields tab-content">
                        {% for language in supportedLanguages %}
                            <div class="{{ form.vars.id|lower }}-translations-fields-{{ language }} tab-pane fade{% if language == app.request.locale %} active in{% endif %}">
                                <fieldset>
                                    <legend>{{ language|languageName|safeHtml }}</legend>
                                    {% if language == app.request.locale %}
                                        «fieldSet»
                                    {% else %}
                                        {{ form_row(attribute(form, 'translations' ~ language)) }}
                                    {% endif %}
                                </fieldset>
                            </div>
                        {% endfor %}
                    </div>
                </div>
            {% else %}
                {% set language = app.request.locale %}
                <fieldset>
                    <legend>{{ language|languageName|safeHtml }}</legend>
                    «fieldSet»
                </fieldset>
            {% endif %}
        «ENDIF»
    '''

    def private fieldSet(Entity it) '''
        «FOR field : getEditableTranslatableFields»«field.fieldWrapper»«ENDFOR»
        «IF hasTranslatableSlug»
            «slugField»
        «ENDIF»
    '''

    def private fieldDetailsFurtherOptions(Entity it) '''
        <fieldset>
            <legend>{{ __('«IF hasTranslatableFields»Further properties«ELSE»Content«ENDIF»') }}</legend>
            «IF hasTranslatableFields»
                «FOR field : getEditableNonTranslatableFields»«field.fieldWrapper»«ENDFOR»
            «ELSE»
                «FOR field : getEditableFields»«field.fieldWrapper»«ENDFOR»
            «ENDIF»
            «IF !hasTranslatableFields || (hasSluggableFields && !hasTranslatableSlug)»
                «slugField»
            «ENDIF»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    {{ form_row(form.«geoFieldName») }}
                «ENDFOR»
            «ENDIF»
            «IF isInheriting»
                {{ form_row(form.parentFields) }}
            «ENDIF»
        </fieldset>
    '''

    def private slugField(Entity it) '''
        «IF hasSluggableFields && slugUpdatable && application.supportsSlugInputFields»
            {{ form_row(form.slug) }}
        «ENDIF»
    '''

    def private formTemplateJS(Entity it) '''
        «IF geographical»
            «includeLeaflet('edit', name.formatForDB)»
        «ENDIF»
        {% set formInitScript %}
            <script>
            /* <![CDATA[ */
                «jsInitImpl»
            /* ]]> */
            </script>
        {% endset %}
        {{ pageAddAsset('footer', formInitScript) }}
    '''

    def private jsInitImpl(Entity it) '''
        «new Relations(fsa, app, false).initJs(it, false)»

        ( function($) {
            $(document).ready(function() {
                «new Relations(fsa, app, false).initJs(it, true)»
                «app.vendorAndName»InitEditForm('{{ mode }}', '{% if mode != 'create' %}{{ «name.formatForDB».«primaryKey.name.formatForCode» }}{% endif %}');
                «FOR field : getDerivedFields»«field.additionalInitScript»«ENDFOR»
                «IF standardFields»
                    {% if form.moderationSpecificCreator is defined %}
                        initUserLiveSearch('«app.appName.toLowerCase»_«name.formatForCode.toLowerCase»_moderationSpecificCreator');
                    {% endif %}
                «ENDIF»
            });
        })(jQuery);
    '''

    def private fieldWrapper(DerivedField it) '''
        «IF entity.getIncomingJoinRelations.filter[r|r.getSourceFields.head == name.formatForDB].empty»«/* No input fields for foreign keys, relations are processed further down */»
            «fieldFormRow»
        «ENDIF»
    '''

    def private submitActions(Entity it) '''
        {# include possible submit actions #}
        <div class="form-group form-buttons">
            <div class="col-sm-offset-3 col-sm-9">
                «submitActionsImpl»
            </div>
        </div>
    '''

    def private submitActionsImpl(Entity it) '''
        {% for action in actions %}
            {{ form_widget(attribute(form, action.id)) }}
            {% if mode == 'create' and action.id == 'submit' and form.submitrepeat is defined %}
                {{ form_widget(attribute(form, 'submitrepeat')) }}
            {% endif %}
        {% endfor %}
        {{ form_widget(form.reset) }}
        {{ form_widget(form.cancel) }}
    '''

    def private displayHooks(Entity it, Application app) '''
        {% set hookId = mode != 'create' ? «name.formatForDB».«primaryKey.name.formatForCode» : null %}
        {% set hooks = notifyDisplayHooks(eventName='«app.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit', id=hookId, outputAsArray=true) %}
        {% if hooks is iterable and hooks|length > 0 %}
            {% for area, hook in hooks %}
                <div class="z-displayhook" data-area="{{ area|e('html_attr') }}">{{ hook|raw }}</div>
            {% endfor %}
        {% endif %}
    '''

    def private entityInlineRedirectHandlerFile(Entity it) {
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
                <script src="{{ asset('jquery/jquery.min.js') }}"></script>
                «IF needsInlineEditing»
                    <script src="{{ zasset('@«appName»:js/«appName».InlineEditing.js') }}"></script>
                «ENDIF»
            </head>
            <body>
                <script>
                /* <![CDATA[ */
                    // close window from parent document
                    ( function($) {
                        $(document).ready(function() {
                            «vendorAndName»CloseWindowFromInside('{{ idPrefix|e('js') }}', {% if commandName in ['submit', 'create', 'approve'] %}{{ itemId }}, '{{ formattedTitle|default('')|e('js') }}', '{{ searchTerm|default('')|e('js') }}'{% else %}0, '', ''{% endif %});
                        });
                    })(jQuery);
                /* ]]> */
                </script>
            </body>
        </html>
    '''
}
