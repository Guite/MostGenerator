package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Emails {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        val entitiesWithWorkflow = getAllEntities.filter[workflow != EntityWorkflowType.NONE]
        if (entitiesWithWorkflow.empty) {
            return
        }

        val templatePath = getViewPath + 'Email/'
        val templateExtension = '.html.twig'

        for (entity : entitiesWithWorkflow) {
            var fileName = 'notify' + entity.name.formatForCodeCapital + 'Creator' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'notify' + entity.name.formatForCodeCapital + 'Creator.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, entity.notifyCreatorTemplate)
            }

            fileName = 'notify' + entity.name.formatForCodeCapital + 'Moderator' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'notify' + entity.name.formatForCodeCapital + 'Moderator.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, entity.notifyModeratorTemplate)
            }
        }
    }

    def private notifyCreatorTemplate(Entity it) '''
        <p>{{ __f('Hello %s', { '%s': recipient.name }) }},</p>

        <p>{{ __f('Your «name.formatForDisplay» "%s" has been changed.', { '%s': mailData.name }) }}</p>

        <p>{{ __f("It's new state is: %s", { '%s': mailData.newState }) }}</p>

        {% if mailData.remarks is not empty %}
            <p>{{ __('Additional remarks:') }}<br />{{ mailData.remarks|nl2br }}</p>
        {% endif %}

        {% if mailData.newState != __('Deleted') %}
            «IF application.hasUserController»
                «IF application.getMainUserController.hasActions('display')»
                    <p>{{ __('Link to your «name.formatForDisplay»:') }} <a href="{{ mailData.displayUrl|e('html_attr') }}" title="{{ mailData.name|e('html_attr') }}">{{ mailData.displayUrl }}</a></p>
                «ENDIF»
                «IF application.getMainUserController.hasActions('edit')»
                    <p>{{ __('Edit your «name.formatForDisplay»:') }} <a href="{{ mailData.editUrl|e('html_attr') }}" title="{{ __('Edit') }}">{{ mailData.editUrl }}</a></p>
                «ENDIF»
            «ENDIF»
        {% endif %}

        <p>{{ __f('This mail has been sent automatically by %s.', { '%s': getModVar('ZConfig', 'sitename') }) }}</p>
    '''

    def private notifyModeratorTemplate(Entity it) '''
        <p>{{ __f('Hello %s', { '%s': recipient.name }) }},</p>

        <p>{{ __f('A user changed his «name.formatForDisplay» "%s".', { '%s': mailData.name }) }}</p>

        <p>{{ __f("It's new state is: %s", { '%s': mailData.newState }) }}</p>

        {% if mailData.remarks is not empty %}
            <p>{{ __('Additional remarks:') }}<br />{{ mailData.remarks|nl2br }}</p>
        {% endif %}

        {% if mailData.newState != __('Deleted') %}
            «IF application.hasAdminController && application.getAllAdminControllers.head.hasActions('display')
                || application.hasUserController && application.getMainUserController.hasActions('display')»
                <p>{{ __('Link to the «name.formatForDisplay»:') }} <a href="{{ mailData.displayUrl|e('html_attr') }}" title="{{ mailData.name|e('html_attr') }}">{{ mailData.displayUrl }}</a></p>
            «ENDIF»
            «IF application.hasAdminController && application.getAllAdminControllers.head.hasActions('edit')
                || application.hasUserController && application.getMainUserController.hasActions('edit')»
                <p>{{ __('Edit the «name.formatForDisplay»:') }} <a href="{{ mailData.editUrl|e('html_attr') }}" title="{{ __('Edit') }}">{{ mailData.editUrl }}</a></p>
            «ENDIF»
        {% endif %}

        <p>{{ __f('This mail has been sent automatically by %s.', { '%s': getModVar('ZConfig', 'sitename') }) }}</p>
    '''
}
