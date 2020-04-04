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
        «IF application.targets('3.0') && !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        «IF application.targets('3.0')»
             {% block title own ? 'My «nameMultiple.formatForDisplay»'|trans : '«nameMultiple.formatForDisplayCapital» list'|trans %}
         «ELSE»
             {% block title own ? __('My «nameMultiple.formatForDisplay»') : __('«nameMultiple.formatForDisplayCapital» list') %}
         «ENDIF»
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'map«IF application.targets('3.0')»«ELSE»-o«ENDIF»' %}
        «ENDIF»
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-view «appName.toLowerCase»-map">
                «(new ViewPagesHelper).commonHeader(it)»
                {{ include('@«application.appName»/«name.formatForCodeCapital»/«IF isAdmin»Admin/«ENDIF»viewQuickNav.html.twig', {«IF !hasVisibleWorkflow»workflowStateFilter: false, «ENDIF»sorting: false, pageSizeSelector: false}) }}{# see template file for available options #}

                <div id="mapContainer" class="«application.appName.toLowerCase»-mapcontainer">
                </div>
                «(new ViewPagesHelper).pagerCall(it)»
                «IF !skipHookSubscribers»

                    {{ block('display_hooks') }}
                «ENDIF»
                {% for «name.formatForCode» in items«IF application.targets('3.0')»|filter(i => i.latitude|default != 0 and i.longitude|default != 0)«ELSE» if «name.formatForCode».latitude|default != 0 and «name.formatForCode».longitude|default != 0«ENDIF» %}
                    <div class="map-marker-definition" data-latitude="{{ «name.formatForCode».latitude|e('html_attr') }}" data-longitude="{{ «name.formatForCode».longitude|e('html_attr') }}" data-title="{{ «name.formatForCode»|«appName.formatForDB»_formattedTitle|e('html_attr') }}" data-image="«IF null !== getMapImageField»{% if «name.formatForCode».«getMapImageField.name.formatForCode» is not empty and «name.formatForCode».«getMapImageField.name.formatForCode»Meta|default %}{{ «name.formatForCode».«getMapImageField.name.formatForCode»Url|e('html_attr') }}{% endif %}«ENDIF»" data-detail-url="«IF hasDisplayAction»{{ path('«appName.formatForDB»_«name.formatForCode»_' ~ routeArea ~ 'display'«routeParams(name.formatForCode, true)»)|e('html_attr') }}«ENDIF»"></div>
                {% endfor %}
            </div>
        {% endblock %}
        {% block footer %}
            {{ parent() }}
            «includeLeaflet('view', name.formatForCode)»
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».ViewMap.js')) }}
        {% endblock %}
        «(new ViewPagesHelper).callDisplayHooks(it)»
    '''

    def private getMapImageField(Entity it) {
    	if (getUploadFieldsEntity.filter[isOnlyImageField].empty) {
    	    return null
    	}
    	getUploadFieldsEntity.filter[isOnlyImageField].head
    }
}
