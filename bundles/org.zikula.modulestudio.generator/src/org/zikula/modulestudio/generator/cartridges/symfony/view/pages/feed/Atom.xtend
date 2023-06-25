package org.zikula.modulestudio.generator.cartridges.symfony.view.pages.feed

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
        if (!hasIndexAction) {
            return
        }
        ('Generating Atom view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFileWithExtension('index', 'atom')
        fsa.generateFile(templateFilePath, atomView(application))
    }

    def private atomView(Entity it, Application app) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» atom feed #}
        {% trans_default_domain '«name.formatForCode»' %}
        <?xml version="1.0" encoding="{% set charset = pageGetVar('meta.charset') %}{% if charset == 'ISO-8859-15' %}ISO-8859-1{% else %}{{ charset|default('utf-8') }}{% endif %}" ?>
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title type="text">{% trans %}Latest «nameMultiple.formatForDisplay»{% endtrans %}</title>
            <subtitle type="text">{% trans %}A direct feed showing the list of «nameMultiple.formatForDisplay»{% endtrans %} - {{ siteSlogan() }}</subtitle>
            <author>
                <name>{{ siteName() }}</name>
            </author>
        {% set amountOfItems = items|length %}
        {% if amountOfItems > 0 %}
        {% set uniqueID %}tag:{{ app.request.schemeAndHttpHost|replace({'http://': '', '/': ''}) }},{{ «IF standardFields»items.first.createdDate«ELSE»'now'«ENDIF»|date('Y-m-d') }}:{{ path('«app.appName.formatForDB»_«name.formatForDB»_«defaultAction»'«IF hasDetailAction»«routeParams('items.first', true)»«ENDIF») }}{% endset %}
            <id>{{ uniqueID }}</id>
            <updated>{{ «IF standardFields»items[0].updatedDate«ELSE»'now'«ENDIF»|date('Y-m-dTH:M:SZ') }}</updated>
        {% endif %}
            <link rel="alternate" type="text/html" hreflang="{{ app.request.locale }}" href="{{ url('«app.appName.formatForDB»_«name.formatForDB»_«IF hasIndexAction»index«ELSE»«defaultAction»«ENDIF»') }}" />
            <link rel="self" type="application/atom+xml" href="{{ app.request.schemeAndHttpHost ~ app.request.basePath }}" />
            <rights>Copyright (c) {{ 'now'|date('Y') }}, {{ app.request.schemeAndHttpHost }}</rights>
        «val objName = name.formatForCode»
        {% for «objName» in items %}
            <entry>
                <title type="html">{{ «objName»|«app.appName.formatForDB»_formattedTitle }}</title>
                <link rel="alternate" type="text/html" href="{{ url('«app.appName.formatForDB»_«name.formatForDB»_«defaultAction»'«IF hasDetailAction»«routeParams(objName, true)»«ENDIF») }}" />
                {% set uniqueID %}tag:{{ app.request.schemeAndHttpHost|replace({ 'http://': '', '/': '' }) }},{{ «IF standardFields»«objName».createdDate«ELSE»'now'«ENDIF»|date('Y-m-d') }}:{{ path('«app.appName.formatForDB»_«name.formatForDB»_«defaultAction»'«IF hasDetailAction»«routeParams(objName, true)»«ENDIF») }}{% endset %}
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
