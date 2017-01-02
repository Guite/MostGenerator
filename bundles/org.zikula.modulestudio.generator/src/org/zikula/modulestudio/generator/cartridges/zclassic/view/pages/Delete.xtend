package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Delete {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        val templateFilePath = templateFile('delete')
        if (!application.shouldBeSkipped(templateFilePath)) {
            println('Generating delete templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, deleteView(appName))
        }
    }

    def private deleteView(Entity it, String appName) '''
        «val app = application»
        {# purpose of this template: «nameMultiple.formatForDisplay» delete confirmation view #}
        {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        {% block title __('Delete «name.formatForDisplay»') %}
        {% block admin_page_icon 'trash-o' %}
        {% block content %}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-delete">
                <p class="alert alert-warning">{{ __f('Do you really want to delete this «name.formatForDisplay»: "%name%" ?', {'%name%': «name.formatForCode».getTitleFromDisplayPattern()}) }}</p>

                {% form_theme deleteForm with [
                    '@«appName»/Form/bootstrap_3.html.twig',
                    'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
                ] %}
                {{ form_start(deleteForm) }}
                {{ form_errors(deleteForm) }}

                <fieldset>
                    <legend>{{ __('Confirmation prompt') }}</legend>
                    <div class="form-group">
                        <div class="col-sm-offset-3 col-sm-9">
                            {{ form_widget(deleteForm.delete) }}
                            {{ form_widget(deleteForm.cancel) }}
                        </div>
                    </div>
                </fieldset>
                «IF !skipHookSubscribers»

                    {{ block('display_hooks') }}
                «ENDIF»
                {{ form_end(deleteForm) }}
            </div>
        {% endblock %}
        «IF !skipHookSubscribers»
            {% block display_hooks %}
                «callDisplayHooks(appName)»
            {% endblock %}
        «ENDIF»
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_delete', id=«FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForCode».«pkField.name.formatForCode»«ENDFOR») %}
        {% if hooks is iterable and hooks|length > 0 %}
            {% for providerArea, hook in hooks %}
                <fieldset>
                    {# <legend>{{ hookName }}</legend> #}
                    {{ hook }}
                </fieldset>
            {% endfor %}
        {% endif %}
    '''
}
