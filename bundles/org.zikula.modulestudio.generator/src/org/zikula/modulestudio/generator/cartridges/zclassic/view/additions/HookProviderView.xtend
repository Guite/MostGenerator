package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.HookProviderMode
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookProviderView {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasFormAwareHookProviders && !hasUiHooksProviders) {
            return
        }

        val templatePath = getViewPath + 'Email/'
        val templateExtension = '.html.twig'

        for (entity : getAllEntities) {
            if (entity.formAwareHookProvider != HookProviderMode.DISABLED) {
                var fileName = 'edit' + entity.name.formatForCodeCapital + 'Form' + templateExtension
                if (!shouldBeSkipped(templatePath + fileName)) {
                    if (shouldBeMarked(templatePath + fileName)) {
                        fileName = 'edit' + entity.name.formatForCodeCapital + 'Form.generated' + templateExtension
                    }
                    fsa.generateFile(templatePath + fileName, entity.formAwareEditTemplate)
                }
                fileName = 'delete' + entity.name.formatForCodeCapital + 'Form' + templateExtension
                if (!shouldBeSkipped(templatePath + fileName)) {
                    if (shouldBeMarked(templatePath + fileName)) {
                        fileName = 'delete' + entity.name.formatForCodeCapital + 'Form.generated' + templateExtension
                    }
                    fsa.generateFile(templatePath + fileName, entity.formAwareDeleteTemplate)
                }
            }
            if (entity.uiHooksProvider != HookProviderMode.DISABLED) {
                // TODO
            }
        }
    }

    def private formAwareEditTemplate(Entity it) '''
        {# purpose of this template: inner edit form included via form aware hooks #}
        {# should include as little formatting as possible #}
        {% for element in form.«application.appName.formatForDB»_hook_edit«name.formatForDB»form %}
            {{ form_row(element) }}
        {% endfor %}
    '''

    def private formAwareDeleteTemplate(Entity it) '''
        {# purpose of this template: inner delete form included via form aware hooks #}
        {# should include as little formatting as possible #}
        {% for element in form.«application.appName.formatForDB»_hook_delete«name.formatForDB»form %}
            {{ form_row(element) }}
        {% endfor %}
    '''
}
