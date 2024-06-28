package org.zikula.modulestudio.generator.cartridges.symfony.view.pages

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.ItemActionsPosition
import de.guite.modulestudio.metamodel.ItemActionsStyle
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.MenuViews
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.Relations
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.SimpleFields
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

class Detail {

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

        var templateFilePath = templateFile('detail')
        fsa.generateFile(templateFilePath, displayView(appName))

        if (tree != EntityTreeType.NONE) {
            templateFilePath = templateFile('detailTreeRelatives')
            fsa.generateFile(templateFilePath, treeRelatives(appName))
        }
    }

    def private getReferredElements(Entity it) {
        outgoingReferredElements + incomingReferredElements
    }

    def private getOutgoingReferredElements(Entity it) {
        outgoingJoinRelations.filter[r|r.target instanceof Entity && r.target.application == it.application]
    }

    def private getIncomingReferredElements(Entity it) {
        incoming.filter(ManyToManyRelationship).filter[r|r.bidirectional && r.source instanceof Entity && r.source.application == it.application]
    }

    def private displayView(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» display view #}
        {% set baseTemplate = app.request.query.getBoolean('raw', false) ? 'raw' : (routeArea == 'admin' ? 'adminBase' : 'base') %}
        {% extends '@«application.vendorAndName»/' ~ baseTemplate ~ '.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% block pageTitle %}{{ «objName»|«application.appName.formatForDB»_formattedTitle|default('«name.formatForDisplayCapital»'|trans) }}{% endblock %}
        {% block title %}
            «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.detailActionsPosition) && application.detailActionsStyle == ItemActionsStyle.DROPDOWN»
                {% set isQuickView = app.request.query.getBoolean('raw', false) %}
            «ENDIF»
            {% set templateTitle = «objName»|«application.appName.formatForDB»_formattedTitle|default('«name.formatForDisplayCapital»'|trans) %}
            «templateHeading(appName)»
            «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.detailActionsPosition) && application.detailActionsStyle == ItemActionsStyle.DROPDOWN»
                {% if not isQuickView %}
                    «new MenuViews().itemActions(it, 'detail', 'Start')»
                {% endif %}
            «ENDIF»
        {% endblock %}
        {% block admin_page_icon 'eye' %}
        {% block content %}
            {% set isQuickView = app.request.query.getBoolean('raw', false) %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-display">
                «content(appName)»
            </div>
        {% endblock %}
        «val refedElems = getReferredElements»
        «IF !refedElems.empty»
            {% block related_items %}
                {% set isQuickView = app.request.query.getBoolean('raw', false) %}
                «IF useGroupingTabs('detail')»
                    <div role="tabpanel" class="tab-pane fade" id="tabRelations" aria-labelledby="relationsTab">
                        <h3>{% trans from 'messages' %}Related data{% endtrans %}</h3>
                        «displayRelatedItems(appName)»
                    </div>
                «ELSE»
                    «displayRelatedItems(appName)»
                «ENDIF»
            {% endblock %}
        «ENDIF»
        «IF geographical»
            {% block footer %}
                {{ parent() }}
                «includeLeaflet('detail', objName)»
            {% endblock %}
        «ENDIF»
    '''

    def private displayRelatedItems(Entity it, String appName) '''
        «val relationHelper = new Relations»
        «FOR elem : incomingReferredElements»
            «relationHelper.displayRelatedItems(elem, appName, it, false)»
        «ENDFOR»
        «FOR elem : outgoingReferredElements»
            «relationHelper.displayRelatedItems(elem, appName, it, true)»
        «ENDFOR»
    '''

    def private content(Entity it, String appName) '''
        «val refedElems = getReferredElements»
        «IF useGroupingTabs('detail')»
            «tabs»
            <div class="tab-content">
                <div role="tabpanel" class="tab-pane fade show active" id="tabFields" aria-labelledby="fieldsTab">
                    «fieldSection(true)»
                </div>
                «displayExtensions(name.formatForCode)»
                «displayAdditions»
            </div>
        «ELSEIF !refedElems.empty»
            <div class="row">
                <div class="col-md-9">
                    «fieldSection(false)»
                    «displayExtensions(name.formatForCode)»
                    «displayAdditions»
                </div>
                <div class="col-md-3">
                    {{ block('related_items') }}
                </div>
            </div>
        «ELSE»
            «fieldSection(false)»
            «displayExtensions(name.formatForCode)»
            «displayAdditions»
        «ENDIF»
    '''

    def private tabs(Entity it) '''
        <div class="zikula-bootstrap-tab-container">
            <ul class="nav nav-tabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <a id="fieldsTab" href="#tabFields" title="{{ 'Fields'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link active">{% trans from 'messages' %}Fields{% endtrans %}</a>
                </li>
                «IF geographical»
                    <li class="nav-item" role="presentation">
                        <a id="mapTab" href="#tabMap" title="{{ 'Map'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from 'messages' %}Map{% endtrans %}</a>
                    </li>
                «ENDIF»
                «IF !getReferredElements.empty»
                    <li class="nav-item" role="presentation">
                        <a id="relationsTab" href="#tabRelations" title="{{ 'Related data'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from 'messages' %}Related data{% endtrans %}</a>
                    </li>
                «ENDIF»
                «IF tree != EntityTreeType.NONE»
                    {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Bundle\\Helper\\FeatureActivationHelper::TREE_RELATIVES'), '«name.formatForCode»') %}
                        <li class="nav-item" role="presentation">
                            <a id="relativesTab" href="#tabRelatives" title="{{ 'Relatives'|trans({}, 'messages')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from 'messages' %}Relatives{% endtrans %}</a>
                        </li>
                    {% endif %}
                «ENDIF»
                «IF standardFields»
                    <li class="nav-item" role="presentation">
                        <a id="standardFieldsTab" href="#tabStandardFields" title="{{ 'Creation and update'|trans({}, 'messages') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from 'messages' %}Creation and update{% endtrans %}</a>
                    </li>
                «ENDIF»
            </ul>
        </div>
    '''

    def private fieldSection(Entity it, Boolean withHeading) '''
        «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.detailActionsPosition) && application.detailActionsStyle != ItemActionsStyle.DROPDOWN»
            {% if not isQuickView %}
                «new MenuViews().itemActions(it, 'detail', 'Start')»
            {% endif %}
        «ENDIF»
        «IF withHeading»
            <h3>{% trans from 'messages' %}Fields{% endtrans %}</h3>
        «ENDIF»
        <dl>
            «FOR field : getFieldsForDetailPage»«field.displayEntry»«ENDFOR»
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»«relation.displayEntry(false)»«ENDFOR»
            «/*«FOR relation : outgoing.filter[OneToOneRelationship).filter[target instanceof Entity]»«relation.displayEntry(true)»«ENDFOR»*/»
        </dl>
    '''

    def private templateHeading(Entity it, String appName) '''{{ templateTitle }}«IF hasVisibleWorkflow»{% if routeArea == 'admin' %} <small>({{ «name.formatForCode».workflowState|«appName.formatForDB»_objectState(false)|lower }})</small>{% endif %}«ENDIF»'''

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
        new SimpleFields().displayField(it, entity.name.formatForCode, 'detail')
    }

    def private displayEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val mainEntity = (if (useTarget) source else target) as Entity»
        «val linkEntity = (if (useTarget) target else source) as Entity»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        {% if «relObjName»|default %}
            <dt>{% trans from '«linkEntity.name.formatForCode»' %}«relationAliasName.formatForDisplayCapital»{% endtrans %}</dt>
            <dd>
              {% if not isQuickView %}
                  «IF linkEntity.hasDetailAction»
                      <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.toLowerCase»_detail'«linkEntity.routeParams(relObjName, true)») }}">{% apply spaceless %}
                  «ENDIF»
                    {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
                  «IF linkEntity.hasDetailAction»
                    {% endapply %}</a>
                    <a id="«linkEntity.name.formatForCode»Item{{ «relObjName».getKey() }}Display" href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_detail', {«IF !linkEntity.hasSluggableFields || !linkEntity.slugUnique»«linkEntity.routePkParams(relObjName, true)»«ENDIF»«linkEntity.appendSlug(relObjName, true)», raw: 1}) }}" title="{{ 'Open quick view window'|trans({}, 'messages')|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ «relObjName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fas fa-id-card"></i></a>
                  «ENDIF»
              {% else %}
                  {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
              {% endif %}
            </dd>
        {% endif %}
    '''

    def private displayExtensions(Entity it, String objName) '''
        «IF geographical»
            «IF useGroupingTabs('detail')»
                <div role="tabpanel" class="tab-pane fade" id="tabMap" aria-labelledby="mapTab">
                    <h3>{% trans from 'messages' %}Map{% endtrans %}</h3>
            «ELSE»
                <h3 class="«application.appName.toLowerCase»-map">{% trans from 'messages' %}Map{% endtrans %}</h3>
            «ENDIF»
            <div id="mapContainer" class="«application.appName.toLowerCase»-mapcontainer">
            </div>
            «IF useGroupingTabs('detail')»
                </div>
            «ENDIF»
        «ENDIF»
        «IF useGroupingTabs('detail')»
            {{ block('related_items') }}
        «ENDIF»
        «IF tree != EntityTreeType.NONE»
            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Bundle\\Helper\\FeatureActivationHelper::TREE_RELATIVES'), '«name.formatForCode»') %}
                «IF useGroupingTabs('detail')»
                <div role="tabpanel" class="tab-pane fade" id="tabRelatives" aria-labelledby="relativesTab">
                    <h3>{% trans from 'messages' %}Relatives{% endtrans %}</h3>
                «ELSE»
                <h3 class="relatives">{% trans from 'messages' %}Relatives{% endtrans %}</h3>
                «ENDIF»
                    {{ include(
                        '@«application.vendorAndName»/«name.formatForCodeCapital»/displayTreeRelatives.html.twig',
                        {allParents: true, directParent: true, allChildren: true, directChildren: true, predecessors: true, successors: true, preandsuccessors: true}
                    ) }}
                «IF useGroupingTabs('detail')»
                </div>
                «ENDIF»
            {% endif %}
        «ENDIF»
        «IF standardFields»
            {{ include('@«application.vendorAndName»/Helper/includeStandardFieldsDisplay.html.twig', {obj: «objName»«IF useGroupingTabs('detail')», tabs: true«ENDIF»}) }}
        «ENDIF»
    '''

    def private displayAdditions(Entity it) '''
        «IF #[ItemActionsPosition.END, ItemActionsPosition.BOTH].contains(application.detailActionsPosition)»
            {% if not isQuickView %}
                «new MenuViews().itemActions(it, 'detail', 'End')»
            {% endif %}
        «ENDIF»
    '''

    def private treeRelatives(Entity it, String appName) '''
        «val objName = name.formatForCode»
        «val pluginPrefix = application.appName.formatForDB»
        {# purpose of this template: show different forms of relatives for a given tree node #}
        {% trans_default_domain '«name.formatForCode»' %}
        {#<h3>{% trans %}Related «nameMultiple.formatForDisplay»{% endtrans %}</h3>#}
        {% if «objName».lvl > 0 %}
            {% if allParents is not defined or allParents == true %}
                {% set parents = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allParents') %}
                {% if parents is not null and parents is iterable and parents|length > 0 %}
                    <h4>{% trans from 'messages' %}All parents{% endtrans %}</h4>
                    {{ _self.list_relatives(parents) }}
                {% endif %}
            {% endif %}
            {% if directParent is not defined or directParent == true %}
                {% set parents = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directParent') %}
                {% if parents is not null and parents is iterable and parents|length > 0 %}
                    <h4>{% trans from 'messages' %}Direct parent{% endtrans %}</h4>
                    {{ _self.list_relatives(parents) }}
                {% endif %}
            {% endif %}
        {% endif %}
        {% if allChildren is not defined or allChildren == true %}
            {% set allChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allChildren') %}
            {% if allChildren is not null and allChildren is iterable and allChildren|length > 0 %}
                <h4>{% trans from 'messages' %}All children{% endtrans %}</h4>
                {{ _self.list_relatives(allChildren) }}
            {% endif %}
        {% endif %}
        {% if directChildren is not defined or directChildren == true %}
            {% set directChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directChildren') %}
            {% if directChildren is not null and directChildren is iterable and directChildren|length > 0 %}
                <h4>{% trans from 'messages' %}Direct children{% endtrans %}</h4>
                {{ _self.list_relatives(directChildren) }}
            {% endif %}
        {% endif %}
        {% if «objName».lvl > 0 %}
            {% if predecessors is not defined or predecessors == true %}
                {% set predecessors = «pluginPrefix»_treeSelection('«objName»', node=«objName», target='predecessors') %}
                {% if predecessors is not null and predecessors is iterable and predecessors|length > 0 %}
                    <h4>{% trans from 'messages' %}Predecessors{% endtrans %}</h4>
                    {{ _self.list_relatives(predecessors) }}
                {% endif %}
            {% endif %}
            {% if successors is not defined or successors == true %}
                {% set successors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='successors') %}
                {% if successors is not null and successors is iterable and successors|length > 0 %}
                    <h4>{% trans from 'messages' %}Successors{% endtrans %}</h4>
                    {{ _self.list_relatives(successors) }}
                {% endif %}
            {% endif %}
            {% if preandsuccessors is not defined or preandsuccessors == true %}
                {% set preandsuccessors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='preandsuccessors') %}
                {% if preandsuccessors is not null and preandsuccessors is iterable and preandsuccessors|length > 0 %}
                    <h4>{% trans from 'messages' %}Siblings{% endtrans %}</h4>
                    {{ _self.list_relatives(preandsuccessors) }}
                {% endif %}
            {% endif %}
        {% endif %}
        {% macro list_relatives(items) %}
            «nodeLoop(appName, 'items')»
        {% endmacro %}
    '''

    def private nodeLoop(Entity it, String appName, String collectionName) '''
        «val objName = name.formatForCode»
        <ul>
        {% for node in «collectionName» %}
            <li><a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_detail'«routeParams('node', true)») }}" title="{{ node|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}">{{ node|«application.appName.formatForDB»_formattedTitle }}</a></li>
        {% endfor %}
        </ul>
    '''
}
