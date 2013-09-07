package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
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
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Display {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension UrlExtensions = new UrlExtensions()
    @Inject extension Utils = new Utils()
    @Inject extension ViewExtensions = new ViewExtensions()
    @Inject extension WorkflowExtensions = new WorkflowExtensions()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' display templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(templateFile(controller, name, 'display'), displayView(appName, controller))
        if (tree != EntityTreeType::NONE) {
            fsa.generateFile(templateFile(controller, name, 'display_treeRelatives'), treeRelatives(appName, controller))
        }
    }

    def private displayView(Entity it, String appName, Controller controller) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» display view in «controller.formattedName» area *}
        {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/header.tpl'}
        «val refedElems = getOutgoingJoinRelations.filter(e|e.target.container.application == it.container.application) + incoming.filter(ManyToManyRelationship).filter(e|e.source.container.application == it.container.application)»
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-display«IF !refedElems.isEmpty» withrightbox«ENDIF»">
        «val objName = name.formatForCode»
        «val leadingField = getLeadingField»
        {gt text='«name.formatForDisplayCapital»' assign='templateTitle'}
        «IF leadingField !== null && leadingField.showLeadingFieldInTitle»
            {assign var='templateTitle' value=$«objName».«leadingField.name.formatForCode»|default:$templateTitle}
        «ENDIF»
        {pagesetvar name='title' value=$templateTitle|@html_entity_decode}
        «controller.templateHeader(it, appName)»

        «IF !refedElems.isEmpty»
            {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
                <div class="«appName.toLowerCase»rightbox">
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
            </div>«/* fields panel */»
        {/if}
        «ENDIF»
        «displayExtensions(controller, objName)»

        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «callDisplayHooks(appName, controller)»
            «itemActions(appName, controller)»
            «IF useGroupingPanels('display')»
                </div>«/* panels */»
            «ENDIF»
            «IF !refedElems.isEmpty»
                <br style="clear: right" />
            «ENDIF»
        {/if}

        «controller.templateFooter»
        </div>
        {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/footer.tpl'}

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
                        active: $('z-panel-header-fields')
                    });
                    «ENDIF»
                });
            /* ]]> */
            </script>
        {/if}
        «ENDIF»
    '''

    def private fieldDetails(Entity it, String appName, Controller controller) '''
        <dl>
            «FOR field : getLeadingDisplayFields»«field.displayEntry(controller)»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    <dt>{gt text='«geoFieldName.toFirstUpper»'}</dt>
                    <dd>{$«name.formatForCode».«geoFieldName»|«appName.formatForDB»FormatGeoData}</dd>
                «ENDFOR»
            «ENDIF»
            «IF softDeleteable»
                <dt>{gt text='Deleted at'}</dt>
                <dd>{$«name.formatForCode».deletedAt|dateformat:'datebrief'}</dd>
            «ENDIF»
            «FOR relation : incoming.filter(OneToManyRelationship).filter(e|e.bidirectional)»«relation.displayEntry(controller, false)»«ENDFOR»
            «/*«FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayEntry(controller, true)»«ENDFOR»*/»
        </dl>
    '''

    def private templateHeader(Controller it, Entity entity, String appName) {
        switch it {
            AdminController: '''
                <div class="z-admin-content-pagetitle">
                    {icon type='display' size='small' __alt='Details'}
                    <h3>«templateHeading(entity, appName)»</h3>
                </div>
            '''
            default: '''
                <div class="z-frontendcontainer">
                    <h2>«templateHeading(entity, appName)»</h2>
            '''
        }
    }

    def private templateHeading(Entity it, String appName) '''{$templateTitle|notifyfilters:'«appName.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'}«IF hasVisibleWorkflow» ({$«name.formatForCode».workflowState|«appName.formatForDB»ObjectState:false|lower})«ENDIF»{icon id='itemactionstrigger' type='options' size='extrasmall' __alt='Actions' class='z-pointer z-hide'}'''

    def private templateFooter(Controller it) {
        switch it {
            AdminController: ''
            default: '''
                </div>
            '''
        }
    }

    def private displayEntry(DerivedField it, Controller controller) '''
        «val fieldLabel = if (name == 'workflowState') 'state' else name»
        <dt>{gt text='«fieldLabel.formatForDisplayCapital»'}</dt>
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
          «var linkController = getLinkController(container.application, controller, linkEntity)»
          «IF linkController !== null»
              <a href="{modurl modname='«linkEntity.container.application.appName»' type='«linkController.formattedName»' «linkEntity.modUrlDisplay(relObjName, true)»}">{strip}
          «ENDIF»
            «val leadingField = linkEntity.getLeadingField»
            «IF leadingField !== null»
                {$«relObjName».«leadingField.name.formatForCode»«/*|nl2br*/»|default:""}
            «ELSE»
                {gt text='«linkEntity.name.formatForDisplayCapital»'}
            «ENDIF»
          «IF linkController !== null»
            {/strip}</a>
            <a id="«linkEntity.name.formatForCode»Item«FOR pkField : linkEntity.getPrimaryKeyFields»{$«relObjName».«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«linkEntity.container.application.appName»' type='«linkController.formattedName»' «linkEntity.modUrlDisplay(relObjName, true)» theme='Printer'«controller.additionalUrlParametersForQuickViewLink»}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
            <script type="text/javascript">
            /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                    «val leadingLinkField = linkEntity.getLeadingField»
                    «IF leadingLinkField !== null»
                        «container.application.prefix»InitInlineWindow($('«linkEntity.name.formatForCode»Item«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«relObjName».«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$«relObjName».«leadingLinkField.name.formatForCode»|replace:"'":""}}');
                    «ELSE»
                        «container.application.prefix»InitInlineWindow($('«linkEntity.name.formatForCode»Item«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«relObjName».«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{gt text='«linkEntity.name.formatForDisplayCapital»'|replace:"'":""}}');
                    «ENDIF»
                });
            /* ]]> */
            </script>
          «ENDIF»
          {else}
        «IF leadingField !== null»
            {$«relObjName».«leadingField.name.formatForCode»«/*|nl2br*/»|default:""}
        «ELSE»
            {gt text='«linkEntity.name.formatForDisplayCapital»'}
        «ENDIF»
          {/if}
        {else}
            {gt text='Not set.'}
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
                <h3 class="«container.application.appName.formatForDB»map z-panel-header z-panel-indicator z-pointer">{gt text='Map'}</h3>
                <div class="«container.application.appName.formatForDB»map z-panel-content" style="display: none">
            «ELSE»
                <h3 class="«container.application.appName.formatForDB»map">{gt text='Map'}</h3>
            «ENDIF»
            {pageaddvarblock name='header'}
                <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
                <script type="text/javascript" src="{$baseurl}plugins/Mapstraction/lib/vendor/mxn/mxn.js?(googlev3)"></script>
                <script type="text/javascript">
                /* <![CDATA[ */
                    var mapstraction;
                    Event.observe(window, 'load', function() {
                        mapstraction = new mxn.Mapstraction('mapcontainer', 'googlev3');
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
            <div id="mapcontainer" class="«controller.container.application.appName.toLowerCase»mapcontainer">
            </div>
        «ENDIF»
        «IF attributable»
            {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/include_attributes_display.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
        «ENDIF»
        «IF categorisable»
            {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/include_categories_display.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
        «ENDIF»
        «IF tree != EntityTreeType::NONE»
            «IF useGroupingPanels('display')»
                <h3 class="relatives z-panel-header z-panel-indicator z-pointer">{gt text='Relatives'}</h3>
                <div class="relatives z-panel-content" style="display: none">
            «ELSE»
                <h3 class="relatives">{gt text='Relatives'}</h3>
            «ENDIF»
                    {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»/«name.formatForCode»«ELSE»«controller.formattedName.toFirstUpper»/«name.formatForCodeCapital»«ENDIF»/display_treeRelatives.tpl' allParents=true directParent=true allChildren=true directChildren=true predecessors=true successors=true preandsuccessors=true}
            «IF useGroupingPanels('display')»
                </div>
            «ENDIF»
        «ENDIF»
        «IF metaData»
            {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/include_metadata_display.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
        «ENDIF»
        «IF standardFields»
            {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/include_standardfields_display.tpl' obj=$«objName»«IF useGroupingPanels('display')» panel=true«ENDIF»}
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

    def private treeRelatives(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        «val pluginPrefix = container.application.appName.formatForDB»
        «val leadingField = getLeadingField»
        {* purpose of this template: show different forms of relatives for a given tree node *}
        <h3>{gt text='Related «nameMultiple.formatForDisplay»'}</h3>
        {if $«objName».lvl gt 0}
            {if !isset($allParents) || $allParents eq true}
                {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='allParents' assign='allParents'}
                {if $allParents ne null && count($allParents) gt 0}
                    <h4>{gt text='All parents'}</h4>
                    <ul>
                    {foreach item='node' from=$allParents}
                        <li><a href="{modurl modname='«appName»' type='«controller.formattedName»' «modUrlDisplay('node', true)»}"«IF leadingField !== null» title="{$node.«leadingField.name.formatForCode»|replace:'"':''}">{$node.«leadingField.name.formatForCode»}«ELSE»>{gt text='«name.formatForCodeCapital»'}«ENDIF»</a></li>
                    {/foreach}
                    </ul>
                {/if}
            {/if}
            {if !isset($directParent) || $directParent eq true}
                {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='directParent' assign='directParent'}
                {if $directParent ne null}
                    <h4>{gt text='Direct parent'}</h4>
                    <ul>
                        <li><a href="{modurl modname='«appName»' type='«controller.formattedName»' «modUrlDisplay('directParent', true)»}"«IF leadingField !== null» title="{$directParent.«leadingField.name.formatForCode»|replace:'"':''}">{$directParent.«leadingField.name.formatForCode»}«ELSE»>{gt text='«name.formatForCodeCapital»'}«ENDIF»</a></li>
                    </ul>
                {/if}
            {/if}
        {/if}
        {if !isset($allChildren) || $allChildren eq true}
            {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='allChildren' assign='allChildren'}
            {if $allChildren ne null && count($allChildren) gt 0}
                <h4>{gt text='All children'}</h4>
                <ul>
                {foreach item='node' from=$allChildren}
                    <li><a href="{modurl modname='«appName»' type='«controller.formattedName»' «modUrlDisplay('node', true)»}"«IF leadingField !== null» title="{$node.«leadingField.name.formatForCode»|replace:'"':''}">{$node.«leadingField.name.formatForCode»}«ELSE»>{gt text='«name.formatForCodeCapital»'}«ENDIF»</a></li>
                {/foreach}
                </ul>
            {/if}
        {/if}
        {if !isset($directChildren) || $directChildren eq true}
            {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='directChildren' assign='directChildren'}
            {if $directChildren ne null && count($directChildren) gt 0}
                <h4>{gt text='Direct children'}</h4>
                <ul>
                {foreach item='node' from=$directChildren}
                    <li><a href="{modurl modname='«appName»' type='«controller.formattedName»' «modUrlDisplay('node', true)»}"«IF leadingField !== null» title="{$node.«leadingField.name.formatForCode»|replace:'"':''}">{$node.«leadingField.name.formatForCode»}«ELSE»>{gt text='«name.formatForCodeCapital»'}«ENDIF»</a></li>
                {/foreach}
                </ul>
            {/if}
        {/if}
        {if $«objName».lvl gt 0}
            {if !isset($predecessors) || $predecessors eq true}
                {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='predecessors' assign='predecessors'}
                {if $predecessors ne null && count($predecessors) gt 0}
                    <h4>{gt text='Predecessors'}</h4>
                    <ul>
                    {foreach item='node' from=$predecessors}
                        <li><a href="{modurl modname='«appName»' type='«controller.formattedName»' «modUrlDisplay('node', true)»}"«IF leadingField !== null» title="{$node.«leadingField.name.formatForCode»|replace:'"':''}">{$node.«leadingField.name.formatForCode»}«ELSE»>{gt text='«name.formatForCodeCapital»'}«ENDIF»</a></li>
                    {/foreach}
                    </ul>
                {/if}
            {/if}
            {if !isset($successors) || $successors eq true}
                {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='successors' assign='successors'}
                {if $successors ne null && count($successors) gt 0}
                    <h4>{gt text='Successors'}</h4>
                    <ul>
                    {foreach item='node' from=$successors}
                        <li><a href="{modurl modname='«appName»' type='«controller.formattedName»' «modUrlDisplay('node', true)»}"«IF leadingField !== null» title="{$node.«leadingField.name.formatForCode»|replace:'"':''}">{$node.«leadingField.name.formatForCode»}«ELSE»>{gt text='«name.formatForCodeCapital»'}«ENDIF»</a></li>
                    {/foreach}
                    </ul>
                {/if}
            {/if}
            {if !isset($preandsuccessors) || $preandsuccessors eq true}
                {«pluginPrefix»TreeSelection objectType='«objName»' node=$«objName» target='preandsuccessors' assign='preandsuccessors'}
                {if $preandsuccessors ne null && count($preandsuccessors) gt 0}
                    <h4>{gt text='Siblings'}</h4>
                    <ul>
                    {foreach item='node' from=$preandsuccessors}
                        <li><a href="{modurl modname='«appName»' type='«controller.formattedName»' «modUrlDisplay('node', true)»}"«IF leadingField !== null» title="{$node.«leadingField.name.formatForCode»|replace:'"':''}">{$node.«leadingField.name.formatForCode»}«ELSE»>{gt text='«name.formatForCodeCapital»'}«ENDIF»</a></li>
                    {/foreach}
                    </ul>
                {/if}
            {/if}
        {/if}
    '''
}
