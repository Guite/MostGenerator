package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockListView {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Block/'
        if (!generateListContentType || targets('2.0')) {
            new CommonIntegrationTemplates().generate(it, fsa, templatePath)
        }
        val templateExtension = '.html.twig'
        var fileName = 'itemlist' + templateExtension
        fsa.generateFile(templatePath + fileName, displayTemplate)

        fileName = 'itemlist_modify' + templateExtension
        fsa.generateFile(templatePath + fileName, editTemplate)
    }

    def private displayTemplate(Application it) '''
        {# purpose of this template: Display items within a block (fallback template) #}
        Default block for generic item list.
    '''

    def private editTemplate(Application it) '''
        {# purpose of this template: Edit block for generic item list view #}
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
            <div id="customTemplateArea" data-switch="zikulablocksmodule_block[properties][template]" data-switch-value="custom">
                {% if form.customTemplate is defined %}
                    {{ form_row(form.customTemplate) }}
                {% endif %}
            </div>
        {% endif %}

        {% if form.filter is defined %}
            {{ form_row(form.filter) }}
        {% endif %}
    '''
}
