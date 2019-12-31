package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ViewPagesHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def commonHeader(Entity it) '''
        «IF null !== documentation && !documentation.empty»
            «IF !documentation.containedTwigVariables.empty»
                <p class="alert alert-info">{{ __f('«documentation.replace('\'', '\\\'').replaceTwigVariablesForTranslation»', {«documentation.containedTwigVariables.map[v|'\'%' + v + '%\': ' + v + '|default'].join(', ')»}) }}</p>
            «ELSE»
                <p class="alert alert-info">{{ __('«documentation.replace('\'', '\\\'')»') }}</p>
            «ENDIF»

        «ENDIF»
        «new MenuViews().viewActions(it)»

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