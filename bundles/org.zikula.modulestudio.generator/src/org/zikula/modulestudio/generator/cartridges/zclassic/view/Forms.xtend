package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Section
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.SharedFormElements
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
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
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension SharedFormElements = new SharedFormElements
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

    IMostFileSystemAccess fsa
    Application app
    Boolean isSeparateAdminTemplate

    def generate(Application it, IMostFileSystemAccess fsa) {
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
        ('Generating edit form templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        isSeparateAdminTemplate = false
        var templatePath = editTemplateFile(actionName)
        fsa.generateFile(templatePath, formTemplate(actionName))

        if (application.separateAdminTemplates) {
            isSeparateAdminTemplate = true
            templatePath = editTemplateFile('Admin/' + actionName)
            fsa.generateFile(templatePath, formTemplate(actionName))
        }

        new Relations(fsa, app, false).generateInclusionTemplate(it)
        if (application.separateAdminTemplates) {
            new Relations(fsa, app, true).generateInclusionTemplate(it)
        }
    }

    def private formTemplate(Entity it, String actionName) '''
        «IF application.separateAdminTemplates»
            {# purpose of this template: build the «IF isSeparateAdminTemplate»admin«ELSE»user«ENDIF» form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» #}
            {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : «IF isSeparateAdminTemplate»'adminBase'«ELSE»'base'«ENDIF» %}
        «ELSE»
            {# purpose of this template: build the form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» #}
            {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : (routeArea == 'admin' ? 'adminBase' : 'base') %}
        «ENDIF»
        «IF application.targets('3.0')»
            {% extends '@«application.appName»/' ~ baseTemplate ~ '.html.twig' %}
        «ELSE»
            {% extends '«application.appName»::' ~ baseTemplate ~ '.html.twig' %}
        «ENDIF»
        {% block title mode == 'create' ? __('Create «name.formatForDisplay»') : __('Edit «name.formatForDisplay»') %}
        «IF !application.separateAdminTemplates || isSeparateAdminTemplate»
            {% block admin_page_icon mode == 'create' ? 'plus' : '«IF application.targets('3.0')»edit«ELSE»pencil-square-o«ENDIF»' %}
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
            '@«application.appName»/Form/bootstrap_«IF application.targets('3.0')»4«ELSE»3«ENDIF».html.twig',
            «IF application.targets('3.0')»
                '@ZikulaFormExtension/Form/form_div_layout.html.twig'
            «ELSE»
                'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
            «ENDIF»
        ] %}
        {{ form_start(form, {attr: {id: '«name.formatForCode»EditForm', class: '«app.vendorAndName.toLowerCase»-edit-form'}}) }}
        «IF useGroupingTabs('edit')»
            <div class="zikula-bootstrap-tab-container">
                <ul class="nav nav-tabs" role="tablist">
                    <li class="«IF application.targets('3.0')»nav-item«ELSE»active«ENDIF»" role="presentation">
                        <a id="fieldsTab" href="#tabFields" title="{{ __('Fields') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link active"«ENDIF»>{{ __('Fields') }}</a>
                    </li>
                    «IF geographical»
                        <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                            <a id="mapTab" href="#tabMap" title="{{ __('Map') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>{{ __('Map') }}</a>
                        </li>
                    «ENDIF»
                    «new Relations(fsa, app, isSeparateAdminTemplate).generateTabTitles(it)»
                    «IF attributable»
                        {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                            <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                                <a id="attributesTab" href="#tabAttributes" title="{{ __('Attributes') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>{{ __('Attributes') }}</a>
                            </li>
                        {% endif %}
                    «ENDIF»
                    «IF categorisable»
                        {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                            <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                                <a id="categoriesTab" href="#tabCategories" title="{{ __('Categories') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>{{ __('Categories') }}</a>
                            </li>
                        {% endif %}
                    «ENDIF»
                    «IF standardFields»
                        {% if mode != 'create' %}
                            <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                                <a id="standardFieldsTab" href="#tabStandardFields" title="{{ __('Creation and update') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>{{ __('Creation and update') }}</a>
                            </li>
                        {% endif %}
                    «ENDIF»
                    {% if form.moderationSpecificCreator is defined or form.moderationSpecificCreationDate is defined %}
                        <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                            <a id="moderationTab" href="#tabModeration" title="{{ __('Moderation options') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>{{ __('Moderation') }}</a>
                        </li>
                    {% endif %}
                </ul>

                {{ form_errors(form) }}
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane fade «IF application.targets('3.0')»show«ELSE»in«ENDIF» active" id="tabFields" aria-labelledby="fieldsTab">
                        <h3>{{ __('Fields') }}</h3>
                        «fieldDetails('')»
                    </div>
                    «new Section().generate(it, app, fsa, isSeparateAdminTemplate)»
                </div>
            </div>
        «ELSE»
            {{ form_errors(form) }}
            «fieldDetails('')»
            «new Section().generate(it, app, fsa, isSeparateAdminTemplate)»
        «ENDIF»

        «submitActions»
        {{ form_end(form) }}
        «IF !skipHookSubscribers»
            «displayHooks(app)»

        «ENDIF»
    '''

    def fieldDetails(Entity it, String subElem) '''
        «translatableFieldDetails(subElem)»
        «IF tree != EntityTreeType.NONE
          || !hasTranslatableFields
          || (hasTranslatableFields && (!getEditableNonTranslatableFields.empty || (hasSluggableFields && !hasTranslatableSlug)))
          || geographical
          || isInheriting»
            «fieldDetailsFurtherOptions(subElem)»
        «ENDIF»
    '''

    def private translatableFieldDetails(Entity it, String subElem) '''
        «IF hasTranslatableFields»
            {% if translationsEnabled == true %}
                <div class="zikula-bootstrap-tab-container">
                    <ul class="{{ form.vars.id|lower }}-translation-locales nav nav-tabs" role="tablist">
                        {% for language in supportedLanguages %}
                            <li«IF application.targets('3.0')» class="nav-item"«ELSE»{% if language == app.request.locale %} class="active"{% endif %}«ENDIF» role="presentation">
                                <a href="#" data-toggle="tab" data-target=".{{ form.vars.id|lower }}-translations-fields-{{ language }}"«IF application.targets('3.0')» class="nav-link{% if language == app.request.locale %} active{% endif %}"«ENDIF»>
                                    {% if not form.vars.valid %}
                                        <span class="label label-danger"><i class="fa fa-«IF application.targets('3.0')»exclamation-triangle«ELSE»warning«ENDIF»"></i> <span class="sr-only">{{ __('Errors') }}</span></span>
                                    {% endif %}
                                    {% set hasRequiredFields = language in localesWithMandatoryFields %}
                                    {% if hasRequiredFields %}<span class="required">{% endif %}{{ language|«IF application.targets('3.0')»language_name«ELSE»languageName|safeHtml«ENDIF» }}{% if hasRequiredFields %}</span>{% endif %}
                                </a>
                            </li>
                        {% endfor %}
                    </ul>
                    <div class="{{ form.vars.id|lower }}-translation-fields tab-content">
                        {% for language in supportedLanguages %}
                            <div class="{{ form.vars.id|lower }}-translations-fields-{{ language }} tab-pane fade{% if language == app.request.locale %} «IF application.targets('3.0')»show«ELSE»in«ENDIF» active{% endif %}">
                                <fieldset>
                                    <legend>{{ language|«IF application.targets('3.0')»language_name«ELSE»languageName|safeHtml«ENDIF» }}</legend>
                                    {% if language == app.request.locale %}
                                        «fieldSet(subElem)»
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
                    <legend>{{ language|«IF application.targets('3.0')»language_name«ELSE»languageName|safeHtml«ENDIF» }}</legend>
                    «fieldSet(subElem)»
                </fieldset>
            {% endif %}
        «ENDIF»
    '''

    def private fieldSet(Entity it, String subElem) '''
        «FOR field : getEditableTranslatableFields»«field.fieldWrapper(subElem)»«ENDFOR»
        «IF hasTranslatableSlug»
            «slugField(subElem)»
        «ENDIF»
    '''

    def private fieldDetailsFurtherOptions(Entity it, String subElem) '''
        <fieldset>
            <legend>{{ __('«IF hasTranslatableFields»Further properties«ELSE»Content«ENDIF»') }}</legend>
            «IF tree != EntityTreeType.NONE»
                {% if mode == 'create' and form.parent is defined %}
                    {{ form_row(form.parent) }}
                {% endif %}
            «ENDIF»
            «IF hasTranslatableFields»
                «FOR field : getEditableNonTranslatableFields»«field.fieldWrapper(subElem)»«ENDFOR»
            «ELSE»
                «FOR field : getEditableFields»«field.fieldWrapper(subElem)»«ENDFOR»
            «ENDIF»
            «IF !hasTranslatableFields || (hasSluggableFields && !hasTranslatableSlug)»
                «slugField(subElem)»
            «ENDIF»
            «IF geographical && !subElem.empty»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    {{ form_row(attribute(«subElem», '«geoFieldName»')) }}
                «ENDFOR»
            «ENDIF»
            «IF isInheriting»
                «IF !subElem.empty»
                    {{ form_row(attribute(«subElem», 'parentFields')) }}
                «ELSE»
                    {{ form_row(form.parentFields) }}
                «ENDIF»
            «ENDIF»
        </fieldset>
    '''

    def private slugField(Entity it, String subElem) '''
        «IF hasSluggableFields && slugUpdatable»
            «IF !subElem.empty»
                {{ form_row(attribute(«subElem», 'slug')) }}
            «ELSE»
                {{ form_row(form.slug) }}
            «ENDIF»
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

    def private fieldWrapper(DerivedField it, String subElem) '''
        «IF entity.getIncomingJoinRelations.filter[r|r.getSourceFields.head == name.formatForDB].empty»«/* No input fields for foreign keys, relations are processed further down */»
            «fieldFormRow(subElem)»
        «ENDIF»
    '''

    def private submitActions(Entity it) '''
        {# include possible submit actions #}
        <div class="form-group form-buttons«IF application.targets('3.0')» row«ENDIF»">
            <div class="«IF application.targets('3.0')»col-md-9 offset-md-3«ELSE»col-sm-offset-3 col-sm-9«ENDIF»">
                «submitActionsImpl»
            </div>
        </div>
        «IF app.targets('3.0') && !getOutgoingJoinRelationsWithoutDeleteCascade.empty»
            {% if not workflow_can(«name.formatForDB», 'delete') %}
                <div class="alert alert-info">
                    <h4>{{ __('Deletion of this «name.formatForDisplay» is not possible') }}</h4>
                    <ul>
                        {% for blocker in workflow_transition_blockers(«name.formatForDB», 'delete') %}
                            <li>{{ blocker.message }}</li>
                        {% endfor %}
                    </ul>
                </div>
            {% endif %}
        «ENDIF»
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
        {% if supportsHookSubscribers %}
            {% set hookId = mode != 'create' ? «name.formatForDB».«primaryKey.name.formatForCode» : null %}
            {% set hooks = notifyDisplayHooks(eventName='«app.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit', id=hookId, outputAsArray=true) %}
            {% if hooks is iterable and hooks|length > 0 %}
                {% for area, hook in hooks %}
                    <div class="z-displayhook" data-area="{{ area|e('html_attr') }}">{{ hook|raw }}</div>
                {% endfor %}
            {% endif %}
        {% endif %}
    '''

    def private entityInlineRedirectHandlerFile(Entity it) {
        val templatePath = app.getViewPath + name.formatForCodeCapital + '/'
        val fileName = 'inlineRedirectHandler.html.twig'
        fsa.generateFile(templatePath + fileName, app.inlineRedirectHandlerImpl)
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
