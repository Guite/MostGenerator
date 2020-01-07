package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Kml {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Entity it, IMostFileSystemAccess fsa) {
        if (!(hasViewAction || hasDisplayAction)) {
            return
        }
        ('Generating KML view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        var templateFilePath = ''
        if (hasViewAction) {
            templateFilePath = templateFileWithExtension('view', 'kml')
            fsa.generateFile(templateFilePath, kmlView)

            if (application.separateAdminTemplates) {
                templateFilePath = templateFileWithExtension('Admin/view', 'kml')
                fsa.generateFile(templateFilePath, kmlView)
            }
        }
        if (hasDisplayAction) {
            templateFilePath = templateFileWithExtension('display', 'kml')
            fsa.generateFile(templateFilePath, kmlDisplay)

            if (application.separateAdminTemplates) {
                templateFilePath = templateFileWithExtension('Admin/display', 'kml')
                fsa.generateFile(templateFilePath, kmlDisplay)
            }
        }
    }

    def private kmlView(Entity it) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» view kml view #}
        «IF !application.isSystemModule && application.targets('3.0')»
            {% trans_default_domain '«application.appName.formatForDB»' %}
        «ENDIF»
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
        {% for «objName» in items %}
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{{ «objName».get«stringFields.head.name.formatForCodeCapital»() }}«ELSE»«IF application.targets('3.0')»{% trans %}«name.formatForDisplayCapital»{% endtrans %}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»«ENDIF»</name>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty && textFields.head != stringFields.head»
                    <description><![CDATA[{{ «objName».get«textFields.head.name.formatForCodeCapital»() }}«IF hasDisplayAction»<br /><a href="{{ url('«application.appName.toLowerCase»_«name.formatForCode.toLowerCase»_display'«routeParams(name.formatForCode, true)») }}">«IF application.targets('3.0')»{% trans %}Details{% endtrans %}«ELSE»{{ __('Details') }}«ENDIF»</a>«ENDIF»]]></description>
                «ENDIF»
                <Point>
                    <coordinates>{{ «objName».getLongitude() }}, {{ «objName».getLatitude() }}, 0</coordinates>
                </Point>
            </Placemark>
        {% endfor %}
        </Document>
        </kml>
    '''

    def private kmlDisplay(Entity it) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» display kml view #}
        «IF !application.isSystemModule && application.targets('3.0')»
            {% trans_default_domain '«application.appName.formatForDB»' %}
        «ENDIF»
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{{ «objName».get«stringFields.head.name.formatForCodeCapital»() }}«ELSE»«IF application.targets('3.0')»{% trans %}«name.formatForDisplayCapital»{% endtrans %}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»«ENDIF»</name>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty && textFields.head != stringFields.head»
                    <description><![CDATA[{{ «objName».get«textFields.head.name.formatForCodeCapital»() }}«IF hasDisplayAction»<br /><a href="{{ url('«application.appName.toLowerCase»_«name.formatForCode.toLowerCase»_display'«routeParams(name.formatForCode, true)») }}">«IF application.targets('3.0')»{% trans %}Details{% endtrans %}«ELSE»{{ __('Details') }}«ENDIF»</a>«ENDIF»]]></description>
                «ENDIF»
                <Point>
                    <coordinates>{{ «objName».getLongitude() }}, {{ «objName».getLatitude() }}, 0</coordinates>
                </Point>
            </Placemark>
        </Document>
        </kml>
    '''
}
