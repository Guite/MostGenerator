package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
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
            if (!targets('2.0')) {
                // content type editing is not ready for Twig yet
                fileName = 'select.tpl'
                fsa.generateFile(templatePath + fileName, entity.selectTemplateLegacy(it))
            }
        }
    }

    def private displayTemplate(Entity it, Application app) '''
        {# purpose of this template: Display one certain «name.formatForDisplay» within an external context #}
        «IF app.targets('3.0') && !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
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
            {{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle«IF !skipHookSubscribers»|notifyFilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')|safeHtml«ENDIF» }}
            «IF hasDisplayAction»
                </a>
            «ENDIF»
            </p>
        {% endif %}
        {% if hasPermission('«app.appName»::', '::', 'ACCESS_EDIT') %}
            {# for normal users without edit permission show only the actual file per default #}
            {% if displayMode == 'embed' %}
                <p class="«app.appName.toLowerCase»-external-title">
                    <strong>{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle«IF !skipHookSubscribers»|notifyFilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')|safeHtml«ENDIF» }}</strong>
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
                {% set displayPage = include('@«app.appName»/«name.formatForDisplayCapital»/display.html.twig', {«name.formatForCode»: «name.formatForCode», routeArea: '', currentUrlObject: null}) %}
                {% set displayPage = displayPage|split('<body>') %}
                {% set displayPage = displayPage[1]|split('</body>') %}
                {{ displayPage[0]|raw }#}
            «ENDIF»

            {# you can distinguish the context like this: #}
            {# % if source == 'block' %}
                ... detail block
            {% elseif source == 'contentType' %}
                ... detail content type
            {% elseif source == 'scribite' %}
                ...
            {% endif % #}
            «IF hasAbstractStringFieldsEntity || categorisable»

            {# you can enable more details about the item: #}
            {#
                <p class="«app.appName.toLowerCase»-external-description">
                    «displayDescription('', '<br />')»
                    «IF categorisable»
                        {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
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
            <dd>{{ catMapping.category.«IF application.targets('3.0')»displayName«ELSE»display_name«ENDIF»[app.request.locale]|default(catMapping.category.name) }}</dd>
        {% endfor %}
        </dl>
    '''

    def private itemInfoTemplate(Entity it, Application app) '''
        {# purpose of this template: Display item information for previewing from other modules #}
        «IF app.targets('3.0') && !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        <dl id="«name.formatForCode»{{ «name.formatForCode».getKey() }}">
        <dt>{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle«IF !skipHookSubscribers»|notifyFilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')|safeHtml«ENDIF» }}</dt>
        «IF hasImageFieldsEntity»
            <dd>«displaySnippet»</dd>
        «ENDIF»
        «displayDescription('<dd>', '</dd>')»
        «IF categorisable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                <dd>
                    «displayCategories»
                </dd>
            {% endif %}
        «ENDIF»
        </dl>
    '''

    def private findTemplate(Entity it, Application app) '''
        {# purpose of this template: Display a popup selector of «nameMultiple.formatForDisplay» for scribite integration #}
        {% set useFinder = true %}
        «IF app.targets('3.0')»
            {% extends '@«app.appName»/raw.html.twig' %}
        «ELSE»
            {% extends '«app.appName»::raw.html.twig' %}
        «ENDIF»
        «IF app.targets('3.0') && !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% block title «IF app.targets('3.0')»'Search and select «name.formatForDisplay»'|trans«ELSE»__('Search and select «name.formatForDisplay»')«ENDIF» %}
        {% block content %}
            <div class="container">
                «findTemplateObjectTypeSwitcher(app)»
                {% form_theme finderForm with [
                    '@«app.appName»/Form/bootstrap_«IF app.targets('3.0')»4«ELSE»3«ENDIF».html.twig',
                    «IF app.targets('3.0')»
                        '@ZikulaFormExtension/Form/form_div_layout.html.twig'
                    «ELSE»
                        'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
                    «ENDIF»
                ]«IF app.targets('3.0')» only«ENDIF» %}
                {{ form_start(finderForm, {attr: {id: '«app.appName.toFirstLower»SelectorForm'}}) }}
                {{ form_errors(finderForm) }}
                <fieldset>
                    <legend>«IF application.targets('3.0')»{% trans %}Search and select «name.formatForDisplay»{% endtrans %}«ELSE»{{ __('Search and select «name.formatForDisplay»') }}«ENDIF»</legend>
                    {% if finderForm.language is defined and getModVar('ZConfig', 'multilingual') %}
                        {{ form_row(finderForm.language) }}
                    {% endif %}
                    «IF categorisable»
                        {% if finderForm.categories is defined and featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
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
                        «IF app.targets('3.0')»
                            {{ include(paginator.template) }}
                        «ELSE»
                            {{ pager({display: 'page', rowcount: pager.numitems, limit: pager.itemsperpage, posvar: 'pos', maxpages: 10, route: '«app.appName.formatForDB»_external_finder'}) }}
                        «ENDIF»
                    </div>
                    <div class="form-group«IF app.targets('3.0')» row«ENDIF»">
                        <div class="«IF app.targets('3.0')»col-md-9 offset-md-3«ELSE»col-sm-offset-3 col-sm-9«ENDIF»">
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
                        «IF app.targets('3.0')»
                            <li class="nav-item">
                                <a href="{{ path('«app.appName.formatForDB»_external_finder', {objectType: '«entity.name.formatForCode»', editor: editorName}) }}" title="{{ 'Search and select «entity.name.formatForDisplay»'|trans|e('html_attr') }}" class="nav-link{{ objectType == '«entity.name.formatForCode»' ? ' active' : '' }}">{% trans %}«entity.nameMultiple.formatForDisplayCapital»{% endtrans %}</a>
                            </li>
                        «ELSE»
                            <li{{ objectType == '«entity.name.formatForCode»' ? ' class="active"' : '' }}>
                                <a href="{{ path('«app.appName.formatForDB»_external_finder', {objectType: '«entity.name.formatForCode»', editor: editorName}) }}" title="{{ __('Search and select «entity.name.formatForDisplay»')|e('html_attr') }}">{{ __('«entity.nameMultiple.formatForDisplayCapital»') }}</a>
                            </li>
                        «ENDIF»
                    {% endif %}
                «ENDFOR»
                </ul>
            </div>
        «ENDIF»
    '''

    def private findTemplateObjectId(Entity it, Application app) '''
        <div class="form-group«IF app.targets('3.0')» row«ENDIF»">
            <label class="«IF app.targets('3.0')»col-md-3 col-form«ELSE»col-sm-3 control«ENDIF»-label">«IF app.targets('3.0')»{% trans %}«name.formatForDisplayCapital»{% endtrans %}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»:</label>
            <div class="col-«IF app.targets('3.0')»md«ELSE»sm«ENDIF»-9">
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
                                            <img src="{{ attribute(«name.formatForCode», imageField).getPathname()«IF app.targets('3.0')»|«app.appName.formatForDB»_relativePath«ENDIF»|imagine_filter('zkroot', thumbOptions) }}" alt="{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ thumbOptions.thumbnail.size[0] }}" height="{{ thumbOptions.thumbnail.size[1] }}" class="«IF !app.targets('3.0')»img-«ENDIF»rounded" />
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
                                {% if not onlyImages %}<li>{% endif %}«IF application.targets('3.0')»{% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}«ELSE»{{ __('No «nameMultiple.formatForDisplay» found.') }}«ENDIF»{% if not onlyImages %}</li>{% endif %}
                            «ELSE»
                                <li>«IF application.targets('3.0')»{% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}«ELSE»{{ __('No «nameMultiple.formatForDisplay» found.') }}«ENDIF»</li>
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
                    {{ render(controller('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Controller\\«name.formatForCodeCapital»Controller::editAction')) }}
                </fieldset>
            </div>
            #}
        «ENDIF»
    '''

    def private selectTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display a popup selector for Forms and Content integration *}
        {assign var='baseID' value='«name.formatForCode»'}
        <div id="itemSelectorInfo" class="«IF app.targets('3.0')»d-none«ELSE»hidden«ENDIF»" data-base-id="{$baseID}" data-selected-id="{$selectedId|default:0}"></div>
        <div class="row">
            <div class="col-«IF app.targets('3.0')»md«ELSE»sm«ENDIF»-8">
                «IF categorisable»

                    {if $properties ne null && is_array($properties)}
                        {gt text='All' assign='lblDefault'}
                        {nocache}
                        {foreach key='propertyName' item='propertyId' from=$properties}
                            <div class="form-group«IF app.targets('3.0')» row«ENDIF»">
                                {assign var='hasMultiSelection' value=$categoryHelper->hasMultipleSelection('«name.formatForCode»', $propertyName)}
                                {gt text='Category' assign='categoryLabel'}
                                {assign var='categorySelectorId' value='catid'}
                                {assign var='categorySelectorName' value='catid'}
                                {assign var='categorySelectorSize' value='1'}
                                {if $hasMultiSelection eq true}
                                    {gt text='Categories' assign='categoryLabel'}
                                    {assign var='categorySelectorName' value='catids'}
                                    {assign var='categorySelectorId' value='catids__'}
                                    {assign var='categorySelectorSize' value='8'}
                                {/if}
                                <label for="{$baseID}_{$categorySelectorId}{$propertyName}" class="col-sm-3 control-label">{$categoryLabel}:</label>
                                <div class="col-«IF app.targets('3.0')»md«ELSE»sm«ENDIF»-9">
                                    {selector_category name="`$baseID`_`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName|default:null categoryRegistryModule='«app.appName»' categoryRegistryTable="`$objectType`Entity" categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize cssClass='form-control'}
                                </div>
                            </div>
                        {/foreach}
                        {/nocache}
                    {/if}
                «ENDIF»
                <div class="form-group«IF app.targets('3.0')» row«ENDIF»">
                    <label for="{$baseID}Id" class="«IF app.targets('3.0')»col-md-3 col-form«ELSE»col-sm-3 control«ENDIF»-label-label">{gt text='«name.formatForDisplayCapital»'}:</label>
                    <div class="col-«IF app.targets('3.0')»md«ELSE»sm«ENDIF»-9">
                        <select id="{$baseID}Id" name="id" class="form-control">
                            {foreach item='«name.formatForCode»' from=$items}
                                <option value="{$«name.formatForCode»->getKey()}"{if $selectedId eq $«name.formatForCode»->getKey()} selected="selected"{/if}>{$«name.formatForCode»->get«IF hasDisplayStringFieldsEntity»«getDisplayStringFieldsEntity.head.name.formatForCodeCapital»«ELSE»«getSelfAndParentDataObjects.map[fields].flatten.head.name.formatForCodeCapital»«ENDIF»()}</option>
                            {foreachelse}
                                <option value="0">{gt text='No entries found.'}</option>
                            {/foreach}
                        </select>
                    </div>
                </div>
                <div class="form-group«IF app.targets('3.0')» row«ENDIF»">
                    <label for="{$baseID}Sort" class="«IF app.targets('3.0')»col-md-3 col-form«ELSE»col-sm-3 control«ENDIF»-label-label">{gt text='Sort by'}:</label>
                    <div class="col-«IF app.targets('3.0')»md«ELSE»sm«ENDIF»-9">
                        <select id="{$baseID}Sort" name="sort" class="form-control">
                            «FOR field : getSortingFields»
                                <option value="«field.name.formatForCode»"{if $sort eq '«field.name.formatForCode»'} selected="selected"{/if}>{gt text='«field.name.formatForDisplayCapital»'}</option>
                            «ENDFOR»
                            «IF standardFields»
                                <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                                <option value="createdBy"{if $sort eq 'createdBy'} selected="selected"{/if}>{gt text='Creator'}</option>
                                <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
                                <option value="updatedBy"{if $sort eq 'updatedBy'} selected="selected"{/if}>{gt text='Updater'}</option>
                            «ENDIF»
                        </select>
                        <select id="{$baseID}SortDir" name="sortdir" class="form-control">
                            <option value="asc"{if $sortdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                            <option value="desc"{if $sortdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
                        </select>
                    </div>
                </div>
                «IF hasAbstractStringFieldsEntity»
                    <div class="form-group«IF app.targets('3.0')» row«ENDIF»">
                        <label for="{$baseID}SearchTerm" class="«IF app.targets('3.0')»col-md-3 col-form«ELSE»col-sm-3 control«ENDIF»-label-label">{gt text='Search for'}:</label>
                        <div class="col-«IF app.targets('3.0')»md«ELSE»sm«ENDIF»-9">
                            <div class="input-group">
                                <input type="text" id="{$baseID}SearchTerm" name="q" class="form-control" />
                                <span class="input-group-btn">
                                    <input type="button" id="«app.appName.toFirstLower»SearchGo" name="gosearch" value="{gt text='Filter'}" class="btn btn-«IF app.targets('3.0')»secondary«ELSE»default«ENDIF»" />
                                </span>
                            </div>
                        </div>
                    </div>
                «ENDIF»
            </div>
            <div class="col-«IF app.targets('3.0')»md«ELSE»sm«ENDIF»-4">
                <div id="{$baseID}Preview" style="border: 1px dotted #a3a3a3; padding: .2em .5em">
                    <p><strong>{gt text='«name.formatForDisplayCapital» information'}</strong></p>
                    {img id='ajaxIndicator' modname='core' set='ajax' src='indicator_circle.gif' alt='' class='hidden'}
                    <div id="{$baseID}PreviewContainer">&nbsp;</div>
                </div>
            </div>
        </div>
    '''
}
