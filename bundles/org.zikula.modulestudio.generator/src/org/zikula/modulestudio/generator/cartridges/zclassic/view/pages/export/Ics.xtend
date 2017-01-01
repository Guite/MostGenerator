package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UrlField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Ics {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating ics view templates for entity "' + name.formatForDisplay + '"')
        val templateFilePath = templateFileWithExtension('display', 'ics')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, if (application.targets('1.3.x')) icsDisplayLegacy(appName) else icsDisplay(appName))
        }
    }

    def private icsDisplayLegacy(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display ics view *}
        {«appName.formatForDB»TemplateHeaders contentType='text/calendar; charset=iso-8859-15«/*charset=utf-8*/»' asAttachment=true fileName="«name.formatForCode»_`«IF hasSluggableFields»$«objName».slug«ELSE»$«objName»->getTitleFromDisplayPattern()«ENDIF»`.ics"}
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:{$baseurl}
        METHOD:PUBLISH
        BEGIN:VEVENT
        DTSTART:{php}$«objName» = $this->get_template_vars('«objName»'); echo gmdate('Ymd\THi00\Z', $«objName»['«getStartDateField.name.formatForCode»']) . "\r\n";{/php}
        DTEND:{php}$«objName» = $this->get_template_vars('«objName»'); echo gmdate('Ymd\THi00\Z', $«objName»['«getEndDateField.name.formatForCode»']) . "\r\n";{/php}
        {if $«objName».zipcode ne '' && $«objName».city ne ''}{assign var='location' value="`$«objName».zipcode` `$«objName».city`"}LOCATION{$location|«appName.formatForDB»FormatIcalText}{/if}
        «IF geographical»
            {if $«objName».latitude && $«objName».longitude}GEO:{$«objName».longitude};{$«objName».latitude}
            {/if}
        «ENDIF»
        TRANSP:OPAQUE
        SEQUENCE:0
        UID:{php}$«objName» = $this->get_template_vars('«objName»'); echo md5('ICAL' . $«objName»['«getStartDateField.name.formatForCode»'] . rand(1, 5000) . $«objName»['«getEndDateField.name.formatForCode»']) . "\r\n";{/php}
        DTSTAMP:{php}echo gmdate('Ymd\THi00\Z', time()) . "\r\n";{/php}
        «IF standardFields»
            ORGANIZER;CN="{usergetvar name='uname' uid=$«objName».createdUserId}":MAILTO:{usergetvar name='email' uid=$«objName».createdUserId}
        «ENDIF»
        «IF categorisable»
            CATEGORIES:{foreach name='categoryLoop' key='propName' item='catMapping' from=$«objName».categories}{if !$smarty.foreach.categoryLoop.first},{/if}{$catMapping.category.name|safetext|upper}{/foreach}
        «ENDIF»
        SUMMARY{$«objName»->getTitleFromDisplayPattern()|«appName.formatForDB»FormatIcalText}
        «IF hasTextFieldsEntity»
            «val field = getTextFieldsEntity.head»
            {if $«objName».«field.name.formatForCode» ne ''}DESCRIPTION{$«objName».«field.name.formatForCode»|«appName.formatForDB»FormatIcalText}{/if}
        «ENDIF»
        PRIORITY:5
        «IF hasUploadFieldsEntity»
            «FOR field : getUploadFieldsEntity»
                {if $«objName».«field.name.formatForCode»}ATTACH;VALUE=URL:{$«objName».«field.name.formatForCode»FullPathUrl}
                {/if}
            «ENDFOR»
        «ENDIF»
        «IF !fields.filter(UrlField).empty»
            «FOR field : fields.filter(UrlField)»
                {if $«objName».«field.name.formatForCode»}ATTACH;VALUE=URL:{$«objName».«field.name.formatForCode»}
                {/if}
            «ENDFOR»
        «ENDIF»
        CLASS:PUBLIC
        STATUS:CONFIRMED
        END:VEVENT
        END:VCALENDAR
    '''

    def private icsDisplay(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» display ics view #}
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:{{ app.request.getSchemeAndHttpHost() }}
        METHOD:PUBLISH
        BEGIN:VEVENT
        DTSTART:{{ «objName»|date('Ymd\THi00\Z') }}
        DTEND:{{ «objName»|date('Ymd\THi00\Z') }}
        {% if «objName».zipcode != '' and «objName».city is not empty %}{% set location = «objName».zipcode ~ ' ' ~ «objName».city %}LOCATION{{ location|«appName.formatForDB»_icalText }}{% endif %}
        «IF geographical»
            {% if «objName».latitude and «objName».longitude %}GEO:{{ «objName».longitude }};{{ «objName».latitude }}
            {% endif %}
        «ENDIF»
        TRANSP:OPAQUE
        SEQUENCE:0
        UID:{{ 'ICAL' ~ «objName».«getStartDateField.name.formatForCode» ~ random(5000) ~ «objName».«getEndDateField.name.formatForCode» }}
        DTSTAMP:{{ 'now'|date('Ymd\THi00\Z') }}
        «IF standardFields»
            ORGANIZER;CN="{{ «objName».createdUserId.getUname() }}":MAILTO:{{ «objName».createdUserId.getEmail() }}
        «ENDIF»
        «IF categorisable»
            CATEGORIES:{% for propName, catMapping in «objName».categories %}{% if not loop.first %},{% endif %}{{ catMapping.category.display_name[lang]|upper %}{% endfor %}
        «ENDIF»
        SUMMARY{{ «objName».getTitleFromDisplayPattern()|«appName.formatForDB»_icalText }}
        «IF hasTextFieldsEntity»
            «val field = getTextFieldsEntity.head»
            {% if «objName».«field.name.formatForCode» is not empty %}DESCRIPTION{{ «objName».«field.name.formatForCode»|«appName.formatForDB»_icalText }}{% endif %}
        «ENDIF»
        PRIORITY:5
        «IF hasUploadFieldsEntity»
            «FOR field : getUploadFieldsEntity»
                {% if «objName».«field.name.formatForCode» %}ATTACH;VALUE=URL:{{ «objName».«field.name.formatForCode»Url }}
                {% endif %}
            «ENDFOR»
        «ENDIF»
        «IF !fields.filter(UrlField).empty»
            «FOR field : fields.filter(UrlField)»
                {% if «objName».«field.name.formatForCode» %}ATTACH;VALUE=URL:{{ «objName».«field.name.formatForCode» }}
                {% endif %}
            «ENDFOR»
        «ENDIF»
        CLASS:PUBLIC
        STATUS:CONFIRMED
        END:VEVENT
        END:VCALENDAR
    '''
}
