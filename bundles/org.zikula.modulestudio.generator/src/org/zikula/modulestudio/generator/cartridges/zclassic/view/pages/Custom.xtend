package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Custom {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def dispatch generate(Action it, Application app, Controller controller, IFileSystemAccess fsa) {
    }

    def dispatch generate(CustomAction it, Application app, Controller controller, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + controller.formattedName.toFirstUpper + '/'
        val templateExtension = '.html.twig'
        var fileName = name.formatForCode.toFirstLower + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            println('Generating ' + controller.formattedName + ' templates for custom action "' + name.formatForDisplay + '"')
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = name.formatForCode.toFirstLower + '.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, customView(it, app, controller))
        }
        ''' '''
    }

    def dispatch generate(CustomAction it, Application app, Entity entity, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + entity.name.formatForDisplayCapital + '/'
        val templateExtension = '.html.twig'
        var fileName = name.formatForCode.toFirstLower + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            println('Generating ' + entity.name.formatForDisplay + ' templates for custom action "' + name.formatForDisplay + '"')
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = name.formatForCode.toFirstLower + '.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, customView(it, app, entity))
        }
        ''' '''
    }

    def private dispatch customView(CustomAction it, Application app, Controller controller) '''
        {# purpose of this template: show output of «name.formatForDisplay» action in «controller.formattedName» area #}
        {% extends '«app.appName»::«IF controller instanceof AdminController»adminBase«ELSE»base«ENDIF».html.twig' %}
        {% block title __('«name.formatForDisplayCapital»') %}
        «IF controller instanceof AdminController»
            {% block admin_page_icon 'square' %}
        «ENDIF»
        {% block content %}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                <p>Please override this template by moving it from <em>/«app.rootFolder»/«if (app.systemModule) app.name.formatForCodeCapital else app.vendor.formatForCodeCapital + '/' + app.name.formatForCodeCapital»Module/«app.getViewPath»«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».html.twig</em> to either <em>/themes/YourTheme/Resources/«app.appName»/views/«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».html.twig</em> or <em>/app/Resources/«app.appName»/views/«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».html.twig</em>.</p>
            </div>
        {% endblock %}
    '''

    def private dispatch customView(CustomAction it, Application app, Entity controller) '''
        {# purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» area #}
        {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        {% block title %}
            {{ __('«name.formatForDisplayCapital»') }}
        {% endblock %}
        {% block adminPageIcon %}square{% endblock %}
        {% block content %}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                <p>Please override this template by moving it from <em>/«app.rootFolder»/«if (app.systemModule) app.name.formatForCodeCapital else app.vendor.formatForCodeCapital + '/' + app.name.formatForCodeCapital»Module/«app.getViewPath»«entity.name.formatForDisplayCapital»/«name.formatForCode.toFirstLower».html.twig</em> to either <em>/themes/YourTheme/Resources/«app.appName»/views/«entity.name.formatForDisplayCapital»/«name.formatForCode.toFirstLower».html.twig</em> or <em>/app/Resources/«app.appName»/views/«entity.name.formatForDisplayCapital»/«name.formatForCode.toFirstLower».html.twig</em>.</p>
            </div>
        {% endblock %}
    '''
}
