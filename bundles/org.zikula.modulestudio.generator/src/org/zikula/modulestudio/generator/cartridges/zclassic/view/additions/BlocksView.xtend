package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlocksView {
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Block/'
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
        {# Purpose of this template: Edit block for generic item list #}
        {{ form_row(form.objectType) }}
        «IF hasCategorisableEntities»
            {% if is_categorisable %}
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
        <p class="col-sm-offset-3 help-block small"><a class="fa fa-filter" data-toggle="modal" data-target="#filterSyntaxModal">{{ __('Show syntax examples') }}</a></p>

        {{ include('@«appName»/includeFilterSyntaxDialog.html.twig') }}
        «editTemplateJs»
    '''

    def private editTemplateJs(Application it) '''
        {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap.min.css')) }}
        {{ pageAddAsset('stylesheet', asset('bootstrap/css/bootstrap-theme.min.css')) }}
        {{ pageAddAsset('javascript', asset('bootstrap/js/bootstrap.min.js')) }}
    '''
}
