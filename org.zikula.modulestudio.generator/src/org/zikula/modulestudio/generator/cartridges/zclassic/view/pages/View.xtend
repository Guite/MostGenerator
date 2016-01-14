package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import java.util.List
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewQuickNavForm
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class View {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    SimpleFields fieldHelper = new SimpleFields

    Integer listType

    /*
      listType:
        0 = div and ul
        1 = div and ol
        2 = div and dl
        3 = div and table
     */
    def generate(Entity it, String appName, Integer listType, IFileSystemAccess fsa) {
        println('Generating view templates for entity "' + name.formatForDisplay + '"')
        this.listType = listType
        val templateFilePath = templateFile('view')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, viewView(appName))
        }
        new ViewQuickNavForm().generate(it, appName, fsa)
    }

    def private viewView(Entity it, String appName) '''
        «IF application.targets('1.3.x')»
            {* purpose of this template: «nameMultiple.formatForDisplay» list view *}
            {assign var='lct' value='user'}
            {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                {assign var='lct' value='admin'}
            {/if}
            {include file="`$lct`/header.tpl"}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» list view #}
            {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
            {% block title %}
                {{ __('«name.formatForDisplayCapital» list') }}
            {% endblock %}
            {% block adminPageIcon %}list{% endblock %}
            {% block content %}
        «ENDIF»
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-view">
            «IF application.targets('1.3.x')»
                {gt text='«name.formatForDisplayCapital» list' assign='templateTitle'}
                {pagesetvar name='title' value=$templateTitle}
                «templateHeader»
            «ENDIF»
            «IF null !== documentation && documentation != ''»

                «IF application.targets('1.3.x')»
                    <p class="z-informationmsg">{gt text='«documentation.replace('\'', '\\\'')»'}</p>
                «ELSE»
                    <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»') }}</p>
                «ENDIF»
            «ENDIF»

            «pageNavLinks(appName)»

            «IF application.targets('1.3.x')»
                {include file='«name.formatForCode»/viewQuickNav.tpl' all=$all own=$own«IF !hasVisibleWorkflow» workflowStateFilter=false«ENDIF»}{* see template file for available options *}
            «ELSE»
                {{ include('@«application.appName»/«name.formatForCodeCapital»/viewQuickNav.html.twig', { all: all, own: own«IF !hasVisibleWorkflow», workflowStateFilter: false«ENDIF» }) }}{# see template file for available options #}
            «ENDIF»

            «viewForm(appName)»
            «IF !skipHookSubscribers»

                «callDisplayHooks(appName)»
            «ENDIF»
        </div>
        «IF application.targets('1.3.x')»
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {% endblock %}
        «ENDIF»
        «ajaxToggle»
    '''

    def private pageNavLinks(Entity it, String appName) '''
        «val objName = name.formatForCode»
        «IF application.targets('1.3.x')»
            «IF hasActions('edit')»
                {if $canBeCreated}
                    {checkpermissionblock component='«appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»'}
                        {gt text='Create «name.formatForDisplay»' assign='createTitle'}
                        <a href="{modurl modname='«appName»' type=$lct func='edit' ot='«objName»'}" title="{$createTitle}" class="z-icon-es-add">{$createTitle}</a>
                    {/checkpermissionblock}
                {/if}
            «ENDIF»
            {assign var='own' value=0}
            {if isset($showOwnEntries) && $showOwnEntries eq 1}
                {assign var='own' value=1}
            {/if}
            {assign var='all' value=0}
            {if isset($showAllEntries) && $showAllEntries eq 1}
                {gt text='Back to paginated view' assign='linkTitle'}
                <a href="{modurl modname='«appName»' type=$lct func='view' ot='«objName»'}" title="{$linkTitle}" class="z-icon-es-view">{$linkTitle}</a>
                {assign var='all' value=1}
            {else}
                {gt text='Show all entries' assign='linkTitle'}
                <a href="{modurl modname='«appName»' type=$lct func='view' ot='«objName»' all=1}" title="{$linkTitle}" class="z-icon-es-view">{$linkTitle}</a>
            {/if}
            «IF tree != EntityTreeType.NONE»
                {gt text='Switch to hierarchy view' assign='linkTitle'}
                <a href="{modurl modname='«appName»' type=$lct func='view' ot='«objName»' tpl='tree'}" title="{$linkTitle}" class="z-icon-es-view">{$linkTitle}</a>
            «ENDIF»
        «ELSE»
            «IF hasActions('edit')»
                {% if canBeCreated %}
                    {% if hasPermission('«appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
                        {% set createTitle = __('Create «name.formatForDisplay»') %}
                        <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'edit') }}" title="{{ createTitle|e('html_attr') }}" class="fa fa-plus">{{ createTitle }}</a>
                    {% endif %}
                {% endif %}
            «ENDIF»
            {% set own = showOwnEntries is defined and showOwnEntries == 1 ? 1 : 0 %}
            {% set all = showAllEntries is defined and showAllEntries == 1 ? 1 : 0 %}
            {% all == 1 %}
                {% set linkTitle = __('Back to paginated view') %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-table">{{ linkTitle }}</a>
            {% else %}
                {% set linkTitle = __('Show all entries') %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', { all: 1 }) }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-table">{{ linkTitle }}</a>
            {% endif %}
            «IF tree != EntityTreeType.NONE»
                {% set linkTitle = __('Switch to hierarchy view') %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', { tpl: 'tree' }) }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-code-fork">{{ linkTitle }}</a>
            «ENDIF»
        «ENDIF»
    '''

    def private viewForm(Entity it, String appName) '''
        «IF listType == 3»
            «IF application.targets('1.3.x')»
                {if $lct eq 'admin'}
                <form action="{modurl modname='«appName»' type='«name.formatForCode»' func='handleSelectedEntries' lct=$lct}" method="post" id="«nameMultiple.formatForCode»ViewForm" class="z-form">
                    <div>
                        <input type="hidden" name="csrftoken" value="{insert name='csrftoken'}" />
                {/if}
            «ELSE»
                {% if routeArea == 'admin' %}
                <form action="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'handleselectedentries') }}" method="post" id="«nameMultiple.formatForCode»ViewForm" class="form-horizontal" role="form">
                    <div>
                {/if}
            «ENDIF»
        «ENDIF»
            «viewItemList(appName)»
            «pagerCall(appName)»
        «IF listType == 3»
            «IF application.targets('1.3.x')»
                {if $lct eq 'admin'}
                        «massActionFields(appName)»
                    </div>
                </form>
                {/if}
            «ELSE»
                {% if routeArea == 'admin' %}
                        «massActionFields(appName)»
                    </div>
                </form>
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def private viewItemList(Entity it, String appName) '''
            «val listItemsFields = getDisplayFieldsForView»
            «val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»
            «val listItemsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]»
            «viewItemListHeader(appName, listItemsFields, listItemsIn, listItemsOut)»

            «viewItemListBody(appName, listItemsFields, listItemsIn, listItemsOut)»

            «viewItemListFooter»
    '''

    def private viewItemListHeader(Entity it, String appName, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        «IF listType != 3»
            <«listType.asListTag»>
        «ELSE»
            «IF !application.targets('1.3.x')»
                <div class="table-responsive">
            «ENDIF»
            <table class="«IF application.targets('1.3.x')»z-datatable«ELSE»table table-striped table-bordered table-hover«IF (listItemsFields.size + listItemsIn.size + listItemsOut.size + 1) > 7» table-condensed«ELSE»{% if routeArea == 'admin' %} table-condensed{% endif %}«ENDIF»«ENDIF»">
                <colgroup>
                    «IF application.targets('1.3.x')»
                        {if $lct eq 'admin'}
                            <col id="cSelect" />
                        {/if}
                    «ELSE»
                        {% if routeArea == 'admin' %}
                            <col id="cSelect" />
                        {% endif %}
                    «ENDIF»
                    «FOR field : listItemsFields»«field.columnDef»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.columnDef(false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.columnDef(true)»«ENDFOR»
                    <col id="cItemActions" />
                </colgroup>
                <thead>
                <tr>
                    «IF application.targets('1.3.x')»
                        «IF categorisable»
                            {assign var='catIdListMainString' value=','|implode:$catIdList.Main}
                        «ENDIF»
                        {if $lct eq 'admin'}
                            <th id="hSelect" scope="col" align="center" valign="middle">
                                <input type="checkbox" id="toggle«nameMultiple.formatForCodeCapital»" />
                            </th>
                        {/if}
                    «ELSE»
                        «IF categorisable»
                            {% set catIdListMainString = catIdList.Main|join(',') %}
                        «ENDIF»
                        {% if routeArea == 'admin' %}
                            <th id="hSelect" scope="col" align="center" valign="middle">
                                <input type="checkbox" id="toggle«nameMultiple.formatForCodeCapital»" />
                            </th>
                        {% endif %}
                    «ENDIF»
                    «FOR field : listItemsFields»«field.headerLine»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.headerLine(false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.headerLine(true)»«ENDFOR»
                    <th id="hItemActions" scope="col" class="«IF application.targets('1.3.x')»z-right «ENDIF»z-order-unsorted">«IF application.targets('1.3.x')»{gt text='Actions'}«ELSE»{{ __('Actions') }}«ENDIF»</th>
                </tr>
                </thead>
                <tbody>
        «ENDIF»
    '''

    def private viewItemListBody(Entity it, String appName, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        «IF application.targets('1.3.x')»{foreach item='«name.formatForCode»' from=$items}«ELSE»{% for «name.formatForCode» in items %}«ENDIF»
            «IF listType < 2»
                <li><ul>
            «ELSEIF listType == 2»
                <dt>
            «ELSEIF listType == 3»
                <tr«IF application.targets('1.3.x')» class="{cycle values='z-odd, z-even'}"«ENDIF»>
                    «IF application.targets('1.3.x')»
                        {if $lct eq 'admin'}
                            <td headers="hselect" align="center" valign="top">
                                <input type="checkbox" name="items[]" value="{$«name.formatForCode».«getPrimaryKeyFields.head.name.formatForCode»}" class="«nameMultiple.formatForCode.toLowerCase»-checkbox" />
                            </td>
                        {/if}
                    «ELSE»
                        {% if routeArea == 'admin' %}
                            <td headers="hselect" align="center" valign="top">
                                <input type="checkbox" name="items[]" value="{{ «name.formatForCode».«getPrimaryKeyFields.head.name.formatForCode» }}" class="«nameMultiple.formatForCode.toLowerCase»-checkbox" />
                            </td>
                        {% endif %}
                    «ENDIF»
            «ENDIF»
                «FOR field : listItemsFields»«field.displayEntry(false)»«ENDFOR»
                «FOR relation : listItemsIn»«relation.displayEntry(false)»«ENDFOR»
                «FOR relation : listItemsOut»«relation.displayEntry(true)»«ENDFOR»
                «itemActions(appName)»
            «IF listType < 2»
                </ul></li>
            «ELSEIF listType == 2»
                </dt>
            «ELSEIF listType == 3»
                </tr>
            «ENDIF»
        «IF application.targets('1.3.x')»{foreachelse}«ELSE»{% else %}«ENDIF»
            «IF listType < 2»
                <li>
            «ELSEIF listType == 2»
                <dt>
            «ELSEIF listType == 3»
                <tr class="z-«IF application.targets('1.3.x')»{if $lct eq 'admin'}admin{else}data{/if}«ELSE»{{ routeArea == 'admin' ? 'admin' : 'data' }}«ENDIF»tableempty">
                «IF application.targets('1.3.x')»
                    «'    '»<td class="z-left" colspan="{if $lct eq 'admin'}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 1)»{else}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 0)»{/if}">
                «ELSE»
                    «'    '»<td class="text-left" colspan="{% if routeArea == 'admin' %}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 1)»{% else %}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 0)»{% endif %}">
                «ENDIF»
            «ENDIF»
            «IF application.targets('1.3.x')»{gt text='No «nameMultiple.formatForDisplay» found.'}«ELSE»{{ __('No «nameMultiple.formatForDisplay» found.') }}«ENDIF»
            «IF listType < 2»
                </li>
            «ELSEIF listType == 2»
                </dt>
            «ELSEIF listType == 3»
                  </td>
                </tr>
            «ENDIF»
        «IF application.targets('1.3.x')»{/foreach}«ELSE»{% endfor %}«ENDIF»
    '''

    def private viewItemListFooter(Entity it) '''
        «IF listType != 3»
            <«listType.asListTag»>
        «ELSE»
                </tbody>
            </table>
            «IF !application.targets('1.3.x')»
                </div>
            «ENDIF»
        «ENDIF»
    '''

    def private pagerCall(Entity it, String appName) '''

        «IF application.targets('1.3.x')»
            {if !isset($showAllEntries) || $showAllEntries ne 1}
                {pager rowcount=$pager.numitems limit=$pager.itemsperpage display='page' modname='«appName»' type=$lct func='view' ot='«name.formatForCode»'}
            {/if}
        «ELSE»
            {% if all != 1 %}
                {{ pager({ rowcount: pager.numitems, limit: pager.itemsperpage, display: 'page', route: '«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view'}) }}
            {% endif %}
        «ENDIF»
    '''

    def private massActionFields(Entity it, String appName) '''
        «IF application.targets('1.3.x')»
        <fieldset>
            <label for="«appName.toFirstLower»Action">{gt text='With selected «nameMultiple.formatForDisplay»'}</label>
            <select id="«appName.toFirstLower»Action" name="action">
                <option value="">{gt text='Choose action'}</option>
            «IF workflow != EntityWorkflowType::NONE»
                «IF workflow == EntityWorkflowType::ENTERPRISE»
                    <option value="accept" title="{gt text='«getWorkflowActionDescription(workflow, 'Accept')»'}">{gt text='Accept'}</option>
                    «IF ownerPermission»
                        <option value="reject" title="{gt text='«getWorkflowActionDescription(workflow, 'Reject')»'}">{gt text='Reject'}</option>
                    «ENDIF»
                    <option value="demote" title="{gt text='«getWorkflowActionDescription(workflow, 'Demote')»'}">{gt text='Demote'}</option>
                «ENDIF»
                <option value="approve" title="{gt text='«getWorkflowActionDescription(workflow, 'Approve')»'}">{gt text='Approve'}</option>
            «ENDIF»
            «IF hasTray»
                <option value="unpublish" title="{gt text='«getWorkflowActionDescription(workflow, 'Unpublish')»'}">{gt text='Unpublish'}</option>
                <option value="publish" title="{gt text='«getWorkflowActionDescription(workflow, 'Publish')»'}">{gt text='Publish'}</option>
            «ENDIF»
            «IF hasArchive»
                <option value="archive" title="{gt text='«getWorkflowActionDescription(workflow, 'Archive')»'}">{gt text='Archive' comment='this is the verb, not the noun'}</option>
            «ENDIF»
            «IF softDeleteable»
                <option value="trash" title="{gt text='«getWorkflowActionDescription(workflow, 'Trash')»'}">{gt text='Trash' comment='this is the verb, not the noun'}</option>
                <option value="recover" title="{gt text='«getWorkflowActionDescription(workflow, 'Recover')»'}">{gt text='Recover'}</option>
            «ENDIF»
                <option value="delete" title="{gt text='«getWorkflowActionDescription(workflow, 'Delete')»'}">{gt text='Delete'}</option>
            </select>
            <input type="submit" value="{gt text='Submit'}" />
        </fieldset>
        «ELSE»
        <fieldset>
            <label for="«appName.toFirstLower»Action" class="col-sm-3 control-label">{{ __('With selected «nameMultiple.formatForDisplay»') }}</label>
            <div class="col-sm-6">
                <select id="«appName.toFirstLower»Action" name="action" class="form-control input-sm">
                    <option value="">{{ __('Choose action') }}</option>
                «IF workflow != EntityWorkflowType::NONE»
                    «IF workflow == EntityWorkflowType::ENTERPRISE»
                        <option value="accept" title="{{ __('«getWorkflowActionDescription(workflow, 'Accept')»') }}">{{ __('Accept') }}</option>
                        «IF ownerPermission»
                            <option value="reject" title="{{ __('«getWorkflowActionDescription(workflow, 'Reject')»') }}">{{ __('Reject') }}</option>
                        «ENDIF»
                        <option value="demote" title="{{ __('«getWorkflowActionDescription(workflow, 'Demote')»') }}">{{ __('Demote') }}</option>
                    «ENDIF»
                    <option value="approve" title="{{ __('«getWorkflowActionDescription(workflow, 'Approve')»') }}">{{ __('Approve') }}</option>
                «ENDIF»
                «IF hasTray»
                    <option value="unpublish" title="{{ __('«getWorkflowActionDescription(workflow, 'Unpublish')»') }}">{{ __('Unpublish') }}</option>
                    <option value="publish" title="{{ __('«getWorkflowActionDescription(workflow, 'Publish')»') }}">{{ __('Publish') }}</option>
                «ENDIF»
                «IF hasArchive»
                    <option value="archive" title="{{ __('«getWorkflowActionDescription(workflow, 'Archive')»') }}">{{ __('Archive' comment='this is the verb, not the noun') }}</option>
                «ENDIF»
                «IF softDeleteable»
                    <option value="trash" title="{{ __('«getWorkflowActionDescription(workflow, 'Trash')»') }}">{{ __('Trash' comment='this is the verb, not the noun') }}</option>
                    <option value="recover" title="{{ __('«getWorkflowActionDescription(workflow, 'Recover')»') }}">{{ __('Recover') }}</option>
                «ENDIF»
                    <option value="delete" title="{{ __('«getWorkflowActionDescription(workflow, 'Delete')»') }}">{{ __('Delete') }}</option>
                </select>
            </div>
            <div class="col-sm-3">
                <input type="submit" value="{{ __('Submit') }}" class="btn btn-default btn-sm" />
            </div>
        </fieldset>
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName) '''

        «IF application.targets('1.3.x')»
            {* here you can activate calling display hooks for the view page if you need it *}
            {*if $lct ne 'admin'}
                {notifydisplayhooks eventname='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view' urlobject=$currentUrlObject assign='hooks'}
                {foreach key='providerArea' item='hook' from=$hooks}
                    {$hook}
                {/foreach}
            {/if*}
        «ELSE»
            {# here you can activate calling display hooks for the view page if you need it #}
            {# % if routeArea != 'admin' %}
                {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view', urlObject=currentUrlObject) %}
                {% for providerArea, hook in hooks %}
                    {{ hook }}
                {% endfor %}
            {% endif % #}
        «ENDIF»
    '''

    def private ajaxToggle(Entity it) '''
        «IF hasBooleansWithAjaxToggleEntity || listType == 3»
            «IF !application.targets('1.3.x')»
                {% block footer %}
                    {{ parent() }}
            «ENDIF»

            <script type="text/javascript">
            /* <![CDATA[ */
                «IF application.targets('1.3.x')»
                    document.observe('dom:loaded', function() {
                        «initAjaxSingleToggle»
                        «IF listType == 3»
                            «initMassToggle»
                        «ENDIF»
                    });
                «ELSE»
                    ( function($) {
                        $(document).ready(function() {
                            «new ItemActionsView().generateView(it, 'javascript')»
                            «initAjaxSingleToggle»
                            «IF listType == 3»
                                «initMassToggle»
                            «ENDIF»
                        });
                    })(jQuery);
                «ENDIF»
            /* ]]> */
            </script>
            «IF !application.targets('1.3.x')»
                {% endblock %}
            «ENDIF»
        «ENDIF»
    '''

    def private initAjaxSingleToggle(Entity it) '''
        «IF hasBooleansWithAjaxToggleEntity»
            «val objName = name.formatForCode»
            «IF application.targets('1.3.x')»
                {{foreach item='«objName»' from=$items}}
                    {{assign var='itemid' value=$«objName».«getFirstPrimaryKey.name.formatForCode»}}
                    «FOR field : getBooleansWithAjaxToggleEntity»
                        «application.vendorAndName»InitToggle('«objName»', '«field.name.formatForCode»', '{{$itemid}}');
                    «ENDFOR»
                {{/foreach}}
            «ELSE»
                {% for «objName» in items %}
                    {% set itemid = «objName».«getFirstPrimaryKey.name.formatForCode» %}
                    «FOR field : getBooleansWithAjaxToggleEntity»
                        «application.vendorAndName»InitToggle('«objName»', '«field.name.formatForCode»', '{{ itemid|e('js') }}');
                    «ENDFOR»
                {% endfor %}
            «ENDIF»
        «ENDIF»
    '''

    def private initMassToggle(Entity it) '''
        {{if «IF application.targets('1.3.x')»$lct«ELSE»$routeArea«ENDIF» eq 'admin'}}
            {{* init the "toggle all" functionality *}}
            «IF application.targets('1.3.x')»
                if ($('toggle«nameMultiple.formatForCodeCapital»') != undefined) {
                    $('toggle«nameMultiple.formatForCodeCapital»').observe('click', function (e) {
                        Zikula.toggleInput('«nameMultiple.formatForCode»ViewForm');
                        e.stop();
                    });
                }
            «ELSE»
                if ($('#toggle«nameMultiple.formatForCodeCapital»').length > 0) {
                    $('#toggle«nameMultiple.formatForCodeCapital»').on('click', function (e) {
                        Zikula.toggleInput('«nameMultiple.formatForCode»ViewForm');
                        e.preventDefault();
                    });
                }
            «ENDIF»
        {{/if}}
    '''

    // 1.3.x only
    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            <div class="z-admin-content-pagetitle">
                {icon type='view' size='small' alt=$templateTitle}
                <h3>{$templateTitle}</h3>
            </div>
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''

    def private columnDef(DerivedField it) '''
        <col id="c«markupIdCode(false)»" />
    '''

    def private columnDef(JoinRelationship it, Boolean useTarget) '''
        <col id="c«markupIdCode(useTarget)»" />
    '''

    def private headerLine(DerivedField it) '''
        <th id="h«markupIdCode(false)»" scope="col" class="«IF entity.application.targets('1.3.x')»z«ELSE»text«ENDIF»-«alignment»">
            «val fieldLabel = if (name == 'workflowState') 'state' else name»
            «headerSortingLink(entity, name.formatForCode, fieldLabel)»
        </th>
    '''

    def private headerLine(JoinRelationship it, Boolean useTarget) '''
        <th id="h«markupIdCode(useTarget)»" scope="col" class="«IF application.targets('1.3.x')»z«ELSE»text«ENDIF»-left">
            «val mainEntity = (if (useTarget) source else target)»
            «headerSortingLink(mainEntity, getRelationAliasName(useTarget).formatForCode, getRelationAliasName(useTarget).formatForCodeCapital)»
        </th>
    '''

    def private headerSortingLink(Object it, DataObject entity, String fieldName, String label) '''
        «IF entity.application.targets('1.3.x')»
            {sortlink __linktext='«label.formatForDisplayCapital»' currentsort=$sort modname='«entity.application.appName»' type=$lct func='view' sort='«fieldName»'«headerSortingLinkParameters(entity)» ot='«entity.name.formatForCode»'}
        «ELSE»
            <a href="{{ sort.«fieldName».url }}" title="{{ __f('Sort by %s', '«label.formatForDisplay»') }}" class="{{ sort.«fieldName».class }}">{{ __('«label.formatForDisplayCapital»') }}</a>
        «ENDIF»
    '''

    // 1.3.x only
    def private headerSortingLinkParameters(DataObject it) ''' sortdir=$sdir all=$all own=$own«IF it instanceof Entity && (it as Entity).categorisable» catidMain=$catIdListMainString«ENDIF»«sortParamsForIncomingRelations»«sortParamsForListFields»«sortParamsForUserFields»«sortParamsForCountryFields»«sortParamsForLanguageFields»«sortParamsForLocaleFields»«IF hasAbstractStringFieldsEntity» q=$q«ENDIF» pageSize=$pageSize«sortParamsForBooleanFields»'''

    // 1.3.x only
    def private sortParamsForIncomingRelations(DataObject it) '''«IF !getBidirectionalIncomingJoinRelationsWithOneSource.empty»«FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»«val sourceAliasName = relation.getRelationAliasName(false).formatForCode» «sourceAliasName»=$«sourceAliasName»«ENDFOR»«ENDIF»'''
    // 1.3.x only
    def private sortParamsForListFields(DataObject it) '''«IF hasListFieldsEntity»«FOR field : getListFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    // 1.3.x only
    def private sortParamsForUserFields(DataObject it) '''«IF hasUserFieldsEntity»«FOR field : getUserFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    // 1.3.x only
    def private sortParamsForCountryFields(DataObject it) '''«IF hasCountryFieldsEntity»«FOR field : getCountryFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    // 1.3.x only
    def private sortParamsForLanguageFields(DataObject it) '''«IF hasLanguageFieldsEntity»«FOR field : getLanguageFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    // 1.3.x only
    def private sortParamsForLocaleFields(DataObject it) '''«IF hasLocaleFieldsEntity»«FOR field : getLocaleFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    // 1.3.x only
    def private sortParamsForBooleanFields(DataObject it) '''«IF hasBooleanFieldsEntity»«FOR field : getBooleanFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''

    def private displayEntry(Object it, Boolean useTarget) '''
        «val cssClass = entryContainerCssClass»
        «IF listType != 3»
            <«listType.asItemTag»«IF cssClass != ''» class="«cssClass»"«ENDIF»>
        «ELSE»
            <td headers="h«markupIdCode(useTarget)»" class="z-«alignment»«IF cssClass != ''» «cssClass»«ENDIF»">
        «ENDIF»
            «displayEntryInner(useTarget)»
        </«listType.asItemTag»>
    '''

    def private dispatch entryContainerCssClass(Object it) {
        return ''
    }
    def private dispatch entryContainerCssClass(ListField it) {
        if (name == 'workflowState') {
            if (entity.application.targets('1.3.x')) {
                'z-nowrap'
            } else {
                'nowrap'
            }
        } else ''
    }

    def private dispatch displayEntryInner(Object it, Boolean useTarget) {
    }

    def private dispatch displayEntryInner(DerivedField it, Boolean useTarget) '''
        «IF newArrayList('name', 'title').contains(name)»
            «IF entity instanceof Entity && entity.hasActions('display')»
                «IF entity.application.targets('1.3.x')»
                    <a href="{modurl modname='«entity.application.appName»' type=$lct func='display' ot='«entity.name.formatForCode»' «(entity as Entity).routeParamsLegacy(entity.name.formatForCode, true, true)»}" title="{gt text='View detail page'}">«displayLeadingEntry»</a>
                «ELSE»
                    <a href="{{ path('«entity.application.appName.formatForDB»_«entity.name.formatForDB»_' ~ routeArea ~ 'display'«(entity as Entity).routeParams(entity.name.formatForCode, true)») }}" title="{{ __('View detail page')|e('html_attr') }}">«displayLeadingEntry»</a>
                «ENDIF»
            «ELSE»
                «displayLeadingEntry»
            «ENDIF»
        «ELSEIF name == 'workflowState'»
            «IF entity.application.targets('1.3.x')»
                {$«entity.name.formatForCode».workflowState|«entity.application.appName.formatForDB»ObjectState}
            «ELSE»
                {{ «entity.name.formatForCode».workflowState|«entity.application.appName.formatForDB»_objectState }}
            «ENDIF»
        «ELSE»
            «fieldHelper.displayField(it, entity.name.formatForCode, 'view')»
        «ENDIF»
    '''

    def private displayLeadingEntry(DerivedField it) {
        if (entity.application.targets('1.3.x')) '''{$«entity.name.formatForCode».«name.formatForCode»«IF entity instanceof Entity && !((entity as Entity).skipHookSubscribers)»|notifyfilters:'«entity.application.appName.formatForDB».filterhook.«(entity as Entity).nameMultiple.formatForDB»'«ENDIF»}'''
        else '''{{ «entity.name.formatForCode».«name.formatForCode»«IF entity instanceof Entity && !((entity as Entity).skipHookSubscribers)»|notifyFilters(«entity.application.appName.formatForDB».filterhook.«(entity as Entity).nameMultiple.formatForDB»')«ENDIF» }}'''
    }

    def private dispatch displayEntryInner(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (!useTarget) target else source) as Entity»
        «val linkEntity = (if (useTarget) target else source) as Entity»
        «var relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        «IF application.targets('1.3.x')»{if isset($«relObjName») && $«relObjName» ne null}«ELSE»{% if «relObjName»|default %}«ENDIF»
            «IF linkEntity.hasActions('display')»
                «IF application.targets('1.3.x')»
                    <a href="{modurl modname='«linkEntity.application.appName»' type=$lct func='display' ot='«linkEntity.name.formatForCode»' «linkEntity.routeParamsLegacy(relObjName, true, true)»}">{strip}
                «ELSE»
                    <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display'«linkEntity.routeParams(relObjName, true)») }}">{% spaceless %}
                «ENDIF»
            «ENDIF»
              «IF application.targets('1.3.x')»{$«relObjName»->getTitleFromDisplayPattern()}«ELSE»{{ «relObjName».getTitleFromDisplayPattern() }}«ENDIF»
            «IF linkEntity.hasActions('display')»
                «IF application.targets('1.3.x')»{/strip}«ELSE»{% endspaceless %}«ENDIF»</a>
                «IF application.targets('1.3.x')»
                    <a id="«linkEntity.name.formatForCode»Item«FOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'»{$«mainEntity.name.formatForCode».«pkField.name.formatForCode»}«ENDFOR»_rel_«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{$«relObjName».«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«application.appName»' type=$lct func='display' ot='«linkEntity.name.formatForCode»' «linkEntity.routeParamsLegacy(relObjName, true, true)» theme='Printer' forcelongurl=true}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
                «ELSE»
                    <a id="«linkEntity.name.formatForCode»Item«FOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'»{{ «mainEntity.name.formatForCode».«pkField.name.formatForCode» }}«ENDFOR»_rel_«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{ «relObjName».«pkField.name.formatForCode» }}«ENDFOR»Display" href="{{ path('«application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display', {«linkEntity.routePkParams(relObjName, true)»«linkEntity.appendSlug(relObjName, true)», 'theme': 'ZikulaPrinterTheme' }) }}" title="{{ __('Open quick view window')|e('html_attr') }}" class="fa fa-search-plus hidden"></a>
                «ENDIF»
                <script type="text/javascript">
                /* <![CDATA[ */
                    «IF application.targets('1.3.x')»
                        document.observe('dom:loaded', function() {
                            «application.vendorAndName»InitInlineWindow($('«linkEntity.name.formatForCode»Item«FOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«mainEntity.name.formatForCode».«pkField.name.formatForCode»}}«ENDFOR»_rel_«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«relObjName».«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$«relObjName»->getTitleFromDisplayPattern()|replace:"'":""}}');
                        });
                    «ELSE»
                        ( function($) {
                            $(document).ready(function() {
                                «application.vendorAndName»InitInlineWindow($('#«linkEntity.name.formatForCode»Item«FOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'»{{ «mainEntity.name.formatForCode».«pkField.name.formatForCode» }}«ENDFOR»_rel_«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{ «relObjName».«pkField.name.formatForCode» }}«ENDFOR»Display'), '{{ «relObjName».getTitleFromDisplayPattern()|e('js') }}');
                            });
                        })(jQuery);
                    «ENDIF»
                /* ]]> */
                </script>
            «ENDIF»
        «IF application.targets('1.3.x')»{else}«ELSE»{% else %}«ENDIF»
            «IF application.targets('1.3.x')»{gt text='Not set.'}«ELSE»{{ __('Not set.') }}«ENDIF»
        «IF application.targets('1.3.x')»{/if}«ELSE»{% endif %}«ENDIF»
    '''

    def private dispatch markupIdCode(Object it, Boolean useTarget) {
    }
    def private dispatch markupIdCode(NamedObject it, Boolean useTarget) {
        name.formatForCodeCapital
    }
    def private dispatch markupIdCode(DerivedField it, Boolean useTarget) {
        name.formatForCodeCapital
    }
    def private dispatch markupIdCode(JoinRelationship it, Boolean useTarget) {
        getRelationAliasName(useTarget).toFirstUpper
    }

    def private alignment(Object it) {
        switch it {
            BooleanField: 'center'
            IntegerField: 'right'
            DecimalField: 'right'
            FloatField: 'right'
            default: 'left'
        }
    }

    def private itemActions(Entity it, String appName) '''
        «IF listType != 3»
            <«listType.asItemTag»>
        «ELSE»
            <td id="«new ItemActionsView().itemActionContainerViewId(it)»" headers="hItemActions" class="«IF application.targets('1.3.x')»z-right z-nowrap«ELSE»actions nowrap«ENDIF» z-w02">
        «ENDIF»
            «new ItemActionsView().generateView(it, 'markup')»
        </«listType.asItemTag»>
    '''

    def private asListTag (Integer listType) {
        switch listType {
            case 0: 'ul'
            case 1: 'ol'
            case 2: 'dl'
            case 3: 'table'
        }
    }

    def private asItemTag (Integer listType) {
        switch listType {
            case 0: 'li' // ul
            case 1: 'li' // ol
            case 2: 'dd' // dl
            case 3: 'td' // table
        }
    }
}
