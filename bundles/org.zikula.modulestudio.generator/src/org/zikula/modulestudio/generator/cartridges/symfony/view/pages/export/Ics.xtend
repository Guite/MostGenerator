package org.zikula.modulestudio.generator.cartridges.symfony.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UrlField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Ics {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, IMostFileSystemAccess fsa) {
        if (!hasDetailAction) {
            return
        }
        ('Generating ICS view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFileWithExtension('detail', 'ics')
        fsa.generateFile(templateFilePath, icsDetail)
    }

    def private icsDetail(Entity it) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» detail ics view #}
        {% trans_default_domain '«name.formatForCode»' %}
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:{{ app.request.schemeAndHttpHost }}
        METHOD:PUBLISH
        BEGIN:VEVENT
        DTSTART:{{ «objName».«getStartDateField.name.formatForCode»|date('Ymd\THi00\Z') }}
        DTEND:{{ «objName».«getEndDateField.name.formatForCode»|date('Ymd\THi00\Z') }}
        {% if «objName».zipcode != '' and «objName».city is not empty %}{% set location = «objName».zipcode ~ ' ' ~ «objName».city %}LOCATION{{ location|«application.appName.formatForDB»_icalText }}{% endif %}
        «IF geographical»
            {% if «objName».latitude and «objName».longitude %}GEO:{{ «objName».longitude }};{{ «objName».latitude }}
            {% endif %}
        «ENDIF»
        TRANSP:OPAQUE
        SEQUENCE:0
        UID:{{ 'ICAL' ~ «objName».«primaryKey.name.formatForCode» ~ «objName».«getStartDateField.name.formatForCode»|date('Ymd\THi00\Z') ~ «objName».«getEndDateField.name.formatForCode»|date('Ymd\THi00\Z') }}
        DTSTAMP:{{ 'now'|date('Ymd\THi00\Z') }}
        «IF standardFields»
            ORGANIZER;CN="{{ «objName».createdBy.getUname() }}":MAILTO:{{ «objName».createdBy.getEmail() }}
        «ENDIF»
        SUMMARY{{ «objName»|«application.appName.formatForDB»_formattedTitle|«application.appName.formatForDB»_icalText }}
        «IF hasTextFieldsEntity»
            «val field = getTextFieldsEntity.head»
            {% if «objName».«field.name.formatForCode» is not empty %}DESCRIPTION{{ «objName».«field.name.formatForCode»|«application.appName.formatForDB»_icalText }}{% endif %}
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
