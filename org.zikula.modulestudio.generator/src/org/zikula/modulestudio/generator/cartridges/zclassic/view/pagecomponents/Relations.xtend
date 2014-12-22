package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Relations {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def displayItemList(Entity it, Application app, Boolean many, IFileSystemAccess fsa) {
        val templatePath = templateFile('include_displayItemList' + (if (many) 'Many' else 'One'))
        if (!app.shouldBeSkipped(templatePath)) {
            fsa.generateFile(templatePath, '''
                {* purpose of this template: inclusion template for display of related «nameMultiple.formatForDisplay» *}
                {assign var='lct' value='user'}
                {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                    {assign var='lct' value='admin'}
                {/if}
                {if $lct ne 'admin'}
                    {checkpermission component='«app.appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»' assign='hasAdminPermission'}
                    {checkpermission component='«app.appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»' assign='hasEditPermission'}
                {/if}
                «IF hasActions('display')»
                    {if !isset($nolink)}
                        {assign var='nolink' value=false}
                    {/if}
                «ENDIF»
                «IF !many»
                    <h4>
                «ELSE»
                    {if isset($items) && $items ne null && count($items) gt 0}
                    <ul class="«app.appName.toLowerCase»-related-item-list «name.formatForCode»">
                    {foreach name='relLoop' item='item' from=$items}
                        {if $hasAdminPermission || $item.workflowState eq 'approved'«IF ownerPermission» || ($item.workflowState eq 'defered' && $hasEditPermission && isset($uid) && $item.createdUserId eq $uid)«ENDIF»}
                        <li>
                «ENDIF»
                «IF hasActions('display')»
                    {strip}
                    {if !$nolink}
                        «IF app.targets('1.3.5')»
                            <a href="{modurl modname='«app.appName»' type=$lct func='display' ot='«name.formatForCode»' «routeParamsLegacy('item', true, true)»}" title="{$item->getTitleFromDisplayPattern()|replace:"\"":""}">
                        «ELSE»
                            <a href="{route name='«app.appName.formatForDB»_«name.formatForCode»_display' «routeParams('item', true)» lct=$lct}" title="{$item->getTitleFromDisplayPattern()|replace:"\"":""}">
                        «ENDIF»
                    {/if}
                «ENDIF»
                    {$item->getTitleFromDisplayPattern()}
                «IF hasActions('display')»
                    {if !$nolink}
                        </a>
                        «IF app.targets('1.3.5')»
                            <a id="«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{$item.«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«app.appName»' type=$lct func='display' ot='«name.formatForCode»' «routeParamsLegacy('item', true, true)» theme='Printer' forcelongurl=true}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
                        «ELSE»
                            <a id="«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{$item.«pkField.name.formatForCode»}«ENDFOR»Display" href="{route name='«app.appName.formatForDB»_«name.formatForCode»_display' «routeParams('item', true)» lct=$lct theme='Printer'}" title="{gt text='Open quick view window'}" class="fa fa-search-plus hidden"></a>
                        «ENDIF»
                    {/if}
                    {/strip}
                «ENDIF»
                «IF !many»</h4>
                «ENDIF»
                «IF hasActions('display')»
                    {if !$nolink}
                    <script type="text/javascript">
                    /* <![CDATA[ */
                        «IF app.targets('1.3.5')»
                            document.observe('dom:loaded', function() {
                                «app.vendorAndName»InitInlineWindow($('«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$item.«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$item->getTitleFromDisplayPattern()|replace:"'":""}}');
                            });
                        «ELSE»
                            ( function($) {
                                $(document).ready(function() {
                                    «app.vendorAndName»InitInlineWindow($('#«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$item.«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$item->getTitleFromDisplayPattern()|replace:"'":""}}');
                                });
                            })(jQuery);
                        «ENDIF»
                    /* ]]> */
                    </script>
                    {/if}
                «ENDIF»
                «IF hasImageFieldsEntity»
                    <br />
                    «val imageFieldName = getImageFieldsEntity.head.name.formatForCode»
                    {if $item.«imageFieldName» ne '' && isset($item.«imageFieldName»FullPath) && $item.«imageFieldName»Meta.isImage}
                        {thumb image=$item.«imageFieldName»FullPath objectid="«name.formatForCode»«IF hasCompositeKeys»«FOR pkField : getPrimaryKeyFields»-`$item.«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$item.«primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$relationThumbPreset tag=true img_alt=$item->getTitleFromDisplayPattern()«IF !application.targets('1.3.5')» img_class='img-rounded'«ENDIF»}
                    {/if}
                «ENDIF»
                «IF many»
                        </li>
                        {/if}
                    {/foreach}
                    </ul>
                    {/if}
                «ENDIF»
            ''')
        }
    }

    def displayRelatedItems(JoinRelationship it, String appName, Entity relatedEntity) '''
        «val incoming = (if (target == relatedEntity && source != relatedEntity) true else false)»«/* use outgoing mode for self relations #547 */»
        «val useTarget = !incoming»
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode.toFirstLower»
        «val relationAliasNameParam = getRelationAliasName(!useTarget).formatForCode»
        «val otherEntity = (if (!useTarget) source else target) as Entity»
        «val many = isManySideDisplay(useTarget)»
        {if $lct eq 'admin'}
            <h4>{gt text='«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»'}</h4>
        {else}
            <h3>{gt text='«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»'}</h3>
        {/if}

        {if isset($«relatedEntity.name.formatForCode».«relationAliasName») && $«relatedEntity.name.formatForCode».«relationAliasName» ne null}
            {include file='«IF application.targets('1.3.5')»«otherEntity.name.formatForCode»«ELSE»«otherEntity.name.formatForCodeCapital»«ENDIF»/include_displayItemList«IF many»Many«ELSE»One«ENDIF».tpl' item«IF many»s«ENDIF»=$«relatedEntity.name.formatForCode».«relationAliasName»}
        {/if}

        «IF otherEntity.hasActions('edit')»
            «IF !many»
                {if !isset($«relatedEntity.name.formatForCode».«relationAliasName») || $«relatedEntity.name.formatForCode».«relationAliasName» eq null}
            «ENDIF»
            {assign var='permLevel' value='ACCESS_«IF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»'}
            {if $lct eq 'admin'}
                {assign var='permLevel' value='ACCESS_ADMIN'}
            {/if}
            {checkpermission component='«appName»:«relatedEntity.name.formatForCodeCapital»:' instance="«relatedEntity.idFieldsAsParameterTemplate»::" level=$permLevel assign='mayManage'}
            {if $mayManage || (isset($uid) && isset($«relatedEntity.name.formatForCode».createdUserId) && $«relatedEntity.name.formatForCode».createdUserId eq $uid)}
            <p class="managelink">
                {gt text='Create «otherEntity.name.formatForDisplay»' assign='createTitle'}
                «IF application.targets('1.3.5')»
                    <a href="{modurl modname='«appName»' type=$lct func='edit' ot='«otherEntity.name.formatForCode»' «relationAliasNameParam»="«relatedEntity.idFieldsAsParameterTemplate»" returnTo="`$lct`Display«relatedEntity.name.formatForCodeCapital»"'}" title="{$createTitle}" class="z-icon-es-add">{$createTitle}</a>
                «ELSE»
                    <a href="{route name='«appName.formatForDB»_«otherEntity.name.formatForCode»_edit' lct=$lct «relationAliasNameParam»="«relatedEntity.idFieldsAsParameterTemplate»" returnTo="`$lct`Display«relatedEntity.name.formatForCodeCapital»"'}" title="{$createTitle}" class="fa fa-plus">{$createTitle}</a>
                «ENDIF»
            </p>
            {/if}
            «IF !many»
                {/if}
            «ENDIF»
        «ENDIF»
    '''
}
