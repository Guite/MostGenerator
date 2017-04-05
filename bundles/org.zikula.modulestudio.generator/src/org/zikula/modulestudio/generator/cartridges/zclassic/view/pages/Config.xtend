package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Variable
import de.guite.modulestudio.metamodel.Variables
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Config {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Config/'
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
                «IF hasMultipleConfigSections || hasImageFields || targets('1.5')»
                    <div class="zikula-bootstrap-tab-container">
                        <ul class="nav nav-tabs">
                        «FOR varContainer : getSortedVariableContainers»
                            {% set tabTitle = __('«varContainer.name.formatForDisplayCapital»') %}
                            <li«IF varContainer == getSortedVariableContainers.head || varContainer.isImageArea» class="«IF varContainer == getSortedVariableContainers.head»active«ENDIF»«IF varContainer.isImageArea» dropdown«ENDIF»"«ENDIF» role="presentation">
                                «IF varContainer.isImageArea»
                                    <a id="imagesTabDrop" class="dropdown-toggle" href="#" data-toggle="dropdown" aria-controls="imagesTabDropSections" aria-expanded="false">{{ tabTitle }}<span class="caret"></span></a>
                                    <ul id="imagesTabDropSections" class="dropdown-menu" aria-labelledby="imagesTabDrop">
                                    «FOR entity : getAllEntities.filter[hasImageFieldsEntity]»
                                        «FOR imageUploadField : entity.imageFieldsEntity»
                                            <li>
                                                <a id="images«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»Tab" href="#tabImages«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»" role="tab" data-toggle="tab" aria-controls="tabImages«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»">{{ __('«entity.nameMultiple.formatForDisplayCapital» «imageUploadField.name.formatForDisplay»') }}</a>
                                            </li>
                                        «ENDFOR»
                                    «ENDFOR»
                                    </ul>
                                «ELSE»
                                    <a id="vars«varContainer.sortOrder»Tab" href="#tab«varContainer.sortOrder»" title="{{ tabTitle|e('html_attr') }}" role="tab" data-toggle="tab">{{ tabTitle }}</a>
                                «ENDIF»
                            </li>
                        «ENDFOR»
                        «IF targets('1.5')»
                            {% set tabTitle = __('Workflows') %}
                            <li role="presentation">
                                <a id="workflowsTab" href="#tabWorkflows" title="{{ tabTitle|e('html_attr') }}" role="tab" data-toggle="tab">{{ tabTitle }}</a>
                            </li>
                        «ENDIF»
                        </ul>

                        {{ form_errors(form) }}
                        <div class="tab-content">
                            «configSections»
                        </div>
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
                {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Config.js')) }}
            {% endblock %}
        «ENDIF»
    '''

    def private configSections(Application it) '''
        «FOR varContainer : getSortedVariableContainers»«varContainer.configSection(it, varContainer == getSortedVariableContainers.head)»«ENDFOR»
        «IF targets('1.5')»
            <div role="tabpanel" class="tab-pane fade" id="tabWorkflows" aria-labelledby="workflowsTab">
                {% set tabTitle = __('Workflows') %}
                <fieldset>
                    <legend>{{ tabTitle }}</legend>

                    <p class="alert alert-info">{{ __('Here you can inspect and amend the existing workflows.') }}</p>

                    «FOR entity : getAllEntities»
                        <h4>{{ __('«entity.nameMultiple.formatForDisplayCapital»') }}</h4>
                        <p><a href="{{ path('zikula_workflow_editor_index', { 'workflow': '«appName.formatForDB»_«entity.workflow.textualName»' }) }}" title="{{ __('Edit workflow for «entity.nameMultiple.formatForDisplay»') }}" target="_blank"><i class="fa fa-cubes"></i> {{ __('Edit «entity.nameMultiple.formatForDisplay» workflow') }}</a>
                    «ENDFOR»
                </fieldset>
            </div>
        «ENDIF»
    '''

    def private configSection(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        «IF app.hasMultipleConfigSections || app.hasImageFields»
            «IF isImageArea»
                «configSectionBodyImages(app, isPrimaryVarContainer)»
            «ELSE»
                <div role="tabpanel" class="tab-pane fade«IF isPrimaryVarContainer» in active«ENDIF»" id="tab«sortOrder»" aria-labelledby="vars«sortOrder»Tab">
                    {% set tabTitle = __('«name.formatForDisplayCapital»') %}
                    «configSectionBody(app, isPrimaryVarContainer)»
                </div>
            «ENDIF»
        «ELSE»
            {% set tabTitle = __('«name.formatForDisplayCapital»') %}
            «configSectionBody(app, isPrimaryVarContainer)»
        «ENDIF»
    '''

    def private configSectionBodyImages(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        «FOR entity : app.getAllEntities.filter[hasImageFieldsEntity]»
            «FOR imageUploadField : entity.imageFieldsEntity»
                <div role="tabpanel" class="tab-pane fade«IF isPrimaryVarContainer && entity == app.getAllEntities.filter[hasImageFieldsEntity].head && imageUploadField == entity.imageFieldsEntity.head» in active«ENDIF»" id="tabImages«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»" aria-labelledby="images«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»Tab">
                    {% set tabTitle = __('Image settings for «entity.nameMultiple.formatForDisplay» «imageUploadField.name.formatForDisplay»') %}
                    <fieldset>
                        <legend>{{ tabTitle }}</legend>

                        «FOR modvar : vars.filter[name.contains(entity.name.formatForCodeCapital + imageUploadField.name.formatForCodeCapital)]»«modvar.formRow»«ENDFOR»
                    </fieldset>
                </div>
            «ENDFOR»
        «ENDFOR»
    '''

    def private configSectionBody(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        <fieldset>
            <legend>{{ tabTitle }}</legend>

            «IF null !== documentation && documentation != ''»
                «IF !documentation.containedTwigVariables.empty»
                    {{ __f('«documentation.replace('\'', '\\\'').replaceTwigVariablesForTranslation»', { «documentation.containedTwigVariables.map[v|'\'%' + v + '%\': ' + v + '|default'].join(', ')» }) }}
                «ELSE»
                    <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»')|nl2br }}</p>
                «ENDIF»
            «ELSEIF !app.hasMultipleConfigSections || isPrimaryVarContainer»
                <p class="alert alert-info">{{ __('Here you can manage all basic settings for this application.') }}</p>
            «ENDIF»

            «FOR modvar : vars»«modvar.formRow»«ENDFOR»
        </fieldset>
    '''

    def private isImageArea(Variables it) {
        it.name == 'Images' && !it.vars.filter[name.formatForCode.startsWith('shrinkWidth')].empty
    }

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
