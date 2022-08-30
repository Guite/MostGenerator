package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleFields {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def dispatch displayField(Field it, String objName, String page) '''
        {{ «objName».«name.formatForCode» }}'''

    def dispatch displayField(BooleanField it, String objName, String page) {
        if (ajaxTogglability && (page == 'index' || page == 'detail')) '''
            {% set itemId = «objName».getKey() %}
            <a id="toggle«name.formatForCodeCapital»{{ itemId|e('html_attr') }}" href="javascript:void(0);" class="«application.vendorAndName.toLowerCase»-ajax-toggle d-none" data-object-type="«entity.name.formatForCode»" data-field-name="«name.formatForCode»" data-item-id="{{ itemId|e('html_attr') }}">
                <i class="fas fa-check text-success{% if not «objName».«name.formatForCode» %} d-none{% endif %}" id="yes«name.formatForCodeCapital»{{ itemId|e('html_attr') }}" title="{{ 'This setting is enabled. Click here to disable it.'|trans({}, 'messages')|e('html_attr') }}"></i>
                <i class="fas fa-times text-danger{% if «objName».«name.formatForCode» %} d-none{% endif %}" id="no«name.formatForCodeCapital»{{ itemId|e('html_attr') }}" title="{{ 'This setting is disabled. Click here to enable it.'|trans({}, 'messages')|e('html_attr') }}"></i>
            </a>
            <noscript><div id="noscript«name.formatForCodeCapital»{{ itemId|e('html_attr') }}">
                {% if «objName».«name.formatForCode» %}
                    <i class="fas fa-check text-success" title="{{ 'Yes'|trans({}, 'messages')|e('html_attr') }}"></i>
                {% else %}
                    <i class="fas fa-times text-danger" title="{{ 'No'|trans({}, 'messages')|e('html_attr') }}"></i>
                {% endif %}
            </div></noscript>
        '''
        else '''
            {% if «objName».«name.formatForCode» %}
                <i class="fas fa-check text-success" title="{{ 'Yes'|trans({}, 'messages')|e('html_attr') }}"></i>
            {% else %}
                <i class="fas fa-times text-danger" title="{{ 'No'|trans({}, 'messages')|e('html_attr') }}"></i>
            {% endif %}
        '''
    }

    def dispatch displayField(IntegerField it, String objName, String page) '''
        {{ «objName».«name.formatForCode» }}«IF unit != ''»&nbsp;{% trans %}«unit»{% endtrans %}«ELSEIF percentage»%«ENDIF»'''

    def dispatch displayField(NumberField it, String objName, String page) {
        if (percentage) '''
            {{ («objName».«name.formatForCode» * 100)|format_number }}«IF unit != ''»&nbsp;{% trans %}«unit»{% endtrans %}«ELSE»%«ENDIF»'''
        else '''
            {{ «objName».«name.formatForCode»|format_«IF currency»currency('EUR')«ELSE»number«ENDIF» }}«IF unit != ''»&nbsp;{% trans %}«unit»{% endtrans %}«ENDIF»'''
    }

    def dispatch displayField(UserField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml' || page == 'viewjson') '''«IF !mandatory»{% if «realName»|default and «realName».getUid() > 0 %}«ENDIF»{{ «realName».getUname() }}«IF !mandatory»{% endif %}«ENDIF»'''
        else '''
            «IF !mandatory»
                {% if «realName»|default and «realName».getUid() > 0 %}
            «ENDIF»
            «IF page == 'detail'»
                  {% if not isQuickView %}
            «ENDIF»
                {{ «realName».uid|profileLinkByUserId }}
                <span class="avatar">{{ userAvatar(«realName».uid, {rating: 'g'}) }}</span>
            «IF page == 'detail'»
                {% else %}
                    {{ «realName».uname }}
                {% endif %}
            «ENDIF»
            «IF !mandatory»
                {% else %}&nbsp;{% endif %}
            «ENDIF»
        '''
    }

    def dispatch displayField(StringField it, String objName, String page) {
        if (role == StringRole.PASSWORD) return ''
        if (role == StringRole.COLOUR) '''
            <span class="badge badge-default" style="background-color: {{ «objName».«name.formatForCode»|e('html_attr') }}">{{ «objName».«name.formatForCode» }}«displayUnit»</span>'''
        else if (role == StringRole.DATE_INTERVAL) '''
            {{ «objName».«name.formatForCode»|«application.appName.formatForDB»_dateInterval }}«displayUnit»'''
        else if (role == StringRole.COUNTRY) '''
            {{ «objName».«name.formatForCode»|country_name }}«displayUnit»'''
        else if (role == StringRole.CURRENCY) '''
            {{ «objName».«name.formatForCode»|currency_name }}«displayUnit»'''
        else if (role == StringRole.LANGUAGE) '''
            {{ «objName».«name.formatForCode»|language_name }}«displayUnit»'''
        else if (role == StringRole.LOCALE) '''
            {{ «objName».«name.formatForCode»|locale_name }}«displayUnit»'''
        else if (role == StringRole.TIME_ZONE) '''
            {{ «objName».«name.formatForCode»|timezone_name }}«displayUnit»'''
        else if (role == StringRole.ICON) '''
            {% if «objName».«name.formatForCode» %}<i class="fa-fw {{ «objName».«name.formatForCode»|e('html_attr') }}"></i>«displayUnit»{% endif %}'''
        else '''
            {{ «objName».«name.formatForCode»«IF page == 'viewjson'»|e('html_attr')«ENDIF» }}«displayUnit»'''
    }

    def private displayUnit(StringField it) '''«IF unit != ''»&nbsp;{% trans %}«unit»{% endtrans %}«ENDIF»'''

    def dispatch displayField(TextField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»«IF page == 'view'»|striptags|u.truncate(50)«ELSE»«ENDIF» }}'''

    def dispatch displayField(EmailField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml' || page == 'viewjson') '''{{ «realName»«IF page == 'viewjson'»|e('html_attr')«ENDIF» }}'''
        else '''
            «IF !mandatory»
                {% if «realName» is not empty %}
            «ENDIF»
            «IF page == 'detail'»
                  {% if not isQuickView %}
            «ENDIF»
            <a href="mailto:{{ «realName»|protectMail }}" title="{{ 'Send an email'|trans({}, 'messages')|e('html_attr') }}"><i class="fas fa-envelope"></i></a>
            «IF page == 'detail'»
                {% else %}
                    {{ «realName»|protectMail }}
                {% endif %}
            «ENDIF»
            «IF !mandatory»
                {% else %}&nbsp;{% endif %}
            «ENDIF»
        '''
    }

    def dispatch displayField(UrlField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml' || page == 'viewjson') '''{{ «realName»«IF page == 'viewjson'»|e('html_attr')«ENDIF» }}'''
        else '''
            «IF !mandatory»
                {% if «realName» is not empty %}
            «ENDIF»
            «IF page == 'detail'»
                  {% if not isQuickView %}
            «ENDIF»
            <a href="{{ «realName» }}" title="{{ 'Visit this page'|trans({}, 'messages')|e('html_attr') }}"><i class="fas fa-external-link-square-alt"></i></a>
            «IF page == 'detail'»
                {% else %}
                    {{ «realName» }}
                {% endif %}
            «ENDIF»
            «IF !mandatory»
                {% else %}&nbsp;{% endif %}
            «ENDIF»
        '''
    }

    def dispatch displayField(UploadField it, String objName, String page) {
        val appNameSmall = application.appName.formatForDB
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv') '''{{ «realName» }}'''
        else if (page == 'viewxml') '''
            {% if «realName» is not empty and «realName»Meta|default %} extension="{{ «realName»Meta.extension }}" size="{{ «realName»Meta.size }}" isImage="{% if «realName»Meta.isImage %}true{% else %}false{% endif %}"{% if «realName»Meta.isImage %} width="{{ «realName»Meta.width }}" height="{{ «realName»Meta.height }}" format="{{ «realName»Meta.format }}"{% endif %}{% endif %}>{{ «realName» }}'''
        else if (page == 'viewjson') '''
            "path": "{{ «realName»«IF page == 'viewjson'»|e('html_attr')«ENDIF» }}"
            {% if «realName» is not empty and «realName»Meta|default %},
                "extension": "{{ «realName»Meta.extension }}",
                "size": "{{ «realName»Meta.size }}",
                "isImage": {% if «realName»Meta.isImage %}true{% else %}false{% endif %}{% if «realName»Meta.isImage %},
                    "width": "{{ «realName»Meta.width }}",
                    "height": "{{ «realName»Meta.height }}",
                    "format": "{{ «realName»Meta.format }}"
                {% endif %}
            {% endif %}
        '''
        else '''
            «IF !mandatory»
                {% if «realName» is not empty and «realName»Meta|default %}
            «ELSE»{% if «realName»Meta|default %}
            «ENDIF»
            <a href="{{ «realName»Url }}" title="{{ «objName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"{% if «realName»Meta.isImage %} class="image-link"{% endif %}>
            {% if «realName»Meta.isImage %}
                {% set thumbOptions = attribute(thumbRuntimeOptions, '«entity.name.formatForCode»«name.formatForCodeCapital»') %}
                <img src="«IF application.generatePdfSupport»{% if app.request.requestFormat == 'pdf' %}{{ «realName».getPathname() }}{% else %}«ENDIF»{{ «realName».getPathname()|«application.appName.formatForDB»_relativePath|imagine_filter('zkroot', thumbOptions) }}«IF application.generatePdfSupport»{% endif %}«ENDIF»" alt="{{ «objName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ thumbOptions.thumbnail.size[0] }}" height="{{ thumbOptions.thumbnail.size[1] }}" class="img-thumbnail" />
            {% else %}
                {% trans from 'messages' %}Download{% endtrans %} ({{ «realName»Meta.size|«appNameSmall»_fileSize(«realName».getPathname(), false, false) }})
            {% endif %}
            </a>
            «IF !mandatory»
                {% else %}&nbsp;{% endif %}
            «ELSE»{% endif %}
            «ENDIF»
        '''
    }

    def dispatch displayField(ListField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»|«application.appName.formatForDB»_listEntry('«entity.name.formatForCode»', '«name.formatForCode»') }}'''

    def dispatch displayField(ArrayField it, String objName, String page) {
        if (page == 'viewcsv') return '''{% if «objName».«name.formatForCode» is iterable and «objName».«name.formatForCode»|length > 0 %}{% set firstItem = true %}{{ «objName».«name.formatForCode»|filter(e => e is not iterable)|join(', ') }}{% endif %}'''
        else if (page == 'viewjson') return '''{% if «objName».«name.formatForCode» is iterable and «objName».«name.formatForCode»|length > 0 %}{{ «objName».«name.formatForCode»|filter(e => e is not iterable)|join(', ') }}{% endif %}'''
        else return '''
            {% if «objName».«name.formatForCode» is iterable and «objName».«name.formatForCode»|length > 0 %}
                «IF page == 'viewxml'»
                    {{ «objName».«name.formatForCode»|filter(e => e is not iterable)|join(', ') }}
                «ELSE»
                    <ul>
                    {% for entry in «objName».«name.formatForCode»«IF page == 'viewcsv' || page == 'viewxml' || page == 'viewjson'»|filter(e => e is not iterable)«ENDIF» %}
                        <li>{{ entry }}</li>
                    {% endfor %}
                    </ul>
                «ENDIF»
            {% endif %}
        '''
    }

    def dispatch displayField(DatetimeField it, String objName, String page) {
        if (isDateTimeField) {
            if (!mandatory && nullable) {
                if (page == 'viewcsv') { '''
                    {% if «objName».«name.formatForCode» is not empty %}{{ «objName».«name.formatForCode»|format_datetime('medium', 'short') }}{% endif %}'''
                } else { '''
                    {% if «objName».«name.formatForCode» is not empty %}
                        {{ «objName».«name.formatForCode»|format_datetime('medium', 'short') }}
                    {% endif %}'''
                }
            } else { '''
                {{ «objName».«name.formatForCode»|format_datetime('medium', 'short') }}'''
            }
        } else if (isDateField) {
            if (!mandatory && nullable) {
                if (page == 'viewcsv') { '''
                    {% if «objName».«name.formatForCode» is not empty %}{{ «objName».«name.formatForCode»|format_date('medium', 'none') }}{% endif %}'''
                } else { '''
                    {% if «objName».«name.formatForCode» is not empty %}
                        {{ «objName».«name.formatForCode»|format_date('medium') }}
                    {% endif %}'''
                }
            } else { '''
                {{ «objName».«name.formatForCode»|format_date('medium') }}'''
            }
        } else if (isTimeField) { '''
            {{ «objName».«name.formatForCode»|format_time('short') }}'''
        }
    }
}
