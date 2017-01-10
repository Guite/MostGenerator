package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Custom {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(CustomAction it, Application app, Entity entity, IFileSystemAccess fsa) {
        var templateFilePath = templateFile(entity, name.formatForCode)
        if (!app.shouldBeSkipped(templateFilePath)) {
            println('Generating ' + entity.name.formatForDisplay + ' templates for custom action "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, customView(it, app, entity))
        }
        ''' '''
    }

    def private customView(CustomAction it, Application app, Entity controller) '''
        {# purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» area #}
        {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        {% block title %}
            {{ __('«name.formatForDisplayCapital»') }}
        {% endblock %}
        {% block adminPageIcon %}square{% endblock %}
        {% block content %}
            <div class="«app.appName.toLowerCase»-«controller.name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                <p>Please override this template by moving it from <em>/«app.relativeAppRootPath»/«app.getViewPath»«entity.name.formatForCodeCapital»/«name.formatForCode.toFirstLower».html.twig</em> to either <em>/themes/YourTheme/Resources/«app.appName»/views/«entity.name.formatForCodeCapital»/«name.formatForCode.toFirstLower».html.twig</em> or <em>/app/Resources/«app.appName»/views/«entity.name.formatForCodeCapital»/«name.formatForCode.toFirstLower».html.twig</em>.</p>
            </div>
        {% endblock %}
    '''
}
