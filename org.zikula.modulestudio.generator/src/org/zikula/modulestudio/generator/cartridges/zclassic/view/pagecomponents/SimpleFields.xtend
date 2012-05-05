package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SimpleFields {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension Utils = new Utils()

    def dispatch displayField(EntityField it, String objName, String page) '''
        {$«objName».«name.formatForCode»«IF page == 'viewcsv'»|replace:"\"":""«ENDIF»}'''

    def dispatch displayField(BooleanField it, String objName, String page) {
        if (ajaxTogglability && (page == 'view' || page == 'display')) '''
            {assign var='itemid' value=$«objName».«entity.getFirstPrimaryKey.name.formatForCode»}
            <a id="toggle«name.formatForDB»{$itemid}" href="javascript:void(0);" style="display: none">
            {if $«objName».«name.formatForCode»}
                {icon type='ok' size='extrasmall' __alt='Yes' id="yes«name.formatForDB»_`$itemid`" __title="This setting is enabled. Click here to disable it."}
                {icon type='cancel' size='extrasmall' __alt='No' id="no«name.formatForDB»_`$itemid`" __title="This setting is disabled. Click here to enable it." style="display: none;"}
            {else}
                {icon type='ok' size='extrasmall' __alt='Yes' id="yes«name.formatForDB»_`$itemid`" __title="This setting is enabled. Click here to disable it." style="display: none;"}
                {icon type='cancel' size='extrasmall' __alt='No' id="no«name.formatForDB»_`$itemid`" __title="This setting is disabled. Click here to enable it."}
            {/if}
            </a>
            <noscript><div id="noscript«name.formatForDB»{$itemid}">
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
            {$«objName».«name.formatForCode»«IF country»|«entity.container.application.appName.formatForDB»GetCountryName|safetext«ELSEIF language»|getlanguagename|safetext«ENDIF»«IF page == 'viewcsv'»|replace:"\"":""«ENDIF»}'''
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
                <a href="mailto:{$«realName»}" title="{gt text='Send an email'}">{icon type='mail' size='extrasmall' __alt='Email'}</a>
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
                <a href="{$«realName»}" title="{gt text='Visit this page'}">{icon type='url' size='extrasmall' __alt='Homepage'}</a>
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
              <a href="{$«realName»FullPathURL}" title="{$«objName».«entity.getLeadingField.name.formatForCode»|replace:"\"":""}"{if $«realName»Meta.isImage} rel="imageviewer[«entity.name.formatForDB»]"{/if}>
              {if $«realName»Meta.isImage}
                  <img src="{$«realName»|«appNameSmall»ImageThumb:$«realName»FullPath:«IF page == 'display'»250:150«ELSE»32:20«ENDIF»}" width="«IF page == 'display'»250«ELSE»32«ENDIF»" height="«IF page == 'display'»150«ELSE»20«ENDIF»" alt="{$«objName».«entity.getLeadingField.name.formatForCode»|replace:"\"":""}" />
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
        {$«objName».«name.formatForCode»|«entity.container.application.appName.formatForDB»GetListEntry:'«entity.name.formatForCode»':'«name.formatForCode»'|safetext«IF page == 'viewcsv'»|replace:"\"":""«ENDIF»}'''

    def dispatch displayField(DateField it, String objName, String page) '''
        {$«objName».«name.formatForCode»|dateformat:'datebrief'}'''

    def dispatch displayField(DatetimeField it, String objName, String page) '''
        {$«objName».«name.formatForCode»|dateformat:'datetimebrief'}'''
}
