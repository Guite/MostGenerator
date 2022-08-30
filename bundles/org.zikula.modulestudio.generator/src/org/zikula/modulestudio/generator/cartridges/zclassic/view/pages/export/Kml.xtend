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
        if (!(hasIndexAction || hasDetailAction)) {
            return
        }
        ('Generating KML view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        var templateFilePath = ''
        if (hasIndexAction) {
            templateFilePath = templateFileWithExtension('index', 'kml')
            fsa.generateFile(templateFilePath, kmlIndex)
        }
        if (hasDetailAction) {
            templateFilePath = templateFileWithExtension('detail', 'kml')
            fsa.generateFile(templateFilePath, kmlDetail)
        }
    }

    def private kmlIndex(Entity it) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» index kml view #}
        {% trans_default_domain '«name.formatForCode»' %}
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
        {% for «objName» in items %}
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{{ «objName».get«stringFields.head.name.formatForCodeCapital»() }}«ELSE»{% trans %}«name.formatForDisplayCapital»{% endtrans %}«ENDIF»</name>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty && textFields.head != stringFields.head»
                    <description><![CDATA[{{ «objName».get«textFields.head.name.formatForCodeCapital»() }}«IF hasDetailAction»<br /><a href="{{ url('«application.appName.toLowerCase»_«name.formatForCode.toLowerCase»_detail'«routeParams(name.formatForCode, true)») }}">{% trans %}Details{% endtrans %}</a>«ENDIF»]]></description>
                «ENDIF»
                <Point>
                    <coordinates>{{ «objName».getLongitude() }}, {{ «objName».getLatitude() }}, 0</coordinates>
                </Point>
            </Placemark>
        {% endfor %}
        </Document>
        </kml>
    '''

    def private kmlDetail(Entity it) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» detail kml view #}
        {% trans_default_domain '«name.formatForCode»' %}
        <?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{{ «objName».get«stringFields.head.name.formatForCodeCapital»() }}«ELSE»{% trans %}«name.formatForDisplayCapital»{% endtrans %}«ENDIF»</name>
                «val textFields = fields.filter(TextField)»
                «IF !textFields.empty && textFields.head != stringFields.head»
                    <description><![CDATA[{{ «objName».get«textFields.head.name.formatForCodeCapital»() }}«IF hasDetailAction»<br /><a href="{{ url('«application.appName.toLowerCase»_«name.formatForCode.toLowerCase»_detail'«routeParams(name.formatForCode, true)») }}">{% trans %}Details{% endtrans %}</a>«ENDIF»]]></description>
                «ENDIF»
                <Point>
                    <coordinates>{{ «objName».getLongitude() }}, {{ «objName».getLatitude() }}, 0</coordinates>
                </Point>
            </Placemark>
        </Document>
        </kml>
    '''
}
