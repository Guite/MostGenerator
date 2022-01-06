package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeListView {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'ContentType/'
        new CommonIntegrationTemplates().generate(it, fsa, templatePath)

        var fileName = 'itemListEdit.html.twig'
        fsa.generateFile(templatePath + fileName, editTemplate)
    }

    def private editTemplate(Application it) '''
        {# purpose of this template: edit view of generic item list content type #}
        {% if form.objectType is defined %}
            {{ form_row(form.objectType) }}
        {% endif %}
        «IF hasCategorisableEntities»
            {% if form.categories is defined %}
                {{ form_row(form.categories) }}
            {% endif %}
        «ENDIF»
        {% if form.sorting is defined %}
            {{ form_row(form.sorting) }}
        {% endif %}
        {% if form.amount is defined %}
            {{ form_row(form.amount) }}
        {% endif %}

        {% if form.template is defined %}
            {{ form_row(form.template) }}
            <div id="customTemplateArea">
                {% if form.customTemplate is defined %}
                    {{ form_row(form.customTemplate) }}
                {% endif %}
            </div>
        {% endif %}

        {% if form.filter is defined %}
            {{ form_row(form.filter) }}
        {% endif %}

        {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».ContentType.List.Edit.js')) }}
    '''
}
