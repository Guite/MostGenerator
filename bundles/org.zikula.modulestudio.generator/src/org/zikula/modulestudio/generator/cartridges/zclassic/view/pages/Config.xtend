package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
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
        val templatePath = getViewPath + configController.formatForDB.toFirstUpper + '/'
        val templateExtension = '.html.twig'
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
        «IF hasImageFields»
            {% block footer %}
                {{ parent() }}

                <script type="text/javascript">
                /* <![CDATA[ */
                    ( function($) {
                        function «prefix.formatForDB»ToggleShrinkSettings(fieldName) {
                            var idSuffix = fieldName.replace('«appName.toLowerCase»_appsettings_', '');
                            $('#shrinkDetails' + idSuffix).toggleClass('hidden', !$('#«appName.toLowerCase»_appsettings_enableShrinkingFor' + idSuffix).prop('checked'));
                        }

                        $(document).ready(function() {
                            $('.shrink-enabler').each(function (index) {
                                $(this).bind('click keyup', function (event) {
                                    «prefix.formatForDB»ToggleShrinkSettings($(this).attr('id').replace('enableShrinkingFor', ''));
                                });
                                «prefix.formatForDB»ToggleShrinkSettings($(this).attr('id').replace('enableShrinkingFor', ''));
                            });
                        });
                    })(jQuery);
                /* ]]> */
                </script>
            {% endblock %}
        «ENDIF»
    '''

    def private configSections(Application it) '''
        «FOR varContainer : getSortedVariableContainers»«varContainer.configSection(it, varContainer == getSortedVariableContainers.head)»«ENDFOR»
    '''

    def private configSection(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        «IF app.hasMultipleConfigSections»
            {% set tabTitle = __('«name.formatForDisplayCapital»') %}
            <div role="tabpanel" class="tab-pane fade«IF isPrimaryVarContainer» in active«ENDIF»" id="tab«sortOrder»">
                «configSectionBody(app, isPrimaryVarContainer)»
            </div>
        «ELSE»
            {% set tabTitle = __('«name.formatForDisplayCapital»') %}
            «configSectionBody(app, isPrimaryVarContainer)»
        «ENDIF»
    '''

    def private configSectionBody(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        <fieldset>
            <legend>{{ tabTitle }}</legend>

            «IF null !== documentation && documentation != ''»
                <p class="alert alert-info">{{ __('«documentation.replace("'", "")»')|nl2br }}</p>
            «ELSEIF !app.hasMultipleConfigSections || isPrimaryVarContainer»
                <p class="alert alert-info">{{ __('Here you can manage all basic settings for this application.') }}</p>
            «ENDIF»

            «FOR modvar : vars»«modvar.formRow»«ENDFOR»
        </fieldset>
    '''

    def private formRow(Variable it) '''
        «IF name.formatForCode.startsWith('shrinkWidth')»
            <div id="shrinkDetails«name.formatForCode.replace('shrinkWidth', '').formatForCodeCapital»">
        «ENDIF»
        {{ form_row(form.«name.formatForCode») }}
        «IF name.formatForCode.startsWith('shrinkHeight')»
            </div>
        «ENDIF»
    '''
}
