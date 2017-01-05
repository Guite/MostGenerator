package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    private SimpleFields fieldHelper = new SimpleFields

    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        val templateExtension = '.html.twig'
        for (entity : getAllEntities.filter[hasDisplayAction]) {
            val templatePath = getViewPath + 'External/' + entity.name.formatForCodeCapital + '/'

            fileName = 'display' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'display.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, entity.displayTemplate(it))
            }

            fileName = 'info' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'info.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, entity.itemInfoTemplate(it))
            }

            fileName = 'find' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'find.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, entity.findTemplate(it))
            }

            // content type editing is not ready for Twig yet
            fileName = 'select.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'select.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.selectTemplate(it))
            }
        }
    }

    def private displayTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display one certain «name.formatForDisplay» within an external context #}
        <div id="«name.formatForCode»{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}" class="«app.appName.toLowerCase»-external-«name.formatForDB»">
        {% if displayMode == 'link' %}
            <p«IF hasDisplayAction» class="«app.appName.toLowerCase»-external-link"«ENDIF»>
            «IF hasDisplayAction»
                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}" title="{{ «name.formatForCode».getTitleFromDisplayPattern()|e('html_attr') }}">
            «ENDIF»
            {{ «name.formatForCode».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyFilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')«ENDIF» }}
            «IF hasDisplayAction»
                </a>
            «ENDIF»
            </p>
        {% endif %}
        {% if hasPermission('«app.appName»::', '::', 'ACCESS_EDIT') %}
            {# for normal users without edit permission show only the actual file per default #}
            {% if displayMode == 'embed' %}
                <p class="«app.appName.toLowerCase»-external-title">
                    <strong>{{ «name.formatForCode».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyFilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')«ENDIF» }}</strong>
                </p>
            {% endif %}
        {% endif %}

        {% if displayMode == 'link' %}
        {% elseif displayMode == 'embed' %}
            <div class="«app.appName.toLowerCase»-external-snippet">
                «displaySnippet»
            </div>

            {# you can distinguish the context like this: #}
            {# % if source == 'contentType' %}
                ...
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
            <dd>{{ catMapping.category.display_name[lang] }}</dd>
        {% endfor %}
        </dl>
    '''

    def private itemInfoTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display item information for previewing from other modules #}
        <dl id="«name.formatForCode»{{ «name.formatForCode».«getFirstPrimaryKey.name.formatForCode» }}">
        <dt>{{ «name.formatForCode».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyFilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')«ENDIF» }}</dt>
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
        {# Purpose of this template: Display a popup selector of «nameMultiple.formatForDisplay» for scribite integration #}
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{{ app.request.locale }}" lang="{{ app.request.locale }}">
        <head>
            <title>{{ __('Search and select «name.formatForDisplay»') }}</title>
            {{ pageAddAsset('stylesheet', pagevars.homepath ~ 'style/core.css') }}
            {{ pageAddAsset('stylesheet', zasset('@«app.appName»:css/style.css')) }}
            {{ pageAddAsset('stylesheet', zasset('@«app.appName»:css/finder.css')) }}
            <script type="text/javascript">/* <![CDATA[ */
                if (typeof(Zikula) == 'undefined') {var Zikula = {};}
                Zikula.Config = {'entrypoint': '{{ getModVar('ZConfig', 'entrypoint', 'index.php') }}', 'baseURL': '{{ app.request.getSchemeAndHttpHost() ~ '/' }}', 'baseURI': '{{ app.request.getBasePath() }}'}; /* ]]> */
            </script>
            {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap.min.css')) }}
            {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap-theme.min.css')) }}
            {{ pageAddAsset('javascript', asset('jquery/jquery.min.js')) }}
            {{ pageAddAsset('javascript', asset('bootstrap/js/bootstrap.min.js')) }}
            {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».Finder.js')) }}
        </head>
        <body>
            <div class="container">
                «findTemplateObjectTypeSwitcher(app)»
                {% form_theme finderForm with [
                    '@«app.appName»/Form/bootstrap_3.html.twig',
                    'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
                ] %}
                {{ form_start(finderForm, {attr: { id: '«app.appName.toFirstLower»SelectorForm' }}) }}
                {{ form_errors(finderForm) }}
                <fieldset>
                    <legend>{{ __('Search and select «name.formatForDisplay»') }}</legend>
                    «IF categorisable»
                        {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                            {{ form_row(finderForm.categories) }}
                        {% endif %}
                    «ENDIF»
                    {{ form_row(finderForm.pasteas) }}
                    <br />
                    «findTemplateObjectId(app)»

                    {{ form_row(finderForm.sort) }}
                    {{ form_row(finderForm.sortdir) }}
                    {{ form_row(finderForm.num) }}
                    «IF hasAbstractStringFieldsEntity»
                        {{ form_row(finderForm.q) }}
                    «ENDIF»
                    <div>
                        {{ pager({ display: 'page', rowcount: pager.numitems, limit: pager.itemsperpage, posvar: 'pos', maxpages: 10, route: '«app.appName.formatForDB»_external_finder'}) }}
                    </div>
                    <div class="form-group">
                        <div class="col-sm-offset-3 col-sm-9">
                            {{ form_widget(finderForm.update) }}
                            {{ form_widget(finderForm.cancel) }}
                        </div>
                    </div>
                </fieldset>
                {{ form_end(finderForm) }}
            </div>

            «findTemplateEditForm(app)»

            {% set customJsInit %}
                «findTemplateJs(app)»
            {% endset %}
            {{ pageAddAsset('footer', customJsInit) }}
        </body>
        </html>
    '''

    def private findTemplateObjectTypeSwitcher(Entity it, Application app) '''
        «IF app.hasDisplayActions»
            <ul class="nav nav-tabs«/*pills nav-justified*/»">
            «FOR entity : app.getAllEntities.filter[hasDisplayAction]»
                <li{{ objectType == '«entity.name.formatForCode»' ? ' class="active"' : '' }}><a href="{{ path('«app.appName.formatForDB»_external_finder', {'objectType': '«entity.name.formatForCode»', 'editor': editorName}) }}" title="{{ __('Search and select «entity.name.formatForDisplay»') }}">{{ __('«entity.nameMultiple.formatForDisplayCapital»') }}</a></li>
            «ENDFOR»
            </ul>
        «ENDIF»
    '''

    def private findTemplateObjectId(Entity it, Application app) '''
        <div class="form-group">
            <label for="«app.appName.toFirstLower»ObjectId" class="col-sm-3 control-label">{{ __('«name.formatForDisplayCapital»') }}:</label>
            <div class="col-sm-9">
                <div id="«app.appName.toLowerCase»ItemContainer">
                    <ul>
                        {% for «name.formatForCode» in items %}
                            <li>
                                {% set itemId = «name.formatForCode».createCompositeIdentifier() %}
                                <a href="#" data-itemid="{{ itemId }}">{{ «name.formatForCode».getTitleFromDisplayPattern() }}</a>
                                <input type="hidden" id="url{{ itemId }}" value="{{ url('«app.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}" />
                                <input type="hidden" id="title{{ itemId }}" value="{{ «name.formatForCode».getTitleFromDisplayPattern()|e('html_attr') }}" />
                                <input type="hidden" id="desc{{ itemId }}" value="{% set description %}«displayDescription('', '')»{% endset %}{{ description|striptags|e('html_attr') }}" />
                            </li>
                        {% else %}
                            <li>{{ __('No entries found.') }}</li>
                        {% endfor %}
                    </ul>
                </div>
            </div>
        </div>
    '''

    def private findTemplateEditForm(Entity it, Application app) '''
        «IF hasEditAction»
            {#
            <div class="«app.appName.toLowerCase»-finderform">
                <fieldset>
                    {{ render(controller('«app.appName»:Admin:edit')) }}
                </fieldset>
            </div>
            #}
        «ENDIF»
    '''

    def private findTemplateJs(Entity it, Application app) '''
        <script type="text/javascript">
        /* <![CDATA[ */
            ( function($) {
                $(document).ready(function() {
                    «app.appName.toFirstLower».finder.onLoad();
                });
            })(jQuery);
        /* ]]> */
        </script>
    '''

    def private selectTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display a popup selector for Forms and Content integration *}
        {assign var='baseID' value='«name.formatForCode»'}
        <div id="{$baseID}Preview" style="float: right; width: 300px; border: 1px dotted #a3a3a3; padding: .2em .5em; margin-right: 1em">
            <p><strong>{gt text='«name.formatForDisplayCapital» information'}</strong></p>
            {img id='ajax_indicator' modname='core' set='ajax' src='indicator_circle.gif' alt='' class='hidden'}
            <div id="{$baseID}PreviewContainer">&nbsp;</div>
        </div>
        <br />
        <br />
        {assign var='leftSide' value=' style="float: left; width: 10em"'}
        {assign var='rightSide' value=' style="float: left"'}
        {assign var='break' value=' style="clear: left"'}
        «IF categorisable»

            {if $properties ne null && is_array($properties)}
                {gt text='All' assign='lblDefault'}
                {nocache}
                {foreach key='propertyName' item='propertyId' from=$properties}
                    <p>
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
                        <label for="{$baseID}_{$categorySelectorId}{$propertyName}"{$leftSide}>{$categoryLabel}:</label>
                        &nbsp;
                        {selector_category name="`$baseID`_`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«app.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize cssClass='form-control'}
                        <br{$break} />
                    </p>
                {/foreach}
                {/nocache}
            {/if}
        «ENDIF»
        <p>
            <label for="{$baseID}Id"{$leftSide}>{gt text='«name.formatForDisplayCapital»'}:</label>
            <select id="{$baseID}Id" name="id"{$rightSide}>
                {foreach item='«name.formatForCode»' from=$items}
                    <option value="{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}"{if $selectedId eq $«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»} selected="selected"{/if}>{$«name.formatForCode»->getTitleFromDisplayPattern()}</option>
                {foreachelse}
                    <option value="0">{gt text='No entries found.'}</option>
                {/foreach}
            </select>
            <br{$break} />
        </p>
        <p>
            <label for="{$baseID}Sort"{$leftSide}>{gt text='Sort by'}:</label>
            <select id="{$baseID}Sort" name="sort"{$rightSide}>
                «FOR field : getDerivedFields»
                    <option value="«field.name.formatForCode»"{if $sort eq '«field.name.formatForCode»'} selected="selected"{/if}>{gt text='«field.name.formatForDisplayCapital»'}</option>
                «ENDFOR»
                «IF standardFields»
                    <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                    <option value="createdBy"{if $sort eq 'createdBy'} selected="selected"{/if}>{gt text='Creator'}</option>
                    <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
                «ENDIF»
            </select>
            <select id="{$baseID}SortDir" name="sortdir" class="form-control">
                <option value="asc"{if $sortdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                <option value="desc"{if $sortdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
            </select>
            <br{$break} />
        </p>
        «IF hasAbstractStringFieldsEntity»
            <p>
                <label for="{$baseID}SearchTerm"{$leftSide}>{gt text='Search for'}:</label>
                <input type="text" id="{$baseID}SearchTerm" name="q" class="form-control"{$rightSide} />
                <input type="button" id="«app.appName.toFirstLower»SearchGo" name="gosearch" value="{gt text='Filter'}" class="btn btn-default" />
                <br{$break} />
            </p>
        «ENDIF»
        <br />
        <br />

        <script type="text/javascript">
        /* <![CDATA[ */
            ( function($) {
                $(document).ready(function() {
                    «app.appName.toFirstLower».itemSelector.onLoad('{{$baseID}}', {{$selectedId|default:0}});
                });
            })(jQuery);
        /* ]]> */
        </script>
    '''
}
