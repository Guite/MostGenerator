package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.Relations
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
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
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating display templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = templateFile('display')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, displayView(appName))
        }
        if (tree != EntityTreeType.NONE) {
            templateFilePath = templateFile('displayTreeRelatives')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, treeRelatives(appName))
            }
        }
    }

    def private displayView(Entity it, String appName) '''
        «val refedElems = getOutgoingJoinRelations.filter[e|e.target instanceof Entity && e.target.application == it.application]
                        + incoming.filter(ManyToManyRelationship).filter[e|e.source instanceof Entity && e.source.application == it.application]»
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» display view #}
        {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
        {% block pageTitle %}{{ «objName».getTitleFromDisplayPattern()|default(__('«name.formatForDisplayCapital»')) }}{% endblock %}
        {% block title %}
            {% set templateTitle = «objName».getTitleFromDisplayPattern()|default(__('«name.formatForDisplayCapital»')) %}
            «templateHeading(appName)»
            «new ItemActionsView().generateDisplay(it)»
        {% endblock %}
        {% block admin_page_icon 'eye' %}
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-display">

            «IF !refedElems.empty»
                {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                    <div class="row">
                        <div class="col-sm-9">
                {% endif %}
            «ENDIF»
            «IF useGroupingPanels('display')»

                {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                    <div class="panel-group" id="accordion">
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseFields">{{ __('Fields') }}</a></h3>
                            </div>
                            <div id="collapseFields" class="panel-collapse collapse in">
                                <div class="panel-body">
                {% endif %}
            «ENDIF»

            «fieldDetails(appName)»
            «IF useGroupingPanels('display')»
                {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                            </div>
                        </div>
                    </div>
                {% endif %}
            «ENDIF»
            «displayExtensions(objName)»

            {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                «IF !skipHookSubscribers»
                    {# include display hooks #}
                    {{ block('display_hooks') }}
                «ENDIF»
                «IF useGroupingPanels('display')»
                    </div>«/* panels */»
                «ENDIF»
                «IF !refedElems.empty»
                        </div>
                        <div class="col-sm-3">
                            {{ block('related_items') }}
                        </div>
                    </div>
                «ENDIF»
            {% endif %}
        </div>
        {% endblock %}
        «IF !refedElems.empty»
            {% block related_items %}
                «val relationHelper = new Relations»
                «FOR elem : refedElems»«relationHelper.displayRelatedItems(elem, appName, it)»«ENDFOR»
            {% endblock %}
        «ENDIF»
        «IF !skipHookSubscribers»
            {% block display_hooks %}
                «callDisplayHooks(appName)»
            {% endblock %}
        «ENDIF»
        {% block footer %}
            {{ parent() }}
            «IF hasBooleansWithAjaxToggleEntity('display') || hasImageFieldsEntity»

                {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                    <script type="text/javascript">
                    /* <![CDATA[ */
                        ( function($) {
                            $(document).ready(function() {
                                «IF hasImageFieldsEntity»
                                    $('a.lightbox').lightbox();
                                «ENDIF»
                                «IF hasBooleansWithAjaxToggleEntity('display')»
                                    «initAjaxToggle»
                                «ENDIF»
                            });
                        })(jQuery);
                    /* ]]> */
                    </script>
                {% endif %}
            «ENDIF»
        {% endblock %}
    '''

    def private initAjaxToggle(Entity it) '''
        «IF hasBooleansWithAjaxToggleEntity('display')»
            {% set itemid = «name.formatForCode».createCompositeIdentifier() %}
            «FOR field : getBooleansWithAjaxToggleEntity('display')»
                «application.vendorAndName»InitToggle('«name.formatForCode»', '«field.name.formatForCode»', '{{ itemid|e('html_attr') }}');
            «ENDFOR»
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
            «IF softDeleteable»
                {% if «name.formatForCode».deletedAt is not empty %}
                    <dt>{{ __('Deleted at') }}</dt>
                    <dd>{{ «name.formatForCode».deletedAt|localizeddate('medium', 'short') }}</dd>
                {% endif %}
            «ENDIF»
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»«relation.displayEntry(false)»«ENDFOR»
            «/*«FOR relation : outgoing.filter[OneToOneRelationship).filter[target instanceof Entity]»«relation.displayEntry(true)»«ENDFOR»*/»
        </dl>
    '''

    def private templateHeading(Entity it, String appName) '''{{ templateTitle«IF !skipHookSubscribers»|notifyFilters('«appName.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')«ENDIF» }}«IF hasVisibleWorkflow»{% if routeArea == 'admin' %} <small>({{ «name.formatForCode».workflowState|«appName.formatForDB»_objectState(false)|lower }})</small>{% endif %}«ENDIF»'''

    def private displayEntry(DerivedField it) '''
        «val fieldLabel = if (name == 'workflowState') 'state' else name»
        {% if «entity.name.formatForCode».«name.formatForCode» is not empty«IF name == 'workflowState'» and routeArea == 'admin'«ENDIF» %}
            <dt>{{ __('«fieldLabel.formatForDisplayCapital»') }}</dt>
            <dd>«displayEntryImpl»</dd>
        {% endif %}
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
              {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                  «IF linkEntity.hasDisplayAction»
                      <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.toLowerCase»_' ~ routeArea ~ 'display'«linkEntity.routeParams(relObjName, true)») }}">{% spaceless %}
                  «ENDIF»
                    {{ «relObjName».getTitleFromDisplayPattern() }}
                  «IF linkEntity.hasDisplayAction»
                    {% endspaceless %}</a>
                    <a id="«linkEntity.name.formatForCode»Item{{ «FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR ' ~ '»«relObjName».«pkField.name.formatForCode»«ENDFOR» }}Display" href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display', { «linkEntity.routePkParams(relObjName, true)»«linkEntity.appendSlug(relObjName, true)», 'theme': 'ZikulaPrinterTheme' }) }}" title="{{ __('Open quick view window')|e('html_attr') }}" class="hidden"><span class="fa fa-eye"></span></a>
                    <script type="text/javascript">
                    /* <![CDATA[ */
                        ( function($) {
                            $(document).ready(function() {
                                «application.vendorAndName»InitInlineWindow($('«linkEntity.name.formatForCode»Item{{ «FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR ' ~ '»«relObjName».«pkField.name.formatForCode»«ENDFOR» }}Display'), '{{ «relObjName».getTitleFromDisplayPattern()|e('js') }}');
                            });
                        })(jQuery);
                    /* ]]> */
                    </script>
                  «ENDIF»
              {% else %}
                  {{ «relObjName».getTitleFromDisplayPattern() }}
              {% endif %}
            </dd>
        {% endif %}
    '''

    def private displayExtensions(Entity it, String objName) '''
        «IF geographical»
            «IF useGroupingPanels('display')»
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMap">{{ __('Map') }}</a></h3>
                    </div>
                    <div id="collapseMap" class="panel-collapse collapse in">
                        <div class="panel-body">
            «ELSE»
                <h3 class="«application.appName.toLowerCase»-map">{{ __('Map') }}</h3>
            «ENDIF»
            {% set geoScripts %}
                <script type="text/javascript" src="https://maps.google.com/maps/api/js?sensor=false"></script>
                <script type="text/javascript" src="{{ pagevars.homepath }}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                <script type="text/javascript">
                /* <![CDATA[ */
                    var mapstraction;
                    ( function($) {
                        $(document).ready(function() {
                            «initGeographical(objName)»
                        });
                    })(jQuery);
                /* ]]> */
                </script>
            {% endset %}
            {{ pageAddAsset('header', geoScripts) }}
            <div id="mapContainer" class="«application.appName.toLowerCase»-mapcontainer">
            </div>
            «IF useGroupingPanels('display')»
                        </div>
                    </div>
                </div>
            «ENDIF»
        «ENDIF»
        «IF attributable»
            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                {{ include('@«application.appName»/Helper/includeAttributesDisplay.html.twig', { obj: «objName»«IF useGroupingPanels('display')», panel: true«ENDIF» }) }}
            {% endif %}
        «ENDIF»
        «IF categorisable»
            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                {{ include('@«application.appName»/Helper/includeCategoriesDisplay.html.twig', { obj: «objName»«IF useGroupingPanels('display')», panel: true«ENDIF» }) }}
            {% endif %}
        «ENDIF»
        «IF tree != EntityTreeType.NONE»
            {% if featureActivationHelper.isEnabled(constant('«application.vendor.formatForCodeCapital»\\«application.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::TREE_RELATIVES'), '«name.formatForCode»') %}
                «IF useGroupingPanels('display')»
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseRelatives">{{ __('Relatives') }}</a></h3>
                    </div>
                    <div id="collapseRelatives" class="panel-collapse collapse in">
                        <div class="panel-body">
                «ELSE»
                <h3 class="relatives">{{ __('Relatives') }}</h3>
                «ENDIF»
                    {{ include(
                        '@«application.appName»/«name.formatForCodeCapital»/displayTreeRelatives.html.twig',
                        { allParents: true, directParent: true, allChildren: true, directChildren: true, predecessors: true, successors: true, preandsuccessors: true }
                    ) }}
                «IF useGroupingPanels('display')»
                        </div>
                    </div>
                </div>
                «ENDIF»
            {% endif %}
        «ENDIF»
        «IF standardFields»
            {{ include('@«application.appName»/Helper/includeStandardFieldsDisplay.html.twig', { obj: «objName»«IF useGroupingPanels('display')», panel: true«ENDIF» }) }}
        «ENDIF»
    '''

    def private initGeographical(Entity it, String objName) '''
        mapstraction = new mxn.Mapstraction('mapContainer', 'googlev3');
        mapstraction.addControls({
            pan: true,
            zoom: 'small',
            map_type: true
        });

        var latlon = new mxn.LatLonPoint({{ «objName».latitude|«application.name.formatForDB»_geoData }}, {{ «objName».longitude|«application.name.formatForDB»_geoData }});

        mapstraction.setMapType(mxn.Mapstraction.SATELLITE);
        mapstraction.setCenterAndZoom(latlon, 18);
        mapstraction.mousePosition('position');

        // add a marker
        var marker = new mxn.Marker(latlon);
        mapstraction.addMarker(marker, true);

        $('#collapseMap').on('hidden.bs.collapse', function () {
            // redraw the map after it's panel has been opened (see also #340)
            mapstraction.resizeTo($('#mapContainer').width(), $('#mapContainer').height());
        })
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view', id=«displayHookId», urlObject=currentUrlObject) %}
        {% for providerArea, hook in hooks %}
            {% if providerArea != 'provider.scribite.ui_hooks.editor' %}{# fix for #664 #}
                «IF useGroupingPanels('display')»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseHook{{ loop.index }}">{{ providerArea }}</a></h3>
                        </div>
                        <div id="collapseHook{{ loop.index  }}" class="panel-collapse collapse in">
                            <div class="panel-body">
                                {{ hook }}
                            </div>
                        </div>
                    </div>
                «ELSE»
                    {{ hook }}
                «ENDIF»
            {% endif %}
        {% endfor %}
    '''

    def private displayHookId(Entity it) '''«FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForCode».«pkField.name.formatForCode»«ENDFOR»'''

    def private treeRelatives(Entity it, String appName) '''
        «val objName = name.formatForCode»
        «val pluginPrefix = application.appName.formatForDB»
        {# purpose of this template: show different forms of relatives for a given tree node #}
        <h3>{{ __('Related «nameMultiple.formatForDisplay»') }}</h3>
        {% if «objName».lvl > 0 %}
            {% if allParents is not defined or allParents == true %}
                {% set allParents = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allParents') %}
                {% if allParents is not null and allParents is iterable and allParents|length > 0 %}
                    <h4>{{ __('All parents') }}</h4>
                    {{ list_relatives(allParents) }}
                {% endif %}
            {% endif %}
            {% is directParent is not defined or directParent == true %}
                {% set directParent = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directParent') %}
                {% if directParent is not null %}
                    <h4>{{ __('Direct parent') }}</h4>
                    <ul>
                        <li><a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'display'«routeParams('directParent', true)») }}" title="{{ directParent.getTitleFromDisplayPattern()|e('html_attr') }}">{{ directParent.getTitleFromDisplayPattern() }}</a></li>
                    </ul>
                {% endif %}
            {% endif %}
        {% endif %}
        {% if allChildren is not defined or allChildren == true %}
            {% set allChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='allChildren') %}
            {% if allChildren is not null and allChildren is iterable and allChildren|length > 0 %}
                <h4>{{ __('All children') }}</h4>
                {{ list_relatives(allChildren) }}
            {% endif %}
        {% endif %}
        {% if directChildren is not defined or directChildren == true %}
            {% set directChildren = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='directChildren') %}
            {% if directChildren is not null and directChildren is iterable and directChildren|length > 0 %}
                <h4>{{ __('Direct children') }}</h4>
                {{ list_relatives(directChildren) }}
            {% endif %}
        {% endif %}
        {% if «objName».lvl > 0 %}
            {% if predecessors is not defined or predecessors == true %}
                {% set predecessors = «pluginPrefix»_treeSelection('«objName»', node=«objName», target='predecessors') %}
                {% if predecessors is not null and predecessors is iterable and predecessors|length > 0 %}
                    <h4>{{ __('Predecessors') }}</h4>
                    {{ list_relatives(predecessors) }}
                {% endif %}
            {% endif %}
            {% if successors is not defined or successors == true %}
                {% set successors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='successors') %}
                {% if successors is not null and successors is iterable and successors|length > 0 %}
                    <h4>{{ __('Successors') }}</h4>
                    {{ list_relatives(successors) }}
                {% endif %}
            {% endif %}
            {% if preandsuccessors is not defined or preandsuccessors == true %}
                {% set preandsuccessors = «pluginPrefix»_treeSelection(objectType='«objName»', node=«objName», target='preandsuccessors') %}
                {% if preandsuccessors is not null and preandsuccessors is iterable and preandsuccessors|length > 0 %}
                    <h4>{{ __('Siblings') }}</h4>
                    {{ list_relatives(preandsuccessors) }}
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
            <li><a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'display'«routeParams('node', true)») }}" title="{{ node.getTitleFromDisplayPattern()|e('html_attr') }}">{{ node.getTitleFromDisplayPattern() }}</a></li>
        {% endfor %}
        </ul>
    '''
}
