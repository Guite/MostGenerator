package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockModerationView {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Block/'
        val fileName = 'moderation.html.twig'
        fsa.generateFile(templatePath + fileName, displayTemplate)
    }

    def private displayTemplate(Application it) '''
        {# purpose of this template: show moderation block #}
        {% if moderationObjects|length > 0 %}
            <ul>
            {% for modItem in moderationObjects %}
                {% set itemObjectType = modItem.objectType|lower %}
                «IF hasViewActions»
                    {% if itemObjectType in ['«getAllEntities.filter[hasViewAction].map[name.formatForCode].join('\', \'')»'] %}
                        <li><a href="{{ path('«appName.formatForDB»_' ~ itemObjectType ~ '_adminview', {workflowState: modItem.state}) }}" class="font-weight-bold">{{ modItem.message }}</a></li>
                    {% elseif itemObjectType in ['«getAllEntities.filter[hasIndexAction].map[name.formatForCode].join('\', \'')»'] %}
                        <li><a href="{{ path('«appName.formatForDB»_' ~ itemObjectType ~ '_adminindex', {workflowState: modItem.state}) }}" class="font-weight-bold">{{ modItem.message }}</a></li>
                    {% else %}
                        <li><strong>{{ modItem.message }}</strong></li>
                    {% endif %}
                «ELSE»
                    {% if itemObjectType in ['«getAllEntities.filter[hasIndexAction].map[name.formatForCode].join('\', \'')»'] %}
                        <li><a href="{{ path('«appName.formatForDB»_' ~ itemObjectType ~ '_adminindex', {workflowState: modItem.state}) }}" class="font-weight-bold">{{ modItem.message }}</a></li>
                    {% else %}
                        <li><strong>{{ modItem.message }}</strong></li>
                    {% endif %}
                «ENDIF»
            {% endfor %}
            </ul>
        {% endif %}
    '''
}
