package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MailzView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Mailz/'
        val templateExtension = '.twig'
        var entityTemplate = ''
        for (entity : getAllEntities) {
            entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + '.text' + templateExtension
            fsa.generateFile(entityTemplate, entity.textTemplate(it))

            entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + '.html' + templateExtension
            fsa.generateFile(entityTemplate, entity.htmlTemplate(it))
        }
    }

    def private textTemplate(Entity it, Application app) '''
        {# purpose of this template: Display «nameMultiple.formatForDisplay» in text mailings #}
        «IF !app.isSystemModule && app.targets('3.0')»
            {% trans_default_domain '«app.appName.formatForDB»' %}
        «ENDIF»
        {% for «name.formatForCode» in items %}
        «mailzEntryText»
        -----
        {% else %}
        «IF app.targets('3.0')»{% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}«ELSE»{{ __('No «nameMultiple.formatForDisplay» found.') }}«ENDIF»
        {% endfor %}
    '''

    def private htmlTemplate(Entity it, Application app) '''
        {# purpose of this template: Display «nameMultiple.formatForDisplay» in html mailings #}
        «IF !app.isSystemModule && app.targets('3.0')»
            {% trans_default_domain '«app.appName.formatForDB»' %}
        «ENDIF»
        «IF app.generateListContentType»{#«ENDIF»
        <ul>
        {% for «name.formatForCode» in items %}
            <li>
                «mailzEntryHtml»
            </li>
        {% else %}
            <li>«IF app.targets('3.0')»{% trans %}No «nameMultiple.formatForDisplay» found.{% endtrans %}«ELSE»{{ __('No «nameMultiple.formatForDisplay» found.') }}«ENDIF»</li>
        {% endfor %}
        </ul>
        «IF app.generateListContentType»#}

        {{ include('@«app.appName»/ContentType/itemlist_«name.formatForCode»_display_description.html.twig') }}«ENDIF»
    '''

    def private mailzEntryText(Entity it) '''
        {{ «name.formatForCode»|«application.appName.formatForDB»_formattedTitle }}
        «mailzEntryHtmlLinkUrl»
    '''

    def private mailzEntryHtml(Entity it) '''
        <a href="«mailzEntryHtmlLinkUrl»">{{ «name.formatForCode»|«application.appName.formatForDB»_formattedTitle }}</a>
    '''

    def private mailzEntryHtmlLinkUrl(Entity it) '''
        «IF hasDisplayAction»
            {{ url('«application.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}
        «ELSEIF hasViewAction»
            {{ url('«application.appName.formatForDB»_«name.formatForDB»_view') }}
        «ELSEIF hasIndexAction»
            {{ url('«application.appName.formatForDB»_«name.formatForDB»_index') }}
        «ELSE»
            {{ app.request.schemeAndHttpHost ~ app.request.basePath }}
        «ENDIF»'''
}
