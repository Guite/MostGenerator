package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Custom {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app

    def generate(CustomAction it, Application app, Entity entity, IFileSystemAccess fsa) {
        'Generating ' + entity.name.formatForDisplay + ' templates for custom action "' + name.formatForDisplay + '"'.printIfNotTesting(fsa)
        this.app = app
        var templateFilePath = templateFile(entity, name.formatForCode)
        if (!app.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, customView(it, entity, false))
        }
        if (app.generateSeparateAdminTemplates) {
            templateFilePath = templateFile(entity, 'Admin/' + name.formatForCode)
            if (!app.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, customView(it, entity, true))
            }
        }
    }

    def private customView(CustomAction it, Entity controller, Boolean isAdmin) '''
        «IF app.generateSeparateAdminTemplates»
            {# purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» area #}
            {% extends «IF isAdmin»'«app.appName»::adminBase.html.twig'«ELSE»'«app.appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» area #}
            {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        «ENDIF»
        {% block title __('«name.formatForDisplayCapital»') %}
        «IF !app.generateSeparateAdminTemplates || isAdmin»
            {% block admin_page_icon 'square' %}
        «ENDIF»
        {% block content %}
            <div class="«app.appName.toLowerCase»-«controller.name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                <p>Please override this template by moving it from <em>/«app.relativeAppRootPath»/«app.getViewPath»«relativeTemplatePath(controller, isAdmin)»</em> to either <em>/themes/YourTheme/Resources/«app.appName»/views/«relativeTemplatePath(controller, isAdmin)»</em> or <em>/app/Resources/«app.appName»/views/«relativeTemplatePath(controller, isAdmin)»</em>.</p>
            </div>
        {% endblock %}
    '''

    def private relativeTemplatePath(CustomAction it, Entity controller, Boolean isAdmin) '''«entity.name.formatForCodeCapital»/«IF app.generateSeparateAdminTemplates && isAdmin»Admin/«ENDIF»«name.formatForCode.toFirstLower».html.twig'''
}
