package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ViewMap {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension UrlExtensions = new UrlExtensions
    extension ViewExtensions = new ViewExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    String appName

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating map view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        this.appName = appName

        var templateFilePath = templateFile('viewMap')
        fsa.generateFile(templateFilePath, mapView(appName, false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/viewMap')
            fsa.generateFile(templateFilePath, mapView(appName, true))
        }
    }

    def private mapView(Entity it, String appName, Boolean isAdmin) '''
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» tree view #}
            {% extends «IF isAdmin»'«appName»::adminBase.html.twig'«ELSE»'«appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» map view #}
            {% extends routeArea == 'admin' ? '«appName»::adminBase.html.twig' : '«appName»::base.html.twig' %}
        «ENDIF»
        {% block title own ? __('My «nameMultiple.formatForDisplay»') : __('«nameMultiple.formatForDisplayCapital» list') %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block adminPageIcon 'map-o' %}
        «ENDIF»
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-view «appName.toLowerCase»-map">

            {{ block('page_nav_links') }}

            {{ include('@«application.appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewQuickNav.html.twig'«IF !hasVisibleWorkflow», {workflowStateFilter: false}«ENDIF») }}{# see template file for available options #}

            <div id="mapContainer" style="height: 800px">
            </div>
            «IF !skipHookSubscribers»

                {{ block('display_hooks') }}
            «ENDIF»
            </div>
        {% endblock %}
        {% block footer %}
            {{ parent() }}
            «includeLeaflet('view', name.formatForCode)»
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».ViewMap.js')) }}
            {% set customStyle %}
                <style>
                    .detail-marker {
                        width: auto !important;
                        height: auto !important;
                        background-color: #f5f5f5;
                        border: 1px solid #666;
                        padding: 15px 10px 10px;
                        border-radius: 4px;
                    }
                </style>
            {% endset %}
            {{ pageAddAsset('header', customStyle) }}
            {% set customScript %}
                <script>
                /* <![CDATA[ */
                    var markerData = [];
                    {% for «name.formatForCode» in items if «name.formatForCode».latitude|default and «name.formatForCode».longitude|default %}
                        markerData.push({
                            latitude: {{ «name.formatForCode».latitude|e('js') }},
                            longitude: {{ «name.formatForCode».longitude|e('js') }},
                            title: '{{ «name.formatForCode»|«appName.formatForDB»_formattedTitle|e('js') }}'«IF null !== getMapImageField»,
                            image: '{% if «name.formatForCode».«getMapImageField.name.formatForCode» is not empty and «name.formatForCode».«getMapImageField.name.formatForCode»Meta|default %}{{ «name.formatForCode».«getMapImageField.name.formatForCode»Url|e('js') }}{% endif %}'«ENDIF»«IF hasDisplayAction»,
                            detailUrl: '{{ path('«appName.formatForDB»_«name.formatForCode»_' ~ routeArea ~ 'display'«routeParams(name.formatForCode, true)»)|e('js') }}'«ENDIF»
                        });
                    {% endfor %}
                    ( function($) {
                        $(document).ready(function() {
                            $('.«appName.formatForDB»-quicknav').removeClass('navbar-form');
                            $('.«appName.formatForDB»-quicknav input, .«appName.formatForDB»-quicknav select')
                                .css('width', '100%')
                            ;
                        });
                    })(jQuery);
                /* ]]> */
                </script>
            {% endset %}
            {{ pageAddAsset('footer', customScript) }}
        {% endblock %}
        {% block page_nav_links %}
            <p>
                «pageNavLinks»
            </p>
        {% endblock %}
        «IF !skipHookSubscribers»
            {% block display_hooks %}
                «callDisplayHooks»
            {% endblock %}
        «ENDIF»
    '''

    def private getMapImageField(Entity it) {
    	if (getUploadFieldsEntity.filter[isOnlyImageField].empty) {
    	    return null
    	}
    	getUploadFieldsEntity.filter[isOnlyImageField].head
    }

    def private pageNavLinks(Entity it) '''
        «val objName = name.formatForCode»
        «IF hasEditAction»
            {% if canBeCreated %}
                {% if permissionHelper.hasComponentPermission('«name.formatForCode»', constant('ACCESS_«IF workflow == EntityWorkflowType.NONE»EDIT«ELSE»COMMENT«ENDIF»')) %}
                    {% set createTitle = __('Create «name.formatForDisplay»') %}
                    <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'edit') }}" title="{{ createTitle|e('html_attr') }}"><i class="fa fa-plus"></i> {{ createTitle }}</a>
                {% endif %}
            {% endif %}
        «ENDIF»
        {% if all == 1 %}
            {% set linkTitle = __('Back to paginated view') %}
            {% set routeArgs = own ? {own: 1} : {} %}
            <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', routeArgs) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-table"></i> {{ linkTitle }}</a>
        {% else %}
            {% set linkTitle = __('Show all entries') %}
            {% set routeArgs = own ? {all: 1, own: 1} : {all: 1} %}
            <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', routeArgs) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-table"></i> {{ linkTitle }}</a>
        {% endif %}
        «IF standardFields»
            {% if own == 1 %}
                {% set linkTitle = __('Show also entries from other users') %}
                {% set routeArgs = all ? {all: 1} : {} %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', routeArgs) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-users"></i> {{ linkTitle }}</a>
            {% else %}
                {% set linkTitle = __('Show only own entries') %}
                {% set routeArgs = all ? {all: 1, own: 1} : {own: 1} %}
                <a href="{{ path('«appName.formatForDB»_«objName.toLowerCase»_' ~ routeArea ~ 'view', routeArgs) }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa fa-user"></i> {{ linkTitle }}</a>
            {% endif %}
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it) '''

        {# here you can activate calling display hooks for the view page if you need it #}
        {# % if routeArea != 'admin' %}
            {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view', urlObject=currentUrlObject, outputAsArray=true) %}
            {% if hooks is iterable and hooks|length > 0 %}
                {% for area, hook in hooks %}
                    <div class="z-displayhook" data-area="{{ area|e('html_attr') }}">{{ hook|raw }}</div>
                {% endfor %}
            {% endif %}
        {% endif % #}
    '''
}
