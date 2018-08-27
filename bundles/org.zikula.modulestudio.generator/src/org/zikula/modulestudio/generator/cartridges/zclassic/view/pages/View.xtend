package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ItemActionsPosition
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.UrlField
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ItemActionsView
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewQuickNavForm
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class View {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    SimpleFields fieldHelper = new SimpleFields
    Integer listType
    String appName

    static val LIST_TYPE_UL = 0
    static val LIST_TYPE_OL = 1
    static val LIST_TYPE_DL = 2
    static val LIST_TYPE_TABLE = 3

    def generate(Entity it, String appName, Integer listType, IMostFileSystemAccess fsa) {
        ('Generating view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        this.listType = listType
        this.appName = appName

        var templateFilePath = templateFile('view')
        fsa.generateFile(templateFilePath, viewView(false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/view')
            fsa.generateFile(templateFilePath, viewView(true))
        }
        new ViewQuickNavForm().generate(it, appName, fsa)
        if (loggable) {
            templateFilePath = templateFile('viewDeleted')
            fsa.generateFile(templateFilePath, viewViewDeleted(false))

            if (application.separateAdminTemplates) {
                templateFilePath = templateFile('Admin/viewDeleted')
                fsa.generateFile(templateFilePath, viewViewDeleted(true))
            }
        }
    }

    def private viewView(Entity it, Boolean isAdmin) '''
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» list view #}
            {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» list view #}
            {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
        «ENDIF»
        {% block title own ? __('My «nameMultiple.formatForDisplay»') : __('«nameMultiple.formatForDisplayCapital» list') %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'list-alt' %}
        «ENDIF»
        {% block content %}
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-view">
            «IF null !== documentation && !documentation.empty»

                «IF !documentation.containedTwigVariables.empty»
                    <p class="alert alert-info">{{ __f('«documentation.replace('\'', '\\\'').replaceTwigVariablesForTranslation»', {«documentation.containedTwigVariables.map[v|'\'%' + v + '%\': ' + v + '|default'].join(', ')»}) }}</p>
                «ELSE»
                    <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»') }}</p>
                «ENDIF»
            «ENDIF»

            {{ block('page_nav_links') }}

            {{ include('@«application.appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewQuickNav.html.twig'«IF !hasVisibleWorkflow», {workflowStateFilter: false}«ENDIF») }}{# see template file for available options #}

            «viewForm»
            «IF !skipHookSubscribers»

                {{ block('display_hooks') }}
            «ENDIF»
        </div>
        {% endblock %}
        {% block page_nav_links %}
            <p>
                «pageNavLinks»
            </p>
        {% endblock %}
        «IF !skipHookSubscribers»
            {% block display_hooks %}
                «callDisplayHooks»
            {% endblock %}
        «ENDIF»
    '''

    def private pageNavLinks(Entity it) '''
        «val objName = name.formatForCode»
        «IF hasEditAction»
            {% if canBeCreated %}
                {% if permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»')) %}
                    {% set createTitle = __('Create «name.formatForDisplay»') %}
                    <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'edit') }}" title="{{ createTitle|e('html_attr') }}"><i class="fa fa-plus"></i> {{ createTitle }}</a>
                {% endif %}
            {% endif %}
        «ENDIF»
        {% if all == 1 %}
            {% set linkTitle = __('Back to paginated view') %}
            {% set routeArgs = own ? {own: 1} : {} %}
            <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', routeArgs) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-table"></i> {{ linkTitle }}</a>
        {% else %}
            {% set linkTitle = __('Show all entries') %}
            {% set routeArgs = own ? {all: 1, own: 1} : {all: 1} %}
            <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', routeArgs) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-table"></i> {{ linkTitle }}</a>
        {% endif %}
        «IF tree != EntityTreeType.NONE»
            {% set linkTitle = __('Switch to hierarchy view') %}
            <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', {tpl: 'tree'}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-code-fork"></i> {{ linkTitle }}</a>
        «ENDIF»
        «IF standardFields»
            {% if own == 1 %}
                {% set linkTitle = __('Show also entries from other users') %}
                {% set routeArgs = all ? {all: 1} : {} %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', routeArgs) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-users"></i> {{ linkTitle }}</a>
            {% else %}
                {% set linkTitle = __('Show only own entries') %}
                {% set routeArgs = all ? {all: 1, own: 1} : {own: 1} %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', routeArgs) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-user"></i> {{ linkTitle }}</a>
            {% endif %}
        «ENDIF»
        «IF loggable»
            {% if hasDeletedEntities %}
                {% set linkTitle = __('View deleted «nameMultiple.formatForDisplay»') %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', {deleted: 1}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-trash-o"></i> {{ linkTitle }}</a>
            {% endif %}
        «ENDIF»
    '''

    def private viewForm(Entity it) '''
        «IF listType == LIST_TYPE_TABLE»
            {% if routeArea == 'admin' %}
            <form action="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'handleselectedentries') }}" method="post" id="«nameMultiple.formatForCode»ViewForm" class="form-horizontal" role="form">
                <div>
            {% endif %}
        «ENDIF»
            «viewItemList»
            «pagerCall»
        «IF listType == LIST_TYPE_TABLE»
            {% if routeArea == 'admin' %}
                    «massActionFields»
                </div>
            </form>
            {% endif %}
        «ENDIF»
    '''

    def private viewItemList(Entity it) '''
        «val listItemsFields = getFieldsForViewPage»
        «val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»
        «val listItemsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]»
        «viewItemListHeader(listItemsFields, listItemsIn, listItemsOut)»

        «viewItemListBody(listItemsFields, listItemsIn, listItemsOut)»

        «viewItemListFooter»
    '''

    def private viewItemListHeader(Entity it, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        «val app = application»
        «IF listType != LIST_TYPE_TABLE»
            <«listType.asListTag»>
        «ELSE»
            «IF hasSortableFields»
                {% set activateSortable = routeArea == 'admin' and sort.«getSortableFields.head.name.formatForCode».class == '«IF app.targets('2.0')»sorted-«ELSE»z-order-«ENDIF»asc' %}
            «ENDIF»
            <div class="table-responsive">
            <table«IF hasSortableFields»{% if activateSortable and items|length > 1 %} id="sortableTable" data-object-type="«name.formatForCode»" data-min="{{ items|first.«getSortableFields.head.name.formatForCode» }}" data-max="{{ items|last.«getSortableFields.head.name.formatForCode» }}"{% endif %}«ENDIF» class="table table-striped table-bordered table-hover«IF (listItemsFields.size + listItemsIn.size + listItemsOut.size + 1) > 7» table-condensed«ELSE»{% if routeArea == 'admin' %} table-condensed{% endif %}«ENDIF»">
                <colgroup>
                    {% if routeArea == 'admin' %}
                        <col id="cSelect" />
                    {% endif %}
                    «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(app.viewActionsPosition)»
                        <col id="cItemActionsStart" />
                    «ENDIF»
                    «IF hasSortableFields»
                        {% if activateSortable %}
                            <col id="cSortable" />
                        {% endif %}
                    «ENDIF»
                    «FOR field : listItemsFields»«field.columnDef»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.columnDef(false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.columnDef(true)»«ENDFOR»
                    «IF #[ItemActionsPosition.END, ItemActionsPosition.BOTH].contains(app.viewActionsPosition)»
                        <col id="cItemActionsEnd" />
                    «ENDIF»
                </colgroup>
                <thead>
                <tr>
                    {% if routeArea == 'admin' %}
                        <th id="hSelect" scope="col" class="text-center z-w02">
                            <input type="checkbox" class="«application.vendorAndName.toLowerCase»-mass-toggle" />
                        </th>
                    {% endif %}
                    «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(app.viewActionsPosition)»
                        <th id="hItemActionsStart" scope="col" class="«IF !app.targets('2.0')»z-order-unsorted «ENDIF»z-w02">{{ __('Actions') }}</th>
                    «ENDIF»
                    «IF hasSortableFields»
                        {% if activateSortable %}
                            <th id="hSortable" scope="col" class="«IF !app.targets('2.0')»z-order-unsorted «ENDIF»z-w02">{{ __('Sorting') }}</th>
                        {% endif %}
                    «ENDIF»
                    «FOR field : listItemsFields»«field.headerLine»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.headerLine(false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.headerLine(true)»«ENDFOR»
                    «IF #[ItemActionsPosition.END, ItemActionsPosition.BOTH].contains(app.viewActionsPosition)»
                        <th id="hItemActionsEnd" scope="col" class="«IF !app.targets('2.0')»z-order-unsorted «ENDIF»z-w02">{{ __('Actions') }}</th>
                    «ENDIF»
                </tr>
                </thead>
                <tbody>
        «ENDIF»
    '''

    def private viewItemListBody(Entity it, List<DerivedField> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        {% for «name.formatForCode» in items %}
            «IF listType == LIST_TYPE_UL || listType == LIST_TYPE_OL»
                <li><ul>
            «ELSEIF listType == LIST_TYPE_DL»
                <dt>
            «ELSEIF listType == LIST_TYPE_TABLE»
                <tr«IF hasSortableFields»{% if activateSortable %} data-item-id="{{ «name.formatForCode».getKey() }}" class="sort-item"{% endif %}«ENDIF»>
                    {% if routeArea == 'admin' %}
                        <td headers="hSelect" class="text-center z-w02">
                            <input type="checkbox" name="items[]" value="{{ «name.formatForCode».getKey() }}" class="«application.vendorAndName.toLowerCase»-toggle-checkbox" />
                        </td>
                    {% endif %}
            «ENDIF»
                «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.viewActionsPosition)»
                    «itemActions('Start')»
                «ENDIF»
                «IF hasSortableFields»
                    {% if activateSortable %}
                        <td headers="hSortable" class="text-center z-w02">
                            <i class="fa fa-arrows sort-handle pointer" title="{{ __('Drag to reorder') }}"></i>
                        </td>
                    {% endif %}
                «ENDIF»
                «FOR field : listItemsFields»«IF field.name == 'workflowState'»{% if routeArea == 'admin' %}«ENDIF»«field.displayEntry(false)»«IF field.name == 'workflowState'»{% endif %}«ENDIF»«ENDFOR»
                «FOR relation : listItemsIn»«relation.displayEntry(false)»«ENDFOR»
                «FOR relation : listItemsOut»«relation.displayEntry(true)»«ENDFOR»
                «IF #[ItemActionsPosition.END, ItemActionsPosition.BOTH].contains(application.viewActionsPosition)»
                    «itemActions('End')»
                «ENDIF»
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

    def private pagerCall(Entity it) '''

        {% if all != 1 and pager|default %}
            {{ pager({rowcount: pager.amountOfItems, limit: pager.itemsPerPage, display: 'page', route: '«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view'}) }}
        {% endif %}
    '''

    def private massActionFields(Entity it) '''
        <fieldset>
            <label for="«appName.toFirstLower»Action" class="col-sm-3 control-label">{{ __('With selected «nameMultiple.formatForDisplay»') }}</label>
            <div class="col-sm-6">
                <select id="«appName.toFirstLower»Action" name="action" class="form-control input-sm">
                    <option value="">{{ __('Choose action') }}</option>
                    «IF workflow != EntityWorkflowType.NONE»
                        «IF workflow == EntityWorkflowType.ENTERPRISE»
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
                        <option value="unarchive" title="{{ __('«getWorkflowActionDescription(workflow, 'Unarchive')»') }}">{{ __('Unarchive') }}</option>
                    «ENDIF»
                    <option value="delete" title="{{ __('«getWorkflowActionDescription(workflow, 'Delete')»') }}">{{ __('Delete') }}</option>
                </select>
            </div>
            <div class="col-sm-3">
                <input type="submit" value="{{ __('Submit') }}" class="btn btn-default btn-sm" />
            </div>
        </fieldset>
    '''

    def private callDisplayHooks(Entity it) '''

        {# here you can activate calling display hooks for the view page if you need it #}
        {# % if routeArea != 'admin' %}
            {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view', urlObject=currentUrlObject, outputAsArray=true) %}
            {% if hooks is iterable and hooks|length > 0 %}
                {% for area, hook in hooks %}
                    <div class="z-displayhook" data-area="{{ area|e('html_attr') }}">{{ hook|raw }}</div>
                {% endfor %}
            {% endif %}
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
        <th id="h«markupIdCode(false)»" scope="col" class="text-«alignment»«IF !entity.getSortingFields.contains(it)» «IF !application.targets('2.0')»z-order-«ENDIF»unsorted«ENDIF»">
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
            <«listType.asItemTag»«IF !cssClass.empty» class="«cssClass»"«ENDIF»>
        «ELSE»
            <td headers="h«markupIdCode(useTarget)»" class="text-«alignment»«IF !cssClass.empty» «cssClass»«ENDIF»">
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
        «IF #['name', 'title'].contains(name)»
            «IF entity instanceof Entity && (entity as Entity).hasDisplayAction»
                <a href="{{ path('«application.appName.formatForDB»_«entity.name.formatForDB»_' ~ routeArea ~ 'display'«(entity as Entity).routeParams(entity.name.formatForCode, true)») }}" title="{{ __('View detail page')|e('html_attr') }}">«displayLeadingEntry»</a>
            «ELSE»
                «displayLeadingEntry»
            «ENDIF»
        «ELSEIF name == 'workflowState'»
            {{ «entity.name.formatForCode».workflowState|«application.appName.formatForDB»_objectState }}
        «ELSE»
            «fieldHelper.displayField(it, entity.name.formatForCode, 'view')»
        «ENDIF»
    '''

    def private displayLeadingEntry(DerivedField it) {
        '''{{ «entity.name.formatForCode».«name.formatForCode»«IF entity instanceof Entity && !((entity as Entity).skipHookSubscribers)»|notifyFilters('«application.appName.formatForDB».filterhook.«(entity as Entity).nameMultiple.formatForDB»')|safeHtml«ENDIF» }}'''
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
                <a id="«linkEntity.name.formatForCode»Item{{ «mainEntity.name.formatForCode».getKey() }}_rel_{{ «relObjName».getKey() }}Display" href="{{ path('«application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display', {«IF !linkEntity.hasSluggableFields || !linkEntity.slugUnique»«linkEntity.routePkParams(relObjName, true)»«ENDIF»«linkEntity.appendSlug(relObjName, true)», raw: 1}) }}" title="{{ __('Open quick view window')|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ «relObjName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fa fa-id-card-o"></i></a>
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
            NumberField: 'right'
            EmailField: 'center'
            UrlField: 'center'
            default: 'left'
        }
    }

    def private itemActions(Entity it, String idSuffix) '''
        «IF listType != LIST_TYPE_TABLE»
            <«listType.asItemTag»>
        «ELSE»
            <td id="«new ItemActionsView().itemActionContainerViewId(it)»«idSuffix»" headers="hItemActions«idSuffix»" class="actions nowrap z-w02">
        «ENDIF»
            «new ItemActionsView().generate(it, 'view', idSuffix)»
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

    def private viewViewDeleted(Entity it, Boolean isAdmin) '''
        «IF application.separateAdminTemplates»
            {# purpose of this template: «IF isAdmin»admin«ELSE»user«ENDIF» list view of deleted «nameMultiple.formatForDisplay» #}
            {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: list view of deleted «nameMultiple.formatForDisplay» #}
            {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
        «ENDIF»
        {% block title __('Deleted «nameMultiple.formatForDisplay»') %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'trash-o' %}
        «ENDIF»
        {% block content %}
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-viewdeleted">
            {{ block('page_nav_links') }}
            «IF !hasDisplayAction»
                <p class="alert alert-info">{{ __('Because there exists no display action for «nameMultiple.formatForDisplay» it is not possible to preview deleted items.') }}</p>
            «ENDIF»
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
                            <th id="hId" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted z-w02">{{ __('ID') }}</th>
                            <th id="hDate" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Date') }}</th>
                            <th id="hUser" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('User') }}</th>
                            <th id="hActions" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Actions') }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for logEntry in deletedEntities %}
                            <tr>
                                <td headers="hVersion" class="text-center">{{ logEntry.objectId }}</td>
                                <td headers="hDate">{{ logEntry.loggedAt|localizeddate('long', 'medium') }}</td>
                                <td headers="hUser">{{ userAvatar(logEntry.username, {size: 20, rating: 'g'}) }} {{ logEntry.username|profileLinkByUserName() }}</td>
                                <td headers="hActions" class="actions nowrap">
                                    «IF hasDisplayAction»
                                        {% set linkTitle = __f('Preview «name.formatForDisplay» %id%', {'%id%': logEntry.objectId}) %}
                                        <a id="«name.formatForCode»ItemDisplay{{ logEntry.objectId }}" href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'undelete', {«getPrimaryKey.name.formatForCode»: logEntry.objectId, preview: 1, raw: 1}) }}" title="{{ linkTitle|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ __f('«name.formatForDisplayCapital» %id%', {'%id%': logEntry.objectId}) }}"><i class="fa fa-id-card-o"></i></a>
                                    «ENDIF»
                                    {% set linkTitle = __f('Undelete «name.formatForDisplay» %id%', {'%id%': logEntry.objectId}) %}
                                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'undelete', {«getPrimaryKey.name.formatForCode»: logEntry.objectId}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-history"></i></a>
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
                <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-reply"></i> {{ linkTitle }}</a>
            </p>
        {% endblock %}
    '''
}
