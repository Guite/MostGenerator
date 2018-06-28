package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Emails {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        val entitiesWithWorkflow = getAllEntities.filter[workflow != EntityWorkflowType.NONE]
        if (entitiesWithWorkflow.empty) {
            return
        }

        val templatePath = getViewPath + 'Email/'
        val templateExtension = '.html.twig'

        for (entity : entitiesWithWorkflow) {
            var fileName = 'notify' + entity.name.formatForCodeCapital + 'Creator' + templateExtension
            fsa.generateFile(templatePath + fileName, entity.notifyCreatorTemplate)

            fileName = 'notify' + entity.name.formatForCodeCapital + 'Moderator' + templateExtension
            fsa.generateFile(templatePath + fileName, entity.notifyModeratorTemplate)
        }
    }

    def private notifyCreatorTemplate(Entity it) '''
        <p>{{ __f('Hello %recipient%', {'%recipient%': recipient.name}) }},</p>

        <p>{{ __f('Your «name.formatForDisplay» "%entity%" has been changed.', {'%entity%': mailData.name}) }}</p>

        <p>{{ __f("It's new state is: %state%", {'%state%': mailData.newState}) }}</p>

        {% if mailData.remarks is not empty %}
            <p>{{ __('Additional remarks:') }}<br />{{ mailData.remarks|nl2br }}</p>
        {% endif %}

        {% if mailData.newState != __('Deleted') %}
            «IF hasDisplayAction»
                <p>{{ __('Link to your «name.formatForDisplay»:') }} <a href="{{ mailData.displayUrl|e('html_attr') }}" title="{{ mailData.name|e('html_attr') }}">{{ mailData.displayUrl }}</a></p>
            «ENDIF»
            «IF hasEditAction»
                <p>{{ __('Edit your «name.formatForDisplay»:') }} <a href="{{ mailData.editUrl|e('html_attr') }}" title="{{ __('Edit') }}">{{ mailData.editUrl }}</a></p>
            «ENDIF»
        {% endif %}

        <p>{{ __f('This mail has been sent automatically by %siteName%.', {'%siteName%': getSystemVar('sitename')}) }}</p>
    '''

    def private notifyModeratorTemplate(Entity it) '''
        <p>{{ __f('Hello %recipient%', {'%recipient%': recipient.name}) }},</p>

        <p>{{ __f('A user changed his «name.formatForDisplay» "%entity%".', {'%entity%': mailData.name}) }}</p>

        <p>{{ __f("It's new state is: %state%", {'%state%': mailData.newState}) }}</p>

        {% if mailData.remarks is not empty %}
            <p>{{ __('Additional remarks:') }}<br />{{ mailData.remarks|nl2br }}</p>
        {% endif %}

        {% if mailData.newState != __('Deleted') %}
            «IF hasDisplayAction»
                <p>{{ __('Link to the «name.formatForDisplay»:') }} <a href="{{ mailData.displayUrl|e('html_attr') }}" title="{{ mailData.name|e('html_attr') }}">{{ mailData.displayUrl }}</a></p>
            «ENDIF»
            «IF hasEditAction»
                <p>{{ __('Edit the «name.formatForDisplay»:') }} <a href="{{ mailData.editUrl|e('html_attr') }}" title="{{ __('Edit') }}">{{ mailData.editUrl }}</a></p>
            «ENDIF»
        {% endif %}

        <p>{{ __f('This mail has been sent automatically by %siteName%.', {'%siteName%': getSystemVar('sitename')}) }}</p>
    '''
}
