package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.UserController
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Layout {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
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
        fileName = 'Form/bootstrap_3' + templateExtension
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'Form/bootstrap_3.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, formBaseTemplate)
        }
    }

    // 1.4.x only
    def baseTemplate(Application it) '''
        {# purpose of this template: general base layout #}
        {% block header %}
            «/*{{ pageAddAsset('javascript', 'jquery-ui') }}*/»
            {{ pageAddAsset('stylesheet', asset('jquery-ui/themes/base/jquery-ui.min.css')) }}
            {{ pageAddAsset('javascript', asset('bootstrap/js/bootstrap.min.js')) }}
            {#{ pageAddAsset('javascript', 'zikula') }}{# still required for Gettext #}
            «IF hasUploads»
                {{ pageAddAsset('javascript', asset('bootstrap-media-lightbox/bootstrap-media-lightbox.min.js')) }}
                {{ pageAddAsset('stylesheet', asset('bootstrap-media-lightbox/bootstrap-media-lightbox.css')) }}
            «ENDIF»
            «IF hasViewActions || hasDisplayActions || hasEditActions»
                {{ pageAddAsset('stylesheet', asset('bootstrap-jqueryui/bootstrap-jqueryui.min.css')) }}
                {{ pageAddAsset('javascript', asset('bootstrap-jqueryui/bootstrap-jqueryui.min.js')) }}
            «ENDIF»
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».js')) }}
            {{ polyfill([«IF hasGeographical»'geolocation', «ENDIF»'forms', 'forms-ext']) }}

            {# initialise additional gettext domain for translations within javascript #}
            {# blocked by https://github.com/zikula/core/issues/2601 #}
            {# commented out because not sure yet whether this is still required in 1.4.x #}
            {# { pageAddVar('jsgettext', '«appName.formatForDB»_js:«appName»') } #}
        {% endblock %}

        {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
            {% block appTitle %}
                <h2 class="userheader">{{ __('«name.formatForDisplayCapital»') }}</h2>
                {{ moduleLinks(type='user«/* TODO controller.formattedName */»', modName='«appName»') }}
            {% endblock %}
        {% endif %}

        {% block titleArea %}
            <h2>{% block title %}{% endblock %}</h2>
        {% endblock %}
        {{ pageSetVar('title', block('title')) }}

        «IF generateModerationPanel && needsApproval»
            {{ block('moderation_panel') }}

        «ENDIF»
        {{ showflashes() }}

        {% block content %}{% endblock %}

        {% block footer %}
            {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
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
        «IF generateModerationPanel && needsApproval»

            {% block moderation_panel %}
                {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                    {% set moderationObjects = «appName.formatForDB»_moderationObjects() %}
                    {% if moderationObjects|length > 0 %}
                        {% for modItem in moderationObjects %}
                            <p class="alert alert-info alert-dismissable text-center">
                                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                                {% set itemObjectType = modItem.objectType|lower %}
                                <a href="{{ path('«appName.formatForDB»_' ~ itemObjectType ~ '_adminview', { workflowState: modItem.state }) }}" class="bold alert-link">{{ modItem.message }}</a>
                            </p>
                        {% endfor %}
                    {% endif %}
                {% endif %}
            {% endblock %}
        «ENDIF»
    '''

    // 1.4.x only
    def adminBaseTemplate(Application it) '''
        {# purpose of this template: admin area base layout #}
        {% extends '«appName»::base.html.twig' %}
        {% block header %}
            {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                {{ adminHeader() }}
            {% endif %}
            {{ parent() }}
        {% endblock %}
        {% block appTitle %}{# empty on purpose #}{% endblock %}
        {% block titleArea %}
            <h3><span class="fa fa-{% block admin_page_icon %}{% endblock %}"></span>{% block title %}{% endblock %}</h3>
        {% endblock %}
        {% block footer %}
            {% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}
                {{ adminFooter() }}
            {% endif %}
            {{ parent() }}
        {% endblock %}
    '''

    // 1.4.x only
    def formBaseTemplate(Application it) '''
        {# purpose of this template: apply some general form extensions #}
        {% extends 'ZikulaFormExtensionBundle:Form:bootstrap_3_zikula_admin_layout.html.twig' %}
        «IF !getAllEntities.filter[e|!e.fields.filter(DateField).empty].empty»

            {% block date_widget %}
                {{ parent() }}
                {% if not mandatory %}
                    <span class="help-block"><a id="reset{{ id|capitalize }}Val" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
                {% endif %}
            {% endblock %}
        «ENDIF»
        «IF !getAllEntities.filter[e|!e.fields.filter(DatetimeField).empty].empty»

            {% block datetime_widget %}
                {{ parent() }}
                {% if not mandatory %}
                    <span class="help-block"><a id="reset{{ id|capitalize }}Val" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
                {% endif %}
            {% endblock %}
        «ENDIF»
        «IF hasUploads»

            {% block file_widget %}
                {% spaceless %}

                {{ parent() }}
                {% if not mandatory %}
                    <span class="help-block"><a id="reset{{ id|capitalize }}Val" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
                {% endif %}
                <span class="help-block">{{ __('Allowed file extensions') }}: <span id="{{ id }}FileExtensions">{{ allowed_extensions|default('') }}</span></span>
                {% if allowed_size is not null and allowed_size > 0 %}
                    <span class="help-block">{{ __('Allowed file size') }}: {{ allowed_size|«appName.formatForDB»_fileSize('', false, false) }}</span>
                {% endif %}
                {% if file_path is not null %}
                    <span class="help-block">
                        {{ __('Current file') }}:
                        <a href="{{ file_url }}" title="{{ __('Open file') }}"{% if file_meta.isImage %} class="lightbox"{% endif %}>
                        {% if file_meta.isImage %}
                            {{ «appName.formatForDB»_thumb({ image: file_path, objectid: object_type ~ object_id, preset: template_from_string("{{ object_type }}ThumbPreset{{ id|capitalize }}"), tag: true, img_alt: formattedEntityTitle, img_class: 'img-thumbnail' }) }}
                        {% else %}
                            {{ __('Download') }} ({{ file_meta.size|«appName.formatForDB»_fileSize(file_path, false, false) }})
                        {% endif %}
                        </a>
                    </span>
                {% if not mandatory %}
                    {{ form_row(attribute(form, id ~ 'DeleteFile')) }}
                {% endif %}

                {% endspaceless %}
            {% endblock %}
        «ENDIF»
        «IF hasUserFields»

            {% block «appName.formatForDB»_field_user_widget %}
                {{ block('hidden_widget') }}
                <div id="{{ id }}LiveSearch" class="«appName.toLowerCase»-livesearch-user «appName.toLowerCase»-autocomplete-user hidden">
                    <i class="fa fa-search" title="{{ __('Search user') }}"></i>{% if required %}<span class="required">*</span>{% endif %}
                    <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
                    <input type="hidden" id="{{ id }}" name="{{ id }}" {{ block('widget_attributes') }} value="{{ value }}" />
                    <input type="text" id="{{ id }}Selector" name="{{ id }}Selector" autocomplete="off" {{ block('widget_attributes') }} value="{% if value > 0 %}{{ «appName.formatForDB»_userVar('uname', value) }}{% endif %}" />
                    <i class="fa fa-refresh fa-spin hidden" id="{{ id }}Indicator"></i>
                    <span id="{{ id }}NoResultsHint" class="hidden">{{ __('No results found!') }}</span>
                </div>
                {% if value and not inlineUsage %}
                    <span class="help-block avatar">
                        {{ «appName.formatForDB»_userAvatar(uid=value, rating='g')|raw }}
                    </span>
                    {% if hasPermission('ZikulaUsersModule::', '::', 'ACCESS_ADMIN') %}
                        <span class="help-block"><a href="{{ path('zikulausersmodule_admin_modify', { 'userid': value }) }}" title="{{ __('Switch to users administration') }}">{{ __('Manage user') }}</a></span>
                    {% endif %}
                {% endif %}
            {% endblock %}
        «ENDIF»
        «IF needsAutoCompletion»

            {% block «appName.formatForDB»_field_autocompletionrelation_widget %}
                {% set entityNameTranslated = '' %}
                {% set withImage = false %}
                «FOR entity : entities»
                    {% «IF entity != entities.head»else«ENDIF»if objectType == '«entity.name.formatForCode»' %}
                        {% set entityNameTranslated = __('«entity.name.formatForDisplay»') %}
                        «IF entity.hasImageFieldsEntity»
                            {% set withImage = true %}
                        «ENDIF»
                «ENDFOR»
                {% endif %}
                {% set idPrefix = uniqueNameForJs %}
                {% set addLinkText = multiple ? __f('Add %name%', { '%name%': entityNameTranslated }) : __f('Select %name%', { '%entityName%': entityNameTranslated }) %}
                {% set createLink = createUrl != '' ? '<a id="' ~ uniqueNameForJs ~ 'SelectorDoNew" href="' ~ createUrl ~ '" title="' ~ __f('Create new %name%', { '%name%': entityNameTranslated }) ~ '" class="btn btn-default «appName.toLowerCase»-inline-button">' ~ __('Create') ~ '</a>' : '' %}

                <div class="«appName.toLowerCase»-relation-rightside">'
                    <a id="{{ uniqueNameForJs }}AddLink" href="javascript:void(0);" class="hidden">{{ addLinkText }}</a>
                    <div id="{{ idPrefix }}AddFields" class="«appName.toLowerCase»-autocomplete{{ withImage ? '-with-image' : '' }}">
                        <label for="{{ idPrefix }}Selector">{{ __f('Find %name%', { '%name%': entityNameTranslated }) }}</label>
                        <br />
                        <i class="fa fa-search" title="{{ __f('Search %name%', { '%name%': entityNameTranslated })|e('html_attr') }}"></i>
                        <input type="hidden" name="{{ idPrefix }}Scope" id="{{ idPrefix }}Scope" value="{{ multiple ? '0' : '1' }}" />
                        <input type="text" id="{{ idPrefix }}Selector" name="{{ idPrefix }}Selector" value="{# value #}" autocomplete="off" {{ block('widget_attributes') }} />
                        <i class="fa fa-refresh fa-spin hidden" id="{{ idPrefix }}Indicator"></i>
                        <span id="{{ idPrefix }}NoResultsHint" class="hidden">{{ __('No results found!') }}</span>
                        <input type="button" id="{{ idPrefix }}SelectorDoCancel" name="{{ idPrefix }}SelectorDoCancel" value="{{ __('Cancel') }}" class="btn btn-default «appName.toLowerCase»-inline-button" />
                        {{ createLink }}
                        <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
                    </div>
                </div>
            {% endblock %}
        «ENDIF»
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
