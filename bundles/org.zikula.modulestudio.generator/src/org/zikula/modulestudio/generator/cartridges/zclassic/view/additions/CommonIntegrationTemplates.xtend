package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class CommonIntegrationTemplates {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa, String templatePath) {
        val templateExtension = '.html.twig'
        var fileName = ''
        for (entity : getAllEntities) {
            fileName = 'itemlist_' + entity.name.formatForCode + '_display_description' + templateExtension
            fsa.generateFile(templatePath + fileName, entity.displayDescTemplate(it))

            fileName = 'itemlist_' + entity.name.formatForCode + '_display' + templateExtension
            fsa.generateFile(templatePath + fileName, entity.displayTemplate(it))
        }
        fileName = 'itemlist_display' + templateExtension
        fsa.generateFile(templatePath + fileName, fallbackDisplayTemplate)
    }

    def private displayDescTemplate(Entity it, Application app) '''
        {# purpose of this template: Display «nameMultiple.formatForDisplay» within an external context #}
        «IF !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        <dl>
            {% for «name.formatForCode» in items %}
                <dt>{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}</dt>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty»
                    {% if «name.formatForCode».«textFields.head.name.formatForCode» %}
                        <dd>{{ «name.formatForCode».«textFields.head.name.formatForCode»|striptags|u.truncate(200, '…') }}</dd>
                    {% endif %}
                «ELSE»
                    «val stringFields = fields.filter(StringField).filter[role != StringRole.PASSWORD]»
                    «IF !stringFields.empty»
                        {% if «name.formatForCode».«stringFields.head.name.formatForCode» %}
                            <dd>{{ «name.formatForCode».«stringFields.head.name.formatForCode»|striptags|u.truncate(200, '…') }}</dd>
                        {% endif %}
                    «ENDIF»
                «ENDIF»
                «IF hasDisplayAction»
                    <dd>«detailLink»</dd>
                «ENDIF»
            {% else %}
                <dt>{% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}</dt>
            {% endfor %}
        </dl>
    '''

    def private displayTemplate(Entity it, Application app) '''
        {# purpose of this template: Display «nameMultiple.formatForDisplay» within an external context #}
        «IF !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% for «name.formatForCode» in items %}
            <h3>{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}</h3>
            «IF hasDisplayAction»
                <p>«detailLink»</p>
            «ENDIF»
        {% endfor %}
    '''

    def private fallbackDisplayTemplate(Application it) '''
        {# purpose of this template: Display objects within an external context #}
    '''

    def private detailLink(Entity it) '''
        <a href="{{ path('«application.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}" title="{{ 'Read more'|trans|e('html_attr') }}">{% trans %}Read more{% endtrans %}</a>
    '''
}
