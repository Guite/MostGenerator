package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
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
        if (ajaxTogglability && (page == 'view' || page == 'display')) '''
            {% set itemId = «objName».getKey() %}
            <a id="toggle«name.formatForCodeCapital»{{ itemId|e('html_attr') }}" href="javascript:void(0);" class="«application.vendorAndName.toLowerCase»-ajax-toggle «IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»" data-object-type="«entity.name.formatForCode»" data-field-name="«name.formatForCode»" data-item-id="{{ itemId|e('html_attr') }}">
                <i class="fa«IF application.targets('3.0')»s«ENDIF» fa-check text-success{% if not «objName».«name.formatForCode» %} «IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»{% endif %}" id="yes«name.formatForCodeCapital»{{ itemId|e('html_attr') }}" title="{{ «IF application.targets('3.0')»'This setting is enabled. Click here to disable it.'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('This setting is enabled. Click here to disable it.')«ENDIF»|e('html_attr') }}"></i>
                <i class="fa«IF application.targets('3.0')»s«ENDIF» fa-times text-danger{% if «objName».«name.formatForCode» %} «IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF»{% endif %}" id="no«name.formatForCodeCapital»{{ itemId|e('html_attr') }}" title="{{ «IF application.targets('3.0')»'This setting is disabled. Click here to enable it.'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('This setting is disabled. Click here to enable it.')«ENDIF»|e('html_attr') }}"></i>
            </a>
            <noscript><div id="noscript«name.formatForCodeCapital»{{ itemId|e('html_attr') }}">
                {% if «objName».«name.formatForCode» %}
                    <i class="fa«IF application.targets('3.0')»s«ENDIF» fa-check text-success" title="{{ «IF application.targets('3.0')»'Yes'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Yes')«ENDIF»|e('html_attr') }}"></i>
                {% else %}
                    <i class="fa«IF application.targets('3.0')»s«ENDIF» fa-times text-danger" title="{{ «IF application.targets('3.0')»'No'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('No')«ENDIF»|e('html_attr') }}"></i>
                {% endif %}
            </div></noscript>
        '''
        else '''
            {% if «objName».«name.formatForCode» %}
                <i class="fa«IF application.targets('3.0')»s«ENDIF» fa-check text-success" title="{{ «IF application.targets('3.0')»'Yes'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Yes')«ENDIF»|e('html_attr') }}"></i>
            {% else %}
                <i class="fa«IF application.targets('3.0')»s«ENDIF» fa-times text-danger" title="{{ «IF application.targets('3.0')»'No'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('No')«ENDIF»|e('html_attr') }}"></i>
            {% endif %}
        '''
    }

    def dispatch displayField(IntegerField it, String objName, String page) '''
        {{ «objName».«name.formatForCode» }}«IF unit != ''»&nbsp;«IF application.targets('3.0')»{% trans %}«unit»{% endtrans %}«ELSE»{{ __('«unit»') }}«ENDIF»«ELSEIF percentage»%«ENDIF»'''

    def dispatch displayField(NumberField it, String objName, String page) {
        if (percentage) '''
            {{ («objName».«name.formatForCode» * 100)|«IF application.targets('3.0')»format_number«ELSE»localizednumber«ENDIF» }}«IF unit != ''»&nbsp;«IF application.targets('3.0')»{% trans %}«unit»{% endtrans %}«ELSE»{{ __('«unit»') }}«ENDIF»«ELSE»%«ENDIF»'''
        else '''
            {{ «objName».«name.formatForCode»|«IF application.targets('3.0')»format_«ELSE»localized«ENDIF»«IF currency»currency('EUR')«ELSE»number«ENDIF» }}«IF unit != ''»&nbsp;«IF application.targets('3.0')»{% trans %}«unit»{% endtrans %}«ELSE»{{ __('«unit»') }}«ENDIF»«ENDIF»'''
    }

    def dispatch displayField(UserField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml') '''«IF !mandatory»{% if «realName»|default and «realName».getUid() > 0 %}«ENDIF»{{ «realName».getUname() }}«IF !mandatory»{% endif %}«ENDIF»'''
        else '''
            «IF !mandatory»
                {% if «realName»|default and «realName».getUid() > 0 %}
            «ENDIF»
            «IF page == 'display'»
                  {% if not isQuickView %}
            «ENDIF»
                {{ «realName».uid|profileLinkByUserId }}{% if currentUser.loggedIn %}{% set sendMessageUrl = «realName».uid|messageSendLink(urlOnly=true) %}{% if sendMessageUrl != '#' %}{% set linkTitle = «IF application.targets('3.0')»'Send private message to %userName%'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»({'%userName%': «realName».uname})«ELSE»__f('Send private message to %userName%', {'%userName%': «realName».uname})«ENDIF» %}<a href="{{ sendMessageUrl }}" title="{{ linkTitle|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-envelope«IF !application.targets('3.0')»-o«ENDIF»"></i></a>{% endif %}{% endif %}
                <span class="avatar">{{ userAvatar(«realName».uid, {rating: 'g'}) }}</span>
            «IF page == 'display'»
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
            <span class="«IF application.targets('3.0')»badge badge«ELSE»label label«ENDIF»-default" style="background-color: {{ «objName».«name.formatForCode»|e('html_attr') }}">{{ «objName».«name.formatForCode» }}«displayUnit»</span>'''
        else if (application.targets('2.0') && role == StringRole.DATE_INTERVAL) '''
            {{ «objName».«name.formatForCode»|«application.appName.formatForDB»_dateInterval }}«displayUnit»'''
        else if (application.targets('3.0') && role == StringRole.COUNTRY) '''
            {{ «objName».«name.formatForCode»|country_name }}«displayUnit»'''
        else if (application.targets('3.0') && role == StringRole.CURRENCY) '''
            {{ «objName».«name.formatForCode»|currency_name }}«displayUnit»'''
        else if (application.targets('3.0') && role == StringRole.LANGUAGE) '''
            {{ «objName».«name.formatForCode»|language_name }}«displayUnit»'''
        else if (application.targets('3.0') && role == StringRole.LOCALE) '''
            {{ «objName».«name.formatForCode»|locale_name }}«displayUnit»'''
        else if (application.targets('3.0') && role == StringRole.TIME_ZONE) '''
            {{ «objName».«name.formatForCode»|timezone_name }}«displayUnit»'''
        else if (application.targets('3.0') && role == StringRole.ICON) '''
            {% if «objName».«name.formatForCode» %}<i class="fa-fw {{ «objName».«name.formatForCode»|e('html_attr') }}"></i>«displayUnit»{% endif %}'''
        else '''
            {{ «objName».«name.formatForCode»«IF role == StringRole.COUNTRY»|«application.appName.formatForDB»_countryName«ELSEIF role == StringRole.LANGUAGE || role == StringRole.LOCALE»|languageName«ENDIF» }}«displayUnit»'''
    }

    def private displayUnit(StringField it) '''«IF unit != ''»&nbsp;«IF application.targets('3.0')»{% trans %}«unit»{% endtrans %}«ELSE»{{ __('«unit»') }}«ENDIF»«ENDIF»'''

    def dispatch displayField(TextField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»«IF page == 'view'»|striptags|«IF application.targets('3.0')»u.«ENDIF»truncate(50)«ELSE»«IF page == 'display' && null !== entity && entity instanceof Entity && !(entity as Entity).skipHookSubscribers»|notifyFilters('«entity.application.appName.formatForDB».filter_hooks.«(entity as Entity).nameMultiple.formatForDB».filter')«ENDIF»|safeHtml«ENDIF» }}'''

    def dispatch displayField(EmailField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml') '''{{ «realName» }}'''
        else '''
            «IF !mandatory»
                {% if «realName» is not empty %}
            «ENDIF»
            «IF page == 'display'»
                  {% if not isQuickView %}
            «ENDIF»
            <a href="mailto:{{ «realName»|protectMail }}" title="{{ «IF application.targets('3.0')»'Send an email'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Send an email')«ENDIF»|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-envelope"></i></a>
            «IF page == 'display'»
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
        if (page == 'viewcsv' || page == 'viewxml') '''{{ «realName» }}'''
        else '''
            «IF !mandatory»
                {% if «realName» is not empty %}
            «ENDIF»
            «IF page == 'display'»
                  {% if not isQuickView %}
            «ENDIF»
            <a href="{{ «realName» }}" title="{{ «IF application.targets('3.0')»'Visit this page'|trans«IF !application.isSystemModule»({}, 'messages')«ENDIF»«ELSE»__('Visit this page')«ENDIF»|e('html_attr') }}"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-external-link-square«IF application.targets('3.0')»-alt«ENDIF»"></i></a>
            «IF page == 'display'»
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
        else '''
            «IF !mandatory»
                {% if «realName» is not empty and «realName»Meta|default %}
            «ELSE»{% if «realName»Meta|default %}
            «ENDIF»
            <a href="{{ «realName»Url }}" title="{{ «objName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}"{% if «realName»Meta.isImage %} class="image-link"{% endif %}>
            {% if «realName»Meta.isImage %}
                {% set thumbOptions = attribute(thumbRuntimeOptions, '«entity.name.formatForCode»«name.formatForCodeCapital»') %}
                <img src="«IF application.generatePdfSupport»{% if app.request.requestFormat == 'pdf' %}{{ «realName».getPathname() }}{% else %}«ENDIF»{{ «realName».getPathname()«IF application.targets('3.0')»|«application.appName.formatForDB»_relativePath«ENDIF»|imagine_filter('zkroot', thumbOptions) }}«IF application.generatePdfSupport»{% endif %}«ENDIF»" alt="{{ «objName»|«application.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ thumbOptions.thumbnail.size[0] }}" height="{{ thumbOptions.thumbnail.size[1] }}" class="img-thumbnail" />
            {% else %}
                «IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Download{% endtrans %}«ELSE»{{ __('Download') }}«ENDIF» ({{ «realName»Meta.size|«appNameSmall»_fileSize(«realName».getPathname(), false, false) }})
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
        if (page == 'viewcsv') return '''{% if «objName».«name.formatForCode» is iterable and «objName».«name.formatForCode»|length > 0 %}{% set firstItem = true %}{% for entry in «objName».«name.formatForCode»«IF application.targets('3.0')»|filter(e => e is not iterable)«ELSE» if entry is not iterable«ENDIF» %}{% if true == firstItem %}{% set firstItem = false %}{% else %}, {% endif %}{{ entry }}{% endfor %}{% endif %}'''
        else return '''
            {% if «objName».«name.formatForCode» is iterable and «objName».«name.formatForCode»|length > 0 %}
                «IF page == 'viewxml'»
                    {% set firstItem = true %}
                    {% for entry in «objName».«name.formatForCode»«IF application.targets('3.0')»|filter(e => e is not iterable)«ELSE» if entry is not iterable«ENDIF» %}
                        {% if true == firstItem %}{% set firstItem = false %}{% else %}, {% endif %}{{ entry }}
                    {% endfor %}
                «ELSE»
                    <ul>
                    {% for entry in «objName».«name.formatForCode»«IF page == 'viewcsv' || page == 'viewxml'»«IF application.targets('3.0')»|filter(e => e is not iterable)«ELSE» if entry is not iterable«ENDIF»«ENDIF» %}
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
                    {% if «objName».«name.formatForCode» is not empty %}{{ «objName».«name.formatForCode»|«IF application.targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('medium', 'short') }}{% endif %}'''
                } else { '''
                    {% if «objName».«name.formatForCode» is not empty %}
                        {{ «objName».«name.formatForCode»|«IF application.targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('medium', 'short') }}
                    {% endif %}'''
                }
            } else { '''
                {{ «objName».«name.formatForCode»|«IF application.targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('medium', 'short') }}'''
            }
        } else if (isDateField) {
            if (!mandatory && nullable) {
                if (page == 'viewcsv') { '''
                    {% if «objName».«name.formatForCode» is not empty %}{{ «objName».«name.formatForCode»|«IF application.targets('3.0')»format_date«ELSE»localizeddate«ENDIF»('medium', 'none') }}{% endif %}'''
                } else { '''
                    {% if «objName».«name.formatForCode» is not empty %}
                        {{ «objName».«name.formatForCode»|«IF application.targets('3.0')»format_date('medium')«ELSE»localizeddate('medium', 'none')«ENDIF» }}
                    {% endif %}'''
                }
            } else { '''
                {{ «objName».«name.formatForCode»|«IF application.targets('3.0')»format_date('medium')«ELSE»localizeddate('medium', 'none')«ENDIF» }}'''
            }
        } else if (isTimeField) { '''
            {{ «objName».«name.formatForCode»|«IF application.targets('3.0')»format_time('short')«ELSE»localizeddate('none', 'short')«ENDIF» }}'''
        }
    }
}
