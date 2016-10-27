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
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Config {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.x')) configController.formatForDB else configController.formatForDB.toFirstUpper) + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'
        var fileName = 'config' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            println('Generating config template')
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'config.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, configView)
        }
    }

    def private configView(Application it) '''
        «IF targets('1.3.x')»
            {* purpose of this template: module configuration page *}
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
                    <h2>{$templateTitle}</h2>
                «ENDIF»

                {form cssClass='z-form'}
                    {* add validation summary and a <div> element for styling the form *}
                    {«appName.formatForDB»FormFrame}
                        {formsetinitialfocus inputId='«getSortedVariableContainers.head.vars.head.name.formatForCode»'}
                        «IF hasMultipleConfigSections»
                            {formtabbedpanelset}
                                «configSections»
                            {/formtabbedpanelset}
                        «ELSE»
                            «configSections»
                        «ENDIF»

                        <div class="z-buttons z-formbuttons">
                            {formbutton commandName='save' __text='Update configuration' class='z-bt-save'}
                            {formbutton commandName='cancel' __text='Cancel' class='z-bt-cancel'}
                        </div>
                    {/«appName.formatForDB»FormFrame}
                {/form}
            </div>
            {include file='«configController.formatForDB»/footer.tpl'}
            «IF !getAllVariables.filter[null !== documentation && documentation != ''].empty || hasImageFields»
                <script type="text/javascript">
                /* <![CDATA[ */
                    «IF hasImageFields»
                        function «prefix.formatForDB»ToggleShrinkSettings(fieldName)
                        {
                            $$('.shrinkdimension-' + fieldName.toLowerCase()).each(function(elem, index) {
                                if ($('enableShrinkingFor' + fieldName).checked == true) {
                                    elem.removeClassName('z-hide');
                                } else {
                                    elem.addClassName('z-hide');
                                }
                            });
                        }

                    «ENDIF»
                    document.observe('dom:loaded', function() {
                        «IF !getAllVariables.filter[null !== documentation && documentation != ''].empty»
                            Zikula.UI.Tooltips($$('.«appName.toLowerCase»-form-tooltips'));
                        «ENDIF»
                        «IF hasImageFields»
                            $$('.shrink-enabler').each(function(elem, index) {
                                elem.observe('click', «prefix.formatForDB»ToggleShrinkSettings(elem.getAttribute('id').replace('enableShrinkingFor', '')));
                                elem.observe('keyup', «prefix.formatForDB»ToggleShrinkSettings(elem.getAttribute('id').replace('enableShrinkingFor', '')));
                                «prefix.formatForDB»ToggleShrinkSettings(elem.getAttribute('id').replace('enableShrinkingFor', ''));
                            });
                        «ENDIF»
                    });
                /* ]]> */
                </script>
            «ENDIF»
        «ELSE»
            {# purpose of this template: module configuration page #}
            {% extends '«appName»::adminBase.html.twig' %}
            {% block title __('Settings') %}
            {% block admin_page_icon 'wrench' %}
            {% block content %}
                <div class="«appName.toLowerCase»-config">
                    {% form_theme form with [
                        '@«appName»/Form/bootstrap_3.html.twig',
                        'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
                    ] %}
                    {{ form_start(form) }}
                    «IF hasMultipleConfigSections»
                        <ul class="nav nav-pills">
                        «FOR varContainer : getSortedVariableContainers»
                            {% set tabTitle = __('«varContainer.name.formatForDisplayCapital»') %}
                            <li«IF varContainer == getSortedVariableContainers.head» class="active"«ENDIF» data-toggle="pill"><a href="#tab«varContainer.sortOrder»" title="{{ tabTitle|e('html_attr') }}" role="tab" data-toggle="tab">{{ tabTitle }}</a></li>
                        «ENDFOR»
                        </ul>

                        {{ form_errors(form) }}
                        <div class="tab-content">
                            «configSections»
                        </div>
                    «ELSE»
                        {{ form_errors(form) }}
                        «configSections»
                    «ENDIF»

                    <div class="form-group">
                        <div class="col-sm-offset-3 col-sm-9">
                            {{ form_widget(form.save) }}
                            {{ form_widget(form.cancel) }}
                        </div>
                    </div>
                    {{ form_end(form) }}
                </div>
            {% endblock %}
        «ENDIF»
    '''

    def private configSections(Application it) '''
        «FOR varContainer : getSortedVariableContainers»«varContainer.configSection(it, varContainer == getSortedVariableContainers.head)»«ENDFOR»
    '''

    def private configSection(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        «IF app.hasMultipleConfigSections»
            «IF app.targets('1.3.x')»
                {gt text='«name.formatForDisplayCapital»' assign='tabTitle'}
                {formtabbedpanel title=$tabTitle}
                    «configSectionBody(app, isPrimaryVarContainer)»
                {/formtabbedpanel}
            «ELSE»
                {% set tabTitle = __('«name.formatForDisplayCapital»') %}
                <div role="tabpanel" class="tab-pane fade«IF isPrimaryVarContainer» in active«ENDIF»" id="tab«sortOrder»">
                    «configSectionBody(app, isPrimaryVarContainer)»
                </div>
            «ENDIF»
        «ELSE»
            «IF app.targets('1.3.x')»
                {gt text='«name.formatForDisplayCapital»' assign='tabTitle'}
            «ELSE»
                {% set tabTitle = __('«name.formatForDisplayCapital»') %}
            «ENDIF»
            «configSectionBody(app, isPrimaryVarContainer)»
        «ENDIF»
    '''

    def private configSectionBody(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        <fieldset>
            «IF app.targets('1.3.x')»
                <legend>{$tabTitle}</legend>

                «IF null !== documentation && documentation != ''»
                    <p class="z-confirmationmsg">{gt text='«documentation.replace("'", "")»'|nl2br}</p>
                «ELSEIF !app.hasMultipleConfigSections || isPrimaryVarContainer»
                    <p class="z-confirmationmsg">{gt text='Here you can manage all basic settings for this application.'}</p>
                «ENDIF»
            «ELSE»
                <legend>{{ tabTitle }}</legend>

                «IF null !== documentation && documentation != ''»
                    <p class="alert alert-info">{{ __('«documentation.replace("'", "")»')|nl2br }}</p>
                «ELSEIF !app.hasMultipleConfigSections || isPrimaryVarContainer»
                    <p class="alert alert-info">{{ __('Here you can manage all basic settings for this application.') }}</p>
                «ENDIF»
            «ENDIF»

            «FOR modvar : vars»«modvar.formRow»«ENDFOR»
        </fieldset>
    '''

    def private formRow(Variable it) '''
        «IF container.application.targets('1.3.x')»
            <div class="z-formrow«IF isShrinkDimensionField» shrinkdimension-«name.formatForCode.replace('shrinkWidth', '').replace('shrinkHeight', '').toLowerCase»«ENDIF»">
                «IF null !== documentation && documentation != ""»
                    {gt text='«documentation.replace("'", '"')»' assign='toolTip'}
                «ENDIF»
                {formlabel for='«name.formatForCode»' __text='«name.formatForDisplayCapital»' cssClass='«IF null !== documentation && documentation != ''»«container.application.appName.toLowerCase»-form-tooltips «ENDIF»'«IF null !== documentation && documentation != ''» title=$toolTip«ENDIF»}
                «IF isShrinkDimensionField»
                    <div>
                        «inputFieldLegacy» {gt text='pixels'}
                    </div>
                «ELSE»
                    «inputFieldLegacy»
                «ENDIF»
            </div>
        «ELSE»
            {{ form_row(form.«name.formatForCode») }}
        «ENDIF»
    '''

    def private isShrinkDimensionField(Variable it) {
        name.formatForCode.startsWith('shrinkWidth') || name.formatForCode.startsWith('shrinkHeight')
    }

    def private dispatch inputFieldLegacy(Variable it) '''
        {formtextinput id='«name.formatForCode»' group='config' maxLength=255 __title='Enter the «name.formatForDisplay».'}
    '''

    def private dispatch inputFieldLegacy(IntVar it) '''
        «IF isUserGroupSelector»
            {formdropdownlist id='«name.formatForCode»' group='config' __title='Choose the «name.formatForDisplay»'}
        «ELSE»
            «IF isShrinkDimensionField»
                {formintinput id='«name.formatForCode»' group='config' size=8 maxLength=4 __title='«documentation.formatForDisplay»'}
            «ELSE»
                {formintinput id='«name.formatForCode»' group='config' maxLength=255 __title='Enter the «name.formatForDisplay». Only digits are allowed.'}
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch inputFieldLegacy(TextVar it) '''
        {formtextinput id='«name.formatForCode»' group='config'«IF maxLength > 0 || !multiline» maxLength=«IF maxLength > 0»«maxLength»«ELSE»255«ENDIF»«ENDIF» __title='Enter the «name.formatForDisplay».'«IF multiline» textMode='multiline' rows='6«/*8*/»' cols='50'«ENDIF»}
    '''

    def private dispatch inputFieldLegacy(BoolVar it) '''
        {formcheckbox id='«name.formatForCode»' group='config'«IF name.formatForCode.startsWith('enableShrinkingFor')» cssClass='shrink-enabler'«ENDIF»}
    '''

    def private dispatch inputFieldLegacy(ListVar it) '''
        «IF multiple»
            {formcheckboxlist id='«name.formatForCode»' group='config' repeatColumns=2 __title='Choose the «name.formatForDisplay»'}
        «ELSE»
            {formdropdownlist id='«name.formatForCode»' group='config'«IF multiple» selectionMode='multiple'«ENDIF» __title='Choose the «name.formatForDisplay»'}
        «ENDIF»
    '''
}
