package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Section {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ViewExtensions = new ViewExtensions
    @Inject extension Utils = new Utils

    Relations relationHelper = new Relations

    /**
     * Entry point for edit sections beside the actual fields.
     */
    def generate(Entity it, Application app, Controller controller, IFileSystemAccess fsa) '''

        «extensionsAndRelations(app, controller, fsa)»

        «displayHooks(app)»

        «returnControl»

        «submitActions»
    '''

    def private extensionsAndRelations(Entity it, Application app, Controller controller, IFileSystemAccess fsa) '''
        «IF geographical»
            «IF useGroupingPanels('edit')»
            <h3 class="«app.appName.toLowerCase»-map z-panel-header z-panel-indicator «IF app.targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Map'}</h3>
            <fieldset class="«app.appName.toLowerCase»-map z-panel-content" style="display: none">
            «ELSE»
            <fieldset class="«app.appName.toLowerCase»-map">
            «ENDIF»
                <legend>{gt text='Map'}</legend>
                <div id="mapContainer" class="«app.appName.toLowerCase»-mapcontainer">
                </div>
            </fieldset>

        «ENDIF»
        «IF attributable»
            {include file='«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/include_attributes_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «IF categorisable»
            {include file='«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/include_categories_edit.tpl' obj=$«name.formatForDB» groupName='«name.formatForDB»Obj'«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «relationHelper.generateIncludeStatement(it, app, controller, fsa)»
        «IF metaData»
            {include file='«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/include_metadata_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «IF standardFields»
            {if $mode ne 'create'}
                {include file='«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/include_standardfields_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
            {/if}
        «ENDIF»
    '''

    def private displayHooks(Entity it, Application app) '''
        {* include display hooks *}
        {if $mode ne 'create'}
            {assign var='hookId' value=«IF !hasCompositeKeys»$«name.formatForDB».«getFirstPrimaryKey.name.formatForCode»«ELSE»"«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForDB».«pkField.name.formatForCode»`«ENDFOR»"«ENDIF»}
            {notifydisplayhooks eventname='«app.name.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit' id=$hookId assign='hooks'}
        {else}
            {notifydisplayhooks eventname='«app.name.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit' id=null assign='hooks'}
        {/if}
        {if is_array($hooks) && count($hooks)}
            {foreach key='providerArea' item='hook' from=$hooks}
                «IF useGroupingPanels('edit')»
                    <h3 class="hook z-panel-header z-panel-indicator «IF app.targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{$providerArea}</h3>
                    <fieldset class="hook z-panel-content" style="display: none">{$hook}</div>
                «ELSE»
                    <fieldset>
                «ENDIF»
                    {$hook}
                </fieldset>
            {/foreach}
        {/if}
    '''

    def private returnControl(Entity it) '''
        {* include return control *}
        {if $mode eq 'create'}
            <fieldset>
                <legend>{gt text='Return control'}</legend>
                <div class="«IF container.application.targets('1.3.5')»z-formrow«ELSE»form-group«ENDIF»">
                    {formlabel for='repeatCreation' __text='Create another item after save'«IF !container.application.targets('1.3.5')» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !container.application.targets('1.3.5')»
                    <div class="col-lg-9">
                «ENDIF»
                        {formcheckbox group='«name.formatForDB»' id='repeatCreation' readOnly=false}
                «IF !container.application.targets('1.3.5')»
                    </div>
                «ENDIF»
                </div>
            </fieldset>
        {/if}
    '''

    def private submitActions(Entity it) '''
        {* include possible submit actions *}
        <div class="«IF container.application.targets('1.3.5')»z-buttons z-formbuttons«ELSE»form-group form-buttons«ENDIF»">
        «IF !container.application.targets('1.3.5')»
            <div class="col-lg-offset-3 col-lg-9">
        «ENDIF»
        {foreach item='action' from=$actions}
            {assign var='actionIdCapital' value=$action.id|@ucwords}
            {gt text=$action.title assign='actionTitle'}
            {*gt text=$action.description assign='actionDescription'*}{* TODO: formbutton could support title attributes *}
            {if $action.id eq 'delete'}
                {gt text='Really delete this «name.formatForDisplay»?' assign='deleteConfirmMsg'}
                {formbutton id="btn`$actionIdCapital`" commandName=$action.id text=$actionTitle class=$action.buttonClass confirmMessage=$deleteConfirmMsg}
            {else}
                {formbutton id="btn`$actionIdCapital`" commandName=$action.id text=$actionTitle class=$action.buttonClass}
            {/if}
        {/foreach}
            {formbutton id='btnCancel' commandName='cancel' __text='Cancel' class='«IF container.application.targets('1.3.5')»z-bt-cancel«ELSE»btn btn-default«ENDIF»'}
        «IF !container.application.targets('1.3.5')»
            </div>
        «ENDIF»
        </div>
    '''
}
