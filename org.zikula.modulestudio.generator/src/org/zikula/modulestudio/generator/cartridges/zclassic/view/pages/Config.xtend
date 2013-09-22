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
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating config template')
        val templatePath = getViewPath + (if (targets('1.3.5')) configController.formatForDB else configController.formatForDB.toFirstUpper) + '/'
        fsa.generateFile(templatePath + 'config.tpl', configView)
    }

    def private configView(Application it) '''
        {* purpose of this template: module configuration *}
        {include file='«IF targets('1.3.5')»«configController.formatForDB»«ELSE»«configController.formatForDB.toFirstUpper»«ENDIF»/header.tpl'}
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

            {form cssClass='«IF targets('1.3.5')»z-form«ELSE»form-horizontal«ENDIF»'«IF !targets('1.3.5')» role='form'«ENDIF»}
«/*            {formsetinitialfocus inputId='myelemid'}*/»

                {* add validation summary and a <div> element for styling the form *}
                {«appName.formatForDB»FormFrame}
                    {formsetinitialfocus inputId='«getSortedVariableContainers.head.vars.head.name.formatForCode»'}
                    «IF hasMultipleConfigSections»
                        {formtabbedpanelset}
                    «ENDIF»
                    «FOR varContainer : getSortedVariableContainers»«varContainer.configSection(it, hasMultipleConfigSections, varContainer == getSortedVariableContainers.head)»«ENDFOR»
                    «IF hasMultipleConfigSections»
                        {/formtabbedpanelset}
                    «ENDIF»

                    <div class="«IF targets('1.3.5')»z-buttons z-formbuttons«ELSE»form-group form-buttons«ENDIF»">
                    «IF !targets('1.3.5')»
                        <div class="col-lg-offset-3 col-lg-9">
                    «ENDIF»
                        {formbutton commandName='save' __text='Update configuration' class='«IF targets('1.3.5')»z-bt-save«ELSE»btn btn-success«ENDIF»'}
                        {formbutton commandName='cancel' __text='Cancel' class='«IF targets('1.3.5')»z-bt-cancel«ELSE»btn btn-default«ENDIF»'}
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                    </div>
                {/«appName.formatForDB»FormFrame}
            {/form}
            «IF configController.formatForDB == 'admin'»
            «ELSE»
                </div>
            «ENDIF»
        </div>
        {include file='«IF targets('1.3.5')»«configController.formatForDB»«ELSE»«configController.formatForDB.toFirstUpper»«ENDIF»/footer.tpl'}
        «IF !getAllVariables.filter[documentation !== null && documentation != ''].empty»
            <script type="text/javascript">
            /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                    Zikula.UI.Tooltips($$('.«appName.formatForDB»FormTooltips'));
                });
            /* ]]> */
            </script>
        «ENDIF»
    '''

    def private configSection(Variables it, Application app, Boolean hasMultipleConfigSections, Boolean isPrimaryVarContainer) '''
        «IF hasMultipleConfigSections»
            {gt text='«name.formatForDisplayCapital»' assign='tabTitle'}
            {formtabbedpanel title=$tabTitle}
        «ENDIF»
        <fieldset>
            <legend>«name.formatForDisplayCapital»</legend>

            «IF documentation !== null && documentation != ''»
                <p class="«IF app.targets('1.3.5')»z-confirmationmsg«ELSE»alert alert-info«ENDIF»">{gt text='«documentation.replaceAll("'", "")»'|nl2br}</p>
            «ELSEIF !hasMultipleConfigSections || isPrimaryVarContainer»
                <p class="«IF app.targets('1.3.5')»z-confirmationmsg«ELSE»alert alert-info«ENDIF»">{gt text='Here you can manage all basic settings for this application.'}</p>
            «ENDIF»

            «FOR modvar : vars»«modvar.formRow»«ENDFOR»
        </fieldset>
        «IF hasMultipleConfigSections»
            {/formtabbedpanel}
        «ENDIF»
    '''

    def private formRow(Variable it) '''
        <div class="«IF container.container.application.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            «IF documentation !== null && documentation != ""»
                {gt text='«documentation.replaceAll("'", '"')»' assign='toolTip'}
            «ENDIF»
            {formlabel for='«name.formatForCode»' __text='«name.formatForDisplayCapital»' cssClass='«IF documentation !== null && documentation != ''»«container.container.application.appName.formatForDB»FormTooltips «ENDIF»«IF !container.container.application.targets('1.3.5')» col-lg-3 control-label«ENDIF»'«IF documentation !== null && documentation != ''» title=$toolTip«ENDIF»}
            «IF !container.container.application.targets('1.3.5')»
                <div class="col-lg-9">
            «ENDIF»
                «inputField»
            «IF !container.container.application.targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private dispatch inputField(Variable it) '''
        {formtextinput id='«name.formatForCode»' group='config' maxLength=255 __title='Enter the «name.formatForDisplay».'«IF !container.container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
    '''

    def private dispatch inputField(IntVar it) '''
        {formintinput id='«name.formatForCode»' group='config' maxLength=255 __title='Enter the «name.formatForDisplay». Only digits are allowed.'«IF !container.container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
    '''

    def private dispatch inputField(BoolVar it) '''
        {formcheckbox id='«name.formatForCode»' group='config'}
    '''

    def private dispatch inputField(ListVar it) '''
        «IF multiple»
            {formcheckboxlist id='«name.formatForCode»' group='config' repeatColumns=2 __title='Choose the «name.formatForDisplay»'«IF !container.container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ELSE»
            {formdropdownlist id='«name.formatForCode»' group='config'«IF multiple» selectionMode='multiple'«ENDIF» __title='Choose the «name.formatForDisplay»'«IF !container.container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ENDIF»
    '''
}
