package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.NamedObject
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class IndexPagesHelper {

    extension FormattingExtensions = new FormattingExtensions

    def commonHeader(Entity it) '''
        «docsWithVariables(application)»
        «new MenuViews().viewActions(it)»

    '''

    def docsWithVariables(NamedObject it, Application app) '''
        «IF null !== documentation && !documentation.replaceAll('\\s+', '').empty»
            «IF !documentation.containedTwigVariables.empty»
                <p class="alert alert-info">{% trans with {«documentation.containedTwigVariables.map[v|'\'%' + v + '%\': ' + v + '|default'].join(', ')»} from '«IF it instanceof Variables»config«ELSEIF it instanceof DataObject»«name.formatForCode»«ELSE»messages«ENDIF»' %}«documentation.replace('\'', '\\\'').replaceTwigVariablesForTranslation»{% endtrans %}</p>
            «ELSE»
                <p class="alert alert-info">{% trans from '«IF it instanceof Variables»config«ELSEIF it instanceof DataObject»«name.formatForCode»«ELSE»messages«ENDIF»' %}«documentation.replace('\'', '\\\'')»{% endtrans %}</p>
            «ENDIF»

        «ENDIF»
    '''

    def pagerCall(Entity it) '''

        {% if all != 1 %}
            {{ include(paginator.template) }}
        {% endif %}
    '''
}