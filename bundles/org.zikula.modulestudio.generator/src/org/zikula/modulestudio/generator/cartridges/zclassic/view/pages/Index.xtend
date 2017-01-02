package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Index {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app

    def generate(Entity it, IFileSystemAccess fsa) {
        /*if (hasActions('view')) {
            return
        }*/
        app = application
        val pageName = 'index'
        val templateExtension = '.html.twig'
        val app = application
        val templatePath = app.getViewPath + name.formatForCodeCapital + '/'
        var fileName = pageName + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            println('Generating ' + pageName + ' templates for entity "' + name.formatForDisplay + '"')
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = pageName + '.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, indexView(pageName))
        }
    }

    def private indexView(Entity it, String pageName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» «pageName» view #}
        {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
        {% block title __('«nameMultiple.formatForDisplay»') %}
        {% block admin_page_icon 'home' %}
        {% block content %}
            <p>{{ __('Welcome to the «name.formatForDisplay» section of the «app.name.formatForDisplayCapital» application.') }}</p>
        {% endblock %}
    '''
}
