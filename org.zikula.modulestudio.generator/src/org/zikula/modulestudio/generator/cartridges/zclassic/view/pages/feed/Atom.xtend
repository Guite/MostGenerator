package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
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
            fsa.generateFile(templateFilePath, if (app.targets('1.3.x')) atomViewLegacy(appName) else atomView(appName))
        }
    }

    def private atomViewLegacy(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» atom feed *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        {«appName.formatForDB»TemplateHeaders contentType='application/atom+xml'}<?xml version="1.0" encoding="{charset assign='charset'}{if $charset eq 'ISO-8859-15'}ISO-8859-1{else}{$charset}{/if}" ?>
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title type="text">{gt text='Latest «nameMultiple.formatForDisplay»'}</title>
            <subtitle type="text">{gt text='A direct feed showing the list of «nameMultiple.formatForDisplay»'} - {$modvars.ZConfig.slogan}</subtitle>
            <author>
                <name>{$modvars.ZConfig.sitename}</name>
            </author>
        {assign var='amountOfItems' value=$items|@count}
        {if $amountOfItems gt 0}
        {capture assign='uniqueID'}tag:{$baseurl|replace:'http://':''|replace:'/':''},{«IF standardFields»$items[0].createdDate«ELSE»$smarty.now«ENDIF»|dateformat:'%Y-%m-%d'}:{modurl modname='«appName»' type=$lct func='«defaultAction»' ot='«name.formatForCode»'«IF hasActions('display')»«routeParamsLegacy('items[0]', true, true)»«ENDIF»}{/capture}
            <id>{$uniqueID}</id>
            <updated>{«IF standardFields»$items[0].updatedDate«ELSE»$smarty.now«ENDIF»|dateformat:'%Y-%m-%dT%H:%M:%SZ'}</updated>
        {/if}
        <link rel="alternate" type="text/html" hreflang="{lang}" href="{modurl modname='«appName»' type=$lct func='«IF hasActions('index')»main«ELSEIF hasActions('view')»view' ot='«name.formatForCode»«ELSE»«app.getAdminAndUserControllers.map[actions].flatten.toList.head.name.formatForCode»«ENDIF»' fqurl=true}" />
        <link rel="self" type="application/atom+xml" href="{php}echo substr(\System::getBaseUrl(), 0, strlen(\System::getBaseUrl())-1);{/php}{getcurrenturi}" />
        <rights>Copyright (c) {php}echo date('Y');{/php}, {$baseurl}</rights>

        «val objName = name.formatForCode»
        {foreach item='«objName»' from=$items}
            <entry>
                <title type="html">{$«objName»->getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters:'«appName.formatForDB».filterhook.«nameMultiple.formatForDB»'«ENDIF»}</title>
                <link rel="alternate" type="text/html" href="{modurl modname='«appName»' type=$lct func='«defaultAction»' ot='«name.formatForCode»'«IF hasActions('display')»«routeParamsLegacy(objName, true, true)»«ENDIF» fqurl=true}" />
                {capture assign='uniqueID'}tag:{$baseurl|replace:'http://':''|replace:'/':''},{«IF standardFields»$«objName».createdDate«ELSE»$smarty.now«ENDIF»|dateformat:'%Y-%m-%d'}:{modurl modname='«appName»' type=$lct func='«defaultAction»' ot='«name.formatForCode»'«IF hasActions('display')»«routeParamsLegacy(objName, true, true)»«ENDIF»}{/capture}
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
                        {if isset($«objName».metadata) && isset($«objName».metadata.author)}
                            <author>{$«objName».metadata.author}</author>
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
                            {elseif isset($«objName».metadata) && isset($«objName».metadata.author)}
                            <author>{$«objName».metadata.author}</author>
                        «ENDIF»
                    {/if}
                «ENDIF»

                «descriptionLegacy(objName)»
            </entry>
        {/foreach}
        </feed>
    '''

    def private atomView(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» atom feed #}
        {{ «appName.formatForDB»_templateHeaders(contentType='application/atom+xml') }}<?xml version="1.0" encoding="{% set charset = pageGetVar('meta.charset') %}{% if charset == 'ISO-8859-15' %}ISO-8859-1{% else %}{{ charset }}{% endif %}" ?>
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title type="text">{{ __('Latest «nameMultiple.formatForDisplay»') }}</title>
            <subtitle type="text">{{ __('A direct feed showing the list of «nameMultiple.formatForDisplay»') }} - {{ getModVar('ZConfig', 'slogan') }}</subtitle>
            <author>
                <name>{{ getModVar('ZConfig', 'sitename') }}</name>
            </author>
        {% set homePath = pageGetVar('homepath') %}
        {% set amountOfItems = items|length %}
        {% if amountOfItems > 0 %}
        {% set uniqueID %}tag:{{ homePath|replace({ 'http://': '', '/': '' }) }},{{ «IF standardFields»items.first.createdDate«ELSE»'now'«ENDIF»|date('Y-m-d') }}:{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«IF hasActions('display')»display«ELSE»«IF hasActions('view')»view«ELSE»index«ENDIF»«ENDIF»'«IF hasActions('display')»«routeParams('items.first', true)»«ENDIF») }}{% endset %}
            <id>{{ uniqueID }}</id>
            <updated>{{ «IF standardFields»items[0].updatedDate«ELSE»'now'«ENDIF»|date('Y-m-dTH:M:SZ') }}</updated>
        {% endif %}
        <link rel="alternate" type="text/html" hreflang="{{ lang() }}" href="{{ url('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«IF hasActions('index')»index«ELSEIF hasActions('view')»view«ELSE»«app.getAdminAndUserControllers.map[actions].flatten.toList.head.name.formatForCode»«ENDIF»') }}" />
        <link rel="self" type="application/atom+xml" href="{{ homePath ~ app.request.getPathInfo() }}" />
        <rights>Copyright (c) {{ 'now'|date('Y') }}, {{ homePath|e }}</rights>

        «val objName = name.formatForCode»
        {% for «objName» in items %}
            <entry>
                <title type="html">{{ «objName».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters('«appName.formatForDB».filterhook.«nameMultiple.formatForDB»')«ENDIF» }}</title>
                <link rel="alternate" type="text/html" href="{{ url('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasActions('display')»«routeParams(objName, true)»«ENDIF») }}" />
                {% set uniqueID %}tag:{{ homePath|replace({ 'http://': '', '/': '' }) }},{{ «IF standardFields»«objName».createdDate«ELSE»'now'«ENDIF»|date('Y-m-d') }}:{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasActions('display')»«routeParams(objName, true)»«ENDIF») }}{% endset %}
                <id>{{ uniqueID }}</id>
                «IF standardFields»
                    {% if «objName».updatedDate|default %}
                        <updated>{{ «objName».updatedDate|date('Y-m-dTH:M:SZ') }}</updated>
                    {% endif %}
                    {% if «objName».createdDate|default %}
                        <published>{{ «objName».createdDate|date('Y-m-dTH:M:SZ') }}</published>
                    {% endif %}
                «ENDIF»
                «IF !standardFields»
                    «IF metaData»
                        {% if «objName».metadata is defined and «objName».metadata.author is defined %}
                            <author>{{ «objName».metadata.author }}</author>
                        {/if}
                    «ENDIF»
                «ELSE»
                    {% if «objName».createdUserId is defined %}
                        {% set cr_uname = «appName.toLowerCase»_userVar('uname', obj.createdUserId) %}
                        {% set cr_name = «appName.toLowerCase»_userVar('name', obj.createdUserId) %}
                        <author>
                           <name>{{ cr_name|default(cr_uname) }}</name>
                           <uri>{{ «appName.toLowerCase»_userVar('_UYOURHOMEPAGE', «objName».createdUserId, '-') }}</uri>
                           <email>{{ «appName.toLowerCase»_userVar('email', «objName».createdUserId) }}</email>
                        </author>
                        «IF metaData»
                            {% elseif «objName».metadata is defined and «objName».metadata.author is defined %}
                            <author>{{ «objName».metadata.author }}</author>
                        «ENDIF»
                        #}
                    {% endif %}
                «ENDIF»

                «description(objName)»
            </entry>
        {% endfor %}
        </feed>
    '''

    def private descriptionLegacy(Entity it, String objName) '''
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
                {$«objName».getTitleFromDisplayPattern()|replace:'<br>':'<br />'}
            «ENDIF»
            ]]>
        </content>
    '''

    def private description(Entity it, String objName) '''
        «val textFields = fields.filter(TextField)»
        «val stringFields = fields.filter(StringField)»
        <summary type="html">
            <![CDATA[
            «IF !textFields.empty»
                {{ «objName».«textFields.head.name.formatForCode»|truncate(150, true, '&hellip;')|default('-') }}
            «ELSEIF !stringFields.empty»
                {{ «objName».«stringFields.head.name.formatForCode»|truncate(150, true, '&hellip;')|default('-') }}
            «ELSE»
                {{ «objName».getTitleFromDisplayPattern()|truncate(150, true, '&hellip;')|default('-') }}
            «ENDIF»
            ]]>
        </summary>
        <content type="html">
            <![CDATA[
            «IF textFields.size > 1»
                {{ «objName».«textFields.tail.head.name.formatForCode»|replace({ '<br>': '<br />' }) }}
            «ELSEIF !textFields.empty && !stringFields.empty»
                {{ «objName».«stringFields.head.name.formatForCode»|replace({ '<br>': '<br />' }) }}
            «ELSEIF stringFields.size > 1»
                {{ «objName».«stringFields.tail.head.name.formatForCode»|replace({ '<br>': '<br />' }) }}
            «ELSE»
                {{ «objName».getTitleFromDisplayPattern()|replace({ '<br>': '<br />' }) }}
            «ENDIF»
            ]]>
        </content>
    '''
}
