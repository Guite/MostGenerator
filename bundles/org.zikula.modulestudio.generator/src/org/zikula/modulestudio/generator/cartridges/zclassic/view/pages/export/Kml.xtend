package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions

class Kml {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating kml view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = ''
        if (hasActions('view')) {
            templateFilePath = templateFileWithExtension('view', 'kml')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, kmlView(appName))
            }
        }
        if (hasActions('display')) {
            templateFilePath = templateFileWithExtension('display', 'kml')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, kmlDisplay(appName))
            }
        }
    }

    def private kmlView(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» view kml view #}
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
        {% for «objName» in items %}
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{{ «objName».get«stringFields.head.name.formatForCodeCapital»() }}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»</name>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty && textFields.head != stringFields.head»
                    <description><![CDATA[{{ «objName».get«textFields.head.name.formatForCodeCapital»() }}«IF hasActions('display')»<br /><a href="{{ url('«appName.toLowerCase»_«name.formatForCode.toLowerCase»_display'«routeParams(name.formatForCode, true)») }}">{{ __('Details') }}</a>«ENDIF»]]></description>
                «ENDIF»
                <Point>
                    <coordinates>{{ «objName».getLongitude() }}, {{ «objName».getLatitude() }}, 0</coordinates>
                </Point>
            </Placemark>
        {% endfor %}
        </Document>
        </kml>
    '''

    def private kmlDisplay(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» display kml view #}
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{{ «objName».get«stringFields.head.name.formatForCodeCapital»() }}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»</name>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty && textFields.head != stringFields.head»
                    <description><![CDATA[{{ «objName».get«textFields.head.name.formatForCodeCapital»() }}«IF hasActions('display')»<br /><a href="{{ url('«appName.toLowerCase»_«name.formatForCode.toLowerCase»_display'«routeParams(name.formatForCode, true)») }}">{{ __('Details') }}</a>«ENDIF»]]></description>
                «ENDIF»
                <Point>
                    <coordinates>{{ «objName».getLongitude() }}, {{ «objName».getLatitude() }}, 0</coordinates>
                </Point>
            </Placemark>
        </Document>
        </kml>
    '''
}
