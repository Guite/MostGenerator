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

        var templateFilePath = templateFile('viewDeleted')
        fsa.generateFile(templateFilePath, viewViewDeleted(false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/viewDeleted')
            fsa.generateFile(templateFilePath, viewViewDeleted(true))
        }
    }

    def private viewViewDeleted(Entity it, Boolean isAdmin) '''
        «IF application.separateAdminTemplates»
            {# purpose of this template: «IF isAdmin»admin«ELSE»user«ENDIF» list view of deleted «nameMultiple.formatForDisplay» #}
            «IF application.targets('3.0')»
                {% extends «IF isAdmin»'@«application.appName»/adminBase.html.twig'«ELSE»'@«application.appName»/base.html.twig'«ENDIF» %}
            «ELSE»
                {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
            «ENDIF»
        «ELSE»
            {# purpose of this template: list view of deleted «nameMultiple.formatForDisplay» #}
            «IF application.targets('3.0')»
                {% extends routeArea == 'admin' ? '@«application.appName»/adminBase.html.twig' : '@«application.appName»/base.html.twig' %}
            «ELSE»
                {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
            «ENDIF»
        «ENDIF»
        {% block title __('Deleted «nameMultiple.formatForDisplay»') %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'trash-«IF application.targets('3.0')»alt«ELSE»o«ENDIF»' %}
        «ENDIF»
        {% block content %}
            <div class="«application.appName.toLowerCase»-«name.formatForDB» «application.appName.toLowerCase»-viewdeleted">
                {{ block('page_nav_links') }}«/*new ViewPagesHelper().commonHeader(it)*/»
                «IF !hasDisplayAction»
                    <p class="alert alert-info">{{ __('Because there exists no display action for «nameMultiple.formatForDisplay» it is not possible to preview deleted items.') }}</p>
                «ENDIF»
                «historyTable»
                {{ block('page_nav_links') }}
            </div>
        {% endblock %}
        {% block page_nav_links %}
            <p>
                {% set linkTitle = __('Back to overview') %}
                <a href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-reply"></i> {{ linkTitle }}</a>
            </p>
        {% endblock %}
    '''

    def private historyTable(Entity it) '''
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
                        <th id="hTitle" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Title') }}</th>
                        <th id="hDate" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Date') }}</th>
                        <th id="hUser" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('User') }}</th>
                        <th id="hActions" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">{{ __('Actions') }}</th>
                    </tr>
                </thead>
                <tbody>
                    {% for logEntry in deletedEntities %}
                        <tr>
                            <td headers="hVersion" class="text-center">{{ logEntry.objectId }}</td>
                            <td headers="hTitle">
                                {{ logEntry|«application.appName.formatForDB»_logDescription }}
                            </td>
                            <td headers="hDate">{{ logEntry.loggedAt|«IF application.targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('long', 'medium') }}</td>
                            <td headers="hUser">{{ userAvatar(logEntry.username, {size: 20, rating: 'g'}) }} {{ logEntry.username|profileLinkByUserName() }}</td>
                            <td headers="hActions" class="actions nowrap">
                                «IF hasDisplayAction»
                                    {% set linkTitle = __f('Preview «name.formatForDisplay» %id%', {'%id%': logEntry.objectId}) %}
                                    <a id="«name.formatForCode»ItemDisplay{{ logEntry.objectId }}" href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'undelete', {«getPrimaryKey.name.formatForCode»: logEntry.objectId, preview: 1, raw: 1}) }}" title="{{ linkTitle|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window hidden" data-modal-title="{{ __f('«name.formatForDisplayCapital» %id%', {'%id%': logEntry.objectId}) }}"><i class="fa fa-id-card«IF !application.targets('3.0')»-o«ENDIF»"></i></a>
                                «ENDIF»
                                {% set linkTitle = __f('Undelete «name.formatForDisplay» %id%', {'%id%': logEntry.objectId}) %}
                                <a href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'undelete', {«getPrimaryKey.name.formatForCode»: logEntry.objectId}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-history"></i></a>
                            </td>
                        </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    '''
}
