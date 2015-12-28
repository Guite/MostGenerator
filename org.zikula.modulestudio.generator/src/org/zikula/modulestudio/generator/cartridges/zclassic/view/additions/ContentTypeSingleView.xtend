package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeSingleView {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.x')) 'contenttype' else 'ContentType') + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'
        var fileName = 'item_edit' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'item_edit.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) editTemplateLegacy else editTemplate)
        }
    }

    def private editTemplateLegacy(Application it) '''
        {* Purpose of this template: edit view of specific item detail view content type *}
        <div style="margin-left: 80px">
            <div class="z-formrow">
                {formlabel for='«appName.toFirstLower»ObjectType' __text='Object type'}
                {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
                {formdropdownlist id='«appName.toFirstLower»ObjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypes}
                <span class="z-sub z-formnote">{gt text='If you change this please save the element once to reload the parameters below.'}</span>
            </div>
            <div{* class="z-formrow"*}>
                <p>{gt text='Please select your item here. You can resort the dropdown list and reduce it\'s entries by applying filters. On the right side you will see a preview of the selected entry.'}</p>
                {«appName.formatForDB»ItemSelector id='id' group='data' objectType=$objectType}«/* MAYBE PER OBJECTTYPE */»
            </div>

            <div{* class="z-formrow"*}>
                {formradiobutton id='linkButton' value='link' dataField='displayMode' group='data' mandatory=1}
                {formlabel for='linkButton' __text='Link to object'}
                {formradiobutton id='embedButton' value='embed' dataField='displayMode' group='data' mandatory=1}
                {formlabel for='embedButton' __text='Embed object display'}
            </div>
        </div>
    '''

    def private editTemplate(Application it) '''
        {# Purpose of this template: edit view of specific item detail view content type #}
        «/* TODO migrate to Symfony forms #416 */»
        <div style="margin-left: 80px">
            <div class="form-group">
                {formlabel for='«appName.toFirstLower»ObjectType' __text='Object type' cssClass='col-sm-3 control-label'}
                <div class="col-sm-9">
                    {% set allObjectTypes = «appName.formatForDB»_objectTypeSelector() %}
                    {formdropdownlist id='«appName.toFirstLower»ObjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypes cssClass='form-control'}
                    <span class="help-block">{{ __('If you change this please save the element once to reload the parameters below.') }}</span>
                </div>
            </div>
            <div{* class="form-group"*}>
                <p>{{ __('Please select your item here. You can resort the dropdown list and reduce it\'s entries by applying filters. On the right side you will see a preview of the selected entry.') }}</p>
                {«appName.formatForDB»ItemSelector id='id' group='data' objectType=$objectType}«/* MAYBE PER OBJECTTYPE */»
            </div>

            <div{* class="form-group"*}>
                {formradiobutton id='linkButton' value='link' dataField='displayMode' group='data' mandatory=1}
                {formlabel for='linkButton' __text='Link to object'}
                {formradiobutton id='embedButton' value='embed' dataField='displayMode' group='data' mandatory=1}
                {formlabel for='embedButton' __text='Embed object display'}
            </div>
        </div>
    '''
}
