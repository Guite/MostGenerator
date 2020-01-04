package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.view

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewPagesHelper
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

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating map view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

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
            «IF application.targets('3.0')»
                {% extends «IF isAdmin»'@«appName»/adminBase.html.twig'«ELSE»'@«appName»/base.html.twig'«ENDIF» %}
            «ELSE»
                {% extends «IF isAdmin»'«appName»::adminBase.html.twig'«ELSE»'«appName»::base.html.twig'«ENDIF» %}
            «ENDIF»
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» map view #}
            «IF application.targets('3.0')»
                {% extends routeArea == 'admin' ? '@«appName»/adminBase.html.twig' : '@«appName»/base.html.twig' %}
            «ELSE»
                {% extends routeArea == 'admin' ? '«appName»::adminBase.html.twig' : '«appName»::base.html.twig' %}
            «ENDIF»
        «ENDIF»
        {% block title own ? __('My «nameMultiple.formatForDisplay»') : __('«nameMultiple.formatForDisplayCapital» list') %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'map«IF application.targets('3.0')»«ELSE»-o«ENDIF»' %}
        «ENDIF»
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-view «appName.toLowerCase»-map">
                «new ViewPagesHelper().commonHeader(it)»
                {{ include('@«application.appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewQuickNav.html.twig', {«IF !hasVisibleWorkflow»workflowStateFilter: false, «ENDIF»sorting: false, pageSizeSelector: false}) }}{# see template file for available options #}

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
                    {% for «name.formatForCode» in items if «name.formatForCode».latitude|default != 0 and «name.formatForCode».longitude|default != 0 %}
                        markerData.push({
                            latitude: '{{ «name.formatForCode».latitude|e('js') }}',
                            longitude: '{{ «name.formatForCode».longitude|e('js') }}',
                            title: '{{ «name.formatForCode»|«appName.formatForDB»_formattedTitle|e('js') }}'«IF null !== getMapImageField»,
                            image: '{% if «name.formatForCode».«getMapImageField.name.formatForCode» is not empty and «name.formatForCode».«getMapImageField.name.formatForCode»Meta|default %}{{ «name.formatForCode».«getMapImageField.name.formatForCode»Url|e('js') }}{% endif %}'«ENDIF»«IF hasDisplayAction»,
                            detailUrl: '{{ path('«appName.formatForDB»_«name.formatForCode»_' ~ routeArea ~ 'display'«routeParams(name.formatForCode, true)»)|e('js') }}'«ENDIF»
                        });
                    {% endfor %}
                    ( function($) {
                        $(document).ready(function() {
                            $('.«appName.formatForDB»-quicknav').removeClass('«IF application.targets('3.0')»form-inline«ELSE»navbar-form«ENDIF»');
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
        «new ViewPagesHelper().callDisplayHooks(it)»
    '''

    def private getMapImageField(Entity it) {
    	if (getUploadFieldsEntity.filter[isOnlyImageField].empty) {
    	    return null
    	}
    	getUploadFieldsEntity.filter[isOnlyImageField].head
    }
}
