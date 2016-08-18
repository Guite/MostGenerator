package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Rss {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        val templateFilePath = templateFileWithExtension('view', 'rss')
        if (!application.shouldBeSkipped(templateFilePath)) {
            println('Generating rss view templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, if (application.targets('1.3.x')) rssViewLegacy(appName) else rssView(appName))
        }
    }

    def private rssViewLegacy(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» rss feed *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        {«appName.formatForDB»TemplateHeaders contentType='application/rss+xml'}<?xml version="1.0" encoding="{charset assign='charset'}{if $charset eq 'ISO-8859-15'}ISO-8859-1{else}{$charset}{/if}" ?>
        <rss version="2.0"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"
            xmlns:admin="http://webns.net/mvcb/"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:content="http://purl.org/rss/1.0/modules/content/"
            xmlns:atom="http://www.w3.org/2005/Atom">
        {*<rss version="0.92">*}
            <channel>
                <title>{gt text='Latest «nameMultiple.formatForDisplay»'}</title>
                <link>{$baseurl|escape:'html'}</link>
                <atom:link href="{php}echo substr(\System::getBaseUrl(), 0, strlen(\System::getBaseUrl())-1);{/php}{getcurrenturi}" rel="self" type="application/rss+xml" />
                <description>{gt text='A direct feed showing the list of «nameMultiple.formatForDisplay»'} - {$modvars.ZConfig.slogan}</description>
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
                <webMaster>{$modvars.ZConfig.adminmail|escape:'html'} ({usergetvar name='name' uid=2 default='admin'})</webMaster>

        «val objName = name.formatForCode»
        {foreach item='«objName»' from=$items}
            <item>
                <title><![CDATA[{if isset($«objName».updatedDate) && $«objName».updatedDate ne null}{$«objName».updatedDate|dateformat} - {/if}{$«objName»->getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters:'«appName.formatForDB».filterhook.«nameMultiple.formatForDB»'«ENDIF»}]]></title>
                <link>{modurl modname='«appName»' type=$lct func='«defaultAction»' ot='«name.formatForCode»'«IF hasActions('display')» «routeParamsLegacy(objName, true, true)»«ENDIF» fqurl=true}</link>
                <guid>{modurl modname='«appName»' type=$lct func='«defaultAction»' ot='«name.formatForCode»'«IF hasActions('display')» «routeParamsLegacy(objName, true, true)»«ENDIF» fqurl=true}</guid>
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
                        <author>{usergetvar name='email' uid=$«objName».createdUserId} ({$cr_name|default:$cr_uname})</author>
                        «IF metaData»
                            {elseif isset($«objName».metadata) && isset($«objName».metadata.author)}
                                <author>{$«objName».metadata.author}</author>
                        «ENDIF»
                    {/if}
                «ENDIF»
                «IF categorisable»

                    <category><![CDATA[{gt text='Categories'}: {foreach name='categoryLoop' key='propName' item='catMapping' from=$«objName».categories}{$catMapping.category.name|safetext}{if !$smarty.foreach.categoryLoop.last}, {/if}{/foreach}]]></category>
                «ENDIF»

                «descriptionLegacy(objName)»
            </item>
        {/foreach}
            </channel>
        </rss>
    '''

    def private rssView(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» rss feed #}
        <?xml version="1.0" encoding="{% set charset = pageGetVar('meta.charset') %}{% if charset == 'ISO-8859-15' %}ISO-8859-1{% else %}{{ charset }}{% endif %}" ?>
        <rss version="2.0"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"
            xmlns:admin="http://webns.net/mvcb/"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:content="http://purl.org/rss/1.0/modules/content/"
            xmlns:atom="http://www.w3.org/2005/Atom">
        {*<rss version="0.92">*}
        {% set homePath = pageGetVar('homepath') %}
            <channel>
                <title>{{ __('Latest «nameMultiple.formatForDisplay»') }}</title>
                <link>{{ homePath|e }}</link>
                <atom:link href="{{ homePath ~ app.request.getPathInfo() }}" rel="self" type="application/rss+xml" />
                <description>{{ __('A direct feed showing the list of «nameMultiple.formatForDisplay»') }} - {{ getModVar('ZConfig', 'slogan') }}</description>
                <language>{{ lang() }}</language>
                {# commented out as imagepath is not defined and we can't know whether this logo exists or not
                <image>
                    <title>{{ getModVar('ZConfig', 'sitename') }}</title>
                    <url>{{ homePath|e }}{{ imagepath }}/logo.jpg</url>
                    <link>{{ homePath|e }}</link>
                </image>
                #}
                <docs>http://blogs.law.harvard.edu/tech/rss</docs>
                <copyright>Copyright (c) {{ 'now'|date('Y') }}, {{ homePath|e }}</copyright>
                <webMaster>{{ pageGetVar('adminmail)|e }} ({{ «appName.toLowerCase»_userVar('name', 2, 'admin') }})</webMaster>
        «val objName = name.formatForCode»
        {% for «objName» in items %}
            {{ block('entry') }}
        {% endfor %}
            </channel>
        </rss>
        {% block entry %}
            <item>
                {{ block('entry_content') }}
            </item>
        {% endblock %}
        {% block entry_content %}
            <title><![CDATA[{% if «objName».updatedDate|default %}{{ «objName».updatedDate|localizeddate('medium', 'short') }} - {% endif %}{{ «objName».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyfilters('«appName.formatForDB».filterhook.«nameMultiple.formatForDB»')«ENDIF» }}]]></title>
            <link>{{ url('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasActions('display')»«routeParams(objName, true)»«ENDIF») }}</link>
            <guid>{{ url('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasActions('display')»«routeParams(objName, true)»«ENDIF») }}</guid>
            «IF !standardFields»
                «IF metaData»
                    {% if «objName».metadata|default and «objName».metadata.author|default %}
                        <author>{{ «objName».metadata.author }}</author>
                    {% endif %}
                «ENDIF»
            «ELSE»
                {% if «objName».createdUserId is defined %}
                    {% set cr_uname = «appName.toLowerCase»_userVar('uname', obj.createdUserId) %}
                    {% set cr_name = «appName.toLowerCase»_userVar('name', obj.createdUserId) %}
                    <author>{{ «appName.toLowerCase»_userVar('email', «objName».createdUserId) }} ({{ cr_name|default(cr_uname) }})</author>
                    «IF metaData»
                        {% elseif «objName».metadata|default and «objName».metadata.author|default %}
                            <author>{{ «objName».metadata.author }}</author>
                    «ENDIF»
                {% endif %}
            «ENDIF»
            «IF categorisable»
                <category><![CDATA[{{ __('Categories') }}: {% for propName, catMapping in «objName».categories %}{{ catMapping.category.display_name[lang] }}{% if not loop.last %}, {% endif %}{% endfor %}]]></category>
            «ENDIF»
            «description(objName)»
        {% endblock %}
    '''

    def private descriptionLegacy(Entity it, String objName) '''
        «val textFields = fields.filter(TextField)»
        «val stringFields = fields.filter(StringField)»
        <description>
            <![CDATA[
            «IF !textFields.empty»
                {$«objName».«textFields.head.name.formatForCode»|replace:'<br>':'<br />'}
            «ELSEIF !stringFields.empty»
                {$«objName».«stringFields.head.name.formatForCode»|replace:'<br>':'<br />'}
            «ELSE»
                {$«objName»->getTitleFromDisplayPattern()|replace:'<br>':'<br />'}
            «ENDIF»
            ]]>
        </description>
        «IF standardFields»
            {if isset($«objName».createdDate) && $«objName».createdDate ne null}
                <pubDate>{$«objName».createdDate|dateformat:"%a, %d %b %Y %T +0100"}</pubDate>
            {/if}
        «ENDIF»
    '''

    def private description(Entity it, String objName) '''
        «val textFields = fields.filter(TextField)»
        «val stringFields = fields.filter(StringField)»
        <description>
            <![CDATA[
            «IF !textFields.empty»
                {{ «objName».«textFields.head.name.formatForCode»|replace({ '<br>': '<br />' }) }}
            «ELSEIF !stringFields.empty»
                {{ «objName».«stringFields.head.name.formatForCode»|replace({ '<br>': '<br />' }) }}
            «ELSE»
                {{ «objName».getTitleFromDisplayPattern()|replace({ '<br>': '<br />' }) }}
            «ENDIF»
            ]]>
        </description>
        «IF standardFields»
            {% if «objName».createdDate|default %}
                <pubDate>{{ «objName».createdDate|date('a, d b Y T +0100') }}</pubDate>
            {% endif %}
        «ENDIF»
    '''
}
