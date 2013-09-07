package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MailzView {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension UrlExtensions = new UrlExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) 'mailz' else 'Mailz') + '/'
        for (entity : getAllEntities) {
            fsa.generateFile(templatePath + 'itemlist_' + entity.name.formatForCode + '_text.tpl', entity.textTemplate(it))
            fsa.generateFile(templatePath + 'itemlist_' + entity.name.formatForCode + '_html.tpl', entity.htmlTemplate(it))
        }
    }

    def private textTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» in text mailings *}
        {foreach item='«name.formatForCode»' from=$items}
        «mailzEntryText(app.appName)»
        -----
        {foreachelse}
        {gt text='No «nameMultiple.formatForDisplay» found.'}
        {/foreach}
    '''

    def private htmlTemplate(Entity it, Application app) '''
        {* Purpose of this template: Display «nameMultiple.formatForDisplay» in html mailings *}
        {*
        <ul>
        {foreach item='«name.formatForCode»' from=$items}
            <li>
                «mailzEntryHtml(app)»
            </li>
        {foreachelse}
            <li>{gt text='No «nameMultiple.formatForDisplay» found.'}</li>
        {/foreach}
        </ul>
        *}

        {include file='«IF app.targets('1.3.5')»contenttype«ELSE»ContentType«ENDIF»/itemlist_«name.formatForCode»_display_description.tpl'}
    '''

    def private mailzEntryText(Entity it, String appName) '''
        «val leadingField = getLeadingField»
        «IF leadingField !== null»
            {$«name.formatForCode».«leadingField.name.formatForCode»}
        «ENDIF»
        {modurl modname='«appName»' type='user' «modUrlDisplayWithFreeOt(name.formatForCode, true, '$objectType')» fqurl=true}
    '''

    def private mailzEntryHtml(Entity it, Application app) '''
        «IF app.hasUserController && app.getMainUserController.hasActions('display')»
            <a href="«mailzEntryHtmlLinkUrlDisplay(app)»">«mailzEntryHtmlLinkText(app)»</a>
        «ELSE»
            <a href="«mailzEntryHtmlLinkUrlMain(app)»">«mailzEntryHtmlLinkText(app)»</a>
        «ENDIF»
    '''

    def private mailzEntryHtmlLinkUrlDisplay(Entity it, Application app) '''
        {modurl modname='«app.appName»' type='user' «modUrlDisplayWithFreeOt(name.formatForCode, true, '$objectType')» fqurl=true}'''

    def private mailzEntryHtmlLinkUrlMain(Entity it, Application app) '''
        «IF app.hasUserController»
            «IF app.getMainUserController.hasActions('view')»
                {modurl modname='«app.appName»' type='user' func='view' fqurl=true}
            «ELSEIF app.getMainUserController.hasActions('index')»
                {modurl modname='«app.appName»' type='user' func='«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»' fqurl=true}
            «ELSE»
                {modurl modname='«app.appName»' type='user' func='«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»' fqurl=true}
            «ENDIF»
        «ELSE»
            {homepage}
        «ENDIF»'''

    def private mailzEntryHtmlLinkText(Entity it, Application app) '''
        «val leadingField = getLeadingField»
        «IF leadingField !== null»{$«name.formatForCode».«leadingField.name.formatForCode»}
        «ELSE»{gt text='«name.formatForDisplayCapital»'}
        «ENDIF»
    '''
}
