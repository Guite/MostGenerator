package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeSingleView {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
    	val templatePath = appName.getAppSourcePath + 'templates/contenttype/'
        fsa.generateFile(templatePath + 'item_edit.tpl', editTemplate)
    }

    def private editTemplate(Application it) '''
        {* Purpose of this template: edit view of specific item detail view content type *}

        <div class="z-formrow">
            {formlabel for='«appName»_objecttype' __text='Object type'}
            {«appName.formatForDB»SelectorObjectTypes assign='allObjectTypes'}
            {formdropdownlist id='«appName»_objecttype' dataField='objectType' group='data' mandatory=true items=$allObjectTypes}
        </div>

        <div style="margin-left: 80px">
            <div{* class="z-formrow"*}>
                {«appName.formatForDB»SelectorItems id='id' group='data' objectType=$objectType}
                «/* EVENTUELL PRO OBJECTTYPE */»
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
