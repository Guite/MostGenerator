package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.HookProviderMode
import de.guite.modulestudio.metamodel.ItemActionsPosition
import de.guite.modulestudio.metamodel.ItemActionsStyle
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Display {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating display templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFile('display')
        fsa.generateFile(templateFilePath, displayView(appName, false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/display')
            fsa.generateFile(templateFilePath, displayView(appName, true))
        }

        if (tree != EntityTreeType.NONE) {
            templateFilePath = templateFile('displayTreeRelatives')
            fsa.generateFile(templateFilePath, treeRelatives(appName, false))

            if (application.separateAdminTemplates) {
                templateFilePath = templateFile('Admin/displayTreeRelatives')
                fsa.generateFile(templateFilePath, treeRelatives(appName, true))
            }
        }
    }

    def private displayView(Entity it, String appName, Boolean isAdmin) '''
        «val refedElems = getOutgoingJoinRelations.filter[r|r.target instanceof Entity && r.target.application == it.application]
                        + incoming.filter(ManyToManyRelationship).filter[r|r.bidirectional && r.source instanceof Entity && r.source.application == it.application]»
        «val objName = name.formatForCode»
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» display view #}
            {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : «IF isAdmin»'adminBase'«ELSE»'base'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» display view #}
            {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : (routeArea == 'admin' ? 'adminBase' : 'base') %}
        «ENDIF»
        {% extends '«application.appName»::' ~ baseTemplate ~ '.html.twig' %}
        {% block pageTitle %}{{ «objName»|«application.appName.formatForDB»_formattedTitle|default(__('«name.formatForDisplayCapital»')) }}{% endblock %}
        {% block title %}
            {% set templateTitle = «objName»|«application.appName.formatForDB»_formattedTitle|default(__('«name.formatForDisplayCapital»')) %}
            «templateHeading(appName)»
            «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.displayActionsPosition) && application.displayActionsStyle == ItemActionsStyle.DROPDOWN»
                «new ItemActionsView().generate(it, 'display', 'Start')»
            «ENDIF»
        {% endblock %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'eye' %}
        «ENDIF»
        {% block content %}
            {% set isQuickView = app.request.query.getBoolean('raw', false) %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-display">

            «IF useGroupingTabs('display')»
                <div class="zikula-bootstrap-tab-container">
                    <ul class="nav nav-tabs">
                        <li role="presentation" class="active">
                            <a id="fieldsTab" href="#tabFields" title="{{ __('Fields') }}" role="tab" data-toggle="tab">{{ __('Fields') }}</a>
                        </li>
                        «IF geographical»
                            <li role="presentation">
                                <a id="mapTab" href="#tabMap" title="{{ __('Map') }}" role="tab" data-toggle="tab">{{ __('Map') }}</a>
                            </li>
                        «ENDIF»
                        «IF !refedElems.empty»
                            <li role="presentation">
                                <a id="relationsTab" href="#tabRelations" title="{{ __('Related data') }}" role="tab" data-toggle="tab">{{ __('Related data') }}</a>
                            </li>
                        «ENDIF»
                        «IF attributable»
                            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                                <li role="presentation">
                                    <a id="attributesTab" href="#tabAttributes" title="{{ __('Attributes') }}" role="tab" data-toggle="tab">{{ __('Attributes') }}</a>
                                </li>
                            {% endif %}
                        «ENDIF»
                        «IF categorisable»
                            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                                <li role="presentation">
                                    <a id="categoriesTab" href="#tabCategories" title="{{ __('Categories') }}" role="tab" data-toggle="tab">{{ __('Categories') }}</a>
                                </li>
                            {% endif %}
                        «ENDIF»
                        «IF tree != EntityTreeType.NONE»
                            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::TREE_RELATIVES'), '«name.formatForCode»') %}
                                <li role="presentation">
                                    <a id="relativesTab" href="#tabRelatives" title="{{ __('Relatives') }}" role="tab" data-toggle="tab">{{ __('Relatives') }}</a>
                                </li>
                            {% endif %}
                        «ENDIF»
                        «IF uiHooksProvider != HookProviderMode.DISABLED»
                            <li role="presentation">
                                <a id="assignmentsTab" href="#tabAssignments" title="{{ __('Hook assignments') }}" role="tab" data-toggle="tab">{{ __('Hook assignments') }}</a>
                            </li>
                        «ENDIF»
                        «IF standardFields»
                            <li role="presentation">
                                <a id="standardFieldsTab" href="#tabStandardFields" title="{{ __('Creation and update') }}" role="tab" data-toggle="tab">{{ __('Creation and update') }}</a>
                            </li>
                        «ENDIF»
                        «IF !skipHookSubscribers»
                            <li role="presentation">
                                <a id="hooksTab" href="#tabHooks" title="{{ __('Hooks') }}" role="tab" data-toggle="tab">{{ __('Hooks') }}</a>
                            </li>
                        «ENDIF»
                    </ul>
                </div>

                <div class="tab-content">
                    <div role="tabpanel" class="tab-pane fade in active" id="tabFields" aria-labelledby="fieldsTab">
                        «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.displayActionsPosition) && application.displayActionsStyle != ItemActionsStyle.DROPDOWN»
                            «new ItemActionsView().generate(it, 'display', 'Start')»
                        «ENDIF»
                        <h3>{{ __('Fields') }}</h3>
                        «fieldDetails(appName)»
                    </div>
            «ELSE»
                «IF !refedElems.empty»
                    <div class="row">
                        <div class="col-sm-9">
                «ENDIF»
                «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.displayActionsPosition) && application.displayActionsStyle != ItemActionsStyle.DROPDOWN»
                    «new ItemActionsView().generate(it, 'display', 'Start')»
                «ENDIF»
                «fieldDetails(appName)»
            «ENDIF»

            «displayExtensions(objName, isAdmin)»

            «IF !skipHookSubscribers»
                {{ block('display_hooks') }}
            «ENDIF»
            «IF #[ItemActionsPosition.END, ItemActionsPosition.BOTH].contains(application.displayActionsPosition)»
                «new ItemActionsView().generate(it, 'display', 'End')»
            «ENDIF»
            «IF useGroupingTabs('display')»
                </div>
            «ELSE»
                «IF !refedElems.empty»
                        </div>
                        <div class="col-sm-3">
                            {{ block('related_items') }}
                        </div>
                    </div>
                «ENDIF»
            «ENDIF»
        </div>
        {% endblock %}
        «IF !refedElems.empty»
            «val relationHelper = new Relations»
            {% block related_items %}
                {% set isQuickView = app.request.query.getBoolean('raw', false) %}
                «IF useGroupingTabs('display')»
                    <div role="tabpanel" class="tab-pane fade" id="tabRelations" aria-labelledby="relationsTab">
                        <h3>{{ __('Related data') }}</h3>
                        «FOR elem : refedElems»«relationHelper.displayRelatedItems(elem, appName, it, isAdmin)»«ENDFOR»
                    </div>
                «ELSE»
                    «FOR elem : refedElems»«relationHelper.displayRelatedItems(elem, appName, it, isAdmin)»«ENDFOR»
                «ENDIF»
            {% endblock %}
        «ENDIF»
        «IF !skipHookSubscribers»
            {% block display_hooks %}
                {% if «name.formatForCode».supportsHookSubscribers() %}
                    «callDisplayHooks(appName)»
                {% endif %}
            {% endblock %}
        «ENDIF»
        «IF geographical»
            {% block footer %}
                {{ parent() }}
                «includeLeaflet('display', objName)»
            {% endblock %}
        «ENDIF»
    '''

    def private fieldDetails(Entity it, String appName) '''
        <dl>
            «FOR field : getFieldsForDisplayPage»«field.displayEntry»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    {% if «name.formatForCode».«geoFieldName» is not empty %}
                        <dt>{{ __('«geoFieldName.toFirstUpper»') }}</dt>
                        <dd>{{ «name.formatForCode».«geoFieldName»|«appName.formatForDB»_geoData }}</dd>
                    {% endif %}
                «ENDFOR»
            «ENDIF»
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»«relation.displayEntry(false)»«ENDFOR»
            «/*«FOR relation : outgoing.filter[OneToOneRelationship).filter[target instanceof Entity]»«relation.displayEntry(true)»«ENDFOR»*/»
        </dl>
    '''

    def private templateHeading(Entity it, String appName) '''{{ templateTitle«IF !skipHookSubscribers»|notifyFilters('«appName.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')|safeHtml«ENDIF» }}«IF hasVisibleWorkflow»{% if routeArea == 'admin' %} <small>({{ «name.formatForCode».workflowState|«appName.formatForDB»_objectState(false)|lower }})</small>{% endif %}«ENDIF»'''

    def private dispatch displayEntry(DerivedField it) '''
        {% if «entity.name.formatForCode».«name.formatForCode» is not empty«IF name == 'workflowState'» and routeArea == 'admin'«ENDIF» %}
            «displayEntryInner»
        {% endif %}
    '''
    def private dispatch displayEntry(BooleanField it) '''
        «displayEntryInner»
    '''

    def private displayEntryInner(DerivedField it) '''
        «val fieldLabel = if (name == 'workflowState') 'state' else name»
        <dt>{{ __('«fieldLabel.formatForDisplayCapital»') }}</dt>
        <dd>«displayEntryImpl»</dd>
    '''

    def private displayEntryImpl(DerivedField it) {
        new SimpleFields().displayField(it, entity.name.formatForCode, 'display')
    }

    def private displayEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val mainEntity = (if (useTarget) source else target) as Entity»
        «val linkEntity = (if (useTarget) target else source) as Entity»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        {% if «relObjName»|default %}
            <dt>{{ __('«relationAliasName.formatForDisplayCapital»') }}</dt>
            <dd>
              {% if not isQuickView %}
                  «IF linkEntity.hasDisplayAction»
                      <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.toLowerCase»_' ~ routeArea ~ 'display'«linkEntity.routeParams(relObjName, true)») }}">{% spaceless %}
                  «ENDIF»
                    {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
                  «IF linkEntity.hasDisplayAction»
                    {% endspaceless %}</a>
                    <a id="«linkEntity.name.formatForCode»Item{{ «relObjName».getKey() }}Display" href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display', {«IF !linkEntity.hasSluggableFields || !linkEntity.slugUnique»«linkEntity.routePkParams(relObjName, true)»«ENDIF»«linkEntity.appendSlug(relObjName, true)», raw: 1}) }}" title="{{ __('Open quick view window')|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ «relObjName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fa fa-id-card-o"></i></a>
                  «ENDIF»
              {% else %}
                  {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
              {% endif %}
            </dd>
        {% endif %}
    '''

    def private displayExtensions(Entity it, String objName, Boolean isAdmin) '''
        «IF geographical»
            «IF useGroupingTabs('display')»
                <div role="tabpanel" class="tab-pane fade" id="tabMap" aria-labelledby="mapTab">
                    <h3>{{ __('Map') }}</h3>
            «ELSE»
                <h3 class="«application.appName.toLowerCase»-map">{{ __('Map') }}</h3>
            «ENDIF»
            <div id="mapContainer" class="«application.appName.toLowerCase»-mapcontainer">
            </div>
            «IF useGroupingTabs('display')»
                </div>
            «ENDIF»
        «ENDIF»
        «IF useGroupingTabs('display')»
            {{ block('related_items') }}
        «ENDIF»
        «IF attributable»
            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                {{ include('@«application.appName»/Helper/includeAttributesDisplay.html.twig', {obj: «objName»«IF useGroupingTabs('display')», tabs: true«ENDIF»}) }}
            {% endif %}
        «ENDIF»
        «IF categorisable»
            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                {{ include('@«application.appName»/Helper/includeCategoriesDisplay.html.twig', {obj: «objName»«IF useGroupingTabs('display')», tabs: true«ENDIF»}) }}
            {% endif %}
        «ENDIF»
        «IF tree != EntityTreeType.NONE»
            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::TREE_RELATIVES'), '«name.formatForCode»') %}
                «IF useGroupingTabs('display')»
                <div role="tabpanel" class="tab-pane fade" id="tabRelatives" aria-labelledby="relativesTab">
                    <h3>{{ __('Relatives') }}</h3>
                «ELSE»
                <h3 class="relatives">{{ __('Relatives') }}</h3>
                «ENDIF»
                    {{ include(
                        '@«application.appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»displayTreeRelatives.html.twig',
                        {allParents: true, directParent: true, allChildren: true, directChildren: true, predecessors: true, successors: true, preandsuccessors: true}
                    ) }}
                «IF useGroupingTabs('display')»
                </div>
                «ENDIF»
            {% endif %}
        «ENDIF»
        «IF uiHooksProvider != HookProviderMode.DISABLED»
            «IF useGroupingTabs('display')»
            <div role="tabpanel" class="tab-pane fade" id="tabAssignments" aria-labelledby="assignmentsTab">
                <h3>{{ __('Hook assignments') }}</h3>
            «ELSE»
            <h3 class="hook-assignments">{{ __('Hook assignments') }}</h3>
            «ENDIF»
                {% if hookAssignments|length > 0 %}
                    <p>{{ __('This «name.formatForDisplay» is assigned to the following data objects:') }}</p>
                    <ul>
                    {% for assignment in hookAssignments %}
                    	<li><a href="{{ assignment.url|e('html_attr') }}" title="{{ __('View this object')|e('html_attr') }}">{{ assignment.date|localizeddate('medium', 'short') }} - {{ assignment.text }}</a></li>
                    {% endfor %}
                    </ul>
                {% else %}
                    <p>{{ __('This «name.formatForDisplay» is not assigned to any data objects yet.') }}</p>
                {% endif %}
            «IF useGroupingTabs('display')»
            </div>
            «ENDIF»
        «ENDIF»
        «IF standardFields»
            {{ include('@«application.appName»/Helper/includeStandardFieldsDisplay.html.twig', {obj: «objName»«IF useGroupingTabs('display')», tabs: true«ENDIF»}) }}
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        «IF useGroupingTabs('display')»
            <div role="tabpanel" class="tab-pane fade" id="tabHooks" aria-labelledby="hooksTab">
                <h3>{{ __('Hooks') }}</h3>
        «ENDIF»
        {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view', id=«name.formatForCode».getKey(), urlObject=currentUrlObject, outputAsArray=true) %}
        {% if hooks is iterable and hooks|length > 0 %}
            {% for area, hook in hooks %}
                <div class="z-displayhook" data-area="{{ area|e('html_attr') }}">{{ hook|raw }}</div>
            {% endfor %}
        {% endif %}
        «IF useGroupingTabs('display')»
            </div>
        «ENDIF»
    '''

    def private treeRelatives(Entity it, String appName, Boolean isAdmin) '''
        «val objName = name.formatForCode»
        «val pluginPrefix = application.appName.formatForDB»
        «IF application.separateAdminTemplates»
            {# purpose of this template: show different forms of relatives for a given tree node in «IF isAdmin»admin«ELSE»user«ENDIF» area #}
        «ELSE»
            {# purpose of this template: show different forms of relatives for a given tree node #}
        «ENDIF»
        {% import _self as relatives %}
        <h3>{{ __('Related «nameMultiple.formatForDisplay»') }}</h3>
        {% if «objName».lvl > 0 %}
            {% if allParents is not defined or allParents == true %}
                {% set allParents = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allParents') %}
                {% if allParents is not null and allParents is iterable and allParents|length > 0 %}
                    <h4>{{ __('All parents') }}</h4>
                    {{ relatives.list_relatives(allParents, routeArea) }}
                {% endif %}
            {% endif %}
            {% if directParent is not defined or directParent == true %}
                {% set directParent = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directParent') %}
                {% if directParent is not null %}
                    <h4>{{ __('Direct parent') }}</h4>
                    <ul>
                        <li><a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'display'«routeParams('directParent', true)») }}" title="{{ directParent|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}">{{ directParent|«application.appName.formatForDB»_formattedTitle }}</a></li>
                    </ul>
                {% endif %}
            {% endif %}
        {% endif %}
        {% if allChildren is not defined or allChildren == true %}
            {% set allChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allChildren') %}
            {% if allChildren is not null and allChildren is iterable and allChildren|length > 0 %}
                <h4>{{ __('All children') }}</h4>
                {{ relatives.list_relatives(allChildren, routeArea) }}
            {% endif %}
        {% endif %}
        {% if directChildren is not defined or directChildren == true %}
            {% set directChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directChildren') %}
            {% if directChildren is not null and directChildren is iterable and directChildren|length > 0 %}
                <h4>{{ __('Direct children') }}</h4>
                {{ relatives.list_relatives(directChildren, routeArea) }}
            {% endif %}
        {% endif %}
        {% if «objName».lvl > 0 %}
            {% if predecessors is not defined or predecessors == true %}
                {% set predecessors = «pluginPrefix»_treeSelection('«objName»', node=«objName», target='predecessors') %}
                {% if predecessors is not null and predecessors is iterable and predecessors|length > 0 %}
                    <h4>{{ __('Predecessors') }}</h4>
                    {{ relatives.list_relatives(predecessors, routeArea) }}
                {% endif %}
            {% endif %}
            {% if successors is not defined or successors == true %}
                {% set successors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='successors') %}
                {% if successors is not null and successors is iterable and successors|length > 0 %}
                    <h4>{{ __('Successors') }}</h4>
                    {{ relatives.list_relatives(successors, routeArea) }}
                {% endif %}
            {% endif %}
            {% if preandsuccessors is not defined or preandsuccessors == true %}
                {% set preandsuccessors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='preandsuccessors') %}
                {% if preandsuccessors is not null and preandsuccessors is iterable and preandsuccessors|length > 0 %}
                    <h4>{{ __('Siblings') }}</h4>
                    {{ relatives.list_relatives(preandsuccessors, routeArea) }}
                {% endif %}
            {% endif %}
        {% endif %}
        {% macro list_relatives(items, routeArea) %}
            «nodeLoop(appName, 'items')»
        {% endmacro %}
    '''

    def private nodeLoop(Entity it, String appName, String collectionName) '''
        «val objName = name.formatForCode»
        <ul>
        {% for node in «collectionName» %}
            <li><a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'display'«routeParams('node', true)») }}" title="{{ node|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}">{{ node|«application.appName.formatForDB»_formattedTitle }}</a></li>
        {% endfor %}
        </ul>
    '''
}
