package org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberRole
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
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

    def dispatch displayField(BooleanField it, String objName, String page) '''
        {% if «objName».«name.formatForCode» %}
            <i class="fas fa-check text-success" title="{{ 'Yes'|trans({}, 'messages')|e('html_attr') }}"></i>
        {% else %}
            <i class="fas fa-times text-danger" title="{{ 'No'|trans({}, 'messages')|e('html_attr') }}"></i>
        {% endif %}
    '''

    def dispatch displayField(NumberField it, String objName, String page) {
        if (NumberRole.PERCENTAGE == role) '''
            {{ («objName».«name.formatForCode» * 100)|format_number }}«IF unit != ''»&nbsp;{% trans %}«unit»{% endtrans %}«ELSE»%«ENDIF»'''
        else if (#['latitude', 'longitude'].contains(name)) '''
            {{ «objName».«name.formatForCode»|«application.appName.formatForDB»_geoData }}'''
        else '''
            {{ «objName».«name.formatForCode»|format_«IF NumberRole.MONEY == role»currency(«currencyForMoney(objName)»)«ELSE»number«ENDIF» }}«displayUnit»'''
    }

    def private currencyForMoney(NumberField it, String objName) '''«IF entity.hasCurrencyFieldsEntity»«objName».«entity.getCurrencyFieldsEntity.head.name.formatForCode»|default('EUR')«ELSE»'EUR'«ENDIF»'''

    def private dispatch displayUnit(NumberField it) '''«IF unit != ''»&nbsp;{% trans %}«unit»{% endtrans %}«ELSEIF NumberRole.PERCENTAGE == role»%«ENDIF»'''

    def dispatch displayField(UserField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml' || page == 'viewjson') '''«IF !mandatory»{% if «realName»|default and «realName».getId() > 0 %}«ENDIF»{{ «realName».getUname() }}«IF !mandatory»{% endif %}«ENDIF»'''
        else '''
            «IF !mandatory»
                {% if «realName»|default and «realName».getId() > 0 %}
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

    def dispatch displayField(StringField it, String objName, String page) '''
        «IF !mandatory»
            {% if «objName».«name.formatForCode» is not empty %}
        «ENDIF»
        «displayFieldInner(objName, page)»
        «IF !mandatory»
            {% else %}&nbsp;{% endif %}
        «ENDIF»
    '''

    def displayFieldInner(StringField it, String objName, String page) {
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
        else if (role == StringRole.MAIL) '''
            «IF page == 'detail'»
                  {% if not isQuickView %}
            «ENDIF»
               <a href="mailto:{{ «objName».«name.formatForCode»|protectMail }}" title="{{ 'Send an email'|trans({}, 'messages')|e('html_attr') }}"><i class="fas fa-envelope"></i></a>
            «IF page == 'detail'»
                {% else %}
                    {{ «objName».«name.formatForCode»|protectMail }}
                {% endif %}
            «ENDIF»
        '''
        else if (role == StringRole.URL) '''
            «IF page == 'detail'»
                  {% if not isQuickView %}
            «ENDIF»
                <a href="{{ «objName».«name.formatForCode» }}" title="{{ 'Visit this page'|trans({}, 'messages')|e('html_attr') }}"><i class="fas fa-external-link-square-alt"></i></a>
            «IF page == 'detail'»
                {% else %}
                    {{ «objName».«name.formatForCode» }}
                {% endif %}
            «ENDIF»
        '''
        else '''
            {{ «objName».«name.formatForCode»«IF page == 'viewjson'»|e('html_attr')«ENDIF» }}«displayUnit»'''
    }

    def private dispatch displayUnit(StringField it) '''«IF unit != ''»&nbsp;{% trans %}«unit»{% endtrans %}«ENDIF»'''

    def dispatch displayField(TextField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»«IF page == 'view'»|striptags|u.truncate(50)«ELSE»«ENDIF» }}'''

    def dispatch displayField(UploadField it, String objName, String page) {
        val appNameSmall = application.appName.formatForDB
        val realName = objName + '.' + name.formatForCode
        '''
            «IF !mandatory»
                {% if «realName» is not empty %}
            «ENDIF»
            <a href="{{ «realName»Url }}" title="{{ «objName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}">
                {% trans from 'messages' %}Download{% endtrans %} ({{ «realName»Meta.size|«appNameSmall»_fileSize(«realName».getPathname(), false, false) }})
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
