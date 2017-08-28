package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeSingleView {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'ContentType/'
        // content type editing is not ready for Twig yet
        var fileName = 'item_edit.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'item_edit.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, editTemplate)
        }
    }

    def private editTemplate(Application it) '''
        {* Purpose of this template: edit view of specific item detail view content type *}

        <div style="margin-left: 80px">
            «IF getAllEntities.size > 1»
                <div class="form-group">
                    {formlabel for='«appName.toFirstLower»ObjectType' __text='Object type'«editLabelClass»}
                    <div class="col-sm-9">
                        {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
                        {formdropdownlist id='«appName.toFirstLower»ObjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypes«editInputClass»}
                        <span class="help-block">{gt text='If you change this please save the element once to reload the parameters below.'}</span>
                    </div>
                </div>
            «ENDIF»
            <div{* class="form-group"*}>
                <p>{gt text='Please select your item here. You can resort the dropdown list and reduce it\'s entries by applying filters. On the right side you will see a preview of the selected entry.' domain='«appName.formatForDB»'}</p>
                {«appName.formatForDB»ItemSelector id='id' group='data' objectType=$objectType}«/* MAYBE PER OBJECTTYPE */»
            </div>

            <div{* class="form-group"*}>
                {gt text='Link to object' assign='displayModeLabel'}
                {formradiobutton id='linkButton' value='link' dataField='displayMode' group='data' mandatory=1}
                {formlabel for='linkButton' text=$displayModeLabel}
                {gt text='Embed object display' assign='displayModeLabel'}
                {formradiobutton id='embedButton' value='embed' dataField='displayMode' group='data' mandatory=1}
                {formlabel for='embedButton' text=$displayModeLabel}
            </div>

            <div{* class="form-group"*}>
                {gt text='Custom template' domain='«appName.formatForDB»' assign='customTemplateLabel'}
                {formlabel for='«appName.toFirstLower»CustomTemplate' text=$customTemplateLabel«editLabelClass»}
                <div class="col-sm-9">
                    {formtextinput id='«appName.toFirstLower»CustomTemplate' dataField='customTemplate' group='data' mandatory=false maxLength=80«editInputClass»}
                    <span class="help-block">{gt text='Example' domain='«appName.formatForDB»'}: <em>displaySpecial.html.twig</em></span>
                    <span class="help-block">{gt text='Needs to be located in the "External/YourEntity/" directory.' domain='«appName.formatForDB»'}</span>
                </div>
            </div>
        </div>
    '''

    def private editLabelClass() ''' cssClass='col-sm-3 control-label'«''»'''
    def private editInputClass() ''' cssClass='form-control'«''»'''
}
