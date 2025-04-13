package org.zikula.modulestudio.generator.cartridges.symfony.view.pages.view

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.IndexPagesHelper

class ViewHierarchy {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating tree view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFile('viewTree')
        fsa.generateFile(templateFilePath, hierarchyView(appName))

        templateFilePath = templateFile('viewTreeItems')
        fsa.generateFile(templateFilePath, hierarchyItemsView(appName))
    }

    def private hierarchyView(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» tree view #}
        {% extends routeArea == 'admin' ? '@«application.vendorAndName»/adminBase.html.twig' : '@«application.vendorAndName»/base.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% block title '«name.formatForDisplayCapital» hierarchy'|trans %}
        {% block admin_page_icon 'code-branch' %}
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-indexhierarchy">
                «(new IndexPagesHelper).commonHeader(it)»
                {% for rootId, treeNodes in trees %}
                    {{ include('@«application.vendorAndName»/«name.formatForCodeCapital»/viewTreeItems.html.twig', {rootId: rootId, items: treeNodes}) }}
                {% else %}
                    {{ include('@«application.vendorAndName»/«name.formatForCodeCapital»/viewTreeItems.html.twig', {rootId: 1, items: null}) }}
                {% endfor %}

                <br style="clear: left" />
            </div>
        {% endblock %}
        {% block footer %}
            {{ parent() }}
            {{ pageAddAsset('stylesheet', asset('jstree/dist/themes/default/style.min.css')) }}
            {{ pageAddAsset('javascript', asset('jstree/dist/jstree.min.js')) }}
            {{ pageAddAsset('javascript', zasset('@«application.vendorAndName»:js/«appName».Tree.js')) }}
        {% endblock %}
    '''

    def private hierarchyItemsView(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» tree items #}
        {% set hasNodes = items|default and items is iterable and items|length > 0 %}
        {% set idPrefix = '«name.formatForCode.toFirstLower»Tree' ~ rootId %}

        <p>
            <label for="{{ idPrefix }}SearchTerm">{% trans from 'messages' %}Quick search{% endtrans %}:</label>
            <input type="search" id="{{ idPrefix }}SearchTerm" value="" />
        </p>

        <div class="btn-toolbar" role="toolbar" aria-label="{{ 'Tree button toolbar'|trans({}, 'messages')|e('html_attr') }}">
            <div class="btn-group btn-group-sm" role="group" aria-label="«name.formatForDB» buttons">
                <button type="button" id="{{ idPrefix }}Expand" class="btn btn-secondary" title="{{ 'Expand all nodes'|trans({}, 'messages')|e('html_attr') }}"><i class="fas fa-expand"></i> {% trans from 'messages' %}Expand all{% endtrans %}</button>
                <button type="button" id="{{ idPrefix }}Collapse" class="btn btn-secondary" title="{{ 'Collapse all nodes'|trans({}, 'messages')|e('html_attr') }}"><i class="fas fa-compress"></i> {% trans from 'messages' %}Collapse all{% endtrans %}</button>
            </div>
        </div>
        <div class="clearfix">
            <div id="{{ idPrefix }}" class="tree-container" data-root-id="{{ rootId|e('html_attr') }}" data-object-type="«name.formatForCode»" data-urlargnames="«IF hasSluggableFields && slugUnique»slug«ELSE»«getPrimaryKey.name.formatForCode»«IF hasSluggableFields»,slug«ENDIF»«ENDIF»" data-has-detail="«hasDetailAction.displayBool»" data-has-edit="«hasEditAction.displayBool»">
                {% if hasNodes %}
                    {% set treeData = «appName.formatForDB»_treeData(objectType='«name.formatForCode»', tree=items, routeArea=routeArea, rootId=rootId) %}
                    <ul id="itemTree{{ rootId|e('html_attr') }}">
                        {{ treeData.nodes|raw }}
                    </ul>
                {% endif %}
            </div>
            {% if treeData|default %}
                <ul id="itemActionsForTree{{ rootId|e('html_attr') }}" class="d-none">
                    {{ treeData.actions|raw }}
                </ul>
            {% endif %}
            <p>&nbsp;</p>
            <p>&nbsp;</p>
            <p>&nbsp;</p>
            <p>&nbsp;</p>
        </div>
    '''
}
