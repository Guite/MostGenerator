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
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.MenuViews

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

    def private getReferredElements(Entity it) {
        getOutgoingJoinRelations.filter[r|r.target instanceof Entity && r.target.application == it.application]
        + incoming.filter(ManyToManyRelationship).filter[r|r.bidirectional && r.source instanceof Entity && r.source.application == it.application]
    }

    def private displayView(Entity it, String appName, Boolean isAdmin) '''
        «val objName = name.formatForCode»
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» display view #}
            {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : «IF isAdmin»'adminBase'«ELSE»'base'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» display view #}
            {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : (routeArea == 'admin' ? 'adminBase' : 'base') %}
        «ENDIF»
        {% extends '@«application.appName»/' ~ baseTemplate ~ '.html.twig' %}
        «IF !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% block pageTitle %}{{ «objName»|«application.appName.formatForDB»_formattedTitle|default('«name.formatForDisplayCapital»'|trans) }}{% endblock %}
        {% block title %}
            «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.displayActionsPosition) && application.displayActionsStyle == ItemActionsStyle.DROPDOWN»
                {% set isQuickView = app.request.query.getBoolean('raw', false) %}
            «ENDIF»
            {% set templateTitle = «objName»|«application.appName.formatForDB»_formattedTitle|default('«name.formatForDisplayCapital»'|trans) %}
            «templateHeading(appName)»
            «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.displayActionsPosition) && application.displayActionsStyle == ItemActionsStyle.DROPDOWN»
                {% if not isQuickView %}
                    «new MenuViews().itemActions(it, 'display', 'Start')»
                {% endif %}
            «ENDIF»
        {% endblock %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'eye' %}
        «ENDIF»
        {% block content %}
            {% set isQuickView = app.request.query.getBoolean('raw', false) %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-display">
                «content(appName, isAdmin)»
            </div>
            «IF hasCounterFieldsEntity»
                «FOR counterField : getCounterFields»
                    {{ «appName.toLowerCase»_increaseCounter(«objName», '«counterField.name.formatForCode»') }}
                «ENDFOR»
            «ENDIF»
        {% endblock %}
        «val refedElems = getReferredElements»
        «IF !refedElems.empty»
            «val relationHelper = new Relations»
            {% block related_items %}
                {% set isQuickView = app.request.query.getBoolean('raw', false) %}
                «IF useGroupingTabs('display')»
                    <div role="tabpanel" class="tab-pane fade" id="tabRelations" aria-labelledby="relationsTab">
                        <h3>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Related data{% endtrans %}</h3>
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

    def private content(Entity it, String appName, Boolean isAdmin) '''
        «val refedElems = getReferredElements»
        «IF useGroupingTabs('display')»
            «tabs»
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane fade show active" id="tabFields" aria-labelledby="fieldsTab">
                    «fieldSection(true)»
                </div>
                «displayExtensions(name.formatForCode, isAdmin)»
                «displayAdditions»
            </div>
        «ELSEIF !refedElems.empty»
            <div class="row">
                <div class="col-md-9">
                    «fieldSection(false)»
                    «displayExtensions(name.formatForCode, isAdmin)»
                    «displayAdditions»
                </div>
                <div class="col-md-3">
                    {{ block('related_items') }}
                </div>
            </div>
        «ELSE»
            «fieldSection(false)»
            «displayExtensions(name.formatForCode, isAdmin)»
            «displayAdditions»
        «ENDIF»
    '''

    def private tabs(Entity it) '''
        <div class="zikula-bootstrap-tab-container">
            <ul class="nav nav-tabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <a id="fieldsTab" href="#tabFields" title="{{ 'Fields'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link active">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Fields{% endtrans %}</a>
                </li>
                «IF geographical»
                    <li class="nav-item" role="presentation">
                        <a id="mapTab" href="#tabMap" title="{{ 'Map'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Map{% endtrans %}</a>
                    </li>
                «ENDIF»
                «IF !getReferredElements.empty»
                    <li class="nav-item" role="presentation">
                        <a id="relationsTab" href="#tabRelations" title="{{ 'Related data'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Related data{% endtrans %}</a>
                    </li>
                «ENDIF»
                «IF attributable»
                    {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                        <li class="nav-item" role="presentation">
                            <a id="attributesTab" href="#tabAttributes" title="{{ 'Attributes'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Attributes{% endtrans %}</a>
                        </li>
                    {% endif %}
                «ENDIF»
                «IF categorisable»
                    {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                        <li class="nav-item" role="presentation">
                            <a id="categoriesTab" href="#tabCategories" title="{{ 'Categories'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Categories{% endtrans %}</a>
                        </li>
                    {% endif %}
                «ENDIF»
                «IF tree != EntityTreeType.NONE»
                    {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::TREE_RELATIVES'), '«name.formatForCode»') %}
                        <li class="nav-item" role="presentation">
                            <a id="relativesTab" href="#tabRelatives" title="{{ 'Relatives'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Relatives{% endtrans %}</a>
                        </li>
                    {% endif %}
                «ENDIF»
                «IF uiHooksProvider != HookProviderMode.DISABLED»
                    <li class="nav-item" role="presentation">
                        <a id="assignmentsTab" href="#tabAssignments" title="{{ 'Hook assignments'|trans«IF !application.isSystemModule»({}, 'hooks')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hook assignments{% endtrans %}</a>
                    </li>
                «ENDIF»
                «IF standardFields»
                    <li class="nav-item" role="presentation">
                        <a id="standardFieldsTab" href="#tabStandardFields" title="{{ 'Creation and update'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF» }}" role="tab" data-toggle="tab" class="nav-link">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Creation and update{% endtrans %}</a>
                    </li>
                «ENDIF»
                «IF !skipHookSubscribers»
                    <li class="nav-item" role="presentation">
                        <a id="hooksTab" href="#tabHooks" title="{{ 'Hooks'|trans«IF !application.isSystemModule»({}, 'hooks')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hooks{% endtrans %}</a>
                    </li>
                «ENDIF»
            </ul>
        </div>
    '''

    def private fieldSection(Entity it, Boolean withHeading) '''
        «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.displayActionsPosition) && application.displayActionsStyle != ItemActionsStyle.DROPDOWN»
            {% if not isQuickView %}
                «new MenuViews().itemActions(it, 'display', 'Start')»
            {% endif %}
        «ENDIF»
        «IF withHeading»
            <h3>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Fields{% endtrans %}</h3>
        «ENDIF»
        <dl>
            «FOR field : getFieldsForDisplayPage»«field.displayEntry»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    {% if «name.formatForCode».«geoFieldName» is not empty %}
                        <dt>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}«geoFieldName.toFirstUpper»{% endtrans %}</dt>
                        <dd>{{ «name.formatForCode».«geoFieldName»|«application.appName.formatForDB»_geoData }}</dd>
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
        <dt>{% trans %}«fieldLabel.formatForDisplayCapital»{% endtrans %}</dt>
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
            <dt>{% trans«IF !application.isSystemModule» from '«linkEntity.name.formatForCode»'«ENDIF» %}«relationAliasName.formatForDisplayCapital»{% endtrans %}</dt>
            <dd>
              {% if not isQuickView %}
                  «IF linkEntity.hasDisplayAction»
                      <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.toLowerCase»_' ~ routeArea ~ 'display'«linkEntity.routeParams(relObjName, true)») }}">{% apply spaceless %}
                  «ENDIF»
                    {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
                  «IF linkEntity.hasDisplayAction»
                    {% endapply %}</a>
                    <a id="«linkEntity.name.formatForCode»Item{{ «relObjName».getKey() }}Display" href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display', {«IF !linkEntity.hasSluggableFields || !linkEntity.slugUnique»«linkEntity.routePkParams(relObjName, true)»«ENDIF»«linkEntity.appendSlug(relObjName, true)», raw: 1}) }}" title="{{ 'Open quick view window'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ «relObjName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fas fa-id-card"></i></a>
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
                    <h3>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Map{% endtrans %}</h3>
            «ELSE»
                <h3 class="«application.appName.toLowerCase»-map">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Map{% endtrans %}</h3>
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
                    <h3>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Relatives{% endtrans %}</h3>
                «ELSE»
                <h3 class="relatives">{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Relatives{% endtrans %}</h3>
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
                <h3>{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hook assignments{% endtrans %}</h3>
            «ELSE»
            <h3 class="hook-assignments">{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hook assignments{% endtrans %}</h3>
            «ENDIF»
                {% if hookAssignments|length > 0 %}
                    <p>{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}This «name.formatForDisplay» is assigned to the following data objects:{% endtrans %}</p>
                    <ul>
                    {% for assignment in hookAssignments %}
                        <li><a href="{{ assignment.url|e('html_attr') }}" title="{{ 'View this object'|trans«IF !application.isSystemModule»({}, 'hooks')«ENDIF»|e('html_attr') }}">{{ assignment.date|format_datetime('medium', 'short') }} - {{ assignment.text }}</a></li>
                    {% endfor %}
                    </ul>
                {% else %}
                    <p>{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}This «name.formatForDisplay» is not assigned to any data objects yet.{% endtrans %}</p>
                {% endif %}
            «IF useGroupingTabs('display')»
            </div>
            «ENDIF»
        «ENDIF»
        «IF standardFields»
            {{ include('@«application.appName»/Helper/includeStandardFieldsDisplay.html.twig', {obj: «objName»«IF useGroupingTabs('display')», tabs: true«ENDIF»}) }}
        «ENDIF»
    '''

    def private displayAdditions(Entity it) '''
        «IF !skipHookSubscribers»
            {{ block('display_hooks') }}
        «ENDIF»
        «IF #[ItemActionsPosition.END, ItemActionsPosition.BOTH].contains(application.displayActionsPosition)»
            {% if not isQuickView %}
                «new MenuViews().itemActions(it, 'display', 'End')»
            {% endif %}
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        «IF useGroupingTabs('display')»
            <div role="tabpanel" class="tab-pane fade" id="tabHooks" aria-labelledby="hooksTab">
                <h3>{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hooks{% endtrans %}</h3>
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
        «IF !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {#<h3>{% trans %}Related «nameMultiple.formatForDisplay»{% endtrans %}</h3>#}
        {% if «objName».lvl > 0 %}
            {% if allParents is not defined or allParents == true %}
                {% set parents = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allParents') %}
                {% if parents is not null and parents is iterable and parents|length > 0 %}
                    <h4>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}All parents{% endtrans %}</h4>
                    {{ _self.list_relatives(parents, routeArea) }}
                {% endif %}
            {% endif %}
            {% if directParent is not defined or directParent == true %}
                {% set parents = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directParent') %}
                {% if parents is not null and parents is iterable and parents|length > 0 %}
                    <h4>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Direct parent{% endtrans %}</h4>
                    {{ _self.list_relatives(parents, routeArea) }}
                {% endif %}
            {% endif %}
        {% endif %}
        {% if allChildren is not defined or allChildren == true %}
            {% set allChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allChildren') %}
            {% if allChildren is not null and allChildren is iterable and allChildren|length > 0 %}
                <h4>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}All children{% endtrans %}</h4>
                {{ _self.list_relatives(allChildren, routeArea) }}
            {% endif %}
        {% endif %}
        {% if directChildren is not defined or directChildren == true %}
            {% set directChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directChildren') %}
            {% if directChildren is not null and directChildren is iterable and directChildren|length > 0 %}
                <h4>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Direct children{% endtrans %}</h4>
                {{ _self.list_relatives(directChildren, routeArea) }}
            {% endif %}
        {% endif %}
        {% if «objName».lvl > 0 %}
            {% if predecessors is not defined or predecessors == true %}
                {% set predecessors = «pluginPrefix»_treeSelection('«objName»', node=«objName», target='predecessors') %}
                {% if predecessors is not null and predecessors is iterable and predecessors|length > 0 %}
                    <h4>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Predecessors{% endtrans %}</h4>
                    {{ _self.list_relatives(predecessors, routeArea) }}
                {% endif %}
            {% endif %}
            {% if successors is not defined or successors == true %}
                {% set successors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='successors') %}
                {% if successors is not null and successors is iterable and successors|length > 0 %}
                    <h4>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Successors{% endtrans %}</h4>
                    {{ _self.list_relatives(successors, routeArea) }}
                {% endif %}
            {% endif %}
            {% if preandsuccessors is not defined or preandsuccessors == true %}
                {% set preandsuccessors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='preandsuccessors') %}
                {% if preandsuccessors is not null and preandsuccessors is iterable and preandsuccessors|length > 0 %}
                    <h4>{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Siblings{% endtrans %}</h4>
                    {{ _self.list_relatives(preandsuccessors, routeArea) }}
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
