package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Delete {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        ('Generating delete templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFile('delete')
        fsa.generateFile(templateFilePath, deleteView(false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/delete')
            fsa.generateFile(templateFilePath, deleteView(true))
        }
    }

    def private deleteView(Entity it, Boolean isAdmin) '''
        «val app = application»
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» delete confirmation view #}
            «IF application.targets('3.0')»
                {% extends «IF isAdmin»'@«application.appName»/adminBase.html.twig'«ELSE»'@«application.appName»/base.html.twig'«ENDIF» %}
            «ELSE»
                {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
            «ENDIF»
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» delete confirmation view #}
            «IF application.targets('3.0')»
                {% extends routeArea == 'admin' ? '@«app.appName»/adminBase.html.twig' : '@«app.appName»/base.html.twig' %}
            «ELSE»
                {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
            «ENDIF»
        «ENDIF»
        «IF application.targets('3.0') && !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% block title «IF app.targets('3.0')»'Delete «name.formatForDisplay»'|trans«ELSE»__('Delete «name.formatForDisplay»')«ENDIF» %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'trash-«IF application.targets('3.0')»alt«ELSE»o«ENDIF»' %}
        «ENDIF»
        {% block content %}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-delete">
                «IF app.targets('3.0')»
                    <p class="alert alert-warning">{% trans with {'%name%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle} %}Do you really want to delete this «name.formatForDisplay»: "%name%" ?{% endtrans %}</p>
                «ELSE»
                    <p class="alert alert-warning">{{ __f('Do you really want to delete this «name.formatForDisplay»: "%name%" ?', {'%name%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) }}</p>
                «ENDIF»

                {% form_theme deleteForm with [
                    '@«app.appName»/Form/bootstrap_«IF application.targets('3.0')»4«ELSE»3«ENDIF».html.twig',
                    «IF app.targets('3.0')»
                        '@ZikulaFormExtension/Form/form_div_layout.html.twig'
                    «ELSE»
                        'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
                    «ENDIF»
                ]«IF app.targets('3.0')» only«ENDIF» %}
                {{ form_start(deleteForm) }}
                {{ form_errors(deleteForm) }}

                «IF !skipHookSubscribers»
                    {% if «name.formatForCode».supportsHookSubscribers() and formHookTemplates|length > 0 %}
                        <fieldset>
                            {% for hookTemplate in formHookTemplates %}
                                {{ include(hookTemplate.0, hookTemplate.1, ignore_missing = true) }}
                            {% endfor %}
                        </fieldset>
                    {% endif %}
                «ENDIF»
                <fieldset>
                    <legend>«IF app.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Confirmation prompt{% endtrans %}«ELSE»{{ __('Confirmation prompt') }}«ENDIF»</legend>
                    <div class="form-group«IF application.targets('3.0')» row«ENDIF»">
                        <div class="«IF application.targets('3.0')»col-md-9 offset-md-3«ELSE»col-sm-offset-3 col-sm-9«ENDIF»">
                            {{ form_widget(deleteForm.delete) }}
                            {{ form_widget(deleteForm.cancel) }}
                        </div>
                    </div>
                </fieldset>
                {{ form_end(deleteForm) }}
                «IF !skipHookSubscribers»

                    {{ block('display_hooks') }}
                «ENDIF»
            </div>
        {% endblock %}
        «IF !skipHookSubscribers»
            {% block display_hooks %}
                {% if «name.formatForCode».supportsHookSubscribers() %}
                    «callDisplayHooks(app.appName)»
                {% endif %}
            {% endblock %}
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_delete', id=«name.formatForCode».getKey(), urlObject=currentUrlObject, outputAsArray=true) %}
        {% if hooks is iterable and hooks|length > 0 %}
            {% for area, hook in hooks %}
                <div class="z-displayhook" data-area="{{ area|e('html_attr') }}">{{ hook|raw }}</div>
            {% endfor %}
        {% endif %}
    '''
}
