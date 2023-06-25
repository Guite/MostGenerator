package org.zikula.modulestudio.generator.cartridges.symfony.view.pages

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
        fsa.generateFile(templateFilePath, deleteView)
    }

    def private deleteView(Entity it) '''
        «val app = application»
        {# purpose of this template: «nameMultiple.formatForDisplay» delete confirmation view #}
        {% extends routeArea == 'admin' ? '@«app.vendorAndName»/adminBase.html.twig' : '@«app.vendorAndName»/base.html.twig' %}
        {% trans_default_domain '«name.formatForCode»' %}
        {% block title 'Delete «name.formatForDisplay»'|trans %}
        {% block admin_page_icon 'trash-alt' %}
        {% block content %}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-delete">
                <p class="alert alert-warning">{% trans with {'%name%': «name.formatForCode»|«app.appName.formatForDB»_formattedTitle} %}Do you really want to delete this «name.formatForDisplay»: "%name%" ?{% endtrans %}</p>

                {% form_theme deleteForm with [
                    '@«app.vendorAndName»/Form/bootstrap_4.html.twig',
                    '@ZikulaFormExtension/Form/form_div_layout.html.twig'
                ] only %}
                {{ form_start(deleteForm) }}
                {{ form_errors(deleteForm) }}

                <fieldset>
                    <legend>{% trans from 'messages' %}Confirmation prompt{% endtrans %}</legend>
                    <div class="form-group row">
                        <div class="col-md-9 offset-md-3">
                            {{ form_widget(deleteForm.delete) }}
                            {{ form_widget(deleteForm.cancel) }}
                        </div>
                    </div>
                </fieldset>
                {{ form_end(deleteForm) }}
            </div>
        {% endblock %}
    '''
}
