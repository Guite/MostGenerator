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

        «returnControl»

        «submitActions»
    '''

    def private extensionsAndRelations(Entity it, Application app, IFileSystemAccess fsa) '''
        «IF geographical»
            «IF useGroupingPanels('edit')»
                «IF isLegacyApp»
                    <h3 class="«app.appName.toLowerCase»-map z-panel-header z-panel-indicator z-pointer">{gt text='Map'}</h3>
                    <fieldset class="«app.appName.toLowerCase»-map z-panel-content" style="display: none">
                «ELSE»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMap">{{ __('Map') }}</a></h3>
                        </div>
                        <div id="collapseMap" class="panel-collapse collapse in">
                            <div class="panel-body">
                «ENDIF»
            «ELSE»
                <fieldset class="«app.appName.toLowerCase»-map">
            «ENDIF»
                <legend>«IF isLegacyApp»{gt text='Map'}«ELSE»{{ __('Map') }}«ENDIF»</legend>
                <div id="mapContainer" class="«app.appName.toLowerCase»-mapcontainer">
                </div>
            «IF isLegacyApp»
                </fieldset>
            «ELSE»
                        </div>
                    </div>
                </div>
            «ENDIF»

        «ENDIF»
        «IF isLegacyApp»
            «IF attributable»
                {include file='helper/includeAttributesEdit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
            «ENDIF»
            «IF categorisable»
                {include file='helper/includeCategoriesEdit.tpl' obj=$«name.formatForDB» groupName='«name.formatForDB»Obj'«IF useGroupingPanels('edit')» panel=true«ENDIF»}
            «ENDIF»
            «relationHelper.generateIncludeStatement(it, app, fsa)»
            «IF metaData»
                {include file='helper/includeMetaDataEdit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
            «ENDIF»
            «IF standardFields»
                {if $mode ne 'create'}
                    {include file='helper/includeStandardFieldsEdit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
                {/if}
            «ENDIF»
        «ELSE»
            «IF attributable»
                {{ include('Helper/includeAttributesEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingPanels('edit')», panel: true«ENDIF» }) }}
            «ENDIF»
            «IF categorisable»
                {{ include('Helper/includeCategoriesEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingPanels('edit')», panel: true«ENDIF» }) }}
            «ENDIF»
            «relationHelper.generateIncludeStatement(it, app, fsa)»
            «IF metaData»
                {{ include('Helper/includeMetaDataEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingPanels('edit')», panel: true«ENDIF» }) }}
            «ENDIF»
            «IF standardFields»
                {% if mode != 'create' %}
                    {{ include('Helper/includeStandardFieldsEdit.html.twig', { obj: «name.formatForDB»«IF useGroupingPanels('edit')», panel: true«ENDIF» }) }}
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def private displayHooks(Entity it, Application app) '''
        «IF isLegacyApp»
            {* include display hooks *}
            {if $mode ne 'create'}
                {assign var='hookId' value=«IF !hasCompositeKeys»$«name.formatForDB».«getFirstPrimaryKey.name.formatForCode»«ELSE»"«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForDB».«pkField.name.formatForCode»`«ENDFOR»"«ENDIF»}
                {notifydisplayhooks eventname='«app.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit' id=$hookId assign='hooks'}
            {else}
                {notifydisplayhooks eventname='«app.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit' id=null assign='hooks'}
            {/if}
            {if is_array($hooks) && count($hooks)}
                {foreach name='hookLoop' key='providerArea' item='hook' from=$hooks}
                    {if $providerArea ne 'provider.scribite.ui_hooks.editor'}{* fix for #664 *}
                        «IF useGroupingPanels('edit')»
                            <h3 class="hook z-panel-header z-panel-indicator z-pointer">{$providerArea}</h3>
                            <fieldset class="hook z-panel-content" style="display: none">
                                {$hook}
                            </fieldset>
                        «ELSE»
                            <fieldset>
                                {$hook}
                            </fieldset>
                        «ENDIF»
                    {/if}
                {/foreach}
            {/if}
        «ELSE»
            {# include display hooks #}
            {% if mode != 'create' %}
                {% set hookId = «FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForDB».«pkField.name.formatForCode»«ENDFOR» %}
                {% set hooks = notifyDisplayHooks(eventName='«app.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit', id=hookId) %}
            {% else %}
                {% set hooks = notifyDisplayHooks(eventName='«app.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit', id=null) %}
            {% endif %}
            {% if hooks is iterable and hooks|length > 0 %}
                {% for providerArea, hook in hooks %}
                    {% if providerArea != 'provider.scribite.ui_hooks.editor' %}{# fix for #664 #}
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
                    {% endif %}
                {% endfor %}
            {% endif %}
        «ENDIF»
    '''

    def private additionalRemark(Entity it) '''
        «IF workflow != EntityWorkflowType.NONE»
            «IF isLegacyApp»
                <fieldset>
                    <legend>{gt text='Communication'}</legend>
                    <div class="z-formrow">
                        {formlabel for='additionalNotificationRemarks' __text='Additional remarks'}
                        {gt text='Enter any additions about your changes' assign='fieldTitle'}
                        {if $mode eq 'create'}
                            {gt text='Enter any additions about your content' assign='fieldTitle'}
                        {/if}
                        {formtextinput group='«name.formatForDB»' id='additionalNotificationRemarks' mandatory=false title=$fieldTitle textMode='multiline' rows='6«/*8*/»' cols='50'}
                        {if $isModerator || $isSuperModerator}
                            <span class="z-formnote">{gt text='These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.'}</span>
                        {elseif $isCreator}
                            <span class="z-formnote">{gt text='These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.'}</span>
                        {/if}
                    </div>
                </fieldset>
            «ELSE»
                <fieldset>
                    <legend>{{ __('Communication') }}</legend>
                    {{ form_row(form.additionalNotificationRemarks) }}
                </fieldset>
            «ENDIF»
        «ENDIF»
    '''

    def private returnControl(Entity it) '''
        «IF isLegacyApp»
            {* include return control *}
            {if $mode eq 'create'}
                <fieldset>
                    <legend>{gt text='Return control'}</legend>
                    <div class="z-formrow">
                        {formlabel for='repeatCreation' __text='Create another item after save'}
                        {formcheckbox group='«name.formatForDB»' id='repeatCreation' readOnly=false}
                    </div>
                </fieldset>
            {/if}
        «ELSE»
            {# include return control #}
            {% if mode == 'create' %}
                <fieldset>
                    <legend>{{ __('Return control') }}</legend>
                    {{ form_row(form.repeatCreation) }}
                </fieldset>
            {/if}
        «ENDIF»
    '''

    def private submitActions(Entity it) '''
        «IF isLegacyApp»
            {* include possible submit actions *}
            <div class="z-buttons z-formbuttons">
                «submitActionsImpl»
        «ELSE»
            {# include possible submit actions #}
            <div class="form-group form-buttons">
                <div class="col-sm-offset-3 col-sm-9">
                    «submitActionsImpl»
                </div>
        «ENDIF»
        </div>
    '''

    def private submitActionsImpl(Entity it) '''
        «IF isLegacyApp»
            {foreach item='action' from=$actions}
                {assign var='actionIdCapital' value=$action.id|@ucfirst}
                {gt text=$action.title assign='actionTitle'}
                {*gt text=$action.description assign='actionDescription'*}{* TODO: formbutton could support title attributes *}
                {if $action.id eq 'delete'}
                    {gt text='Really delete this «name.formatForDisplay»?' assign='deleteConfirmMsg'}
                    {formbutton id="btn`$actionIdCapital`" commandName=$action.id text=$actionTitle class=$action.buttonClass confirmMessage=$deleteConfirmMsg}
                {else}
                    {formbutton id="btn`$actionIdCapital`" commandName=$action.id text=$actionTitle class=$action.buttonClass}
                {/if}
            {/foreach}
            {formbutton id='btnCancel' commandName='cancel' __text='Cancel' class='z-bt-cancel' formnovalidate='formnovalidate'}
        «ELSE»
            {% for action in actions %}
                {{ form_widget(attribute(form, action.id), {attr: {class: action.buttonClass}, icon: action.id == 'delete' ? 'fa-trash-o' : '') }}
            {% endfor %}
            {{ form_widget(form.reset, {attr: {class: 'btn btn-default', formnovalidate: 'formnovalidate'}, icon: 'fa-refresh'}) }}
            {{ form_widget(form.cancel, {attr: {class: 'btn btn-default', formnovalidate: 'formnovalidate'}, icon: 'fa-times'}) }}
        «ENDIF»
    '''

    def private isLegacyApp(Entity it) {
        application.targets('1.3.x')
    }
}
