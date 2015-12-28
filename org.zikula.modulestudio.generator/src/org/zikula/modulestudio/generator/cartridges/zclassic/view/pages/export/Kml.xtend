package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Kml {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating kml view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = ''
        if (hasActions('view')) {
            templateFilePath = templateFileWithExtension('view', 'kml')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, if (application.targets('1.3.x')) kmlViewLegacy(appName) else kmlView(appName))
            }
        }
        if (hasActions('display')) {
            templateFilePath = templateFileWithExtension('display', 'kml')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, if (application.targets('1.3.x')) kmlDisplayLegacy(appName) else kmlDisplay(appName))
            }
        }
    }

    def private kmlViewLegacy(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» view kml view *}
        {«appName.formatForDB»TemplateHeaders contentType='application/vnd.google-earth.kml+xml'}<?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
        {foreach item='«objName»' from=$items}
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{$«objName»->get«stringFields.head.name.formatForCodeCapital»()}«ELSE»{gt text='«name.formatForDisplayCapital»'}«ENDIF»</name>
                <Point>
                    <coordinates>{$«objName»->getLongitude()}, {$«objName»->getLatitude()}, 0</coordinates>
                </Point>
            </Placemark>
        {/foreach}
        </Document>
        </kml>
    '''

    def private kmlView(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» view kml view #}
        {{ «appName.formatForDB»_templateHeaders(contentType='application/vnd.google-earth.kml+xml') }}<?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
        {% for «objName» in items %}
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{{ «objName».get«stringFields.head.name.formatForCodeCapital»() }}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»</name>
                <Point>
                    <coordinates>{{ «objName».getLongitude() }}, {{ «objName».getLatitude() }}, 0</coordinates>
                </Point>
            </Placemark>
        {% endfor %}
        </Document>
        </kml>
    '''

    def private kmlDisplayLegacy(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display kml view *}
        {«appName.formatForDB»TemplateHeaders contentType='application/vnd.google-earth.kml+xml'}<?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{$«objName»->get«stringFields.head.name.formatForCodeCapital»()}«ELSE»{gt text='«name.formatForDisplayCapital»'}«ENDIF»</name>
                <Point>
                    <coordinates>{$«objName»->getLongitude()}, {$«objName»->getLatitude()}, 0</coordinates>
                </Point>
            </Placemark>
        </Document>
        </kml>
    '''

    def private kmlDisplay(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display kml view *}
        {{ «appName.formatForDB»_templateHeaders(contentType='application/vnd.google-earth.kml+xml') }}<?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{{ «objName»->get«stringFields.head.name.formatForCodeCapital»() }}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»</name>
                <Point>
                    <coordinates>{{ «objName»->getLongitude() }}, {{ «objName»->getLatitude() }}, 0</coordinates>
                </Point>
            </Placemark>
        </Document>
        </kml>
    '''
}
