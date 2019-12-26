package org.zikula.modulestudio.generator.cartridges.zclassic.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.UploadNamingScheme
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Layout {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions
    extension WorkflowExtensions = new WorkflowExtensions

    IMostFileSystemAccess fsa

    new(IMostFileSystemAccess fsa) {
        this.fsa = fsa
    }

    def baseTemplates(Application it) {
        val templatePath = getViewPath
        val templateExtension = '.html.twig'

        var fileName = 'base' + templateExtension
        fsa.generateFile(templatePath + fileName, baseTemplate)

        fileName = 'adminBase' + templateExtension
        fsa.generateFile(templatePath + fileName, adminBaseTemplate)

        fileName = 'Form/bootstrap_3' + templateExtension
        fsa.generateFile(templatePath + fileName, formBaseTemplate)
    }

    def baseTemplate(Application it) '''
        {# purpose of this template: general base layout #}
        {% block header %}
            «IF hasGeographical && hasEditActions && !targets('3.0')»
                {% if 'edit' in app.request.get('_route') %}
                    {{ polyfill(['geolocation']) }}
                {% endif %}
            «ENDIF»
        {% endblock %}

        {% block appTitle %}
            {{ moduleHeader('user', '«/* custom title */»', '«/* title link */»', false, true«/* flashes */», false, true«/* image */») }}
        {% endblock %}

        {% block titleArea %}
            <h2>{% block title %}{% endblock %}</h2>
        {% endblock %}
        {{ pageSetVar('title', block('pageTitle') is defined ? block('pageTitle') : block('title')) }}

        «IF generateModerationPanel && needsApproval»
            {{ include('@«appName»/Helper/includeModerationPanel.html.twig') }}

        «ENDIF»
        {{ showflashes() }}

        {% block content %}{% endblock %}

        {% block footer %}
            {{ moduleFooter() }}
        {% endblock %}

        {% block assets %}
            «commonFooter»
        {% endblock %}
    '''

    def private commonFooter(Application it) '''
        «IF generatePoweredByBacklinksIntoFooterTemplates»
            «new FileHelper(it).msWeblink»
        «ENDIF»
        {{ pageAddAsset('stylesheet', zasset('@«appName»:css/custom.css'), 120) }}
        «IF needsJQueryUI»
            {{ pageAddAsset('stylesheet', asset('jquery-ui/themes/base/jquery-ui.min.css')) }}
            {{ pageAddAsset('javascript', asset('jquery-ui/jquery-ui.min.js')) }}
        «ENDIF»
        «IF hasImageFields»
            {{ pageAddAsset('javascript', asset('magnific-popup/jquery.magnific-popup.min.js'), 90) }}
            {{ pageAddAsset('stylesheet', asset('magnific-popup/magnific-popup.css'), 90) }}
        «ENDIF»
        {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».js')) }}
        «IF hasGeographical»
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Geo.js')) }}
        «ENDIF»
    '''

    def adminBaseTemplate(Application it) '''
        {# purpose of this template: admin area base layout #}
        «IF targets('3.0')»
            {% extends '@«appName»/base.html.twig' %}
        «ELSE»
            {% extends '«appName»::base.html.twig' %}
        «ENDIF»
        {% block header %}
            {% if not app.request.query.getBoolean('raw', false) %}
                {{ adminHeader() }}
            {% endif %}
            {{ parent() }}
        {% endblock %}
        {% block appTitle %}{# empty on purpose #}{% endblock %}
        {% block titleArea %}
            <h3><i class="fa fa-{% block admin_page_icon %}{% endblock %}"></i> {% block title %}{% endblock %}</h3>
        {% endblock %}
        {% block footer %}
            {% if not app.request.query.getBoolean('raw', false) %}
                {{ adminFooter() }}
            {% endif %}
        {% endblock %}
    '''

    def formBaseTemplate(Application it) '''
        {# purpose of this template: apply some general form extensions #}
        «IF targets('3.0')»
            {% extends '@ZikulaFormExtension/Form/bootstrap_3_zikula_admin_layout.html.twig' %}
        «ELSE»
            {% extends 'ZikulaFormExtensionBundle:Form:bootstrap_3_zikula_admin_layout.html.twig' %}
        «ENDIF»
        «IF !getAllEntities.filter[e|e.hasDirectDateTimeFields].empty || !getAllVariables.filter(DatetimeField).filter[isDateTimeField].empty»

            {%- block datetime_widget -%}
                {{- parent() -}}
                {%- if not required -%}
                    <em class="help-block small"><a id="{{ id }}ResetVal" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></em>
                {%- endif -%}
            {%- endblock -%}
        «ENDIF»
        «IF !getAllEntities.filter[e|e.hasDirectDateFields].empty || !getAllVariables.filter(DatetimeField).filter[isDateField].empty»

            {%- block date_widget -%}
                {{- parent() -}}
                {%- if not required -%}
                    <em class="help-block small"><a id="{{ id }}ResetVal" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></em>
                {%- endif -%}
            {%- endblock -%}
        «ENDIF»
        «IF hasColourFields && !targets('2.0')»

            {%- block «appName.formatForDB»_field_colour_widget -%}
                {%- set type = type|default('color') -%}
                {{ block('form_widget_simple') }}
            {%- endblock -%}
        «ENDIF»
        «IF hasTelephoneFields && !targets('2.0')»

            {%- block «appName.formatForDB»_field_tel_widget -%}
                {%- set type = type|default('tel') -%}
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
                {% «IF targets('3.0')»apply spaceless«ELSE»spaceless«ENDIF» %}
                {{ form_row(attribute(form, field_name)) }}
                <div class="col-sm-9 col-sm-offset-3" style="margin-top: -20px; padding-left: 8px">
                    {% if not required %}
                        <em class="help-block small"><a id="{{ id }}_{{ field_name }}ResetVal" href="javascript:void(0);" class="hidden">{{ __('Reset to empty value') }}</a></em>
                    {% endif %}
                    <em class="help-block small">{{ __('Allowed file extensions') }}: <span id="{{ id }}_{{ field_name }}FileExtensions">{{ allowed_extensions|default('') }}</span></em>
                    {% if allowed_size|default %}
                        <em class="help-block small">{{ __('Allowed file size') }}: {{ allowed_size }}</em>
                    {% endif %}
                    «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                        {% if has_custom_filename %}
                            {{ form_row(attribute(form, field_name ~ 'CustomFileName')) }}
                        {% endif %}
                    «ENDIF»
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
                        {% if allow_deletion and not required and form[field_name ~ 'DeleteFile'] is defined %}
                            {{ form_row(attribute(form, field_name ~ 'DeleteFile')) }}
                        {% endif %}
                    {% endif %}
                </div>
                {% «IF targets('3.0')»endapply«ELSE»endspaceless«ENDIF» %}
            {% endblock %}
        «ENDIF»
        «IF hasAutoCompletionRelation»

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
                {% set addLinkText = multiple ? __f('Add %name%', {'%name%': entityNameTranslated}) : __f('Select %name%', {'%name%': entityNameTranslated}) %}

                <div id="{{ idPrefix }}LiveSearch" class="«appName.toLowerCase»-relation-rightside">
                    <a id="{{ idPrefix }}AddLink" href="javascript:void(0);" class="hidden">{{ addLinkText }}</a>
                    <div id="{{ idPrefix }}AddFields" class="«appName.toLowerCase»-autocomplete{{ withImage ? '-with-image' : '' }}">
                        <label for="{{ idPrefix }}Selector">{{ __f('Find %name%', {'%name%': entityNameTranslated}) }}</label>
                        <br />
                        <i class="fa fa-search" title="{{ __f('Search %name%', {'%name%': entityNameTranslated})|e('html_attr') }}"></i>
                        <input type="hidden" {{ block('widget_attributes') }} value="{{ value }}" />
                        <input type="hidden" name="{{ idPrefix }}Multiple" id="{{ idPrefix }}Multiple" value="{{ multiple ? '1' : '0' }}" />
                        <input type="text" id="{{ idPrefix }}Selector" name="{{ idPrefix }}Selector" autocomplete="off" />
                        <button type="button" id="{{ idPrefix }}SelectorDoCancel" name="{{ idPrefix }}SelectorDoCancel" class="btn btn-default «appName.toLowerCase»-inline-button"><i class="fa fa-times"></i> {{ __('Cancel') }}</button>
                        {% if create_url != '' %}
                            <a id="{{ idPrefix }}SelectorDoNew" href="{{ create_url }}" title="{{ __f('Create new %name%', {'%name%': entityNameTranslated}) }}" class="btn btn-default «appName.toLowerCase»-inline-button"><i class="fa fa-plus"></i> {{ __('Create') }}</a>
                        {% endif %}
                        <noscript><p>{{ __('This function requires JavaScript activated!') }}</p></noscript>
                    </div>
                </div>
            {% endblock %}
        «ENDIF»
    '''

    def rawPageFile(Application it) {
        val fileName = 'raw.html.twig'
        fsa.generateFile(getViewPath + fileName, rawPageImpl)
    }

    def rawPageImpl(Application it) '''
        {# purpose of this template: Display pages without the theme #}
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="{{ app.request.locale }}" lang="{{ app.request.locale }}">
        <head>
            <title>{{ block('pageTitle')|default(block('title')) }}</title>
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
            {% block footer %}
                «commonFooter»
                <script>
                    /* <![CDATA[ */
                        if (typeof(Zikula) == 'undefined') {var Zikula = {};}
                        Zikula.Config = {'entrypoint': '{{ getSystemVar('entrypoint', 'index.php') }}', 'baseURL': '{{ app.request.schemeAndHttpHost ~ '/' }}', 'baseURI': '{{ app.request.basePath }}'};
                    /* ]]> */
                </script>
                «IF (hasEditActions || needsConfig) && !targets('3.0')»
                    {% if «IF hasEditActions»'edit' in app.request.get('_route')«IF needsConfig» or «ENDIF»«ENDIF»«IF needsConfig»'config' in app.request.get('_route')«ENDIF» %}
                        {{ polyfill([«IF hasGeographical»'geolocation', «ENDIF»'forms', 'forms-ext']) }}
                    {% endif %}
                «ENDIF»
                «IF generateExternalControllerAndFinder»
                    {% if useFinder|default != true %}
                        «rawJsInit»
                    {% endif %}
                «ELSE»
                    «rawJsInit»
                «ENDIF»
            {% endblock %}
        </body>
        </html>
    '''

    def private rawJsInit(Application it) '''
        {% set customScript %}
            <script>
            /* <![CDATA[ */
                ( function($) {
                    $(document).ready(function() {
                        $('.dropdown-toggle').addClass('hidden');
                    });
                })(jQuery);
            /* ]]> */
            </script>
        {% endset %}
        {{ pageAddAsset('footer', customScript) }}
    '''

    def pdfHeaderFile(Application it) {
        if (!generatePdfSupport) {
            return
        }
        val fileName = 'includePdfHeader.html.twig'
        fsa.generateFile(getViewPath + fileName, pdfHeaderImpl)
    }

    def private pdfHeaderImpl(Application it) '''
        <!DOCTYPE html>
        <html xml:lang="{{ app.request.locale }}" lang="{{ app.request.locale }}" dir="auto">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
            <title>{{ pageGetVar('title') }}</title>
            <style>
                @page {
                    margin: 1cm 2cm 1cm 1cm;
                }
                img {
                    border-width: 0;
                    vertical-align: top;
                }
            </style>
        </head>
        <body>
    '''
}
