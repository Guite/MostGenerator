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
        fsa.generateFile(templateFilePath, indexView)
    }

    def private indexView(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» index view #}
        {% extends routeArea == 'admin' ? '@«application.appName»/adminBase.html.twig' : '@«application.appName»/base.html.twig' %}
        «IF !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {% block title '«nameMultiple.formatForDisplayCapital»'|trans %}
        {% block admin_page_icon 'home' %}
        {% block content %}
            <div class="«application.appName.toLowerCase»-«name.formatForDB» «application.appName.toLowerCase»-index">
                <p>{% trans %}Welcome to the «name.formatForDisplay» section of the «application.name.formatForDisplayCapital» application.{% endtrans %}</p>
            </div>
        {% endblock %}
    '''
}
