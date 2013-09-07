package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeSingleView {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) 'contenttype' else 'ContentType') + '/'
        fsa.generateFile(templatePath + 'item_edit.tpl', editTemplate)
    }

    def private editTemplate(Application it) '''
        {* Purpose of this template: edit view of specific item detail view content type *}

        <div style="margin-left: 80px">
            <div class="z-formrow">
                {formlabel for='«appName»_objecttype' __text='Object type'}
                {«appName.formatForDB»ObjectTypeSelector assign='allObjectTypes'}
                {formdropdownlist id='«appName»_objecttype' dataField='objectType' group='data' mandatory=true items=$allObjectTypes}
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
}
