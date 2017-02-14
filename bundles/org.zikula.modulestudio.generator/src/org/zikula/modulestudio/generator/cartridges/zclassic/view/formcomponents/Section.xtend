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

        «submitActions»
    '''

    def private extensionsAndRelations(Entity it, Application app, IFileSystemAccess fsa) '''
        «IF geographical»
            «IF useGroupingPanels('edit')»
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMap">{{ __('Map') }}</a></h3>
                    </div>
                    <div id="collapseMap" class="panel-collapse collapse in">
                        <div class="panel-body">
            «ELSE»
                <fieldset class="«app.appName.toLowerCase»-map">
            «ENDIF»
                <legend>{{ __('Map') }}</legend>
                <div id="mapContainer" class="«app.appName.toLowerCase»-mapcontainer">
                </div>
            «IF useGroupingPanels('edit')»
                        </div>
                    </div>
                </div>
            «ELSE»
                </fieldset>
            «ENDIF»

        «ENDIF»
        «IF attributable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::ATTRIBUTES'), '«name.formatForCode»') %}
                {{ include('@«app.appName»/Helper/includeAttributesEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingPanels('edit')», panel: true«ENDIF» }) }}
            {% endif %}
        «ENDIF»
        «IF categorisable»
            {% if featureActivationHelper.isEnabled(constant('«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Helper\\FeatureActivationHelper::CATEGORIES'), '«name.formatForCode»') %}
                {{ include('@«app.appName»/Helper/includeCategoriesEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingPanels('edit')», panel: true«ENDIF» }) }}
            {% endif %}
        «ENDIF»
        «relationHelper.generateIncludeStatement(it, app, fsa)»
        «IF standardFields»
            {% if mode != 'create' %}
                {{ include('@«app.appName»/Helper/includeStandardFieldsEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingPanels('edit')», panel: true«ENDIF» }) }}
            {% endif %}
        «ENDIF»
    '''

    def private displayHooks(Entity it, Application app) '''
        {# include display hooks #}
        {% set hookId = mode != 'create' ? «FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForDB».«pkField.name.formatForCode»«ENDFOR» : null %}
        {% set hooks = notifyDisplayHooks(eventName='«app.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit', id=hookId) %}
        {% if hooks is iterable and hooks|length > 0 %}
            {% for providerArea, hook in hooks if providerArea != 'provider.scribite.ui_hooks.editor' %}
                «IF useGroupingPanels('edit')»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseHook{{ loop.index }}">{{ providerArea }}</a></h3>
                        </div>
                        <div id="collapseHook{{ loop.index }}" class="panel-collapse collapse in">
                            <div class="panel-body">
                                {{ hook }}
                            </div>
                        </div>
                    </div>
                «ELSE»
                    <fieldset>
                        {{ hook }}
                    </fieldset>
                «ENDIF»
            {% endfor %}
        {% endif %}
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
                <fieldset id="moderationFieldsSection">
                    <legend>{{ __('Moderation') }} <i class="fa fa-expand"></i></legend>
                    <div id="moderationFieldsContent">
                        {{ form_row(form.moderationSpecificCreator) }}
                        {{ form_row(form.moderationSpecificCreationDate) }}
                    </div>
                </fieldset>
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

    def private submitActions(Entity it) '''
        {# include possible submit actions #}
        <div class="form-group form-buttons">
            <div class="col-sm-offset-3 col-sm-9">
                «submitActionsImpl»
            </div>
        </div>
    '''

    def private submitActionsImpl(Entity it) '''
        {% for action in actions %}
            {{ form_widget(attribute(form, action.id)) }}
        {% endfor %}
        {{ form_widget(form.reset) }}
        {{ form_widget(form.cancel) }}
    '''
}
