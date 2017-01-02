package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UrlField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Ics {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating ics view templates for entity "' + name.formatForDisplay + '"')
        val templateFilePath = templateFileWithExtension('display', 'ics')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, icsDisplay(appName))
        }
    }

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
