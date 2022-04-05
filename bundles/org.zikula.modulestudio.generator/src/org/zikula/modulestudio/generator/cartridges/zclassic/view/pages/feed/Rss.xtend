package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.feed

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
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

    def generate(Entity it, IMostFileSystemAccess fsa) {
        if (!hasViewAction) {
            return
        }
        ('Generating RSS view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFileWithExtension('view', 'rss')
        fsa.generateFile(templateFilePath, rssView(application))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFileWithExtension('Admin/view', 'rss')
            fsa.generateFile(templateFilePath, rssView(application))
        }
    }

    def private rssView(Entity it, Application app) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» rss feed #}
        «IF !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        <?xml version="1.0" encoding="{% set charset = pageGetVar('meta.charset') %}{% if charset == 'ISO-8859-15' %}ISO-8859-1{% else %}{{ charset|default('utf-8') }}{% endif %}" ?>
        <rss version="2.0"
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:sy="http://purl.org/rss/1.0/modules/syndication/"
            xmlns:admin="http://webns.net/mvcb/"
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:content="http://purl.org/rss/1.0/modules/content/"
            xmlns:atom="http://www.w3.org/2005/Atom">
        {#<rss version="0.92">#}
            <channel>
                <title>{% trans %}Latest «nameMultiple.formatForDisplay»{% endtrans %}</title>
                <link>{{ app.request.schemeAndHttpHost ~ app.request.basePath }}</link>
                <atom:link href="{{ app.request.schemeAndHttpHost ~ app.request.basePath ~ app.request.pathInfo }}" rel="self" type="application/rss+xml" />
                <description>{% trans %}A direct feed showing the list of «nameMultiple.formatForDisplay»{% endtrans %} - {{ getSystemVar('slogan') }}</description>
                <language>{{ app.request.locale }}</language>
                {# commented out as imagepath is not defined and we can't know whether this logo exists or not
                <image>
                    <title>{{ getSystemVar('sitename') }}</title>
                    <url>{{ app.request.schemeAndHttpHost ~ app.request.basePath }}{{ imagepath }}/logo.jpg</url>
                    <link>{{ app.request.schemeAndHttpHost ~ app.request.basePath }}</link>
                </image>
                #}
                <docs>http://blogs.law.harvard.edu/tech/rss</docs>
                <copyright>Copyright (c) {{ 'now'|date('Y') }}, {{ app.request.schemeAndHttpHost }}</copyright>
                <webMaster>{{ getSystemVar('adminmail') }}</webMaster>
        «val objName = name.formatForCode»
        {% for «objName» in items %}
            <item>
                <title><![CDATA[{{ «objName»|«app.appName.formatForDB»_formattedTitle«IF !skipHookSubscribers»|notifyFilters('«app.appName.formatForDB».filterhook.«nameMultiple.formatForDB»')|safeHtml«ENDIF» }}]]></title>
                <link>{{ url('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasDisplayAction»«routeParams(objName, true)»«ENDIF») }}</link>
                <guid>{{ url('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasDisplayAction»«routeParams(objName, true)»«ENDIF») }}</guid>
                «IF standardFields»
                    {% if «objName».createdBy|default and «objName».createdBy.getUid() > 0 %}
                        {% set creatorAttributes = «objName».createdBy.getAttributes() %}
                        <author>{{ «objName».createdBy.getEmail() }} ({{ creatorAttributes.get('realname')|default(creatorAttributes.get('name'))|default(«objName».createdBy.getUname()) }})</author>
                    {% endif %}
                «ENDIF»
                «IF categorisable»
                    <category><![CDATA[{% trans %}Categories{% endtrans %}: {% for catMapping in «objName».categories %}{{ catMapping.category.display_name[app.request.locale]|default(catMapping.category.name) }}{% if not loop.last %}, {% endif %}{% endfor %}]]></category>
                «ENDIF»
                «description(objName)»
            </item>
        {% endfor %}
            </channel>
        </rss>
    '''

    def private description(Entity it, String objName) '''
        «val textFields = fields.filter(TextField)»
        «val stringFields = fields.filter(StringField)»
        <description>
            <![CDATA[
            «IF !textFields.empty»
                {{ «objName».«textFields.head.name.formatForCode»|replace({'<br>': '<br />'}) }}
            «ELSEIF !stringFields.empty»
                {{ «objName».«stringFields.head.name.formatForCode»|replace({'<br>': '<br />'}) }}
            «ELSE»
                {{ «objName»|«application.appName.formatForDB»_formattedTitle|replace({'<br>': '<br />'}) }}
            «ENDIF»
            ]]>
        </description>
        «IF standardFields»
            {% if «objName».createdDate|default %}
                <pubDate>{{ «objName».createdDate|date('r') }}</pubDate>
            {% endif %}
        «ENDIF»
    '''
}
