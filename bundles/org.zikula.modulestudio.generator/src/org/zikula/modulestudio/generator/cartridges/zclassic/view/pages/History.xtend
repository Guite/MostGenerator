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
            «IF app.targets('3.0')»
                {% extends «IF isAdmin»'@«app.appName»/adminBase.html.twig'«ELSE»'@«app.appName»/base.html.twig'«ENDIF» %}
            «ELSE»
                {% extends «IF isAdmin»'«app.appName»::adminBase.html.twig'«ELSE»'«app.appName»::base.html.twig'«ENDIF» %}
            «ENDIF»
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» change history view #}
            «IF app.targets('3.0')»
                {% extends routeArea == 'admin' ? '@«app.appName»/adminBase.html.twig' : '@«app.appName»/base.html.twig' %}
            «ELSE»
                {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
            «ENDIF»
        «ENDIF»
        «IF !app.isSystemModule && app.targets('3.0')»
            {% trans_default_domain '«app.appName.formatForDB»' %}
        «ENDIF»
        «IF !app.targets('3.0')»
            {% import _self as helper %}
        «ENDIF»
        {% macro outputSimpleValue(input) %}
            {{ input is «app.appName.toLowerCase»_instanceOf('DateTimeInterface') ? input|«IF app.targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('long', 'medium') : input|default(«IF app.targets('3.0')»'an empty value'|trans«ELSE»__('an empty value')«ENDIF») }}
        {% endmacro %}
        {% macro outputArray(input«IF hasTranslatableFields», keysAreLanguages«ENDIF») %}
            «IF !app.targets('3.0')»
                {% import _self as helper %}
            «ENDIF»
            <ul>
                {% for key, value in input %}
                    <li><span class="«IF app.targets('3.0')»font-weight-«ENDIF»bold">{{ «IF hasTranslatableFields»keysAreLanguages ? key|«IF app.targets('3.0')»language_name«ELSE»languageName|safeHtml|humanize«ENDIF» : «ENDIF»key|humanize }}:</span> {% if value is iterable %}{{ «IF app.targets('3.0')»_self«ELSE»helper«ENDIF».outputArray(value«IF hasTranslatableFields», false«ENDIF») }}{% else %}<span class="«IF app.targets('3.0')»font-«ENDIF»italic">{{ value }}</span>{% endif %}</li>
                {% endfor %}
            </ul>
        {% endmacro %}
        «IF app.targets('3.0')»
            {% block title isDiffView == true ? 'Compare versions of %entityTitle%'|trans({'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) : '«name.formatForDisplayCapital» change history for %entityTitle%'|trans({'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) %}
        «ELSE»
            {% block title isDiffView == true ? __f('Compare versions of %entityTitle%', {'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) : __f('«name.formatForDisplayCapital» change history for %entityTitle%', {'%entityTitle%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) %}
        «ENDIF»
        «IF !app.separateAdminTemplates || isAdmin»
            {% block admin_page_icon isDiffView == true ? 'arrows-«IF app.targets('3.0')»alt-«ENDIF»h' : 'history' %}
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
            <form action="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'loggablehistory', {«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»: «name.formatForCode».get«IF hasSluggableFields && slugUnique»Slug«ELSE»Key«ENDIF»()}) }}" method="get"«IF !app.targets('3.0')» class="form-horizontal" role="form"«ENDIF»>
                <div class="table-responsive">
                    «historyTable»
                </div>
                <p>
                    <button id="compareButton" type="submit" value="compare" class="btn btn-primary" disabled="disabled"><i class="fa fa-arrows«IF app.targets('3.0')»-alt«ENDIF»-h"></i> «IF app.targets('3.0')»{% trans %}Compare selected versions{% endtrans %}«ELSE»{{ __('Compare selected versions') }}«ENDIF»</button>
                </p>
            </form>
        {% endblock %}
        {% block diff_view %}
            <div class="table-responsive">
                <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-«IF app.targets('3.0')»sm«ELSE»condensed«ENDIF»{% endif %}">
                    <colgroup>
                        <col id="cFieldName" />
                        <col id="cMinVersion" />
                        <col id="cMaxVersion" />
                    </colgroup>
                    <thead>
                        <tr>
                            <th id="hFieldName" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">«IF app.targets('3.0')»{% trans %}Field name{% endtrans %}«ELSE»{{ __('Field name') }}«ENDIF»</th>
                            <th id="hMinVersion" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">«IF app.targets('3.0')»{% trans with {'%version%': minVersion} %}Version %version%{% endtrans %}«ELSE»{{ __f('Version %version%', {'%version%': minVersion}) }}«ENDIF»</th>
                            <th id="hMaxVersion" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">«IF app.targets('3.0')»{% trans with {'%version%': maxVersion} %}Version %version%{% endtrans %}«ELSE»{{ __f('Version %version%', {'%version%': maxVersion}) }}«ENDIF»</th>
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
                                                {{ «IF app.targets('3.0')»_self«ELSE»helper«ENDIF».outputArray(values.old«IF hasTranslatableFields», (fieldName == 'translationData')«ENDIF») }}
                                            {% endif %}
                                        {% else %}
                                            «IF app.targets('3.0')»{% trans %}an empty collection{% endtrans %}«ELSE»{{ __('an empty collection') }}«ENDIF»
                                        {% endif %}
                                    {% else %}
                                        {{ «IF app.targets('3.0')»_self«ELSE»helper«ENDIF».outputSimpleValue(values.old) }}
                                    {% endif %}
                                </td>
                                <td headers="hMaxVersion h{{ fieldName|e('html_attr') }}"{% if values.changed %} class="diff-new"{% endif %}>
                                    {% if values.new is iterable %}
                                        {% if values.new|length > 0 %}
                                            {% if fieldName in ['createdBy', 'updatedBy'] and values.new.uid is defined %}
                                                {{ userAvatar(values.new.uid, {rating: 'g'}) }} {{ values.new.uid|profileLinkByUserId() }}
                                            {% else %}
                                                {{ «IF app.targets('3.0')»_self«ELSE»helper«ENDIF».outputArray(values.new«IF hasTranslatableFields», (fieldName == 'translationData')«ENDIF») }}
                                            {% endif %}
                                        {% else %}
                                            «IF app.targets('3.0')»{% trans %}an empty collection{% endtrans %}«ELSE»{{ __('an empty collection') }}«ENDIF»
                                        {% endif %}
                                    {% else %}
                                        {{ «IF app.targets('3.0')»_self«ELSE»helper«ENDIF».outputSimpleValue(values.new) }}
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
        <table class="table table-striped table-bordered table-hover{% if routeArea == 'admin' %} table-«IF app.targets('3.0')»sm«ELSE»condensed«ENDIF»{% endif %}">
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
                    <th id="hSelect" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted«IF !app.targets('3.0')» z-w02«ENDIF»">«IF app.targets('3.0')»{% trans %}Select{% endtrans %}«ELSE»{{ __('Select') }}«ENDIF»</th>
                    <th id="hVersion" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted«IF !app.targets('3.0')» z-w02«ENDIF»">«IF app.targets('3.0')»{% trans %}Version{% endtrans %}«ELSE»{{ __('Version') }}«ENDIF»</th>
                    <th id="hDate" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">«IF app.targets('3.0')»{% trans %}Date{% endtrans %}«ELSE»{{ __('Date') }}«ENDIF»</th>
                    <th id="hUser" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">«IF app.targets('3.0')»{% trans %}User{% endtrans %}«ELSE»{{ __('User') }}«ENDIF»</th>
                    <th id="hOperation" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted" colspan="2">«IF app.targets('3.0')»{% trans %}Operation{% endtrans %}«ELSE»{{ __('Operation') }}«ENDIF»</th>
                    <th id="hChanges" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">«IF app.targets('3.0')»{% trans %}Changes{% endtrans %}«ELSE»{{ __('Changes') }}«ENDIF»</th>
                    <th id="hActions" scope="col" class="«IF !app.targets('2.0')»z-order-«ENDIF»unsorted">«IF app.targets('3.0')»{% trans %}Actions{% endtrans %}«ELSE»{{ __('Actions') }}«ENDIF»</th>
                </tr>
            </thead>
            <tbody>
                {% for logEntry in logEntries %}
                    <tr>
                        <td headers="hSelect hVersion{{ logEntry.version|e('html_attr') }}" class="text-center">
                            <input type="checkbox" name="versions[]" value="{{ logEntry.version }}" class="«app.vendorAndName.toLowerCase»-toggle-checkbox" />
                        </td>
                        <th id="hVersion{{ logEntry.version|e('html_attr') }}" headers="hVersion" scope="row" class="text-center">{{ logEntry.version }}{% if loop.first %} («IF app.targets('3.0')»{% trans %}latest{% endtrans %}«ELSE»{{ __('latest') }}«ENDIF»){% endif %}</td>
                        <td headers="hDate hVersion{{ logEntry.version|e('html_attr') }}">
                            {{ logEntry.loggedAt|«IF app.targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('long', 'medium') }}
                        </td>
                        <td headers="hUser hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.username %}
                                {{ userAvatar(logEntry.username, {rating: 'g'}) }} {{ logEntry.username|profileLinkByUserName() }}
                            {% endif %}
                        </td>
                        <td headers="hOperation hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_CREATE') %}
                                «IF app.targets('3.0')»{% trans %}Created{% endtrans %}«ELSE»{{ __('Created') }}«ENDIF»
                            {% elseif logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_UPDATE') %}
                                «IF app.targets('3.0')»{% trans %}Updated{% endtrans %}«ELSE»{{ __('Updated') }}«ENDIF»
                            {% elseif logEntry.action == constant('Gedmo\\Loggable\\LoggableListener::ACTION_REMOVE') %}
                                «IF app.targets('3.0')»{% trans %}Removed{% endtrans %}«ELSE»{{ __('Removed') }}«ENDIF»
                            {% endif %}
                        </td>
                        <td headers="hOperation hVersion{{ logEntry.version|e('html_attr') }}">
                            {{ logEntry|«app.appName.formatForDB»_logDescription }}
                        </td>
                        <td headers="hChanges hVersion{{ logEntry.version|e('html_attr') }}">
                            {% if logEntry.data is not empty %}
                                <a role="button" data-toggle="collapse" href="#changes{{ logEntry.version }}" aria-expanded="false" aria-controls="changes{{ logEntry.version }}">
                                    «IF app.targets('3.0')»
                                        {{ '{0} No fields updated|{1} One field updated|]1,Inf[ %count% fields updated'|trans({'%count%': logEntry.data|length}«IF !app.isSystemModule», '«app.appName.formatForDB»'«ENDIF») }}
                                    «ELSE»
                                        {{ '{0} No fields updated|{1} One field updated|]1,Inf[ %amount% fields updated'|transchoice(logEntry.data|length, {'%amount%': logEntry.data|length}«IF !app.isSystemModule», '«app.appName.formatForDB»'«ENDIF») }}
                                    «ENDIF»
                                </a>
                                <div id="changes{{ logEntry.version }}" class="collapse">
                                    <ul>
                                        {% for field, value in logEntry.data %}
                                            {% if value is iterable %}
                                                {% if value|length > 0 %}
                                                    <li>
                                                    {% if field in ['createdBy', 'updatedBy'] and value.uid is defined %}
                                                        «IF app.targets('3.0')»
                                                            {{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': userAvatar(value.uid, {rating: 'g'}) ~ ' ' ~ value.uid|profileLinkByUserId()})|raw }}
                                                        «ELSE»
                                                            {{ __f('%field% set to <em>%value%</em>', {'%field%': field|humanize, '%value%': userAvatar(value.uid, {rating: 'g'}) ~ ' ' ~ value.uid|profileLinkByUserId()})|raw }}
                                                        «ENDIF»
                                                    {% else %}
                                                        «IF app.targets('3.0')»
                                                            {{ '%field% set to:'|trans({'%field%': field|humanize}) }}
                                                        «ELSE»
                                                            {{ __f('%field% set to:', {'%field%': field|humanize}) }}
                                                        «ENDIF»
                                                        {{ «IF app.targets('3.0')»_self«ELSE»helper«ENDIF».outputArray(value«IF hasTranslatableFields», (field == 'translationData')«ENDIF») }}
                                                    {% endif %}
                                                    </li>
                                                {% else %}
                                                    «IF app.targets('3.0')»
                                                        <li>{{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': __('an empty collection')})|raw }}</li>
                                                    «ELSE»
                                                        <li>{{ __f('%field% set to <em>%value%</em>', {'%field%': field|humanize, '%value%': __('an empty collection')})|raw }}</li>
                                                    «ENDIF»
                                                {% endif %}
                                            {% else %}
                                                «IF app.targets('3.0')»
                                                    <li>{{ '%field% set to <em>%value%</em>'|trans({'%field%': field|humanize, '%value%': «IF app.targets('3.0')»_self«ELSE»helper«ENDIF».outputSimpleValue(value)})|raw }}</li>
                                                «ELSE»
                                                    <li>{{ __f('%field% set to <em>%value%</em>', {'%field%': field|humanize, '%value%': «IF app.targets('3.0')»_self«ELSE»helper«ENDIF».outputSimpleValue(value)})|raw }}</li>
                                                «ENDIF»
                                            {% endif %}
                                        {% endfor %}
                                    </ul>
                                </div>
                            {% else %}
                                «IF app.targets('3.0')»{% trans %}None{% endtrans %}«ELSE»{{ __('None') }}«ENDIF»
                            {% endif %}
                        </td>
                        <td headers="hActions hVersion{{ logEntry.version|e('html_attr') }}" class="actions«IF !app.targets('3.0')» nowrap«ENDIF»">
                            «IF hasDisplayAction»
                                {% set linkTitle = «IF app.targets('3.0')»'Preview version %version%'|trans({'%version%': logEntry.version})«ELSE»__f('Preview version %version%', {'%version%': logEntry.version})«ENDIF» %}
                                <a id="«name.formatForCode»Item{{ «name.formatForCode».getKey() }}Display{{ logEntry.version }}" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display', {«IF !hasSluggableFields || !slugUnique»«routePkParams(name.formatForCode, true)»«ENDIF»«appendSlug(name.formatForCode, true)», version: logEntry.version, raw: 1}) }}" title="{{ linkTitle|e('html_attr') }}" class="«app.vendorAndName.toLowerCase»-inline-window «IF app.targets('3.0')»d-none«ELSE»hidden«ENDIF»" data-modal-title="{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle|e('html_attr') ~ ' ' ~ «IF app.targets('3.0')»'version'|trans«ELSE»__('version')«ENDIF» ~ ' ' ~ logEntry.version }}"><i class="fa fa-id-card«IF !app.targets('3.0')»-o«ENDIF»"></i></a>
                            «ENDIF»
                            {% if not loop.first %}
                                {% set linkTitle = «IF app.targets('3.0')»'Revert to version %version%'|trans({ '%version%': logEntry.version })«ELSE»__f('Revert to version %version%', { '%version%': logEntry.version })«ENDIF» %}
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
                    {% set linkTitle = «IF application.targets('3.0')»'Back to history'|trans«ELSE»__('Back to history')«ENDIF» %}
                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'loggablehistory', {«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»: «name.formatForCode».get«IF hasSluggableFields && slugUnique»Slug«ELSE»Key«ENDIF»()}) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-history"></i> {{ linkTitle }}</a>
                {% else %}
                    «IF hasViewAction»
                        {% set linkTitle = «IF application.targets('3.0')»'«nameMultiple.formatForDisplayCapital» list'|trans«ELSE»__('«nameMultiple.formatForDisplayCapital» list')«ENDIF» %}
                        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view') }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-reply"></i> {{ linkTitle }}</a>
                    «ENDIF»
                {% endif %}
                «IF hasDisplayAction»
                    {% set linkTitle = «IF application.targets('3.0')»'Back to detail view'|trans«ELSE»__('Back to detail view')«ENDIF» %}
                    <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams(name.formatForCode, true)») }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-eye"></i> {{ linkTitle }}</a>
                «ENDIF»
            </p>
        «ENDIF»
    '''
}
