package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.view

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewPagesHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

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
        {% extends routeArea == 'admin' ? '@«appName»/adminBase.html.twig' : '@«appName»/base.html.twig' %}
        «IF !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% block title '«name.formatForDisplayCapital» hierarchy'|trans %}
        {% block admin_page_icon 'code-branch' %}
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewhierarchy">
                «(new ViewPagesHelper).commonHeader(it)»
                {% for rootId, treeNodes in trees %}
                    {{ include('@«appName»/«name.formatForCodeCapital»/viewTreeItems.html.twig', {rootId: rootId, items: treeNodes}) }}
                {% else %}
                    {{ include('@«appName»/«name.formatForCodeCapital»/viewTreeItems.html.twig', {rootId: 1, items: null}) }}
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

    def private hierarchyItemsView(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» tree items #}
        {% set hasNodes = items|default and items is iterable and items|length > 0 %}
        {% set idPrefix = '«name.formatForCode.toFirstLower»Tree' ~ rootId %}

        <p>
            <label for="{{ idPrefix }}SearchTerm">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Quick search{% endtrans %}:</label>
            <input type="search" id="{{ idPrefix }}SearchTerm" value="" />
        </p>

        <div class="btn-toolbar" role="toolbar" aria-label="{{ 'Tree button toolbar'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}">
            <div class="btn-group btn-group-sm" role="group" aria-label="«name.formatForDB» buttons">
                <button type="button" id="{{ idPrefix }}Expand" class="btn btn-secondary" title="{{ 'Expand all nodes'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}"><i class="fas fa-expand"></i> {% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Expand all{% endtrans %}</button>
                <button type="button" id="{{ idPrefix }}Collapse" class="btn btn-secondary" title="{{ 'Collapse all nodes'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}"><i class="fas fa-compress"></i> {% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Collapse all{% endtrans %}</button>
            </div>
        </div>
        <div class="clearfix">
            <div id="{{ idPrefix }}" class="tree-container" data-root-id="{{ rootId|e('html_attr') }}" data-object-type="«name.formatForCode»" data-urlargnames="«IF hasSluggableFields && slugUnique»slug«ELSE»«getPrimaryKey.name.formatForCode»«IF hasSluggableFields»,slug«ENDIF»«ENDIF»" data-has-display="«hasDisplayAction.displayBool»" data-has-edit="«(hasEditAction && !readOnly).displayBool»">
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
