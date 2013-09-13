package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Atom {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension UrlExtensions = new UrlExtensions
    @Inject extension Utils = new Utils

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' atom view templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(templateFileWithExtension(controller, name, 'view', 'atom'), atomView(appName, controller))
    }

    def private atomView(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» atom feed in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='application/atom+xml'}<?xml version="1.0" encoding="{charset assign='charset'}{if $charset eq 'ISO-8859-15'}ISO-8859-1{else}{$charset}{/if}" ?>
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
        {capture assign='uniqueID'}tag:{$baseurl|replace:'http://':''|replace:'/':''},{$items[0].createdDate|dateformat|default:$smarty.now|dateformat:'%Y-%m-%d'}:{modurl modname='«appName»' type='«controller.formattedName»' «IF controller.hasActions('display')»«modUrlDisplay('items[0]', true)»«ELSE»func='«IF controller.hasActions('view')»view«ELSE»«IF container.application.targets('1.3.5')»main«ELSE»index«ENDIF»«ENDIF»' ot='«name.formatForCode»'«ENDIF»}{/capture}
            <id>{$uniqueID}</id>
            <updated>{$items[0].updatedDate|default:$smarty.now|dateformat:'%Y-%m-%dT%H:%M:%SZ'}</updated>
        {/if}
            <link rel="alternate" type="text/html" hreflang="{lang}" href="{modurl modname='«appName»' type='«controller.formattedName»' func='«IF controller.hasActions('index')»«IF container.application.targets('1.3.5')»main«ELSE»index«ENDIF»«ELSE»«controller.actions.head.name.formatForCode»«ENDIF»' fqurl=1}" />
            <link rel="self" type="application/atom+xml" href="{php}echo substr(\System::getBaseURL(), 0, strlen(\System::getBaseURL())-1);{/php}{getcurrenturi}" />
            <rights>Copyright (c) {php}echo date('Y');{/php}, {$baseurl}</rights>

        {foreach item='«objName»' from=$items}
            <entry>
                «val leadingField = getLeadingField»
                «IF leadingField !== null»
                    <title type="html">{$«objName».«leadingField.name.formatForCode»|notifyfilters:'«appName.formatForDB».filterhook.«nameMultiple.formatForDB»'}</title>
                «ELSE»
                    <title type="html">{gt text='«name.formatForCodeCapital»'}</title>
                «ENDIF»
                <link rel="alternate" type="text/html" href="{modurl modname='«appName»' type='«controller.formattedName»' «IF controller.hasActions('display')»«modUrlDisplay(objName, true)»«ELSE»func='«IF controller.hasActions('view')»view«ELSE»«IF container.application.targets('1.3.5')»main«ELSE»index«ENDIF»«ENDIF»' ot='«name.formatForCode»'«ENDIF» fqurl='1'}" />

                {capture assign='uniqueID'}tag:{$baseurl|replace:'http://':''|replace:'/':''},{$«objName».createdDate|dateformat|default:$smarty.now|dateformat:'%Y-%m-%d'}:{modurl modname='«appName»' type='«controller.formattedName»' «IF controller.hasActions('display')»«modUrlDisplay(objName, true)»«ELSE»func='«IF controller.hasActions('view')»view«ELSE»«IF container.application.targets('1.3.5')»main«ELSE»index«ENDIF»«ENDIF»' ot='«name.formatForCode»'«ENDIF»}{/capture}
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

                «val textFields = fields.filter(TextField).filter[!leading]»
                «val stringFields = fields.filter(StringField).filter[!leading]»
                <summary type="html">
                    <![CDATA[
                    «IF !textFields.empty»
                        {$«objName».«textFields.head.name.formatForCode»|truncate:150:"&hellip;"|default:'-'}
                    «ELSEIF !stringFields.empty»
                        {$«objName».«stringFields.head.name.formatForCode»|truncate:150:"&hellip;"|default:'-'}
                    «ELSE»
                        «IF leadingField !== null»
                            {$«objName».«leadingField.name.formatForCode»|truncate:150:"&hellip;"|default:'-'}
                        «ENDIF»
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
                        «IF leadingField !== null»
                            {$«objName».«leadingField.name.formatForCode»|replace:'<br>':'<br />'}
                        «ENDIF»
                    «ENDIF»
                    ]]>
                </content>
            </entry>
        {/foreach}
        </feed>
    '''
}
