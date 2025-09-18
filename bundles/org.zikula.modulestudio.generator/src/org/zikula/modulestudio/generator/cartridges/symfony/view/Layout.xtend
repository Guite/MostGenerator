package org.zikula.modulestudio.generator.cartridges.symfony.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.UploadNamingScheme
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Layout {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension ViewExtensions = new ViewExtensions

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

        fileName = 'Form/form_layout_addons' + templateExtension
        fsa.generateFile(templatePath + fileName, formBaseTemplate)

        fileName = 'raw.html.twig'
        fsa.generateFile(templatePath + fileName, rawPageImpl)
    }

    def baseTemplate(Application it) '''
        {# purpose of this template: general base layout #}
        {% trans_default_domain 'messages' %}
        {% block header %}
        {% endblock %}

        {% block appTitle %}{% endblock %}

        {% block titleArea %}
            <h2>{% block title %}{% endblock %}</h2>
        {% endblock %}
        {{ pageSetVar('title', block('pageTitle') is defined ? block('pageTitle') : block('title')) }}

        {% block content %}{% endblock %}

        {% block footer %}
        {% endblock %}

        {% block assets %}
            «commonFooter»
        {% endblock %}
    '''

    def private commonFooter(Application it) '''
        «new FileHelper(it).msWeblink»
        {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Backlink.Integration.js')) }}
        {{ pageAddAsset('stylesheet', zasset('@«appName»:css/custom.css'), 120) }}
        «IF needsJQueryUI»
            {{ pageAddAsset('stylesheet', asset('jquery-ui/themes/base/jquery-ui.min.css')) }}
            {{ pageAddAsset('javascript', asset('jquery-ui/jquery-ui.min.js'), constant('Zikula\\ThemeBundle\\Engine\\AssetBag::WEIGHT_JQUERY_UI')) }}
        «ENDIF»
        {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».js')) }}
        «IF hasGeographical»
            {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».Geo.js')) }}
        «ENDIF»
    '''

    def adminBaseTemplate(Application it) '''
        {# purpose of this template: admin area base layout #}
        {% extends '@«vendorAndName»/base.html.twig' %}
        {% trans_default_domain 'messages' %}
        {% block titleArea %}
            <h3><i class="fas fa-{% block admin_page_icon %}{% endblock %}"></i> {% block title %}{% endblock %}</h3>
        {% endblock %}
    '''

    def formBaseTemplate(Application it) '''
        {# purpose of this template: apply some general form extensions #}
        {% extends '@ZikulaTheme/Form/form_layout_addons.html.twig' %}
        {% trans_default_domain 'messages' %}
        «IF !entities.filter[e|e.hasDirectDateTimeFields].empty || !getAllVariables.filter(DatetimeField).filter[isDateTimeField].empty»

            {%- block datetime_widget -%}
                {{- parent() -}}
                {%- if not required -%}
                    <small class="form-text text-muted">
                        <a id="{{ id }}ResetVal" href="javascript:void(0);" class="d-none">{% trans %}Reset to empty value{% endtrans %}</a>
                    </small>
                {%- endif -%}
            {%- endblock -%}
        «ENDIF»
        «IF !entities.filter[e|e.hasDirectDateFields].empty || !getAllVariables.filter(DatetimeField).filter[isDateField].empty»

            {%- block date_widget -%}
                {{- parent() -}}
                {%- if not required -%}
                    <small class="form-text text-muted">
                        <a id="{{ id }}ResetVal" href="javascript:void(0);" class="d-none">{% trans %}Reset to empty value{% endtrans %}</a>
                    </small>
                {%- endif -%}
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
                {% apply spaceless %}
                {{ form_row(attribute(form, field_name)) }}
                <div class="col-md-9 offset-md-3">
                    {% if not required %}
                        <small class="form-text text-muted">
                            <a id="{{ id }}_{{ field_name }}ResetVal" href="javascript:void(0);" class="d-none">{% trans %}Reset to empty value{% endtrans %}</a>
                        </small>
                    {% endif %}
                    <small class="form-text text-muted">
                        {% trans %}Allowed file extensions{% endtrans %}: <span id="{{ id }}_{{ field_name }}FileExtensions">{{ allowed_extensions|default('') }}</span>
                    </small>
                    {% if allowed_size|default %}
                        <small class="form-text text-muted">
                            {% trans %}Allowed file size{% endtrans %}: {{ allowed_size }}
                        </small>
                    {% endif %}
                    «IF hasUploadNamingScheme(UploadNamingScheme.USERDEFINEDWITHCOUNTER)»
                        {% if has_custom_filename %}
                            {{ form_row(attribute(form, field_name ~ 'CustomFileName')) }}
                        {% endif %}
                    «ENDIF»
                    {% if file_path|default %}
                        <small class="form-text text-muted">
                            {% trans %}Current file{% endtrans %}:
                            <a href="{{ file_url }}" title="{{ 'Open file'|trans|e('html_attr') }}"{% if file_meta.isImage %} class="image-link"{% endif %}>
                            {% if file_meta.isImage %}
                                <img src="{{ file_path|«appName.formatForDB»_relativePath|imagine_filter('zkroot', thumb_runtime_options) }}" alt="{{ edited_entity|«appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ thumb_runtime_options.thumbnail.size[0] }}" height="{{ thumb_runtime_options.thumbnail.size[1] }}" class="img-thumbnail" />
                            {% else %}
                                {% trans %}Download{% endtrans %} ({{ file_meta.size|«appName.formatForDB»_fileSize(file_path, false, false) }})
                            {% endif %}
                            </a>
                        </small>
                        {% if allow_deletion and not required and form[field_name ~ 'DeleteFile'] is defined %}
                            {{ form_row(attribute(form, field_name ~ 'DeleteFile')) }}
                        {% endif %}
                    {% endif %}
                </div>
                {% endapply %}
            {% endblock %}
        «ENDIF»
        «IF hasAutoCompletionRelation»

            {% block «appName.formatForDB»_field_autocompletionrelation_widget %}
                {% set entityNameTranslated = '' %}
                {% set withImage = false %}
                «FOR entity : entities»
                    {% «IF entity != entities.head»else«ENDIF»if object_type == '«entity.name.formatForCode»' %}
                        {% set entityNameTranslated = '«entity.name.formatForDisplay»'|trans %}
                        «IF entity.hasImageFieldsEntity»
                            {% set withImage = true %}
                        «ENDIF»
                «ENDFOR»
                {% endif %}
                {% set idPrefix = unique_name_for_js %}
                {% set addLinkText = multiple ? 'Add %name%'|trans({'%name%': entityNameTranslated}) : 'Select %name%'|trans({'%name%': entityNameTranslated}) %}
                {% set findLinkText = 'Find %name%'|trans({'%name%': entityNameTranslated}) %}
                {% set searchLinkText = 'Search %name%'|trans({'%name%': entityNameTranslated}) %}
                {% set createNewLinkText = 'Create new %name%'|trans({'%name%': entityNameTranslated}) %}

                <div id="{{ idPrefix }}LiveSearch" class="«appName.toLowerCase»-relation-rightside">
                    <a id="{{ idPrefix }}AddLink" href="javascript:void(0);" title="{{ addLinkText|e('html_attr') }}" class="d-none">{{ addLinkText }}</a>
                    <div id="{{ idPrefix }}AddFields" class="«appName.toLowerCase»-autocomplete{{ withImage ? '-with-image' : '' }}">
                        <label for="{{ idPrefix }}Selector">{{ findLinkText }}</label>
                        <br />
                        <i class="fas fa-search" title="{{ searchLinkText|e('html_attr') }}"></i>
                        <input type="hidden" {{ block('widget_attributes') }} value="{{ value }}" />
                        <input type="hidden" name="{{ idPrefix }}Multiple" id="{{ idPrefix }}Multiple" value="{{ multiple ? '1' : '0' }}" />
                        <input type="text" id="{{ idPrefix }}Selector" name="{{ idPrefix }}Selector" autocomplete="off" />
                        <button type="button" id="{{ idPrefix }}SelectorDoCancel" name="{{ idPrefix }}SelectorDoCancel" class="btn btn-secondary «appName.toLowerCase»-inline-button"><i class="fas fa-times"></i> {% trans %}Cancel{% endtrans %}</button>
                        {% if create_url != '' %}
                            <a id="{{ idPrefix }}SelectorDoNew" href="{{ create_url }}" title="{{ createNewLinkText|e('html_attr') }}" class="btn btn-secondary «appName.toLowerCase»-inline-button"><i class="fas fa-plus"></i> {% trans %}Create{% endtrans %}</a>
                        {% endif %}
                        <noscript><p>{% trans %}This function requires JavaScript activated!{% endtrans %}</p></noscript>
                    </div>
                </div>
            {% endblock %}
        «ENDIF»
    '''

    def rawPageImpl(Application it) '''
        {# purpose of this template: display pages without the theme #}
        {% trans_default_domain 'messages' %}
        <!DOCTYPE html>
        <html lang="{{ app.locale }}" dir="auto">
        <head>
            <title>{{ block('pageTitle') is defined ? block('pageTitle') : block('title') }}</title>
        </head>
        <body>
            <h2>{{ block('title') }}</h2>
            {% block content %}{% endblock %}
            {% block footer %}
                «commonFooter»
                «rawJsInit»
            {% endblock %}
        </body>
        </html>
    '''

    def private rawJsInit(Application it) '''
        {{ pageAddAsset('javascript', zasset('@«appName»:js/«appName».RawPage.js')) }}
    '''
}
