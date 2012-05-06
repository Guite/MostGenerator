package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import de.guite.modulestudio.metamodel.modulestudio.AdminController

class ViewHierarchy {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' tree view templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(templateFile(controller, name, 'view_tree'), hierarchyView(appName, controller))
        fsa.generateFile(templateFile(controller, name, 'view_tree_items'), hierarchyItemsView(appName, controller))
    }

    def private hierarchyView(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        «val appPrefix = container.application.prefix»
        {* purpose of this template: «nameMultiple.formatForDisplay» tree view in «controller.formattedName» area *}
        {include file='«controller.formattedName»/header.tpl'}
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewhierarchy">
        {gt text='«name.formatForDisplayCapital» hierarchy' assign='templateTitle'}
        {pagesetvar name='title' value=$templateTitle}
        «controller.templateHeader»

        «IF documentation != null && documentation != ''»
            <p class="sectiondesc">«documentation»</p>
        «ENDIF»

        <p>
            «IF controller.hasActions('edit')»
                {checkpermissionblock component='«appName»::' instance='.*' level="ACCESS_ADD"}
                    {gt text='Add root node' assign='addRootTitle'}
                    <a id="z-tree-addroot" href="javascript:void(0)" title="{$addRootTitle}" style="display: none" class="z-icon-es-add">{$addRootTitle}</a>

                    <script type="text/javascript" charset="utf-8">
                /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                       $('z-tree-addroot').observe('click', function(event) {
                           «appPrefix»PerformTreeOperation('«name.formatForCode»', 1, 'addRootNode');
                           Event.stop(event);
                       }).show();
                });
                /* ]]> */
                </script>
                <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>

                {*
                    {gt text='Create «name.formatForDisplay»' assign='createTitle'}
                    <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='edit' ot='«objName»'}" title="{$createTitle}" class="z-icon-es-add">
                        {$createTitle}
                    </a>
                *}
                {/checkpermissionblock}
            «ENDIF»
            {gt text='Switch to table view' assign='switchTitle'}
            <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='view' ot='«objName»'}" title="{$switchTitle}" class="z-icon-es-view">
                {$switchTitle}
            </a>
        </p>

        {foreach key='rootId' item='treeNodes' from=$trees}
            {include file='«controller.formattedName»/«name.formatForCode»/view_tree_items.tpl' rootId=$rootId items=$treeNodes}
        {foreachelse}
            {include file='«controller.formattedName»/«name.formatForCode»/view_tree_items.tpl' rootId=1 items=null}
        {/foreach}

        <br style="clear: left" />

        «controller.templateFooter»
        </div>
        {include file='«controller.formattedName»/footer.tpl'}
    '''

    def private templateHeader(Controller it) {
        switch it {
            AdminController: '''
                <div class="z-admin-content-pagetitle">
                    {icon type='view' size='small' alt=$templateTitle}
                    <h3>{$templateTitle}</h3>
                </div>
            '''
            default: '''
                <div class="z-frontendcontainer">
                    <h2>{$templateTitle}</h2>
            '''
        }
    }

    def private templateFooter(Controller it) {
        switch it {
            AdminController: ''
            default: '''
                </div>
            '''
        }
    }

    def private hierarchyItemsView(Entity it, String appName, Controller controller) '''
        «val appPrefix = container.application.prefix»
        {* purpose of this template: «nameMultiple.formatForDisplay» tree items in «controller.formattedName» area *}
        {assign var='hasNodes' value=false}
        {if isset($items) && (is_object($items) && $items->count() gt 0) || (is_array($items) && count($items) gt 0)}
            {assign var='hasNodes' value=true}
        {/if}

        {* initialise additional gettext domain for translations within javascript *}
        {pageaddvar name='jsgettext' value='module_«appName.formatForDB»_js:«appName»'}

        <div id="«name.formatForDB»_tree{$rootId}" class="z-treecontainer">
            <div id="treeitems{$rootId}" class="z-treeitems">
            {if $hasNodes}
                {«appName.formatForDB»TreeJS objectType='«name.formatForCode»' tree=$items controller='«controller.formattedName»' root=$rootId sortable=true}
            {/if}
            </div>
        </div>

        {pageaddvar name='javascript' value='modules/«appName»/javascript/«appName»_tree.js'}
        <script type="text/javascript" charset="utf-8">
        /* <![CDATA[ */
            document.observe('dom:loaded', function() {
            {{if $hasNodes}}
                «appPrefix»InitTreeNodes('«name.formatForCode»', '«controller.formattedName»', '{{$rootId}}', «controller.hasActions('display').displayBool», «(controller.hasActions('edit') && !readOnly).displayBool»);
                Zikula.TreeSortable.trees.itemtree{{$rootId}}.config.onSave = «appPrefix»TreeSave;
            {{/if}}
            });
        /* ]]> */
        </script>
        <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>
    '''
}
