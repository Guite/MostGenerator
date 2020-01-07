package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.SharedFormElements
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.ViewPagesHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Config {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension SharedFormElements = new SharedFormElements
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Config/'
        val fileName = 'config.html.twig'
        'Generating config page view template'.printIfNotTesting(fsa)
        fsa.generateFile(templatePath + fileName, configView)
    }

    def private configView(Application it) '''
        {# purpose of this template: module configuration page #}
        «IF targets('3.0')»
            {% extends '@«appName»/adminBase.html.twig' %}
        «ELSE»
            {% extends '«appName»::adminBase.html.twig' %}
        «ENDIF»
        «IF !isSystemModule && targets('3.0')»
            {% trans_default_domain '«appName.formatForDB»' %}
        «ENDIF»
        {% block title «IF targets('3.0')»'Settings'|trans«ELSE»__('Settings')«ENDIF» %}
        {% block admin_page_icon 'wrench' %}
        {% block content %}
            <div class="«appName.toLowerCase»-config">
                {% form_theme form with [
                    '@«appName»/Form/bootstrap_«IF targets('3.0')»4«ELSE»3«ENDIF».html.twig',
                    «IF targets('3.0')»
                        '@ZikulaFormExtension/Form/form_div_layout.html.twig'
                    «ELSE»
                        'ZikulaFormExtensionBundle:Form:form_div_layout.html.twig'
                    «ENDIF»
                ] %}
                {{ form_start(form) }}
                <div class="zikula-bootstrap-tab-container">
                    <ul class="nav nav-tabs" role="tablist">
                        «FOR varContainer : getSortedVariableContainers»
                            {% set tabTitle = «IF targets('3.0')»'«varContainer.name.formatForDisplayCapital»'|trans«ELSE»__('«varContainer.name.formatForDisplayCapital»')«ENDIF» %}
                            «IF targets('3.0')»
                                <li class="nav-item«IF varContainer.isImageArea» dropdown«ENDIF»" role="presentation">
                            «ELSE»
                                <li role="presentation"«IF varContainer == getSortedVariableContainers.head || varContainer.isImageArea» class="«IF varContainer == getSortedVariableContainers.head»active«ENDIF»«IF varContainer.isImageArea» dropdown«ENDIF»"«ENDIF»>
                            «ENDIF»
                                «IF varContainer.isImageArea»
                                    <a id="imagesTabDrop" class="«IF targets('3.0')»nav-link «IF varContainer == getSortedVariableContainers.head»active «ENDIF»«ENDIF»dropdown-toggle" href="#" data-toggle="dropdown" aria-controls="imagesTabDropSections" aria-expanded="false" title="{{ tabTitle|e('html_attr') }}">{{ tabTitle }}«IF !targets('3.0')»<span class="caret"></span>«ENDIF»</a>
                                    <ul id="imagesTabDropSections" class="dropdown-menu" aria-labelledby="imagesTabDrop">
                                    «FOR entity : getAllEntities.filter[hasImageFieldsEntity]»
                                        «FOR imageUploadField : entity.imageFieldsEntity»
                                            <li>
                                                <a id="images«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»Tab" href="#tabImages«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»" role="tab" data-toggle="tab" aria-controls="tabImages«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»">«IF targets('3.0')»{% trans %}«entity.nameMultiple.formatForDisplayCapital» «imageUploadField.name.formatForDisplay»{% endtrans %}«ELSE»{{ __('«entity.nameMultiple.formatForDisplayCapital» «imageUploadField.name.formatForDisplay»') }}«ENDIF»</a>
                                            </li>
                                        «ENDFOR»
                                    «ENDFOR»
                                    </ul>
                                «ELSE»
                                    <a id="vars«varContainer.sortOrder»Tab" href="#tab«varContainer.sortOrder»" title="{{ tabTitle|e('html_attr') }}" role="tab" data-toggle="tab"«IF targets('3.0')» class="nav-link«IF varContainer == getSortedVariableContainers.head» active«ENDIF»"«ENDIF»>{{ tabTitle }}</a>
                                «ENDIF»
                            </li>
                        «ENDFOR»
                        {% set tabTitle = «IF targets('3.0')»'Workflows'|trans«ELSE»__('Workflows')«ENDIF» %}
                        <li«IF targets('3.0')» class="nav-item"«ENDIF» role="presentation">
                            <a id="workflowsTab" href="#tabWorkflows" title="{{ tabTitle|e('html_attr') }}" role="tab" data-toggle="tab"«IF targets('3.0')» class="nav-link"«ENDIF»>{{ tabTitle }}</a>
                        </li>
                    </ul>

                    {{ form_errors(form) }}
                    <div class="tab-content">
                        «configSections»
                    </div>
                </div>

                <div class="form-group form-buttons«IF targets('3.0')» row«ENDIF»">
                    <div class="«IF targets('3.0')»col-md-9 offset-md-3«ELSE»col-sm-offset-3 col-sm-9«ENDIF»">
                        {{ form_widget(form.save) }}
                        {{ form_widget(form.reset) }}
                        {{ form_widget(form.cancel) }}
                    </div>
                </div>
                {{ form_end(form) }}
            </div>
        {% endblock %}
        {% block footer %}
            {{ parent() }}
            «IF hasImageFields || hasLoggable»
                {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Config.js')) }}
            «ENDIF»
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Validation.js'), 98) }}
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».EditFunctions.js'), 99) }}
            «formTemplateJS»
        {% endblock %}
    '''

    def private configSections(Application it) '''
        «FOR varContainer : getSortedVariableContainers»«varContainer.configSection(it, varContainer == getSortedVariableContainers.head)»«ENDFOR»
        <div role="tabpanel" class="tab-pane fade" id="tabWorkflows" aria-labelledby="workflowsTab">
            {% set tabTitle = «IF targets('3.0')»'Workflows'|trans«ELSE»__('Workflows')«ENDIF» %}
            <fieldset>
                <legend>{{ tabTitle }}</legend>

                «IF targets('3.0')»
                    <p class="alert alert-info">{% trans %}Here you can inspect and amend the existing workflows.{% endtrans %}</p>
                «ELSE»
                    <p class="alert alert-info">{{ __('Here you can inspect and amend the existing workflows.') }}</p>
                «ENDIF»

                «FOR entity : getAllEntities»
                    «IF targets('3.0')»
                        <h4>{% trans %}«entity.nameMultiple.formatForDisplayCapital»{% endtrans %}</h4>
                    «ELSE»
                        <h4>{{ __('«entity.nameMultiple.formatForDisplayCapital»') }}</h4>
                    «ENDIF»
                    <p><a href="{{ path('zikula_workflow_editor_index', {workflow: '«appName.formatForDB»_«entity.workflow.textualName»'}) }}" title="{{ «IF targets('3.0')»'Edit workflow for «entity.nameMultiple.formatForDisplay»'|trans«ELSE»__('Edit workflow for «entity.nameMultiple.formatForDisplay»')«ENDIF»|e('html_attr') }}" target="_blank"><i class="fa fa-cubes"></i> «IF targets('3.0')»{% trans %}Edit «entity.nameMultiple.formatForDisplay» workflow{% endtrans %}«ELSE»{{ __('Edit «entity.nameMultiple.formatForDisplay» workflow') }}«ENDIF»</a>
                «ENDFOR»
            </fieldset>
        </div>
    '''

    def private configSection(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        «IF isImageArea»
            «configSectionBodyImages(app, isPrimaryVarContainer)»
        «ELSE»
            <div role="tabpanel" class="tab-pane fade«IF isPrimaryVarContainer» «IF app.targets('3.0')»show«ELSE»in«ENDIF» active«ENDIF»" id="tab«sortOrder»" aria-labelledby="vars«sortOrder»Tab">
                {% set tabTitle = «IF app.targets('3.0')»'«name.formatForDisplayCapital»'|trans«ELSE»__('«name.formatForDisplayCapital»')«ENDIF» %}
                «configSectionBody(app, isPrimaryVarContainer)»
            </div>
        «ENDIF»
    '''

    def private configSectionBodyImages(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        «FOR entity : app.getAllEntities.filter[hasImageFieldsEntity]»
            «FOR imageUploadField : entity.imageFieldsEntity»
                <div role="tabpanel" class="tab-pane fade«IF isPrimaryVarContainer && entity == app.getAllEntities.filter[hasImageFieldsEntity].head && imageUploadField == entity.imageFieldsEntity.head» «IF app.targets('3.0')»show«ELSE»in«ENDIF» active«ENDIF»" id="tabImages«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»" aria-labelledby="images«entity.name.formatForCodeCapital»«imageUploadField.name.formatForCodeCapital»Tab">
                    «IF app.targets('3.0')»
                        {% set tabTitle = 'Image settings for «entity.nameMultiple.formatForDisplay» «imageUploadField.name.formatForDisplay»'|trans %}
                    «ELSE»
                        {% set tabTitle = __('Image settings for «entity.nameMultiple.formatForDisplay» «imageUploadField.name.formatForDisplay»') %}
                    «ENDIF»
                    <fieldset>
                        <legend>{{ tabTitle }}</legend>
                        «val fieldSuffix = entity.name.formatForCodeCapital + imageUploadField.name.formatForCodeCapital»

                        «FOR field : fields.filter(DerivedField).filter[name.endsWith(fieldSuffix) || name.endsWith(fieldSuffix + 'View') || name.endsWith(fieldSuffix + 'Display') || name.endsWith(fieldSuffix + 'Edit')]»«field.fieldWrapper»«ENDFOR»
                    </fieldset>
                </div>
            «ENDFOR»
        «ENDFOR»
    '''

    def private configSectionBody(Variables it, Application app, Boolean isPrimaryVarContainer) '''
        <fieldset>
            <legend>{{ tabTitle }}</legend>
            «new ViewPagesHelper().docsWithVariables(it, app)»
            «IF (null === documentation || documentation.empty) && (!app.hasMultipleConfigSections || isPrimaryVarContainer)»
                «IF app.targets('3.0')»
                    <p class="alert alert-info">{% trans %}Here you can manage all basic settings for this application.{% endtrans %}</p>
                «ELSE»
                    <p class="alert alert-info">{{ __('Here you can manage all basic settings for this application.') }}</p>
                «ENDIF»

            «ENDIF»
            «FOR field : fields.filter(DerivedField)»«field.fieldWrapper»«ENDFOR»
        </fieldset>
    '''

    def private formTemplateJS(Application it) '''
        {% set formInitScript %}
            <script>
            /* <![CDATA[ */
                «jsInitImpl»
            /* ]]> */
            </script>
        {% endset %}
        {{ pageAddAsset('footer', formInitScript) }}
    '''

    def private jsInitImpl(Application it) '''
        ( function($) {
            $(document).ready(function() {
                «vendorAndName»InitEditForm('edit', '1');
                «FOR varContainer : getSortedVariableContainers»
                    «FOR field : varContainer.fields»«field.additionalInitScript»«ENDFOR»
                «ENDFOR»
            });
        })(jQuery);
    '''

    def private isImageArea(Variables it) {
        it.name == 'Images' && !it.fields.filter[name.formatForCode.startsWith('shrinkWidth')].empty
    }

    def private fieldWrapper(DerivedField it) '''
        «IF name.formatForCode.startsWith('shrinkWidth')»
            <div id="shrinkDetails«name.formatForCode.replace('shrinkWidth', '').formatForCodeCapital»">
        «ENDIF»
        «fieldFormRow('')»
        «IF name.formatForCode.startsWith('shrinkHeight')»
            </div>
        «ENDIF»
    '''
}
