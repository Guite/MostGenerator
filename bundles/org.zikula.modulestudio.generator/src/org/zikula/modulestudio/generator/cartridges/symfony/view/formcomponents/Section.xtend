package org.zikula.modulestudio.generator.cartridges.symfony.view.formcomponents

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
    def generate(Entity it, Application app, IMostFileSystemAccess fsa) '''

        «extensionsAndRelations(app, fsa)»

        «additionalRemark»
        «moderationFields»
    '''

    def private extensionsAndRelations(Entity it, Application app, IMostFileSystemAccess fsa) '''
        «IF geographical»
            «IF useGroupingTabs('edit')»
                <div role="tabpanel" class="tab-pane fade" id="tabMap" aria-labelledby="mapTab">
                    <h3>{% trans from 'messages' %}Map{% endtrans %}</h3>
            «ELSE»
                <fieldset class="«app.appName.toLowerCase»-map">
            «ENDIF»
                <legend>{% trans from 'messages' %}Map{% endtrans %}</legend>
                <div id="mapContainer" class="«app.appName.toLowerCase»-mapcontainer">
                </div>
                <br />
                «FOR geoFieldName : #['latitude', 'longitude']»
                    {{ form_row(form.«geoFieldName») }}
                «ENDFOR»
            «IF useGroupingTabs('edit')»
                </div>
            «ELSE»
                </fieldset>
            «ENDIF»

        «ENDIF»
        «new Relations(fsa, app).generateIncludeStatement(it)»
        «IF categorisable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Bundle\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                {{ include('@«app.vendorAndName»/Helper/includeCategoriesEdit.html.twig', {obj: «name.formatForCode»«IF useGroupingTabs('edit')», tabs: true«ENDIF»}) }}
            {% endif %}
        «ENDIF»
        «IF standardFields»
            {% if mode != 'create' %}
                {{ include('@«app.vendorAndName»/Helper/includeStandardFieldsEdit.html.twig', {obj: «name.formatForCode»«IF useGroupingTabs('edit')», tabs: true«ENDIF»}) }}
            {% endif %}
        «ENDIF»
    '''

    def private additionalRemark(Entity it) '''
        «IF workflow != EntityWorkflowType.NONE»
            <fieldset>
                <legend>{% trans from 'messages' %}Communication{% endtrans %}</legend>
                {{ form_row(form.additionalNotificationRemarks) }}
            </fieldset>

        «ENDIF»
    '''

    def private moderationFields(Entity it) '''
        «IF standardFields»
            {% if form.moderationSpecificCreator is defined or form.moderationSpecificCreationDate is defined %}
                «IF useGroupingTabs('edit')»
                    <div role="tabpanel" class="tab-pane fade" id="tabModeration" aria-labelledby="moderationTab">
                        <h3>{% trans from 'messages' %}Moderation{% endtrans %}</h3>
                        {% if form.moderationSpecificCreator is defined %}
                            {{ form_row(form.moderationSpecificCreator) }}
                        {% endif %}
                        {% if form.moderationSpecificCreationDate is defined %}
                            {{ form_row(form.moderationSpecificCreationDate) }}
                        {% endif %}
                    </div>
                «ELSE»
                    <fieldset id="moderationFieldsSection">
                        <legend>{% trans from 'messages' %}Moderation{% endtrans %} <i class="fas fa-expand"></i></legend>
                        <div id="moderationFieldsContent">
                            {% if form.moderationSpecificCreator is defined %}
                                {{ form_row(form.moderationSpecificCreator) }}
                            {% endif %}
                            {% if form.moderationSpecificCreationDate is defined %}
                                {{ form_row(form.moderationSpecificCreationDate) }}
                            {% endif %}
                        </div>
                    </fieldset>
                «ENDIF»
            {% endif %}

        «ENDIF»
    '''
}
