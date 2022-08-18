package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    SimpleFields fieldHelper = new SimpleFields

    def generate(Application it, IMostFileSystemAccess fsa) {
        var fileName = ''
        val templateExtension = '.html.twig'
        for (entity : getFinderEntities) {
            val templatePath = getViewPath + 'External/' + entity.name.formatForCodeCapital + '/'

            fileName = 'find' + templateExtension
            fsa.generateFile(templatePath + fileName, entity.findTemplate(it))
        }
        for (entity : getAllEntities.filter[hasDisplayAction]) {
            val templatePath = getViewPath + 'External/' + entity.name.formatForCodeCapital + '/'

            fileName = 'display' + templateExtension
            fsa.generateFile(templatePath + fileName, entity.displayTemplate(it))

            fileName = 'info' + templateExtension
            fsa.generateFile(templatePath + fileName, entity.itemInfoTemplate(it))
        }
    }

    def private displayTemplate(Entity it, Application app) '''
        {# purpose of this template: Display one certain «name.formatForDisplay» within an external context #}
        {% trans_default_domain '«name.formatForCode»' %}
        «IF hasImageFieldsEntity»
            {{ pageAddAsset('javascript', asset('magnific-popup/jquery.magnific-popup.min.js'), 90) }}
            {{ pageAddAsset('stylesheet', asset('magnific-popup/magnific-popup.css'), 90) }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».js')) }}
        «ENDIF»
        <div id="«name.formatForCode»{{ «name.formatForCode».getKey() }}" class="«app.appName.toLowerCase»-external-«name.formatForDB»">
        {% if displayMode == 'link' %}
            <p«IF hasDisplayAction» class="«app.appName.toLowerCase»-external-link"«ENDIF»>
            «IF hasDisplayAction»
                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}" title="{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}">
            «ENDIF»
            {{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}
            «IF hasDisplayAction»
                </a>
            «ENDIF»
            </p>
        {% endif %}
        {% if hasPermission('«app.appName»::', '::', 'ACCESS_EDIT') %}
            {# for normal users without edit permission show only the actual file per default #}
            {% if displayMode == 'embed' %}
                <p class="«app.appName.toLowerCase»-external-title">
                    <strong>{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}</strong>
                </p>
            {% endif %}
        {% endif %}

        {% if displayMode == 'link' %}
        {% elseif displayMode == 'embed' %}
            <div class="«app.appName.toLowerCase»-external-snippet">
                «displaySnippet»
            </div>
            «IF hasDisplayAction»

                {# you can embed the display template like this: #}
                {#{ app.request.query.set('raw', 1) }}
                {% set displayPage = include('@«app.vendorAndName»/«name.formatForDisplayCapital»/display.html.twig', {«name.formatForCode»: «name.formatForCode», routeArea: '', currentUrlObject: null}) %}
                {% set displayPage = displayPage|split('<body>') %}
                {% set displayPage = displayPage[1]|split('</body>') %}
                {{ displayPage[0]|raw }#}
            «ENDIF»
            «IF hasAbstractStringFieldsEntity || categorisable»

            {# you can enable more details about the item: #}
            {#
                <p class="«app.appName.toLowerCase»-external-description">
                    «displayDescription('', '<br />')»
                    «IF categorisable»
                        {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Bundle\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                            «displayCategories»
                        {% endif %}
                    «ENDIF»
                </p>
            #}
            «ENDIF»
        {% endif %}
        </div>
    '''

    def private displaySnippet(Entity it) '''
        «IF hasImageFieldsEntity»
            «val imageField = getImageFieldsEntity.head»
            «fieldHelper.displayField(imageField, name.formatForCode, 'display')»
        «ELSE»
            &nbsp;
        «ENDIF»
    '''

    def private displayDescription(Entity it, String praefix, String suffix) '''
        «IF hasAbstractStringFieldsEntity»
            «IF hasTextFieldsEntity»
                {% if «name.formatForCode».«getTextFieldsEntity.head.name.formatForCode» is not empty %}«praefix»{{ «name.formatForCode».«getTextFieldsEntity.head.name.formatForCode» }}«suffix»{% endif %}
            «ELSEIF hasStringFieldsEntity»
                {% if «name.formatForCode».«getStringFieldsEntity.head.name.formatForCode» is not empty %}«praefix»{{ «name.formatForCode».«getStringFieldsEntity.head.name.formatForCode» }}«suffix»{% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def private displayCategories(Entity it) '''
        <dl class="category-list">
        {% for propName, catMapping in «name.formatForCode».categories %}
            <dt>{{ propName }}</dt>
            <dd>{{ catMapping.category.displayName[app.request.locale]|default(catMapping.category.name) }}</dd>
        {% endfor %}
        </dl>
    '''

    def private itemInfoTemplate(Entity it, Application app) '''
        {# purpose of this template: Display item information for previewing from other modules #}
        {% trans_default_domain '«name.formatForCode»' %}
        <dl id="«name.formatForCode»{{ «name.formatForCode».getKey() }}">
        <dt>{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}</dt>
        «IF hasImageFieldsEntity»
            <dd>«displaySnippet»</dd>
        «ENDIF»
        «displayDescription('<dd>', '</dd>')»
        «IF categorisable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Bundle\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                <dd>
                    «displayCategories»
                </dd>
            {% endif %}
        «ENDIF»
        </dl>
    '''

    def private findTemplate(Entity it, Application app) '''
        {# purpose of this template: Display a popup selector of «nameMultiple.formatForDisplay» #}
        {% set useFinder = true %}
        {% extends '@«app.vendorAndName»/raw.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% block title 'Search and select «name.formatForDisplay»'|trans %}
        {% block content %}
            <div class="container">
                «findTemplateObjectTypeSwitcher(app)»
                {% form_theme finderForm with [
                    '@«app.vendorAndName»/Form/bootstrap_4.html.twig',
                    '@ZikulaFormExtension/Form/form_div_layout.html.twig'
                ] only %}
                {{ form_start(finderForm, {attr: {id: '«app.appName.toFirstLower»SelectorForm'}}) }}
                {{ form_errors(finderForm) }}
                <fieldset>
                    <legend>{% trans %}Search and select «name.formatForDisplay»{% endtrans %}</legend>
                    {% if finderForm.language is defined and getModVar('ZConfig', 'multilingual') %}
                        {{ form_row(finderForm.language) }}
                    {% endif %}
                    «IF categorisable»
                        {% if finderForm.categories is defined and featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Bundle\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                            {{ form_row(finderForm.categories) }}
                        {% endif %}
                    «ENDIF»
                    «IF hasImageFieldsEntity»
                        {% if finderForm.onlyImages is defined %}
                            {{ form_row(finderForm.onlyImages) }}
                        {% endif %}
                        <div id="imageFieldRow">
                            {% if finderForm.imageField is defined %}
                                {{ form_row(finderForm.imageField) }}
                            {% endif %}
                        </div>
                    «ENDIF»
                    {% if finderForm.pasteAs is defined %}
                        {{ form_row(finderForm.pasteAs) }}
                    {% endif %}
                    <br />
                    «findTemplateObjectId(app)»

                    {% if finderForm.sort is defined %}
                        {{ form_row(finderForm.sort) }}
                    {% endif %}
                    {% if finderForm.sortdir is defined %}
                        {{ form_row(finderForm.sortdir) }}
                    {% endif %}
                    {% if finderForm.num is defined %}
                        {{ form_row(finderForm.num) }}
                    {% endif %}
                    «IF hasAbstractStringFieldsEntity»
                        <div id="searchTermRow">
                            {% if finderForm.q is defined %}
                                {{ form_row(finderForm.q) }}
                            {% endif %}
                        </div>
                    «ENDIF»
                    <div>
                        {{ include(paginator.template) }}
                    </div>
                    <div class="form-group row">
                        <div class="col-md-9 offset-md-3">
                            {{ form_widget(finderForm.update) }}
                            {{ form_widget(finderForm.cancel) }}
                        </div>
                    </div>
                </fieldset>
                {{ form_end(finderForm) }}
            </div>

            «findTemplateEditForm(app)»
        {% endblock %}
        {% block footer %}
            {{ parent() }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».Finder.js')) }}
        {% endblock %}
    '''

    def private findTemplateObjectTypeSwitcher(Entity it, Application app) '''
        «IF app.hasDisplayActions»
            <div class="zikula-bootstrap-tab-container">
                <ul class="nav nav-tabs" role="tablist">
                «FOR entity : app.getAllEntities.filter[hasDisplayAction]»
                    {% if '«entity.name.formatForCode»' in activatedObjectTypes %}
                        <li class="nav-item">
                            <a href="{{ path('«app.appName.formatForDB»_external_finder', {objectType: '«entity.name.formatForCode»', editor: editorName}) }}" title="{{ 'Search and select «entity.name.formatForDisplay»'|trans|e('html_attr') }}" class="nav-link{{ objectType == '«entity.name.formatForCode»' ? ' active' : '' }}">{% trans %}«entity.nameMultiple.formatForDisplayCapital»{% endtrans %}</a>
                        </li>
                    {% endif %}
                «ENDFOR»
                </ul>
            </div>
        «ENDIF»
    '''

    def private findTemplateObjectId(Entity it, Application app) '''
        <div class="form-group row">
            <label class="col-md-3 col-form-label">{% trans %}«name.formatForDisplayCapital»{% endtrans %}:</label>
            <div class="col-md-9">
                <div id="«app.appName.toLowerCase»ItemContainer">
                    «IF hasImageFieldsEntity»
                        {% if not onlyImages %}
                            <ul>
                        {% endif %}
                    «ELSE»
                        <ul>
                    «ENDIF»
                        {% for «name.formatForCode» in items %}
                            «IF hasImageFieldsEntity»
                            {% if not onlyImages or (attribute(«name.formatForCode», imageField) is not empty and attribute(«name.formatForCode», imageField ~ 'Meta').isImage) %}
                            «ENDIF»
                            «IF hasImageFieldsEntity»
                                {% if not onlyImages %}
                                    <li>
                                {% endif %}
                            «ELSE»
                                <li>
                            «ENDIF»
                                {% set itemId = «name.formatForCode».getKey() %}
                                <a href="#" data-itemid="{{ itemId }}">
                                    «IF hasImageFieldsEntity»
                                        {% if onlyImages %}
                                            {% set thumbOptions = attribute(thumbRuntimeOptions, '«name.formatForCode»' ~ imageField[:1]|upper ~ imageField[1:]) %}
                                            <img src="{{ attribute(«name.formatForCode», imageField).getPathname()|«app.appName.formatForDB»_relativePath|imagine_filter('zkroot', thumbOptions) }}" alt="{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ thumbOptions.thumbnail.size[0] }}" height="{{ thumbOptions.thumbnail.size[1] }}" class="rounded" />
                                        {% else %}
                                            {{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}
                                        {% endif %}
                                    «ELSE»
                                        {{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}
                                    «ENDIF»
                                </a>
                                {% set displayParameters = {«IF !hasSluggableFields || !slugUnique»«routePkParams(name.formatForCode, true)»«ENDIF»«appendSlug(name.formatForCode, true)»}|merge({'_locale': language|default(app.request.locale)}) %}
                                «IF hasDisplayAction»
                                    <input type="hidden" id="path{{ itemId }}" value="{{ path('«app.appName.formatForDB»_«name.formatForDB»_display', displayParameters) }}" />
                                    <input type="hidden" id="url{{ itemId }}" value="{{ url('«app.appName.formatForDB»_«name.formatForDB»_display', displayParameters) }}" />
                                «ENDIF»
                                <input type="hidden" id="title{{ itemId }}" value="{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}" />
                                <input type="hidden" id="desc{{ itemId }}" value="{% set description %}«displayDescription('', '')»{% endset %}{{ description|striptags|e('html_attr') }}" />
                                «IF hasImageFieldsEntity»
                                    {% if onlyImages %}
                                        <input type="hidden" id="imagePath{{ itemId }}" value="{{ app.request.basePath }}/{{ attribute(«name.formatForCode», imageField).getPathname() }}" />
                                    {% endif %}
                                «ENDIF»
                            «IF hasImageFieldsEntity»
                                {% if not onlyImages %}
                                    </li>
                                {% endif %}
                            «ELSE»
                                </li>
                            «ENDIF»
                            «IF hasImageFieldsEntity»
                            {% endif %}
                            «ENDIF»
                        {% else %}
                            «IF hasImageFieldsEntity»
                                {% if not onlyImages %}<li>{% endif %}{% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}{% if not onlyImages %}</li>{% endif %}
                            «ELSE»
                                <li>{% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}</li>
                            «ENDIF»
                        {% endfor %}
                    «IF hasImageFieldsEntity»
                        {% if not onlyImages %}
                            </ul>
                        {% endif %}
                    «ELSE»
                        </ul>
                    «ENDIF»
                </div>
            </div>
        </div>
    '''

    def private findTemplateEditForm(Entity it, Application app) '''
        «IF hasEditAction»
            {#
            <div class="«app.appName.toLowerCase»-finderform">
                <fieldset>
                    {{ render(controller('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Bundle\\Controller\\«name.formatForCodeCapital»Controller::editAction')) }}
                </fieldset>
            </div>
            #}
        «ENDIF»
    '''
}
