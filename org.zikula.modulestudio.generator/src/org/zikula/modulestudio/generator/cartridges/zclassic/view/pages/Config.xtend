package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.BoolVar
import de.guite.modulestudio.metamodel.modulestudio.IntVar
import de.guite.modulestudio.metamodel.modulestudio.ListVar
import de.guite.modulestudio.metamodel.modulestudio.Variable
import de.guite.modulestudio.metamodel.modulestudio.Variables
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Config {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating config template')
        fsa.generateFile(getAppSourcePath + 'templates/' + configController.formatForDB + '/config.tpl', configView)
    }

    def private configView(Application it) '''
        {* purpose of this template: module configuration *}
        {include file='«configController.formatForDB»/header.tpl'}
        <div class="«appName.toLowerCase»-config">
            {gt text='Settings' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            «IF configController.formatForDB == 'admin'»
                <div class="z-admin-content-pagetitle">
                    {icon type='config' size='small' __alt='Settings'}
                    <h3>{$templateTitle}</h3>
                </div>
            «ELSE»
                <div class="z-frontendcontainer">
                    <h2>{$templateTitle}</h2>
            «ENDIF»

            {form cssClass='z-form'}
«/*            {formsetinitialfocus inputId='myelemid'}*/»

                {* add validation summary and a <div> element for styling the form *}
                {«appName.formatForDB»FormFrame}
                    {formsetinitialfocus inputId='«getSortedVariableContainers.head.vars.head.name.formatForCode»'}
                    «IF hasMultipleConfigSections»
                        {formtabbedpanelset}
                    «ENDIF»
                    «FOR varContainer : getSortedVariableContainers»«varContainer.configSection(hasMultipleConfigSections)»«ENDFOR»
                    «IF hasMultipleConfigSections»
                        {/formtabbedpanelset}
                    «ENDIF»

                    <div class="z-buttons z-formbuttons">
                        {formbutton commandName='save' __text='Update configuration' class='z-bt-save'}
                        {formbutton commandName='cancel' __text='Cancel' class='z-bt-cancel'}
                    </div>
                {/«appName.formatForDB»FormFrame}
            {/form}
            «IF configController.formatForDB == 'admin'»
            «ELSE»
                </div>
            «ENDIF»
        </div>
        {include file='«configController.formatForDB»/footer.tpl'}
        «IF !getAllVariables.filter(e|e.documentation != null && e.documentation != '').isEmpty»
            <script type="text/javascript">
            /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                    Zikula.UI.Tooltips($$('.«appName.formatForDB»FormTooltips'));
                });
            /* ]]> */
            </script>
        «ENDIF»
    '''

    def private configSection(Variables it, Boolean hasMultipleConfigSections) '''
        «IF hasMultipleConfigSections»
            {gt text='«name.formatForDisplayCapital»' assign='tabTitle'}
            {formtabbedpanel title=$tabTitle}
        «ENDIF»
        <fieldset>
            «IF hasMultipleConfigSections»
                «IF documentation != null && documentation != ''»
                    <legend>{gt text='«documentation.replaceAll("'", "")»'}</legend>
                «ELSE»
                    <legend>{gt text='«name.formatForDisplayCapital»'}</legend>
                «ENDIF»
            «ELSE»
                «IF documentation != null && documentation != ''»
                    <legend>{gt text='«documentation.replaceAll("'", "")»'}</legend>
                «ELSE»
                    <legend>{gt text='Here you can manage all basic settings for this application.'}</legend>
                «ENDIF»
            «ENDIF»

            «FOR modvar : vars»«modvar.formRow»«ENDFOR»
        </fieldset>
        «IF hasMultipleConfigSections»
            {/formtabbedpanel}
        «ENDIF»
    '''

    def private formRow(Variable it) '''
        <div class="z-formrow">
            «IF documentation != null && documentation != ""»
                {gt text='«documentation.replaceAll("'", '"')»' assign='toolTip'}
            «ENDIF»
            {formlabel for='«name.formatForCode»' __text='«name.formatForDisplayCapital»'«IF documentation != null && documentation != ''» class='«container.container.application.appName.formatForDB»FormTooltips' title=$toolTip«ENDIF»}
            «inputField»
        </div>
    '''

    def private dispatch inputField(Variable it) '''
        {formtextinput id='«name.formatForCode»' group='config' maxLength=255 __title='Enter this setting.'}
    '''

    def private dispatch inputField(IntVar it) '''
        {formintinput id='«name.formatForCode»' group='config' maxLength=255 __title='Enter this setting. Only digits are allowed.'}
    '''

    def private dispatch inputField(BoolVar it) '''
        {formcheckbox id='«name.formatForCode»' group='config'}
    '''

    def private dispatch inputField(ListVar it) '''
        «IF multiple»
            {formcheckboxlist id='«name.formatForCode»' group='config' repeatColumns=2}
        «ELSE»
            {formdropdownlist id='«name.formatForCode»' group='config'«IF multiple» selectionMode='multiple'«ENDIF»}
        «ENDIF»
    '''
}
