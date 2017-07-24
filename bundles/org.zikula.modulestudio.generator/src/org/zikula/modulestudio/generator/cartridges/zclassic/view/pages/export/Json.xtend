package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Json {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        if (!(hasViewAction || hasDisplayAction)) {
            return
        }
        println('Generating json view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = ''
        if (hasViewAction) {
            templateFilePath = templateFileWithExtension('view', 'json')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, jsonView(appName))
            }
            if (application.generateSeparateAdminTemplates) {
                templateFilePath = templateFileWithExtension('Admin/view', 'json')
                if (!application.shouldBeSkipped(templateFilePath)) {
                    fsa.generateFile(templateFilePath, jsonView(appName))
                }
            }
        }
        if (hasDisplayAction) {
            templateFilePath = templateFileWithExtension('display', 'json')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, jsonDisplay(appName))
            }
            if (application.generateSeparateAdminTemplates) {
                templateFilePath = templateFileWithExtension('Admin/display', 'json')
                if (!application.shouldBeSkipped(templateFilePath)) {
                    fsa.generateFile(templateFilePath, jsonDisplay(appName))
                }
            }
        }
    }

    def private jsonView(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» view json view #}
        [
        {% for «objName» in items %}
            {% if not loop.first %},{% endif %}
            {{ «objName».toArray()|json_encode() }}
        {% endfor %}
        ]
    '''

    def private jsonDisplay(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» display json view #}
        {{ «objName».toArray()|json_encode() }}
    '''
}
