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
        val templatePath = getViewPath + (if (targets('1.3.x')) 'mailz' else 'Mailz') + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.twig'
        var entityTemplate = ''
        for (entity : getAllEntities) {
            entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + (if (targets('1.3.x')) '_text' else '.text') + templateExtension
            if (!shouldBeSkipped(entityTemplate)) {
                if (shouldBeMarked(entityTemplate)) {
                    entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + (if (targets('1.3.x')) '_text.generated' else '.generated.text') + templateExtension
                }
                fsa.generateFile(entityTemplate, if (targets('1.3.x')) entity.textTemplateLegacy(it) else entity.textTemplate(it))
            }
            entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + (if (targets('1.3.x')) '_html' else '.html') + templateExtension
            if (!shouldBeSkipped(entityTemplate)) {
                if (shouldBeMarked(entityTemplate)) {
                    entityTemplate = templatePath + 'itemlist_' + entity.name.formatForCode + (if (targets('1.3.x')) '_html.generated' else '.generated.html') + templateExtension
                }
                fsa.generateFile(entityTemplate, if (targets('1.3.x')) entity.htmlTemplateLegacy(it) else entity.htmlTemplate(it))
            }
        }
    }

    def private textTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» in text mailings *}
        {foreach item='«name.formatForCode»' from=$items}
        «mailzEntryText(app.appName)»
        -----
        {foreachelse}
        {gt text='No «nameMultiple.formatForDisplay» found.'}
        {/foreach}
    '''

    def private textTemplate(Entity it, Application app) '''
        {# Purpose of this template: Display «nameMultiple.formatForDisplay» in text mailings #}
        {% for «name.formatForCode» in items %}
        «mailzEntryText(app.appName)»
        -----
        {% else %}
        {{ __('No «nameMultiple.formatForDisplay» found.') }}
        {% endfor %}
    '''

    def private htmlTemplateLegacy(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» in html mailings *}
        «IF app.generateListContentType»{*«ENDIF»
        <ul>
        {foreach item='«name.formatForCode»' from=$items}
            <li>
                «mailzEntryHtml(app)»
            </li>
        {foreachelse}
            <li>{gt text='No «nameMultiple.formatForDisplay» found.'}</li>
        {/foreach}
        </ul>
        «IF app.generateListContentType»*}

        {include file='contenttype/itemlist_«name.formatForCode»_display_description.tpl'}«ENDIF»
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
        «IF application.targets('1.3.x')»
            {$«name.formatForCode»->getTitleFromDisplayPattern()}
        «ELSE»
            {{ «name.formatForCode».getTitleFromDisplayPattern() }}
        «ENDIF»
        «mailzEntryHtmlLinkUrlDisplay(application)»
    '''

    def private mailzEntryHtml(Entity it, Application app) '''
        «IF app.hasUserController && app.getMainUserController.hasActions('display')»
            <a href="«mailzEntryHtmlLinkUrlDisplay(app)»">«mailzEntryHtmlLinkText(app)»</a>
        «ELSE»
            <a href="«mailzEntryHtmlLinkUrlMain(app)»">«mailzEntryHtmlLinkText(app)»</a>
        «ENDIF»
    '''

    def private mailzEntryHtmlLinkUrlDisplay(Entity it, Application app) '''
        «IF application.targets('1.3.x')»
            {modurl modname='«app.appName»' type='user' func='display' ot='«name.formatForCode»'«routeParamsLegacy(name.formatForCode, true, true)» fqurl=true}
        «ELSE»
            {{ url('«app.appName.formatForDB»_«name.formatForDB»_display'«routeParams(name.formatForCode, true)») }}
        «ENDIF»'''

    def private mailzEntryHtmlLinkUrlMain(Entity it, Application app) '''
        «IF app.hasUserController»
            «IF app.targets('1.3.x')»
                «IF app.getMainUserController.hasActions('view')»
                    {modurl modname='«app.appName»' type='user' func='view' fqurl=true}
                «ELSEIF app.getMainUserController.hasActions('index')»
                    {modurl modname='«app.appName»' type='user' func='main' fqurl=true}
                «ELSE»
                    {modurl modname='«app.appName»' type='user' func='main' fqurl=true}
                «ENDIF»
            «ELSE»
                «IF app.getMainUserController.hasActions('view')»
                    {{ url('«app.appName.formatForDB»_«name.formatForDB»_view') }}
                «ELSEIF app.getMainUserController.hasActions('index')»
                    {{ url('«app.appName.formatForDB»_«name.formatForDB»_index') }}
                «ELSE»
                    {{ url('«app.appName.formatForDB»_«name.formatForDB»_index') }}
                «ENDIF»
            «ENDIF»
        «ELSE»
            «IF app.targets('1.3.x')»{homepage}«ELSE»{{ pagevars.homepath }}«ENDIF»
        «ENDIF»'''

    def private mailzEntryHtmlLinkText(Entity it, Application app) '''
        «IF app.targets('1.3.x')»
            {$«name.formatForCode»->getTitleFromDisplayPattern()}
        «ELSE»
            {{ «name.formatForCode».getTitleFromDisplayPattern() }}
        «ENDIF»
    '''
}
