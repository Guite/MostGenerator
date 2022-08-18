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
        fsa.generateFile(templateFilePath, customView(it, entity))
    }

    def private customView(CustomAction it, Entity controller) '''
        {# purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» area #}
        {% extends routeArea == 'admin' ? '@«app.appName»/adminBase.html.twig' : '@«app.appName»/base.html.twig' %}
        {% trans_default_domain '«controller.name.formatForCode»' %}
        {% block title '«name.formatForDisplayCapital»'|trans %}
        {% block admin_page_icon 'square' %}
        {% block content %}
            <div class="«app.appName.toLowerCase»-«controller.name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                <p class="alert alert-info">Please override this template by moving it from <em>/«app.relativeAppRootPath»/«app.getViewPath»«relativeTemplatePath(controller)»</em> to either <em>/themes/YourTheme/Resources/«app.vendor.formatForCodeCapital»/«app.name.formatForCodeCapital»Module/views/«relativeTemplatePath(controller)»</em> or <em>/templates/bundles/«app.appName»/«relativeTemplatePath(controller)»</em>.</p>
            </div>
        {% endblock %}
    '''

    def private relativeTemplatePath(CustomAction it, Entity controller) '''«entity.name.formatForCodeCapital»/«name.formatForCode.toFirstLower».html.twig'''
}
