package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Emails {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val entitiesWithWorkflow = getAllEntities.filter[workflow != EntityWorkflowType.NONE]
        if (entitiesWithWorkflow.empty) {
            return
        }

        val templatePath = getViewPath + if (targets('1.3.5')) 'email' else 'Email' + '/'

        for (entity : entitiesWithWorkflow) {
            var fileName = 'notify' + entity.name.formatForCodeCapital + 'Creator.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'notify' + entity.name.formatForCodeCapital + 'Creator.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.notifyCreatorTemplate)
            }

            fileName = 'notify' + entity.name.formatForCodeCapital + 'Moderator.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'notify' + entity.name.formatForCodeCapital + 'Moderator.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, entity.notifyModeratorTemplate)
            }
        }
    }

    def private notifyCreatorTemplate(Entity it) '''
        <p>{gt text='Hello %s' tag=$recipient.name},</p>

        <p>{gt text='Your «name.formatForDisplay» "%s" has been changed.' tag=$mailData.name}</p>

        <p>{gt text='It\'s new state is: %s' tag=$mailData.newState}</p>

        {if $mailData.remarks ne ''}
            <p>{gt text='Additional remarks:'} {$mailData.remarks|safetext}</p>
        {/if}

        «IF application.hasUserController»

            «IF application.getMainUserController.hasActions('display')»
                <p>{gt text='Link to the «name.formatForDisplay»:'} <a href="{$mailData.displayUrl|safetext}" title="{$mailData.name|replace:'"':''}">{$mailData.displayUrl|safetext}</a></p>
            «ENDIF»
            «IF application.getMainUserController.hasActions('edit')»
                <p>{gt text='Edit your «name.formatForDisplay»:'} <a href="{$mailData.editUrl|safetext}" title="{gt text='Edit'}">{$mailData.editUrl|safetext}</a></p>
            «ENDIF»
        «ENDIF»

        <p>{gt text='This mail has been sent automatically by %s.' tag=$modvars.ZConfig.sitename}</p>
    '''

    def private notifyModeratorTemplate(Entity it) '''
        <p>{gt text='Hello %s' tag=$recipient.name},</p>

        <p>{gt text='A user changed his «name.formatForDisplay» "%s".' tag=$mailData.name}</p>

        <p>{gt text='It\'s new state is: %s' tag=$mailData.newState}</p>

        {if $mailData.remarks ne ''}
            <p>{gt text='Additional remarks:'} {$mailData.remarks|safetext}</p>
        {/if}

        «IF application.hasAdminController && application.getAllAdminControllers.head.hasActions('display')
            || application.hasUserController && application.getMainUserController.hasActions('display')»
            <p>{gt text='Link to the «name.formatForDisplay»:'} <a href="{$mailData.displayUrl|safetext}" title="{$mailData.name|replace:'"':''}">{$mailData.displayUrl|safetext}</a></p>
        «ENDIF»
        «IF application.hasAdminController && application.getAllAdminControllers.head.hasActions('edit')
            || application.hasUserController && application.getMainUserController.hasActions('edit')»
            <p>{gt text='Edit the «name.formatForDisplay»:'} <a href="{$mailData.editUrl|safetext}" title="{gt text='Edit'}">{$mailData.editUrl|safetext}</a></p>
        «ENDIF»

        <p>{gt text='This mail has been sent automatically by %s.' tag=$modvars.ZConfig.sitename}</p>
    '''
}
