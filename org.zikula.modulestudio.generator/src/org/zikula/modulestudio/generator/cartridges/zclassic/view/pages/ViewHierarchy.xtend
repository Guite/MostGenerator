package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewHierarchy {

    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating tree view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = templateFile('view_tree')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, hierarchyView(appName))
        }
        templateFilePath = templateFile('view_tree_items')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, hierarchyItemsView(appName))
        }
    }

    def private hierarchyView(Entity it, String appName) '''
        «val objName = name.formatForCode»
        «val appPrefix = container.application.prefix()»
        {* purpose of this template: «nameMultiple.formatForDisplay» tree view *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        «IF container.application.targets('1.3.5')»
            {include file="`$lct`/header.tpl"}
        «ELSE»
            {assign var='lctUc' value=$lct|ucfirst}
            {include file="`$lctUc`/header.tpl"}
        «ENDIF»
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewhierarchy">
            {gt text='«name.formatForDisplayCapital» hierarchy' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            «templateHeader»

            «IF documentation !== null && documentation != ''»
                <p class="«IF container.application.targets('1.3.5')»z-informationmsg«ELSE»alert alert-info«ENDIF»">«documentation»</p>
            «ENDIF»

            <p>
            «IF hasActions('edit')»
                {checkpermissionblock component='«appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»'}
                    {gt text='Add root node' assign='addRootTitle'}
                    <a id="treeAddRoot" href="javascript:void(0)" title="{$addRootTitle}" class="«IF container.application.targets('1.3.5')»z-icon-es-add z-hide«ELSE»fa fa-plus hidden«ENDIF»">{$addRootTitle}</a>

                    <script type="text/javascript">
                    /* <![CDATA[ */
                    «IF container.application.targets('1.3.5')»
                        document.observe('dom:loaded', function() {
                            $('treeAddRoot').observe('click', function(event) {
                                «appPrefix»PerformTreeOperation('«objName»', 1, 'addRootNode');
                                Event.stop(event);
                            }).removeClassName('z-hide');
                        });
                    «ELSE»
                        ( function($) {
                            $(document).ready(function() {
                                $('#treeAddRoot').click( function(event) {
                                    «appPrefix»PerformTreeOperation('«objName»', 1, 'addRootNode');
                                    event.stopPropagation();
                                }).removeClass('hidden');
                            });
                        })(jQuery);
                    «ENDIF»
                    /* ]]> */
                    </script>
                    <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>
                {/checkpermissionblock}
            «ENDIF»
                {gt text='Switch to table view' assign='switchTitle'}
                <a href="{modurl modname='«appName»' «IF container.application.targets('1.3.5')»type=$lct func='view' ot='«objName»'«ELSE»type='«objName»' func='view' lct=$lct«ENDIF»}" title="{$switchTitle}" class="«IF container.application.targets('1.3.5')»z-icon-es-view«ELSE»fa fa-table«ENDIF»">{$switchTitle}</a>
            </p>

            {foreach key='rootId' item='treeNodes' from=$trees}
                {include file='«IF container.application.targets('1.3.5')»«objName»«ELSE»«name.formatForCodeCapital»«ENDIF»/view_tree_items.tpl' lct=$lct rootId=$rootId items=$treeNodes}
            {foreachelse}
                {include file='«IF container.application.targets('1.3.5')»«objName»«ELSE»«name.formatForCodeCapital»«ENDIF»/view_tree_items.tpl' lct=$lct rootId=1 items=null}
            {/foreach}

            <br style="clear: left" />
        </div>
        «IF container.application.targets('1.3.5')»
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {include file="`$lctUc`/footer.tpl"}
        «ENDIF»
    '''

    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            «IF container.application.targets('1.3.5')»
                <div class="z-admin-content-pagetitle">
                    {icon type='view' size='small' alt=$templateTitle}
                    <h3>{$templateTitle}</h3>
                </div>
            «ELSE»
                <h3>
                    <span class="fa fa-list"></span>
                    {$templateTitle}
                </h3>
            «ENDIF»
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''

    def private hierarchyItemsView(Entity it, String appName) '''
        «val appPrefix = container.application.prefix()»
        {* purpose of this template: «nameMultiple.formatForDisplay» tree items *}
        {assign var='hasNodes' value=false}
        {if isset($items) && (is_object($items) && $items->count() gt 0) || (is_array($items) && count($items) gt 0)}
            {assign var='hasNodes' value=true}
        {/if}

        <div id="«name.formatForCode.toFirstLower»Tree{$rootId}" class="«IF container.application.targets('1.3.5')»z-«ENDIF»tree-container">
            <div id="«name.formatForCode.toFirstLower»TreeItems{$rootId}" class="«IF container.application.targets('1.3.5')»z-«ENDIF»tree-items">
            {if $hasNodes}
                {«appName.formatForDB»TreeJS objectType='«name.formatForCode»' tree=$items controller=$lct root=$rootId sortable=true}
            {/if}
            </div>
        </div>

        {if $hasNodes}
            {pageaddvar name='javascript' value='«container.application.rootFolder»/«IF container.application.targets('1.3.5')»«appName»/javascript/«ELSE»«container.application.getAppJsPath»«ENDIF»«appName»«IF container.application.targets('1.3.5')»_t«ELSE».T«ENDIF»ree.js'}
            <script type="text/javascript">
            /* <![CDATA[ */
                «IF container.application.targets('1.3.5')»
                    document.observe('dom:loaded', function() {
                        «appPrefix»InitTreeNodes('«name.formatForCode»', '{{$rootId}}', «hasActions('display').displayBool», «(hasActions('edit') && !readOnly).displayBool»);
                        Zikula.TreeSortable.trees.itemtree{{$rootId}}.config.onSave = «appPrefix»TreeSave;
                    });
                «ELSE»
                    ( function($) {
                        $(document).ready(function() {
                            «appPrefix»InitTreeNodes('«name.formatForCode»', '{{$rootId}}', «hasActions('display').displayBool», «(hasActions('edit') && !readOnly).displayBool»);
                            Zikula.TreeSortable.trees.itemtree{{$rootId}}.config.onSave = «appPrefix»TreeSave;
                        });
                    })(jQuery);
                «ENDIF»
            /* ]]> */
            </script>
            <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>
        {/if}
    '''
}
