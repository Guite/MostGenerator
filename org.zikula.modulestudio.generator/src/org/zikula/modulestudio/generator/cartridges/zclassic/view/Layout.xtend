package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.UserController
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Layout {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IFileSystemAccess fsa

    new(IFileSystemAccess fsa) {
	    this.fsa = fsa
    }

    // 1.4.x only
    def baseTemplates(Application it) {
        val templatePath = getViewPath
        val templateExtension = '.html.twig'
        var fileName = 'base' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'base.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, baseTemplate)
        }
        fileName = 'adminBase' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'adminBase.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, adminBaseTemplate)
        }

    }

    // 1.4.x only
    def baseTemplate(Application it) '''
        {# purpose of this template: general base layout #}
        {% block header %}
            {{ pageAddAsset('stylesheet', 'web/bootstrap/css/bootstrap.min.css') }}
            {{ pageAddAsset('stylesheet', 'web/bootstrap/css/bootstrap-theme.min.css') }}
            {{ pageAddAsset('javascript', 'jquery') }}
            {{ pageAddAsset('javascript', 'jquery-ui') }}
            {{ pageAddAsset('stylesheet', 'web/jquery-ui/themes/base/jquery-ui.min.css') }}
            {{ pageAddAsset('javascript', 'web/bootstrap/js/bootstrap.min.js') }}
            {{ pageAddAsset('javascript', 'zikula') }}{# still required for Gettext #}
            «IF hasUploads»
                {{ pageAddAsset('javascript', 'web/bootstrap-media-lightbox/bootstrap-media-lightbox.min.js') }}
                {{ pageAddAsset('stylesheet', 'web/bootstrap-media-lightbox/bootstrap-media-lightbox.css') }}
            «ENDIF»
            «IF hasViewActions || hasDisplayActions || hasEditActions»
                {{ pageAddAsset('stylesheet', 'web/bootstrap-jqueryui/bootstrap-jqueryui.min.css') }}
                {{ pageAddAsset('javascript', 'web/bootstrap-jqueryui/bootstrap-jqueryui.min.js') }}
                «IF hasEditActions»
                    {% if app.request.query.get('func') == 'edit' %}
                        {{ polyfill() }}
                    {% endif %}
                «ENDIF»
            «ENDIF»
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».js')) }}

            {# initialise additional gettext domain for translations within javascript #}
            {# blocked by https://github.com/zikula/core/issues/2601 #}
            {# commented out because not sure yet whether this is still required in 1.4.x #}
            {# { pageAddVar('jsgettext', '«appName.formatForDB»_js:«appName»') } #}
        {% endblock %}

        {% if app.request.query.get('theme') != 'Printer' %}
            {% block appTitle %}
                <h2 class="userheader">{{ __('«name.formatForDisplayCapital»') }}</h2>
            «/* TODO replace modulelinks, blocked by https://github.com/zikula/core/pull/2648 * /»
            {# modulelinks modname='«appName»' type='«controller.formattedName»' #}*/»
            {% endblock %}
        {% endif %}

        {% block titleArea %}
            <h2>{% block title %}{% endblock %}</h2>
        {% endblock %}
        {{ pageSetVar('title', block('title')) }}

        {% if app.request.query.get('theme') != 'Printer' %}
            «IF generateModerationPanel && needsApproval»
                {% set moderationObjects = «appName.formatForDB»_moderationObjects() %}
                {% if moderationObjects|length > 0 %}
                    {% for modItem in moderationObjects %}
                        <p class="alert alert-info alert-dismissable text-center">
                            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                            {% set itemObjectType = modItem.objectType|lower %}
                            <a href="{{ path('«appName.formatForDB»_' ~ itemObjectType ~ '_adminview', { 'workflowState': modItem.state }) }}" class="bold alert-link">{{ modItem.message }}</a>
                        </p>
                    {% endfor %}
                {% endif %}
            «ENDIF»
        {% endif %}

        {{ showflashes() }}

        {% block content %}{% endblock %}

        {% block footer %}
            {% if app.request.query.get('theme') != 'Printer' %}
                «IF generatePoweredByBacklinksIntoFooterTemplates»
                    «new FileHelper().msWeblink(it)»
                «ENDIF»
            «IF hasEditActions»
            {% elseif app.request.query.get('func') == 'edit' %}
                {{ pageAddAsset('stylesheet', 'style/core.css') }}
                {{ pageAddAsset('stylesheet', zasset('@«appName»:css/style.css')) }}
                {{ pageAddAsset('stylesheet', zasset('@ZikulaThemeModule:css/form/style.css')) }}
                {{ pageAddAsset('stylesheet', zasset('@ZikulaAndreas08Theme:css/fluid960gs/reset.css')) }}
                {% set pageStyles %}
                <style type="text/css">
                    body {
                        font-size: 70%;
                    }
                </style>
                {% endset %}
                {{ pageAddAsset('header', pageStyles) }}
            «ENDIF»
            {% endif %}
        {% endblock %}
    '''

    // 1.4.x only
    def adminBaseTemplate(Application it) '''
        {# purpose of this template: admin area base layout #}
        {% extends '«appName»::base.html.twig' %}
        {% block header %}
            {% if app.request.query.get('theme') != 'Printer' %}
                {{ render(controller('ZikulaAdminModule:Admin:adminheader')) }}
            {% endif %}
            {{ parent() }}
        {% endblock %}
        {% block appTitle %}{# empty on purpose #}{% endblock %}
        {% block titleArea %}
            <h3><span class="fa fa-{% block adminPageIcon %}{% endblock %}"></span>{% block title %}{% endblock %}</h3>
        {% endblock %}
        {% block footer %}
            {% if app.request.query.get('theme') != 'Printer' %}
                {{ render(controller('ZikulaAdminModule:Admin:adminfooter')) }}
            {% endif %}
            {{ parent() }}
        {% endblock %}
    '''

    // 1.3.x only
    def headerFooterFile(Application it, Controller controller) {
        val templatePath = getViewPath + controller.formattedName + '/'
        val templateExtension = '.tpl'
        var fileName = 'header' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'header.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, headerImpl(controller))
        }
        fileName = 'footer' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'footer.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, footerImpl(controller))
        }
    }

    // 1.3.x only
    def private headerImpl(Application it, Controller controller) '''
        {* purpose of this template: header for «controller.formattedName» area *}
        {pageaddvar name='javascript' value='prototype'}
        {pageaddvar name='javascript' value='validation'}
        {pageaddvar name='javascript' value='zikula'}
        {pageaddvar name='javascript' value='livepipe'}
        {pageaddvar name='javascript' value='zikula.ui'}
        «IF hasUploads»
            {pageaddvar name='javascript' value='zikula.imageviewer'}
        «ENDIF»
        {pageaddvar name='javascript' value='«rootFolder»/«appName»/javascript/«appName».js'}

        {* initialise additional gettext domain for translations within javascript *}
        {pageaddvar name='jsgettext' value='module_«appName.formatForDB»_js:«appName»'}

        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «IF controller instanceof AdminController»
                {adminheader}
            «ELSE»
                <div class="z-frontendbox">
                    <h2>{gt text='«name.formatForDisplayCapital»' comment='This is the title of the header template'}</h2>
                    {modulelinks modname='«appName»' type='«controller.formattedName»'}
                </div>
            «ENDIF»
            «IF generateModerationPanel && needsApproval && controller instanceof UserController»
                {nocache}
                    {«appName.formatForDB»ModerationObjects assign='moderationObjects'}
                    {if count($moderationObjects) gt 0}
                        {foreach item='modItem' from=$moderationObjects}
                            <p class="z-informationmsg z-center">
                                <a href="{modurl modname='«appName»' type='admin' func='view' ot=$modItem.objectType workflowState=$modItem.state}" class="z-bold">{$modItem.message}</a>
                            </p>
                        {/foreach}
                    {/if}
                {/nocache}
            «ENDIF»
        {/if}
        «IF controller instanceof AdminController»
        «ELSE»
            {insert name='getstatusmsg'}
        «ENDIF»
    '''

    // 1.3.x only
    def private footerImpl(Application it, Controller controller) '''
        {* purpose of this template: footer for «controller.formattedName» area *}
        {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «IF generatePoweredByBacklinksIntoFooterTemplates»
                «new FileHelper().msWeblink(it)»
            «ENDIF»
            «IF controller instanceof AdminController»
                {adminfooter}
            «ENDIF»
        «IF hasEditActions»
        {elseif isset($smarty.get.func) && $smarty.get.func eq 'edit'}
            {pageaddvar name='stylesheet' value='style/core.css'}
            {pageaddvar name='stylesheet' value='«rootFolder»/«appName»/style/style.css'}
            {pageaddvar name='stylesheet' value='system/Theme/style/form/style.css'}
            {pageaddvar name='stylesheet' value='themes/Andreas08/style/fluid960gs/reset.css'}
            {capture assign='pageStyles'}
            <style type="text/css">
                body {
                    font-size: 70%;
                }
            </style>
            {/capture}
            {pageaddvar name='header' value=$pageStyles}
        «ENDIF»
        {/if}
    '''

    def pdfHeaderFile(Application it) {
        val templateExtension = if (isLegacy) '.tpl' else '.html.twig'
        var fileName = 'includePdfHeader' + templateExtension
        if (!shouldBeSkipped(getViewPath + fileName)) {
            if (shouldBeMarked(getViewPath + fileName)) {
                fileName = 'includePdfHeader.generated' + templateExtension
            }
            fsa.generateFile(getViewPath + fileName, pdfHeaderImpl)
        }
    }

    def private pdfHeaderImpl(Application it) '''
        <!DOCTYPE html>
        <html xml:lang="«IF isLegacy»{lang}«ELSE»{{ lang() }}«ENDIF»" lang="«IF isLegacy»{lang}«ELSE»{{ lang() }}«ENDIF»" dir="«IF isLegacy»{langdirection}«ELSE»{{ langdirection() }}«ENDIF»">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <title>«IF isLegacy»{pagegetvar name='title'}«ELSE»{{ pageGetVar('title') }}«ENDIF»</title>
        <style>
            @page {
                margin: 0 2cm 1cm 1cm;
            }

            img {
                border-width: 0;
                vertical-align: middle;
            }
        </style>
        </head>
        <body>
    '''

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}