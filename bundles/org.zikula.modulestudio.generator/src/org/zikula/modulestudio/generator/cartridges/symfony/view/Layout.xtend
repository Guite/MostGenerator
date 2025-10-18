package org.zikula.modulestudio.generator.cartridges.symfony.view

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DatetimeField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Layout {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
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
