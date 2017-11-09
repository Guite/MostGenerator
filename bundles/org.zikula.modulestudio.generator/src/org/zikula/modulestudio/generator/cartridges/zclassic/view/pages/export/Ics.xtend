package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.UrlField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Ics {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        if (!hasDisplayAction) {
            return
        }
        println('Generating ics view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = templateFileWithExtension('display', 'ics')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, icsDisplay(appName))
        }
        if (application.generateSeparateAdminTemplates) {
            templateFilePath = templateFileWithExtension('Admin/display', 'ics')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, icsDisplay(appName))
            }
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
            ORGANIZER;CN="{{ «objName».createdBy.getUname() }}":MAILTO:{{ «objName».createdBy.getEmail() }}
        «ENDIF»
        «IF categorisable»
            CATEGORIES:{% for propName, catMapping in «objName».categories %}{% if not loop.first %},{% endif %}{{ catMapping.category.display_name[lang]|upper %}{% endfor %}
        «ENDIF»
        SUMMARY{{ «objName»|«application.appName.formatForDB»_formattedTitle|«appName.formatForDB»_icalText }}
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
