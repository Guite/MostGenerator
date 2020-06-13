package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewPagesHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def commonHeader(Entity it) '''
        «docsWithVariables(application)»
        «new MenuViews().viewActions(it)»

    '''

    def docsWithVariables(NamedObject it, Application app) '''
        «IF null !== documentation && !documentation.replaceAll('\\s+', '').empty»
            «IF app.targets('3.0')»
                «IF !documentation.containedTwigVariables.empty»
                    <p class="alert alert-info">{% trans with {«documentation.containedTwigVariables.map[v|'\'%' + v + '%\': ' + v + '|default'].join(', ')»}«IF !app.isSystemModule» from '«IF it instanceof Variables»config«ELSEIF it instanceof DataObject»«name.formatForCode»«ELSE»messages«ENDIF»'«ENDIF» %}«documentation.replace('\'', '\\\'').replaceTwigVariablesForTranslation»{% endtrans %}</p>
                «ELSE»
                    <p class="alert alert-info">{% trans«IF !app.isSystemModule» from '«IF it instanceof Variables»config«ELSEIF it instanceof DataObject»«name.formatForCode»«ELSE»messages«ENDIF»'«ENDIF» %}«documentation.replace('\'', '\\\'')»{% endtrans %}</p>
                «ENDIF»
            «ELSE»
                «IF !documentation.containedTwigVariables.empty»
                    <p class="alert alert-info">{{ __f('«documentation.replace('\'', '\\\'').replaceTwigVariablesForTranslation»', {«documentation.containedTwigVariables.map[v|'\'%' + v + '%\': ' + v + '|default'].join(', ')»}) }}</p>
                «ELSE»
                    <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»') }}</p>
                «ENDIF»
            «ENDIF»

        «ENDIF»
    '''

    def pagerCall(Entity it) '''

        {% if all != 1«IF !application.targets('3.0')» and pager|default«ENDIF» %}
            «IF application.targets('3.0')»
                {{ include(paginator.template) }}
            «ELSE»
                {{ pager({rowcount: pager.amountOfItems, limit: pager.itemsPerPage, display: 'page', route: '«application.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'view'}) }}
            «ENDIF»
        {% endif %}
    '''

    def callDisplayHooks(Entity it) '''
        «IF !skipHookSubscribers»
            {% block display_hooks %}
                «displayHooksImpl»
            {% endblock %}
        «ENDIF»
    '''

    def private displayHooksImpl(Entity it) '''
        {# here you can activate calling display hooks for the view page if you need it #}
        {# % if routeArea != 'admin' %}
            {% set hooks = notifyDisplayHooks(eventName='«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view', urlObject=currentUrlObject, outputAsArray=true) %}
            {% if hooks is iterable and hooks|length > 0 %}
                {% for area, hook in hooks %}
                    <div class="z-displayhook" data-area="{{ area|e('html_attr') }}">{{ hook|raw }}</div>
                {% endfor %}
            {% endif %}
        {% endif % #}
    '''
}