package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
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

class Display {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension UrlExtensions = new UrlExtensions()
    @Inject extension Utils = new Utils()
    @Inject extension ViewExtensions = new ViewExtensions()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' display templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(templateFile(controller, name, 'display'), displayView(appName, controller))
    }

    def private displayView(Entity it, String appName, Controller controller) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» display view in «controller.formattedName» area *}
        {include file='«controller.formattedName»/header.tpl'}
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-display">
        «val objName = name.formatForCode»
        «val leadingField = getLeadingField»
        {gt text='«name.formatForDisplayCapital»' assign='templateTitle'}
        «IF leadingField != null && leadingField.showLeadingFieldInTitle»
            {assign var='templateTitle' value=$«objName».«leadingField.name.formatForCode»|default:$templateTitle}
        «ENDIF»
        {pagesetvar name='title' value=$templateTitle|@html_entity_decode}
        «controller.templateHeader(it, appName)»

        «val refedElems = getOutgoingJoinRelations.filter(e|e.target.container.application == it.container.application) + incoming.filter(typeof(ManyToManyRelationship)).filter(e|e.source.container.application == it.container.application)»
        «IF !refedElems.isEmpty»
            {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                <div class="«appName.formatForDB»RightBox">
                    «val relationHelper = new Relations()»
                    «FOR elem : refedElems»«relationHelper.displayRelatedItems(elem, appName, controller, it)»«ENDFOR»
                </div>
            {/if}
        «ENDIF»

        «IF useGroupingPanels('display')»
        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
        <div class="z-panels" id="«appName»_panel">
            <h3 id="z-panel-header-fields" class="z-panel-header z-panel-indicator z-pointer z-panel-active">{gt text='Fields'}</h3>
            <div class="z-panel-content z-panel-active" style="overflow: visible">
        {/if}
        «ENDIF»
        «fieldDetails(appName, controller)»
        «IF useGroupingPanels('display')»
        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            </div>
        {/if}
        «ENDIF»
        «displayExtensions(controller, objName)»

        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «callDisplayHooks(appName, controller)»
            «itemActions(appName, controller)»
            «IF !refedElems.isEmpty»
                <br style="clear: right" />
            «ENDIF»
        {/if}

        «controller.templateFooter»
        </div>
        {include file='«controller.formattedName»/footer.tpl'}

        «IF hasBooleansWithAjaxToggleEntity || useGroupingPanels('display')»
        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            <script type="text/javascript">
            /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                    «IF hasBooleansWithAjaxToggleEntity»
                    {{assign var='itemid' value=$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»}}
                «FOR field : getBooleansWithAjaxToggleEntity»
                    «container.application.prefix»InitToggle('«name.formatForCode»', '«field.name.formatForCode»', '{{$itemid}}');
                «ENDFOR»
                    «ENDIF»
                    «IF useGroupingPanels('display')»
                    var panel = new Zikula.UI.Panels('«appName»_panel', {
                        headerSelector: 'h3',
                        headerClassName: 'z-panel-header z-panel-indicator',
                        contentClassName: 'z-panel-content',
                        active: 'z-panel-header-fields'
                    });
                    «ENDIF»
                });
            /* ]]> */
            </script>
        {/if}
        «ENDIF»
    '''

    def private fieldDetails(Entity it, String appName, Controller controller) '''
        <dl id="«appName»_body">
            «IF leadingField != null && leadingField.showLeadingFieldInTitle»
                «FOR field : getDerivedFields.filter(e|!e.leading && !e.primaryKey)»«field.displayEntry(controller)»«ENDFOR»
            «ELSE»
                «FOR field : getDerivedFields.filter(e|!e.primaryKey)»«field.displayEntry(controller)»«ENDFOR»
            «ENDIF»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    <dt>{gt text='«geoFieldName.toFirstUpper»'}</dt>
                    <dd>{$«name.formatForCode».«geoFieldName»|«appName.formatForDB»FormatGeoData}</dd>
                «ENDFOR»
            «ENDIF»
            «FOR relation : incoming.filter(typeof(OneToManyRelationship)).filter(e|e.bidirectional)»«relation.displayEntry(controller, false)»«ENDFOR»
            «/*«FOR relation : outgoing.filter(typeof(OneToOneRelationship))»«relation.displayEntry(controller, true)»«ENDFOR»*/»
        </dl>
    '''

    def private showLeadingFieldInTitle(DerivedField it) {
        switch it {
            IntegerField: true
            StringField: true
            TextField: true
            default: false
        }
    }

    def private templateHeader(Controller it, Entity entity, String appName) {
        switch it {
            AdminController: '''
                <div class="z-admin-content-pagetitle">
                    {icon type='display' size='small' __alt='Details'}
                    <h3>{$templateTitle|notifyfilters:'«appName.formatForDB».filter_hooks.«entity.nameMultiple.formatForDB».filter'}{icon id='itemactionstrigger' type='options' size='extrasmall' __alt='Actions' class='z-pointer z-hide'}</h3>
                </div>
            '''
            default: '''
                <div class="z-frontendcontainer">
                    <h2>{$templateTitle|notifyfilters:'«appName.formatForDB».filter_hooks.«entity.nameMultiple.formatForDB».filter'}{icon id='itemactionstrigger' type='options' size='extrasmall' __alt='Actions' class='z-pointer z-hide'}</h2>
            '''
        }
    }

    def private templateFooter(Controller it) {
        switch it {
            AdminController: ''
            default: '''
                </div>
            '''
        }
    }

    def private displayEntry(DerivedField it, Controller controller) '''
        <dt>{gt text='«name.formatForDisplayCapital»'}</dt>
        <dd>«displayEntryImpl»</dd>
    '''

    def private displayEntryImpl(DerivedField it) {
        new SimpleFields().displayField(it, entity.name.formatForCode, 'display')
    }

    def private displayEntry(JoinRelationship it, Controller controller, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (useTarget) source else target)»
        «val linkEntity = (if (useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        <dt>{gt text='«relationAliasName.formatForDisplayCapital»'}</dt>
        <dd>
        {if isset($«relObjName») && $«relObjName» ne null}
          {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
          «var Controller linkController = null»
          «IF container.application == linkEntity.container.application && controller.hasActions('display')»
              «linkController = controller»
          «ELSEIF linkEntity.container.application.hasUserController && linkEntity.container.application.getMainUserController.hasActions('display')»
              «linkController = linkEntity.container.application.getMainUserController»
          «ENDIF»
          «IF linkController != null»
              <a href="{modurl modname='«linkEntity.container.application.appName»' type='«linkController.formattedName»' «linkEntity.modUrlDisplay(relObjName, true)»}">
          «ENDIF»
            «val leadingField = linkEntity.getLeadingField»
            «IF leadingField != null»
                {$«relObjName».«leadingField.name.formatForCode»«/*|nl2br*/»|default:""}
            «ELSE»
                {gt text='«linkEntity.name.formatForDisplayCapital»'}
            «ENDIF»
          «IF linkController != null»
            </a>
            <a id="«linkEntity.name.formatForCode»Item«FOR pkField : linkEntity.getPrimaryKeyFields»{$«relObjName».«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«linkEntity.container.application.appName»' type='«linkController.formattedName»' «linkEntity.modUrlDisplay(relObjName, true)» theme='Printer'«controller.additionalUrlParametersForQuickViewLink»}" title="{gt text='Open quick view window'}" class="z-hide">
                {icon type='view' size='extrasmall' __alt='Quick view'}
            </a>
            <script type="text/javascript">
            /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                    «val leadingLinkField = linkEntity.getLeadingField»
                    «IF leadingLinkField != null»
                        «container.application.prefix»InitInlineWindow($('«linkEntity.name.formatForCode»Item«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«relObjName».«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$«relObjName».«leadingLinkField.name.formatForCode»|replace:"'":""}}');
                    «ELSE»
                        «container.application.prefix»InitInlineWindow($('«linkEntity.name.formatForCode»Item«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«relObjName».«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{gt text='«linkEntity.name.formatForDisplayCapital»'|replace:"'":""}}');
                    «ENDIF»
                });
            /* ]]> */
            </script>
          «ENDIF»
          {else}
        «IF leadingField != null»
            {$«relObjName».«leadingField.name.formatForCode»«/*|nl2br*/»|default:""}
        «ELSE»
            {gt text='«linkEntity.name.formatForDisplayCapital»'}
        «ENDIF»
          {/if}
        {else}
            {gt text='No set.'}
        {/if}
        </dd>
    '''

    def private itemActions(Entity it, String appName, Controller controller) '''
        {if count($«name.formatForCode»._actions) gt 0}
            «itemActionsImpl(appName, controller)»
        {/if}
    '''

    def private itemActionsImpl(Entity it, String appName, Controller controller) '''
        <p id="itemactions">
        {foreach item='option' from=$«name.formatForCode»._actions}
            <a href="{$option.url.type|«appName.formatForDB»ActionUrl:$option.url.func:$option.url.arguments}" title="{$option.linkTitle|safetext}" class="z-icon-es-{$option.icon}">{$option.linkText|safetext}</a>
        {/foreach}
        </p>
        <script type="text/javascript">
        /* <![CDATA[ */
            document.observe('dom:loaded', function() {
                «container.application.prefix»InitItemActions('«name.formatForCode»', 'display', 'itemactions');
            });
        /* ]]> */
        </script>
    '''

    def private displayExtensions(Entity it, Controller controller, String objName) '''
        «IF geographical»
            «IF useGroupingPanels('display')»
                <h3 class="map z-panel-header z-panel-indicator z-pointer">{gt text='Map'}</h3>
                <div class="map z-panel-content" style="display: none">
            «ELSE»
                <h3 class="map">{gt text='Map'}</h3>
            «ENDIF»
            {pageaddvarblock name='header'}
                <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
                <script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                <script type="text/javascript">
                /* <![CDATA[ */
                    var mapstraction;
                    Event.observe(window, 'load', function() {
                        mapstraction = new mxn.Mapstraction('mapContainer', 'googlev3');
                        mapstraction.addControls({
                            pan: true,
                            zoom: 'small',
                            map_type: true
                        });

                        var latlon = new mxn.LatLonPoint({{$«objName».latitude|«container.application.name.formatForDB»FormatGeoData}}, {{$«objName».longitude|«container.application.name.formatForDB»FormatGeoData}});

                        mapstraction.setMapType(mxn.Mapstraction.SATELLITE);
                        mapstraction.setCenterAndZoom(latlon, 18);
                        mapstraction.mousePosition('position');

                        // add a marker
                        var marker = new mxn.Marker(latlon);
                        mapstraction.addMarker(marker, true);
                    });
                /* ]]> */
                </script>
            {/pageaddvarblock}
            <div id="mapContainer" class="«controller.container.application.appName.formatForDB»MapContainer">
            </div>
            «IF useGroupingPanels('display')»
                </div>
            «ENDIF»
        «ENDIF»
        «IF attributable»
            {include file='«controller.formattedName»/include_attributes_display.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
        «ENDIF»
        «IF categorisable»
            {include file='«controller.formattedName»/include_categories_display.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
        «ENDIF»
        «IF standardFields»
            {include file='«controller.formattedName»/include_standardfields_display.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
        «ENDIF»
        «IF metaData»
            {include file='«controller.formattedName»/include_metadata_display.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName, Controller controller) '''
        {* include display hooks *}
        {notifydisplayhooks eventname='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view' id=«displayHookId» urlobject=$currentUrlObject assign='hooks'}
        {foreach key='providerArea' item='hook' from=$hooks}
            «IF useGroupingPanels('display')»
                <h3 class="z-panel-header z-panel-indicator z-pointer">{$providerArea}</h3>
                <div class="z-panel-content" style="display: none">{$hook}</div>
            «ELSE»
                {$hook}
            «ENDIF»
        {/foreach}
    '''

    def private displayHookId(Entity it) '''«IF !hasCompositeKeys»$«name.formatForCode».«getFirstPrimaryKey.name.formatForCode»«ELSE»"«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»"«ENDIF»'''
}
