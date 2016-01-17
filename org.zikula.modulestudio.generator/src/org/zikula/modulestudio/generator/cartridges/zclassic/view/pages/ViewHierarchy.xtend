package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewHierarchy {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating tree view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = templateFile('viewTree')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, hierarchyView(appName))
        }
        templateFilePath = templateFile('viewTreeItems')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, hierarchyItemsView(appName))
        }
    }

    def private hierarchyView(Entity it, String appName) '''
        «val objName = name.formatForCode»
        «IF isLegacyApp»
            {* purpose of this template: «nameMultiple.formatForDisplay» tree view *}
            {assign var='lct' value='user'}
            {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                {assign var='lct' value='admin'}
            {/if}
            {include file="`$lct`/header.tpl"}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewhierarchy">
                {gt text='«name.formatForDisplayCapital» hierarchy' assign='templateTitle'}
                {pagesetvar name='title' value=$templateTitle}
                «templateHeader»
                «IF null !== documentation && documentation != ''»

                    <p class="z-informationmsg">{gt text='«documentation.replace('\'', '\\\'')»'}</p>
                «ENDIF»

                <p>
                «IF hasActions('edit')»
                    {checkpermissionblock component='«appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»'}
                        {gt text='Add root node' assign='addRootTitle'}
                        <a id="treeAddRoot" href="javascript:void(0)" title="{$addRootTitle}" class="z-icon-es-add z-hide">{$addRootTitle}</a>

                        <script type="text/javascript">
                        /* <![CDATA[ */
                            document.observe('dom:loaded', function() {
                                $('treeAddRoot').observe('click', function(event) {
                                    «application.vendorAndName»PerformTreeOperation('«objName»', 1, 'addRootNode');
                                    Event.stop(event);
                                }).removeClassName('z-hide');
                            });
                        /* ]]> */
                        </script>
                        <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>
                    {/checkpermissionblock}
                «ENDIF»
                    {gt text='Switch to table view' assign='switchTitle'}
                    <a href="{modurl modname='«appName»' type=$lct func='view' ot='«objName»'}" title="{$switchTitle}" class="z-icon-es-view">{$switchTitle}</a>
                </p>

                {foreach key='rootId' item='treeNodes' from=$trees}
                    {include file='«objName»/viewTreeItems.tpl' lct=$lct rootId=$rootId items=$treeNodes}
                {foreachelse}
                    {include file='«objName»/viewTreeItems.tpl' lct=$lct rootId=1 items=null}
                {/foreach}

                <br style="clear: left" />
            </div>
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» tree view #}
            {% extends routeArea == 'admin' ? '«appName»::adminBase.html.twig' : '«appName»::base.html.twig' %}
            {% block title __('«name.formatForDisplayCapital» hierarchy') %}
            {% block adminPageIcon 'list' %}
            {% block content %}
                <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewhierarchy">
                    «IF null !== documentation && documentation != ''»

                        <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»') }}</p>
                    «ENDIF»

                    <p>
                        «IF hasActions('edit')»
                        {% if hasPermission('«appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
                            {% set addRootTitle = __('Add root node') %}
                            <a id="treeAddRoot" href="javascript:void(0)" title="{{ addRootTitle|e('html_attr') }}" class="fa fa-plus hidden">{{ addRootTitle }}</a>

                            <script type="text/javascript">
                            /* <![CDATA[ */
                                ( function($) {
                                    $(document).ready(function() {
                                        $('#treeAddRoot').click( function(event) {
                                            «application.vendorAndName»PerformTreeOperation('«objName»', 1, 'addRootNode');
                                            event.stopPropagation();
                                        }).removeClass('hidden');
                                    });
                                })(jQuery);
                            /* ]]> */
                            </script>
                            <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
                        {% endif %}
                        «ENDIF»
                        {% set switchTitle = __('Switch to table view') %}
                        <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view') }}" title="{{ switchTitle|e('html_attr') }}" class="fa fa-table">{{ switchTitle }}</a>
                    </p>

                    {% for rootId, treeNodes in trees %}
                        {{ include('@«appName»/«name.formatForCodeCapital»/viewTreeItems.html.twig', { rootId: rootId, items: treeNodes }) }}
                    {% else %}
                        {{ include('@«appName»/«name.formatForCodeCapital»/viewTreeItems.html.twig', { rootId: 1, items: null }) }}
                    {% endfor %}

                    <br style="clear: left" />
                </div>
            {% endblock %}
        «ENDIF»
    '''

    // 1.3.x only
    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            <div class="z-admin-content-pagetitle">
                {icon type='view' size='small' alt=$templateTitle}
                <h3>{$templateTitle}</h3>
            </div>
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''

    def private hierarchyItemsView(Entity it, String appName) '''
        «IF isLegacyApp»
            {* purpose of this template: «nameMultiple.formatForDisplay» tree items *}
            {assign var='hasNodes' value=false}
            {if isset($items) && (is_object($items) && $items->count() gt 0) || (is_array($items) && count($items) gt 0)}
                {assign var='hasNodes' value=true}
            {/if}
            {assign var='idPrefix' value="«name.formatForCode.toFirstLower»Tree`$rootId`"}

            <div id="{$idPrefix}" class="z-tree-container">
                <div id="«name.formatForCode.toFirstLower»TreeItems{$rootId}" class="z-tree-items">
                {if $hasNodes}
                    {«appName.formatForDB»TreeData objectType='«name.formatForCode»' tree=$items controller=$lct root=$rootId sortable=true}
                {/if}
                </div>
            </div>

            {pageaddvar name='javascript' value='«application.rootFolder»/«appName»/javascript/«appName»_tree.js'}
            {if $hasNodes}
                <script type="text/javascript">
                /* <![CDATA[ */
                    document.observe('dom:loaded', function() {
                        «application.vendorAndName»InitTreeNodes('«name.formatForCode»', '{{$rootId}}', «hasActions('display').displayBool», «(hasActions('edit') && !readOnly).displayBool»);
                        Zikula.TreeSortable.trees.itemTree{{$rootId}}.config.onSave = «application.vendorAndName»TreeSave;
                    });
                /* ]]> */
                </script>
                <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>
            {/if}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» tree items #}
            {% set hasNodes = false %}
            {% if items|default and items is iterable and items|length > 0 %}
                {% set hasNodes = true %}
            {% endif %}
            {% set idPrefix = '«name.formatForCode.toFirstLower»Tree' ~ rootId %}

            <p>
                <label for="{{ idPrefix }}SearchTerm">{{ __('Quick search') }}:</label>
                <input type="search" id="{{ idPrefix }}SearchTerm" value="" />
            </p>

            <div id="{{ idPrefix }}" class="tree-container">
                {% if hasNodes %}
                    <ul id="itemTree{{ rootId }}">
                        {{ «appName.formatForDB»_treeData(objectType='«name.formatForCode»', tree=items, controller=area, root=rootId) }}
                    </ul>
                {% endif %}
            </div>

            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Tree.js')) }}

            {% if hasNodes %}
                {{ pageAddAsset('javascript', 'web/jstree/dist/jstree.min.js') }}
                {{ pageAddAsset('stylesheet', 'web/jstree/dist/themes/default/style.min.css') }}
                <script type="text/javascript">
                /* <![CDATA[ */
                    ( function($) {
                        $(document).ready(function() {
                            «application.vendorAndName»InitTreeNodes('«name.formatForCode»', '{{ rootId|e('js') }}', «hasActions('display').displayBool», «(hasActions('edit') && !readOnly).displayBool»);

                            var tree = $('#{{ idPrefix|e('js') }}').jstree({
                                'core': {
                                    'multiple': false,
                                    'check_callback': true
                                },
                                'dnd': {
                                    'copy': false,
                                    'is_draggable': function(node) {
                                        // disable drag and drop for root category
                                        var inst = node.inst;
                                        var level = inst.get_path().length;

                                        return level > 1 ? true : false;
                                    }
                                },
                                'state': {
                                    'key': '{{ idPrefix|e('js') }}'
                                },
                                'plugins': [ 'dnd', 'search', 'state', 'wholerow' ]
                            });

                            tree.on('move_node.jstree', function (e, data) {
                                var node = data.node;
                                var parentId = data.parent;
                                var parentNode = $tree.jstree('get_node', parentId, false);

                                «application.vendorAndName»TreeSave(node, parentNode, 'bottom');
                            });

                            var searchStartDelay = false;
                            $('#{{ idPrefix|e('js') }}SearchTerm').keyup(function () {
                                if (searchStartDelay) {
                                    clearTimeout(searchStartDelay);
                                }
                                searchStartDelay = setTimeout(function () {
                                    var v = $('#{{ idPrefix|e('js') }}SearchTerm').val();
                                    $('#{{ idPrefix|e('js') }}').jstree(true).search(v);
                                }, 250);
                            });

                            $('.dropdown-toggle').dropdown();
                        });
                    })(jQuery);
                /* ]]> */
                </script>
                <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
            {% endif %}
        «ENDIF»
    '''

    def private isLegacyApp(Entity it) {
        application.targets('1.3.x')
    }
}
