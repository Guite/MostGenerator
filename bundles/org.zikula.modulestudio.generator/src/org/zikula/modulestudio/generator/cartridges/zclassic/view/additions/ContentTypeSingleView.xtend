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
            <div class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»">
                {formlabel for='«appName.toFirstLower»ObjectType' __text='Object type'«IF !targets('1.3.x')» cssClass='col-sm-3 control-label'«ENDIF»}
                «IF !targets('1.3.x')»
                    <div class="col-sm-9">
                «ENDIF»
                    {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
                    {formdropdownlist id='«appName.toFirstLower»ObjectType' dataField='objectType' group='data' mandatory=true items=$allObjectTypes«IF !targets('1.3.x')» cssClass='form-control'«ENDIF»}
                    <span class="«IF targets('1.3.x')»z-sub z-formnote«ELSE»help-block«ENDIF»">{gt text='If you change this please save the element once to reload the parameters below.'}</span>
                «IF !targets('1.3.x')»
                    </div>
                «ENDIF»
            </div>
            <div{* class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»"*}>
                <p>{gt text='Please select your item here. You can resort the dropdown list and reduce it\'s entries by applying filters. On the right side you will see a preview of the selected entry.'}</p>
                {«appName.formatForDB»ItemSelector id='id' group='data' objectType=$objectType}«/* MAYBE PER OBJECTTYPE */»
            </div>

            <div{* class="«IF targets('1.3.x')»z-formrow«ELSE»form-group«ENDIF»"*}>
                {formradiobutton id='linkButton' value='link' dataField='displayMode' group='data' mandatory=1}
                {formlabel for='linkButton' __text='Link to object'}
                {formradiobutton id='embedButton' value='embed' dataField='displayMode' group='data' mandatory=1}
                {formlabel for='embedButton' __text='Embed object display'}
            </div>
        </div>
    '''
}
