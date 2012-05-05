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
import org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents.Relations

class Section {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()

    Relations relationHelper = new Relations()
    IFileSystemAccess fsa

    /**
     * Entry point for edit sections beside the actual fields.
     */
    def generate(Entity it, Application app, Controller controller, IFileSystemAccess fsa) '''
        «this.fsa = fsa»
        «extensionsAndRelations(app, controller)»

        «displayHooks(app)»

        «returnControl»

        «submitActions»
    '''

    def private extensionsAndRelations(Entity it, Application app, Controller controller) '''
        «IF attributable»
            {include file='«controller.formattedName»/include_attributes_edit.tpl' obj=$«name.formatForDB»}
        «ENDIF»
        «IF categorisable»
            {include file='«controller.formattedName»/include_categories_edit.tpl' obj=$«name.formatForDB» groupName='«name.formatForDB»Obj'}
        «ENDIF»
        «IF standardFields»
            {if $mode ne 'create'}
                {include file='«controller.formattedName»/include_standardfields_edit.tpl' obj=$«name.formatForDB»}
            {/if}
        «ENDIF»
        «IF metaData»
            {include file='«controller.formattedName»/include_metadata_edit.tpl' obj=$«name.formatForDB»}
        «ENDIF»
        «FOR relation : getBidirectionalIncomingJoinRelations»«relationHelper.generate(relation, app, controller, true, true, fsa)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«relationHelper.generate(relation, app, controller, true, false, fsa)»«ENDFOR»
    '''

    def private displayHooks(Entity it, Application app) '''
        {* include display hooks *}
        {if $mode eq 'create'}
            {notifydisplayhooks eventname='«app.name.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit' id=null assign='hooks'}
        {else}
            {notifydisplayhooks eventname='«app.name.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit' id=«IF !hasCompositeKeys»$«name.formatForDB».«getFirstPrimaryKey.name.formatForCode»«ELSE»"«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForDB».«pkField.name.formatForCode»`«ENDFOR»"«ENDIF» assign='hooks'}
        {/if}
        {if is_array($hooks) && count($hooks)}
            <fieldset>
                <legend>{gt text='Hooks'}</legend>
                {foreach key='providerArea' item='hook' from=$hooks}
                    <div class="z-formrow">
                        {$hook}
                    </div>
                {/foreach}
            </fieldset>
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
