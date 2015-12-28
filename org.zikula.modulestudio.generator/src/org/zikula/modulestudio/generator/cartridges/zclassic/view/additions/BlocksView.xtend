package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlocksView {
    extension FormattingExtensions = new FormattingExtensions
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
        «ELSE»
            {# Purpose of this template: Edit block for generic item list #}
        «ENDIF»
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
            <label for="«appName.toFirstLower»ObjectType"«IF !targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF targets('1.3.x')»{gt text='Object type'}«ELSE»{{ __('Object type') }}«ENDIF»:</label>
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <select id="«appName.toFirstLower»ObjectType" name="objecttype" size="1"«IF !targets('1.3.x')» class="form-control"«ENDIF»>
                    «FOR entity : getAllEntities»
                        «IF targets('1.3.x')»
                            <option value="«entity.name.formatForCode»"{if $objectType eq '«entity.name.formatForCode»'} selected="selected"{/if}>{gt text='«entity.nameMultiple.formatForDisplayCapital»'}</option>
                        «ELSE»
                            <option value="«entity.name.formatForCode»"{{ objectType == '«entity.name.formatForCode»' ? ' selected="selected"' : '' }}>{{ __('«entity.nameMultiple.formatForDisplayCapital»') }}</option>
                        «ENDIF»
                    «ENDFOR»
                </select>
                «IF targets('1.3.x')»
                    <span class="z-sub z-formnote">{gt text='If you change this please save the block once to reload the parameters below.'}</span>
                «ELSE»
                    <span class="help-block">{{ __('If you change this please save the block once to reload the parameters below.') }}</span>
                «ENDIF»
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateCategories(Application it) '''
        «IF targets('1.3.x')»
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
        «ELSE»
            {% if catIds is not null and catIds is iterable %}
                {% set lblDefault = __('All') %}
                {% for propertyName, propertyId in catIds %}
                    <div class="form-group">
                        {% set hasMultiSelection = «appName.formatForDB»_isCategoryMultiValued(objectType, propertyName) %}
                        {% set categoryLabel = __('Category') %}
                        {% set categorySelectorId = 'catid' %}
                        {% set categorySelectorName = 'catid' %}
                        {% set categorySelectorSize = 1 %}
                        {% if hasMultiSelection == true %}
                            {% set categoryLabel = __('Categories') %}
                            {% set categorySelectorName = 'catids' %}
                            {% set categorySelectorId = 'catids__' %}
                            {% set categorySelectorSize = 8 %}
                        {/if}
                        <label for="{{ categorySelectorId ~ propertyName }}" class="col-sm-3 control-label">{{ categoryLabel }}</label>
                        <div class="col-sm-9">
                            «/* TODO migrate to Symfony forms #416 */»
                            {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIds.$propertyName categoryRegistryModule='«appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize cssClass='form-control'}
                            <span class="help-block">{{ __('This is an optional filter.') }}</span>
                        </div>
                    </div>
                {% endfor %}
            {% endif %}
        «ENDIF»
    '''

    def private editTemplateSorting(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«appName.toFirstLower»Sorting"«IF !targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF targets('1.3.x')»{gt text='Sorting'}«ELSE»{{ __('Sorting') }}«ENDIF»:</label>
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <select id="«appName.toFirstLower»Sorting" name="sorting"«IF !targets('1.3.x')» class="form-control"«ENDIF»>
                    «IF targets('1.3.x')»
                        <option value="random"{if $sorting eq 'random'} selected="selected"{/if}>{gt text='Random'}</option>
                        <option value="newest"{if $sorting eq 'newest'} selected="selected"{/if}>{gt text='Newest'}</option>
                        <option value="alpha"{if $sorting eq 'default' || ($sorting ne 'random' && $sorting ne 'newest')} selected="selected"{/if}>{gt text='Default'}</option>
                    «ELSE»
                        <option value="random"{{ sorting == 'random' ? ' selected="selected"' : '' }}>{{ __('Random') }}</option>
                        <option value="newest"{{ sorting == 'newest' ? ' selected="selected"' : '' }}>{{ __('Newest') }}</option>
                        <option value="alpha"{{ (sorting == 'default' or (sorting != 'random' and sorting != 'newest')) ? ' selected="selected"' : '' }}>{{ __('Default') }}</option>
                    «ENDIF»
                </select>
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateAmount(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«appName.toFirstLower»Amount"«IF !targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF targets('1.3.x')»{gt text='Amount'}«ELSE»{{ __('Amount') }}«ENDIF»:</label>
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <input type="text" id="«appName.toFirstLower»Amount" name="amount" maxlength="2" size="10" value="«IF targets('1.3.x')»{$amount|default:"5"}«ELSE»{{ amount|default(5) }}«ENDIF»"«IF !targets('1.3.x')» class="form-control"«ENDIF» />
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateTemplate(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
            <label for="«appName.toFirstLower»Template"«IF !targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF targets('1.3.x')»{gt text='Template'}«ELSE»{{ __('Template') }}«ENDIF»:</label>
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <select id="«appName.toFirstLower»Template" name="template"«IF !targets('1.3.x')» class="form-control"«ENDIF»>
                    «IF targets('1.3.x')»
                        <option value="itemlist_display.tpl"{if $template eq 'itemlist_display.tpl'} selected="selected"{/if}>{gt text='Only item titles'}</option>
                        <option value="itemlist_display_description.tpl"{if $template eq 'itemlist_display_description.tpl'} selected="selected"{/if}>{gt text='With description'}</option>
                        <option value="custom"{if $template eq 'custom'} selected="selected"{/if}>{gt text='Custom template'}</option>
                    «ELSE»
                        <option value="itemlist_display.html.twig"{{ template == 'itemlist_display.html.twig' ? ' selected="selected"' : '' }}>{{ __('Only item titles') }}</option>
                        <option value="itemlist_display_description.html.twig"{{ template == 'itemlist_display_description.tpl' ? ' selected="selected"' : '' }}>{{ __('With description') }}</option>
                        <option value="custom"{{ template == 'custom' ? ' selected="selected"' : '' }}>{{ __('Custom template') }}</option>
                    «ENDIF»
                </select>
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>

        <div id="customTemplateArea" class="«IF targets('1.3.x')»z-formrow z-hide«ELSE»form-group hidden«ENDIF»"«IF !targets('1.3.x')» data-switch="«appName.toFirstLower»Template" data-switch-value="custom"«ENDIF»>
            <label for="«appName.toFirstLower»CustomTemplate"«IF !targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF targets('1.3.x')»{gt text='Custom template'}«ELSE»{{ __('Custom template') }}«ENDIF»:</label>
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <input type="text" id="«appName.toFirstLower»CustomTemplate" name="customtemplate" size="40" maxlength="80" value="«IF targets('1.3.x')»{$customTemplate|default:''}«ELSE»{{ customTemplate|default('') }}«ENDIF»"«IF !targets('1.3.x')» class="form-control"«ENDIF» />
                «IF targets('1.3.x')»
                    <span class="z-sub z-formnote">{gt text='Example'}: <em>itemlist_[objectType]_display.tpl</em></span>
                «ELSE»
                    <span class="help-block">{{ __('Example') }}: <em>itemlist_[objectType]_display.html.twig</em></span>
                «ENDIF»
            «IF !targets('1.3.x')»
                </div>
            «ENDIF»
        </div>
    '''

    def private editTemplateFilter(Application it) '''
        <div class="«IF targets('1.3.x')»z-formrow z-hide«ELSE»form-group«ENDIF»">
            <label for="«appName.toFirstLower»Filter"«IF !targets('1.3.x')» class="col-sm-3 control-label"«ENDIF»>«IF targets('1.3.x')»{gt text='Filter (expert option)'}«ELSE»{{ __('Filter (expert option)') }}«ENDIF»:</label>
            «IF !targets('1.3.x')»
                <div class="col-sm-9">
            «ENDIF»
                <input type="text" id="«appName.toFirstLower»Filter" name="filter" size="40" value="«IF targets('1.3.x')»{$filterValue|default:''}«ELSE»{{ filterValue|default('') }}«ENDIF»"«IF !targets('1.3.x')» class="form-control"«ENDIF» />
                «IF targets('1.3.x')»
                    <span class="z-sub z-formnote">
                        ({gt text='Syntax examples'}: <kbd>name:like:foobar</kbd> {gt text='or'} <kbd>status:ne:3</kbd>)
                    </span>
                «ELSE»
                    <span class="help-block">
                        <a class="fa fa-filter" data-toggle="modal" data-target="#filterSyntaxModal">{{ __('Show syntax examples') }}</a>
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
