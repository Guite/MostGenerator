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

        fileName = 'Form/bootstrap_' + (if (targets('3.0')) '4' else '3') + templateExtension
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
            {% set customScript %}
                <script>
                /* <![CDATA[ */
                    ( function($) {
                        $(document).ready(function() {
                            if ($('#poweredBy').length > 0) {
                                $('#poweredBy').html($('#poweredBy').html() + ' «IF targets('3.0')»{% trans %}and{% endtrans %}«ELSE»{{ __('and') }}«ENDIF» ').append($('#poweredByMost a'));
                                $('#poweredByMost').remove();
                            }
                        });
                    })(jQuery);
                /* ]]> */
                </script>
            {% endset %}
            {{ pageAddAsset('footer', customScript) }}
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
            {% extends '@ZikulaFormExtension/Form/bootstrap_4_zikula_admin_layout.html.twig' %}
        «ELSE»
            {% extends 'ZikulaFormExtensionBundle:Form:bootstrap_3_zikula_admin_layout.html.twig' %}
        «ENDIF»
        «IF !getAllEntities.filter[e|e.hasDirectDateTimeFields].empty || !getAllVariables.filter(DatetimeField).filter[isDateTimeField].empty»

            {%- block datetime_widget -%}
                {{- parent() -}}
                {%- if not required -%}
                    «IF targets('3.0')»<small class="form-text text-muted">«ELSE»<em class="help-block small">«ENDIF»
                        <a id="{{ id }}ResetVal" href="javascript:void(0);" class="«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»">«IF targets('3.0')»{% trans %}Reset to empty value{% endtrans %}«ELSE»{{ __('Reset to empty value') }}«ENDIF»</a>
                    «IF targets('3.0')»</small>«ELSE»</em>«ENDIF»
                {%- endif -%}
            {%- endblock -%}
        «ENDIF»
        «IF !getAllEntities.filter[e|e.hasDirectDateFields].empty || !getAllVariables.filter(DatetimeField).filter[isDateField].empty»

            {%- block date_widget -%}
                {{- parent() -}}
                {%- if not required -%}
                    «IF targets('3.0')»<small class="form-text text-muted">«ELSE»<em class="help-block small">«ENDIF»
                        <a id="{{ id }}ResetVal" href="javascript:void(0);" class="«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»">«IF targets('3.0')»{% trans %}Reset to empty value{% endtrans %}«ELSE»{{ __('Reset to empty value') }}«ENDIF»</a>
                    «IF targets('3.0')»</small>«ELSE»</em>«ENDIF»
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
                <div class="«IF targets('3.0')»col-md-9 offset-md-3«ELSE»col-sm-9 col-sm-offset-3«ENDIF»"«IF !targets('3.0')» style="margin-top: -20px; padding-left: 8px"«ENDIF»>
                    {% if not required %}
                        «IF targets('3.0')»<small class="form-text text-muted">«ELSE»<em class="help-block small">«ENDIF»
                            <a id="{{ id }}_{{ field_name }}ResetVal" href="javascript:void(0);" class="«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»">«IF targets('3.0')»{% trans %}Reset to empty value{% endtrans %}«ELSE»{{ __('Reset to empty value') }}«ENDIF»</a>
                        «IF targets('3.0')»</small>«ELSE»</em>«ENDIF»
                    {% endif %}
                    «IF targets('3.0')»<small class="form-text text-muted">«ELSE»<em class="help-block small">«ENDIF»
                        «IF targets('3.0')»{% trans %}Allowed file extensions{% endtrans %}«ELSE»{{ __('Allowed file extensions') }}«ENDIF»: <span id="{{ id }}_{{ field_name }}FileExtensions">{{ allowed_extensions|default('') }}</span>
                    «IF targets('3.0')»</small>«ELSE»</em>«ENDIF»
                    {% if allowed_size|default %}
                        «IF targets('3.0')»<small class="form-text text-muted">«ELSE»<em class="help-block small">«ENDIF»
                            «IF targets('3.0')»{% trans %}Allowed file size{% endtrans %}«ELSE»{{ __('Allowed file size') }}«ENDIF»: {{ allowed_size }}
                        «IF targets('3.0')»</small>«ELSE»</em>«ENDIF»
                    {% endif %}
                    «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                        {% if has_custom_filename %}
                            {{ form_row(attribute(form, field_name ~ 'CustomFileName')) }}
                        {% endif %}
                    «ENDIF»
                    {% if file_path|default %}
                        «IF targets('3.0')»<small class="form-text text-muted">«ELSE»<span class="help-block small">«ENDIF»
                            «IF targets('3.0')»{% trans %}Current file{% endtrans %}«ELSE»{{ __('Current file') }}«ENDIF»:
                            <a href="{{ file_url }}" title="{{ «IF targets('3.0')»'Open file'|trans«ELSE»__('Open file')«ENDIF»|e('html_attr') }}"{% if file_meta.isImage %} class="image-link"{% endif %}>
                            {% if file_meta.isImage %}
                                <img src="{{ file_path|imagine_filter('zkroot', thumb_runtime_options) }}" alt="{{ edited_entity|«appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ thumb_runtime_options.thumbnail.size[0] }}" height="{{ thumb_runtime_options.thumbnail.size[1] }}" class="img-thumbnail" />
                            {% else %}
                                «IF targets('3.0')»{% trans %}Download{% endtrans %}«ELSE»{{ __('Download') }}«ENDIF» ({{ file_meta.size|«appName.formatForDB»_fileSize(file_path, false, false) }})
                            {% endif %}
                            </a>
                        «IF targets('3.0')»</small>«ELSE»</span>«ENDIF»
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
                        {% set entityNameTranslated = «IF targets('3.0')»'«entity.name.formatForDisplay»'|trans«ELSE»__('«entity.name.formatForDisplay»')«ENDIF» %}
                        «IF entity.hasImageFieldsEntity»
                            {% set withImage = true %}
                        «ENDIF»
                «ENDFOR»
                {% endif %}
                {% set idPrefix = unique_name_for_js %}
                «IF targets('3.0')»
                    {% set addLinkText = multiple ? 'Add %name%'|trans({'%name%': entityNameTranslated}) : 'Select %name%'|trans({'%name%': entityNameTranslated}) %}
                «ELSE»
                    {% set addLinkText = multiple ? __f('Add %name%', {'%name%': entityNameTranslated}) : __f('Select %name%', {'%name%': entityNameTranslated}) %}
                «ENDIF»
                {% set findLinkText = «IF targets('3.0')»'Find %name%'|trans({'%name%': entityNameTranslated})«ELSE»__f('Find %name%', {'%name%': entityNameTranslated})«ENDIF» %}
                {% set searchLinkText = «IF targets('3.0')»'Search %name%'|trans({'%name%': entityNameTranslated})«ELSE»__f('Search %name%', {'%name%': entityNameTranslated})«ENDIF» %}
                {% set createNewLinkText = «IF targets('3.0')»'Create new %name%'|trans({'%name%': entityNameTranslated})«ELSE»__f('Create new %name%', {'%name%': entityNameTranslated})«ENDIF» %}

                <div id="{{ idPrefix }}LiveSearch" class="«appName.toLowerCase»-relation-rightside">
                    <a id="{{ idPrefix }}AddLink" href="javascript:void(0);" title="{{ addLinkText|e('html_attr') }}" class="«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»">{{ addLinkText }}</a>
                    <div id="{{ idPrefix }}AddFields" class="«appName.toLowerCase»-autocomplete{{ withImage ? '-with-image' : '' }}">
                        <label for="{{ idPrefix }}Selector">{{ findLinkText }}</label>
                        <br />
                        <i class="fa fa-search" title="{{ searchLinkText|e('html_attr') }}"></i>
                        <input type="hidden" {{ block('widget_attributes') }} value="{{ value }}" />
                        <input type="hidden" name="{{ idPrefix }}Multiple" id="{{ idPrefix }}Multiple" value="{{ multiple ? '1' : '0' }}" />
                        <input type="text" id="{{ idPrefix }}Selector" name="{{ idPrefix }}Selector" autocomplete="off" />
                        <button type="button" id="{{ idPrefix }}SelectorDoCancel" name="{{ idPrefix }}SelectorDoCancel" class="btn btn-default «appName.toLowerCase»-inline-button"><i class="fa fa-times"></i> {{ __('Cancel') }}</button>
                        {% if create_url != '' %}
                            <a id="{{ idPrefix }}SelectorDoNew" href="{{ create_url }}" title="{{ createNewLinkText|e('html_attr') }}" class="btn btn-default «appName.toLowerCase»-inline-button"><i class="fa fa-plus"></i> «IF targets('3.0')»{% trans %}Create{% endtrans %}«ELSE»{{ __('Create') }}«ENDIF»</a>
                        {% endif %}
                        <noscript><p>«IF targets('3.0')»{% trans %}This function requires JavaScript activated!{% endtrans %}«ELSE»{{ __('This function requires JavaScript activated!') }}«ENDIF»</p></noscript>
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
                        $('.dropdown-toggle').addClass('«IF targets('3.0')»d-none«ELSE»hidden«ENDIF»');
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
