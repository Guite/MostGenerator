package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class History {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating history templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFile('history')
        fsa.generateFile(templateFilePath, historyView(false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/history')
            fsa.generateFile(templateFilePath, historyView(true))
        }
    }

    def private historyView(Entity it, Boolean isAdmin) '''
        «val app = application»
        «IF app.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» change history view #}
            {% extends «IF isAdmin»'@«app.appName»/adminBase.html.twig'«ELSE»'@«app.appName»/base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» change history view #}
            {% extends routeArea == 'admin' ? '@«app.appName»/adminBase.html.twig' : '@«app.appName»/base.html.twig' %}
        «ENDIF»
        «IF !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% macro outputSimpleValue(input) %}
            {{ input is «app.appName.toLowerCase»_instanceOf('DateTimeInterface') ? input|format_datetime('long', 'medium') : input|default('an empty value'|trans«IF !app.isSystemModule»({}, 'messages')«ENDIF») }}
        {% endmacro %}
        {% macro outputArray(input«IF hasTranslatableFields», keysAreLanguages«ENDIF») %}
            <ul>
                {% for key, value in input %}
                    <li><span class="font-weight-bold">{{ «IF hasTranslatableFields»keysAreLanguages ? key|language_name : «ENDIF»key|humanize }}:</span> {% if value is iterable %}{{ _self.outputArray(value«IF hasTranslatableFields», false«ENDIF») }}{% else %}<span class="font-italic">{{ value }}</span>{% endif %}</li>
                {% endfor %}
            </ul>
        {% endmacro %}
        {% block title isDiffView == true ? 'Compare versions of %entityTitle%'|trans({'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}«IF !app.isSystemModule», 'messages'«ENDIF») : '«name.formatForDisplayCapital» change history for %entityTitle%'|trans({'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) %}
        «IF !app.separateAdminTemplates || isAdmin»
            {% block admin_page_icon isDiffView == true ? 'arrows-alt-h' : 'history' %}
        «ENDIF»
        {% block content %}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-history">
                {% if isDiffView != true %}
                    {{ pageAddAsset('javascript', zasset('@«app.appName»:js/«app.appName».VersionHistory.js')) }}
                {% endif %}
                {{ block('page_nav_links') }}
                {% if isDiffView == true %}
                    {{ block('diff_view') }}
                {% else %}
                    {{ block('history_table') }}
                {% endif %}
                {{ block('page_nav_links') }}
            </div>
        {% endblock %}
        {% block page_nav_links %}
            «pageNavLinks(app.appName)»
        {% endblock %}
        {% block history_table %}
            <form action="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'loggablehistory', {«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»: «name.formatForCode».get«IF hasSluggableFields && slugUnique»Slug«ELSE»Key«ENDIF»()}) }}" method="get">
                <div class="table-responsive">
                    «historyTable»
                </div>
                <p>
                    <button id="compareButton" type="submit" value="compare" class="btn btn-primary" disabled="disabled"><i class="fas fa-arrows-alt-h"></i> {% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Compare selected versions{% endtrans %}</button>
                </p>
            </form>
        {% endblock %}
        {% block diff_view %}
            <div class="table-responsive">
                <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-sm{% endif %}">
                    <colgroup>
                        <col id="cFieldName" />
                        <col id="cMinVersion" />
                        <col id="cMaxVersion" />
                    </colgroup>
                    <thead>
                        <tr>
                            <th id="hFieldName" scope="col" class="unsorted">{% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Field name{% endtrans %}</th>
                            <th id="hMinVersion" scope="col" class="unsorted">{% trans with {'%version%': minVersion}«IF !app.isSystemModule» from 'messages'«ENDIF» %}Version %version%{% endtrans %}</th>
                            <th id="hMaxVersion" scope="col" class="unsorted">{% trans with {'%version%': maxVersion}«IF !app.isSystemModule» from 'messages'«ENDIF» %}Version %version%{% endtrans %}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for fieldName, values in diffValues %}
                            <tr>
                                <th id="h{{ fieldName|e('html_attr') }}" headers="hFieldName" scope="row">
                                    {{ fieldName|humanize }}
                                </th>
                                <td headers="hMinVersion h{{ fieldName|e('html_attr') }}"{% if values.changed %} class="diff-old"{% endif %}>
                                    {% if values.old is iterable %}
                                        {% if values.old|length > 0 %}
                                            {% if fieldName in ['createdBy', 'updatedBy'] and values.old.uid is defined %}
                                                {{ userAvatar(values.old.uid, {rating: 'g'}) }} {{ values.old.uid|profileLinkByUserId() }}
                                            {% else %}
                                                {{ _self.outputArray(values.old«IF hasTranslatableFields», (fieldName == 'translationData')«ENDIF») }}
                                            {% endif %}
                                        {% else %}
                                            {% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}an empty collection{% endtrans %}
                                        {% endif %}
                                    {% else %}
                                        {{ _self.outputSimpleValue(values.old) }}
                                    {% endif %}
                                </td>
                                <td headers="hMaxVersion h{{ fieldName|e('html_attr') }}"{% if values.changed %} class="diff-new"{% endif %}>
                                    {% if values.new is iterable %}
                                        {% if values.new|length > 0 %}
                                            {% if fieldName in ['createdBy', 'updatedBy'] and values.new.uid is defined %}
                                                {{ userAvatar(values.new.uid, {rating: 'g'}) }} {{ values.new.uid|profileLinkByUserId() }}
                                            {% else %}
                                                {{ _self.outputArray(values.new«IF hasTranslatableFields», (fieldName == 'translationData')«ENDIF») }}
                                            {% endif %}
                                        {% else %}
                                            {% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}an empty collection{% endtrans %}
                                        {% endif %}
                                    {% else %}
                                        {{ _self.outputSimpleValue(values.new) }}
                                    {% endif %}
                                </td>
                            </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
        {% endblock %}
    '''

    def private historyTable(Entity it) '''
        «val app = application»
        <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-sm{% endif %}">
            <colgroup>
                <col id="cSelect" />
                <col id="cVersion" />
                <col id="cDate" />
                <col id="cUser" />
                <col id="cOperation" />
                <col id="cChanges" />
                <col id="cActions" />
            </colgroup>
            <thead>
                <tr>
                    <th id="hSelect" scope="col" class="unsorted">{% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Select{% endtrans %}</th>
                    <th id="hVersion" scope="col" class="unsorted">{% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Version{% endtrans %}</th>
                    <th id="hDate" scope="col" class="unsorted">{% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Date{% endtrans %}</th>
                    <th id="hUser" scope="col" class="unsorted">{% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}User{% endtrans %}</th>
                    <th id="hOperation" scope="col" class="unsorted" colspan="2">{% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Operation{% endtrans %}</th>
                    <th id="hChanges" scope="col" class="unsorted">{% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Changes{% endtrans %}</th>
                    <th id="hActions" scope="col" class="unsorted">{% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Actions{% endtrans %}</th>
                </tr>
            </thead>
            <tbody>
                {% for logEntry in logEntries %}
                    <tr>
                        <td headers="hSelect hVersion{{ logEntry.version|e('html_attr') }}" class="text-center">
                            <input type="checkbox" name="versions[]" value="{{ logEntry.version }}" class="«app.vendorAndName.toLowerCase»-toggle-checkbox" />
                        </td>
                        <th id="hVersion{{ logEntry.version|e('html_attr') }}" headers="hVersion" scope="row" class="text-center">{{ logEntry.version }}{% if loop.first %} ({% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}latest{% endtrans %}){% endif %}</td>
                        <td headers="hDate hVersion{{ logEntry.version|e('html_attr') }}">
                            {{ logEntry.loggedAt|format_datetime('long', 'medium') }}
                        </td>
                        <td headers="hUser hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.username %}
                                {{ userAvatar(logEntry.username, {rating: 'g'}) }} {{ logEntry.username|profileLinkByUserName() }}
                            {% endif %}
                        </td>
                        <td headers="hOperation hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_CREATE') %}
                                {% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Created{% endtrans %}
                            {% elseif logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_UPDATE') %}
                                {% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Updated{% endtrans %}
                            {% elseif logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_REMOVE') %}
                                {% trans«IF !app.isSystemModule» from 'messages'«ENDIF» %}Removed{% endtrans %}
                            {% endif %}
                        </td>
                        <td headers="hOperation hVersion{{ logEntry.version|e('html_attr') }}">
                            {{ logEntry|«app.appName.formatForDB»_logDescription }}
                        </td>
                        <td headers="hChanges hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.data is not empty %}
                                <a role="button" data-toggle="collapse" href="#changes{{ logEntry.version }}" aria-expanded="false" aria-controls="changes{{ logEntry.version }}">
                                    {{ '{0} No fields updated|{1} One field updated|]1,Inf[ %count% fields updated'|trans({'%count%': logEntry.data|length}«IF !app.isSystemModule», 'messages'«ENDIF») }}
                                </a>
                                <div id="changes{{ logEntry.version }}" class="collapse">
                                    <ul>
                                        {% for field, value in logEntry.data %}
                                            {% if value is iterable %}
                                                {% if value|length > 0 %}
                                                    <li>
                                                    {% if field in ['createdBy', 'updatedBy'] and value.uid is defined %}
                                                        {{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': userAvatar(value.uid, {rating: 'g'}) ~ ' ' ~ value.uid|profileLinkByUserId()}«IF !app.isSystemModule», 'messages'«ENDIF»)|raw }}
                                                    {% else %}
                                                        {{ '%field% set to:'|trans({'%field%': field|humanize}«IF !app.isSystemModule», 'messages'«ENDIF») }}
                                                        {{ _self.outputArray(value«IF hasTranslatableFields», (field == 'translationData')«ENDIF») }}
                                                    {% endif %}
                                                    </li>
                                                {% else %}
                                                    <li>{{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': 'an empty collection'|trans«IF !app.isSystemModule»({}, 'messages')«ENDIF»}«IF !app.isSystemModule», 'messages'«ENDIF»)|raw }}</li>
                                                {% endif %}
                                            {% else %}
                                                <li>{{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': _self.outputSimpleValue(value)}«IF !app.isSystemModule», 'messages'«ENDIF»)|raw }}</li>
                                            {% endif %}
                                        {% endfor %}
                                    </ul>
                                </div>
                            {% else %}
                                {% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}None{% endtrans %}
                            {% endif %}
                        </td>
                        <td headers="hActions hVersion{{ logEntry.version|e('html_attr') }}" class="actions">
                            «IF hasDisplayAction»
                                {% set linkTitle = 'Preview version %version%'|trans({'%version%': logEntry.version}«IF !app.isSystemModule», 'messages'«ENDIF») %}
                                <a id="«name.formatForCode»Item{{ «name.formatForCode».getKey() }}Display{{ logEntry.version }}" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display', {«IF !hasSluggableFields || !slugUnique»«routePkParams(name.formatForCode, true)»«ENDIF»«appendSlug(name.formatForCode, true)», version: logEntry.version, raw: 1}) }}" title="{{ linkTitle|e('html_attr') }}" class="«app.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle|e('html_attr') ~ ' ' ~ 'version'|trans«IF !app.isSystemModule»({}, 'messages')«ENDIF» ~ ' ' ~ logEntry.version }}"><i class="fas fa-id-card"></i></a>
                            «ENDIF»
                            {% if not loop.first %}
                                {% set linkTitle = 'Revert to version %version%'|trans({'%version%': logEntry.version}«IF !app.isSystemModule», 'messages'«ENDIF») %}
                                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'loggablehistory', {«IF !hasSluggableFields || !slugUnique»«routePkParams(name.formatForCode, true)»«ENDIF»«appendSlug(name.formatForCode, true)», revert: logEntry.version}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-history"></i></a>
                            {% endif %}
                        </td>
                    </tr>
                {% endfor %}
            </tbody>
        </table>
    '''

    def private pageNavLinks(Entity it, String appName) '''
        «IF hasViewAction || hasDisplayAction»
            <p>
                {% if isDiffView == true %}
                    {% set linkTitle = 'Back to history'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF» %}
                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'loggablehistory', {«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»: «name.formatForCode».get«IF hasSluggableFields && slugUnique»Slug«ELSE»Key«ENDIF»()}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-history"></i> {{ linkTitle }}</a>
                {% else %}
                    «IF hasViewAction»
                        {% set linkTitle = '«nameMultiple.formatForDisplayCapital» list'|trans %}
                        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-reply"></i> {{ linkTitle }}</a>
                    «ENDIF»
                {% endif %}
                «IF hasDisplayAction»
                    {% set linkTitle = 'Back to detail view'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF» %}
                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams(name.formatForCode, true)») }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-eye"></i> {{ linkTitle }}</a>
                «ENDIF»
            </p>
        «ENDIF»
    '''
}
