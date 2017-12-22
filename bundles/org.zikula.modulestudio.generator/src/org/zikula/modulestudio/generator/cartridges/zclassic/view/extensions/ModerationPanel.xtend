package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class ModerationPanel {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate (Application it, IMostFileSystemAccess fsa) {
        if (!(generateModerationPanel && needsApproval)) {
            return
        }
        val templatePath = getViewPath + 'Helper/'
        val fileName = 'includeModerationPanel.html.twig'
        fsa.generateFile(templatePath + fileName, moderationPanelImpl)
    }

    def private moderationPanelImpl(Application it) '''
        {# purpose of this template: show amount of pending items to moderators #}
        {% if not app.request.query.getBoolean('raw', false) %}
            {% set moderationObjects = «appName.formatForDB»_moderationObjects() %}
            {% if moderationObjects|length > 0 %}
                {% for modItem in moderationObjects %}
                    <p class="alert alert-info alert-dismissable text-center">
                        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                        {% set itemObjectType = modItem.objectType|lower %}
                        <a href="{{ path('«appName.formatForDB»_' ~ itemObjectType ~ '_adminview', {workflowState: modItem.state}) }}" class="bold alert-link">{{ modItem.message }}</a>
                    </p>
                {% endfor %}
            {% endif %}
        {% endif %}
    '''
}
