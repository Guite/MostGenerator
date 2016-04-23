package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlocksView {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.x')) 'block' else 'Block') + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'
        var fileName = 'itemlist' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, displayTemplate)
        }
        fileName = 'itemlist_modify' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_modify.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    def private displayTemplate(Application it) '''
        «IF targets('1.3.x')»
            {* Purpose of this template: Display items within a block (fallback template) *}
        «ELSE»
            {# Purpose of this template: Display items within a block (fallback template) #}
        «ENDIF»
        Default block for generic item list.
    '''

    def private editTemplate(Application it) '''
        «IF targets('1.3.x')»
            {* Purpose of this template: Edit block for generic item list *}
            «editTemplateObjectTypeLegacy»

            «editTemplateCategoriesLegacy»

            «editTemplateSortingLegacy»

            «editTemplateAmountLegacy»

            «editTemplateTemplateLegacy»

            «editTemplateFilterLegacy»

            «editTemplateJs»
        «ELSE»
            {# Purpose of this template: Edit block for generic item list #}
            {{ form_row(form.objectType) }}
            «IF hasCategorisableEntities»
                {% if isCategorisable %}
                    {{ form_row(form.categories) }}
                {% endif %}
            «ENDIF»
            {{ form_row(form.sorting) }}
            {{ form_row(form.amount) }}

            {{ form_row(form.template) }}
            <div id="customTemplateArea" class="hidden" data-switch="template" data-switch-value="custom">
                {{ form_row(form.customTemplate) }}
            </div>

            {{ form_row(form.filter) }}

            {{ include('@«appName»/includeFilterSyntaxDialog.html.twig') }}
            «editTemplateJs»
        «ENDIF»
    '''

    // 1.3.x only
    def private editTemplateObjectTypeLegacy(Application it) '''
        <div class="z-formrow">
            <label for="«appName.toFirstLower»ObjectType">{gt text='Object type'}:</label>
            <select id="«appName.toFirstLower»ObjectType" name="objecttype" size="1">
                «FOR entity : getAllEntities»
                    <option value="«entity.name.formatForCode»"{if $objectType eq '«entity.name.formatForCode»'} selected="selected"{/if}>{gt text='«entity.nameMultiple.formatForDisplayCapital»'}</option>
                «ENDFOR»
            </select>
            <span class="z-sub z-formnote">{gt text='If you change this please save the block once to reload the parameters below.'}</span>
        </div>
    '''

    // 1.3.x only
    def private editTemplateCategoriesLegacy(Application it) '''
        {if $catIds ne null && is_array($catIds)}
            {gt text='All' assign='lblDefault'}
            {nocache}
            {foreach key='propertyName' item='propertyId' from=$catIds}
                <div class="z-formrow">
                    {modapifunc modname='«appName»' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
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
                    {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}
                    <span class="z-sub z-formnote">{gt text='This is an optional filter.'}</span>
                </div>
            {/foreach}
            {/nocache}
        {/if}
    '''

    // 1.3.x only
    def private editTemplateSortingLegacy(Application it) '''
        <div class="z-formrow">
            <label for="«appName.toFirstLower»Sorting">{gt text='Sorting'}:</label>
            <select id="«appName.toFirstLower»Sorting" name="sorting">
                <option value="random"{if $sorting eq 'random'} selected="selected"{/if}>{gt text='Random'}</option>
                <option value="newest"{if $sorting eq 'newest'} selected="selected"{/if}>{gt text='Newest'}</option>
                <option value="default"{if $sorting eq 'default' || ($sorting ne 'random' && $sorting ne 'newest')} selected="selected"{/if}>{gt text='Default'}</option>
            </select>
        </div>
    '''

    // 1.3.x only
    def private editTemplateAmountLegacy(Application it) '''
        <div class="z-formrow">
            <label for="«appName.toFirstLower»Amount">{gt text='Amount'}:</label>
            <input type="text" id="«appName.toFirstLower»Amount" name="amount" maxlength="2" size="10" value="{$amount|default:"5"}" />
        </div>
    '''

    // 1.3.x only
    def private editTemplateTemplateLegacy(Application it) '''
        <div class="z-formrow">
            <label for="«appName.toFirstLower»Template">{gt text='Template'}:</label>
            <select id="«appName.toFirstLower»Template" name="template">
                <option value="itemlist_display.tpl"{if $template eq 'itemlist_display.tpl'} selected="selected"{/if}>{gt text='Only item titles'}</option>
                <option value="itemlist_display_description.tpl"{if $template eq 'itemlist_display_description.tpl'} selected="selected"{/if}>{gt text='With description'}</option>
                <option value="custom"{if $template eq 'custom'} selected="selected"{/if}>{gt text='Custom template'}</option>
            </select>
        </div>

        <div id="customTemplateArea" class="z-formrow z-hide">
            <label for="«appName.toFirstLower»CustomTemplate">{gt text='Custom template'}:</label>
            <input type="text" id="«appName.toFirstLower»CustomTemplate" name="customtemplate" size="40" maxlength="80" value="{$customTemplate|default:''}" />
            <span class="z-sub z-formnote">{gt text='Example'}: <em>itemlist_[objectType]_display.tpl</em></span>
        </div>
    '''

    // 1.3.x only
    def private editTemplateFilterLegacy(Application it) '''
        <div class="z-formrow z-hide">
            <label for="«appName.toFirstLower»Filter">{gt text='Filter (expert option)'}:</label>
            <input type="text" id="«appName.toFirstLower»Filter" name="filter" size="40" value="{$filter|default:''}" />
            <span class="z-sub z-formnote">
                ({gt text='Syntax examples'}: <kbd>name:like:foobar</kbd> {gt text='or'} <kbd>status:ne:3</kbd>)
            </span>
        </div>
    '''

    def private editTemplateJs(Application it) '''
        «IF targets('1.3.x')»
            {pageaddvar name='javascript' value='prototype'}
        «ELSE»
            {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap.min.css')) }}
            {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap-theme.min.css')) }}
            {{ pageAddAsset('javascript', asset('bootstrap/js/bootstrap.min.js')) }}
        «ENDIF»
        «IF targets('1.3.x')»
            <script type="text/javascript">
            /* <![CDATA[ */
                function «vendorAndName»ToggleCustomTemplate() {
                    if ($F('«appName.toFirstLower»Template') == 'custom') {
                        $('customTemplateArea').removeClassName('z-hide');
                    } else {
                        $('customTemplateArea').addClassName('z-hide');
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
}
