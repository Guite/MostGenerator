package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Index {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, IFileSystemAccess fsa) {
        /*if (hasActions('view')) {
            return
        }*/
        ('Generating index templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        var templateFilePath = templateFile('index')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, indexView(false))
        }
        if (application.generateSeparateAdminTemplates) {
            templateFilePath = templateFile('Admin/index')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, indexView(true))
            }
        }
    }

    def private indexView(Entity it, Boolean isAdmin) '''
        «IF application.generateSeparateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» index view #}
            {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» index view #}
            {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
        «ENDIF»
        {% block title __('«nameMultiple.formatForDisplay»') %}
        «IF !application.generateSeparateAdminTemplates || isAdmin»
            {% block admin_page_icon 'home' %}
        «ENDIF»
        {% block content %}
            <p>{{ __('Welcome to the «name.formatForDisplay» section of the «application.name.formatForDisplayCapital» application.') }}</p>
        {% endblock %}
    '''
}
