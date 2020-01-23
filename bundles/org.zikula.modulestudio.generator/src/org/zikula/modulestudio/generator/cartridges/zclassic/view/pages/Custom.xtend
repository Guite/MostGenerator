package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Custom {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app

    def generate(CustomAction it, Application app, Entity entity, IMostFileSystemAccess fsa) {
        ('Generating ' + entity.name.formatForDisplay + ' templates for custom action "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        this.app = app

        var templateFilePath = templateFile(entity, name.formatForCode)
        fsa.generateFile(templateFilePath, customView(it, entity, false))

        if (app.separateAdminTemplates) {
            templateFilePath = templateFile(entity, 'Admin/' + name.formatForCode)
            fsa.generateFile(templateFilePath, customView(it, entity, true))
        }
    }

    def private customView(CustomAction it, Entity controller, Boolean isAdmin) '''
        «IF app.separateAdminTemplates»
            {# purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» area #}
            «IF app.targets('3.0')»
                {% extends «IF isAdmin»'@«app.appName»/adminBase.html.twig'«ELSE»'@«app.appName»/base.html.twig'«ENDIF» %}
            «ELSE»
                {% extends «IF isAdmin»'«app.appName»::adminBase.html.twig'«ELSE»'«app.appName»::base.html.twig'«ENDIF» %}
            «ENDIF»
        «ELSE»
            {# purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» area #}
            «IF app.targets('3.0')»
                {% extends routeArea == 'admin' ? '@«app.appName»/adminBase.html.twig' : '@«app.appName»/base.html.twig' %}
            «ELSE»
                {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
            «ENDIF»
        «ENDIF»
        «IF app.targets('3.0') && !app.isSystemModule»
            {% trans_default_domain '«controller.name.formatForCode»' %}
        «ENDIF»
        {% block title «IF app.targets('3.0')»'«name.formatForDisplayCapital»'|trans«ELSE»__('«name.formatForDisplayCapital»')«ENDIF» %}
        «IF !app.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'square' %}
        «ENDIF»
        {% block content %}
            <div class="«app.appName.toLowerCase»-«controller.name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                <p class="alert alert-info">Please override this template by moving it from <em>/«app.relativeAppRootPath»/«app.getViewPath»«relativeTemplatePath(controller, isAdmin)»</em> to either <em>/themes/YourTheme/Resources/«app.appName»/views/«relativeTemplatePath(controller, isAdmin)»</em> or <em>/app/Resources/«app.appName»/views/«relativeTemplatePath(controller, isAdmin)»</em>.</p>
            </div>
        {% endblock %}
    '''

    def private relativeTemplatePath(CustomAction it, Entity controller, Boolean isAdmin) '''«entity.name.formatForCodeCapital»/«IF app.separateAdminTemplates && isAdmin»Admin/«ENDIF»«name.formatForCode.toFirstLower».html.twig'''
}
