package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleFields {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def dispatch displayField(EntityField it, String objName, String page) '''
        {$«objName».«name.formatForCode»}'''

    def dispatch displayField(BooleanField it, String objName, String page) {
        if (ajaxTogglability && (page == 'view' || page == 'display')) '''
            {assign var='itemid' value=$«objName».«entity.getFirstPrimaryKey.name.formatForCode»}
            «IF entity.container.application.targets('1.3.5')»
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
                <a id="toggle«name.formatForCodeCapital»{$itemid}" href="javascript:void(0);" class="hidden">
                {if $«objName».«name.formatForCode»}
                    <span class="cursor-pointer fa fa-check" id="yes«name.formatForDB»_{$itemid}" title="{gt text='This setting is enabled. Click here to disable it.'}"></span>
                    <span class="cursor-pointer fa fa-times hidden" id="no«name.formatForDB»_{$itemid}" title="{gt text='This setting is disabled. Click here to enable it.'}"></span>
                {else}
                    <span class="cursor-pointer fa fa-check hidden" id="yes«name.formatForDB»_{$itemid}" title="{gt text='This setting is enabled. Click here to disable it.'}"></span>
                    <span class="cursor-pointer fa fa-times" id="no«name.formatForDB»_{$itemid}" title="{gt text='This setting is disabled. Click here to enable it.'}"></span>
                {/if}
                </a>
            «ENDIF»
            <noscript><div id="noscript«name.formatForCodeCapital»{$itemid}">
                {$«objName».«name.formatForCode»|yesno:true}
            </div></noscript>
        '''
        else '''
            {$«objName».«name.formatForCode»|yesno:true}'''
    }
    def dispatch displayField(DecimalField it, String objName, String page) '''
        {$«objName».«name.formatForCode»|format«IF currency»currency«ELSE»number«ENDIF»}'''
    def dispatch displayField(FloatField it, String objName, String page) '''
        {$«objName».«name.formatForCode»|format«IF currency»currency«ELSE»number«ENDIF»}'''

    def dispatch displayField(UserField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml') '''{usergetvar name='uname' uid=$«realName»}'''
        else '''
            «IF !mandatory»
                {if $«realName» gt 0}
            «ENDIF»
            «IF page == 'display'»
                  {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «ENDIF»
                {$«realName»|profilelinkbyuid}
                    <span class="avatar">{useravatar uid=$«realName» rating='g'}</span>
            «IF page == 'display'»
                  {else}
                    {usergetvar name='uname' uid=$«realName»}
                  {/if}
            «ENDIF»
            «IF !mandatory»
                {else}&nbsp;{/if}
            «ENDIF»
        '''
    }

    def dispatch displayField(StringField it, String objName, String page) {
        if (!password) '''
            {$«objName».«name.formatForCode»«IF country»|«entity.container.application.appName.formatForDB»GetCountryName|safetext«ELSEIF language || locale»|getlanguagename|safetext«ENDIF»}'''
    }

    def dispatch displayField(EmailField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml') '''{$«realName»}'''
        else '''
            «IF !mandatory»
                {if $«realName» ne ''}
            «ENDIF»
            «IF page == 'display'»
                  {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «ENDIF»
            «IF entity.container.application.targets('1.3.5')»
                <a href="mailto:{$«realName»}" title="{gt text='Send an email'}">{icon type='mail' size='extrasmall' __alt='Email'}</a>
            «ELSE»
                <a href="mailto:{$«realName»}" title="{gt text='Send an email'}" class="fa fa-envelope"></a>
            «ENDIF»
            «IF page == 'display'»
                  {else}
                    {$«realName»}
                  {/if}
            «ENDIF»
            «IF !mandatory»
                {else}&nbsp;{/if}
            «ENDIF»
        '''
    }

    def dispatch displayField(UrlField it, String objName, String page) {
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv' || page == 'viewxml') '''{$«realName»}'''
        else '''
            «IF !mandatory»
                {if $«realName» ne ''}
            «ENDIF»
            «IF page == 'display'»
                  {if !isset($smarty.get.theme) || $smarty.get.theme ne 'Printer'}
            «ENDIF»
            «IF entity.container.application.targets('1.3.5')»
                <a href="{$«realName»}" title="{gt text='Visit this page'}">{icon type='url' size='extrasmall' __alt='Homepage'}</a>
            «ELSE»
                <a href="{$«realName»}" title="{gt text='Visit this page'}" class="fa fa-external-link-square"></a>
            «ENDIF»
            «IF page == 'display'»
                  {else}
                    {$«realName»}
                  {/if}
            «ENDIF»
            «IF !mandatory»
                {else}&nbsp;{/if}
            «ENDIF»
        '''
    }

    def dispatch displayField(UploadField it, String objName, String page) {
        val appNameSmall = entity.container.application.appName.formatForDB
        val realName = objName + '.' + name.formatForCode
        if (page == 'viewcsv') '''{$«realName»}'''
        else if (page == 'viewxml') '''
            {if $«realName» ne ''} extension="{$«realName»Meta.extension}" size="{$«realName»Meta.size}" isImage="{if $«realName»Meta.isImage}true{else}false{/if}"{if $«realName»Meta.isImage} width="{$«realName»Meta.width}" height="{$«realName»Meta.height}" format="{$«realName»Meta.format}"{/if}{/if}>{$«realName»}'''
        else '''
            «IF !mandatory»
                {if $«realName» ne ''}
            «ENDIF»
              <a href="{$«realName»FullPathURL}" title="{$«objName»->getTitleFromDisplayPattern()|replace:"\"":""}"{if $«realName»Meta.isImage} «IF entity.container.application.targets('1.3.5')»rel="imageviewer[«entity.name.formatForDB»]"«ELSE»class="lightbox"«ENDIF»{/if}>
              {if $«realName»Meta.isImage}
                  {thumb image=$«realName»FullPath objectid="«entity.name.formatForCode»«IF entity.hasCompositeKeys»«FOR pkField : entity.getPrimaryKeyFields»-`$«objName».«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$«objName».«entity.primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$«entity.name.formatForCode»ThumbPreset«name.formatForCodeCapital» tag=true img_alt=$«objName»->getTitleFromDisplayPattern()«IF !entity.container.application.targets('1.3.5')» img_class='img-thumbnail'«ENDIF»}
              {else}
                  {gt text='Download'} ({$«realName»Meta.size|«appNameSmall»GetFileSize:$«realName»FullPath:false:false})
              {/if}
              </a>
            «IF !mandatory»
                {else}&nbsp;{/if}
            «ENDIF»
        '''
    }

    def dispatch displayField(ListField it, String objName, String page) '''
        {$«objName».«name.formatForCode»|«entity.container.application.appName.formatForDB»GetListEntry:'«entity.name.formatForCode»':'«name.formatForCode»'|safetext}'''

    def dispatch displayField(DateField it, String objName, String page) '''
        {$«objName».«name.formatForCode»|dateformat:'datebrief'}'''

    def dispatch displayField(DatetimeField it, String objName, String page) '''
        {$«objName».«name.formatForCode»|dateformat:'datetimebrief'}'''

    def dispatch displayField(TimeField it, String objName, String page) '''
        {$«objName».«name.formatForCode»|dateformat:'timebrief'}'''
}
