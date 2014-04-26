package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Kml {

    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating kml view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = ''
        if (hasActions('view')) {
            templateFilePath = templateFileWithExtension('view', 'kml')
            if (!container.application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, kmlView(appName))
            }
        }
        if (hasActions('display')) {
            templateFilePath = templateFileWithExtension('display', 'kml')
            if (!container.application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, kmlDisplay(appName))
            }
        }
    }

    def private kmlView(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view kml view *}
        «IF container.application.targets('1.3.5')»{«appName.formatForDB»TemplateHeaders contentType='application/vnd.google-earth.kml+xml'}«ENDIF»<?xml version="1.0" encoding="UTF-8"?>
        <kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2">
        <Document>
        {foreach item='item' from=$items}
            <Placemark>
                «val stringFields = fields.filter(StringField) + fields.filter(TextField)»
                <name>«IF !stringFields.empty»{$item->get«stringFields.head.name.formatForCodeCapital»()}«ELSE»{gt text='«name.formatForDisplayCapital»'}«ENDIF»</name>
                <Point>
                    <coordinates>{$item->getLongitude()}, {$item->getLatitude()}, 0</coordinates>
                </Point>
            </Placemark>
        {/foreach}
        </Document>
        </kml>
    '''

    def private kmlDisplay(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display kml view *}
        «IF container.application.targets('1.3.5')»{«appName.formatForDB»TemplateHeaders contentType='application/vnd.google-earth.kml+xml'}«ENDIF»<?xml version="1.0" encoding="UTF-8"?>
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
}
