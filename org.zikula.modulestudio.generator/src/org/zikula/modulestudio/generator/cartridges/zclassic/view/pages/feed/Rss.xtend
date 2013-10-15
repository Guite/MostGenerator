package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Rss {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension UrlExtensions = new UrlExtensions
    @Inject extension Utils = new Utils

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' rss view templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(templateFileWithExtension(controller, name, 'view', 'rss'), rssView(appName, controller))
    }

    def private rssView(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» rss feed in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='application/rss+xml'}<?xml version="1.0" encoding="{charset assign='charset'}{if $charset eq 'ISO-8859-15'}ISO-8859-1{else}{$charset}{/if}" ?>
        <rss version="2.0"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"
            xmlns:admin="http://webns.net/mvcb/"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:content="http://purl.org/rss/1.0/modules/content/"
            xmlns:atom="http://www.w3.org/2005/Atom">
        {*<rss version="0.92">*}
        {gt text='Latest «nameMultiple.formatForDisplay»' assign='channelTitle'}
        {gt text='A direct feed showing the list of «nameMultiple.formatForDisplay»' assign='channelDesc'}
            <channel>
                <title>{$channelTitle}</title>
                <link>{$baseurl|escape:'html'}</link>
                <atom:link href="{php}echo substr(\System::getBaseURL(), 0, strlen(\System::getBaseURL())-1);{/php}{getcurrenturi}" rel="self" type="application/rss+xml" />
                <description>{$channelDesc} - {$modvars.ZConfig.slogan}</description>
                <language>{lang}</language>
                {* commented out as $imagepath is not defined and we can't know whether this logo exists or not
                <image>
                    <title>{$modvars.ZConfig.sitename}</title>
                    <url>{$baseurl|escape:'html'}{$imagepath}/logo.jpg</url>
                    <link>{$baseurl|escape:'html'}</link>
                </image>
                *}
                <docs>http://blogs.law.harvard.edu/tech/rss</docs>
                <copyright>Copyright (c) {php}echo date('Y');{/php}, {$baseurl}</copyright>
                <webMaster>{$modvars.ZConfig.adminmail|escape:'html'} ({usergetvar name='uname' uid=2})</webMaster>

        {foreach item='«objName»' from=$items}
            <item>
                <title><![CDATA[{if isset($«objName».updatedDate) && $«objName».updatedDate ne null}{$«objName».updatedDate|dateformat} - {/if}{$«objName».getTitleFromDisplayPattern()|notifyfilters:'«appName.formatForDB».filterhook.«nameMultiple.formatForDB»'}]]></title>
                <link>{modurl modname='«appName»' type='«controller.formattedName»' «IF controller.hasActions('display')»«modUrlDisplay(objName, true)»«ELSE»func='«IF controller.hasActions('view')»view«ELSE»«IF container.application.targets('1.3.5')»main«ELSE»index«ENDIF»«ENDIF»' ot='«name.formatForCode»'«ENDIF» fqurl='1'}</link>
                <guid>{modurl modname='«appName»' type='«controller.formattedName»' «IF controller.hasActions('display')»«modUrlDisplay(objName, true)»«ELSE»func='«IF controller.hasActions('view')»view«ELSE»«IF container.application.targets('1.3.5')»main«ELSE»index«ENDIF»«ENDIF»' ot='«name.formatForCode»'«ENDIF» fqurl='1'}</guid>
                «IF !standardFields»
                    «IF metaData»
                        {if isset($«objName».__META__) && isset($«objName».__META__.author)}
                            <author>{$«objName».__META__.author}</author>
                        {/if}
                    «ENDIF»
                «ELSE»
                    {if isset($«objName».createdUserId)}
                        {usergetvar name='uname' uid=$«objName».createdUserId assign='cr_uname'}
                        {usergetvar name='name' uid=$«objName».createdUserId assign='cr_name'}
                        <author>{usergetvar name='email' uid=$«objName».createdUserId} ({$cr_name|default:$cr_uname})</author>
                        «IF metaData»
                            {elseif isset($«objName».__META__) && isset($«objName».__META__.author)}
                                <author>{$«objName».__META__.author}</author>
                        «ENDIF»
                    {/if}
                «ENDIF»
                «IF categorisable»

                    <category><![CDATA[{gt text='Categories'}: {foreach name='categoryLoop' key='propName' item='catMapping' from=$«objName».categories}{$catMapping.category.name|safetext}{if !$smarty.foreach.categoryLoop.last}, {/if}{/foreach}]]></category>
                «ENDIF»

                «val textFields = fields.filter(TextField).filter[!leading]»
                «val stringFields = fields.filter(StringField).filter[!leading]»
                <description>
                    <![CDATA[
                    «IF !textFields.empty»
                        {$«objName».«textFields.head.name.formatForCode»|replace:'<br>':'<br />'}
                    «ELSEIF !stringFields.empty»
                        {$«objName».«stringFields.head.name.formatForCode»|replace:'<br>':'<br />'}
                    «ELSE»
                        {$«objName».getTitleFromDisplayPattern()|replace:'<br>':'<br />'}
                    «ENDIF»
                    ]]>
                </description>
                «IF standardFields»
                    {if isset($«objName».createdDate) && $«objName».createdDate ne null}
                        <pubDate>{$«objName».createdDate|dateformat:"%a, %d %b %Y %T +0100"}</pubDate>
                    {/if}
                «ENDIF»
            </item>
        {/foreach}
            </channel>
        </rss>
    '''
}
