package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
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
import org.zikula.modulestudio.generator.extensions.ViewExtensions
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
    extension ViewExtensions = new ViewExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    IFileSystemAccess fsa

    new(IFileSystemAccess fsa) {
        this.fsa = fsa
    }

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

    def baseTemplate(Application it) '''
        {# purpose of this template: general base layout #}
        {% block header %}
            «IF needsJQueryUI»
                {{ pageAddAsset('stylesheet', asset('jquery-ui/themes/base/jquery-ui.min.css')) }}
                {{ pageAddAsset('stylesheet', asset('bootstrap-jqueryui/bootstrap-jqueryui.min.css')) }}
                {{ pageAddAsset('javascript', asset('jquery-ui/jquery-ui.min.js')) }}
                {{ pageAddAsset('javascript', asset('bootstrap-jqueryui/bootstrap-jqueryui.min.js')) }}
            «ENDIF»
            «IF hasImageFields»
                {{ pageAddAsset('javascript', asset('magnific-popup/jquery.magnific-popup.min.js')) }}
                {{ pageAddAsset('stylesheet', asset('magnific-popup/magnific-popup.css')) }}
            «ENDIF»
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».js')) }}
            «IF hasGeographical»
                {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Geo.js')) }}
            «ENDIF»
            «IF targets('1.5')»
                «IF hasGeographical && hasEditActions»
                    {% if 'edit' in app.request.get('_route') %}
                        {{ polyfill(['geolocation']) }}
                    {% endif %}
                «ENDIF»
            «ELSE»
                «IF hasEditActions || needsConfig»
                    {% if «IF hasEditActions»'edit' in app.request.get('_route')«IF needsConfig» or «ENDIF»«ENDIF»«IF needsConfig»'config' in app.request.get('_route')«ENDIF» %}
                        {{ polyfill([«IF hasGeographical»'geolocation', «ENDIF»'forms', 'forms-ext']) }}
                    {% endif %}
                «ENDIF»
            «ENDIF»
        {% endblock %}

        {% block appTitle %}
            {{ moduleHeader('user', '«/* custom title */»', '«/* title link */»', false, true«/* flashes */», false, true«/* image */») }}
        {% endblock %}

        {% block titleArea %}
            <h2>{% block title %}{% endblock %}</h2>
        {% endblock %}
        {{ pageSetVar('title', block('pageTitle')|default(block('title'))) }}

        «IF generateModerationPanel && needsApproval»
            {{ include('@«appName»/Helper/includeModerationPanel.html.twig') }}

        «ENDIF»
        {{ showflashes() }}

        {% block content %}{% endblock %}

        {% block footer %}
            «IF generatePoweredByBacklinksIntoFooterTemplates»
                «new FileHelper().msWeblink(it)»
            «ENDIF»
        {% endblock %}
    '''

    def adminBaseTemplate(Application it) '''
        {# purpose of this template: admin area base layout #}
        {% extends '«appName»::base.html.twig' %}
        {% block header %}
            {% if not app.request.query.getBoolean('raw', false) %}
                {{ adminHeader() }}
            {% endif %}
            {{ parent() }}
        {% endblock %}
        {% block appTitle %}{# empty on purpose #}{% endblock %}
        {% block titleArea %}
            <h3><span class="fa fa-{% block admin_page_icon %}{% endblock %}"></span> {% block title %}{% endblock %}</h3>
        {% endblock %}
        {% block footer %}
            {% if not app.request.query.getBoolean('raw', false) %}
                {{ adminFooter() }}
            {% endif %}
            {{ parent() }}
        {% endblock %}
    '''

    def formBaseTemplate(Application it) '''
        {# purpose of this template: apply some general form extensions #}
        {% extends 'ZikulaFormExtensionBundle:Form:bootstrap_3_zikula_admin_layout.html.twig' %}
        «IF !getAllEntities.filter[e|!e.fields.filter(DateField).empty].empty»

            {%- block date_widget -%}
                {{- parent() -}}
                {%- if not required -%}
                    <span class="help-block"><a id="{{ id }}ResetVal" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
                {%- endif -%}
            {%- endblock -%}
        «ENDIF»
        «IF !getAllEntities.filter[e|!e.fields.filter(DatetimeField).empty].empty»

            {%- block datetime_widget -%}
                {{- parent() -}}
                {%- if not required -%}
                    <span class="help-block"><a id="reset{{ id }}ResetVal" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
                {%- endif -%}
            {%- endblock -%}
        «ENDIF»
        «IF hasColourFields»

            {%- block «appName.formatForDB»_field_colour_widget -%}
                {%- set type = type|default('color') -%}
                {{ block('form_widget_simple') }}
            {%- endblock -%}
        «ENDIF»
        «IF hasTranslatable»

            {%- block «appName.formatForDB»_field_translation_row -%}
                {{ block('form_widget_compound') }}
            {%- endblock -%}
        «ENDIF»
        «IF hasUploads»

            {% block «appName.formatForDB»_field_upload_label %}{% endblock %}
            {% block «appName.formatForDB»_field_upload_row %}
                {% spaceless %}
                {{ form_row(attribute(form, field_name)) }}
                <div class="col-sm-9 col-sm-offset-3">
                    {% if not required %}
                        <span class="help-block"><a id="{{ id }}_{{ field_name }}ResetVal" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
                    {% endif %}
                    <span class="help-block">{{ __('Allowed file extensions') }}: <span id="{{ id }}_{{ field_name }}FileExtensions">{{ allowed_extensions|default('') }}</span></span>
                    {% if allowed_size|default %}
                        <span class="help-block">{{ __('Allowed file size') }}: {{ allowed_size }}</span>
                    {% endif %}
                    {% if file_path|default %}
                        <span class="help-block">
                            {{ __('Current file') }}:
                            <a href="{{ file_url }}" title="{{ __('Open file') }}"{% if file_meta.isImage %} class="image-link"{% endif %}>
                            {% if file_meta.isImage %}
                                <img src="{{ file_path|imagine_filter('zkroot', thumb_runtime_options) }}" alt="{{ edited_entity|«appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ thumb_runtime_options.thumbnail.size[0] }}" height="{{ thumb_runtime_options.thumbnail.size[1] }}" class="img-thumbnail" />
                            {% else %}
                                {{ __('Download') }} ({{ file_meta.size|«appName.formatForDB»_fileSize(file_path, false, false) }})
                            {% endif %}
                            </a>
                        </span>
                        {% if not required %}
                            {{ form_row(attribute(form, field_name ~ 'DeleteFile')) }}
                        {% endif %}
                    {% endif %}
                </div>
                {% endspaceless %}
            {% endblock %}
        «ENDIF»
        «IF needsUserAutoCompletion && !targets('1.5')»

            {% block «appName.formatForDB»_field_user_widget %}
                <div id="{{ id }}LiveSearch" class="«appName.toLowerCase»-autocomplete-user hidden">
                    <i class="fa fa-search" title="{{ __('Search user') }}"></i>
                    <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
                    <input type="hidden" {{ block('widget_attributes') }} value="{{ value }}" />
                    <input type="text" id="{{ id }}Selector" name="{{ id }}Selector" autocomplete="off" value="{{ user_name|e('html_attr') }}" title="{{ __('Enter a part of the user name to search') }}" class="user-selector" />
                </div>
                <span id="{{ id }}Avatar" class="help-block avatar">
                    {% if value and not inline_usage %}
                        «IF targets('1.5')»
                            {{ userAvatar(value, { rating: 'g' }) }}
                        «ELSE»
                            {{ «appName.formatForDB»_userAvatar(uid=value, rating='g') }}
                        «ENDIF»
                    {% endif %}
                </span>
                {% if not required %}
                    <span class="help-block"><a id="{{ id }}ResetVal" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></span>
                {% endif %}
                {% if value and not inline_usage %}
                    {% if hasPermission('ZikulaUsersModule::', '::', 'ACCESS_ADMIN') %}
                        <span class="help-block"><a href="{{ path('zikulausersmodule_useradministration_modify', { 'user': value }) }}" title="{{ __('Switch to users administration') }}">{{ __('Manage user') }}</a></span>
                    {% endif %}
                {% endif %}
            {% endblock %}
        «ENDIF»
        «IF needsAutoCompletion»

            {% block «appName.formatForDB»_field_autocompletionrelation_widget %}
                {% set entityNameTranslated = '' %}
                {% set withImage = false %}
                «FOR entity : entities»
                    {% «IF entity != entities.head»else«ENDIF»if object_type == '«entity.name.formatForCode»' %}
                        {% set entityNameTranslated = __('«entity.name.formatForDisplay»') %}
                        «IF entity.hasImageFieldsEntity»
                            {% set withImage = true %}
                        «ENDIF»
                «ENDFOR»
                {% endif %}
                {% set idPrefix = unique_name_for_js %}
                {% set addLinkText = multiple ? __f('Add %name%', { '%name%': entityNameTranslated }) : __f('Select %name%', { '%name%': entityNameTranslated }) %}

                <div id="{{ idPrefix }}LiveSearch" class="«appName.toLowerCase»-relation-rightside">
                    <a id="{{ idPrefix }}AddLink" href="javascript:void(0);" class="hidden">{{ addLinkText }}</a>
                    <div id="{{ idPrefix }}AddFields" class="«appName.toLowerCase»-autocomplete{{ withImage ? '-with-image' : '' }}">
                        <label for="{{ idPrefix }}Selector">{{ __f('Find %name%', { '%name%': entityNameTranslated }) }}</label>
                        <br />
                        <i class="fa fa-search" title="{{ __f('Search %name%', { '%name%': entityNameTranslated })|e('html_attr') }}"></i>
                        <input type="hidden" {{ block('widget_attributes') }} value="{{ value }}" />
                        <input type="hidden" name="{{ idPrefix }}Multiple" id="{{ idPrefix }}Multiple" value="{{ multiple ? '1' : '0' }}" />
                        <input type="text" id="{{ idPrefix }}Selector" name="{{ idPrefix }}Selector" autocomplete="off" />
                        <input type="button" id="{{ idPrefix }}SelectorDoCancel" name="{{ idPrefix }}SelectorDoCancel" value="{{ __('Cancel') }}" class="btn btn-default «appName.toLowerCase»-inline-button" />
                        {% if create_url != '' %}
                            <a id="{{ idPrefix }}SelectorDoNew" href="{{ create_url }}" title="{{ __f('Create new %name%', { '%name%': entityNameTranslated }) }}" class="btn btn-default rkbulletinnewsmodule-inline-button">{{ __('Create') }}</a>
                        {% endif %}
                        <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
                    </div>
                </div>
            {% endblock %}
        «ENDIF»
    '''

    def rawPageFile(Application it) {
        val templateExtension = '.html.twig'
        var fileName = 'raw' + templateExtension
        if (!shouldBeSkipped(getViewPath + fileName)) {
            if (shouldBeMarked(getViewPath + fileName)) {
                fileName = 'raw.generated' + templateExtension
            }
            fsa.generateFile(getViewPath + fileName, rawPageImpl)
        }
    }

    def rawPageImpl(Application it) '''
        {# purpose of this template: Display pages without the theme #}
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{{ app.request.locale }}" lang="{{ app.request.locale }}">
        <head>
            <title>{{ block('pageTitle')|default(block('title')) }}</title>
            <link rel="stylesheet" type="text/css" href="{{ asset('bootstrap/css/bootstrap.min.css') }}" />
            <link rel="stylesheet" type="text/css" href="{{ asset('bootstrap/css/bootstrap-theme.min.css') }}" />
            «IF needsJQueryUI»
                <link rel="stylesheet" type="text/css" href="{{ asset('jquery-ui/themes/base/jquery-ui.min.css') }}" />
                <link rel="stylesheet" type="text/css" href="{{ asset('bootstrap-jqueryui/bootstrap-jqueryui.min.css') }}" />
            «ENDIF»
            «IF targets('1.5')»
                <link rel="stylesheet" type="text/css" href="{{ asset('bundles/core/css/core.css') }}" />
            «ELSE»
                <link rel="stylesheet" type="text/css" href="{{ app.request.basePath }}/style/core.css" />
            «ENDIF»
            <link rel="stylesheet" type="text/css" href="{{ zasset('@«appName»:css/style.css') }}" />
            «IF generateExternalControllerAndFinder»
                {% if useFinder|default == true %}
                    «rawCssAssets(true)»
                «IF hasImageFields»
                    {% else %}
                        «rawCssAssets(false)»
                «ENDIF»
                {% endif %}
            «ELSE»
                «IF hasImageFields»
                    «rawCssAssets(false)»
                «ENDIF»
            «ENDIF»
            <script type="text/javascript">
                /* <![CDATA[ */
                    if (typeof(Zikula) == 'undefined') {var Zikula = {};}
                    Zikula.Config = {'entrypoint': '{{ getModVar('ZConfig', 'entrypoint', 'index.php') }}', 'baseURL': '{{ app.request.getSchemeAndHttpHost() ~ '/' }}', 'baseURI': '{{ app.request.getBasePath() }}'};
                /* ]]> */
            </script>
            <script type="text/javascript" src="{{ asset('jquery/jquery.min.js') }}"></script>
            <script type="text/javascript" src="{{ asset('bootstrap/js/bootstrap.min.js') }}"></script>
            «IF needsJQueryUI»
                <script type="text/javascript" src="{{ asset('jquery-ui/jquery-ui.min.js') }}"></script>
                <script type="text/javascript" src="{{ asset('bootstrap-jqueryui/bootstrap-jqueryui.min.js') }}"></script>
            «ENDIF»
            <script type="text/javascript" src="{{ asset('bundles/fosjsrouting/js/router.js') }}"></script>
            <script type="text/javascript" src="{{ asset('js/fos_js_routes.js') }}"></script>
            <script type="text/javascript" src="{{ asset('bundles/bazingajstranslation/js/translator.min.js') }}"></script>
            <script type="text/javascript" src="{{ asset('bundles/core/js/Zikula.Translator.js') }}"></script>
            «IF generateExternalControllerAndFinder»
                {% if useFinder|default == true %}
                    «rawJsAssets(true)»
                {% else %}
                    «rawJsAssets(false)»
                {% endif %}
            «ELSE»
                «rawJsAssets(false)»
            «ENDIF»
        </head>
        <body>
            «IF generateExternalControllerAndFinder»
                {% if useFinder|default != true %}
                    <h2>{{ block('title') }}</h2>
                {% endif %}
            «ELSE»
                <h2>{{ block('title') }}</h2>
            «ENDIF»
            {% block content %}{% endblock %}
            «IF generateExternalControllerAndFinder»
                {% if useFinder|default != true %}
                    «rawJsInit»
                {% endif %}
            «ELSE»
                «rawJsInit»
            «ENDIF»
        </body>
        </html>
    '''

    def private rawCssAssets(Application it, Boolean forFinder) '''
        «IF forFinder»
            <link rel="stylesheet" type="text/css" href="{{ zasset('@«appName»:css/finder.css') }}" />
        «ELSE»
            <link rel="stylesheet" type="text/css" href="{{ asset('magnific-popup/magnific-popup.css') }}" />
        «ENDIF»
    '''

    def private rawJsAssets(Application it, Boolean forFinder) '''
        «IF forFinder»
            <script type="text/javascript" src="{{ zasset('@«appName»:js/«appName».Finder.js') }}"></script>
        «ELSE»
            «IF hasImageFields»
                <script type="text/javascript" src="{{ asset('magnific-popup/jquery.magnific-popup.min.js') }}"></script>
            «ENDIF»
            <script type="text/javascript" src="{{ zasset('@«appName»:js/«appName».js') }}"></script>
            «IF hasGeographical»
                <script type="text/javascript" src="{{ zasset('@«appName»:js/«appName».Geo.js') }}"></script>
            «ENDIF»
            «IF hasEditActions || needsConfig»
                «IF hasEditActions»
                    {% if 'edit' in app.request.get('_route') %}
                        {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Validation.js'), 98) }}
                        {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».EditFunctions.js'), 99) }}
                    {% endif %}
                «ENDIF»
                {% if «IF hasEditActions»'edit' in app.request.get('_route')«IF needsConfig» or «ENDIF»«ENDIF»«IF needsConfig»'config' in app.request.get('_route')«ENDIF» %}
                    {{ polyfill([«IF hasGeographical»'geolocation', «ENDIF»'forms', 'forms-ext']) }}
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''

    def private rawJsInit(Application it) '''
        <script type="text/javascript">
        /* <![CDATA[ */
            ( function($) {
                $(document).ready(function() {
                    $('.dropdown-toggle').addClass('hidden');
                });
            })(jQuery);
        /* ]]> */
        </script>
    '''

    def pdfHeaderFile(Application it) {
        val templateExtension = '.html.twig'
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
        <html xml:lang="{{ app.request.locale }}" lang="{{ app.request.locale }}" dir="auto">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <title>{{ pageGetVar('title') }}</title>
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
}
