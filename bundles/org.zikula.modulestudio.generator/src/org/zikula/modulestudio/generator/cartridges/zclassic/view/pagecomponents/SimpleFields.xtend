package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

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
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleFields {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def dispatch displayField(EntityField it, String objName, String page) '''
        «IF isLegacyApp»{$«objName».«name.formatForCode»}«ELSE»{{ «objName».«name.formatForCode» }}«ENDIF»'''

    def dispatch displayField(BooleanField it, String objName, String page) {
        if (ajaxTogglability && (page == 'view' || page == 'display')) '''
            «IF isLegacyApp»
                {assign var='itemid' value=$«objName».«entity.getFirstPrimaryKey.name.formatForCode»}
                <a id="toggle«name.formatForCodeCapital»{$itemid}" href="javascript:void(0);" class="z-hide">
                {if $«objName».«name.formatForCode»}
                    {icon type='ok' size='extrasmall' __alt='Yes' id="yes«name.formatForDB»_`$itemid`" __title='This setting is enabled. Click here to disable it.'}
                    {icon type='cancel' size='extrasmall' __alt='No' id="no«name.formatForDB»_`$itemid`" __title='This setting is disabled. Click here to enable it.' class='z-hide'}
                {else}
                    {icon type='ok' size='extrasmall' __alt='Yes' id="yes«name.formatForDB»_`$itemid`" __title='This setting is enabled. Click here to disable it.' class='z-hide'}
                    {icon type='cancel' size='extrasmall' __alt='No' id="no«name.formatForDB»_`$itemid`" __title='This setting is disabled. Click here to enable it.'}
                {/if}
                </a>
            «ELSE»
                {% set itemid = «objName».«entity.getFirstPrimaryKey.name.formatForCode» %}
                <a id="toggle«name.formatForCodeCapital»{{ itemid }}" href="javascript:void(0);" class="hidden">
                {% if «objName».«name.formatForCode» %}
                    <i class="cursor-pointer fa fa-check" id="yes«name.formatForDB»_{{ itemid }}" title="{{ __('This setting is enabled. Click here to disable it.') }}"></i>
                    <i class="cursor-pointer fa fa-times hidden" id="no«name.formatForDB»_{{ itemid }}" title="{{ __('This setting is disabled. Click here to enable it.') }}"></i>
                {% else %}
                    <i class="cursor-pointer fa fa-check hidden" id="yes«name.formatForDB»_{{ itemid }}" title="{{ __('This setting is enabled. Click here to disable it.') }}"></i>
                    <i class="cursor-pointer fa fa-times" id="no«name.formatForDB»_{{ itemid }}" title="{{ __('This setting is disabled. Click here to enable it.') }}"></i>
                {% endif %}
                </a>
            «ENDIF»
            <noscript><div id="noscript«name.formatForCodeCapital»«IF isLegacyApp»{$itemid}«ELSE»{{ itemid }}«ENDIF»">
                «IF isLegacyApp»
                    {$«objName».«name.formatForCode»|yesno:true}
                «ELSE»
                    {% if «objName».«name.formatForCode» %}
                        <i class="fa fa-check" title="{{ __('Yes') }}"></i>
                    {% else %}
                        <i class="fa fa-times" title="{{ __('No') }}"></i>
                    {% endif %}
                «ENDIF»
            </div></noscript>
        '''
        else '''
            «IF isLegacyApp»
                {$«objName».«name.formatForCode»|yesno:true}
            «ELSE»
                {% if «objName».«name.formatForCode» %}
                    <i class="fa fa-check" title="{{ __('Yes') }}"></i>
                {% else %}
                    <i class="fa fa-times" title="{{ __('No') }}"></i>
                {% endif %}
            «ENDIF»
        '''
    }

    def dispatch displayField(IntegerField it, String objName, String page) '''
        «IF isLegacyApp»{$«objName».«name.formatForCode»}«ELSE»{{ «objName».«name.formatForCode» }}«ENDIF»«IF percentage»%«ENDIF»'''

    def dispatch displayField(DecimalField it, String objName, String page) {
        if (percentage) '''
            «IF isLegacyApp»{math equation='x * y' x=$«objName».«name.formatForCode» y=100 assign='percentValue'}{$percentValue|formatnumber}«ELSE»{{ («objName».«name.formatForCode» * 100)|localizednumber }}«ENDIF»%'''
        else '''
            «IF isLegacyApp»{$«objName».«name.formatForCode»|format«IF currency»currency«ELSE»number«ENDIF»}«ELSE»{{ «objName».«name.formatForCode»|localized«IF currency»currency«ELSE»number«ENDIF» }}«ENDIF»'''
    }
    def dispatch displayField(FloatField it, String objName, String page) {
        if (percentage) '''
            «IF isLegacyApp»{math equation='x * y' x=$«objName».«name.formatForCode» y=100 assign='percentValue'}{$percentValue|formatnumber}«ELSE»{{ («objName».«name.formatForCode» * 100)|localizednumber }}«ENDIF»%'''
        else '''
            «IF isLegacyApp»{$«objName».«name.formatForCode»|format«IF currency»currency«ELSE»number«ENDIF»}«ELSE»{{ «objName».«name.formatForCode»|localized«IF currency»currency«ELSE»number«ENDIF» }}«ENDIF»'''
    }

    def dispatch displayField(UserField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml') '''«IF isLegacyApp»{usergetvar name='uname' uid=$«realName»}«ELSE»{{ «entity.application.appName.formatForDB»_userVar('uname', «realName») }}«ENDIF»'''
        else '''
            «IF !mandatory»
                «IF isLegacyApp»{if $«realName» gt 0}«ELSE»{% if «realName» > 0 %}«ENDIF»
            «ENDIF»
            «IF page == 'display'»
                  «IF isLegacyApp»{if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}«ELSE»{% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}«ENDIF»
            «ENDIF»
                «IF isLegacyApp»
                    {$«realName»|profilelinkbyuid}
                    <span class="avatar">{useravatar uid=$«realName» rating='g'}</span>
                «ELSE»
                    {{ «realName»|profileLinkByUserId() }}
                    <span class="avatar">{{ «entity.application.appName.formatForDB»_userAvatar(uid=«realName», rating='g') }}</span>
                «ENDIF»
            «IF page == 'display'»
                  «IF isLegacyApp»
                      {else}
                        {usergetvar name='uname' uid=$«realName»}
                      {/if}
                  «ELSE»
                      {% else %}
                        {{ «entity.application.appName.formatForDB»_userVar('uname', «realName») }}
                      {% endif %}
                  «ENDIF»
            «ENDIF»
            «IF !mandatory»
                «IF isLegacyApp»{else}&nbsp;{/if}«ELSE»{% else %}&nbsp;{% endif %}«ENDIF»
            «ENDIF»
        '''
    }

    def dispatch displayField(StringField it, String objName, String page) {
        if (!password) '''
            «IF isLegacyApp»{$«objName».«name.formatForCode»«IF country»|«entity.application.appName.formatForDB»GetCountryName|safetext«ELSEIF language || locale»|getlanguagename|safetext«ENDIF»}«ELSE»{{ «objName».«name.formatForCode»«IF country»|«entity.application.appName.formatForDB»_countryName«ELSEIF language || locale»|languageName«ENDIF» }}«ENDIF»'''
    }

    def dispatch displayField(TextField it, String objName, String page) '''
        «IF isLegacyApp»{$«objName».«name.formatForCode»|safehtml}«ELSE»{{ «objName».«name.formatForCode»|safeHtml }}«ENDIF»'''

    def dispatch displayField(EmailField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml') '''«IF isLegacyApp»{$«realName»}«ELSE»{{ «realName» }}«ENDIF»'''
        else '''
            «IF !mandatory»
                «IF isLegacyApp»{if $«realName» ne ''}«ELSE»{% if «realName» is not empty %}«ENDIF»
            «ENDIF»
            «IF page == 'display'»
                  «IF isLegacyApp»{if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}«ELSE»{% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}«ENDIF»
            «ENDIF»
            «IF isLegacyApp»
                <a href="mailto:{$«realName»}" title="{gt text='Send an email'}">{icon type='mail' size='extrasmall' __alt='Email'}</a>
            «ELSE»
                <a href="mailto:{{ «realName»|protectMail }}" title="{{ __('Send an email') }}" class="fa fa-envelope"></a>
            «ENDIF»
            «IF page == 'display'»
                «IF isLegacyApp»
                  {else}
                    {$«realName»}
                  {/if}
                «ELSE»
                  {% else %}
                    {{ «realName»|protectMail }}
                  {% endif %}
                «ENDIF»
            «ENDIF»
            «IF !mandatory»
                «IF isLegacyApp»{else}&nbsp;{/if}«ELSE»{% else %}&nbsp;{% endif %}«ENDIF»
            «ENDIF»
        '''
    }

    def dispatch displayField(UrlField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml') '''«IF isLegacyApp»{$«realName»}«ELSE»{{ «realName» }}«ENDIF»'''
        else '''
            «IF !mandatory»
                «IF isLegacyApp»{if $«realName» ne ''}«ELSE»{% if «realName» is not empty %}«ENDIF»
            «ENDIF»
            «IF page == 'display'»
                  «IF isLegacyApp»{if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}«ELSE»{% if app.request.query.get('theme') != 'ZikulaPrinterTheme' %}«ENDIF»
            «ENDIF»
            «IF isLegacyApp»
                <a href="{$«realName»}" title="{gt text='Visit this page'}">{icon type='url' size='extrasmall' __alt='Homepage'}</a>
            «ELSE»
                <a href="{{ «realName» }}" title="{{ __('Visit this page') }}" class="fa fa-external-link-square"></a>
            «ENDIF»
            «IF page == 'display'»
                «IF isLegacyApp»
                  {else}
                    {$«realName»}
                  {/if}
                «ELSE»
                  {% else %}
                    {{ «realName» }}
                  {% endif %}
                «ENDIF»
            «ENDIF»
            «IF !mandatory»
                «IF isLegacyApp»{else}&nbsp;{/if}«ELSE»{% else %}&nbsp;{% endif %}«ENDIF»
            «ENDIF»
        '''
    }

    def dispatch displayField(UploadField it, String objName, String page) {
        val appNameSmall = entity.application.appName.formatForDB
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv') '''«IF isLegacyApp»{$«realName»}«ELSE»{{ «realName» }}«ENDIF»'''
        else if (page == 'viewxml') '''
            «IF isLegacyApp»{if $«realName» ne '' && $«realName»Meta} extension="{$«realName»Meta.extension}" size="{$«realName»Meta.size}" isImage="{if $«realName»Meta.isImage}true{else}false{/if}"{if $«realName»Meta.isImage} width="{$«realName»Meta.width}" height="{$«realName»Meta.height}" format="{$«realName»Meta.format}"{/if}{/if}>{$«realName»}«ELSE»{% if «realName» is not empty and «realName»Meta|default %} extension="{{ «realName»Meta.extension }}" size="{{ «realName»Meta.size }}" isImage="{% if «realName»Meta.isImage %}true{% else %}false{% endif %}"{% if «realName»Meta.isImage %} width="{{ «realName»Meta.width }}" height="{{ «realName»Meta.height }}" format="{{ «realName»Meta.format }}"{% endif %}{% endif %}>{{ «realName» }}«ENDIF»'''
        else '''
            «IF !mandatory»
                «IF isLegacyApp»{if $«realName» ne '' && $«realName»Meta}«ELSE»{% if «realName» is not empty and «realName»Meta|default %}«ENDIF»
            «ELSEIF !isLegacyApp»{% if «realName»Meta|default %}
            «ENDIF»
            «IF isLegacyApp»
                <a href="{$«realName»FullPathUrl}" title="{$«objName»->getTitleFromDisplayPattern()|replace:"\"":""}"{if $«realName»Meta.isImage} rel="imageviewer[«entity.name.formatForDB»]"{/if}>
                {if $«realName»Meta.isImage}
                    {thumb image=$«realName»FullPath objectid="«entity.name.formatForCode»«IF entity.hasCompositeKeys»«FOR pkField : entity.getPrimaryKeyFields»-`$«objName».«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$«objName».«entity.primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$«entity.name.formatForCode»ThumbPreset«name.formatForCodeCapital» tag=true img_alt=$«objName»->getTitleFromDisplayPattern()}
                {else}
                    {gt text='Download'} ({$«realName»Meta.size|«appNameSmall»GetFileSize:$«realName»FullPath:false:false})
                {/if}
                </a>
            «ELSE»
                <a href="{{ «realName»Url }}" title="{{ «objName».getTitleFromDisplayPattern()|e('html_attr') }}"{% if «realName»Meta.isImage %} class="lightbox"{% endif %}>
                {% if «realName»Meta.isImage %}
                    {% set thumbOptions = attribute(thumbRuntimeOptions, '«entity.name.formatForCode»«name.formatForCodeCapital»') %}
                    <img src="{{ «realName».getRelativePathname()|imagine_filter('zkroot', thumbOptions) }}" alt="{{ «objName».getTitleFromDisplayPattern()|e('html_attr') }}" width="{{ thumbOptions.thumbnail.size[0] }}" height="{{ thumbOptions.thumbnail.size[1] }}" class="img-thumbnail" />
                {% else %}
                    {{ __('Download') }} ({{ «realName»Meta.size|«appNameSmall»_fileSize(«realName».getRelativePathname(), false, false) }})
                {% endif %}
                </a>
            «ENDIF»
            «IF !mandatory»
                «IF isLegacyApp»{else}&nbsp;{/if}«ELSE»{% else %}&nbsp;{% endif %}«ENDIF»
            «ELSEIF !isLegacyApp»{% endif %}
            «ENDIF»
        '''
    }

    def dispatch displayField(ListField it, String objName, String page) '''
        «IF isLegacyApp»{$«objName».«name.formatForCode»|«entity.application.appName.formatForDB»GetListEntry:'«entity.name.formatForCode»':'«name.formatForCode»'|safetext}«ELSE»{{ «objName».«name.formatForCode»|«entity.application.appName.formatForDB»_listEntry('«entity.name.formatForCode»', '«name.formatForCode»') }}«ENDIF»'''

    def dispatch displayField(DateField it, String objName, String page) '''
        «IF isLegacyApp»{$«objName».«name.formatForCode»|dateformat:'datebrief'}«ELSE»{{ «objName».«name.formatForCode»|localizeddate('medium', 'none') }}«ENDIF»'''

    def dispatch displayField(DatetimeField it, String objName, String page) '''
        «IF isLegacyApp»{$«objName».«name.formatForCode»|dateformat:'datetimebrief'}«ELSE»{{ «objName».«name.formatForCode»|localizeddate('medium', 'short') }}«ENDIF»'''

    def dispatch displayField(TimeField it, String objName, String page) '''
        «IF isLegacyApp»{$«objName».«name.formatForCode»|dateformat:'timebrief'}«ELSE»{{ «objName».«name.formatForCode»|localizeddate('none', 'short') }}«ENDIF»'''

    def private isLegacyApp(EntityField it) {
        entity.application.targets('1.3.x')
    }
}
