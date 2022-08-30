package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.view

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewDeleted {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating deleted view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFile('indexDeleted')
        fsa.generateFile(templateFilePath, indexViewDeleted)
    }

    def private indexViewDeleted(Entity it) '''
        {# purpose of this template: index view of deleted «nameMultiple.formatForDisplay» #}
        {% extends routeArea == 'admin' ? '@«application.vendorAndName»/adminBase.html.twig' : '@«application.vendorAndName»/base.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% block title 'Deleted «nameMultiple.formatForDisplay»'|trans %}
        {% block admin_page_icon 'trash-alt' %}
        {% block content %}
            <div class="«application.appName.toLowerCase»-«name.formatForDB» «application.appName.toLowerCase»-indexdeleted">
                {{ block('page_nav_links') }}«/*new ViewPagesHelper().commonHeader(it)*/»
                «IF !hasDetailAction»
                    <p class="alert alert-info">{% trans %}Because there exists no display action for «nameMultiple.formatForDisplay» it is not possible to preview deleted items.{% endtrans %}</p>
                «ENDIF»
                «historyTable»
                {{ block('page_nav_links') }}
            </div>
        {% endblock %}
        {% block page_nav_links %}
            <p>
                {% set linkTitle = 'Back to overview'|trans({}, 'messages') %}
                <a href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'index') }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-reply"></i> {{ linkTitle }}</a>
            </p>
        {% endblock %}
    '''

    def private historyTable(Entity it) '''
        <div class="table-responsive">
            <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-sm{% endif %}">
                <colgroup>
                    <col id="cId" />
                    <col id="cDate" />
                    <col id="cUser" />
                    <col id="cActions" />
                </colgroup>
                <thead>
                    <tr>
                        <th id="hId" scope="col" class="unsorted">{% trans from 'messages' %}ID{% endtrans %}</th>
                        <th id="hTitle" scope="col" class="unsorted">{% trans from 'messages' %}Title{% endtrans %}</th>
                        <th id="hDate" scope="col" class="unsorted">{% trans from 'messages' %}Date{% endtrans %}</th>
                        <th id="hUser" scope="col" class="unsorted">{% trans from 'messages' %}User{% endtrans %}</th>
                        <th id="hActions" scope="col" class="unsorted">{% trans from 'messages' %}Action{% endtrans %}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for logEntry in deletedEntities %}
                        <tr>
                            <th id="hId{{ logEntry.objectId|e('html_attr') }}" headers="hId" scope="row" class="text-center">{{ logEntry.objectId }}</td>
                            <td headers="hTitle hId{{ logEntry.objectId|e('html_attr') }}">
                                {{ logEntry|«application.appName.formatForDB»_logDescription }}
                            </td>
                            <td headers="hDate hId{{ logEntry.objectId|e('html_attr') }}">{{ logEntry.loggedAt|format_datetime('long', 'medium') }}</td>
                            <td headers="hUser hId{{ logEntry.objectId|e('html_attr') }}">{{ userAvatar(logEntry.username, {size: 20, rating: 'g'}) }} {{ logEntry.username|profileLinkByUserName() }}</td>
                            <td headers="hActions hId{{ logEntry.objectId|e('html_attr') }}" class="actions">
                                «IF hasDetailAction»
                                    {% set linkTitle = 'Preview «name.formatForDisplay» %id%'|trans({'%id%': logEntry.objectId}) %}
                                    <a id="«name.formatForCode»ItemDisplay{{ logEntry.objectId }}" href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'undelete', {«getPrimaryKey.name.formatForCode»: logEntry.objectId, preview: 1, raw: 1}) }}" title="{{ linkTitle|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ '«name.formatForDisplayCapital» %id%'|trans({'%id%': logEntry.objectId})|e('html_attr') }}"><i class="fas fa-id-card"></i></a>
                                «ENDIF»
                                {% set linkTitle = 'Undelete «name.formatForDisplay» %id%'|trans({'%id%': logEntry.objectId}) %}
                                <a href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'undelete', {«getPrimaryKey.name.formatForCode»: logEntry.objectId}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-history"></i></a>
                            </td>
                        </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    '''
}
