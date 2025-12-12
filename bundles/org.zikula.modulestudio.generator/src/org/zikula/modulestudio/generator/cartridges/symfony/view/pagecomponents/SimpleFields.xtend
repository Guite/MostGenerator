package org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents

import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/*TODO remove*/
class SimpleFields {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def dispatch displayField(Field it, String objName, String page) '''
        {{ «objName».«name.formatForCode» }}'''


    def dispatch displayField(NumberField it, String objName, String page) {
        if (#['latitude', 'longitude'].contains(name)) '''
            {{ «objName».«name.formatForCode»|«application.appName.formatForDB»_geoData }}'''
        else '''
            {{ «objName».«name.formatForCode» }}'''
    }

    def dispatch displayField(UserField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        '''
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

    def dispatch displayField(StringField it, String objName, String page) {
        if (role == StringRole.MAIL) '''
           <a href="mailto:{{ «objName».«name.formatForCode»|protectMail }}" title="{{ 'Send an email'|trans({}, 'messages')|e('html_attr') }}"><i class="fas fa-envelope"></i></a>
        '''
        else if (role == StringRole.URL) '''
            <a href="{{ «objName».«name.formatForCode» }}" title="{{ 'Visit this page'|trans({}, 'messages')|e('html_attr') }}"><i class="fas fa-external-link-square-alt"></i></a>
        '''
        else '''
            {{ «objName».«name.formatForCode» }}'''
    }
}
