package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.BoolVar
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.ListVar
import de.guite.modulestudio.metamodel.TextVar
import de.guite.modulestudio.metamodel.Variable
import de.guite.modulestudio.metamodel.Variables
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Config {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) configController.formatForDB else configController.formatForDB.toFirstUpper) + '/'
        var fileName = 'config.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            println('Generating config template')
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'config.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, configView)
        }
    }

    def private configView(Application it) '''
        {* purpose of this template: module configuration *}
        {include file='«IF targets('1.3.5')»«configController.formatForDB»«ELSE»«configController.formatForDB.toFirstUpper»«ENDIF»/header.tpl'}
        <div class="«appName.toLowerCase»-config">
            {gt text='Settings' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            «IF configController.formatForDB == 'admin'»
                «IF targets('1.3.5')»
                    <div class="z-admin-content-pagetitle">
                        {icon type='config' size='small' __alt='Settings'}
                        <h3>{$templateTitle}</h3>
                    </div>
                «ELSE»
                    <h3>
                        <span class="fa fa-wrench"></span>
                        {$templateTitle}
                    </h3>
                «ENDIF»
            «ELSE»
                <h2>{$templateTitle}</h2>
            «ENDIF»

            {form cssClass='«IF targets('1.3.5')»z-form«ELSE»form-horizontal«ENDIF»'«IF !targets('1.3.5')» role='form'«ENDIF»}
                {* add validation summary and a <div> element for styling the form *}
                {«appName.formatForDB»FormFrame}
                    {formsetinitialfocus inputId='«getSortedVariableContainers.head.vars.head.name.formatForCode»'}
                    «IF hasMultipleConfigSections && !targets('1.3.5')»
                        <ul class="nav nav-pills">
                        «FOR varContainer : getSortedVariableContainers»
                            {gt text='«varContainer.name.formatForDisplayCapital»' assign='tabTitle'}
                            <li«IF varContainer == getSortedVariableContainers.head» class="active"«ENDIF» data-toggle="pill"><a href="#" title="{$tabTitle|replace:'"':''}">{$tabTitle}</a></li>
                        «ENDFOR»
                        </ul>

                    «ENDIF»
                    «IF hasMultipleConfigSections»
                        «IF targets('1.3.5')»
                            {formtabbedpanelset}
                                «configSections»
                            {/formtabbedpanelset}
                        «ELSE»
                            <div class="tab-content"»
                                «configSections»
                            </div>
                        «ENDIF»
                    «ELSE»
                        «configSections»
                    «ENDIF»

                    <div class="«IF targets('1.3.5')»z-buttons z-formbuttons«ELSE»form-group form-buttons«ENDIF»">
                    «IF !targets('1.3.5')»
                        <div class="col-sm-offset-3 col-sm-9">
                    «ENDIF»
                        {formbutton commandName='save' __text='Update configuration' class='«IF targets('1.3.5')»z-bt-save«ELSE»btn btn-success«ENDIF»'}
                        {formbutton commandName='cancel' __text='Cancel' class='«IF targets('1.3.5')»z-bt-cancel«ELSE»btn btn-default«ENDIF»'}
                    «IF !targets('1.3.5')»
                        </div>
                    «ENDIF»
                    </div>
                {/«appName.formatForDB»FormFrame}
            {/form}
        </div>
        {include file='«IF targets('1.3.5')»«configController.formatForDB»«ELSE»«configController.formatForDB.toFirstUpper»«ENDIF»/footer.tpl'}
        «IF !getAllVariables.filter[documentation !== null && documentation != ''].empty»
            <script type="text/javascript">
            /* <![CDATA[ */
                «IF targets('1.3.5')»
                    document.observe('dom:loaded', function() {
                        Zikula.UI.Tooltips($$('.«appName.toLowerCase»-form-tooltips'));
                    });
                «ELSE»
                    ( function($) {
                        $(document).ready(function() {
                            $('.«appName.toLowerCase»-form-tooltips').tooltip();
                        });
                    })(jQuery);
                «ENDIF»
            /* ]]> */
            </script>
        «ENDIF»
    '''

    def private configSections(Application it) '''
        «FOR varContainer : getSortedVariableContainers»«varContainer.configSection(it, varContainer == getSortedVariableContainers.head)»«ENDFOR»
    '''

    def private configSection(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        «IF app.hasMultipleConfigSections»
            «IF app.targets('1.3.5')»
                {gt text='«name.formatForDisplayCapital»' assign='tabTitle'}
                {formtabbedpanel title=$tabTitle}
                    «configSectionBody(app, isPrimaryVarContainer)»
                {/formtabbedpanel}
            «ELSE»
                {gt text='«name.formatForDisplayCapital»' assign='tabTitle'}
                <div class="tab-pane fade«IF isPrimaryVarContainer» in active«ENDIF»">
                    «configSectionBody(app, isPrimaryVarContainer)»
                </div>
            «ENDIF»
        «ELSE»
            {gt text='«name.formatForDisplayCapital»' assign='tabTitle'}
            «configSectionBody(app, isPrimaryVarContainer)»
        «ENDIF»
    '''

    def private configSectionBody(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        <fieldset>
            <legend>{$tabTitle}</legend>

            «IF documentation !== null && documentation != ''»
                <p class="«IF app.targets('1.3.5')»z-confirmationmsg«ELSE»alert alert-info«ENDIF»">{gt text='«documentation.replace("'", "")»'|nl2br}</p>
            «ELSEIF !app.hasMultipleConfigSections || isPrimaryVarContainer»
                <p class="«IF app.targets('1.3.5')»z-confirmationmsg«ELSE»alert alert-info«ENDIF»">{gt text='Here you can manage all basic settings for this application.'}</p>
            «ENDIF»

            «FOR modvar : vars»«modvar.formRow»«ENDFOR»
        </fieldset>
    '''

    def private formRow(Variable it) '''
        <div class="«IF container.application.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
            «IF documentation !== null && documentation != ""»
                {gt text='«documentation.replace("'", '"')»' assign='toolTip'}
            «ENDIF»
            {formlabel for='«name.formatForCode»' __text='«name.formatForDisplayCapital»' cssClass='«IF documentation !== null && documentation != ''»«container.application.appName.toLowerCase»-form-tooltips «ENDIF»«IF !container.application.targets('1.3.5')» col-sm-3 control-label«ENDIF»'«IF documentation !== null && documentation != ''» title=$toolTip«ENDIF»}
            «IF !container.application.targets('1.3.5')»
                <div class="col-sm-9">
            «ENDIF»
                «inputField»
            «IF !container.application.targets('1.3.5')»
                </div>
            «ENDIF»
        </div>
    '''

    def private dispatch inputField(Variable it) '''
        {formtextinput id='«name.formatForCode»' group='config' maxLength=255 __title='Enter the «name.formatForDisplay».'«IF !container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
    '''

    def private dispatch inputField(IntVar it) '''
        «IF isUserGroupSelector»
            {formdropdownlist id='«name.formatForCode»' group='config' __title='Choose the «name.formatForDisplay»'«IF !container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ELSE»
            {formintinput id='«name.formatForCode»' group='config' maxLength=255 __title='Enter the «name.formatForDisplay». Only digits are allowed.'«IF !container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ENDIF»
    '''

    def private dispatch inputField(TextVar it) '''
        {formtextinput id='«name.formatForCode»' group='config' maxLength=«IF maxLength > 0»«maxLength»«ELSE»255«ENDIF» __title='Enter the «name.formatForDisplay».'«IF !container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
    '''

    def private dispatch inputField(BoolVar it) '''
        {formcheckbox id='«name.formatForCode»' group='config'}
    '''

    def private dispatch inputField(ListVar it) '''
        «IF multiple»
            {formcheckboxlist id='«name.formatForCode»' group='config' repeatColumns=2 __title='Choose the «name.formatForDisplay»'«IF !container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ELSE»
            {formdropdownlist id='«name.formatForCode»' group='config'«IF multiple» selectionMode='multiple'«ENDIF» __title='Choose the «name.formatForDisplay»'«IF !container.application.targets('1.3.5')» cssClass='form-control'«ENDIF»}
        «ENDIF»
    '''
}
