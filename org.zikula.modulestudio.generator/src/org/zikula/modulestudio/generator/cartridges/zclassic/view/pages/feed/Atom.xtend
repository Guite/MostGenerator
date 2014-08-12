package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Atom {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    Application app

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        app = application
        val templateFilePath = templateFileWithExtension('view', 'atom')
        if (!app.shouldBeSkipped(templateFilePath)) {
            println('Generating atom view templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, atomView(appName))
        }
    }

    def private atomView(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» atom feed *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        «IF application.targets('1.3.5')»{«appName.formatForDB»TemplateHeaders contentType='application/atom+xml'}«ENDIF»<?xml version="1.0" encoding="{charset assign='charset'}{if $charset eq 'ISO-8859-15'}ISO-8859-1{else}{$charset}{/if}" ?>
        <feed xmlns="http://www.w3.org/2005/Atom">
        {gt text='Latest «nameMultiple.formatForDisplay»' assign='channelTitle'}
        {gt text='A direct feed showing the list of «nameMultiple.formatForDisplay»' assign='channelDesc'}
            <title type="text">{$channelTitle}</title>
            <subtitle type="text">{$channelDesc} - {$modvars.ZConfig.slogan}</subtitle>
            <author>
                <name>{$modvars.ZConfig.sitename}</name>
            </author>
        {assign var='numItems' value=$items|@count}
        {if $numItems}
        {capture assign='uniqueID'}tag:{$baseurl|replace:'http://':''|replace:'/':''},{$items[0].createdDate|dateformat|default:$smarty.now|dateformat:'%Y-%m-%d'}:«IF app.targets('1.3.5')»{modurl modname='«appName»' type=$lct func='«defaultAction»' ot='«name.formatForCode»'«IF hasActions('display')» «routeParamsLegacy('items[0]', true, true)»«ENDIF»}«ELSE»{route name='«appName.formatForDB»_«name.formatForCode»_«IF hasActions('display')»display«ELSE»«IF hasActions('view')»view«ELSE»index«ENDIF»«ENDIF»'«IF hasActions('display')» «routeParams('items[0]', true)»«ENDIF» lct=$lct}«ENDIF»{/capture}
            <id>{$uniqueID}</id>
            <updated>{$items[0].updatedDate|default:$smarty.now|dateformat:'%Y-%m-%dT%H:%M:%SZ'}</updated>
        {/if}
        «IF app.targets('1.3.5')»
            <link rel="alternate" type="text/html" hreflang="{lang}" href="{modurl modname='«appName»' type=$lct func='«IF hasActions('index')»main«ELSEIF hasActions('view')»view' ot='«name.formatForCode»«ELSE»«app.getAdminAndUserControllers.map[actions].flatten.toList.head.name.formatForCode»«ENDIF»' fqurl=true}" />
        «ELSE»
            <link rel="alternate" type="text/html" hreflang="{lang}" href="{route name='«appName.formatForDB»_«name.formatForCode»_«IF hasActions('index')»index«ELSEIF hasActions('view')»view' lct=$lct«ELSE»«app.getAdminAndUserControllers.map[actions].flatten.toList.head.name.formatForCode»«ENDIF»' absolute=true}" />
        «ENDIF»
        <link rel="self" type="application/atom+xml" href="{php}echo substr(\System::getBaseUrl(), 0, strlen(\System::getBaseUrl())-1);{/php}{getcurrenturi}" />
        <rights>Copyright (c) {php}echo date('Y');{/php}, {$baseurl}</rights>

        «val objName = name.formatForCode»
        {foreach item='«objName»' from=$items}
            <entry>
                <title type="html">{$«objName»->getTitleFromDisplayPattern()|notifyfilters:'«appName.formatForDB».filterhook.«nameMultiple.formatForDB»'}</title>
                «IF app.targets('1.3.5')»
                    <link rel="alternate" type="text/html" href="{modurl modname='«appName»' type=$lct func='«defaultAction»' ot='«name.formatForCode»'«IF hasActions('display')» «routeParamsLegacy(objName, true, true)»«ENDIF» fqurl=true}" />
                    {capture assign='uniqueID'}tag:{$baseurl|replace:'http://':''|replace:'/':''},{$«objName».createdDate|dateformat|default:$smarty.now|dateformat:'%Y-%m-%d'}:{modurl modname='«appName»' type=$lct func='«defaultAction»' ot='«name.formatForCode»'«IF hasActions('display')» «routeParamsLegacy(objName, true, true)»«ENDIF»}{/capture}
                «ELSE»
                    <link rel="alternate" type="text/html" href="{route name='«appName.formatForDB»_«name.formatForCode»_«defaultAction»'«IF hasActions('display')» «routeParams(objName, true)»«ENDIF» lct=$lct absolute=true}" />
                    {capture assign='uniqueID'}tag:{$baseurl|replace:'http://':''|replace:'/':''},{$«objName».createdDate|dateformat|default:$smarty.now|dateformat:'%Y-%m-%d'}:{route name='«appName.formatForDB»_«name.formatForCode»_«defaultAction»'«IF hasActions('display')» «routeParams(objName, true)»«ENDIF» lct=$lct}{/capture}
                «ENDIF»
                <id>{$uniqueID}</id>
                «IF standardFields»
                    {if isset($«objName».updatedDate) && $«objName».updatedDate ne null}
                        <updated>{$«objName».updatedDate|dateformat:'%Y-%m-%dT%H:%M:%SZ'}</updated>
                    {/if}
                    {if isset($«objName».createdDate) && $«objName».createdDate ne null}
                        <published>{$«objName».createdDate|dateformat:'%Y-%m-%dT%H:%M:%SZ'}</published>
                    {/if}
                «ENDIF»
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
                        <author>
                           <name>{$cr_name|default:$cr_uname}</name>
                           <uri>{usergetvar name='_UYOURHOMEPAGE' uid=$«objName».createdUserId assign='homepage'}{$homepage|default:'-'}</uri>
                           <email>{usergetvar name='email' uid=$«objName».createdUserId}</email>
                        </author>
                        «IF metaData»
                            {elseif isset($«objName».__META__) && isset($«objName».__META__.author)}
                            <author>{$«objName».__META__.author}</author>
                        «ENDIF»
                    {/if}
                «ENDIF»

                «description(objName)»
            </entry>
        {/foreach}
        </feed>
    '''

    def private description(Entity it, String objName) '''
        «val textFields = fields.filter(TextField)»
        «val stringFields = fields.filter(StringField)»
        <summary type="html">
            <![CDATA[
            «IF !textFields.empty»
                {$«objName».«textFields.head.name.formatForCode»|truncate:150:"&hellip;"|default:'-'}
            «ELSEIF !stringFields.empty»
                {$«objName».«stringFields.head.name.formatForCode»|truncate:150:"&hellip;"|default:'-'}
            «ELSE»
                {$«objName»->getTitleFromDisplayPattern()|truncate:150:"&hellip;"|default:'-'}
            «ENDIF»
            ]]>
        </summary>
        <content type="html">
            <![CDATA[
            «IF textFields.size > 1»
                {$«objName».«textFields.tail.head.name.formatForCode»|replace:'<br>':'<br />'}
            «ELSEIF !textFields.empty && !stringFields.empty»
                {$«objName».«stringFields.head.name.formatForCode»|replace:'<br>':'<br />'}
            «ELSEIF stringFields.size > 1»
                {$«objName».«stringFields.tail.head.name.formatForCode»|replace:'<br>':'<br />'}
            «ELSE»
                {$«objName»->getTitleFromDisplayPattern()|replace:'<br>':'<br />'}
            «ENDIF»
            ]]>
        </content>
    '''
}
