package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Index {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, IMostFileSystemAccess fsa) {
        /*if (hasActions('view')) {
            return
        }*/
        ('Generating index templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFile('index')
        fsa.generateFile(templateFilePath, indexView(false))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFile('Admin/index')
            fsa.generateFile(templateFilePath, indexView(true))
        }
    }

    def private indexView(Entity it, Boolean isAdmin) '''
        «IF application.separateAdminTemplates»
            {# purpose of this template: «nameMultiple.formatForDisplay» «IF isAdmin»admin«ELSE»user«ENDIF» index view #}
            «IF application.targets('3.0')»
                {% extends «IF isAdmin»'@«application.appName»/adminBase.html.twig'«ELSE»'@«application.appName»/base.html.twig'«ENDIF» %}
            «ELSE»
                {% extends «IF isAdmin»'«application.appName»::adminBase.html.twig'«ELSE»'«application.appName»::base.html.twig'«ENDIF» %}
            «ENDIF»
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» index view #}
            «IF application.targets('3.0')»
                {% extends routeArea == 'admin' ? '@«application.appName»/adminBase.html.twig' : '@«application.appName»/base.html.twig' %}
            «ELSE»
                {% extends routeArea == 'admin' ? '«application.appName»::adminBase.html.twig' : '«application.appName»::base.html.twig' %}
            «ENDIF»
        «ENDIF»
        {% block title «IF application.targets('3.0')»'«nameMultiple.formatForDisplayCapital»'|trans«ELSE»__('«nameMultiple.formatForDisplayCapital»')«ENDIF» %}
        «IF !application.separateAdminTemplates || isAdmin»
            {% block admin_page_icon 'home' %}
        «ENDIF»
        {% block content %}
            <div class="«application.appName.toLowerCase»-«name.formatForDB» «application.appName.toLowerCase»-index">
                «IF application.targets('3.0')»
                    <p>{% trans %}Welcome to the «name.formatForDisplay» section of the «application.name.formatForDisplayCapital» application.{% endtrans %}</p>
                «ELSE»
                    <p>{{ __('Welcome to the «name.formatForDisplay» section of the «application.name.formatForDisplayCapital» application.') }}</p>
                «ENDIF»
            </div>
        {% endblock %}
    '''
}
