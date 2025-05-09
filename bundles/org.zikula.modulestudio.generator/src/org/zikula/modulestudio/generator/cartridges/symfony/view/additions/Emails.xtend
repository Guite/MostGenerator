package org.zikula.modulestudio.generator.cartridges.symfony.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Emails {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        val entitiesWithWorkflow = entities.filter[approval]
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
        {% trans_default_domain 'mail' %}
        <p>{% trans with {'%recipient%': recipient.name} %}Hello %recipient%{% endtrans %},</p>

        <p>{% trans with {'%entity%': mailData.name} %}Your «name.formatForDisplay» "%entity%" has been changed.{% endtrans %}</p>

        <p>{% trans with {'%state%': mailData.newState} %}Its new state is: %state%{% endtrans %}</p>

        {% if mailData.remarks is not empty %}
            <p>{% trans %}Additional remarks:{% endtrans %}<br />{{ mailData.remarks|nl2br }}</p>
        {% endif %}

        {% if mailData.newState != 'Deleted'|trans %}
            «IF hasDetailAction»
                <p>{% trans %}Link to your «name.formatForDisplay»:{% endtrans %} <a href="{{ mailData.detailUrl|e('html_attr') }}" title="{{ mailData.name|e('html_attr') }}">{{ mailData.detailUrl }}</a></p>
            «ENDIF»
            «IF hasEditAction»
                <p>{% trans %}Edit your «name.formatForDisplay»:{% endtrans %} <a href="{{ mailData.editUrl|e('html_attr') }}" title="{% trans %}Edit{% endtrans %}">{{ mailData.editUrl }}</a></p>
            «ENDIF»
        {% endif %}

        <p>{% trans with {'%siteName%': siteName()} %}This mail has been sent automatically by %siteName%.{% endtrans %}</p>
    '''

    def private notifyModeratorTemplate(Entity it) '''
        {# purpose of this template: Email for notification sent to content moderator #}
        {% trans_default_domain 'mail' %}
        <p>{% trans with {'%recipient%': recipient.name} %}Hello %recipient%{% endtrans %},</p>

        «IF standardFields»
            <p>{% trans with {'%entity%': mailData.name, '%editor%': mailData.editor} %}%editor% changed the «name.formatForDisplay» "%entity%".{% endtrans %}</p>
        «ELSE»
            <p>{% trans with {'%entity%': mailData.name} %}A user changed the «name.formatForDisplay» "%entity%".{% endtrans %}</p>
        «ENDIF»

        <p>{% trans with {'%state%': mailData.newState} %}Its new state is: %state%{% endtrans %}</p>

        {% if mailData.remarks is not empty %}
            <p>{% trans %}Additional remarks:{% endtrans %}<br />{{ mailData.remarks|nl2br }}</p>
        {% endif %}

        {% if mailData.newState != 'Deleted'|trans %}
            «IF hasDetailAction»
                <p>{% trans %}Link to the «name.formatForDisplay»:{% endtrans %} <a href="{{ mailData.detailUrl|e('html_attr') }}" title="{{ mailData.name|e('html_attr') }}">{{ mailData.detailUrl }}</a></p>
            «ENDIF»
            «IF hasEditAction»
                <p>{% trans %}Edit the «name.formatForDisplay»:{% endtrans %} <a href="{{ mailData.editUrl|e('html_attr') }}" title="{% trans %}Edit{% endtrans %}">{{ mailData.editUrl }}</a></p>
            «ENDIF»
        {% endif %}

        <p>{% trans with {'%siteName%': siteName()} %}This mail has been sent automatically by %siteName%.{% endtrans %}</p>
    '''
}
