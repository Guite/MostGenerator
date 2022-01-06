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

class Atom {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Entity it, IMostFileSystemAccess fsa) {
        if (!hasViewAction) {
            return
        }
        ('Generating Atom view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFileWithExtension('view', 'atom')
        fsa.generateFile(templateFilePath, atomView(application))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFileWithExtension('Admin/view', 'atom')
            fsa.generateFile(templateFilePath, atomView(application))
        }
    }

    def private atomView(Entity it, Application app) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» atom feed #}
        «IF !app.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        <?xml version="1.0" encoding="{% set charset = pageGetVar('meta.charset') %}{% if charset == 'ISO-8859-15' %}ISO-8859-1{% else %}{{ charset }}{% endif %}" ?>
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title type="text">{% trans %}Latest «nameMultiple.formatForDisplay»{% endtrans %}</title>
            <subtitle type="text">{% trans %}A direct feed showing the list of «nameMultiple.formatForDisplay»{% endtrans %} - {{ getSystemVar('slogan') }}</subtitle>
            <author>
                <name>{{ getSystemVar('sitename') }}</name>
            </author>
        {% set amountOfItems = items|length %}
        {% if amountOfItems > 0 %}
        {% set uniqueID %}tag:{{ app.request.schemeAndHttpHost|replace({'http://': '', '/': ''}) }},{{ «IF standardFields»items.first.createdDate«ELSE»'now'«ENDIF»|date('Y-m-d') }}:{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasDisplayAction»«routeParams('items.first', true)»«ENDIF») }}{% endset %}
            <id>{{ uniqueID }}</id>
            <updated>{{ «IF standardFields»items[0].updatedDate«ELSE»'now'«ENDIF»|date('Y-m-dTH:M:SZ') }}</updated>
        {% endif %}
            <link rel="alternate" type="text/html" hreflang="{{ app.request.locale }}" href="{{ url('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«IF hasIndexAction»index«ELSEIF hasViewAction»view«ELSE»«defaultAction»«ENDIF»') }}" />
            <link rel="self" type="application/atom+xml" href="{{ app.request.schemeAndHttpHost ~ app.request.basePath }}" />
            <rights>Copyright (c) {{ 'now'|date('Y') }}, {{ app.request.schemeAndHttpHost }}</rights>
        «val objName = name.formatForCode»
        {% for «objName» in items %}
            <entry>
                <title type="html">{{ «objName»|«app.appName.formatForDB»_formattedTitle«IF !skipHookSubscribers»|notifyFilters('«app.appName.formatForDB».filterhook.«nameMultiple.formatForDB»')|safeHtml«ENDIF» }}</title>
                <link rel="alternate" type="text/html" href="{{ url('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasDisplayAction»«routeParams(objName, true)»«ENDIF») }}" />
                {% set uniqueID %}tag:{{ app.request.schemeAndHttpHost|replace({ 'http://': '', '/': '' }) }},{{ «IF standardFields»«objName».createdDate«ELSE»'now'«ENDIF»|date('Y-m-d') }}:{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasDisplayAction»«routeParams(objName, true)»«ENDIF») }}{% endset %}
                <id>{{ uniqueID }}</id>
                «IF standardFields»
                    {% if «objName».updatedDate|default %}
                        <updated>{{ «objName».updatedDate|date('Y-m-dTH:M:SZ') }}</updated>
                    {% endif %}
                    {% if «objName».createdDate|default %}
                        <published>{{ «objName».createdDate|date('Y-m-dTH:M:SZ') }}</published>
                    {% endif %}
                    {% if «objName».createdBy|default and «objName».createdBy.getUid() > 0 %}
                        {% set creatorAttributes = «objName».createdBy.getAttributes() %}
                        <author>
                           <name>{{ creatorAttributes.get('realname')|default(creatorAttributes.get('name'))|default(«objName».createdBy.getUname()) }}</name>
                           <uri>{{ creatorAttributes.get('_UYOURHOMEPAGE')|default('-') }}</uri>
                           <email>{{ «objName».createdBy.getEmail() }}</email>
                        </author>
                    {% endif %}
                «ENDIF»
                «description(objName)»
            </entry>
        {% endfor %}
        </feed>
    '''

    def private description(Entity it, String objName) '''
        «val textFields = fields.filter(TextField)»
        «val stringFields = fields.filter(StringField)»
        <summary type="html">
            <![CDATA[
            «IF !textFields.empty»
                {{ «objName».«textFields.head.name.formatForCode»|u.truncate(150, '…')|default('-') }}
            «ELSEIF !stringFields.empty»
                {{ «objName».«stringFields.head.name.formatForCode»|u.truncate(150, '…')|default('-') }}
            «ELSE»
                {{ «objName»|«application.appName.formatForDB»_formattedTitle|u.truncate(150, '…')|default('-') }}
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
                {{ «objName»|«application.appName.formatForDB»_formattedTitle|replace({ '<br>': '<br />' }) }}
            «ENDIF»
            ]]>
        </content>
    '''
}
