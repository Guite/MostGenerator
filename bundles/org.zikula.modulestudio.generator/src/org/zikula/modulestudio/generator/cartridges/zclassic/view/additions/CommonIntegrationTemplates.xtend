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
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context #}
        <dl>
            {% for «name.formatForCode» in items %}
                <dt>{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}</dt>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty»
                    {% if «name.formatForCode».«textFields.head.name.formatForCode» %}
                        <dd>{{ «name.formatForCode».«textFields.head.name.formatForCode»|striptags|truncate(200, true, '…') }}</dd>
                    {% endif %}
                «ELSE»
                    «val stringFields = fields.filter(StringField).filter[role != StringRole.PASSWORD]»
                    «IF !stringFields.empty»
                        {% if «name.formatForCode».«stringFields.head.name.formatForCode» %}
                            <dd>{{ «name.formatForCode».«stringFields.head.name.formatForCode»|striptags|truncate(200, true, '…') }}</dd>
                        {% endif %}
                    «ENDIF»
                «ENDIF»
                «IF hasDisplayAction»
                    <dd>«detailLink(app.appName)»</dd>
                «ENDIF»
            {% else %}
                <dt>{{ __('No entries found.') }}</dt>
            {% endfor %}
        </dl>
    '''

    def private displayTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» within an external context #}
        {% for «name.formatForCode» in items %}
            <h3>{{ «name.formatForCode»|«app.appName.formatForDB»_formattedTitle }}</h3>
            «IF hasDisplayAction»
                <p>«detailLink(app.appName)»</p>
            «ENDIF»
        {% endfor %}
    '''

    def private fallbackDisplayTemplate(Application it) '''
        {# Purpose of this template: Display objects within an external context #}
    '''

    def private detailLink(Entity it, String appName) '''
        <a href="{{ path('«appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}" title="{{ __('Read more')|e('html_attr') }}">{{ __('Read more') }}</a>
    '''
}
