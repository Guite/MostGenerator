package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Json {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        if (!(hasViewAction || hasDisplayAction)) {
            return
        }
        ('Generating JSON view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        var templateFilePath = ''
        if (hasViewAction) {
            templateFilePath = templateFileWithExtension('view', 'json')
            fsa.generateFile(templateFilePath, jsonView(appName))

            if (application.separateAdminTemplates) {
                templateFilePath = templateFileWithExtension('Admin/view', 'json')
                fsa.generateFile(templateFilePath, jsonView(appName))
            }
        }
        if (hasDisplayAction) {
            templateFilePath = templateFileWithExtension('display', 'json')
            fsa.generateFile(templateFilePath, jsonDisplay(appName))

            if (application.separateAdminTemplates) {
                templateFilePath = templateFileWithExtension('Admin/display', 'json')
                fsa.generateFile(templateFilePath, jsonDisplay(appName))
            }
        }
    }

    def private jsonView(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» view json view #}
        [
        {% for «objName» in items %}
            {% if not loop.first %},{% endif %}
            {{ «objName».toArray()|json_encode()|raw }}
        {% endfor %}
        ]
    '''

    def private jsonDisplay(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {# purpose of this template: «nameMultiple.formatForDisplay» display json view #}
        {{ «objName».toArray()|json_encode()|raw }}
    '''
}
