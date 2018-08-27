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
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» change history view #}
            {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» change history view #}
            {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        «ENDIF»
        {% block title isDiffView == true ? __f('Compare versions of %entityTitle%', {'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) : __f('«name.formatForDisplayCapital» change history for %entityTitle%', {'%entityTitle%': «name.formatForCode»|«application.appName.formatForDB»_formattedTitle}) %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon isDiffView == true ? 'arrows-h' : 'history' %}
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
            <form action="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'loggablehistory', {«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»: «name.formatForCode».get«IF hasSluggableFields && slugUnique»Slug«ELSE»Key«ENDIF»()}) }}" method="get" class="form-horizontal" role="form">
                <div class="table-responsive">
                    «historyTable»
                </div>
                <p>
                    <button id="compareButton" type="submit" value="compare" class="btn btn-primary" disabled="disabled"><i class="fa fa-arrows-h"></i> {{ __('Compare selected versions') }}</button>
                </p>
            </form>
        {% endblock %}
        {% block diff_view %}
            <div class="table-responsive">
                <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-condensed{% endif %}">
                    <colgroup>
                        <col id="cFieldName" />
                        <col id="cMinVersion" />
                        <col id="cMaxVersion" />
                    </colgroup>
                    <thead>
                        <tr>
                            <th id="hFieldName" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Field name') }}</th>
                            <th id="hMinVersion" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">{{ __f('Version %version%', {'%version%': minVersion}) }}</th>
                            <th id="hMaxVersion" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">{{ __f('Version %version%', {'%version%': maxVersion}) }}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {% for fieldName, values in diffValues %}
                            <tr>
                                <th headers="hFieldName" id="h{{ fieldName|replace({' ': '', '"':''}) }}" scope="row">{{ fieldName|humanize }}</th>
                                <td headers="hMinVersion h{{ fieldName|replace({' ': '', '"':''}) }}"{% if values.changed %} class="diff-old"{% endif %}>{{ values.old is «app.appName.toLowerCase»_instanceOf('DateTimeInterface') ? values.old|localizeddate('long', 'medium') : values.old }}</td>
                                <td headers="hMaxVersion h{{ fieldName|replace({' ': '', '"':''}) }}"{% if values.changed %} class="diff-new"{% endif %}>{{ values.new is «app.appName.toLowerCase»_instanceOf('DateTimeInterface') ? values.new|localizeddate('long', 'medium') : values.new }}</td>
                            </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
        {% endblock %}
    '''

    def private historyTable(Entity it) '''
        «val app = application»
        <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-condensed{% endif %}">
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
                    <th id="hSelect" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted z-w02">{{ __('Select') }}</th>
                    <th id="hVersion" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted z-w02">{{ __('Version') }}</th>
                    <th id="hDate" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Date') }}</th>
                    <th id="hUser" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('User') }}</th>
                    <th id="hOperation" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Operation') }}</th>
                    <th id="hChanges" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Changes') }}</th>
                    <th id="hActions" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Actions') }}</th>
                </tr>
            </thead>
            <tbody>
                {% for logEntry in logEntries %}
                    <tr>
                        <td headers="hSelect" class="text-center">
                            <input type="checkbox" name="versions[]" value="{{ logEntry.version }}" class="«application.vendorAndName.toLowerCase»-toggle-checkbox" />
                        </td>
                        <td headers="hVersion" class="text-center">{{ logEntry.version }}{% if loop.first %} ({{ __('latest') }}){% endif %}</td>
                        <td headers="hDate">{{ logEntry.loggedAt|localizeddate('long', 'medium') }}</td>
                        <td headers="hUser">{{ userAvatar(logEntry.username, {size: 20, rating: 'g'}) }} {{ logEntry.username|profileLinkByUserName() }}</td>
                        <td headers="hOperation">
                            {% if logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_CREATE') %}
                                {{ __('Created') }}
                            {% elseif logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_UPDATE') %}
                                {{ __('Updated') }}
                            {% elseif logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_REMOVE') %}
                                {{ __('Removed') }}
                            {% endif %}
                        </td>
                        <td headers="hChanges">
                            {% if logEntry.data is not empty %}
                                <a role="button" data-toggle="collapse" href="#changes{{ logEntry.version }}" aria-expanded="false" aria-controls="changes{{ logEntry.version }}">
                                    {{ _fn('One field updated', '%amount% fields updated', logEntry.data|length, {'%amount%': logEntry.data|length}) }}
                                </a>
                                <div id="changes{{ logEntry.version }}" class="collapse">
                                    <ul>
                                        {% for field, value in logEntry.data %}
                                            {% if value is iterable %}
                                                {% if value|length > 0 %}
                                                    <li>{{ __f('%field% set to:', {'%field%': field}) }}
                                                        <ul>
                                                            {% for singleValue in value %}
                                                                <li class="italic">{% if singleValue is iterable %}Array{% else %}{{ singleValue }}{% endif %}</li>
                                                            {% endfor %}
                                                        </ul>
                                                    </li>
                                                {% else %}
                                                    <li>{{ __f('%field% set to <em>%value%</em>', {'%field%': field, '%value%': __('an empty collection')})|raw }}</li>
                                                {% endif %}
                                            {% else %}
                                                <li>{{ __f('%field% set to <em>%value%</em>', {'%field%': field, '%value%': value is «app.appName.toLowerCase»_instanceOf('DateTimeInterface') ? value|localizeddate('long', 'medium') : value|default(__('an empty value'))})|raw }}</li>
                                            {% endif %}
                                        {% endfor %}
                                    </ul>
                                </div>
                            {% else %}
                                {{ __('None') }}
                            {% endif %}
                        </td>
                        <td headers="hActions" class="actions nowrap">
                            «IF hasDisplayAction»
                                {% set linkTitle = __f('Preview version %version%', {'%version%': logEntry.version}) %}
                                <a id="«name.formatForCode»Item{{ «name.formatForCode».getKey() }}Display{{ logEntry.version }}" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display', {«IF !hasSluggableFields || !slugUnique»«routePkParams(name.formatForCode, true)»«ENDIF»«appendSlug(name.formatForCode, true)», version: logEntry.version, raw: 1}) }}" title="{{ linkTitle|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ «name.formatForCode»|«application.appName.formatForDB»_formattedTitle|e('html_attr') ~ ' ' ~ __('version') ~ ' ' ~ logEntry.version }}"><i class="fa fa-id-card-o"></i></a>
                            «ENDIF»
                            {% if not loop.first %}
                                {% set linkTitle = __f('Revert to version %version%', { '%version%': logEntry.version }) %}
                                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'loggablehistory', {«IF !hasSluggableFields || !slugUnique»«routePkParams(name.formatForCode, true)»«ENDIF»«appendSlug(name.formatForCode, true)», revert: logEntry.version}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-history"></i></a>
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
                    {% set linkTitle = __('Back to history') %}
                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'loggablehistory', {«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»: «name.formatForCode».get«IF hasSluggableFields && slugUnique»Slug«ELSE»Key«ENDIF»()}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-history"></i> {{ linkTitle }}</a>
                {% else %}
                    «IF hasViewAction»
                        {% set linkTitle = __('«nameMultiple.formatForDisplayCapital» list') %}
                        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-reply"></i> {{ linkTitle }}</a>
                    «ENDIF»
                    «IF hasDisplayAction»
                        {% set linkTitle = __('Back to detail view') %}
                        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams(name.formatForCode, true)») }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-eye"></i> {{ linkTitle }}</a>
                    «ENDIF»
                {% endif %}
            </p>
        «ENDIF»
    '''
}
