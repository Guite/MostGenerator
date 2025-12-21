package org.zikula.modulestudio.generator.cartridges.symfony.view.pages

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
        fsa.generateFile(templateFilePath, historyView)
    }

    def private historyView(Entity it) '''
        «val app = application»
        {# purpose of this template: «nameMultiple.formatForDisplay» change history view #}
        {% extends routeArea == 'admin' ? '@«app.vendorAndName»/adminBase.html.twig' : '@«app.vendorAndName»/base.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% macro outputSimpleValue(input) %}
            {{ input is «app.appName.toLowerCase»_instanceOf('DateTimeInterface') ? input|format_datetime('long', 'medium') : input|default('an empty value'|trans({}, 'messages')) }}
        {% endmacro %}
        {% macro outputArray(input«IF hasTranslatableFields», keysAreLanguages«ENDIF») %}
            <ul>
                {% for key, value in input %}
                    <li><span class="font-weight-bold">{{ «IF hasTranslatableFields»keysAreLanguages ? key|language_name : «ENDIF»key|humanize }}:</span> {% if value is iterable %}{{ _self.outputArray(value«IF hasTranslatableFields», false«ENDIF») }}{% else %}<span class="font-italic">{{ value }}</span>{% endif %}</li>
                {% endfor %}
            </ul>
        {% endmacro %}
        {% block title isDiffView == true ? 'Compare versions of %entityTitle%'|trans({'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}, 'messages') : '«name.formatForDisplayCapital» change history for %entityTitle%'|trans({'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) %}
        {% block admin_page_icon isDiffView == true ? 'arrows-alt-h' : 'history' %}
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
            <form action="{{ path('«app.appName.formatForDB»_«name.formatForDB»_loggablehistory', {«IF hasSluggableFields»slug«ELSE»id«ENDIF»: «name.formatForCode».get«IF hasSluggableFields»Slug«ELSE»Key«ENDIF»()}) }}" method="get">
                <div class="table-responsive">
                    «historyTable»
                </div>
                <p>
                    <button id="compareButton" type="submit" value="compare" class="btn btn-primary" disabled="disabled"><i class="fas fa-arrows-alt-h"></i> {% trans from 'messages' %}Compare selected versions{% endtrans %}</button>
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
                            <th id="hFieldName" scope="col" class="unsorted">{% trans from 'messages' %}Field name{% endtrans %}</th>
                            <th id="hMinVersion" scope="col" class="unsorted">{% trans with {'%version%': minVersion} from 'messages' %}Version %version%{% endtrans %}</th>
                            <th id="hMaxVersion" scope="col" class="unsorted">{% trans with {'%version%': maxVersion} from 'messages' %}Version %version%{% endtrans %}</th>
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
                                            {% if fieldName in ['createdBy', 'updatedBy'] and values.old.id is defined %}
                                                {{ userAvatar(values.old.id, {rating: 'g'}) }} {{ values.old.id|profileLinkByUserId() }}
                                            {% else %}
                                                {{ _self.outputArray(values.old«IF hasTranslatableFields», (fieldName == 'translationData')«ENDIF») }}
                                            {% endif %}
                                        {% else %}
                                            {% trans from 'messages' %}an empty collection{% endtrans %}
                                        {% endif %}
                                    {% else %}
                                        {{ _self.outputSimpleValue(values.old) }}
                                    {% endif %}
                                </td>
                                <td headers="hMaxVersion h{{ fieldName|e('html_attr') }}"{% if values.changed %} class="diff-new"{% endif %}>
                                    {% if values.new is iterable %}
                                        {% if values.new|length > 0 %}
                                            {% if fieldName in ['createdBy', 'updatedBy'] and values.new.id is defined %}
                                                {{ userAvatar(values.new.id, {rating: 'g'}) }} {{ values.new.id|profileLinkByUserId() }}
                                            {% else %}
                                                {{ _self.outputArray(values.new«IF hasTranslatableFields», (fieldName == 'translationData')«ENDIF») }}
                                            {% endif %}
                                        {% else %}
                                            {% trans from 'messages' %}an empty collection{% endtrans %}
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
                    <th id="hSelect" scope="col" class="unsorted">{% trans from 'messages' %}Select{% endtrans %}</th>
                    <th id="hVersion" scope="col" class="unsorted">{% trans from 'messages' %}Version{% endtrans %}</th>
                    <th id="hDate" scope="col" class="unsorted">{% trans from 'messages' %}Date{% endtrans %}</th>
                    <th id="hUser" scope="col" class="unsorted">{% trans from 'messages' %}User{% endtrans %}</th>
                    <th id="hOperation" scope="col" class="unsorted" colspan="2">{% trans from 'messages' %}Operation{% endtrans %}</th>
                    <th id="hChanges" scope="col" class="unsorted">{% trans from 'messages' %}Changes{% endtrans %}</th>
                    <th id="hActions" scope="col" class="unsorted">{% trans from 'messages' %}Actions{% endtrans %}</th>
                </tr>
            </thead>
            <tbody>
                {% for logEntry in logEntries %}
                    <tr>
                        <td headers="hSelect hVersion{{ logEntry.version|e('html_attr') }}" class="text-center">
                            <input type="checkbox" name="versions[]" value="{{ logEntry.version }}" class="«app.vendorAndName.toLowerCase»-toggle-checkbox" />
                        </td>
                        <th id="hVersion{{ logEntry.version|e('html_attr') }}" headers="hVersion" scope="row" class="text-center">{{ logEntry.version }}{% if loop.first %} ({% trans from 'messages' %}latest{% endtrans %}){% endif %}</td>
                        <td headers="hDate hVersion{{ logEntry.version|e('html_attr') }}">
                            {{ logEntry.loggedAt|format_datetime('long', 'medium') }}
                        </td>
                        <td headers="hUser hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.username %}
                                {{ userAvatar(logEntry.username, {rating: 'g'}) }} {{ logEntry.username|profileLinkByUserId() }}
                            {% endif %}
                        </td>
                        <td headers="hOperation hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_CREATE') %}
                                {% trans from 'messages' %}Created{% endtrans %}
                            {% elseif logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_UPDATE') %}
                                {% trans from 'messages' %}Updated{% endtrans %}
                            {% elseif logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_REMOVE') %}
                                {% trans from 'messages' %}Removed{% endtrans %}
                            {% endif %}
                        </td>
                        <td headers="hOperation hVersion{{ logEntry.version|e('html_attr') }}">
                            {{ logEntry|«app.appName.formatForDB»_logDescription }}
                        </td>
                        <td headers="hChanges hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.data is not empty %}
                                <a role="button" data-toggle="collapse" href="#changes{{ logEntry.version }}" aria-expanded="false" aria-controls="changes{{ logEntry.version }}">
                                    {{ '{0} No fields updated|{1} One field updated|]1,Inf[ %count% fields updated'|trans({'%count%': logEntry.data|length}, 'messages') }}
                                </a>
                                <div id="changes{{ logEntry.version }}" class="collapse">
                                    <ul>
                                        {% for field, value in logEntry.data %}
                                            {% if value is iterable %}
                                                {% if value|length > 0 %}
                                                    <li>
                                                    {% if field in ['createdBy', 'updatedBy'] and value.id is defined %}
                                                        {{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': userAvatar(value.id, {rating: 'g'}) ~ ' ' ~ value.id|profileLinkByUserId()}, 'messages')|raw }}
                                                    {% else %}
                                                        {{ '%field% set to:'|trans({'%field%': field|humanize}, 'messages') }}
                                                        {{ _self.outputArray(value«IF hasTranslatableFields», (field == 'translationData')«ENDIF») }}
                                                    {% endif %}
                                                    </li>
                                                {% else %}
                                                    <li>{{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': 'an empty collection'|trans({}, 'messages')}, 'messages')|raw }}</li>
                                                {% endif %}
                                            {% else %}
                                                <li>{{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': _self.outputSimpleValue(value)}, 'messages')|raw }}</li>
                                            {% endif %}
                                        {% endfor %}
                                    </ul>
                                </div>
                            {% else %}
                                {% trans from 'messages' %}None{% endtrans %}
                            {% endif %}
                        </td>
                        <td headers="hActions hVersion{{ logEntry.version|e('html_attr') }}" class="actions">
                            «IF hasDetailAction»
                                {% set linkTitle = 'Preview version %version%'|trans({'%version%': logEntry.version}, 'messages') %}
                                <a id="«name.formatForCode»Item{{ «name.formatForCode».getKey() }}Display{{ logEntry.version }}" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_detail', {«IF hasSluggableFields»«appendSlug(name.formatForCode, true)»«ELSE»«routePkParams(name.formatForCode, true)»«ENDIF», version: logEntry.version, raw: 1}) }}" title="{{ linkTitle|e('html_attr') }}" class="«app.vendorAndName.toLowerCase»-inline-window d-none" data-modal-title="{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle|e('html_attr') ~ ' ' ~ 'version'|trans({}, 'messages') ~ ' ' ~ logEntry.version }}"><i class="fas fa-id-card"></i></a>
                            «ENDIF»
                            {% if not loop.first %}
                                {% set linkTitle = 'Revert to version %version%'|trans({'%version%': logEntry.version}, 'messages') %}
                                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_loggablehistory', {«IF hasSluggableFields»«appendSlug(name.formatForCode, true)»«ELSE»«routePkParams(name.formatForCode, true)»«ENDIF», revert: logEntry.version}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-history"></i></a>
                            {% endif %}
                        </td>
                    </tr>
                {% endfor %}
            </tbody>
        </table>
    '''

    def private pageNavLinks(Entity it, String appName) '''
        «IF hasIndexAction || hasDetailAction»
            <p>
                {% if isDiffView == true %}
                    {% set linkTitle = 'Back to history'|trans({}, 'messages') %}
                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_loggablehistory', {«IF hasSluggableFields»slug«ELSE»id«ENDIF»: «name.formatForCode».get«IF hasSluggableFields»Slug«ELSE»Key«ENDIF»()}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-history"></i> {{ linkTitle }}</a>
                {% else %}
                    «IF hasIndexAction»
                        {% set linkTitle = '«nameMultiple.formatForDisplayCapital» list'|trans %}
                        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_index') }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-reply"></i> {{ linkTitle }}</a>
                    «ENDIF»
                {% endif %}
                «IF hasDetailAction»
                    {% set linkTitle = 'Back to detail view'|trans({}, 'messages') %}
                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_detail'«routeParams(name.formatForCode, true)») }}" title="{{ linkTitle|e('html_attr') }}"><i class="fas fa-eye"></i> {{ linkTitle }}</a>
                «ENDIF»
            </p>
        «ENDIF»
    '''
}
