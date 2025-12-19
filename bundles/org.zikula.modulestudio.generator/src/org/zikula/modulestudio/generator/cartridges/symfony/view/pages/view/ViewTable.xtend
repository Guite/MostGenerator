package org.zikula.modulestudio.generator.cartridges.symfony.view.pages.view

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.Relationship
import java.util.List
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.IndexPagesHelper
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.MenuViews
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewTable {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    String appName

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating table view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        this.appName = appName

        var templateFilePath = templateFile('index')
        fsa.generateFile(templateFilePath, indexView)

        if (loggable) {
            new ViewDeleted().generate(it, appName, fsa)
        }
    }

    def private indexView(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» index view #}
        {% extends routeArea == 'admin' ? '@«application.appName»/adminBase.html.twig' : '@«application.appName»/base.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% block title own ? 'My «nameMultiple.formatForDisplay»'|trans : '«nameMultiple.formatForDisplayCapital» list'|trans %}
        {% block admin_page_icon 'list-alt' %}
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-index">
                «(new IndexPagesHelper).commonHeader(it)»

                «viewItemList»
                «(new IndexPagesHelper).pagerCall(it)»
            </div>
        {% endblock %}
    '''

    def private viewItemList(Entity it) '''
        «val listItemsFields = getFieldsForIndexPage»
        «val listItemsIn = incoming.filter(OneToManyRelationship).filter[bidirectional]»
        «val listItemsOut = outgoing.filter(OneToOneRelationship)»
        «viewItemListHeader(listItemsFields, listItemsIn, listItemsOut)»

        «viewItemListBody(listItemsFields, listItemsIn, listItemsOut)»

        «viewItemListFooter»
    '''

    def private viewItemListHeader(Entity it, List<Field> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        «IF hasSortableFields»
            {% set activateSortable = routeArea == 'admin'«/* TODO and sort.«getSortableFields.head.name.formatForCode».class == 'sorted-asc'*/» %}
        «ENDIF»
        <div class="table-responsive">
        <table«IF hasSortableFields»{% if activateSortable and items|length > 1 %} id="sortableTable" data-object-type="«name.formatForCode»" data-min="{{ items|first.«getSortableFields.head.name.formatForCode» }}" data-max="{{ items|last.«getSortableFields.head.name.formatForCode» }}"{% endif %}«ENDIF» class="table table-striped table-bordered table-hover«IF (listItemsFields.size + listItemsIn.size + listItemsOut.size + 1) > 7» table-sm«ELSE»{% if routeArea == 'admin' %} table-condensed{% endif %}«ENDIF»">
            <colgroup>
                {% if routeArea == 'admin' %}
                    <col id="cSelect" />
                {% endif %}
                <col id="cItemActions" />
                «IF hasSortableFields»
                    {% if activateSortable %}
                        <col id="cSortable" />
                    {% endif %}
                «ENDIF»
                «FOR field : listItemsFields»«field.columnDef»«ENDFOR»
                «FOR relation : listItemsIn»«relation.columnDef(false)»«ENDFOR»
                «FOR relation : listItemsOut»«relation.columnDef(true)»«ENDFOR»
            </colgroup>
            <thead>
            <tr>
                {% if routeArea == 'admin' %}
                    <th id="hSelect" scope="col" class="text-center">
                        <input type="checkbox" class="«application.vendorAndName.toLowerCase»-mass-toggle" />
                    </th>
                {% endif %}
                <th id="hItemActions" scope="col">{% trans from 'messages' %}Actions{% endtrans %}</th>
                «IF hasSortableFields»
                    {% if activateSortable %}
                        <th id="hSortable" scope="col">{% trans from 'messages' %}Sorting{% endtrans %}</th>
                    {% endif %}
                «ENDIF»
                «FOR field : listItemsFields»«field.headerLine»«ENDFOR»
                «FOR relation : listItemsIn»«relation.headerLine(false)»«ENDFOR»
                «FOR relation : listItemsOut»«relation.headerLine(true)»«ENDFOR»
            </tr>
            </thead>
            <tbody>
    '''

    def private viewItemListBody(Entity it, List<Field> listItemsFields, Iterable<OneToManyRelationship> listItemsIn, Iterable<OneToOneRelationship> listItemsOut) '''
        {% for «name.formatForCode» in items %}
            <tr«IF hasSortableFields»{% if activateSortable %} data-item-id="{{ «name.formatForCode».getKey() }}" class="sort-item"{% endif %}«ENDIF»>
                {% if routeArea == 'admin' %}
                    <td headers="hSelect" class="text-center">
                        <input type="checkbox" name="items[]" value="{{ «name.formatForCode».getKey() }}" class="«application.vendorAndName.toLowerCase»-toggle-checkbox" />
                    </td>
                {% endif %}
                «itemActions»
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
            </tr>
        {% else %}
            <tr class="table-info">
            «'    '»<td colspan="{% if routeArea == 'admin' %}«IF hasSortableFields»{% if activateSortable %}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 1 + 1)»{% else %}«ENDIF»«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 1)»«IF hasSortableFields»{% endif %}«ENDIF»{% else %}«(listItemsFields.size + listItemsIn.size + listItemsOut.size + 1 + 0)»{% endif %}" class="text-center">
            {% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}
              </td>
            </tr>
        {% endfor %}
    '''

    def private viewItemListFooter(Entity it) '''
            </tbody>
        </table>
        </div>
    '''

    def private columnDef(Field it) '''
        «IF name == 'workflowState'»{% if routeArea == 'admin' %}«ENDIF»
        <col id="c«markupIdCode(false)»" />
        «IF name == 'workflowState'»{% endif %}«ENDIF»
    '''

    def private columnDef(Relationship it, Boolean useTarget) '''
        <col id="c«markupIdCode(useTarget)»" />
    '''

    def private headerLine(Field it) '''
        «IF name == 'workflowState'»{% if routeArea == 'admin' %}«ENDIF»
        <th id="h«markupIdCode(false)»" scope="col" class="text-«alignment»">
            «val fieldLabel = if (name == 'workflowState') 'state' else name»
            «headerTitle(entity, name.formatForCode, fieldLabel)»
        </th>
        «IF name == 'workflowState'»{% endif %}«ENDIF»
    '''

    def private headerLine(Relationship it, Boolean useTarget) '''
        <th id="h«markupIdCode(useTarget)»" scope="col" class="text-left">
            «val mainEntity = (if (useTarget) source else target)»
            «headerTitle(mainEntity, getRelationAliasName(useTarget).formatForCode, getRelationAliasName(useTarget).formatForCodeCapital)»
        </th>
    '''

    def private headerTitle(Object it, Entity entity, String fieldName, String label) '''
        {% trans %}«label.formatForDisplayCapital»{% endtrans %}
    '''

    def private displayEntry(Object it, Boolean useTarget) '''
        «val cssClass = entryContainerCssClass»
        <td headers="h«markupIdCode(useTarget)»" class="text-«alignment»«IF !cssClass.empty» «cssClass»«ENDIF»">
            «displayEntryInner(useTarget)»
        </td>
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

    def private dispatch displayEntryInner(Field it, Boolean useTarget) '''
        «IF entity.hasDetailAction && #['name', 'title'].contains(name)»
            <a href="{{ path('«application.appName.formatForDB»_«entity.name.formatForDB»_detail'«entity.routeParams(entity.name.formatForCode, true)») }}" title="{{ 'View detail page'|trans({}, 'messages')|e('html_attr') }}">«displayField»</a>
        «ELSE»
            «displayField»
        «ENDIF»
    '''

    def private displayField(Field it) {
        '''{{ «entity.name.formatForCode».«name.formatForCode» }}'''
    }

    def private dispatch displayEntryInner(Relationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val mainEntity = (if (!useTarget) target else source)»
        «val linkEntity = (if (useTarget) target else source)»
        «var relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        {% if «relObjName»|default %}
            «IF linkEntity.hasDetailAction»
                <a href="{{ path('«linkEntity.application.appName.formatForDB»_«linkEntity.name.formatForDB»_detail'«linkEntity.routeParams(relObjName, true)») }}">{% apply spaceless %}
            «ENDIF»
              {{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}
            «IF linkEntity.hasDetailAction»
                {% endapply %}</a>
                <a id="«linkEntity.name.formatForCode»Item{{ «mainEntity.name.formatForCode».getKey() }}_rel_{{ «relObjName».getKey() }}Display" href="{{ path('«application.appName.formatForDB»_«linkEntity.name.formatForDB»_detail', {«IF linkEntity.hasSluggableFields»«linkEntity.appendSlug(relObjName, true)»«ELSE»«linkEntity.routePkParams(relObjName, true)»«ENDIF», raw: 1}) }}" title="{{ 'Open quick view window'|trans({}, 'messages')|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ «relObjName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"><i class="fas fa-id-card"></i></a>
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
    def private dispatch markupIdCode(Field it, Boolean useTarget) {
        name.formatForCodeCapital
    }
    def private dispatch markupIdCode(Relationship it, Boolean useTarget) {
        getRelationAliasName(useTarget).toFirstUpper
    }

    def private alignment(Object it) {
        switch it {
            BooleanField: 'center'
            NumberField: 'right'
            default: 'left'
        }
    }

    def private itemActions(Entity it) '''
        <td id="«new MenuViews().itemActionContainerViewId(it)»" headers="hItemActions" class="actions">
            «new MenuViews().itemActions(it, 'index')»
        </td>
    '''
}
