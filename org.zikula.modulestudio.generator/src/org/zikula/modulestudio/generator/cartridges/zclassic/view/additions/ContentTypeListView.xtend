package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeListView {
    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.x')) 'contenttype' else 'ContentType') + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'
        var fileName = ''
        for (entity : getAllEntities) {
            fileName = 'itemlist_' + entity.name.formatForCode + '_display_description' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'itemlist_' + entity.name.formatForCode + '_display_description.generated' + templateExtension 
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) entity.displayDescTemplateLegacy(it) else entity.displayDescTemplate(it))
            }
            fileName = 'itemlist_' + entity.name.formatForCode + '_display' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'itemlist_' + entity.name.formatForCode + '_display.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) entity.displayTemplateLegacy(it) else entity.displayTemplate(it))
            }
        }
        fileName = 'itemlist_display' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_display.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, fallbackDisplayTemplate)
        }
        fileName = 'itemlist_edit' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_edit.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    def private displayDescTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context *}
        <dl>
            {foreach item='«name.formatForCode»' from=$items}
                <dt>{$«name.formatForCode»->getTitleFromDisplayPattern()}</dt>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty»
                    {if $«name.formatForCode».«textFields.head.name.formatForCode»}
                        <dd>{$«name.formatForCode».«textFields.head.name.formatForCode»|strip_tags|truncate:200:'&hellip;'}</dd>
                    {/if}
                «ELSE»
                    «val stringFields = fields.filter(StringField).filter[!password]»
                    «IF !stringFields.empty»
                        {if $«name.formatForCode».«stringFields.head.name.formatForCode»}
                            <dd>{$«name.formatForCode».«stringFields.head.name.formatForCode»|strip_tags|truncate:200:'&hellip;'}</dd>
                        {/if}
                    «ENDIF»
                «ENDIF»
                <dd>«detailLink(app.appName)»</dd>
            {foreachelse}
                <dt>{gt text='No entries found.'}</dt>
            {/foreach}
        </dl>
    '''

    def private displayDescTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context #}
        <dl>
            {% for «name.formatForCode» in items %}
                <dt>{{ «name.formatForCode».getTitleFromDisplayPattern() }}</dt>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty»
                    {% if «name.formatForCode».«textFields.head.name.formatForCode» %}
                        <dd>{{ «name.formatForCode».«textFields.head.name.formatForCode»|striptags|truncate(200, true, '&hellip;') }}</dd>
                    {% endif %}
                «ELSE»
                    «val stringFields = fields.filter(StringField).filter[!password]»
                    «IF !stringFields.empty»
                        {% if «name.formatForCode».«stringFields.head.name.formatForCode» %}
                            <dd>{{ «name.formatForCode».«stringFields.head.name.formatForCode»|striptags|truncate(200, true, '&hellip;') }}</dd>
                        {% endif %}
                    «ENDIF»
                «ENDIF»
                <dd>«detailLink(app.appName)»</dd>
            {% else %}
                <dt>{{ __('No entries found.') }}</dt>
            {% endfor %}
        </dl>
    '''

    def private displayTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context *}
        {foreach item='«name.formatForCode»' from=$items}
            <h3>{$«name.formatForCode»->getTitleFromDisplayPattern()}</h3>
            «IF app.hasUserController && app.getMainUserController.hasActions('display')»
                <p>«detailLink(app.appName)»</p>
            «ENDIF»
        {/foreach}
    '''

    def private displayTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context #}
        {% for «name.formatForCode» in items %}
            <h3>{{ «name.formatForCode».getTitleFromDisplayPattern() }}</h3>
            «IF app.hasUserController && app.getMainUserController.hasActions('display')»
                <p>«detailLink(app.appName)»</p>
            «ENDIF»
        {% endfor %}
    '''

    def private fallbackDisplayTemplate(Application it) '''
        «IF targets('1.3.x')»
            {* Purpose of this template: Display objects within an external context *}
        «ELSE»
            {# Purpose of this template: Display objects within an external context #}
        «ENDIF»
    '''

    def private editTemplate(Application it) '''
        «IF targets('1.3.x')»
            {* Purpose of this template: edit view of generic item list content type *}
        «ELSE»
            {# Purpose of this template: edit view of generic item list content type #}
        «ENDIF»
        «/* TODO migrate to Symfony forms #416 */»
        «editTemplateObjectType»

        «editTemplateCategories»

        «editTemplateSorting»

        «editTemplateAmount»

        «editTemplateTemplate»

        «editTemplateFilter»

        «editTemplateJs»
    '''

    def private editTemplateObjectType(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            «IF targets('1.3.x')»
                {gt text='Object type' domain='module_«appName.formatForDB»' assign='objectTypeSelectorLabel'}
            «ELSE»
                {% set objectTypeSelectorLabel = __('Object type', '«appName.formatForDB»') %}
            «ENDIF»
            {formlabel for='«appName.toFirstLower»ObjectType' text=$objectTypeSelectorLabel«IF !targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
            «IF targets('1.3.x')»
                {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
            «ELSE»
                {% set allObjectTypes = «appName.formatForDB»_objectTypeSelector() %}
            «ENDIF»
                {formdropdownlist id='«appName.toFirstLower»OjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypes«IF !targets('1.3.x')» cssClass='form-control'«ENDIF»}
                <span class="«IF targets('1.3.x')»z-sub z-formnote«ELSE»help-block«ENDIF»">«IF targets('1.3.x')»{gt text='If you change this please save the element once to reload the parameters below.' domain='module_«appName.formatForDB»'}«ELSE»{{ __('If you change this please save the element once to reload the parameters below.', '«appName.formatForDB»') }}«ENDIF»</span>
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateCategories(Application it) '''
        «IF targets('1.3.x')»
            {formvolatile}
            {if $properties ne null && is_array($properties)}
                {nocache}
                {foreach key='registryId' item='registryCid' from=$registries}
                    {assign var='propName' value=''}
                    {foreach key='propertyName' item='propertyId' from=$properties}
                        {if $propertyId eq $registryId}
                            {assign var='propName' value=$propertyName}
                        {/if}
                    {/foreach}
                    <div class="z-formrow">
                        {modapifunc modname='«appName»' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                        {gt text='Category' domain='module_«appName.formatForDB»' assign='categorySelectorLabel'}
                        {assign var='selectionMode' value='single'}
                        {if $hasMultiSelection eq true}
                            {gt text='Categories' domain='module_«appName.formatForDB»' assign='categorySelectorLabel'}
                            {assign var='selectionMode' value='multiple'}
                        {/if}
                        {formlabel for="«appName.toFirstLower»CatIds`$propertyName`" text=$categorySelectorLabel}
                        {formdropdownlist id="«appName.toFirstLower»CatIds`$propName`" items=$categories.$propName dataField="catids`$propName`" group='data' selectionMode=$selectionMode«IF !targets('1.3.x')» cssClass='form-control'«ENDIF»}
                        <span class="z-sub z-formnote">{gt text='This is an optional filter.' domain='module_«appName.formatForDB»'}</span>
                    </div>
                {/foreach}
                {/nocache}
            {/if}
            {/formvolatile}
        «ELSE»
            {% if properties is not null and properties is iterable %}
                {% for registryId, registryCid in registries %}
                    {% set propName = '' %}
                    {% for propertyName, propertyId in properties %}
                        {% if propertyId == registryId %}
                            {% set propName = propertyName %}
                        {% endif %}
                    {% endfor %}
                    <div class="form-group">
                        {% set hasMultiSelection = «appName.formatForDB»_isCategoryMultiValued(objectType, propertyName) %}
                        {% set categorySelectorLabel = __('Category', '«appName.formatForDB»') %}
                        {% set selectionMode = 'single' %}
                        {% if hasMultiSelection == true %}
                            {% set categorySelectorLabel = __('Categories', '«appName.formatForDB»') %}
                            {% set selectionMode = 'multiple' %}
                        {% endif %}
                        {formlabel for="«appName.toFirstLower»CatIds`$propertyName`" text=$categorySelectorLabel cssClass='col-sm-3 control-label'}
                        <div class="col-sm-9">
                            {formdropdownlist id="«appName.toFirstLower»CatIds`$propName`" items=$categories.$propName dataField="catids`$propName`" group='data' selectionMode=$selectionMode«IF !targets('1.3.x')» cssClass='form-control'«ENDIF»}
                            <span class="help-block">{{ __('This is an optional filter.', '«appName.formatForDB»') }}</span>
                        </div>
                    </div>
                {% endfor %}
            {% endif %}
        «ENDIF»
    '''

    def private editTemplateSorting(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            «IF targets('1.3.x')»
                {gt text='Sorting' domain='module_«appName.formatForDB»' assign='sortingLabel'}
            «ELSE»
                {% set sortingLabel = __('Sorting', '«appName.formatForDB»') %}
            «ENDIF»
            {formlabel text=$sortingLabel«IF !targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
            <div«IF !targets('1.3.x')» class="col-sm-9"«ENDIF»>
                {formradiobutton id='«appName.toFirstLower»SortRandom' value='random' dataField='sorting' group='data' mandatory=true}
                «IF targets('1.3.x')»
                    {gt text='Random' domain='module_«appName.formatForDB»' assign='sortingRandomLabel'}
                «ELSE»
                    {% set sortingRandomLabel = __('Random', '«appName.formatForDB»') %}
                «ENDIF»
                {formlabel for='«appName.toFirstLower»SortRandom' text=$sortingRandomLabel}
                {formradiobutton id='«appName.toFirstLower»SortNewest' value='newest' dataField='sorting' group='data' mandatory=true}
                «IF targets('1.3.x')»
                    {gt text='Newest' domain='module_«appName.formatForDB»' assign='sortingNewestLabel'}
                «ELSE»
                    {% set sortingNewestLabel = __('Newest', '«appName.formatForDB»') %}
                «ENDIF»
                {formlabel for='«appName.toFirstLower»SortNewest' text=$sortingNewestLabel}
                {formradiobutton id='«appName.toFirstLower»SortDefault' value='default' dataField='sorting' group='data' mandatory=true}
                «IF targets('1.3.x')»
                    {gt text='Default' domain='module_«appName.formatForDB»' assign='sortingDefaultLabel'}
                «ELSE»
                    {% set sortingDefaultLabel = __('Default', '«appName.formatForDB»') %}
                «ENDIF»
                {formlabel for='«appName.toFirstLower»SortDefault' text=$sortingDefaultLabel}
            </div>
        </div>
    '''

    def private editTemplateAmount(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            «IF targets('1.3.x')»
                {gt text='Amount' domain='module_«appName.formatForDB»' assign='amountLabel'}
            «ELSE»
                {% set amountLabel = __('Amount', '«appName.formatForDB»') %}
            «ENDIF»
            {formlabel for='«appName.toFirstLower»Amount' text=$amountLabel«IF !targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                {formintinput id='«appName.toFirstLower»Amount' dataField='amount' group='data' mandatory=true maxLength=2}
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateTemplate(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            «IF targets('1.3.x')»
                {gt text='Template' domain='module_«appName.formatForDB»' assign='templateLabel'}
            «ELSE»
                {% set templateLabel = __('Template', '«appName.formatForDB»') %}
            «ENDIF»
            {formlabel for='«appName.toFirstLower»Template' text=$templateLabel«IF !targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                «IF targets('1.3.x')»
                    {«appName.formatForDB»TemplateSelector assign='allTemplates'}
                «ELSE»
                    {% set allTemplates = «appName.formatForDB»_templateSelector() %}
                «ENDIF»
                {formdropdownlist id='«appName.toFirstLower»Template' dataField='template' group='data' mandatory=true items=$allTemplates«IF !targets('1.3.x')» cssClass='form-control'«ENDIF»}
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>

        <div id="customTemplateArea" class="«IF targets('1.3.x')»z-formrow z-hide«ELSE»form-group hidden«ENDIF»"«IF !targets('1.3.x')» data-switch="«appName.toFirstLower»Template" data-switch-value="custom"«ENDIF»>
            «IF targets('1.3.x')»
                {gt text='Custom template' domain='module_«appName.formatForDB»' assign='customTemplateLabel'}
            «ELSE»
                {% set customTemplateLabel = __('Custom template', '«appName.formatForDB»') %}
            «ENDIF»
            {formlabel for='«appName.toFirstLower»CustomTemplate' text=$customTemplateLabel«IF !targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                {formtextinput id='«appName.toFirstLower»CustomTemplate' dataField='customTemplate' group='data' mandatory=false maxLength=80«IF !targets('1.3.x')» cssClass='form-control'«ENDIF»}
                «IF targets('1.3.x')»
                    <span class="z-sub z-formnote">{gt text='Example' domain='module_«appName.formatForDB»'}: <em>itemlist_[objectType]_display.tpl</em></span>
                «ELSE»
                    <span class="help-block">{{ __('Example', '«appName.formatForDB»') }}: <em>itemlist_[objectType]_display.html.twig</em></span>
                «ENDIF»
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateFilter(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow z-hide«ELSE»form-group«ENDIF»">
            «IF targets('1.3.x')»
                {gt text='Filter (expert option)' domain='module_«appName.formatForDB»' assign='filterLabel'}
            «ELSE»
                {% set filterLabel = __('Filter (expert option)', '«appName.formatForDB»') %}
            «ENDIF»
            {formlabel for='«appName.toFirstLower»Filter' text=$filterLabel«IF !targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                {formtextinput id='«appName.toFirstLower»Filter' dataField='filter' group='data' mandatory=false maxLength=255«IF !targets('1.3.x')» cssClass='form-control'«ENDIF»}
                «IF targets('1.3.x')»
                    <span class="z-sub z-formnote">
                        ({gt text='Syntax examples' domain='module_«appName.formatForDB»'}: <kbd>name:like:foobar</kbd> {gt text='or'} <kbd>status:ne:3</kbd>)
                    </span>
                «ELSE»
                    <span class="help-block">
                        <a class="fa fa-filter" data-toggle="modal" data-target="#filterSyntaxModal">{{ __('Show syntax examples', '«appName.formatForDB»') }}</a>
                    </span>
                «ENDIF»
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
        «IF !targets('1.3.x')»

            {{ include('@«appName»/includeFilterSyntaxDialog.html.twig') }}
        «ENDIF»
    '''

    def private editTemplateJs(Application it) '''
        «IF targets('1.3.x')»
            {pageaddvar name='javascript' value='prototype'}
        «ELSE»
            {{ pageAddAsset('stylesheet', 'web/bootstrap/css/bootstrap.min.css') }}
            {{ pageAddAsset('stylesheet', 'web/bootstrap/css/bootstrap-theme.min.css') }}
            {{ pageAddAsset('javascript', 'jquery') }}
            {{ pageAddAsset('javascript', 'web/bootstrap/js/bootstrap.min.js') }}
        «ENDIF»
        «IF targets('1.3.x')»
            <script type="text/javascript">
            /* <![CDATA[ */
                function «vendorAndName»ToggleCustomTemplate() {
                    if ($F('«appName.toFirstLower»Template') == 'custom') {
                        $('customTemplateArea').removeClassName('«IF targets('1.3.x')»z-hide«ELSE»hidden«ENDIF»');
                    } else {
                        $('customTemplateArea').addClassName('«IF targets('1.3.x')»z-hide«ELSE»hidden«ENDIF»');
                    }
                }

                document.observe('dom:loaded', function() {
                    «vendorAndName»ToggleCustomTemplate();
                    $('«appName.toFirstLower»Template').observe('change', function(e) {
                        «vendorAndName»ToggleCustomTemplate();
                    });
                });
            /* ]]> */
            </script>
        «ENDIF»
    '''

    def private detailLink(Entity it, String appName) '''
        «IF application.targets('1.3.x')»
            <a href="{modurl modname='«appName»' type='user' ot='«name.formatForCode»' func='display' «routeParamsLegacy(name.formatForCode, true, true)»}">{gt text='Read more'}</a>
        «ELSE»
            <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}">{{ __('Read more') }}</a>
        «ENDIF»
    '''
}
