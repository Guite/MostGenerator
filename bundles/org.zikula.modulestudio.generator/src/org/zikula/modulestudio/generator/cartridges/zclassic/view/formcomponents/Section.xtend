package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Section {

    extension FormattingExtensions = new FormattingExtensions
    extension ViewExtensions = new ViewExtensions
    extension Utils = new Utils

    /**
     * Entry point for edit sections beside the actual fields.
     */
    def generate(Entity it, Application app, IMostFileSystemAccess fsa, Boolean isAdmin) '''

        «extensionsAndRelations(app, fsa, isAdmin)»

        «IF !skipHookSubscribers»
            {% if formHookTemplates|length > 0 %}
                <fieldset>
                    {% for hookTemplate in formHookTemplates %}
                        {{ include(hookTemplate.0, hookTemplate.1, ignore_missing = true) }}
                    {% endfor %}
                </fieldset>
            {% endif %}

        «ENDIF»
        «additionalRemark»
        «moderationFields»
    '''

    def private extensionsAndRelations(Entity it, Application app, IMostFileSystemAccess fsa, Boolean isAdmin) '''
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
        «new Relations(fsa, app, isAdmin).generateIncludeStatement(it)»
        «IF attributable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                {{ include('@«app.appName»/Helper/includeAttributesEdit.html.twig', {obj: «name.formatForDB»«IF useGroupingTabs('edit')», tabs: true«ENDIF»}) }}
            {% endif %}
        «ENDIF»
        «IF categorisable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                {{ include('@«app.appName»/Helper/includeCategoriesEdit.html.twig', {obj: «name.formatForDB»«IF useGroupingTabs('edit')», tabs: true«ENDIF»}) }}
            {% endif %}
        «ENDIF»
        «IF standardFields»
            {% if mode != 'create' %}
                {{ include('@«app.appName»/Helper/includeStandardFieldsEdit.html.twig', {obj: «name.formatForDB»«IF useGroupingTabs('edit')», tabs: true«ENDIF»}) }}
            {% endif %}
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
}
