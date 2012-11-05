package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.modulestudio.StringField

class ViewQuickNavForm {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' view filter form templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(templateFile(controller, name, 'view_quickNav'), quickNavForm(controller))
    }

    def private quickNavForm(Entity it, Controller controller) '''
        «val app = container.application»
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» view filter form in «controller.formattedName» area *}
        {checkpermissionblock component='«app.appName»:«name.formatForCodeCapital»:' instance='.*' level='ACCESS_EDIT'}
        {assign var='objectType' value='«name.formatForCode»'}
        <form action="{$modvars.ZConfig.entrypoint|default:'index.php'}" method="get" id="«app.prefix»«name.formatForCodeCapital»QuickNavForm" class="«app.prefix»QuickNavForm">
            <fieldset>
                <h3>{gt text='Quick navigation'}</h3>
                <input type="hidden" name="module" value="{modgetinfo modname='«app.appName»' info='displayname'}" />
                <input type="hidden" name="type" value="«controller.formattedName»" />
                <input type="hidden" name="func" value="view" />
                <input type="hidden" name="ot" value="«objName»" />
                {gt text='All' assign='lblDefault'}
                «formFields»
                <input type="submit" name="updateview" id="quicknav_submit" value="{gt text='OK'}" />
            </fieldset>
        </form>

        <script type="text/javascript">
        /* <![CDATA[ */
            document.observe('dom:loaded', function() {
                «app.prefix»InitQuickNavigation('«name.formatForCode»', '«controller.formattedName»');
                {{if isset($searchFilter) && $searchFilter eq false}}
                    {{* we can hide the submit button if we have no quick search field *}}
                    $('quicknav_submit').addClassName('z-hide');
                {{/if}}
            });
        /* ]]> */
        </script>
        {/checkpermissionblock}
    '''

    def private formFields(Entity it) '''
        «categoriesFields»
        «val incomingRelations = getBidirectionalIncomingJoinRelationsWithOneSource»
        «IF !incomingRelations.isEmpty»
            «FOR relation: incomingRelations»
                «relation.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasListFieldsEntity»
            «FOR field : getListFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasUserFieldsEntity»
            «FOR field : getUserFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasCountryFieldsEntity»
            «FOR field : getCountryFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasLanguageFieldsEntity»
            «FOR field : getLanguageFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
        «IF hasAbstractStringFieldsEntity»
            {if !isset($searchFilter) || $searchFilter eq true}
                <label for="searchterm">{gt text='Search'}:</label>
                <input type="text" id="searchterm" name="searchterm" value="{$searchterm}" />
            {/if}
        «ENDIF»
        «sortingAndPageSize»
        «IF hasBooleanFieldsEntity»
            «FOR field : getBooleanFieldsEntity»
                «field.formField»
            «ENDFOR»
        «ENDIF»
    '''

    def private categoriesFields(Entity it) '''
        «IF categorisable»
            {if !isset($categoryFilter) || $categoryFilter eq true}
                {modapifunc modname='«container.application.appName»' type='category' func='getAllProperties' assign='properties'}
                {if $properties ne null && is_array($properties)}
                    {gt text='All' assign='lblDefault'}
                    {nocache}
                    {foreach key='propertyName' item='propertyId' from=$properties}
                        {modapifunc modname='«container.application.appName»' type='category' func='hasMultipleSelection' ot=$objectType registry=$propertyName assign='hasMultiSelection'}
                        {gt text='Category' assign='categoryLabel'}
                        {assign var='categorySelectorId' value='catid'}
                        {assign var='categorySelectorName' value='catid'}
                        {assign var='categorySelectorSize' value='1'}
                        {if $hasMultiSelection eq true}
                            {gt text='Categories' assign='categoryLabel'}
                            {assign var='categorySelectorName' value='catids'}
                            {assign var='categorySelectorId' value='catids__'}
                            {assign var='categorySelectorSize' value='5'}
                        {/if}
                        <label for="{$categorySelectorId}{$propertyName}">{$categoryLabel}</label>
                        &nbsp;
                        {selector_category name="`$categorySelectorName``$propertyName`" field='id' selectedValue=$catIdList.$propertyName categoryRegistryModule='«container.application.appName»' categoryRegistryTable=$objectType categoryRegistryProperty=$propertyName defaultText=$lblDefault editLink=false multipleSize=$categorySelectorSize}
                    {/foreach}
                    {/nocache}
                {/if}
            {/if}
        «ENDIF»
    '''

    def private dispatch formField(DerivedField it) '''
        «val fieldName = name.formatForCode»
        {if !isset($«fieldName»Filter) || $«fieldName»Filter eq true}
            «formFieldImpl»
        {/if}
    '''

    def private dispatch formFieldImpl(BooleanField it) '''
        «val fieldName = name.formatForCode»
        <label for="«fieldName»">{gt text='«name.formatForDisplayCapital»'}</label>
        <select id="«fieldName»" name="«fieldName»">
            <option value="">{$lblDefault}</option>
        {foreach item='option' from=$«fieldName»Items}
            <option value="{$option.value}"{if $option.value eq $«fieldName»} selected="selected"{/if}>{$option.text|safetext}</option>
        {/foreach}
        </select>
    '''

    def private dispatch formFieldImpl(StringField it) '''
        «val fieldName = name.formatForCode»
        <label for="«fieldName»">{gt text='«name.formatForDisplayCapital»'}</label>
        «IF country»
            {selector_countries name='«fieldName»' selectedValue=$«fieldName» defaultText=$lblDefault}
        «ELSEIF language»
            {html_select_locales name='«fieldName»' selected=$«fieldName»}
        «ENDIF»
    '''

    def private dispatch formFieldImpl(UserField it) '''
        «val fieldName = name.formatForCode»
        <label for="«fieldName»">{gt text='«name.formatForDisplayCapital»'}</label>
        {selector_user name='«fieldName»' selectedValue=$«fieldName» defaultText=$lblDefault}
    '''

    def private dispatch formFieldImpl(ListField it) '''
        «val fieldName = name.formatForCode»
        <label for="«fieldName»">{gt text='«name.formatForDisplayCapital»'}</label>
        <select id="«fieldName»" name="«fieldName»">
            <option value="">{$lblDefault}</option>
        {foreach item='option' from=$«fieldName»Items}
            <option value="{$option.value}"{if $option.title ne ''} title="{$option.title|safetext}"{/if}{if $option.value eq $«fieldName»} selected="selected"{/if}>{$option.text|safetext}</option>
        {/foreach}
        </select>
    '''

    def private dispatch formField(JoinRelationship it) '''
        «val sourceName = source.name.formatForCode»
        «val sourceAliasName = getRelationAliasName(false)»
        {if !isset($«sourceName»Filter) || $«sourceName»Filter eq true}
            <label for="«sourceAliasName»">{gt text='«source.nameMultiple.formatForDisplayCapital»'}</label>
            {modapifunc modname='«source.container.application.appName»' type='selection' func='getEntities' ot='«source.name.formatForCode»' slimMode=true assign='listEntries'}
            <select id="«sourceAliasName»" name="«sourceAliasName»">
                <option value="">{$lblDefault}</option>
            {foreach item='option' from=$listEntries}
                «IF source.hasCompositeKeys»
                    {assign var='entryId' value="«FOR pkField : source.getPrimaryKeyFields SEPARATOR '_'»`$option.«pkField.name.formatForCode»`«ENDFOR»"}
                    <option value="{$entryId}"{if $entryId eq $«sourceAliasName»} selected="selected"{/if}>{$option.«source.leadingField.name.formatForCode»}</option>
                «ELSE»
                    {assign var='entryId' value=$option.«source.getFirstPrimaryKey.name.formatForCode»}
                    <option value="{$entryId}"{if $entryId eq $«sourceAliasName»} selected="selected"{/if}>{$option.«source.leadingField.name.formatForCode»}</option>
                «ENDIF»
            {/foreach}
            </select>
        {/if}
    '''

    def private sortingAndPageSize(Entity it) '''
        {if !isset($sorting) || $sorting eq true}
            <label for="sortby">{gt text='Sort by'}</label>
            &nbsp;
            <select id="sortby" name="sort">
            «FOR field : getDerivedFields»
                <option value="«field.name.formatForCode»"{if $sort eq '«field.name.formatForCode»'} selected="selected"{/if}>{gt text='«field.name.formatForDisplayCapital»'}</option>
            «ENDFOR»
            «IF standardFields»
                <option value="createdDate"{if $sort eq 'createdDate'} selected="selected"{/if}>{gt text='Creation date'}</option>
                <option value="createdUserId"{if $sort eq 'createdUserId'} selected="selected"{/if}>{gt text='Creator'}</option>
                <option value="updatedDate"{if $sort eq 'updatedDate'} selected="selected"{/if}>{gt text='Update date'}</option>
            «ENDIF»
            </select>
            <select id="sortdir" name="sortdir">
                <option value="asc"{if $sdir eq 'asc'} selected="selected"{/if}>{gt text='ascending'}</option>
                <option value="desc"{if $sdir eq 'desc'} selected="selected"{/if}>{gt text='descending'}</option>
            </select>
        {else}
            <input type="hidden" name="sort" value="{$sort}" />
            <input type="hidden" name="sdir" value="{if $sdir eq 'desc'}asc{else}desc{/if}" />
        {/if}
        {if !isset($pageSizeSelector) || $pageSizeSelector eq true}
            {assign var='pageSize' value=$pager.itemsperpage}
            <label for="num">{gt text='Page size'}</label>
            &nbsp;
            <select id="num" name="num">
                <option value="5"{if $pageSize eq 5} selected="selected"{/if}>5</option>
                <option value="10"{if $pageSize eq 10} selected="selected"{/if}>10</option>
                <option value="15"{if $pageSize eq 15} selected="selected"{/if}>15</option>
                <option value="20"{if $pageSize eq 20} selected="selected"{/if}>20</option>
                <option value="30"{if $pageSize eq 30} selected="selected"{/if}>30</option>
                <option value="50"{if $pageSize eq 50} selected="selected"{/if}>50</option>
                <option value="100"{if $pageSize eq 100} selected="selected"{/if}>100</option>
            </select>
        {/if}
    '''
}
