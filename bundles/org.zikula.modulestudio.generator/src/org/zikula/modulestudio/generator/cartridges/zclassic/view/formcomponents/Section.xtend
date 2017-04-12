package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Section {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ViewExtensions = new ViewExtensions
    extension Utils = new Utils

    Relations relationHelper = new Relations

    /**
     * Entry point for edit sections beside the actual fields.
     */
    def generate(Entity it, Application app, IFileSystemAccess fsa) '''

        «extensionsAndRelations(app, fsa)»

        «IF !skipHookSubscribers»
            «displayHooks(app)»

        «ENDIF»
        «additionalRemark»
        «moderationFields»
        «returnControl»
    '''

    def private extensionsAndRelations(Entity it, Application app, IFileSystemAccess fsa) '''
        «IF geographical»
            «IF useGroupingTabs('edit')»
                <div role="tabpanel" class="tab-pane fade" id="tabMap" aria-labelledby="mapTab">
                    <h3>{{ __('Map') }}</h3>
            «ELSE»
                <fieldset class="«app.appName.toLowerCase»-map">
            «ENDIF»
                <legend>{{ __('Map') }}</legend>
                <div id="mapContainer" class="«app.appName.toLowerCase»-mapcontainer">
                </div>
            «IF useGroupingTabs('edit')»
                </div>
            «ELSE»
                </fieldset>
            «ENDIF»

        «ENDIF»
        «relationHelper.generateIncludeStatement(it, app, fsa)»
        «IF attributable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                {{ include('@«app.appName»/Helper/includeAttributesEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingTabs('edit')», tabs: true«ENDIF» }) }}
            {% endif %}
        «ENDIF»
        «IF categorisable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                {{ include('@«app.appName»/Helper/includeCategoriesEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingTabs('edit')», tabs: true«ENDIF» }) }}
            {% endif %}
        «ENDIF»
        «IF standardFields»
            {% if mode != 'create' %}
                {{ include('@«app.appName»/Helper/includeStandardFieldsEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingTabs('edit')», tabs: true«ENDIF» }) }}
            {% endif %}
        «ENDIF»
    '''

    def private displayHooks(Entity it, Application app) '''
        «IF useGroupingTabs('edit')»
            <div role="tabpanel" class="tab-pane fade" id="tabHooks" aria-labelledby="hooksTab">
                <h3>{{ __('Hooks') }}</h3>
        «ENDIF»
        {% set hookId = mode != 'create' ? «FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForDB».«pkField.name.formatForCode»«ENDFOR» : null %}
        {% set hooks = notifyDisplayHooks(eventName='«app.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit', id=hookId) %}
        {% if hooks is iterable and hooks|length > 0 %}
            {% for providerArea, hook in hooks if providerArea != 'provider.scribite.ui_hooks.editor' %}
                «IF useGroupingTabs('edit')»
                    <h4>{{ providerArea }}</h4>
                    {{ hook }}
                «ELSE»
                    <fieldset>
                        <legend>{{ providerArea }}</legend>
                        {{ hook }}
                    </fieldset>
                «ENDIF»
            {% endfor %}
        {% endif %}
        «IF useGroupingTabs('edit')»
            </div>
        «ENDIF»
    '''

    def private additionalRemark(Entity it) '''
        «IF workflow != EntityWorkflowType.NONE»
            <fieldset>
                <legend>{{ __('Communication') }}</legend>
                {{ form_row(form.additionalNotificationRemarks) }}
            </fieldset>

        «ENDIF»
    '''

    def private moderationFields(Entity it) '''
        «IF standardFields»
            {% if form.moderationSpecificCreator is defined %}
                «IF useGroupingTabs('edit')»
                    <div role="tabpanel" class="tab-pane fade" id="tabModeration" aria-labelledby="moderationTab">
                        <h3>{{ __('Moderation') }}</h3>
                        {{ form_row(form.moderationSpecificCreator) }}
                        {{ form_row(form.moderationSpecificCreationDate) }}
                    </div>
                «ELSE»
                    <fieldset id="moderationFieldsSection">
                        <legend>{{ __('Moderation') }} <i class="fa fa-expand"></i></legend>
                        <div id="moderationFieldsContent">
                            {{ form_row(form.moderationSpecificCreator) }}
                            {{ form_row(form.moderationSpecificCreationDate) }}
                        </div>
                    </fieldset>
                «ENDIF»
            {% endif %}

        «ENDIF»
    '''

    def private returnControl(Entity it) '''
        {# include return control #}
        {% if mode == 'create' %}
            <fieldset>
                <legend>{{ __('Return control') }}</legend>
                {{ form_row(form.repeatCreation) }}
            </fieldset>
        {% endif %}
    '''
}
