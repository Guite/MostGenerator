package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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
        {# purpose of this template: Email for notification sent to content creator #}
        «IF application.targets('3.0')»
            {% trans_default_domain 'mail' %}
        «ENDIF»
        «IF application.targets('3.0')»
            <p>{% trans with {'%recipient%': recipient.name} %}Hello %recipient%{% endtrans %},</p>

            <p>{% trans with {'%entity%': mailData.name} %}Your «name.formatForDisplay» "%entity%" has been changed.{% endtrans %}</p>

            <p>{% trans with {'%state%': mailData.newState} %}Its new state is: %state%{% endtrans %}</p>

            {% if mailData.remarks is not empty %}
                <p>{% trans %}Additional remarks:{% endtrans %}<br />{{ mailData.remarks|nl2br }}</p>
            {% endif %}

            {% if mailData.newState != 'Deleted'|trans %}
                «IF hasDisplayAction»
                    <p>{% trans %}Link to your «name.formatForDisplay»:{% endtrans %} <a href="{{ mailData.displayUrl|e('html_attr') }}" title="{{ mailData.name|e('html_attr') }}">{{ mailData.displayUrl }}</a></p>
                «ENDIF»
                «IF hasEditAction»
                    <p>{% trans %}Edit your «name.formatForDisplay»:{% endtrans %} <a href="{{ mailData.editUrl|e('html_attr') }}" title="{% trans %}Edit{% endtrans %}">{{ mailData.editUrl }}</a></p>
                «ENDIF»
            {% endif %}

            <p>{% trans with {'%siteName%': getSystemVar('sitename')} %}This mail has been sent automatically by %siteName%.{% endtrans %}</p>
        «ELSE»
            <p>{{ __f('Hello %recipient%', {'%recipient%': recipient.name}) }},</p>

            <p>{{ __f('Your «name.formatForDisplay» "%entity%" has been changed.', {'%entity%': mailData.name}) }}</p>

            <p>{{ __f('Its new state is: %state%', {'%state%': mailData.newState}) }}</p>

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
        «ENDIF»
    '''

    def private notifyModeratorTemplate(Entity it) '''
        {# purpose of this template: Email for notification sent to content moderator #}
        «IF application.targets('3.0')»
            {% trans_default_domain 'mail' %}
        «ENDIF»
        «IF application.targets('3.0')»
            <p>{% trans with {'%recipient%': recipient.name} %}Hello %recipient%{% endtrans %},</p>

            «IF standardFields»
                <p>{% trans with {'%entity%': mailData.name, '%editor%': mailData.editor} %}%editor% changed a «name.formatForDisplay» "%entity%".{% endtrans %}</p>
            «ELSE»
                <p>{% trans with {'%entity%': mailData.name} %}A user changed his «name.formatForDisplay» "%entity%".{% endtrans %}</p>
            «ENDIF»

            <p>{% trans with {'%state%': mailData.newState} %}Its new state is: %state%{% endtrans %}</p>

            {% if mailData.remarks is not empty %}
                <p>{% trans %}Additional remarks:{% endtrans %}<br />{{ mailData.remarks|nl2br }}</p>
            {% endif %}

            {% if mailData.newState != 'Deleted'|trans %}
                «IF hasDisplayAction»
                    <p>{% trans %}Link to the «name.formatForDisplay»:{% endtrans %} <a href="{{ mailData.displayUrl|e('html_attr') }}" title="{{ mailData.name|e('html_attr') }}">{{ mailData.displayUrl }}</a></p>
                «ENDIF»
                «IF hasEditAction»
                    <p>{% trans %}Edit the «name.formatForDisplay»:{% endtrans %} <a href="{{ mailData.editUrl|e('html_attr') }}" title="{% trans %}Edit{% endtrans %}">{{ mailData.editUrl }}</a></p>
                «ENDIF»
            {% endif %}

            <p>{% trans with {'%siteName%': getSystemVar('sitename')} %}This mail has been sent automatically by %siteName%.{% endtrans %}</p>
        «ELSE»
            <p>{{ __f('Hello %recipient%', {'%recipient%': recipient.name}) }},</p>

            «IF standardFields»
                <p>{{ __f('%editor% changed a «name.formatForDisplay» "%entity%".', {'%entity%': mailData.name, '%editor%': mailData.editor}) }}</p>
            «ELSE»
                <p>{{ __f('A user changed his «name.formatForDisplay» "%entity%".', {'%entity%': mailData.name}) }}</p>
            «ENDIF»

            <p>{{ __f('Its new state is: %state%', {'%state%': mailData.newState}) }}</p>

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
        «ENDIF»
    '''
}
