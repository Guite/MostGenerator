package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.NamedObject
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.UserController
import java.util.List
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewQuickNavForm
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class View {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension UrlExtensions = new UrlExtensions
    @Inject extension Utils = new Utils
    @Inject extension ViewExtensions = new ViewExtensions
    @Inject extension WorkflowExtensions = new WorkflowExtensions

    SimpleFields fieldHelper = new SimpleFields

    Integer listType

    /*
      listType:
        0 = div and ul
        1 = div and ol
        2 = div and dl
        3 = div and table
     */
    def generate(Entity it, String appName, Controller controller, Integer listType, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' view templates for entity "' + name.formatForDisplay + '"')
        this.listType = listType
        val templateFilePath = templateFile(controller, name, 'view')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, viewView(appName, controller))
        }
        new ViewQuickNavForm().generate(it, appName, controller, fsa)
    }

    def private viewView(Entity it, String appName, Controller controller) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view view in «controller.formattedName» area *}
        {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/header.tpl'}
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-view">
            {gt text='«name.formatForDisplayCapital» list' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            «controller.templateHeader»
            «IF documentation !== null && documentation != ''»

                <p class="«IF container.application.targets('1.3.5')»z-informationmsg«ELSE»alert alert-info«ENDIF»">{gt text='«documentation.replace('\'', '\\\'')»'}</p>
            «ENDIF»

            «pageNavLinks(appName, controller)»

            {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»/«name.formatForCode»«ELSE»«controller.formattedName.toFirstUpper»/«name.formatForCodeCapital»«ENDIF»/view_quickNav.tpl' all=$all own=$own«IF !hasVisibleWorkflow» workflowStateFilter=false«ENDIF»}{* see template file for available options *}

            «viewForm(appName, controller)»

            «callDisplayHooks(appName, controller)»
        </div>
        {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/footer.tpl'}
        «ajaxToggle(controller)»
    '''

    def private pageNavLinks(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        «IF controller.hasActions('edit')»
            {if $canBeCreated}
                {checkpermissionblock component='«appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»'}
                    {gt text='Create «name.formatForDisplay»' assign='createTitle'}
                    <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='edit' ot='«objName»'}" title="{$createTitle}" class="«IF container.application.targets('1.3.5')»z-icon-es-add«ELSE»fa fa-plus«ENDIF»">{$createTitle}</a>
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
            <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='view' ot='«objName»'}" title="{$linkTitle}" class="«IF container.application.targets('1.3.5')»z-icon-es-view«ELSE»fa fa-table«ENDIF»">
                {$linkTitle}
            </a>
            {assign var='all' value=1}
        {else}
            {gt text='Show all entries' assign='linkTitle'}
            <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='view' ot='«objName»' all=1}" title="{$linkTitle}" class="«IF container.application.targets('1.3.5')»z-icon-es-view«ELSE»fa fa-table«ENDIF»">{$linkTitle}</a>
        {/if}
        «IF tree != EntityTreeType::NONE»
            {gt text='Switch to hierarchy view' assign='linkTitle'}
            <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='view' ot='«objName»' tpl='tree'}" title="{$linkTitle}" class="«IF container.application.targets('1.3.5')»z-icon-es-view«ELSE»fa fa-code-fork«ENDIF»">{$linkTitle}</a>
        «ENDIF»
    '''

    def private viewForm(Entity it, String appName, Controller controller) '''
        «IF listType == 3 && controller.tableClass == 'admin'»
            <form action="{modurl modname='«appName»' type='«controller.formattedName»' func='handleSelectedEntries'}" method="post" id="«nameMultiple.formatForCode»ViewForm" class="«IF container.application.targets('1.3.5')»z-form«ELSE»form-horizontal«ENDIF»"«IF !container.application.targets('1.3.5')» role="form"«ENDIF»>
                <div>
                    <input type="hidden" name="csrftoken" value="{insert name='csrftoken'}" />
                    <input type="hidden" name="ot" value="«name.formatForCode»" />
                    «viewItemList(appName, controller)»
                    «pagerCall(appName, controller)»
                    «massActionFields(appName)»
                </div>
            </form>
        «ELSE»
            «viewItemList(appName, controller)»
            «pagerCall(appName, controller)»
        «ENDIF»
    '''

    def private viewItemList(Entity it, String appName, Controller controller) '''
            «val listItemsFields = getDisplayFieldsForView»
            «val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional]»
            «val listItemsOut = outgoing.filter(OneToOneRelationship)»
            «viewItemListHeader(appName, controller, listItemsFields, listItemsIn, listItemsOut)»

            «viewItemListBody(appName, controller, listItemsFields, listItemsIn, listItemsOut)»

            «viewItemListFooter»
    '''

    def private viewItemListHeader(Entity it, String appName, Controller controller, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        «IF listType != 3»
            <«listType.asListTag»>
        «ELSE»
            «IF !container.application.targets('1.3.5')»
                <div class="table-responsive">
            «ENDIF»
            <table class="«IF container.application.targets('1.3.5')»z-datatable«ELSE»table table-striped table-bordered table-hover«IF (listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + (if (controller.tableClass == 'admin') 1 else 0)) > 7» table-condensed«ENDIF»«ENDIF»">
                <colgroup>
                    «IF controller.tableClass == 'admin'»
                        <col id="cSelect" />
                    «ENDIF»
                    «FOR field : listItemsFields»«field.columnDef»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.columnDef(false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.columnDef(true)»«ENDFOR»
                    <col id="cItemActions" />
                </colgroup>
                <thead>
                <tr>
                    «IF categorisable»
                        {assign var='catIdListMainString' value=','|implode:$catIdList.Main}
                    «ENDIF»
                    «IF controller.tableClass == 'admin'»
                        <th id="hSelect" scope="col" align="center" valign="middle">
                            <input type="checkbox" id="toggle«nameMultiple.formatForCodeCapital»" />
                        </th>
                    «ENDIF»
                    «FOR field : listItemsFields»«field.headerLine(controller)»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.headerLine(controller, false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.headerLine(controller, true)»«ENDFOR»
                    <th id="hItemActions" scope="col" class="«IF container.application.targets('1.3.5')»z-right «ENDIF»z-order-unsorted">{gt text='Actions'}</th>
                </tr>
                </thead>
                <tbody>
        «ENDIF»
    '''

    def private viewItemListBody(Entity it, String appName, Controller controller, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        {foreach item='«name.formatForCode»' from=$items}
            «IF listType < 2»
                <li><ul>
            «ELSEIF listType == 2»
                <dt>
            «ELSEIF listType == 3»
                <tr«IF container.application.targets('1.3.5')» class="{cycle values='z-odd, z-even'}"«ENDIF»>
                    «IF controller.tableClass == 'admin'»
                        <td headers="hselect" align="center" valign="top">
                            <input type="checkbox" name="items[]" value="{$«name.formatForCode».«getPrimaryKeyFields.head.name.formatForCode»}" class="«nameMultiple.formatForCode.toLowerCase»-checkbox" />
                        </td>
                    «ENDIF»
            «ENDIF»
                «FOR field : listItemsFields»«field.displayEntry(controller, false)»«ENDFOR»
                «FOR relation : listItemsIn»«relation.displayEntry(controller, false)»«ENDFOR»
                «FOR relation : listItemsOut»«relation.displayEntry(controller, true)»«ENDFOR»
                «itemActions(appName, controller)»
            «IF listType < 2»
                </ul></li>
            «ELSEIF listType == 2»
                </dt>
            «ELSEIF listType == 3»
                </tr>
            «ENDIF»
        {foreachelse}
            «IF listType < 2»
                <li>
            «ELSEIF listType == 2»
                <dt>
            «ELSEIF listType == 3»
                <tr class="z-«controller.tableClass»tableempty">
                  <td class="«IF container.application.targets('1.3.5')»z«ELSE»text«ENDIF»-left" colspan="«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + (if (controller.tableClass == 'admin') 1 else 0))»">
            «ENDIF»
            {gt text='No «nameMultiple.formatForDisplay» found.'}
            «IF listType < 2»
                </li>
            «ELSEIF listType == 2»
                </dt>
            «ELSEIF listType == 3»
                  </td>
                </tr>
            «ENDIF»
        {/foreach}
    '''

    def private viewItemListFooter(Entity it) '''
        «IF listType != 3»
            <«listType.asListTag»>
        «ELSE»
                </tbody>
            </table>
            «IF !container.application.targets('1.3.5')»
                </div>
            «ENDIF»
        «ENDIF»
    '''

    def private pagerCall(Entity it, String appName, Controller controller) '''

        {if !isset($showAllEntries) || $showAllEntries ne 1}
            {pager rowcount=$pager.numitems limit=$pager.itemsperpage display='page' modname='«appName»' type='«controller.formattedName»' func='view' ot='«name.formatForCode»'}
        {/if}
    '''

    def private massActionFields(Entity it, String appName) '''
        <fieldset>
            <label for="«appName.toFirstLower»Action"«IF !container.application.targets('1.3.5')» class="col-lg-3 control-label"«ENDIF»>{gt text='With selected «nameMultiple.formatForDisplay»'}</label>
            «IF !container.application.targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
            <select id="«appName.toFirstLower»Action" name="action"«IF !container.application.targets('1.3.5')» class="form-control"«ENDIF»>
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
                <option value="archive" title="{gt text='«getWorkflowActionDescription(workflow, 'Archive')»' comment='this is the verb, not the noun'}">{gt text='Archive'}</option>
            «ENDIF»
            «IF softDeleteable»
                <option value="trash" title="{gt text='«getWorkflowActionDescription(workflow, 'Trash')»' comment='this is the verb, not the noun'}">{gt text='Trash'}</option>
                <option value="recover" title="{gt text='«getWorkflowActionDescription(workflow, 'Recover')»'}">{gt text='Recover'}</option>
            «ENDIF»
                <option value="delete" title="{gt text='«getWorkflowActionDescription(workflow, 'Delete')»'}">{gt text='Delete'}</option>
            </select>
            «IF !container.application.targets('1.3.5')»
                </div>
            «ENDIF»
            <input type="submit" value="{gt text='Submit'}" />
        </fieldset>
    '''

    def private tableClass(Controller it) {
        switch it {
            AdminController: 'admin'
            default: 'data'
        }
    }

    def private callDisplayHooks(Entity it, String appName, Controller controller) {
        switch controller {
            UserController: '''

                {notifydisplayhooks eventname='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view' urlobject=$currentUrlObject assign='hooks'}
                {foreach key='providerArea' item='hook' from=$hooks}
                    {$hook}
                {/foreach}
            '''
            default: ''
        }
    }

    def private ajaxToggle(Entity it, Controller controller) '''
        «IF hasBooleansWithAjaxToggleEntity || (listType == 3 && controller.tableClass == 'admin')»

            <script type="text/javascript">
            /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                «IF hasBooleansWithAjaxToggleEntity»
                    «val objName = name.formatForCode»
                    {{foreach item='«objName»' from=$items}}
                        {{assign var='itemid' value=$«objName».«getFirstPrimaryKey.name.formatForCode»}}
                        «FOR field : getBooleansWithAjaxToggleEntity»
                            «container.application.prefix»InitToggle('«objName»', '«field.name.formatForCode»', '{{$itemid}}');
                        «ENDFOR»
                    {{/foreach}}
                «ENDIF»
                «IF listType == 3 && controller.tableClass == 'admin'»
                    {{* init the "toggle all" functionality *}}
                    if ($('toggle«nameMultiple.formatForCodeCapital»') != undefined) {
                        $('toggle«nameMultiple.formatForCodeCapital»').observe('click', function (e) {
                            Zikula.toggleInput('«nameMultiple.formatForCode»ViewForm');
                            e.stop()
                        });
                    }
                «ENDIF»
                });
            /* ]]> */
            </script>
        «ENDIF»
    '''

    def private templateHeader(Controller it) {
        switch it {
            AdminController: '''
                «IF container.application.targets('1.3.5')»
                    <div class="z-admin-content-pagetitle">
                        {icon type='view' size='small' alt=$templateTitle}
                        <h3>{$templateTitle}</h3>
                    </div>
                «ELSE»
                    <h3>
                        <span class="fa fa-list"></span>
                        {$templateTitle}
                    </h3>
                «ENDIF»
            '''
            default: '''
                <h2>{$templateTitle}</h2>
            '''
        }
    }

    def private columnDef(DerivedField it) '''
        <col id="c«markupIdCode(false)»" />
    '''

    def private columnDef(JoinRelationship it, Boolean useTarget) '''
        <col id="c«markupIdCode(useTarget)»" />
    '''

    def private headerLine(DerivedField it, Controller controller) '''
        <th id="h«markupIdCode(false)»" scope="col" class="«IF entity.container.application.targets('1.3.5')»z«ELSE»text«ENDIF»-«alignment»">
            «val fieldLabel = if (name == 'workflowState') 'state' else name»
            «headerSortingLink(controller, entity, name.formatForCode, fieldLabel)»
        </th>
    '''

    def private headerLine(JoinRelationship it, Controller controller, Boolean useTarget) '''
        <th id="h«markupIdCode(useTarget)»" scope="col" class="«IF container.application.targets('1.3.5')»z«ELSE»text«ENDIF»-left">
            «val mainEntity = (if (useTarget) source else target)»
            «headerSortingLink(controller, mainEntity, getRelationAliasName(useTarget).formatForCode, getRelationAliasName(useTarget).formatForCodeCapital)»
        </th>
    '''

    def private headerSortingLink(Object it, Controller controller, Entity entity, String fieldName, String label) '''
        {sortlink __linktext='«label.formatForDisplayCapital»' currentsort=$sort modname='«controller.container.application.appName»' type='«controller.formattedName»' func='view' ot='«entity.name.formatForCode»' sort='«fieldName»'«headerSortingLinkParameters(entity)»}
    '''

    def private headerSortingLinkParameters(Entity it) ''' sortdir=$sdir all=$all own=$own«IF categorisable» catidMain=$catIdListMainString«ENDIF»«sortParamsForIncomingRelations»«sortParamsForListFields»«sortParamsForUserFields»«sortParamsForCountryFields»«sortParamsForLanguageFields»«sortParamsForLocaleFields»«IF hasAbstractStringFieldsEntity» searchterm=$searchterm«ENDIF» pageSize=$pageSize«sortParamsForBooleanFields»'''

    def private sortParamsForIncomingRelations(Entity it) '''«IF !getBidirectionalIncomingJoinRelationsWithOneSource.empty»«FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»«val sourceAliasName = relation.getRelationAliasName(false).formatForCode» «sourceAliasName»=$«sourceAliasName»«ENDFOR»«ENDIF»'''
    def private sortParamsForListFields(Entity it) '''«IF hasListFieldsEntity»«FOR field : getListFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    def private sortParamsForUserFields(Entity it) '''«IF hasUserFieldsEntity»«FOR field : getUserFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    def private sortParamsForCountryFields(Entity it) '''«IF hasCountryFieldsEntity»«FOR field : getCountryFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    def private sortParamsForLanguageFields(Entity it) '''«IF hasLanguageFieldsEntity»«FOR field : getLanguageFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    def private sortParamsForLocaleFields(Entity it) '''«IF hasLocaleFieldsEntity»«FOR field : getLocaleFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''
    def private sortParamsForBooleanFields(Entity it) '''«IF hasBooleanFieldsEntity»«FOR field : getBooleanFieldsEntity»«val fieldName = field.name.formatForCode» «fieldName»=$«fieldName»«ENDFOR»«ENDIF»'''

    def private displayEntry(Object it, Controller controller, Boolean useTarget) '''
        «val cssClass = entryContainerCssClass»
        «IF listType != 3»
            <«listType.asItemTag»«IF cssClass != ''» class="«cssClass»"«ENDIF»>
        «ELSE»
            <td headers="h«markupIdCode(useTarget)»" class="z-«alignment»«IF cssClass != ''» «cssClass»«ENDIF»">
        «ENDIF»
            «displayEntryInner(controller, useTarget)»
        </«listType.asItemTag»>
    '''

    def private dispatch entryContainerCssClass(Object it) {
        return ''
    }
    def private dispatch entryContainerCssClass(ListField it) {
        if (name == 'workflowState') {
            if (entity.container.application.targets('1.3.5')) {
                'z-nowrap'
            } else {
                'nowrap'
            }
        } else ''
    }

    def private dispatch displayEntryInner(Object it, Controller controller, Boolean useTarget) {
    }

    def private dispatch displayEntryInner(DerivedField it, Controller controller, Boolean useTarget) '''
        «IF leading == true»
            «IF controller.hasActions('display')»
                <a href="{modurl modname='«controller.container.application.appName»' type='«controller.formattedName»' «entity.modUrlDisplay(entity.name.formatForCode, true)»}" title="{gt text='View detail page'}">«displayLeadingEntry(controller)»</a>
            «ELSE»
                «displayLeadingEntry(controller)»
            «ENDIF»
        «ELSEIF name == 'workflowState'»
            {$«entity.name.formatForCode».workflowState|«controller.container.application.appName.formatForDB»ObjectState}
        «ELSE»
            «fieldHelper.displayField(it, entity.name.formatForCode, 'view')»
        «ENDIF»
    '''

    def private displayLeadingEntry(DerivedField it, Controller controller) '''{$«entity.name.formatForCode».«name.formatForCode»|notifyfilters:'«entity.container.application.appName.formatForDB».filterhook.«entity.nameMultiple.formatForDB»'}'''

    def private dispatch displayEntryInner(JoinRelationship it, Controller controller, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (!useTarget) target else source)»
        «val linkEntity = (if (useTarget) target else source)»
        «var relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        {if isset($«relObjName») && $«relObjName» ne null}
            «var linkController = getLinkController(container.application, controller, linkEntity)»
            «IF linkController !== null»
                <a href="{modurl modname='«linkEntity.container.application.appName»' type='«linkController.formattedName»' «linkEntity.modUrlDisplay(relObjName, true)»}">{strip}
            «ENDIF»
              {$«relObjName»->getTitleFromDisplayPattern()|default:""}
            «IF linkController !== null»
                {/strip}</a>
                «IF container.application.targets('1.3.5')»
                    <a id="«linkEntity.name.formatForCode»Item«FOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'»{$«mainEntity.name.formatForCode».«pkField.name.formatForCode»}«ENDFOR»_rel_«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{$«relObjName».«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«container.application.appName»' type='«linkController.formattedName»' «linkEntity.modUrlDisplay(relObjName, true)» theme='Printer'«linkController.additionalUrlParametersForQuickViewLink»}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
                «ELSE»
                    <a id="«linkEntity.name.formatForCode»Item«FOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'»{$«mainEntity.name.formatForCode».«pkField.name.formatForCode»}«ENDFOR»_rel_«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{$«relObjName».«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«container.application.appName»' type='«linkController.formattedName»' «linkEntity.modUrlDisplay(relObjName, true)» theme='Printer'«linkController.additionalUrlParametersForQuickViewLink»}" title="{gt text='Open quick view window'}" class="fa fa-search-plus hidden"></a>
                «ENDIF»
                <script type="text/javascript">
                /* <![CDATA[ */
                    document.observe('dom:loaded', function() {
                        «container.application.prefix»InitInlineWindow($('«linkEntity.name.formatForCode»Item«FOR pkField : mainEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«mainEntity.name.formatForCode».«pkField.name.formatForCode»}}«ENDFOR»_rel_«FOR pkField : linkEntity.getPrimaryKeyFields SEPARATOR '_'»{{$«relObjName».«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$«relObjName»->getTitleFromDisplayPattern()|replace:"'":""}}');
                    });
                /* ]]> */
                </script>
            «ENDIF»
        {else}
            {gt text='Not set.'}
        {/if}
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

    def private itemActions(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        «IF listType != 3»
            <«listType.asItemTag»>
        «ELSE»
            <td id="«itemActionContainerId»" headers="hItemActions" class="«IF container.application.targets('1.3.5')»z-right z-nowrap«ELSE»actions nowrap«ENDIF» z-w02">
        «ENDIF»
            {if count($«objName»._actions) gt 0}
                {foreach item='option' from=$«objName»._actions}
                    «IF container.application.targets('1.3.5')»
                        <a href="{$option.url.type|«appName.formatForDB»ActionUrl:$option.url.func:$option.url.arguments}" title="{$option.linkTitle|safetext}"{if $option.icon eq 'preview'} target="_blank"{/if}>{icon type=$option.icon size='extrasmall' alt=$option.linkText|safetext}</a>
                    «ELSE»
                        <a href="{$option.url.type|«appName.formatForDB»ActionUrl:$option.url.func:$option.url.arguments}" title="{$option.linkTitle|safetext}"{if $option.icon eq 'zoom-in'} target="_blank"{/if} class="fa fa-{$option.icon}" data-linktext="{$option.linkText|safetext}"></a>
                    «ENDIF»
                {/foreach}
                {icon id="«itemActionContainerIdForSmarty»Trigger" type='options' size='extrasmall' __alt='Actions' class='«IF container.application.targets('1.3.5')»z-pointer z-hide«ELSE»cursor-pointer hidden«ENDIF»'}
                <script type="text/javascript">
                /* <![CDATA[ */
                    document.observe('dom:loaded', function() {
                        «container.application.prefix»InitItemActions('«name.formatForCode»', 'view', '«itemActionContainerIdForJs»');
                    });
                /* ]]> */
                </script>
            {/if}
        </«listType.asItemTag»>
    '''

    def private itemActionContainerId(Entity it) '''
        «val objName = name.formatForCode»
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{$«objName».«pkField.name.formatForCode»}«ENDFOR»'''

    def private itemActionContainerIdForJs(Entity it) '''
        «val objName = name.formatForCode»
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$«objName».«pkField.name.formatForCode»}}«ENDFOR»'''

    def private itemActionContainerIdForSmarty(Entity it) '''
        «val objName = name.formatForCode»
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«objName».«pkField.name.formatForCode»`«ENDFOR»'''

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
