package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class ContentTypeDetailView {

    extension NamingExtensions = new NamingExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'ContentType/'

        var fileName = 'itemEdit.html.twig'
        fsa.generateFile(templatePath + fileName, editTemplate)
    }

    def private editTemplate(Application it) '''
        {# purpose of this template: edit view of specific item detail view content type #}
        {% if form.objectType is defined %}
            {{ form_row(form.objectType) }}
        {% endif %}
        {% if form.id is defined %}
            {{ form_row(form.id) }}
        {% endif %}
        {% if form.displayMode is defined %}
            {{ form_row(form.displayMode) }}
        {% endif %}
        {% if form.customTemplate is defined %}
            {{ form_row(form.customTemplate) }}
        {% endif %}
    '''
}
