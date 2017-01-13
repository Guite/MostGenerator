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

class Atom {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions

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
        {# purpose of this template: «nameMultiple.formatForDisplay» atom feed #}
        <?xml version="1.0" encoding="{% set charset = pageGetVar('meta.charset') %}{% if charset == 'ISO-8859-15' %}ISO-8859-1{% else %}{{ charset }}{% endif %}" ?>
        <feed xmlns="http://www.w3.org/2005/Atom">
            <title type="text">{{ __('Latest «nameMultiple.formatForDisplay»') }}</title>
            <subtitle type="text">{{ __('A direct feed showing the list of «nameMultiple.formatForDisplay»') }} - {{ getModVar('ZConfig', 'slogan') }}</subtitle>
            <author>
                <name>{{ getModVar('ZConfig', 'sitename') }}</name>
            </author>
        {% set amountOfItems = items|length %}
        {% if amountOfItems > 0 %}
        {% set uniqueID %}tag:{{ app.request.getSchemeAndHttpHost()|replace({ 'http://': '', '/': '' }) }},{{ «IF standardFields»items.first.createdDate«ELSE»'now'«ENDIF»|date('Y-m-d') }}:{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasDisplayAction»«routeParams('items.first', true)»«ENDIF») }}{% endset %}
            <id>{{ uniqueID }}</id>
            <updated>{{ «IF standardFields»items[0].updatedDate«ELSE»'now'«ENDIF»|date('Y-m-dTH:M:SZ') }}</updated>
        {% endif %}
            <link rel="alternate" type="text/html" hreflang="{{ app.request.locale }}" href="{{ url('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«IF hasIndexAction»index«ELSEIF hasViewAction»view«ELSE»«defaultAction»«ENDIF»') }}" />
            <link rel="self" type="application/atom+xml" href="{{ app.request.getSchemeAndHttpHost() ~ app.request.getBasePath() }}" />
            <rights>Copyright (c) {{ 'now'|date('Y') }}, {{ app.request.getSchemeAndHttpHost()|e }}</rights>
        «val objName = name.formatForCode»
        {% for «objName» in items %}
            {{ block('entry') }}
        {% endfor %}
        </feed>
        {% block entry %}
            <entry>
                {{ block('entry_content') }}
            </entry>
        {% endblock %}
        {% block entry_content %}
            <title type="html">{{ «objName».getTitleFromDisplayPattern()«IF !skipHookSubscribers»|notifyFilters('«appName.formatForDB».filterhook.«nameMultiple.formatForDB»')«ENDIF» }}</title>
            <link rel="alternate" type="text/html" href="{{ url('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasDisplayAction»«routeParams(objName, true)»«ENDIF») }}" />
            {% set uniqueID %}tag:{{ app.request.getSchemeAndHttpHost()|replace({ 'http://': '', '/': '' }) }},{{ «IF standardFields»«objName».createdDate«ELSE»'now'«ENDIF»|date('Y-m-d') }}:{{ path('«appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ '«defaultAction»'«IF hasDisplayAction»«routeParams(objName, true)»«ENDIF») }}{% endset %}
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
                       <name>{{ creatorAttributes.get('name')|default(«objName».createdBy.getUname()) }}</name>
                       <uri>{{ creatorAttributes.get('_UYOURHOMEPAGE')|default('-') }}</uri>
                       <email>{{ «objName».createdBy.getEmail() }}</email>
                    </author>
                {% endif %}
            «ENDIF»
            «description(objName)»
        {% endblock %}
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
