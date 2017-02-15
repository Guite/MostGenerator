package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class History {

    extension FormattingExtensions = new FormattingExtensions
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
        {% block title __f('«name.formatForDisplay» change history for %entityTitle%', { '%entityTitle%': «name.formatForCode».getTitleFromDisplayPattern() }) %}
        {% block admin_page_icon 'history' %}
        {% block content %}
            {{ block('page_nav_links') }}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-history">
                <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-condensed{% endif %}">
                    <colgroup>
                        <col id="cVersion" />
                        <col id="cDate" />
                        <col id="cUser" />
                        <col id="cAction" />
                        <col id="cChanges" />
                        <col id="cActions" />
                    </colgroup>
                    <thead>
                        <th id="hVersion" scope="col" class="z-order-unsorted z-w02">{{ __('Version') }}</th>
                        <th id="hDate" scope="col" class="z-order-unsorted">{{ __('Date') }}</th>
                        <th id="hUser" scope="col" class="z-order-unsorted">{{ __('User') }}</th>
                        <th id="hAction" scope="col" class="z-order-unsorted">{{ __('Action') }}</th>
                        <th id="hChanges" scope="col" class="z-order-unsorted">{{ __('Changes') }}</th>
                        <th id="hActions" scope="col" class="z-order-unsorted">{{ __('Actions') }}</th>
                    </thead>
                    <tbody>
                        {% for logEntry in logEntries %}
                            <tr>
                                <td headers="hVersion" class="text-center">{{ logEntry.version }}</td>
                                <td headers="hDate">{{ logEntry.logged_at|localizeddate('medium', 'medium') }}</td>
                                <td headers="hUser">{{ logEntry.username|profileLinkByUserName() }}</td>
                                <td headers="hAction">
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
                                                    <li>{{ __f('%field% set to %value%', { '%field%': field, '%value%': value }) }}</li>
                                                {% endfor %}
                                            </ul>
                                        </div>
                                    {% else %}
                                        {{ __('None') }}
                                    {% endif %}
                                </td>
                                <td headers="hActions" class="actions nowrap">
                                    TODO
                                    {#
                                    {% set linkTitle = __f('Preview version %version%', { '%version%': logEntry.version }) %}
                                    <a href="#" title="{{ linkTitle|e('html_attr') }}" class="fa fa-search-plus">{{ linkTitle }}</a>

                                    {% set linkTitle = __f('Revert to version %version%', { '%version%': logEntry.version }) %}
                                    <a href="#" title="{{ linkTitle|e('html_attr') }}" class="fa fa-history">{{ linkTitle }}</a>
                                    #}
                                </td>
                            </tr>
                        {% endfor %}
                    </tbody>
                </table>
            </div>
            {{ block('page_nav_links') }}
        {% endblock %}
        {% block page_nav_links %}
            <p>
                {% set linkTitle = __('Back to overview') %}
                <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-reply">{{ linkTitle }}</a>

                {% set linkTitle = __('Back to detail view') %}
                <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams(name.formatForCode, true)») }}" title="{{ linkTitle|e('html_attr') }}" class="fa fa-eye">{{ linkTitle }}</a>
            </p>
        {% endblock %}
    '''
}
