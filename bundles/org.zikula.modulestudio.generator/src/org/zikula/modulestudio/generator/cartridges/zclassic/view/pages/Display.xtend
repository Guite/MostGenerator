package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.DataObject
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
        «IF isLegacyApp»
            {* purpose of this template: «nameMultiple.formatForDisplay» display view *}
            {assign var='lct' value='user'}
            {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                {assign var='lct' value='admin'}
            {/if}
            {include file="`$lct`/header.tpl"}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-display«IF !refedElems.empty» with-rightbox«ENDIF»">
                {gt text='«name.formatForDisplayCapital»' assign='templateTitle'}
                {assign var='templateTitle' value=$«objName»->getTitleFromDisplayPattern()|default:$templateTitle}
                {pagesetvar name='title' value=$templateTitle|@html_entity_decode}
                «templateHeader(appName)»
        «ELSE»
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
        «ENDIF»

            «IF !refedElems.empty»
                «IF isLegacyApp»
                    {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                        <div class="«appName.toLowerCase»-rightbox">
                            «val relationHelper = new Relations»
                            «IF isLegacyApp»
                                «FOR elem : refedElems»«relationHelper.displayRelatedItemsLegacy(elem, appName, it)»«ENDFOR»
                            «ELSE»
                                «FOR elem : refedElems»«relationHelper.displayRelatedItems(elem, appName, it)»«ENDFOR»
                            «ENDIF»
                        </div>
                    {/if}
                «ELSE»
                    {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                        <div class="row">
                            <div class="col-sm-9">
                    {% endif %}
                «ENDIF»
            «ENDIF»
            «IF useGroupingPanels('display')»

                «IF isLegacyApp»
                    {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                        <div id="«appName.toFirstLower»Panel" class="z-panels">
                            <h3 id="z-panel-header-fields" class="z-panel-header z-panel-indicator z-pointer z-panel-active">{gt text='Fields'}</h3>
                            <div class="z-panel-content z-panel-active" style="overflow: visible">
                    {/if}
                «ELSE»
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
            «ENDIF»

            «fieldDetails(appName)»
            «IF useGroupingPanels('display')»
                «IF isLegacyApp»
                    {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                        </div>«/* fields panel */»
                    {/if}
                «ELSE»
                    {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                                </div>
                            </div>
                        </div>
                    {% endif %}
                «ENDIF»
            «ENDIF»
            «displayExtensions(objName)»

            «IF isLegacyApp»{if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}«ELSE»{% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}«ENDIF»
                «IF !skipHookSubscribers»
                    «IF isLegacyApp»
                        «callDisplayHooks(appName)»
                    «ELSE»
                        {# include display hooks #}
                        {{ block('display_hooks') }}
                    «ENDIF»
                «ENDIF»
                «IF isLegacyApp»
                    «new ItemActionsView().generateDisplay(it)»
                «ENDIF»
                «IF useGroupingPanels('display')»
                    </div>«/* panels */»
                «ENDIF»
                «IF !refedElems.empty»
                    «IF isLegacyApp»
                        <br style="clear: right" />
                    «ELSE»
                            </div>
                            <div class="col-sm-3">
                                «IF isLegacyApp»
                                    «val relationHelper = new Relations»
                                    «FOR elem : refedElems»«relationHelper.displayRelatedItemsLegacy(elem, appName, it)»«ENDFOR»
                                «ELSE»
                                    {{ block('related_items') }}
                                «ENDIF»
                            </div>
                        </div>
                    «ENDIF»
                «ENDIF»
            «IF isLegacyApp»{/if}«ELSE»{% endif %}«ENDIF»
        </div>
        «IF isLegacyApp»
            {include file="`$lct`/footer.tpl"}
        «ELSE»
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

        «ENDIF»
        «IF hasBooleansWithAjaxToggleEntity('display') || (useGroupingPanels('display') && isLegacyApp) || (hasImageFieldsEntity && !isLegacyApp)»

        «IF isLegacyApp»{if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}«ELSE»{% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}«ENDIF»
            <script type="text/javascript">
            /* <![CDATA[ */
                «IF isLegacyApp»
                    document.observe('dom:loaded', function() {
                        «initAjaxToggle»
                        «IF useGroupingPanels('display')»
                            var panel = new Zikula.UI.Panels('«appName.toFirstLower»Panel', {
                                headerSelector: 'h3',
                                headerClassName: 'z-panel-header z-panel-indicator',
                                contentClassName: 'z-panel-content',
                                active: $('z-panel-header-fields')
                            });
                        «ENDIF»
                    });
                «ELSE»
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
                «ENDIF»
            /* ]]> */
            </script>
        «IF isLegacyApp»{/if}«ELSE»{% endif %}«ENDIF»
        «ENDIF»
        «IF !isLegacyApp»
            {% endblock %}
        «ENDIF»
    '''

    def private initAjaxToggle(Entity it) '''
        «IF hasBooleansWithAjaxToggleEntity('display')»
            «IF isLegacyApp»
                {{assign var='itemid' value=$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}}
                «FOR field : getBooleansWithAjaxToggleEntity('display')»
                    «application.vendorAndName»InitToggle('«name.formatForCode»', '«field.name.formatForCode»', '{{$itemid}}');
                «ENDFOR»
            «ELSE»
                {% set itemid = «name.formatForCode».«getFirstPrimaryKey.name.formatForCode» %}
                «FOR field : getBooleansWithAjaxToggleEntity('display')»
                    «application.vendorAndName»InitToggle('«name.formatForCode»', '«field.name.formatForCode»', '{{ itemid|e('html_attr') }}');
                «ENDFOR»
            «ENDIF»
        «ENDIF»
    '''

    def private fieldDetails(Entity it, String appName) '''
        <dl>
            «FOR field : getFieldsForDisplayPage»«field.displayEntry»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    «IF isLegacyApp»
                        {if $«name.formatForCode».«geoFieldName»}
                            <dt>{gt text='«geoFieldName.toFirstUpper»'}</dt>
                            <dd>{$«name.formatForCode».«geoFieldName»|«appName.formatForDB»FormatGeoData}</dd>
                        {/if}
                    «ELSE»
                        {% if «name.formatForCode».«geoFieldName» is not empty %}
                            <dt>{{ __('«geoFieldName.toFirstUpper»') }}</dt>
                            <dd>{{ «name.formatForCode».«geoFieldName»|«appName.formatForDB»_geoData }}</dd>
                        {% endif %}
                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            «IF softDeleteable»
                «IF isLegacyApp»
                    {if $«name.formatForCode».deletedAt}
                        <dt>{gt text='Deleted at'}</dt>
                        <dd>{$«name.formatForCode».deletedAt|dateformat:'datebrief'}</dd>
                    {/if}
                «ELSE»
                    {% if «name.formatForCode».deletedAt is not empty %}
                        <dt>{{ __('Deleted at') }}</dt>
                        <dd>{{ «name.formatForCode».deletedAt|localizeddate('medium', 'short') }}</dd>
                    {% endif %}
                «ENDIF»
            «ENDIF»
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»«relation.displayEntry(false)»«ENDFOR»
            «/*«FOR relation : outgoing.filter[OneToOneRelationship).filter[target instanceof Entity]»«relation.displayEntry(true)»«ENDFOR»*/»
        </dl>
    '''

    // 1.3.x only
    def private templateHeader(Entity it, String appName) '''
        {if $lct eq 'admin'}
            <div class="z-admin-content-pagetitle">
                {icon type='display' size='small' __alt='Details'}
                <h3>«templateHeadingLegacy(appName)»«new ItemActionsView().trigger(it, 'display')»</h3>
            </div>
        {else}
            <h2>«templateHeadingLegacy(appName)»«new ItemActionsView().trigger(it, 'display')»</h2>
        {/if}
    '''

    def private templateHeadingLegacy(Entity it, String appName) '''{$templateTitle«IF !skipHookSubscribers»|notifyfilters:'«appName.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'«ENDIF»}«IF hasVisibleWorkflow»{if $lct eq 'admin'} <small>({$«name.formatForCode».workflowState|«appName.formatForDB»ObjectState:false|lower})</small>{/if}«ENDIF»'''
    def private templateHeading(Entity it, String appName) '''{{ templateTitle«IF !skipHookSubscribers»|notifyFilters('«appName.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter')«ENDIF» }}«IF hasVisibleWorkflow»{% if routeArea == 'admin' %} <small>({{ «name.formatForCode».workflowState|«appName.formatForDB»_objectState(false)|lower }})</small>{% endif %}«ENDIF»'''

    def private displayEntry(DerivedField it) '''
        «val fieldLabel = if (name == 'workflowState') 'state' else name»
        «IF entity.isLegacyApp»
            {if $«entity.name.formatForCode».«name.formatForCode»«IF name == 'workflowState'» && $lct eq 'admin'«ENDIF»}
                <dt>{gt text='«fieldLabel.formatForDisplayCapital»'}</dt>
                <dd>«displayEntryImpl»</dd>
            {/if}
        «ELSE»
            {% if «entity.name.formatForCode».«name.formatForCode» is not empty«IF name == 'workflowState'» and routeArea == 'admin'«ENDIF» %}
                <dt>{{ __('«fieldLabel.formatForDisplayCapital»') }}</dt>
                <dd>«displayEntryImpl»</dd>
            {% endif %}
        «ENDIF»
    '''

    def private displayEntryImpl(DerivedField it) {
        new SimpleFields().displayField(it, entity.name.formatForCode, 'display')
    }

    def private displayEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val mainEntity = (if (useTarget) source else target) as Entity»
        «val linkEntity = (if (useTarget) target else source) as Entity»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        «IF linkEntity.isLegacyApp»
            {if isset($«relObjName») && $«relObjName» ne null}
                <dt>{gt text='«relationAliasName.formatForDisplayCapital»'}</dt>
                <dd>
                  {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                  «IF linkEntity.hasActions('display')»
                      <a href="{modurl modname='«linkEntity.application.appName»' type=$lct func='display' ot='«linkEntity.name.formatForCode»' «linkEntity.routeParamsLegacy(relObjName, true, true)»}">{strip}
                  «ENDIF»
                    {$«relObjName»->getTitleFromDisplayPattern()}
                  «IF linkEntity.hasActions('display')»
                    {/strip}</a>
                    <a id="«linkEntity.name.formatForCode»Item«FOR pkField : linkEntity.getPrimaryKeyFields»{$«relObjName».«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«linkEntity.application.appName»' type=$lct func='display' ot='«linkEntity.name.formatForCode»' «linkEntity.routeParamsLegacy(relObjName, true, true)» theme='Printer' forcelongurl=true}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
                    <script type="text/javascript">
                    /* <![CDATA[ */
                        document.observe('dom:loaded', function() {
                            «application.vendorAndName»InitInlineWindow($('«linkEntity.name.formatForCode»Item«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«relObjName».«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$«relObjName»->getTitleFromDisplayPattern()|replace:"'":""}}');
                        });
                    /* ]]> */
                    </script>
                  «ENDIF»
                  {else}
                    {$«relObjName»->getTitleFromDisplayPattern()}
                  {/if}
                </dd>
            {/if}
        «ELSE»
            {% if «relObjName»|default %}
            <dt>{{ __('«relationAliasName.formatForDisplayCapital»') }}</dt>
            <dd>
              {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                  «IF linkEntity.hasActions('display')»
                      <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.toLowerCase»_' ~ routeArea ~ 'display'«linkEntity.routeParams(relObjName, true)») }}">{% spaceless %}
                  «ENDIF»
                    {{ «relObjName».getTitleFromDisplayPattern() }}
                  «IF linkEntity.hasActions('display')»
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
        «ENDIF»
    '''

    def private displayExtensions(Entity it, String objName) '''
        «IF geographical»
            «IF useGroupingPanels('display')»
                «IF isLegacyApp»
                    <h3 class="«application.appName.toLowerCase»-map z-panel-header z-panel-indicator z-pointer">{gt text='Map'}</h3>
                    <div class="«application.appName.toLowerCase»-map z-panel-content" style="display: none">
                «ELSE»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMap">{{ __('Map') }}</a></h3>
                        </div>
                        <div id="collapseMap" class="panel-collapse collapse in">
                            <div class="panel-body">
                «ENDIF»
            «ELSE»
                <h3 class="«application.appName.toLowerCase»-map">«IF isLegacyApp»{gt text='Map'}«ELSE»{{ __('Map') }}«ENDIF»</h3>
            «ENDIF»
            «IF isLegacyApp»
                {pageaddvarblock name='header'}
                    <script type="text/javascript" src="https://maps.google.com/maps/api/js?sensor=false"></script>
                    <script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                    <script type="text/javascript">
                    /* <![CDATA[ */
                        var mapstraction;
                        Event.observe(window, 'load', function() {
                            «initGeographical(objName)»
                        });
                    /* ]]> */
                    </script>
                {/pageaddvarblock}
            «ELSE»
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
            «ENDIF»
            <div id="mapContainer" class="«application.appName.toLowerCase»-mapcontainer">
            </div>
            «IF useGroupingPanels('display')»
                «IF isLegacyApp»
                    </div>
                «ELSE»
                            </div>
                        </div>
                    </div>
                «ENDIF»
            «ENDIF»
        «ENDIF»
        «IF isLegacyApp»
            «IF attributable»
                {include file='helper/includeAttributesDisplay.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
            «ENDIF»
            «IF categorisable»
                {include file='helper/includeCategoriesDisplay.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
            «ENDIF»
            «IF tree != EntityTreeType.NONE»
                «IF useGroupingPanels('display')»
                    <h3 class="relatives z-panel-header z-panel-indicator z-pointer">{gt text='Relatives'}</h3>
                    <div class="relatives z-panel-content" style="display: none">
                «ELSE»
                    <h3 class="relatives">{gt text='Relatives'}</h3>
                «ENDIF»
                    {include file='«name.formatForCode»/displayTreeRelatives.tpl' allParents=true directParent=true allChildren=true directChildren=true predecessors=true successors=true preandsuccessors=true}
                «IF useGroupingPanels('display')»
                    </div>
                «ENDIF»
            «ENDIF»
            «IF standardFields»
                {include file='helper/includeStandardFieldsDisplay.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
            «ENDIF»
        «ELSE»
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
        «ENDIF»
    '''

    def private initGeographical(Entity it, String objName) '''
        mapstraction = new mxn.Mapstraction('mapContainer', 'googlev3');
        mapstraction.addControls({
            pan: true,
            zoom: 'small',
            map_type: true
        });

        «IF isLegacyApp»
            var latlon = new mxn.LatLonPoint({{$«objName».latitude|«application.name.formatForDB»FormatGeoData}}, {{$«objName».longitude|«application.name.formatForDB»FormatGeoData}});
        «ELSE»
            var latlon = new mxn.LatLonPoint({{ «objName».latitude|«application.name.formatForDB»_geoData }}, {{ «objName».longitude|«application.name.formatForDB»_geoData }});
        «ENDIF»

        mapstraction.setMapType(mxn.Mapstraction.SATELLITE);
        mapstraction.setCenterAndZoom(latlon, 18);
        mapstraction.mousePosition('position');

        // add a marker
        var marker = new mxn.Marker(latlon);
        mapstraction.addMarker(marker, true);
        «IF !isLegacyApp»

            $('#collapseMap').on('hidden.bs.collapse', function () {
                // redraw the map after it's panel has been opened (see also #340)
                mapstraction.resizeTo($('#mapContainer').width(), $('#mapContainer').height());
            })
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        «IF isLegacyApp»
            {* include display hooks *}
            {notifydisplayhooks eventname='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view' id=«displayHookIdLegacy» urlobject=$currentUrlObject assign='hooks'}
            {foreach name='hookLoop' key='providerArea' item='hook' from=$hooks}
                {if $providerArea ne 'provider.scribite.ui_hooks.editor'}{* fix for #664 *}
                    «IF useGroupingPanels('display')»
                        <h3 class="z-panel-header z-panel-indicator z-pointer">{$providerArea}</h3>
                        <div class="z-panel-content" style="display: none">
                            {$hook}
                        </div>
                    «ELSE»
                        {$hook}
                    «ENDIF»
                {/if}
            {/foreach}
        «ELSE»
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
        «ENDIF»
    '''

    def private displayHookIdLegacy(Entity it) '''«IF !hasCompositeKeys»$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»«ELSE»"«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»"«ENDIF»'''
    def private displayHookId(Entity it) '''«FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForCode».«pkField.name.formatForCode»«ENDFOR»'''

    def private treeRelatives(Entity it, String appName) '''
        «val objName = name.formatForCode»
        «val pluginPrefix = application.appName.formatForDB»
        «IF isLegacyApp»
            {* purpose of this template: show different forms of relatives for a given tree node *}
            <h3>{gt text='Related «nameMultiple.formatForDisplay»'}</h3>
            {if $«objName».lvl gt 0}
                {if !isset($allParents) || $allParents eq true}
                    {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='allParents' assign='allParents'}
                    {if $allParents ne null && count($allParents) gt 0}
                        <h4>{gt text='All parents'}</h4>
                        «nodeLoop(appName, 'allParents')»
                    {/if}
                {/if}
                {if !isset($directParent) || $directParent eq true}
                    {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='directParent' assign='directParent'}
                    {if $directParent ne null}
                        <h4>{gt text='Direct parent'}</h4>
                        <ul>
                            <li><a href="{modurl modname='«appName»' type=$lct func='display' ot='«objName»' «routeParamsLegacy('directParent', true, true)»}" title="{$directParent->getTitleFromDisplayPattern()|replace:'"':''}">{$directParent->getTitleFromDisplayPattern()}</a></li>
                        </ul>
                    {/if}
                {/if}
            {/if}
            {if !isset($allChildren) || $allChildren eq true}
                {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='allChildren' assign='allChildren'}
                {if $allChildren ne null && count($allChildren) gt 0}
                    <h4>{gt text='All children'}</h4>
                    «nodeLoop(appName, 'allChildren')»
                {/if}
            {/if}
            {if !isset($directChildren) || $directChildren eq true}
                {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='directChildren' assign='directChildren'}
                {if $directChildren ne null && count($directChildren) gt 0}
                    <h4>{gt text='Direct children'}</h4>
                    «nodeLoop(appName, 'directChildren')»
                {/if}
            {/if}
            {if $«objName».lvl gt 0}
                {if !isset($predecessors) || $predecessors eq true}
                    {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='predecessors' assign='predecessors'}
                    {if $predecessors ne null && count($predecessors) gt 0}
                        <h4>{gt text='Predecessors'}</h4>
                        «nodeLoop(appName, 'predecessors')»
                    {/if}
                {/if}
                {if !isset($successors) || $successors eq true}
                    {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='successors' assign='successors'}
                    {if $successors ne null && count($successors) gt 0}
                        <h4>{gt text='Successors'}</h4>
                        «nodeLoop(appName, 'successors')»
                    {/if}
                {/if}
                {if !isset($preandsuccessors) || $preandsuccessors eq true}
                    {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='preandsuccessors' assign='preandsuccessors'}
                    {if $preandsuccessors ne null && count($preandsuccessors) gt 0}
                        <h4>{gt text='Siblings'}</h4>
                        «nodeLoop(appName, 'preandsuccessors')»
                    {/if}
                {/if}
            {/if}
        «ELSE»
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
        «ENDIF»
    '''

    def private nodeLoop(Entity it, String appName, String collectionName) '''
        «val objName = name.formatForCode»
        <ul>
        «IF isLegacyApp»
            {foreach item='node' from=$«collectionName»}
                <li><a href="{modurl modname='«appName»' type=$lct func='display' ot='«objName»' «routeParamsLegacy('node', true, true)»}" title="{$node->getTitleFromDisplayPattern()|replace:'"':''}">{$node->getTitleFromDisplayPattern()}</a></li>
            {/foreach}
        «ELSE»
            {% for node in «collectionName» %}
                <li><a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'display'«routeParams('node', true)») }}" title="{{ node.getTitleFromDisplayPattern()|e('html_attr') }}">{{ node.getTitleFromDisplayPattern() }}</a></li>
            {% endfor %}
        «ENDIF»
        </ul>
    '''

    def private isLegacyApp(DataObject it) {
        application.targets('1.3.x')
    }
}
