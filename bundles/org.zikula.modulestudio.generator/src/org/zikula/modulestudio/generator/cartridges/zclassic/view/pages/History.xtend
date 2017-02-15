package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class History {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        val templateFilePath = templateFile('history')
        if (!application.shouldBeSkipped(templateFilePath)) {
            println('Generating history templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, historyView(appName))
        }
    }

    def private historyView(Entity it, String appName) '''
        «val app = application»
        {# purpose of this template: «nameMultiple.formatForDisplay» change history view #}
        {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        {% block title __f('«name.formatForDisplayCapital» change history for %entityTitle%', { '%entityTitle%': «name.formatForCode».getTitleFromDisplayPattern() }) %}
        {% block admin_page_icon 'history' %}
        {% block content %}
            {{ block('page_nav_links') }}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-history">
                <div class="table-responsive">
                <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-condensed{% endif %}">
                    <colgroup>
                        <col id="cVersion" />
                        <col id="cDate" />
                        <col id="cUser" />
                        <col id="cOperation" />
                        <col id="cChanges" />
                        <col id="cActions" />
                    </colgroup>
                    <thead>
                        <th id="hVersion" scope="col" class="z-order-unsorted z-w02">{{ __('Version') }}</th>
                        <th id="hDate" scope="col" class="z-order-unsorted">{{ __('Date') }}</th>
                        <th id="hUser" scope="col" class="z-order-unsorted">{{ __('User') }}</th>
                        <th id="hOperation" scope="col" class="z-order-unsorted">{{ __('Operation') }}</th>
                        <th id="hChanges" scope="col" class="z-order-unsorted">{{ __('Changes') }}</th>
                        <th id="hActions" scope="col" class="z-order-unsorted">{{ __('Actions') }}</th>
                    </thead>
                    <tbody>
                        {% for logEntry in logEntries %}
                            <tr>
                                <td headers="hVersion" class="text-center">{{ logEntry.version }}{% if loop.first %} ({{ __('latest') }}){% endif %}</td>
                                <td headers="hDate">{{ logEntry.loggedAt|localizeddate('medium', 'medium') }}</td>
                                <td headers="hUser">{{ logEntry.username|profileLinkByUserName() }}</td>
                                <td headers="hOperation">
                                    {% if logEntry.action == 'create' %}
                                        {{ __('Create') }}
                                    {% elseif logEntry.action == 'update' %}
                                        {{ __('Update') }}
                                    {% elseif logEntry.action == 'remove' %}
                                        {{ __('Remove') }}
                                    {% endif %}
                                </td>
                                <td headers="hChanges">
                                    {% if logEntry.data is not empty %}
                                        <a role="button" data-toggle="collapse" href="#changes{{ logEntry.version }}" aria-expanded="false" aria-controls="changes{{ logEntry.version }}">
                                            {{ _fn('One field updated', '%amount% fields updated', logEntry.data|length, { '%amount%': logEntry.data|length }) }}
                                        </a>
                                        <div id="changes{{ logEntry.version }}" class="collapse">
                                            <ul>
                                                {% for field, value in logEntry.data %}
                                                    {% if value is iterable %}
                                                        {% if value|length > 0 %}
                                                            <li>{{ __f('%field% set to:', { '%field%': field }) }}
                                                                <ul>
                                                                    {% for singleValue in value %}
                                                                        <li class="italic">{{ singleValue }}</li>
                                                                    {% endfor %}
                                                                </ul>
                                                            </li>
                                                        {% else %}
                                                            <li>{{ __f('%field% set to <em>%value%</em>', { '%field%': field, '%value%': __('an empty collection') })|raw }}</li>
                                                        {% endif %}
                                                    {% else %}
                                                        <li>{{ __f('%field% set to <em>%value%</em>', { '%field%': field, '%value%': value|default(__('an empty value')) })|raw }}</li>
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
                                        {% set linkTitle = __f('Preview version %version%', { '%version%': logEntry.version }) %}
                                        <a id="«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{ «name.formatForCode».«pkField.name.formatForCode» }}«ENDFOR»Display{{ logEntry.version }}" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display', { «routePkParams(name.formatForCode, true)»«appendSlug('item', true)», 'version': logEntry.version, 'raw': 1 }) }}" title="{{ linkTitle|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ «name.formatForCode».getTitleFromDisplayPattern()|e('html_attr') ~ ' ' ~ __('version') ~ ' ' ~ logEntry.version }}"><span class="fa fa-id-card-o"></span> {{ linkTitle }}</a>
                                    «ENDIF»
                                    TODO
                                    {#
                                    {% set linkTitle = __f('Revert to version %version%', { '%version%': logEntry.version }) %}
                                    <a href="#" title="{{ linkTitle|e('html_attr') }}" class="fa fa-history">{{ linkTitle }}</a>
                                    #}
                                </td>
                            </tr>
                        {% endfor %}
                    </tbody>
                </table>
                </div>
            </div>
            {{ block('page_nav_links') }}
        {% endblock %}
        {% block page_nav_links %}
            «IF hasViewAction || hasDisplayAction»
                <p>
                    «IF hasViewAction»
                        {% set linkTitle = __('Back to overview') %}
                        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-reply">{{ linkTitle }}</a>
                    «ENDIF»
                    «IF hasDisplayAction»
                        {% set linkTitle = __('Back to detail view') %}
                        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams(name.formatForCode, true)») }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-eye">{{ linkTitle }}</a>
                    «ENDIF»
                </p>
            «ENDIF»
        {% endblock %}
    '''
}
