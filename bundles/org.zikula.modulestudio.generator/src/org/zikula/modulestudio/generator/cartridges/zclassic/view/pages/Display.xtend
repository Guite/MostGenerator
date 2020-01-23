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
        «IF application.targets('3.0')»
            {% extends '@«application.appName»/' ~ baseTemplate ~ '.html.twig' %}
        «ELSE»
            {% extends '«application.appName»::' ~ baseTemplate ~ '.html.twig' %}
        «ENDIF»
        «IF application.targets('3.0') && !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% block pageTitle %}{{ «objName»|«application.appName.formatForDB»_formattedTitle|default(«IF application.targets('3.0')»'«name.formatForDisplayCapital»'|trans«ELSE»__('«name.formatForDisplayCapital»')«ENDIF») }}{% endblock %}
        {% block title %}
            «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.displayActionsPosition) && application.displayActionsStyle == ItemActionsStyle.DROPDOWN»
                {% set isQuickView = app.request.query.getBoolean('raw', false) %}
            «ENDIF»
            {% set templateTitle = «objName»|«application.appName.formatForDB»_formattedTitle|default(«IF application.targets('3.0')»'«name.formatForDisplayCapital»'|trans«ELSE»__('«name.formatForDisplayCapital»')«ENDIF») %}
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
        {% endblock %}
        «val refedElems = getReferredElements»
        «IF !refedElems.empty»
            «val relationHelper = new Relations»
            {% block related_items %}
                {% set isQuickView = app.request.query.getBoolean('raw', false) %}
                «IF useGroupingTabs('display')»
                    <div role="tabpanel" class="tab-pane fade" id="tabRelations" aria-labelledby="relationsTab">
                        <h3>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Related data{% endtrans %}«ELSE»{{ __('Related data') }}«ENDIF»</h3>
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
                <div role="tabpanel" class="tab-pane fade «IF application.targets('3.0')»show«ELSE»in«ENDIF» active" id="tabFields" aria-labelledby="fieldsTab">
                    «fieldSection(true)»
                </div>
                «displayExtensions(name.formatForCode, isAdmin)»
                «displayAdditions»
            </div>
        «ELSEIF !refedElems.empty»
            <div class="row">
                <div class="col-«IF application.targets('3.0')»md«ELSE»sm«ENDIF»-9">
                    «fieldSection(false)»
                    «displayExtensions(name.formatForCode, isAdmin)»
                    «displayAdditions»
                </div>
                <div class="col-«IF application.targets('3.0')»md«ELSE»sm«ENDIF»-3">
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
                <li class="«IF application.targets('3.0')»nav-item«ELSE»active«ENDIF»" role="presentation">
                    <a id="fieldsTab" href="#tabFields" title="{{ «IF application.targets('3.0')»'Fields'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Fields')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link active"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Fields{% endtrans %}«ELSE»{{ __('Fields') }}«ENDIF»</a>
                </li>
                «IF geographical»
                    <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                        <a id="mapTab" href="#tabMap" title="{{ «IF application.targets('3.0')»'Map'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Map')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Map{% endtrans %}«ELSE»{{ __('Map') }}«ENDIF»</a>
                    </li>
                «ENDIF»
                «IF !getReferredElements.empty»
                    <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                        <a id="relationsTab" href="#tabRelations" title="{{ «IF application.targets('3.0')»'Related data'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Related data')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Related data{% endtrans %}«ELSE»{{ __('Related data') }}«ENDIF»</a>
                    </li>
                «ENDIF»
                «IF attributable»
                    {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                        <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                            <a id="attributesTab" href="#tabAttributes" title="{{ «IF application.targets('3.0')»'Attributes'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Attributes')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Attributes{% endtrans %}«ELSE»{{ __('Attributes') }}«ENDIF»</a>
                        </li>
                    {% endif %}
                «ENDIF»
                «IF categorisable»
                    {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                        <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                            <a id="categoriesTab" href="#tabCategories" title="{{ «IF application.targets('3.0')»'Categories'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Categories')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Categories{% endtrans %}«ELSE»{{ __('Categories') }}«ENDIF»</a>
                        </li>
                    {% endif %}
                «ENDIF»
                «IF tree != EntityTreeType.NONE»
                    {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::TREE_RELATIVES'), '«name.formatForCode»') %}
                        <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                            <a id="relativesTab" href="#tabRelatives" title="{{ «IF application.targets('3.0')»'Relatives'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Relatives')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Relatives{% endtrans %}«ELSE»{{ __('Relatives') }}«ENDIF»</a>
                        </li>
                    {% endif %}
                «ENDIF»
                «IF uiHooksProvider != HookProviderMode.DISABLED»
                    <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                        <a id="assignmentsTab" href="#tabAssignments" title="{{ «IF application.targets('3.0')»'Hook assignments'|trans«IF !application.isSystemModule»({}, 'hooks')«ENDIF»«ELSE»__('Hook assignments')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hook assignments{% endtrans %}«ELSE»{{ __('Hook assignments') }}«ENDIF»</a>
                    </li>
                «ENDIF»
                «IF standardFields»
                    <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                        <a id="standardFieldsTab" href="#tabStandardFields" title="{{ «IF application.targets('3.0')»'Creation and update'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Creation and update')«ENDIF» }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Creation and update{% endtrans %}«ELSE»{{ __('Creation and update') }}«ENDIF»</a>
                    </li>
                «ENDIF»
                «IF !skipHookSubscribers»
                    <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                        <a id="hooksTab" href="#tabHooks" title="{{ «IF application.targets('3.0')»'Hooks'|trans«IF !application.isSystemModule»({}, 'hooks')«ENDIF»«ELSE»__('Hooks')«ENDIF»|e('html_attr') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hooks{% endtrans %}«ELSE»{{ __('Hooks') }}«ENDIF»</a>
                    </li>
                «ENDIF»
            </ul>
        </div>
    '''

    def private fieldSection(Entity it, Boolean withHeading) '''
        «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.displayActionsPosition) && application.displayActionsStyle != ItemActionsStyle.DROPDOWN»
            «new MenuViews().itemActions(it, 'display', 'Start')»
        «ENDIF»
        «IF withHeading»
            <h3>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Fields{% endtrans %}«ELSE»{{ __('Fields') }}«ENDIF»</h3>
        «ENDIF»
        <dl>
            «FOR field : getFieldsForDisplayPage»«field.displayEntry»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    {% if «name.formatForCode».«geoFieldName» is not empty %}
                        <dt>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}«geoFieldName.toFirstUpper»{% endtrans %}«ELSE»{{ __('«geoFieldName.toFirstUpper»') }}«ENDIF»</dt>
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
        <dt>«IF application.targets('3.0')»{% trans %}«fieldLabel.formatForDisplayCapital»{% endtrans %}«ELSE»{{ __('«fieldLabel.formatForDisplayCapital»') }}«ENDIF»</dt>
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
            <dt>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from '«linkEntity.name.formatForCode»'«ENDIF» %}«relationAliasName.formatForDisplayCapital»{% endtrans %}«ELSE»{{ __('«relationAliasName.formatForDisplayCapital»') }}«ENDIF»</dt>
            <dd>
              {% if not isQuickView %}
                  «IF linkEntity.hasDisplayAction»
                      <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.toLowerCase»_' ~ routeArea ~ 'display'«linkEntity.routeParams(relObjName, true)») }}">{% «IF application.targets('3.0')»apply spaceless«ELSE»spaceless«ENDIF» %}
                  «ENDIF»
                    {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
                  «IF linkEntity.hasDisplayAction»
                    {% «IF application.targets('3.0')»endapply«ELSE»endspaceless«ENDIF» %}</a>
                    <a id="«linkEntity.name.formatForCode»Item{{ «relObjName».getKey() }}Display" href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display', {«IF !linkEntity.hasSluggableFields || !linkEntity.slugUnique»«linkEntity.routePkParams(relObjName, true)»«ENDIF»«linkEntity.appendSlug(relObjName, true)», raw: 1}) }}" title="{{ «IF application.targets('3.0')»'Open quick view window'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Open quick view window')«ENDIF»|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window «IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»" data-modal-title="{{ «relObjName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-id-card«IF !application.targets('3.0')»-o«ENDIF»"></i></a>
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
                    <h3>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Map{% endtrans %}«ELSE»{{ __('Map') }}«ENDIF»</h3>
            «ELSE»
                <h3 class="«application.appName.toLowerCase»-map">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Map{% endtrans %}«ELSE»{{ __('Map') }}«ENDIF»</h3>
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
                    <h3>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Relatives{% endtrans %}«ELSE»{{ __('Relatives') }}«ENDIF»</h3>
                «ELSE»
                <h3 class="relatives">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Relatives{% endtrans %}«ELSE»{{ __('Relatives') }}«ENDIF»</h3>
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
                <h3>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hook assignments{% endtrans %}«ELSE»{{ __('Hook assignments') }}«ENDIF»</h3>
            «ELSE»
            <h3 class="hook-assignments">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hook assignments{% endtrans %}«ELSE»{{ __('Hook assignments') }}«ENDIF»</h3>
            «ENDIF»
                {% if hookAssignments|length > 0 %}
                    «IF application.targets('3.0')»
                        <p>{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}This «name.formatForDisplay» is assigned to the following data objects:{% endtrans %}</p>
                    «ELSE»
                        <p>{{ __('This «name.formatForDisplay» is assigned to the following data objects:') }}</p>
                    «ENDIF»
                    <ul>
                    {% for assignment in hookAssignments %}
                        <li><a href="{{ assignment.url|e('html_attr') }}" title="{{ «IF application.targets('3.0')»'View this object'|trans«IF !application.isSystemModule»({}, 'hooks')«ENDIF»«ELSE»__('View this object')«ENDIF»|e('html_attr') }}">{{ assignment.date|«IF application.targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('medium', 'short') }} - {{ assignment.text }}</a></li>
                    {% endfor %}
                    </ul>
                {% else %}
                    «IF application.targets('3.0')»
                        <p>{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}This «name.formatForDisplay» is not assigned to any data objects yet.{% endtrans %}</p>
                    «ELSE»
                        <p>{{ __('This «name.formatForDisplay» is not assigned to any data objects yet.') }}</p>
                    «ENDIF»
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
            «new MenuViews().itemActions(it, 'display', 'End')»
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        «IF useGroupingTabs('display')»
            <div role="tabpanel" class="tab-pane fade" id="tabHooks" aria-labelledby="hooksTab">
                <h3>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'hooks'«ENDIF» %}Hooks{% endtrans %}«ELSE»{{ __('Hooks') }}«ENDIF»</h3>
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
        «IF application.targets('3.0') && !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        «IF !application.targets('3.0')»
            {% import _self as relatives %}
        «ENDIF»
        <h3>«IF application.targets('3.0')»{% trans %}Related «nameMultiple.formatForDisplay»{% endtrans %}«ELSE»{{ __('Related «nameMultiple.formatForDisplay»') }}«ENDIF»</h3>
        {% if «objName».lvl > 0 %}
            {% if allParents is not defined or allParents == true %}
                {% set allParents = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allParents') %}
                {% if allParents is not null and allParents is iterable and allParents|length > 0 %}
                    <h4>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}All parents{% endtrans %}«ELSE»{{ __('All parents') }}«ENDIF»</h4>
                    {{ «IF application.targets('3.0')»_self«ELSE»relatives«ENDIF».list_relatives(allParents, routeArea) }}
                {% endif %}
            {% endif %}
            {% if directParent is not defined or directParent == true %}
                {% set directParent = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directParent') %}
                {% if directParent is not null %}
                    <h4>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Direct parent{% endtrans %}«ELSE»{{ __('Direct parent') }}«ENDIF»</h4>
                    <ul>
                        <li><a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'display'«routeParams('directParent', true)») }}" title="{{ directParent|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}">{{ directParent|«application.appName.formatForDB»_formattedTitle }}</a></li>
                    </ul>
                {% endif %}
            {% endif %}
        {% endif %}
        {% if allChildren is not defined or allChildren == true %}
            {% set allChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allChildren') %}
            {% if allChildren is not null and allChildren is iterable and allChildren|length > 0 %}
                <h4>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}All children{% endtrans %}«ELSE»{{ __('All children') }}«ENDIF»</h4>
                {{ «IF application.targets('3.0')»_self«ELSE»relatives«ENDIF».list_relatives(allChildren, routeArea) }}
            {% endif %}
        {% endif %}
        {% if directChildren is not defined or directChildren == true %}
            {% set directChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directChildren') %}
            {% if directChildren is not null and directChildren is iterable and directChildren|length > 0 %}
                <h4>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Direct children{% endtrans %}«ELSE»{{ __('Direct children') }}«ENDIF»</h4>
                {{ «IF application.targets('3.0')»_self«ELSE»relatives«ENDIF».list_relatives(directChildren, routeArea) }}
            {% endif %}
        {% endif %}
        {% if «objName».lvl > 0 %}
            {% if predecessors is not defined or predecessors == true %}
                {% set predecessors = «pluginPrefix»_treeSelection('«objName»', node=«objName», target='predecessors') %}
                {% if predecessors is not null and predecessors is iterable and predecessors|length > 0 %}
                    <h4>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Predecessors{% endtrans %}«ELSE»{{ __('Predecessors') }}«ENDIF»</h4>
                    {{ «IF application.targets('3.0')»_self«ELSE»relatives«ENDIF».list_relatives(predecessors, routeArea) }}
                {% endif %}
            {% endif %}
            {% if successors is not defined or successors == true %}
                {% set successors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='successors') %}
                {% if successors is not null and successors is iterable and successors|length > 0 %}
                    <h4>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Successors{% endtrans %}«ELSE»{{ __('Successors') }}«ENDIF»</h4>
                    {{ «IF application.targets('3.0')»_self«ELSE»relatives«ENDIF».list_relatives(successors, routeArea) }}
                {% endif %}
            {% endif %}
            {% if preandsuccessors is not defined or preandsuccessors == true %}
                {% set preandsuccessors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='preandsuccessors') %}
                {% if preandsuccessors is not null and preandsuccessors is iterable and preandsuccessors|length > 0 %}
                    <h4>«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Siblings{% endtrans %}«ELSE»{{ __('Siblings') }}«ENDIF»</h4>
                    {{ «IF application.targets('3.0')»_self«ELSE»relatives«ENDIF».list_relatives(preandsuccessors, routeArea) }}
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
