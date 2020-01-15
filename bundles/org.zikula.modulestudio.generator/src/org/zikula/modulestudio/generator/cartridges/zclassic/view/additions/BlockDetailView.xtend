package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockDetailView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

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
        {{ form_row(form.objectType) }}
        {{ form_row(form.id) }}
        {{ form_row(form.customTemplate) }}
    '''
}
