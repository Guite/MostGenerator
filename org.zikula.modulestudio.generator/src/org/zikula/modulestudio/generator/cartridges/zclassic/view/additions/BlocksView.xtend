package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlocksView {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = appName.getAppSourcePath + 'templates/block/'
        fsa.generateFile(templatePath + 'itemlist.tpl', displayTemplate)
        fsa.generateFile(templatePath + 'itemlist_modify.tpl', editTemplate)
    }

    def private displayTemplate(Application it) '''
        {* Purpose of this template: Display items within a block (fallback template) *}
        Default block for generic item list.
    '''

    def private editTemplate(Application it) '''
        {* Purpose of this template: Edit block for generic item list *}
        <div class="z-formrow">
            <label for="«appName»_objecttype">{gt text='Object type'}:</label>
            <select id="«appName»_objecttype" name="objecttype" size="1">
                «FOR entity : getAllEntities»
                    <option value="«entity.name.formatForCode»"{if $objectType eq '«entity.name.formatForCode»'} selected="selected"{/if}>{gt text='«entity.nameMultiple.formatForDisplayCapital»'}</option>
                «ENDFOR»
            </select>
            <div class="z-sub z-formnote">{gt text='If you change this please save the block once to reload the parameters below.'}</div>
        </div>

        {if $properties ne null && is_array($properties)}
            {gt text='All' assign='lblDefault'}
            {nocache}
            {foreach item='propertyName' from=$properties}
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
                    <div class="z-sub z-formnote">{gt text='This is an optional filter.'}</div>
                </div>
            {/foreach}
            {/nocache}
        {/if}

        <div class="z-formrow">
            <label for="«appName»_sorting">{gt text='Sorting'}:</label>
            <select id="«appName»_sorting" name="sorting">
                <option value="random"{if $sorting eq 'random'} selected="selected"{/if}>{gt text='Random'}</option>
                <option value="newest"{if $sorting eq 'newest'} selected="selected"{/if}>{gt text='Newest'}</option>
                <option value="alpha"{if $sorting eq 'default' || ($sorting != 'random' && $sorting != 'newest')} selected="selected"{/if}>{gt text='Default'}</option>
            </select>
        </div>

        <div class="z-formrow">
            <label for="«appName»_amount">{gt text='Amount'}:</label>
            <input type="text" id="«appName»_amount" name="amount" size="10" value="{$amount|default:"5"}" />
        </div>

        <div class="z-formrow">
            <label for="«appName»_template">{gt text='Template'}:</label>
            <select id="«appName»_template" name="template">
                <option value="itemlist_display.tpl"{if $template eq 'itemlist_display.tpl'} selected="selected"{/if}>{gt text='Only item titles'}</option>
                <option value="itemlist_display_description.tpl"{if $template eq 'itemlist_display_description.tpl'} selected="selected"{/if}>{gt text='With description'}</option>
                <option value="custom"{if $template eq 'custom'} selected="selected"{/if}>{gt text='Custom template'}</option>
            </select>
        </div>

        <div id="customtemplatearea" class="z-formrow z-hide">
            <label for="«appName»_customtemplate">{gt text='Custom template'}:</label>
            <input type="text" id="«appName»__customtemplate" name="customtemplate" size="40" maxlength="80" value="{$customTemplate|default:''}" />
            <div class="z-sub z-formnote">{gt text='Example'}: <em>itemlist_{objecttype}_display.tpl</em></div>
        </div>

        <div class="z-formrow z-hide"«/* TODO: wait until FilterUtil is ready for Doctrine 2 - see https://github.com/zikula/core/issues/118 */»>
            <label for="«appName»_filter">{gt text='Filter (expert option)'}:</label>
            <input type="text" id="«appName»_filter" name="filter" size="40" value="{$filterValue|default:''}" />
            <div class="z-sub z-formnote">({gt text='Syntax examples'}: <kbd>name:like:foobar</kbd> {gt text='or'} <kbd>status:ne:3</kbd>)</div>
        </div>

        {pageaddvar name='javascript' value='prototype'}
        <script type="text/javascript">
        /* <![CDATA[ */
            function «prefix()»ToggleCustomTemplate() {
                if ($F('«appName»_template') == 'custom') {
                    $('customtemplatearea').removeClassName('z-hide');
                } else {
                    $('customtemplatearea').addClassName('z-hide');
                }
            }

            document.observe('dom:loaded', function() {
                «prefix()»ToggleCustomTemplate();
                $('«appName»_template').observe('change', function(e) {
                    «prefix()»ToggleCustomTemplate();
                });
            });
        /* ]]> */
        </script>
    '''
}
