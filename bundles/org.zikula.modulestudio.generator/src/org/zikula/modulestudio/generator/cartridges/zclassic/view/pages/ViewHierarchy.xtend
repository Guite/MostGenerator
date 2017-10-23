package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class ViewHierarchy {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating tree view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = templateFile('viewTree')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, hierarchyView(appName, false))
        }
        if (application.generateSeparateAdminTemplates) {
            templateFilePath = templateFile('Admin/viewTree')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, hierarchyView(appName, true))
            }
        }
        templateFilePath = templateFile('viewTreeItems')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, hierarchyItemsView(appName, false))
        }
        if (application.generateSeparateAdminTemplates) {
            templateFilePath = templateFile('Admin/viewTreeItems')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, hierarchyItemsView(appName, true))
            }
        }
    }

    def private hierarchyView(Entity it, String appName, Boolean isAdmin) '''
        «val objName = name.formatForCode»
        «IF application.generateSeparateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» tree view #}
            {% extends «IF isAdmin»'«appName»::adminBase.html.twig'«ELSE»'«appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» tree view #}
            {% extends routeArea == 'admin' ? '«appName»::adminBase.html.twig' : '«appName»::base.html.twig' %}
        «ENDIF»
        {% block title __('«name.formatForDisplayCapital» hierarchy') %}
        «IF !application.generateSeparateAdminTemplates || isAdmin»
            {% block adminPageIcon 'list-alt' %}
        «ENDIF»
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewhierarchy">
                «IF null !== documentation && documentation != ''»

                    <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»') }}</p>
                «ENDIF»

                <p>
                    «IF hasEditAction»
                    {% if hasPermission('«appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
                        {% set addRootTitle = __('Add root node') %}
                        <a id="treeAddRoot" href="javascript:void(0)" title="{{ addRootTitle|e('html_attr') }}" class="hidden" data-object-type="«objName»"><i class="fa fa-plus"></i> {{ addRootTitle }}</a>
                    {% endif %}
                    «ENDIF»
                    {% set switchTitle = __('Switch to table view') %}
                    <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view') }}" title="{{ switchTitle|e('html_attr') }}"><i class="fa fa-table"></i> {{ switchTitle }}</a>
                </p>

                {% for rootId, treeNodes in trees %}
                    {{ include('@«appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewTreeItems.html.twig', {rootId: rootId, items: treeNodes}) }}
                {% else %}
                    {{ include('@«appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewTreeItems.html.twig', {rootId: 1, items: null}) }}
                {% endfor %}

                <br style="clear: left" />
            </div>
        {% endblock %}
        {% block footer %}
            {{ parent() }}
            {{ pageAddAsset('stylesheet', asset('jstree/dist/themes/default/style.min.css')) }}
            {{ pageAddAsset('javascript', asset('jstree/dist/jstree.min.js')) }}
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Tree.js')) }}
        {% endblock %}
    '''

    def private hierarchyItemsView(Entity it, String appName, Boolean isAdmin) '''
        «IF application.generateSeparateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» tree items #}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» tree items #}
        «ENDIF»
        {% set hasNodes = items|default and items is iterable and items|length > 0 %}
        {% set idPrefix = '«name.formatForCode.toFirstLower»Tree' ~ rootId %}

        <p>
            <label for="{{ idPrefix }}SearchTerm">{{ __('Quick search') }}:</label>
            <input type="search" id="{{ idPrefix }}SearchTerm" value="" />
        </p>

        <div class="btn-toolbar" role="toolbar" aria-label="category button toolbar">
            <div class="btn-group btn-group-sm" role="group" aria-label="«name.formatForDB» buttons">
                <button type="button" id="{{ idPrefix }}Expand" class="btn btn-info" title="{{ __('Expand all nodes') }}"><i class="fa fa-expand"></i> {{ __('Expand all') }}</button>
                <button type="button" id="{{ idPrefix }}Collapse"class="btn btn-info" title="{{ __('Collapse all nodes') }}"><i class="fa fa-compress"></i> {{ __('Collapse all') }}</button>
            </div>
        </div>
        <div id="{{ idPrefix }}" class="tree-container" data-object-type="«name.formatForCode»" data-root-id="{{ rootId|e('html_attr') }}" data-has-display="«hasDisplayAction.displayBool»" data-has-edit="«(hasEditAction && !readOnly).displayBool»">
            {% if hasNodes %}
                <ul id="itemTree{{ rootId|e('html_attr') }}">
                    {{ «appName.formatForDB»_treeData(objectType='«name.formatForCode»', tree=items, routeArea=routeArea, rootId=rootId) }}
                </ul>
            {% endif %}
        </div>
    '''
}
