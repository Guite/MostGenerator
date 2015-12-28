package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExternalView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    private SimpleFields fieldHelper = new SimpleFields

    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = ''
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'
        for (entity : getAllEntities) {
            val templatePath = getViewPath + (if (targets('1.3.x')) 'external/' + entity.name.formatForCode else 'External/' + entity.name.formatForCodeCapital) + '/'

            fileName = 'display' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'display.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) entity.displayTemplateLegacy(it) else entity.displayTemplate(it))
            }

            fileName = 'info' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'info.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) entity.itemInfoTemplateLegacy(it) else entity.itemInfoTemplate(it))
            }

            fileName = 'find' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'find.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) entity.findTemplateLegacy(it) else entity.findTemplate(it))
            }

            fileName = 'select' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'select.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) entity.selectTemplateLegacy(it) else entity.selectTemplate(it))
            }
        }
    }

    def private displayTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display one certain «name.formatForDisplay» within an external context *}
        <div id="«name.formatForCode»{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}" class="«app.appName.toLowerCase»-external-«name.formatForDB»">
        {if $displayMode eq 'link'}
            <p«IF app.hasUserController» class="«app.appName.toLowerCase»-external-link"«ENDIF»>
            «IF app.hasUserController»
                <a href="{modurl modname='«app.appName»' type='user' func='display' ot='«name.formatForCode»' «routeParamsLegacy(name.formatForCode, true, true)»}" title="{$«name.formatForCode»->getTitleFromDisplayPattern()|replace:"\"":""}">
            «ENDIF»
            {$«name.formatForCode»->getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters:'«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'«ENDIF»}
            «IF app.hasUserController»
                </a>
            «ENDIF»
            </p>
        {/if}
        {checkpermissionblock component='«app.appName»::' instance='::' level='ACCESS_EDIT'}«/* TODO review whether this permission check is required here */»
            {if $displayMode eq 'embed'}
                <p class="«app.appName.toLowerCase»-external-title">
                    <strong>{$«name.formatForCode»->getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters:'«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'«ENDIF»}</strong>
                </p>
            {/if}
        {/checkpermissionblock}

        {if $displayMode eq 'link'}
        {elseif $displayMode eq 'embed'}
            <div class="«app.appName.toLowerCase»-external-snippet">
                «displaySnippet»
            </div>

            {* you can distinguish the context like this: *}
            {*if $source eq 'contentType'}
                ...
            {elseif $source eq 'scribite'}
                ...
            {/if*}
            «IF hasAbstractStringFieldsEntity || categorisable»

            {* you can enable more details about the item: *}
            {*
                <p class="«app.appName.toLowerCase»-external-description">
                    «displayDescriptionLegacy('', '<br />')»
                    «IF categorisable»
                        {assignedcategorieslist categories=$«name.formatForCode».categories doctrine2=true}
                    «ENDIF»
                </p>
            *}
            «ENDIF»
        {/if}
        </div>
    '''

    def private displayTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display one certain «name.formatForDisplay» within an external context #}
        <div id="«name.formatForCode»{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}" class="«app.appName.toLowerCase»-external-«name.formatForDB»">
        {% if displayMode == 'link' %}
            <p«IF app.hasUserController» class="«app.appName.toLowerCase»-external-link"«ENDIF»>
            «IF app.hasUserController»
                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}" title="{{ «name.formatForCode».getTitleFromDisplayPattern()|e('html_attr') }}">
            «ENDIF»
            {{ «name.formatForCode».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')«ENDIF» }}
            «IF app.hasUserController»
                </a>
            «ENDIF»
            </p>
        {% endif %}
        {% if hasPermission('«app.appName»::', '::', 'ACCESS_EDIT') %}«/* TODO review whether this permission check is required here */»
            {% if displayMode == 'embed' %}
                <p class="«app.appName.toLowerCase»-external-title">
                    <strong>{{ «name.formatForCode».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')«ENDIF» }}</strong>
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
                        «displayCategories»
                    «ENDIF»
                </p>
            #}
            «ENDIF»
        {/if}
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

    def private displayDescriptionLegacy(Entity it, String praefix, String suffix) '''
        «IF hasAbstractStringFieldsEntity»
            «IF hasTextFieldsEntity»
                {if $«name.formatForCode».«getTextFieldsEntity.head.name.formatForCode» ne ''}«praefix»{$«name.formatForCode».«getTextFieldsEntity.head.name.formatForCode»}«suffix»{/if}
            «ELSEIF hasStringFieldsEntity»
                {if $«name.formatForCode».«getStringFieldsEntity.head.name.formatForCode» ne ''}«praefix»{$«name.formatForCode».«getStringFieldsEntity.head.name.formatForCode»}«suffix»{/if}
            «ENDIF»
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

    def private itemInfoTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display item information for previewing from other modules *}
        <dl id="«name.formatForCode»{$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}">
        <dt>{$«name.formatForCode»->getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters:'«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'«ENDIF»}</dt>
        «IF hasImageFieldsEntity»
            <dd>«displaySnippet»</dd>
        «ENDIF»
        «displayDescription('<dd>', '</dd>')»
        «IF categorisable»
            <dd>{assignedcategorieslist categories=$«name.formatForCode».categories doctrine2=true}</dd>
        «ENDIF»
        </dl>
    '''

    def private itemInfoTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display item information for previewing from other modules #}
        <dl id="«name.formatForCode»{{ «name.formatForCode».«getFirstPrimaryKey.name.formatForCode» }}">
        <dt>{{ «name.formatForCode».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters('«app.name.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')«ENDIF» }}</dt>
        «IF hasImageFieldsEntity»
            <dd>«displaySnippet»</dd>
        «ENDIF»
        «displayDescription('<dd>', '</dd>')»
        «IF categorisable»
            <dd>
                «displayCategories»
            </dd>
        «ENDIF»
        </dl>
    '''

    def private findTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display a popup selector of «nameMultiple.formatForDisplay» for scribite integration *}
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{lang}" lang="{lang}">
        <head>
            <title>{gt text='Search and select «name.formatForDisplay»'}</title>
            <link type="text/css" rel="stylesheet" href="{$baseurl}style/core.css" />
            <link type="text/css" rel="stylesheet" href="{$baseurl}«app.rootFolder»/«app.appName»/style/style.css" />
            <link type="text/css" rel="stylesheet" href="{$baseurl}«app.rootFolder»/«app.appName»/style/finder.css" />
            {assign var='ourEntry' value=$modvars.ZConfig.entrypoint}
            <script type="text/javascript">/* <![CDATA[ */
                if (typeof(Zikula) == 'undefined') {var Zikula = {};}
                Zikula.Config = {'entrypoint': '{{$ourEntry|default:'index.php'}}', 'baseURL': '{{$baseurl}}'}; /* ]]> */
            </script>
            <script type="text/javascript" src="{$baseurl}javascript/ajax/proto_scriptaculous.combined.min.js"></script>
            <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.js"></script>
            <script type="text/javascript" src="{$baseurl}javascript/livepipe/livepipe.combined.min.js"></script>
            <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.UI.js"></script>
            <script type="text/javascript" src="{$baseurl}javascript/helpers/Zikula.ImageViewer.js"></script>
            <script type="text/javascript" src="{$baseurl}«app.rootFolder»/«app.appName»/javascript/«app.appName»_finder.js"></script>
            {if $editorName eq 'tinymce'}
                <script type="text/javascript" src="{$baseurl}modules/Scribite/includes/tinymce/tiny_mce_popup.js"></script>
            {/if}
        </head>
        <body>
            «findTemplateObjectTypeSwitcher(app)»
            <form action="{$ourEntry|default:'index.php'}" id="«app.appName.toFirstLower»SelectorForm" method="get" class="z-form">
            <div>
                <input type="hidden" name="module" value="«app.appName»" />
                <input type="hidden" name="type" value="external" />
                <input type="hidden" name="func" value="finder" />
                <input type="hidden" name="objectType" value="{$objectType}" />
                <input type="hidden" name="editor" id="editorName" value="{$editorName}" />

                <fieldset>
                    <legend>{gt text='Search and select «name.formatForDisplay»'}</legend>
                    «findTemplateCategories(app)»

                    «findTemplatePasteAs(app)»
                    <br />

                    «findTemplateObjectId(app)»

                    «findTemplateSorting(app)»

                    «findTemplatePageSize(app)»

                    «findTemplateSearch(app)»
                    <div style="margin-left: 6em">
                        {pager display='page' rowcount=$pager.numitems limit=$pager.itemsperpage posvar='pos' template='pagercss.tpl' maxpages='10'}
                    </div>
                    <input type="submit" id="«app.appName.toFirstLower»Submit" name="submitButton" value="{gt text='Change selection'}" />
                    <input type="button" id="«app.appName.toFirstLower»Cancel" name="cancelButton" value="{gt text='Cancel'}" />
                    <br />
                </fieldset>
            </div>
            </form>

            «findTemplateJs(app)»

            «findTemplateEditForm(app)»
        </body>
        </html>
    '''

    def private findTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display a popup selector of «nameMultiple.formatForDisplay» for scribite integration #}
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{{ lang() }}" lang="{{ lang() }}">
        <head>
            <title>{{ __('Search and select «name.formatForDisplay»') }}</title>
            <link type="text/css" rel="stylesheet" href="{{ zasset('style/core.css') }}" />
            <link type="text/css" rel="stylesheet" href="{{ zasset('@«app.appName»:css/style.css') }}" />
            <link type="text/css" rel="stylesheet" href="{{ zasset('@«app.appName»:css/finder.css') }}" />
            {% set ourEntry = getModVar('ZConfig', 'entrypoint', 'index.php') %}
            <script type="text/javascript">/* <![CDATA[ */
                if (typeof(Zikula) == 'undefined') {var Zikula = {};}
                Zikula.Config = {'entrypoint': '{{ ourEntry }}', 'baseURL': '{{ pageGetVar('homepath') }}'}; /* ]]> */
            </script>
            <link rel="stylesheet" href="web/bootstrap/css/bootstrap.min.css" type="text/css" />
            <link rel="stylesheet" href="web/bootstrap/css/bootstrap-theme.css" type="text/css" />
            <script type="text/javascript" src="web/jquery/jquery.min.js"></script>
            <script type="text/javascript" src="web/bootstrap/js/bootstrap.min.js"></script>
            <script type="text/javascript" src="{{ zasset('@«app.appName»:js/«app.appName».Finder.js') }}"></script>
        </head>
        <body>
        <div class="container">
            «findTemplateObjectTypeSwitcher(app)»
            <form action="{{ ourEntry }}" id="«app.appName.toFirstLower»SelectorForm" method="get" class="form{# -horizontal #}" role="form">
            <div>
                <input type="hidden" name="module" value="«app.appName»" />
                <input type="hidden" name="type" value="external" />
                <input type="hidden" name="func" value="finder" />
                <input type="hidden" name="objectType" value="{{ objectType }}" />
                <input type="hidden" name="editor" id="editorName" value="{{ editorName }}" />

                <fieldset>
                    <legend>{{ __('Search and select «name.formatForDisplay»') }}</legend>
                    «findTemplateCategories(app)»

                    «findTemplatePasteAs(app)»
                    <br />

                    «findTemplateObjectId(app)»

                    «findTemplateSorting(app)»

                    «findTemplatePageSize(app)»

                    «findTemplateSearch(app)»
                    <div>
                        {{ pager({ display: 'page', rowcount: pager.numitems, limit: pager.itemsperpage, posvar: 'pos', maxpages: 10, route: '«app.appName.formatForDB»_external_finder'}) }}
                    </div>
                    <input type="submit" id="«app.appName.toFirstLower»Submit" name="submitButton" value="{{ __('Change selection') }}" class="btn btn-success" />
                    <input type="button" id="«app.appName.toFirstLower»Cancel" name="cancelButton" value="{{ __('Cancel') }}" class="btn btn-default" />
                    <br />
                </fieldset>
            </div>
            </form>
        </div>

            «findTemplateJs(app)»

            «findTemplateEditForm(app)»
        </body>
        </html>
    '''

    def private findTemplateObjectTypeSwitcher(Entity it, Application app) '''
        «IF app.getAllEntities.size > 1»
            «IF app.targets('1.3.x')»
                <p>{gt text='Switch to'}:
                «FOR entity : app.getAllEntities.filter[e|e.name != name] SEPARATOR ' | '»
                    <a href="{modurl modname='«app.appName»' type='external' func='finder' objectType='«entity.name.formatForCode»' editor=$editorName}" title="{gt text='Search and select «entity.name.formatForDisplay»'}">{gt text='«entity.nameMultiple.formatForDisplayCapital»'}</a>
                «ENDFOR»
                </p>
            «ELSE»
                <ul class="nav nav-pills nav-justified">
                «FOR entity : app.getAllEntities.filter[e|e.name != name] SEPARATOR ' | '»
                    <li{% if objectType == '«entity.name.formatForCode»' %} class="active"{% endif %}><a href="{{ path('«app.appName.formatForDB»_external_finder', {'objectType': '«entity.name.formatForCode»', 'editor': editorName}) }}" title="{{ __('Search and select «entity.name.formatForDisplay»') }}">{{ __('«entity.nameMultiple.formatForDisplayCapital»') }}</a></li>
                «ENDFOR»
                </ul>
            «ENDIF»
        «ENDIF»
    '''

    def private findTemplateCategories(Entity it, Application app) '''
        «IF categorisable»

            «IF app.targets('1.3.x')»
                {if $properties ne null && is_array($properties)}
                    {gt text='All' assign='lblDefault'}
                    {nocache}
                    {foreach key='propertyName' item='propertyId' from=$properties}
                        <div class="z-formrow category-selector">
                            {modapifunc modname='«app.appName»' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
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
                            <label for="{$categorySelectorId}{$propertyName}">{$categoryLabel}</label>
                            &nbsp;
                            {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«app.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}
                            <span class="z-sub z-formnote">{gt text='This is an optional filter.'}</span>
                        </div>
                    {/foreach}
                    {/nocache}
                {/if}
            «ELSE»
                {% if properties is not null and properties is iterable %}
                    {% set lblDefault = __('All') %}
                    {% for propertyName, propertyId in properties %}
                        <div class="form-group category-selector">
                            {% set hasMultiSelection = «app.appName.formatForDB»_isCategoryMultiValued(objectType, propertyName) %}
                            {% set categoryLabel = __('Category') %}
                            {% set categorySelectorId = 'catid' %}
                            {% set categorySelectorName = 'catid' %}
                            {% set categorySelectorSize = 1 %}
                            {% if hasMultiSelection == true %}
                                {% set categoryLabel = __('Categories') %}
                                {% set categorySelectorName = 'catids' %}
                                {% set categorySelectorId = 'catids__ %}
                                {% set categorySelectorSize = 8 %}
                            {% endif %}
                            <label for="{{ categorySelectorId ~ propertyName }}" class="col-sm-3 control-label">{{ categoryLabel }}</label>
                            <div class="col-sm-9">
                                «/* TODO migrate to Symfony forms #416 */»
                                {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«app.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize cssClass='form-control'}
                                <span class="help-block">{{ __('This is an optional filter.') }}</span>
                            </div>
                        </div>
                    {/foreach}
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def private findTemplatePasteAs(Entity it, Application app) '''
        <div class="«IF app.targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«app.appName.toFirstLower»PasteAs"«IF !app.targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF app.targets('1.3.x')»{gt text='Paste as'}«ELSE»{{ __('Paste as') }}«ENDIF»:</label>
            «IF !app.targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <select id="«app.appName.toFirstLower»PasteAs" name="pasteas"«IF !app.targets('1.3.x')» class="form-control"«ENDIF»>
                    «IF app.targets('1.3.x')»
                        <option value="1">{gt text='Link to the «name.formatForDisplay»'}</option>
                        <option value="2">{gt text='ID of «name.formatForDisplay»'}</option>
                    «ELSE»
                        <option value="1">{{ __('Link to the «name.formatForDisplay»') }}</option>
                        <option value="2">{{ __('ID of «name.formatForDisplay»') }}</option>
                    «ENDIF»
                </select>
            «IF !app.targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private findTemplateObjectId(Entity it, Application app) '''
        <div class="«IF app.targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«app.appName.toFirstLower»ObjectId"«IF !app.targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF app.targets('1.3.x')»{gt text='«name.formatForDisplayCapital»'}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»:</label>
            «IF !app.targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <div id="«app.appName.toLowerCase»ItemContainer">
                    <ul>
                    «IF app.targets('1.3.x')»
                        {foreach item='«name.formatForCode»' from=$items}
                            <li>
                                {assign var='itemId' value=$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}
                                <a href="#" onclick="«app.appName.toFirstLower».finder.selectItem({$itemId})" onkeypress="«app.appName.toFirstLower».finder.selectItem({$itemId})">{$«name.formatForCode»->getTitleFromDisplayPattern()}</a>
                                <input type="hidden" id="url{$itemId}" value="«IF app.hasUserController»{modurl modname='«app.appName»' type='user' func='display' ot='«name.formatForCode»' «routeParamsLegacy(name.formatForCode, true, true)» fqurl=true}«ENDIF»" />
                                <input type="hidden" id="title{$itemId}" value="{$«name.formatForCode»->getTitleFromDisplayPattern()|replace:"\"":""}" />
                                <input type="hidden" id="desc{$itemId}" value="{capture assign='description'}«displayDescription('', '')»{/capture}{$description|strip_tags|replace:"\"":""}" />
                            </li>
                        {foreachelse}
                            <li>{gt text='No entries found.'}</li>
                        {/foreach}
                    «ELSE»
                        {% for «name.formatForCode» in items %}
                            <li>
                                {% set itemId = «name.formatForCode».«getFirstPrimaryKey.name.formatForCode» }}
                                <a href="#" onclick="«app.appName.toFirstLower».finder.selectItem({{ itemId }})" onkeypress="«app.appName.toFirstLower».finder.selectItem({{ itemId }})">{{ «name.formatForCode»->getTitleFromDisplayPattern() }}</a>
                                <input type="hidden" id="url{{ itemId }}" value="«IF app.hasUserController»{{ url('«app.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}«ENDIF»" />
                                <input type="hidden" id="title{{ itemId }}" value="{{ «name.formatForCode».getTitleFromDisplayPattern()|e('html_attr') }}" />
                                <input type="hidden" id="desc{{ itemId }}" value="{% set description %}«displayDescription('', '')»{% endset %}{{ description|striptags|e('html_attr') }}" />
                            </li>
                        {% else %}
                            <li>{{ __('No entries found.') }}</li>
                        {% endfor %}
                    «ENDIF»
                    </ul>
                </div>
            «IF !app.targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private findTemplateSorting(Entity it, Application app) '''
        <div class="«IF app.targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«app.appName.toFirstLower»Sort"«IF !app.targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF app.targets('1.3.x')»{gt text='Sort by'}«ELSE»{{ __('Sort by') }}«ENDIF»:</label>
            «IF !app.targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <select id="«app.appName.toFirstLower»Sort" name="sort" class="«IF app.targets('1.3.x')»z-floatleft«ELSE»form-control pull-left«ENDIF»" style="width: 1«IF app.targets('1.3.x')»0«ELSE»5«ENDIF»0px; margin-right: 10px">
                «IF app.targets('1.3.x')»
                    «FOR field : getDerivedFields»
                        <option value="«field.name.formatForCode»"{if $sort eq '«field.name.formatForCode»'} selected="selected"{/if}>{gt text='«field.name.formatForDisplayCapital»'}</option>
                    «ENDFOR»
                    «IF standardFields»
                        <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                        <option value="createdUserId"{if $sort eq 'createdUserId'} selected="selected"{/if}>{gt text='Creator'}</option>
                        <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
                    «ENDIF»
                    </select>
                    <select id="«app.appName.toFirstLower»SortDir" name="sortdir" style="width: 100px">
                        <option value="asc"{if $sortdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                        <option value="desc"{if $sortdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
                    </select>
                «ELSE»
                    «FOR field : getDerivedFields»
                        <option value="«field.name.formatForCode»"{{ sort == '«field.name.formatForCode»' ? ' selected="selected"' : '' }}>{{ __('«field.name.formatForDisplayCapital»') }}</option>
                    «ENDFOR»
                    «IF standardFields»
                        <option value="createdDate"{{ sort == 'createdDate' ? ' selected="selected"' : '' }}>{{ __('Creation date') }}</option>
                        <option value="createdUserId"{{ sort == 'createdUserId' ? ' selected="selected"' : '' }}>{{ __('Creator') }}</option>
                        <option value="updatedDate"{{ sort == 'updatedDate' ? ' selected="selected"' : '' }}>{{ __('Update date') }}</option>
                    «ENDIF»
                    </select>
                    <select id="«app.appName.toFirstLower»SortDir" name="sortdir" class="form-control" style="width: 150px">
                        <option value="asc"{{ sortdir == 'asc' ? ' selected="selected"' : '' }}>{{ __('ascending') }}</option>
                        <option value="desc"{{ sortdir == 'desc' ? ' selected="selected"' : '' }}>{{ __('descending') }}</option>
                    </select>
                «ENDIF»
            «IF !app.targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private findTemplatePageSize(Entity it, Application app) '''
        <div class="«IF app.targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«app.appName.toFirstLower»PageSize"«IF !app.targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF app.targets('1.3.x')»{gt text='Page size'}«ELSE»{{ __('Page size') }}«ENDIF»:</label>
            «IF !app.targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <select id="«app.appName.toFirstLower»PageSize" name="num"«IF app.targets('1.3.x')» style="width: 50px; text-align: right"«ELSE» class="form-control text-right" style="width: 100px"«ENDIF»>
                    «IF app.targets('1.3.x')»
                        <option value="5"{if $pager.itemsperpage eq 5} selected="selected"{/if}>5</option>
                        <option value="10"{if $pager.itemsperpage eq 10} selected="selected"{/if}>10</option>
                        <option value="15"{if $pager.itemsperpage eq 15} selected="selected"{/if}>15</option>
                        <option value="20"{if $pager.itemsperpage eq 20} selected="selected"{/if}>20</option>
                        <option value="30"{if $pager.itemsperpage eq 30} selected="selected"{/if}>30</option>
                        <option value="50"{if $pager.itemsperpage eq 50} selected="selected"{/if}>50</option>
                        <option value="100"{if $pager.itemsperpage eq 100} selected="selected"{/if}>100</option>
                    «ELSE»
                        <option value="5"{{ pager.itemsperpage == 5 ? ' selected="selected"' : '' }}>5</option>
                        <option value="10"{{ pager.itemsperpage == 10 ? ' selected="selected"' : '' }}>10</option>
                        <option value="15"{{ pager.itemsperpage == 15 ? ' selected="selected"' : '' }}>15</option>
                        <option value="20"{{ pager.itemsperpage == 20 ? ' selected="selected"' : '' }}>20</option>
                        <option value="30"{{ pager.itemsperpage == 30 ? ' selected="selected"' : '' }}>30</option>
                        <option value="50"{{ pager.itemsperpage == 50 ? ' selected="selected"' : '' }}>50</option>
                        <option value="100"{{ pager.itemsperpage == 100 ? ' selected="selected"' : '' }}>100</option>
                    «ENDIF»
                </select>
            «IF !app.targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private findTemplateSearch(Entity it, Application app) '''
        «IF hasAbstractStringFieldsEntity»
            <div class="«IF app.targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
                <label for="«app.appName.toFirstLower»SearchTerm"«IF !app.targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF app.targets('1.3.x')»{gt text='Search for'}«ELSE»{{ __('Search for') }}«ENDIF»:</label>
            «IF !app.targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                    <input type="text" id="«app.appName.toFirstLower»SearchTerm" name="q" class="«IF app.targets('1.3.x')»z-floatleft«ELSE»form-control pull-left«ENDIF»" style="width: 150px; margin-right: 10px" />
                    <input type="button" id="«app.appName.toFirstLower»SearchGo" name="gosearch" value="«IF app.targets('1.3.x')»{gt text='Filter'}«ELSE»{{ __('Filter') }}«ENDIF»" style="width: 80px"«IF !app.targets('1.3.x')» class="btn btn-default"«ENDIF» />
            «IF !app.targets('1.3.x')»
                </div>
            «ENDIF»
            </div>

        «ENDIF»
    '''

    def private findTemplateJs(Entity it, Application app) '''
        <script type="text/javascript">
        /* <![CDATA[ */
            «IF app.targets('1.3.x')»
                document.observe('dom:loaded', function() {
                    «app.appName.toFirstLower».finder.onLoad();
                });
            «ELSE»
                ( function($) {
                    $(document).ready(function() {
                        «app.appName.toFirstLower».finder.onLoad();
                    });
                })(jQuery);
            «ENDIF»
        /* ]]> */
        </script>
    '''

    def private findTemplateEditForm(Entity it, Application app) '''
        «IF !app.getAllAdminControllers.empty»
            {«IF app.targets('1.3.x')»*«ELSE»#«ENDIF»
            <div class="«app.appName.toLowerCase»-finderform">
                <fieldset>
                    «IF app.targets('1.3.x')»
                        {modfunc modname='«app.appName»' type='admin' func='edit'}
                    «ELSE»
                        {{ render(controller('«app.appName»:Admin:edit')) }}
                    «ENDIF»
                </fieldset>
            </div>
            «IF app.targets('1.3.x')»*«ELSE»#«ENDIF»}
        «ENDIF»
    '''

    def private selectTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display a popup selector for Forms and Content integration *}
        {assign var='baseID' value='«name.formatForCode»'}
        <div id="{$baseID}Preview" style="float: right; width: 300px; border: 1px dotted #a3a3a3; padding: .2em .5em; margin-right: 1em">
            <p><strong>{gt text='«name.formatForDisplayCapital» information'}</strong></p>
            {img id='ajax_indicator' modname='core' set='ajax' src='indicator_circle.gif' alt='' class='z-hide'}
            <div id="{$baseID}PreviewContainer">&nbsp;</div>
        </div>
        <br />
        <br />
        {assign var='leftSide' value=' style="float: left; width: 10em"'}
        {assign var='rightSide' value=' style="float: left"'}
        {assign var='breakStyle' value=' style="clear: left"'}
        «IF categorisable»

            {if $properties ne null && is_array($properties)}
                {gt text='All' assign='lblDefault'}
                {nocache}
                {foreach key='propertyName' item='propertyId' from=$properties}
                    <p>
                        {modapifunc modname='«app.appName»' type='category' func='hasMultipleSelection' ot='«name.formatForCode»' registry=$propertyName assign='hasMultiSelection'}
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
                        {selector_category name="`$baseID`_`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«app.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}
                        <br{$breakStyle} />
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
            <br{$breakStyle} />
        </p>
        <p>
            <label for="{$baseID}Sort"{$leftSide}>{gt text='Sort by'}:</label>
            <select id="{$baseID}Sort" name="sort"{$rightSide}>
                «FOR field : getDerivedFields»
                    <option value="«field.name.formatForCode»"{if $sort eq '«field.name.formatForCode»'} selected="selected"{/if}>{gt text='«field.name.formatForDisplayCapital»'}</option>
                «ENDFOR»
                «IF standardFields»
                    <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                    <option value="createdUserId"{if $sort eq 'createdUserId'} selected="selected"{/if}>{gt text='Creator'}</option>
                    <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
                «ENDIF»
            </select>
            <select id="{$baseID}SortDir" name="sortdir">
                <option value="asc"{if $sortdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                <option value="desc"{if $sortdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
            </select>
            <br{$breakStyle} />
        </p>
        «IF hasAbstractStringFieldsEntity»
            <p>
                <label for="{$baseID}SearchTerm"{$leftSide}>{gt text='Search for'}:</label>
                <input type="text" id="{$baseID}SearchTerm" name="q"{$rightSide} />
                <input type="button" id="«app.appName.toFirstLower»SearchGo" name="gosearch" value="{gt text='Filter'}" />
                <br{$breakStyle} />
            </p>
        «ENDIF»
        <br />
        <br />

        <script type="text/javascript">
        /* <![CDATA[ */
            document.observe('dom:loaded', function() {
                «app.appName.toFirstLower».itemSelector.onLoad('{{$baseID}}', {{$selectedId|default:0}});
            });
        /* ]]> */
        </script>
    '''

    def private selectTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display a popup selector for Forms and Content integration #}
        {% set baseID = '«name.formatForCode»' %}
        <div id="{{ baseID }}Preview" style="float: right; width: 300px; border: 1px dotted #a3a3a3; padding: .2em .5em; margin-right: 1em">
            <p><strong>{{ __('«name.formatForDisplayCapital» information') }}</strong></p>
            <img id="ajax_indicator" src="{{ zasset('images/ajax/indicator_circle.gif') }}" alt="" width="16" height="16" class="hidden" />
            <div id="{{ baseID }}PreviewContainer">&nbsp;</div>
        </div>
        <br />
        <br />
        {% set leftSide = ' style="float: left; width: 10em"' %}
        {% set rightSide = ' style="float: left"' %}
        {% set breakStyle = ' style="clear: left"' %}
        «IF categorisable»

            {% if properties is not null and properties is iterable %}
                {% set lblDefault = __('All') %}
                {% for propertyName, propertyId in properties %}
                    <p>
                        {% set hasMultiSelection = «app.appName.formatForDB»_isCategoryMultiValued('«name.formatForCode»', propertyName) %}
                        {% set categoryLabel = __('Category') %}
                        {% set categorySelectorId = 'catid' %}
                        {% set categorySelectorName = 'catid' %}
                        {% set categorySelectorSize = 1 %}
                        {% if hasMultiSelection == true %}
                            {% set categoryLabel = __('Categories') %}
                            {% set categorySelectorName = 'catids' %}
                            {% set categorySelectorId = 'catids__ %}
                            {% set categorySelectorSize = 8 %}
                        {% endif %}
                        <label for="{{ baseID ~ '_' ~ categorySelectorId ~ propertyName }}"{{ leftSide }}>{{ categoryLabel }}:</label>
                        &nbsp;
                        «/* TODO migrate to Symfony forms #416 */»
                        {# selector_category name="`$baseID`_`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«app.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize cssClass='form-control' #}
                        <br{{ breakStyle }} />
                    </p>
                {% endfor %}
            {% endif %}
        «ENDIF»
        <p>
            <label for="{{ baseID }}Id"{{ leftSide }}>{{ __('«name.formatForDisplayCapital»') }}:</label>
            <select id="{{ baseID }}Id" name="id"{{ rightSide }}>
                {% for «name.formatForCode» in items %}
                    <option value="{{ «name.formatForCode».«getFirstPrimaryKey.name.formatForCode» }}"{% if selectedId == «name.formatForCode».«getFirstPrimaryKey.name.formatForCode» %} selected="selected"{% endif %}>{{ «name.formatForCode».getTitleFromDisplayPattern() }}</option>
                {% else %}
                    <option value="0">{{ __('No entries found.') }}</option>
                {% endfor %}
            </select>
            <br{{ breakStyle }} />
        </p>
        <p>
            <label for="{{ baseID }}Sort"{{ leftSide }}>{{ __('Sort by') }}:</label>
            <select id="{{ baseID }}Sort" name="sort"{{ rightSide }}>
                «FOR field : getDerivedFields»
                    <option value="«field.name.formatForCode»"{% if sort == '«field.name.formatForCode»' %} selected="selected"{% endif %}>{{ __('«field.name.formatForDisplayCapital»') }}</option>
                «ENDFOR»
                «IF standardFields»
                    <option value="createdDate"{{ sort == 'createdDate' ? ' selected="selected"' : '' }}>{{ __('Creation date') }}</option>
                    <option value="createdUserId"{{ sort == 'createdUserId' ? ' selected="selected"' : '' }}>{{ __('Creator') }}</option>
                    <option value="updatedDate"{{ sort == 'updatedDate' ? ' selected="selected"' : '' }}>{{ __('Update date') }}</option>
                «ENDIF»
            </select>
            <select id="{{ baseID }}SortDir" name="sortdir" class="form-control">
                <option value="asc"{{ sortdir == 'asc' ? ' selected="selected"' : '' }}>{{ __('ascending') }}</option>
                <option value="desc"{{ sortdir == 'desc' ? ' selected="selected"' : '' }}>{{ __('descending') }}</option>
            </select>
            <br{{ breakStyle }} />
        </p>
        «IF hasAbstractStringFieldsEntity»
            <p>
                <label for="{{ baseID }}SearchTerm"{{ leftSide }}>{{ __('Search for') }}:</label>
                <input type="text" id="{{ baseID }}SearchTerm" name="q" class="form-control"{{ rightSide }} />
                <input type="button" id="«app.appName.toFirstLower»SearchGo" name="gosearch" value="{{ __('Filter') }}" class="btn btn-default" />
                <br{{ breakStyle }} />
            </p>
        «ENDIF»
        <br />
        <br />

        <script type="text/javascript">
        /* <![CDATA[ */
            ( function($) {
                $(document).ready(function() {
                    «app.appName.toFirstLower».itemSelector.onLoad('{{ baseID }}', {{ selectedId|default(0) }});
                });
            })(jQuery);
        /* ]]> */
        </script>
    '''
}
