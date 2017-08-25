package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Delete {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating delete templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = templateFile('delete')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, deleteView(false))
        }
        if (application.generateSeparateAdminTemplates) {
            templateFilePath = templateFile('Admin/delete')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, deleteView(true))
            }
        }
    }

    def private deleteView(Entity it, Boolean isAdmin) '''
        «val app = application»
        «IF application.generateSeparateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» delete confirmation view #}
            {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» delete confirmation view #}
            {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        «ENDIF»
        {% block title __('Delete «name.formatForDisplay»') %}
        «IF !application.generateSeparateAdminTemplates || isAdmin»
            {% block admin_page_icon 'trash-o' %}
        «ENDIF»
        {% block content %}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-delete">
                <p class="alert alert-warning">{{ __f('Do you really want to delete this «name.formatForDisplay»: "%name%" ?', {'%name%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle}) }}</p>

                {% form_theme deleteForm with [
                    '@«app.appName»/Form/bootstrap_3.html.twig',
                    'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
                ] %}
                {{ form_start(deleteForm) }}
                {{ form_errors(deleteForm) }}

                «IF !skipHookSubscribers»
                    {% if formHookTemplates|length > 0 %}
                        <fieldset>
                            {% for hookTemplate in formHookTemplates %}
                                {{ include(hookTemplate.0, hookTemplate.1, ignore_missing = true) }}
                            {% endfor %}
                        </fieldset>
                    {% endif %}
                «ENDIF»
                <fieldset>
                    <legend>{{ __('Confirmation prompt') }}</legend>
                    <div class="form-group">
                        <div class="col-sm-offset-3 col-sm-9">
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
                «callDisplayHooks(app.appName)»
            {% endblock %}
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        {{ notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_delete', id=«name.formatForCode».getKey()) }}
    '''
}
