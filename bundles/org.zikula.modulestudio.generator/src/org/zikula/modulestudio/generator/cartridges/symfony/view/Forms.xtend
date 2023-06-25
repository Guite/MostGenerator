package org.zikula.modulestudio.generator.cartridges.symfony.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.view.formcomponents.Relations
import org.zikula.modulestudio.generator.cartridges.symfony.view.formcomponents.Section
import org.zikula.modulestudio.generator.cartridges.symfony.view.formcomponents.SharedFormElements
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
        var templatePath = editTemplateFile(actionName)
        fsa.generateFile(templatePath, formTemplate(actionName))

        new Relations(fsa, app).generateInclusionTemplate(it)
    }

    def private formTemplate(Entity it, String actionName) '''
        {# purpose of this template: build the form to «actionName.formatForDisplay» an instance of «name.formatForDisplay» #}
        {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : (routeArea == 'admin' ? 'adminBase' : 'base') %}
        {% extends '@«app.vendorAndName»/' ~ baseTemplate ~ '.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% block title mode == 'create' ? 'Create «name.formatForDisplay»'|trans : 'Edit «name.formatForDisplay»'|trans %}
        {% block admin_page_icon mode == 'create' ? 'plus' : 'edit' %}
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
            «jsDefinitions»
        {% endblock %}
    '''

    def private formTemplateBody(Entity it, String actionName) '''
        {% form_theme form with [
            '@«app.vendorAndName»/Form/bootstrap_4.html.twig',
            '@ZikulaFormExtension/Form/form_div_layout.html.twig'
        ] only %}
        {{ form_start(form, {attr: {id: '«name.formatForCode»EditForm', class: '«app.vendorAndName.toLowerCase»-edit-form'}}) }}
        «IF useGroupingTabs('edit')»
            <div class="zikula-bootstrap-tab-container">
                <ul class="nav nav-tabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <a id="fieldsTab" href="#tabFields" title="{{ 'Fields'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link active">{% trans from 'messages' %}Fields{% endtrans %}</a>
                    </li>
                    «IF geographical»
                        <li class="nav-item" role="presentation">
                            <a id="mapTab" href="#tabMap" title="{{ 'Map'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from 'messages' %}Map{% endtrans %}</a>
                        </li>
                    «ENDIF»
                    «new Relations(fsa, app).generateTabTitles(it)»
                    «IF categorisable»
                        {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Bundle\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                            <li class="nav-item" role="presentation">
                                <a id="categoriesTab" href="#tabCategories" title="{{ 'Categories'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from 'messages' %}Categories{% endtrans %}</a>
                            </li>
                        {% endif %}
                    «ENDIF»
                    «IF standardFields»
                        {% if mode != 'create' %}
                            <li class="nav-item" role="presentation">
                                <a id="standardFieldsTab" href="#tabStandardFields" title="{{ 'Creation and update'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from 'messages' %}Creation and update{% endtrans %}</a>
                            </li>
                        {% endif %}
                    «ENDIF»
                    {% if form.moderationSpecificCreator is defined or form.moderationSpecificCreationDate is defined %}
                        <li class="nav-item" role="presentation">
                            <a id="moderationTab" href="#tabModeration" title="{{ 'Moderation options'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from 'messages' %}Moderation{% endtrans %}</a>
                        </li>
                    {% endif %}
                </ul>

                {{ form_errors(form) }}
                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane fade show active" id="tabFields" aria-labelledby="fieldsTab">
                        <h3>{% trans from 'messages' %}Fields{% endtrans %}</h3>
                        «fieldDetails('')»
                    </div>
                    «new Section().generate(it, app, fsa)»
                </div>
            </div>
        «ELSE»
            {{ form_errors(form) }}
            «fieldDetails('')»
            «new Section().generate(it, app, fsa)»
        «ENDIF»

        «submitActions»
        {{ form_end(form) }}
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
                            <li class="nav-item" role="presentation">
                                <a href="#" data-toggle="tab" data-target=".{{ form.vars.id|lower }}-translations-fields-{{ language }}" class="nav-link{% if language == app.request.locale %} active{% endif %}">
                                    {% if language != app.request.locale and form[language]|default and not form[language].vars.valid %}
                                        <span class="badge badge-danger"><i class="fas fa-exclamation-triangle"></i> <span class="sr-only">{% trans from 'messages' %}Errors{% endtrans %}</span></span>
                                    {% endif %}
                                    {% set hasRequiredFields = language in localesWithMandatoryFields %}
                                    {% if hasRequiredFields %}<span class="required">{% endif %}{{ language|language_name }}{% if hasRequiredFields %}</span>{% endif %}
                                </a>
                            </li>
                        {% endfor %}
                    </ul>
                    <div class="{{ form.vars.id|lower }}-translation-fields tab-content">
                        {% for language in supportedLanguages %}
                            <div class="{{ form.vars.id|lower }}-translations-fields-{{ language }} tab-pane fade{% if language == app.request.locale %} show active{% endif %}">
                                <fieldset>
                                    <legend>{{ language|language_name }}</legend>
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
                    <legend>{{ language|language_name }}</legend>
                    «fieldSet(subElem)»
                </fieldset>
            {% endif %}
        «ENDIF»
    '''

    def private fieldSet(Entity it, String subElem) '''
        «FOR field : getEditableTranslatableFields.filter[f|!#['latitude', 'longitude'].contains(f.name)]»«field.fieldWrapper(subElem)»«ENDFOR»
        «IF hasTranslatableSlug»
            «slugField(subElem)»
        «ENDIF»
    '''

    def private fieldDetailsFurtherOptions(Entity it, String subElem) '''
        <fieldset>
            <legend>{% trans from 'messages' %}«IF hasTranslatableFields»Further properties«ELSE»Content«ENDIF»{% endtrans %}</legend>
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

    def private jsDefinitions(Entity it) '''
        «IF geographical»
            «includeLeaflet('edit', name.formatForCode)»
        «ENDIF»
        <div id="formEditingDefinition" data-mode="{{ mode|e('html_attr') }}" data-entityid="{% if mode != 'create' %}{{ «name.formatForCode».«primaryKey.name.formatForCode»|e('html_attr') }}{% endif %}"></div>
        «FOR field : getDerivedFields»«field.jsDefinition»«ENDFOR»
        «IF standardFields»
            {% if form.moderationSpecificCreator is defined %}
                <div class="field-editing-definition" data-field-type="user" data-field-name="«app.appName.toLowerCase»_«name.formatForCode.toLowerCase»_moderationSpecificCreator"></div>
            {% endif %}
        «ENDIF»
        «new Relations(fsa, app).jsInitDefinitions(it)»
    '''

    def private fieldWrapper(DerivedField it, String subElem) '''
        «IF entity.getIncomingJoinRelations.filter[r|r.getSourceFields.head == name.formatForDB].empty»«/* No input fields for foreign keys, relations are processed further down */»
            «fieldFormRow(subElem)»
        «ENDIF»
    '''

    def private submitActions(Entity it) '''
        {# include possible submit actions #}
        <div class="form-group form-buttons row">
            <div class="col-md-9 offset-md-3">
                «submitActionsImpl»
            </div>
        </div>
        «IF !getOutgoingJoinRelationsWithoutDeleteCascade.empty»
            {% if mode != 'create' and not workflow_can(«name.formatForCode», 'delete') %}
                <div class="alert alert-info">
                    <h4>{% trans %}Deletion of this «name.formatForDisplay» is not possible{% endtrans %}</h4>
                    <ul>
                        {% for blocker in workflow_transition_blockers(«name.formatForCode», 'delete') %}
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
            </head>
            <body>
                <div id="inlineRedirectParameters" data-idprefix="{{ idPrefix|e('html_attr') }}" {% if commandName in ['submit', 'create', 'approve'] %}data-itemid="{{ itemId }}" data-title="{{ formattedTitle|default('')|e('html_attr') }}" data-searchterm="{{ searchTerm|default('')|e('html_attr') }}"{% else %}data-itemid="0" data-title="" data-searchterm=""{% endif %}></div>
                <script src="{{ asset('jquery/jquery.min.js') }}"></script>
                «IF needsInlineEditing»
                    <script src="{{ zasset('@«appName»:js/«appName».InlineEditing.js') }}"></script>
                «ENDIF»
            </body>
        </html>
    '''
}
