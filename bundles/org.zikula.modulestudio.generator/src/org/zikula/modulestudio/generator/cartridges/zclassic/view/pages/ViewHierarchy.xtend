package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewHierarchy {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
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
        {# purpose of this template: «nameMultiple.formatForDisplay» tree view #}
        {% extends routeArea == 'admin' ? '«appName»::adminBase.html.twig' : '«appName»::base.html.twig' %}
        {% block title __('«name.formatForDisplayCapital» hierarchy') %}
        {% block adminPageIcon 'list-alt' %}
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewhierarchy">
                «IF null !== documentation && documentation != ''»

                    <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»') }}</p>
                «ENDIF»

                <p>
                    «IF hasEditAction»
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
    '''

    def private hierarchyItemsView(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» tree items #}
        {% set hasNodes = items|default and items is iterable and items|length > 0 %}
        {% set idPrefix = '«name.formatForCode.toFirstLower»Tree' ~ rootId %}

        <p>
            <label for="{{ idPrefix }}SearchTerm">{{ __('Quick search') }}:</label>
            <input type="search" id="{{ idPrefix }}SearchTerm" value="" />
        </p>

        <p><a href="#" id="{{ idPrefix }}Expand" title="{{ __('Expand all nodes') }}">{{ __('Expand all') }}</a> | <a href="#" id="{{ idPrefix }}Collapse" title="{{ __('Collapse all nodes') }}">{{ __('Collapse all') }}</a></p>

        <div id="{{ idPrefix }}" class="tree-container">
            {% if hasNodes %}
                <ul id="itemTree{{ rootId }}">
                    {{ «appName.formatForDB»_treeData(objectType='«name.formatForCode»', tree=items, routeArea=routeArea, rootId=rootId) }}
                </ul>
            {% endif %}
        </div>

        {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Tree.js')) }}

        {% if hasNodes %}
            {{ pageAddAsset('javascript', asset('jstree/dist/jstree.min.js')) }}
            {{ pageAddAsset('stylesheet', asset('jstree/dist/themes/default/style.min.css')) }}
            <script type="text/javascript">
            /* <![CDATA[ */
                ( function($) {
                    $(document).ready(function() {
                        «application.vendorAndName»InitTree('{{ idPrefix|e('js') }}', '«name.formatForCode»', '{{ rootId|e('js') }}', «hasDisplayAction.displayBool», «(hasEditAction && !readOnly).displayBool»);
                    });
                })(jQuery);
            /* ]]> */
            </script>
            <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
        {% endif %}
    '''
}
