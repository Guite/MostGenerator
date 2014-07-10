package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityWorkflowType
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

        «displayHooks(app)»

        «additionalRemark»

        «returnControl»

        «submitActions»
    '''

    def private extensionsAndRelations(Entity it, Application app, IFileSystemAccess fsa) '''
        «IF geographical»
            «IF useGroupingPanels('edit')»
                «IF app.targets('1.3.5')»
                    <h3 class="«app.appName.toLowerCase»-map z-panel-header z-panel-indicator «IF app.targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Map'}</h3>
                    <fieldset class="«app.appName.toLowerCase»-map z-panel-content" style="display: none">
                «ELSE»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseMap">{gt text='Map'}</a></h3>
                        </div>
                        <div id="collapseMap" class="panel-collapse collapse in">
                            <div class="panel-body">
                «ENDIF»
            «ELSE»
                <fieldset class="«app.appName.toLowerCase»-map">
            «ENDIF»
                <legend>{gt text='Map'}</legend>
                <div id="mapContainer" class="«app.appName.toLowerCase»-mapcontainer">
                </div>
            «IF app.targets('1.3.5')»
                </fieldset>
            «ELSE»
                        </div>
                    </div>
                </div>
            «ENDIF»

        «ENDIF»
        «IF attributable»
            {include file='«IF app.targets('1.3.5')»helper«ELSE»Helper«ENDIF»/include_attributes_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «IF categorisable»
            {include file='«IF app.targets('1.3.5')»helper«ELSE»Helper«ENDIF»/include_categories_edit.tpl' obj=$«name.formatForDB» groupName='«name.formatForDB»Obj'«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «relationHelper.generateIncludeStatement(it, app, fsa)»
        «IF metaData»
            {include file='«IF app.targets('1.3.5')»helper«ELSE»Helper«ENDIF»/include_metadata_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «IF standardFields»
            {if $mode ne 'create'}
                {include file='«IF app.targets('1.3.5')»helper«ELSE»Helper«ENDIF»/include_standardfields_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
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
            {foreach name='hookLoop' key='providerArea' item='hook' from=$hooks}
                «IF useGroupingPanels('edit')»
                    «IF app.targets('1.3.5')»
                        <h3 class="hook z-panel-header z-panel-indicator «IF app.targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{$providerArea}</h3>
                        <fieldset class="hook z-panel-content" style="display: none">{$hook}</div>
                    «ELSE»
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseHook{$smarty.foreach.hookLoop.iteration}">{$providerArea}</a></h3>
                            </div>
                            <div id="collapseHook{$smarty.foreach.hookLoop.iteration}" class="panel-collapse collapse in">
                                <div class="panel-body">
                    «ENDIF»
                «ELSE»
                    <fieldset>
                «ENDIF»
                    {$hook}
                «IF app.targets('1.3.5')»
                    </fieldset>
                «ELSE»
                            </div>
                        </div>
                    </div>
                «ENDIF»
            {/foreach}
        {/if}
    '''

    def private additionalRemark(Entity it) '''
        «IF workflow != EntityWorkflowType.NONE»
            <fieldset>
                <legend>{gt text='Communication'}</legend>
                <div class="«IF isLegacyApp»z-formrow«ELSE»form-group«ENDIF»">
                    {usergetvar name='uid' assign='uid'}
                    {formlabel for='additionalNotificationRemarks' __text='Additional remarks'«IF !isLegacyApp» cssClass='col-lg-3 control-label'«ENDIF»}
                    {gt text='Enter any additions about your changes' assign='fieldTitle'}
                    {if $mode eq 'create'}
                        {gt text='Enter any additions about your content' assign='fieldTitle'}
                    {/if}
                    {formtextinput group='«name.formatForDB»' id='additionalNotificationRemarks' mandatory=false title=$fieldTitle textMode='multiline' rows='6«/*8*/»'«IF isLegacyApp» cols='50'«ENDIF»}
                    {if $isModerator || $isSuperModerator}
                        <span class="«IF isLegacyApp»z-formnote«ELSE»help-block«ENDIF»">{gt text='These remarks (like a reason for deny) are not stored, but added to any notification emails send to the creator.'}</span>
                    {elseif $isCreator}
                        <span class="«IF isLegacyApp»z-formnote«ELSE»help-block«ENDIF»">{gt text='These remarks (like questions about conformance) are not stored, but added to any notification emails send to our moderators.'}</span>
                    {/if}
                </div>
            </fieldset>
        «ENDIF»
    '''

    def private returnControl(Entity it) '''
        {* include return control *}
        {if $mode eq 'create'}
            <fieldset>
                <legend>{gt text='Return control'}</legend>
                <div class="«IF isLegacyApp»z-formrow«ELSE»form-group«ENDIF»">
                    {formlabel for='repeatCreation' __text='Create another item after save'«IF !isLegacyApp» cssClass='col-lg-3 control-label'«ENDIF»}
                «IF !isLegacyApp»
                    <div class="col-lg-9">
                «ENDIF»
                        {formcheckbox group='«name.formatForDB»' id='repeatCreation' readOnly=false}
                «IF !isLegacyApp»
                    </div>
                «ENDIF»
                </div>
            </fieldset>
        {/if}
    '''

    def private submitActions(Entity it) '''
        {* include possible submit actions *}
        <div class="«IF isLegacyApp»z-buttons z-formbuttons«ELSE»form-group form-buttons«ENDIF»">
        «IF !isLegacyApp»
            <div class="col-lg-offset-3 col-lg-9">
                «submitActionsImpl»
            </div>
        «ELSE»
            «submitActionsImpl»
        «ENDIF»
        </div>
    '''

    def private submitActionsImpl(Entity it) '''
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
        {formbutton id='btnCancel' commandName='cancel' __text='Cancel' class='«IF isLegacyApp»z-bt-cancel«ELSE»btn btn-default«ENDIF»'}
    '''

    def private isLegacyApp(Entity it) {
        container.application.targets('1.3.5')
    }
}
