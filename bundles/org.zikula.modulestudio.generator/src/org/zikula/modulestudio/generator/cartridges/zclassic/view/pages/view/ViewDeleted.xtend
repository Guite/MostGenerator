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
        «IF application.targets('3.0') && !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% block title «IF application.targets('3.0')»'Deleted «nameMultiple.formatForDisplay»'|trans«ELSE»__('Deleted «nameMultiple.formatForDisplay»')«ENDIF» %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'trash-«IF application.targets('3.0')»alt«ELSE»o«ENDIF»' %}
        «ENDIF»
        {% block content %}
            <div class="«application.appName.toLowerCase»-«name.formatForDB» «application.appName.toLowerCase»-viewdeleted">
                {{ block('page_nav_links') }}«/*new ViewPagesHelper().commonHeader(it)*/»
                «IF !hasDisplayAction»
                    <p class="alert alert-info">«IF application.targets('3.0')»{% trans %}Because there exists no display action for «nameMultiple.formatForDisplay» it is not possible to preview deleted items.{% endtrans %}«ELSE»{{ __('Because there exists no display action for «nameMultiple.formatForDisplay» it is not possible to preview deleted items.') }}«ENDIF»</p>
                «ENDIF»
                «historyTable»
                {{ block('page_nav_links') }}
            </div>
        {% endblock %}
        {% block page_nav_links %}
            <p>
                {% set linkTitle = «IF application.targets('3.0')»'Back to overview'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Back to overview')«ENDIF» %}
                <a href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-reply"></i> {{ linkTitle }}</a>
            </p>
        {% endblock %}
    '''

    def private historyTable(Entity it) '''
        <div class="table-responsive">
            <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-«IF application.targets('3.0')»sm«ELSE»condensed«ENDIF»{% endif %}">
                <colgroup>
                    <col id="cId" />
                    <col id="cDate" />
                    <col id="cUser" />
                    <col id="cActions" />
                </colgroup>
                <thead>
                    <tr>
                        <th id="hId" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted«IF !application.targets('3.0')» z-w02«ENDIF»">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}ID{% endtrans %}«ELSE»{{ __('ID') }}«ENDIF»</th>
                        <th id="hTitle" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Title{% endtrans %}«ELSE»{{ __('Title') }}«ENDIF»</th>
                        <th id="hDate" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Date{% endtrans %}«ELSE»{{ __('Date') }}«ENDIF»</th>
                        <th id="hUser" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}User{% endtrans %}«ELSE»{{ __('User') }}«ENDIF»</th>
                        <th id="hActions" scope="col" class="«IF !application.targets('2.0')»z-order-«ENDIF»unsorted">«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Action{% endtrans %}«ELSE»{{ __('Actions') }}«ENDIF»</th>
                    </tr>
                </thead>
                <tbody>
                    {% for logEntry in deletedEntities %}
                        <tr>
                            <th id="hId{{ logEntry.objectId|e('html_attr') }}" headers="hId" scope="row" class="text-center">{{ logEntry.objectId }}</td>
                            <td headers="hTitle hId{{ logEntry.objectId|e('html_attr') }}">
                                {{ logEntry|«application.appName.formatForDB»_logDescription }}
                            </td>
                            <td headers="hDate hId{{ logEntry.objectId|e('html_attr') }}">{{ logEntry.loggedAt|«IF application.targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('long', 'medium') }}</td>
                            <td headers="hUser hId{{ logEntry.objectId|e('html_attr') }}">{{ userAvatar(logEntry.username, {size: 20, rating: 'g'}) }} {{ logEntry.username|profileLinkByUserName() }}</td>
                            <td headers="hActions hId{{ logEntry.objectId|e('html_attr') }}" class="actions«IF !application.targets('3.0')» nowrap«ENDIF»">
                                «IF hasDisplayAction»
                                    {% set linkTitle = «IF application.targets('3.0')»'Preview «name.formatForDisplay» %id%'|trans({'%id%': logEntry.objectId})«ELSE»__f('Preview «name.formatForDisplay» %id%', {'%id%': logEntry.objectId})«ENDIF» %}
                                    <a id="«name.formatForCode»ItemDisplay{{ logEntry.objectId }}" href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'undelete', {«getPrimaryKey.name.formatForCode»: logEntry.objectId, preview: 1, raw: 1}) }}" title="{{ linkTitle|e('html_attr') }}" class="«application.vendorAndName.toLowerCase»-inline-window «IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»" data-modal-title="{{ «IF application.targets('3.0')»'«name.formatForDisplayCapital» %id%'|trans({'%id%': logEntry.objectId})«ELSE»__f('«name.formatForDisplayCapital» %id%', {'%id%': logEntry.objectId})«ENDIF»|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-id-card«IF !application.targets('3.0')»-o«ENDIF»"></i></a>
                                «ENDIF»
                                {% set linkTitle = «IF application.targets('3.0')»'Undelete «name.formatForDisplay» %id%'|trans({'%id%': logEntry.objectId})«ELSE»__f('Undelete «name.formatForDisplay» %id%', {'%id%': logEntry.objectId})«ENDIF» %}
                                <a href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'undelete', {«getPrimaryKey.name.formatForCode»: logEntry.objectId}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-history"></i></a>
                            </td>
                        </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    '''
}
