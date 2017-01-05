package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MailzView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Mailz/'
        val templateExtension = '.twig'
        var entityTemplate = ''
        for (entity : getAllEntities) {
            entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + '.text' + templateExtension
            if (!shouldBeSkipped(entityTemplate)) {
                if (shouldBeMarked(entityTemplate)) {
                    entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + '.generated.text' + templateExtension
                }
                fsa.generateFile(entityTemplate, entity.textTemplate(it))
            }
            entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + '.html' + templateExtension
            if (!shouldBeSkipped(entityTemplate)) {
                if (shouldBeMarked(entityTemplate)) {
                    entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + '.generated.html' + templateExtension
                }
                fsa.generateFile(entityTemplate, entity.htmlTemplate(it))
            }
        }
    }

    def private textTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» in text mailings #}
        {% for «name.formatForCode» in items %}
        «mailzEntryText(app.appName)»
        -----
        {% else %}
        {{ __('No «nameMultiple.formatForDisplay» found.') }}
        {% endfor %}
    '''

    def private htmlTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» in html mailings #}
        «IF app.generateListContentType»{#«ENDIF»
        <ul>
        {% for «name.formatForCode» in items %}
            <li>
                «mailzEntryHtml(app)»
            </li>
        {% else %}
            <li>{{ __('No «nameMultiple.formatForDisplay» found.') }}</li>
        {% endfor %}
        </ul>
        «IF app.generateListContentType»#}

        {{ include('@«app.appName»/ContentType/itemlist_«name.formatForCode»_display_description.html.twig') }}«ENDIF»
    '''

    def private mailzEntryText(Entity it, String appName) '''
        {{ «name.formatForCode».getTitleFromDisplayPattern() }}
        «mailzEntryHtmlLinkUrl(application)»
    '''

    def private mailzEntryHtml(Entity it, Application app) '''
        <a href="«mailzEntryHtmlLinkUrl(app)»">{{ «name.formatForCode».getTitleFromDisplayPattern() }}</a>
    '''

    def private mailzEntryHtmlLinkUrl(Entity it, Application app) '''
        «IF hasDisplayAction»
            {{ url('«app.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}
        «ELSEIF hasViewAction»
            {{ url('«app.appName.formatForDB»_«name.formatForDB»_view') }}
        «ELSEIF hasIndexAction»
            {{ url('«app.appName.formatForDB»_«name.formatForDB»_index') }}
        «ELSE»
            {{ app.request.getSchemeAndHttpHost() ~ app.request.getBasePath() }}
        «ENDIF»'''
}
