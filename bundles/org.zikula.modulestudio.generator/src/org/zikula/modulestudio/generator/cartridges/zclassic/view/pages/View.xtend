package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
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
import de.guite.modulestudio.metamodel.UrlField
import java.util.List
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewQuickNavForm
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class View {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    SimpleFields fieldHelper = new SimpleFields

    Integer listType

    static val LIST_TYPE_UL = 0
    static val LIST_TYPE_OL = 1
    static val LIST_TYPE_DL = 2
    static val LIST_TYPE_TABLE = 3

    def generate(Entity it, String appName, Integer listType, IFileSystemAccess fsa) {
        println('Generating view templates for entity "' + name.formatForDisplay + '"')
        this.listType = listType
        var templateFilePath = templateFile('view')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, viewView(appName, false))
        }
        if (application.generateSeparateAdminTemplates) {
            templateFilePath = templateFile('Admin/view')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, viewView(appName, true))
            }
        }
        new ViewQuickNavForm().generate(it, appName, fsa)
        if (loggable) {
            templateFilePath = templateFile('viewDeleted')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, viewViewDeleted(appName, false))
            }
            if (application.generateSeparateAdminTemplates) {
                templateFilePath = templateFile('Admin/viewDeleted')
                if (!application.shouldBeSkipped(templateFilePath)) {
                    fsa.generateFile(templateFilePath, viewViewDeleted(appName, true))
                }
            }
        }
    }

    def private viewView(Entity it, String appName, Boolean isAdmin) '''
        «IF application.generateSeparateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» list view #}
            {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» list view #}
            {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
        «ENDIF»
        {% block title own ? __('My «nameMultiple.formatForDisplay»') : __('«name.formatForDisplayCapital» list') %}
        «IF !application.generateSeparateAdminTemplates || isAdmin»
            {% block admin_page_icon 'list-alt' %}
        «ENDIF»
        {% block content %}
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-view">
            «IF null !== documentation && documentation != ''»

                «IF !documentation.containedTwigVariables.empty»
                    {{ __f('«documentation.replace('\'', '\\\'').replaceTwigVariablesForTranslation»', { «documentation.containedTwigVariables.map[v|'\'%' + v + '%\': ' + v + '|default'].join(', ')» }) }}
                «ELSE»
                    <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»') }}</p>
                «ENDIF»
            «ENDIF»

            {{ block('page_nav_links') }}

            {{ include('@«application.appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewQuickNav.html.twig'«IF !hasVisibleWorkflow», { workflowStateFilter: false }«ENDIF») }}{# see template file for available options #}

            «viewForm(appName)»
            «IF !skipHookSubscribers»

                {{ block('display_hooks') }}
            «ENDIF»
        </div>
        {% endblock %}
        {% block page_nav_links %}
            <p>
                «pageNavLinks(appName)»
            </p>
        {% endblock %}
        «IF !skipHookSubscribers»
            {% block display_hooks %}
                «callDisplayHooks(appName)»
            {% endblock %}
        «ENDIF»
    '''

    def private pageNavLinks(Entity it, String appName) '''
        «val objName = name.formatForCode»
        «IF hasEditAction»
            {% if canBeCreated %}
                {% if hasPermission('«appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
                    {% set createTitle = __('Create «name.formatForDisplay»') %}
                    <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'edit') }}" title="{{ createTitle|e('html_attr') }}" class="fa fa-plus">{{ createTitle }}</a>
                {% endif %}
            {% endif %}
        «ENDIF»
        {% if all == 1 %}
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
        «IF loggable»
            {% if hasDeletedEntities and hasPermission('«appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_EDIT') %}
                {% set linkTitle = __('View deleted «nameMultiple.formatForDisplay»') %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', { deleted: 1 }) }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-trash-o">{{ linkTitle }}</a>
            {% endif %}
        «ENDIF»
    '''

    def private viewForm(Entity it, String appName) '''
        «IF listType == LIST_TYPE_TABLE»
            {% if routeArea == 'admin' %}
            <form action="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'handleselectedentries') }}" method="post" id="«nameMultiple.formatForCode»ViewForm" class="form-horizontal" role="form">
                <div>
            {% endif %}
        «ENDIF»
            «viewItemList(appName)»
            «pagerCall(appName)»
        «IF listType == LIST_TYPE_TABLE»
            {% if routeArea == 'admin' %}
                    «massActionFields(appName)»
                </div>
            </form>
            {% endif %}
        «ENDIF»
    '''

    def private viewItemList(Entity it, String appName) '''
        «val listItemsFields = getFieldsForViewPage»
        «val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»
        «val listItemsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]»
        «viewItemListHeader(appName, listItemsFields, listItemsIn, listItemsOut)»

        «viewItemListBody(appName, listItemsFields, listItemsIn, listItemsOut)»

        «viewItemListFooter»
    '''

    def private viewItemListHeader(Entity it, String appName, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        «IF listType != LIST_TYPE_TABLE»
            <«listType.asListTag»>
        «ELSE»
            <div class="table-responsive">
            <table class="table table-striped table-bordered table-hover«IF (listItemsFields.size + listItemsIn.size + listItemsOut.size + 1) > 7» table-condensed«ELSE»{% if routeArea == 'admin' %} table-condensed{% endif %}«ENDIF»">
                <colgroup>
                    {% if routeArea == 'admin' %}
                        <col id="cSelect" />
                    {% endif %}
                    <col id="cItemActions" />
                    «FOR field : listItemsFields»«field.columnDef»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.columnDef(false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.columnDef(true)»«ENDFOR»
                </colgroup>
                <thead>
                <tr>
                    {% if routeArea == 'admin' %}
                        <th id="hSelect" scope="col" class="{% if items|length > 0 %}fixed-column {% endif %}text-center z-w02">
                            <input type="checkbox" class="«application.vendorAndName.toLowerCase»-mass-toggle" />
                        </th>
                    {% endif %}
                    <th id="hItemActions" scope="col" class="{% if items|length > 0 %}fixed-column {% endif %}z-order-unsorted z-w02">{{ __('Actions') }}</th>
                    «FOR field : listItemsFields»«field.headerLine»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.headerLine(false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.headerLine(true)»«ENDFOR»
                </tr>
                </thead>
                <tbody>
        «ENDIF»
    '''

    def private viewItemListBody(Entity it, String appName, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        {% for «name.formatForCode» in items %}
            «IF listType == LIST_TYPE_UL || listType == LIST_TYPE_OL»
                <li><ul>
            «ELSEIF listType == LIST_TYPE_DL»
                <dt>
            «ELSEIF listType == LIST_TYPE_TABLE»
                <tr>
                    {% if routeArea == 'admin' %}
                        <td headers="hSelect" class="fixed-column text-center z-w02">
                            <input type="checkbox" name="items[]" value="{{ «name.formatForCode».getKey() }}" class="«application.vendorAndName.toLowerCase»-toggle-checkbox" />
                        </td>
                    {% endif %}
            «ENDIF»
                «itemActions(appName)»
                «FOR field : listItemsFields»«IF field.name == 'workflowState'»{% if routeArea == 'admin' %}«ENDIF»«field.displayEntry(false)»«IF field.name == 'workflowState'»{% endif %}«ENDIF»«ENDFOR»
                «FOR relation : listItemsIn»«relation.displayEntry(false)»«ENDFOR»
                «FOR relation : listItemsOut»«relation.displayEntry(true)»«ENDFOR»
            «IF listType == LIST_TYPE_UL || listType == LIST_TYPE_OL»
                </ul></li>
            «ELSEIF listType == LIST_TYPE_DL»
                </dt>
            «ELSEIF listType == LIST_TYPE_TABLE»
                </tr>
            «ENDIF»
        {% else %}
            «IF listType == LIST_TYPE_UL || listType == LIST_TYPE_OL»
                <li>
            «ELSEIF listType == LIST_TYPE_DL»
                <dt>
            «ELSEIF listType == LIST_TYPE_TABLE»
                <tr class="z-{{ routeArea == 'admin' ? 'admin' : 'data' }}tableempty">
                «'    '»<td class="text-left" colspan="{% if routeArea == 'admin' %}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 1)»{% else %}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 0)»{% endif %}">
            «ENDIF»
            {{ __('No «nameMultiple.formatForDisplay» found.') }}
            «IF listType == LIST_TYPE_UL || listType == LIST_TYPE_OL»
                </li>
            «ELSEIF listType == LIST_TYPE_DL»
                </dt>
            «ELSEIF listType == LIST_TYPE_TABLE»
                  </td>
                </tr>
            «ENDIF»
        {% endfor %}
    '''

    def private viewItemListFooter(Entity it) '''
        «IF listType != LIST_TYPE_TABLE»
            <«listType.asListTag»>
        «ELSE»
                </tbody>
            </table>
            </div>
        «ENDIF»
    '''

    def private pagerCall(Entity it, String appName) '''

        {% if all != 1 and pager|default %}
            {{ pager({ rowcount: pager.amountOfItems, limit: pager.itemsPerPage, display: 'page', route: '«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view'}) }}
        {% endif %}
    '''

    def private massActionFields(Entity it, String appName) '''
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
                        <option value="archive" title="{{ __('«getWorkflowActionDescription(workflow, 'Archive')»') }}">{{ __('Archive') }}</option>
                    «ENDIF»
                    <option value="delete" title="{{ __('«getWorkflowActionDescription(workflow, 'Delete')»') }}">{{ __('Delete') }}</option>
                </select>
            </div>
            <div class="col-sm-3">
                <input type="submit" value="{{ __('Submit') }}" class="btn btn-default btn-sm" />
            </div>
        </fieldset>
    '''

    def private callDisplayHooks(Entity it, String appName) '''

        {# here you can activate calling display hooks for the view page if you need it #}
        {# % if routeArea != 'admin' %}
            {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view', urlObject=currentUrlObject) %}
            {% for providerArea, hook in hooks %}
                {{ hook }}
            {% endfor %}
        {% endif % #}
    '''

    def private columnDef(DerivedField it) '''
        «IF name == 'workflowState'»{% if routeArea == 'admin' %}«ENDIF»
        <col id="c«markupIdCode(false)»" />
        «IF name == 'workflowState'»{% endif %}«ENDIF»
    '''

    def private columnDef(JoinRelationship it, Boolean useTarget) '''
        <col id="c«markupIdCode(useTarget)»" />
    '''

    def private headerLine(DerivedField it) '''
        «IF name == 'workflowState'»{% if routeArea == 'admin' %}«ENDIF»
        <th id="h«markupIdCode(false)»" scope="col" class="text-«alignment»«IF !entity.getSortingFields.contains(it)» z-order-unsorted«ENDIF»">
            «val fieldLabel = if (name == 'workflowState') 'state' else name»
            «IF entity.getSortingFields.contains(it)»
                «headerSortingLink(entity, name.formatForCode, fieldLabel)»
            «ELSE»
                «headerTitle(entity, name.formatForCode, fieldLabel)»
            «ENDIF»
        </th>
        «IF name == 'workflowState'»{% endif %}«ENDIF»
    '''

    def private headerLine(JoinRelationship it, Boolean useTarget) '''
        <th id="h«markupIdCode(useTarget)»" scope="col" class="text-left">
            «val mainEntity = (if (useTarget) source else target)»
            «headerSortingLink(mainEntity, getRelationAliasName(useTarget).formatForCode, getRelationAliasName(useTarget).formatForCodeCapital)»
        </th>
    '''

    def private headerSortingLink(Object it, DataObject entity, String fieldName, String label) '''
        <a href="{{ sort.«fieldName».url }}" title="{{ __f('Sort by %s', {'%s': '«label.formatForDisplay»'}) }}" class="{{ sort.«fieldName».class }}">{{ __('«label.formatForDisplayCapital»') }}</a>
    '''

    def private headerTitle(Object it, DataObject entity, String fieldName, String label) '''
        {{ __('«label.formatForDisplayCapital»') }}
    '''

    def private displayEntry(Object it, Boolean useTarget) '''
        «val cssClass = entryContainerCssClass»
        «IF listType != LIST_TYPE_TABLE»
            <«listType.asItemTag»«IF cssClass != ''» class="«cssClass»"«ENDIF»>
        «ELSE»
            <td headers="h«markupIdCode(useTarget)»" class="text-«alignment»«IF cssClass != ''» «cssClass»«ENDIF»">
        «ENDIF»
            «displayEntryInner(useTarget)»
        </«listType.asItemTag»>
    '''

    def private dispatch entryContainerCssClass(Object it) {
        return ''
    }
    def private dispatch entryContainerCssClass(ListField it) {
        if (name == 'workflowState') {
            'nowrap'
        } else ''
    }

    def private dispatch displayEntryInner(Object it, Boolean useTarget) {
    }

    def private dispatch displayEntryInner(DerivedField it, Boolean useTarget) '''
        «IF newArrayList('name', 'title').contains(name)»
            «IF entity instanceof Entity && (entity as Entity).hasDisplayAction»
                <a href="{{ path('«entity.application.appName.formatForDB»_«entity.name.formatForDB»_' ~ routeArea ~ 'display'«(entity as Entity).routeParams(entity.name.formatForCode, true)») }}" title="{{ __('View detail page')|e('html_attr') }}">«displayLeadingEntry»</a>
            «ELSE»
                «displayLeadingEntry»
            «ENDIF»
        «ELSEIF name == 'workflowState'»
            {{ «entity.name.formatForCode».workflowState|«entity.application.appName.formatForDB»_objectState }}
        «ELSE»
            «fieldHelper.displayField(it, entity.name.formatForCode, 'view')»
        «ENDIF»
    '''

    def private displayLeadingEntry(DerivedField it) {
        '''{{ «entity.name.formatForCode».«name.formatForCode»«IF entity instanceof Entity && !((entity as Entity).skipHookSubscribers)»|notifyFilters('«entity.application.appName.formatForDB».filterhook.«(entity as Entity).nameMultiple.formatForDB»')|safeHtml«ENDIF» }}'''
    }

    def private dispatch displayEntryInner(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val mainEntity = (if (!useTarget) target else source) as Entity»
        «val linkEntity = (if (useTarget) target else source) as Entity»
        «var relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        {% if «relObjName»|default %}
            «IF linkEntity.hasDisplayAction»
                <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display'«linkEntity.routeParams(relObjName, true)») }}">{% spaceless %}
            «ENDIF»
              {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
            «IF linkEntity.hasDisplayAction»
                {% endspaceless %}</a>
                <a id="«linkEntity.name.formatForCode»Item{{ «mainEntity.name.formatForCode».getKey() }}_rel_{{ «relObjName».getKey() }}Display" href="{{ path('«application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display', {«linkEntity.routePkParams(relObjName, true)»«linkEntity.appendSlug(relObjName, true)», 'raw': 1 }) }}" title="{{ __('Open quick view window')|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ «relObjName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"><span class="fa fa-id-card-o"></span></a>
            «ENDIF»
        {% else %}
            {{ __('Not set.') }}
        {% endif %}
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
            EmailField: 'center'
            UrlField: 'center'
            default: 'left'
        }
    }

    def private itemActions(Entity it, String appName) '''
        «IF listType != LIST_TYPE_TABLE»
            <«listType.asItemTag»>
        «ELSE»
            <td id="«new ItemActionsView().itemActionContainerViewId(it)»" headers="hItemActions" class="fixed-column actions nowrap z-w02">
        «ENDIF»
            «new ItemActionsView().generate(it, 'view')»
        </«listType.asItemTag»>
    '''

    def private asListTag (Integer listType) {
        switch listType {
            case LIST_TYPE_UL: 'ul'
            case LIST_TYPE_OL: 'ol'
            case LIST_TYPE_DL: 'dl'
            case LIST_TYPE_TABLE: 'table'
            default: 'table'
        }
    }

    def private asItemTag (Integer listType) {
        switch listType {
            case LIST_TYPE_UL: 'li' // ul
            case LIST_TYPE_OL: 'li' // ol
            case LIST_TYPE_DL: 'dd' // dl
            case LIST_TYPE_TABLE: 'td' // table
            default: 'td'
        }
    }

    def private viewViewDeleted(Entity it, String appName, Boolean isAdmin) '''
        «IF application.generateSeparateAdminTemplates»
            {# purpose of this template: «IF isAdmin»admin«ELSE»user«ENDIF» list view of deleted «nameMultiple.formatForDisplay» #}
            {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: list view of deleted «nameMultiple.formatForDisplay» #}
            {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
        «ENDIF»
        {% block title __('Deleted «nameMultiple.formatForDisplay»') %}
        «IF !application.generateSeparateAdminTemplates || isAdmin»
            {% block admin_page_icon 'trash-o' %}
        «ENDIF»
        {% block content %}
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewdeleted">
            {{ block('page_nav_links') }}
            <div class="table-responsive">
                <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-condensed{% endif %}">
                    <colgroup>
                        <col id="cId" />
                        <col id="cDate" />
                        <col id="cUser" />
                        <col id="cActions" />
                    </colgroup>
                    <thead>
                        <tr>
                            <th id="hId" scope="col" class="z-order-unsorted z-w02">{{ __('ID') }}</th>
                            <th id="hDate" scope="col" class="z-order-unsorted">{{ __('Date') }}</th>
                            <th id="hUser" scope="col" class="z-order-unsorted">{{ __('User') }}</th>
                            <th id="hActions" scope="col" class="z-order-unsorted">{{ __('Actions') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for logEntry in deletedItems %}
                            <tr>
                                <td headers="hVersion" class="text-center">{{ logEntry.objectId }}</td>
                                <td headers="hDate">{{ logEntry.loggedAt|localizeddate('long', 'medium') }}</td>
                                <td headers="hUser">{{ «appName.toLowerCase»_userAvatar(uid=logEntry.username, size=20, rating='g') }} {{ logEntry.username|profileLinkByUserName() }}</td>
                                <td headers="hActions" class="actions nowrap">
                                    «IF hasDisplayAction»
                                        {% set linkTitle = __f('Preview «name.formatForDisplay» %id%', { '%id%': logEntry.objectId }) %}
                                        <a id="«name.formatForCode»ItemDisplay{{ logEntry.objectId }}" href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'displaydeleted', { '«getPrimaryKey.name.formatForCode»': logEntry.objectId, 'raw': 1 }) }}" title="{{ linkTitle|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ __f('«name.formatForDisplayCapital» %id%', { '%id%': logEntry.objectId }) }}"><span class="fa fa-id-card-o"></span></a>
                                    «ENDIF»
                                    {% set linkTitle = __f('Undelete «name.formatForDisplay» %id%', { '%id%': logEntry.objectId }) %}
                                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'displaydeleted', { '«getPrimaryKey.name.formatForCode»': logEntry.objectId, 'undelete': 1 }) }}" title="{{ linkTitle|e('html_attr') }}"><span class="fa fa-history"></span></a>
                                </td>
                            </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
            {{ block('page_nav_links') }}
        </div>
        {% endblock %}
        {% block page_nav_links %}
            <p>
                {% set linkTitle = __('Back to overview') %}
                <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-reply">{{ linkTitle }}</a>
            </p>
        {% endblock %}
    '''
}
