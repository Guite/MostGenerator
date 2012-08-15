package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Section {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension ViewExtensions = new ViewExtensions()
    @Inject extension Utils = new Utils()

    Relations relationHelper = new Relations()

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
            <h3 class="map z-panel-header z-panel-indicator z-pointer">{gt text='Map'}</h3>
            <fieldset class="map z-panel-content" style="display: none">
            «ELSE»
            <fieldset>
                <legend>{gt text='Map'}</legend>
                <div id="mapContainer" class="«app.appName.formatForDB»MapContainer">
                </div>
            «ENDIF»
            </fieldset>

        «ENDIF»
        «IF attributable»
            {include file='«controller.formattedName»/include_attributes_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «IF categorisable»
            {include file='«controller.formattedName»/include_categories_edit.tpl' obj=$«name.formatForDB» groupName='«name.formatForDB»Obj'«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «IF standardFields»
            {if $mode ne 'create'}
                {include file='«controller.formattedName»/include_standardfields_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
            {/if}
        «ENDIF»
        «IF metaData»
            {include file='«controller.formattedName»/include_metadata_edit.tpl' obj=$«name.formatForDB»«IF useGroupingPanels('edit')» panel=true«ENDIF»}
        «ENDIF»
        «FOR relation : getBidirectionalIncomingJoinRelations.filter(e|e.source.container.application == app)»«relationHelper.generate(relation, app, controller, true, true, fsa)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations.filter(e|e.target.container.application == app)»«relationHelper.generate(relation, app, controller, true, false, fsa)»«ENDFOR»
    '''

    def private displayHooks(Entity it, Application app) '''
        {* include display hooks *}
        {if $mode eq 'create'}
            {notifydisplayhooks eventname='«app.name.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit' id=null assign='hooks'}
        {else}
            {notifydisplayhooks eventname='«app.name.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit' id=«IF !hasCompositeKeys»$«name.formatForDB».«getFirstPrimaryKey.name.formatForCode»«ELSE»"«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForDB».«pkField.name.formatForCode»`«ENDFOR»"«ENDIF» assign='hooks'}
        {/if}
        {if is_array($hooks) && count($hooks)}
            {foreach key='providerArea' item='hook' from=$hooks}
                «IF useGroupingPanels('edit')»
                    <h3 class="hook z-panel-header z-panel-indicator z-pointer">{$providerArea}</h3>
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
                <div class="z-formrow">
                    {formlabel for='repeatcreation' __text='Create another item after save'}
                    {formcheckbox group='«name.formatForDB»' id='repeatcreation' readOnly=false}
                </div>
            </fieldset>
        {/if}
    '''

    def private submitActions(Entity it) '''
        {* include possible submit actions *}
        <div class="z-buttons z-formbuttons">
            {if $mode eq 'edit'}
                {formbutton id='btnUpdate' commandName='update' __text='Update «name.formatForDisplay»' class='z-bt-save'}
              {if !$inlineUsage}
                {gt text='Really delete this «name.formatForDisplay»?' assign='deleteConfirmMsg'}
                {formbutton id='btnDelete' commandName='delete' __text='Delete «name.formatForDisplay»' class='z-bt-delete z-btred' confirmMessage=$deleteConfirmMsg}
              {/if}
            {elseif $mode eq 'create'}
                {formbutton id='btnCreate' commandName='create' __text='Create «name.formatForDisplay»' class='z-bt-ok'}
            {else}
                {formbutton id='btnUpdate' commandName='update«/*TODO*/»' __text='OK' class='z-bt-ok'}
            {/if}
            {formbutton id='btnCancel' commandName='cancel' __text='Cancel' class='z-bt-cancel'}
        </div>
        «/*
        {linkbutton commandName='edit' __text='Edit' class='z-icon-es-edit'}
        {button commandName='cancel' __text='Cancel' class='z-bt-cancel'}
        */»
    '''
}
