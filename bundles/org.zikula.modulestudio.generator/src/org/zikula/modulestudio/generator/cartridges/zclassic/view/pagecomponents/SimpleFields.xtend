package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.EntityField
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleFields {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def dispatch displayField(EntityField it, String objName, String page) '''
        {{ «objName».«name.formatForCode» }}'''

    def dispatch displayField(BooleanField it, String objName, String page) {
        if (ajaxTogglability && (page == 'view' || page == 'display')) '''
            {% set itemId = «objName».getKey() %}
            <a id="toggle«name.formatForCodeCapital»{{ itemId }}" href="javascript:void(0);" class="«entity.application.vendorAndName.toLowerCase»-ajax-toggle hidden" data-object-type="«entity.name.formatForCode»" data-field-name="«name.formatForCode»" data-item-id="{{ itemId }}">
                <i class="fa fa-check{% if not «objName».«name.formatForCode» %} hidden{% endif %}" id="yes«name.formatForCodeCapital»{{ itemId }}" title="{{ __('This setting is enabled. Click here to disable it.') }}"></i>
                <i class="fa fa-times{% if «objName».«name.formatForCode» %} hidden{% endif %}" id="no«name.formatForCodeCapital»{{ itemId }}" title="{{ __('This setting is disabled. Click here to enable it.') }}"></i>
            </a>
            <noscript><div id="noscript«name.formatForCodeCapital»{{ itemId }}">
                {% if «objName».«name.formatForCode» %}
                    <i class="fa fa-check" title="{{ __('Yes') }}"></i>
                {% else %}
                    <i class="fa fa-times" title="{{ __('No') }}"></i>
                {% endif %}
            </div></noscript>
        '''
        else '''
            {% if «objName».«name.formatForCode» %}
                <i class="fa fa-check" title="{{ __('Yes') }}"></i>
            {% else %}
                <i class="fa fa-times" title="{{ __('No') }}"></i>
            {% endif %}
        '''
    }

    def dispatch displayField(IntegerField it, String objName, String page) '''
        {{ «objName».«name.formatForCode» }}«IF percentage»%«ENDIF»'''

    def dispatch displayField(DecimalField it, String objName, String page) {
        if (percentage) '''
            {{ («objName».«name.formatForCode» * 100)|localizednumber }}%'''
        else '''
            {{ «objName».«name.formatForCode»|localized«IF currency»currency('EUR')«ELSE»number«ENDIF» }}'''
    }
    def dispatch displayField(FloatField it, String objName, String page) {
        if (percentage) '''
            {{ («objName».«name.formatForCode» * 100)|localizednumber }}%'''
        else '''
            {{ «objName».«name.formatForCode»|localized«IF currency»currency('EUR')«ELSE»number«ENDIF» }}'''
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
                {{ «realName».getUid()|profileLinkByUserId() }}{% if currentUser.loggedIn %}{% set sendMessageUrl = «realName».getUid()|messageSendLink(urlOnly=true) %}{% if sendMessageUrl != '#' %}<a href="{{ sendMessageUrl }}" title="{{ __f('Send private message to %userName%', { '%userName%': «realName».getUname() }) }}"><i class="fa fa-envelope-o"></i></a>{% endif %}{% endif %}
                <span class="avatar">{{ «entity.application.appName.formatForDB»_userAvatar(«realName».getUid(), rating='g') }}</span>
            «IF page == 'display'»
                {% else %}
                    {{ «realName».getUname() }}
                {% endif %}
            «ENDIF»
            «IF !mandatory»
                {% else %}&nbsp;{% endif %}
            «ENDIF»
        '''
    }

    def dispatch displayField(StringField it, String objName, String page) {
        if (password) return ''
        if (entity.application.targets('2.0') && dateInterval) '''
            {{ «objName».«name.formatForCode»|«entity.application.appName.formatForDB»_dateInterval }}'''
        else '''
            {{ «objName».«name.formatForCode»«IF country»|«entity.application.appName.formatForDB»_countryName«ELSEIF language || locale»|languageName«ENDIF» }}'''
    }

    def dispatch displayField(TextField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»|safeHtml«IF page == 'view'»|truncate(50)«ENDIF» }}'''

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
            <a href="mailto:{{ «realName»|protectMail }}" title="{{ __('Send an email') }}" class="fa fa-envelope"></a>
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
            <a href="{{ «realName» }}" title="{{ __('Visit this page') }}" class="fa fa-external-link-square"></a>
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
        val appNameSmall = entity.application.appName.formatForDB
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv') '''{{ «realName» }}'''
        else if (page == 'viewxml') '''
            {% if «realName» is not empty and «realName»Meta|default %} extension="{{ «realName»Meta.extension }}" size="{{ «realName»Meta.size }}" isImage="{% if «realName»Meta.isImage %}true{% else %}false{% endif %}"{% if «realName»Meta.isImage %} width="{{ «realName»Meta.width }}" height="{{ «realName»Meta.height }}" format="{{ «realName»Meta.format }}"{% endif %}{% endif %}>{{ «realName» }}'''
        else '''
            «IF !mandatory»
                {% if «realName» is not empty and «realName»Meta|default %}
            «ELSE»{% if «realName»Meta|default %}
            «ENDIF»
            <a href="{{ «realName»Url }}" title="{{ «objName»|«entity.application.appName.formatForDB»_formattedTitle|e('html_attr') }}"{% if «realName»Meta.isImage %} class="image-link"{% endif %}>
            {% if «realName»Meta.isImage %}
                {% set thumbOptions = attribute(thumbRuntimeOptions, '«entity.name.formatForCode»«name.formatForCodeCapital»') %}
                <img src="{{ «realName».getPathname()|imagine_filter('zkroot', thumbOptions) }}" alt="{{ «objName»|«entity.application.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ thumbOptions.thumbnail.size[0] }}" height="{{ thumbOptions.thumbnail.size[1] }}" class="img-thumbnail" />
            {% else %}
                {{ __('Download') }} ({{ «realName»Meta.size|«appNameSmall»_fileSize(«realName».getPathname(), false, false) }})
            {% endif %}
            </a>
            «IF !mandatory»
                {% else %}&nbsp;{% endif %}
            «ELSE»{% endif %}
            «ENDIF»
        '''
    }

    def dispatch displayField(ListField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»|«entity.application.appName.formatForDB»_listEntry('«entity.name.formatForCode»', '«name.formatForCode»') }}'''

    def dispatch displayField(ArrayField it, String objName, String page) '''
        {% if «objName».«name.formatForCode» is iterable and «objName».«name.formatForCode»|length > 0 %}
            <ul>
            {% for entry in «objName».«name.formatForCode» %}
                <li>{{ entry }}</li>
            {% endfor %}
            </ul>
        {% endif %}
    '''

    def dispatch displayField(DateField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»|localizeddate('medium', 'none') }}'''

    def dispatch displayField(DatetimeField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»|localizeddate('medium', 'short') }}'''

    def dispatch displayField(TimeField it, String objName, String page) '''
        {{ «objName».«name.formatForCode»|localizeddate('none', 'short') }}'''
}
