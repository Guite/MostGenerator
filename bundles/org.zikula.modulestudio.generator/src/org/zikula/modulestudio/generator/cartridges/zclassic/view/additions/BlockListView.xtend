package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockListView {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Block/'
        if (!generateListContentType || targets('2.0')) {
            new CommonIntegrationTemplates().generate(it, fsa, templatePath)
        }
        val templateExtension = '.html.twig'
        var fileName = 'itemlist' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, displayTemplate)
        }
        fileName = 'itemlist_modify' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'itemlist_modify.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    def private displayTemplate(Application it) '''
        {# Purpose of this template: Display items within a block (fallback template) #}
        Default block for generic item list.
    '''

    def private editTemplate(Application it) '''
        {# Purpose of this template: Edit block for generic item list view #}
        {{ form_row(form.objectType) }}
        «IF hasCategorisableEntities»
            {% if form.categories is defined %}
                {{ form_row(form.categories) }}
            {% endif %}
        «ENDIF»
        {{ form_row(form.sorting) }}
        {{ form_row(form.amount) }}

        {{ form_row(form.template) }}
        <div id="customTemplateArea" data-switch="zikulablocksmodule_block[properties][template]" data-switch-value="custom">
            {{ form_row(form.customTemplate) }}
        </div>

        {{ form_row(form.filter) }}
        «editTemplateJs»
    '''

    def private editTemplateJs(Application it) '''
        {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap.min.css')) }}
        {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap-theme.min.css')) }}
        {{ pageAddAsset('javascript', asset('bootstrap/js/bootstrap.min.js')) }}
    '''
}
