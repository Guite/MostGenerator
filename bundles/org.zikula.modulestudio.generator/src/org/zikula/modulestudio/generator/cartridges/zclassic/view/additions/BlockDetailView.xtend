package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class BlockDetailView {

    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateDetailBlock || !hasDisplayActions) {
            return
        }
        val templatePath = getViewPath + 'Block/'
        var fileName = 'item_modify.html.twig'
        fsa.generateFile(templatePath + fileName, editTemplate)
    }

    def private editTemplate(Application it) '''
        {# purpose of this template: Edit block for generic item detail view #}
        {% if form.objectType|default %}
            {{ form_row(form.objectType) }}
        {% endif %}
        {% if form.id|default %}
            {{ form_row(form.id) }}
        {% endif %}
        {% if form.customTemplate|default %}
            {{ form_row(form.customTemplate) }}
        {% endif %}
    '''
}
