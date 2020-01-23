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
        fsa.generateFile(templateFilePath, hierarchyView(appName, false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/viewTree')
            fsa.generateFile(templateFilePath, hierarchyView(appName, true))
        }

        templateFilePath = templateFile('viewTreeItems')
        fsa.generateFile(templateFilePath, hierarchyItemsView(appName, false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/viewTreeItems')
            fsa.generateFile(templateFilePath, hierarchyItemsView(appName, true))
        }
    }

    def private hierarchyView(Entity it, String appName, Boolean isAdmin) '''
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» tree view #}
            «IF application.targets('3.0')»
                {% extends «IF isAdmin»'@«appName»/adminBase.html.twig'«ELSE»'@«appName»/base.html.twig'«ENDIF» %}
            «ELSE»
                {% extends «IF isAdmin»'«appName»::adminBase.html.twig'«ELSE»'«appName»::base.html.twig'«ENDIF» %}
            «ENDIF»
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» tree view #}
            «IF application.targets('3.0')»
                {% extends routeArea == 'admin' ? '@«appName»/adminBase.html.twig' : '@«appName»/base.html.twig' %}
            «ELSE»
                {% extends routeArea == 'admin' ? '«appName»::adminBase.html.twig' : '«appName»::base.html.twig' %}
            «ENDIF»
        «ENDIF»
        «IF application.targets('3.0') && !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% block title «IF application.targets('3.0')»'«name.formatForDisplayCapital» hierarchy'|trans«ELSE»__('«name.formatForDisplayCapital» hierarchy')«ENDIF» %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'code-«IF application.targets('3.0')»branch«ELSE»fork«ENDIF»' %}
        «ENDIF»
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewhierarchy">
                «new ViewPagesHelper().commonHeader(it)»
                {% for rootId, treeNodes in trees %}
                    {{ include('@«appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewTreeItems.html.twig', {rootId: rootId, items: treeNodes}) }}
                {% else %}
                    {{ include('@«appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewTreeItems.html.twig', {rootId: 1, items: null}) }}
                {% endfor %}

                <br style="clear: left" />
                «IF !skipHookSubscribers»

                    {{ block('display_hooks') }}
                «ENDIF»
            </div>
        {% endblock %}
        «new ViewPagesHelper().callDisplayHooks(it)»
        {% block footer %}
            {{ parent() }}
            {{ pageAddAsset('stylesheet', asset('jstree/dist/themes/default/style.min.css')) }}
            {{ pageAddAsset('javascript', asset('jstree/dist/jstree.min.js')) }}
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Tree.js')) }}
        {% endblock %}
    '''

    def private hierarchyItemsView(Entity it, String appName, Boolean isAdmin) '''
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» tree items #}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» tree items #}
        «ENDIF»
        {% set hasNodes = items|default and items is iterable and items|length > 0 %}
        {% set idPrefix = '«name.formatForCode.toFirstLower»Tree' ~ rootId %}

        <p>
            <label for="{{ idPrefix }}SearchTerm">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Quick search{% endtrans %}«ELSE»{{ __('Quick search') }}«ENDIF»:</label>
            <input type="search" id="{{ idPrefix }}SearchTerm" value="" />
        </p>

        <div class="btn-toolbar" role="toolbar" aria-label="{{ «IF application.targets('3.0')»'Tree button toolbar'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Tree button toolbar')«ENDIF»|e('html_attr') }}">
            <div class="btn-group btn-group-sm" role="group" aria-label="«name.formatForDB» buttons">
                <button type="button" id="{{ idPrefix }}Expand" class="btn btn-«IF application.targets('3.0')»secondary«ELSE»info«ENDIF»" title="{{ «IF application.targets('3.0')»'Expand all nodes'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Expand all nodes')«ENDIF»|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-expand"></i> «IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Expand all{% endtrans %}«ELSE»{{ __('Expand all') }}«ENDIF»</button>
                <button type="button" id="{{ idPrefix }}Collapse" class="btn btn-«IF application.targets('3.0')»secondary«ELSE»info«ENDIF»" title="{{ «IF application.targets('3.0')»'Collapse all nodes'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Collapse all nodes')«ENDIF»|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-compress"></i> «IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Collapse all{% endtrans %}«ELSE»{{ __('Collapse all') }}«ENDIF»</button>
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
                <ul id="itemActionsForTree{{ rootId|e('html_attr') }}" class="«IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»">
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
