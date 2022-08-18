package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.view

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
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
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.MenuViews
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewPagesHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewQuickNavForm
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ViewTable {

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
        ('Generating table view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        this.listType = listType
        this.appName = appName

        var templateFilePath = templateFile('view')
        fsa.generateFile(templateFilePath, viewView)

        new ViewQuickNavForm().generate(it, appName, fsa)
        if (loggable) {
            new ViewDeleted().generate(it, appName, fsa)
        }
    }

    def private viewView(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» list view #}
        {% extends routeArea == 'admin' ? '@«application.appName»/adminBase.html.twig' : '@«application.appName»/base.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% block title own ? 'My «nameMultiple.formatForDisplay»'|trans : '«nameMultiple.formatForDisplayCapital» list'|trans %}
        {% block admin_page_icon 'list-alt' %}
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-view">
                «(new ViewPagesHelper).commonHeader(it)»
                {{ include('@«application.appName»/«name.formatForCodeCapital»/viewQuickNav.html.twig'«IF !hasVisibleWorkflow», {workflowStateFilter: false}«ENDIF») }}{# see template file for available options #}

                «viewForm»
            </div>
        {% endblock %}
    '''

    def private viewForm(Entity it) '''
        «IF listType == LIST_TYPE_TABLE»
            {% if routeArea == 'admin' %}
            <form action="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'handleselectedentries') }}" method="post" id="«nameMultiple.formatForCode»ViewForm">
                <div>
            {% endif %}
        «ENDIF»
            «viewItemList»
            «(new ViewPagesHelper).pagerCall(it)»
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
                {% set activateSortable = routeArea == 'admin' and sort.«getSortableFields.head.name.formatForCode».class == 'sorted-asc' %}
            «ENDIF»
            <div class="table-responsive">
            <table«IF hasSortableFields»{% if activateSortable and items|length > 1 %} id="sortableTable" data-object-type="«name.formatForCode»" data-min="{{ items|first.«getSortableFields.head.name.formatForCode» }}" data-max="{{ items|last.«getSortableFields.head.name.formatForCode» }}"{% endif %}«ENDIF» class="table table-striped table-bordered table-hover«IF (listItemsFields.size + listItemsIn.size + listItemsOut.size + 1) > 7» table-sm«ELSE»{% if routeArea == 'admin' %} table-condensed{% endif %}«ENDIF»">
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
                        <th id="hSelect" scope="col" class="text-center">
                            <input type="checkbox" class="«application.vendorAndName.toLowerCase»-mass-toggle" />
                        </th>
                    {% endif %}
                    «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(app.viewActionsPosition)»
                        <th id="hItemActionsStart" scope="col">{% trans from 'messages' %}Actions{% endtrans %}</th>
                    «ENDIF»
                    «IF hasSortableFields»
                        {% if activateSortable %}
                            <th id="hSortable" scope="col">{% trans from 'messages' %}Sorting{% endtrans %}</th>
                        {% endif %}
                    «ENDIF»
                    «FOR field : listItemsFields»«field.headerLine»«ENDFOR»
                    «FOR relation : listItemsIn»«relation.headerLine(false)»«ENDFOR»
                    «FOR relation : listItemsOut»«relation.headerLine(true)»«ENDFOR»
                    «IF #[ItemActionsPosition.END, ItemActionsPosition.BOTH].contains(app.viewActionsPosition)»
                        <th id="hItemActionsEnd" scope="col">{% trans from 'messages' %}Actions{% endtrans %}</th>
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
                        <td headers="hSelect" class="text-center">
                            <input type="checkbox" name="items[]" value="{{ «name.formatForCode».getKey() }}" class="«application.vendorAndName.toLowerCase»-toggle-checkbox" />
                        </td>
                    {% endif %}
            «ENDIF»
                «IF #[ItemActionsPosition.START, ItemActionsPosition.BOTH].contains(application.viewActionsPosition)»
                    «itemActions('Start')»
                «ENDIF»
                «IF hasSortableFields»
                    {% if activateSortable %}
                        <td headers="hSortable" class="text-center">
                            <i class="fas fa-arrows-alt sort-handle pointer" title="{{ 'Drag to reorder'|trans({}, 'messages')|e('html_attr') }}"></i>
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
                <tr class="table-info">
                «'    '»<td colspan="{% if routeArea == 'admin' %}«IF hasSortableFields»{% if activateSortable %}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 1 + 1)»{% else %}«ENDIF»«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 1)»«IF hasSortableFields»{% endif %}«ENDIF»{% else %}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 0)»{% endif %}" class="text-center">
            «ENDIF»
            {% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}
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

    def private massActionFields(Entity it) '''
        <fieldset class="my-3 pt-3">
            <div class="row">
                «massActionFieldsInner»
            </div>
        </fieldset>
    '''

    def private massActionFieldsInner(Entity it) '''
        <label for="«appName.toFirstLower»Action" class="col-md-3 col-form-label">{% trans %}With selected «nameMultiple.formatForDisplay»{% endtrans %}</label>
        <div class="col-md-6">
            <select id="«appName.toFirstLower»Action" name="action" class="form-control form-control-sm">
                <option value="">{% trans from 'messages' %}Choose action{% endtrans %}</option>
                «IF workflow != EntityWorkflowType.NONE»
                    «IF workflow == EntityWorkflowType.ENTERPRISE»
                        <option value="accept" title="{{ '«getWorkflowActionDescription(workflow, 'Accept')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Accept{% endtrans %}</option>
                        «IF ownerPermission»
                            <option value="reject" title="{{ '«getWorkflowActionDescription(workflow, 'Reject')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Reject{% endtrans %}</option>
                        «ENDIF»
                        <option value="demote" title="{{ '«getWorkflowActionDescription(workflow, 'Demote')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Demote{% endtrans %}</option>
                    «ENDIF»
                    <option value="approve" title="{{ '«getWorkflowActionDescription(workflow, 'Approve')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Approve{% endtrans %}</option>
                «ENDIF»
                «IF hasTray»
                    <option value="publish" title="{{ '«getWorkflowActionDescription(workflow, 'Publish')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Publish{% endtrans %}</option>
                    <option value="unpublish" title="{{ '«getWorkflowActionDescription(workflow, 'Unpublish')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Unpublish{% endtrans %}</option>
                «ENDIF»
                «IF hasArchive»
                    <option value="archive" title="{{ '«getWorkflowActionDescription(workflow, 'Archive')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Archive{% endtrans %}</option>
                    <option value="unarchive" title="{{ '«getWorkflowActionDescription(workflow, 'Unarchive')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Unarchive{% endtrans %}</option>
                «ENDIF»
                <option value="delete" title="{{ '«getWorkflowActionDescription(workflow, 'Delete')»'|trans({}, 'messages')|e('html_attr') }}">{% trans from 'messages' %}Delete{% endtrans %}</option>
            </select>
        </div>
        <div class="col-md-3">
            <input type="submit" value="{{ 'Submit'|trans({}, 'messages')|e('html_attr') }}" class="btn btn-secondary btn-sm" />
        </div>
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
        <th id="h«markupIdCode(false)»" scope="col" class="text-«alignment»«IF !entity.getSortingFields.contains(it)» unsorted«ENDIF»">
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
        <a href="{{ sort.«fieldName».url }}" title="{{ 'Sort by %fieldName%'|trans({'%fieldName%': '«label.formatForDisplay»'}, 'messages')|e('html_attr') }}" class="{{ sort.«fieldName».class }}">{% trans %}«label.formatForDisplayCapital»{% endtrans %}</a>
    '''

    def private headerTitle(Object it, DataObject entity, String fieldName, String label) '''
        {% trans %}«label.formatForDisplayCapital»{% endtrans %}
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
                <a href="{{ path('«application.appName.formatForDB»_«entity.name.formatForDB»_' ~ routeArea ~ 'display'«(entity as Entity).routeParams(entity.name.formatForCode, true)») }}" title="{{ 'View detail page'|trans({}, 'messages')|e('html_attr') }}">«displayLeadingEntry»</a>
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
        '''{{ «entity.name.formatForCode».«name.formatForCode» }}'''
    }

    def private dispatch displayEntryInner(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val mainEntity = (if (!useTarget) target else source) as Entity»
        «val linkEntity = (if (useTarget) target else source) as Entity»
        «var relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        {% if «relObjName»|default %}
            «IF linkEntity.hasDisplayAction»
                <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display'«linkEntity.routeParams(relObjName, true)») }}">{% apply spaceless %}
            «ENDIF»
              {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
            «IF linkEntity.hasDisplayAction»
                {% endapply %}</a>
                <a id="«linkEntity.name.formatForCode»Item{{ «mainEntity.name.formatForCode».getKey() }}_rel_{{ «relObjName».getKey() }}Display" href="{{ path('«application.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'display', {«IF !linkEntity.hasSluggableFields || !linkEntity.slugUnique»«linkEntity.routePkParams(relObjName, true)»«ENDIF»«linkEntity.appendSlug(relObjName, true)», raw: 1}) }}" title="{{ 'Open quick view window'|trans({}, 'messages')|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ «relObjName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fas fa-id-card"></i></a>
            «ENDIF»
        {% else %}
            {% trans from 'messages' %}Not set{% endtrans %}
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
            <td id="«new MenuViews().itemActionContainerViewId(it)»«idSuffix»" headers="hItemActions«idSuffix»" class="actions">
        «ENDIF»
            «new MenuViews().itemActions(it, 'view', idSuffix)»
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
}
