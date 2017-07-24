package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockModerationView {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Block/'
        var fileName = 'moderation.html.twig'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'moderation.generated.html.twig'
            }
            fsa.generateFile(templatePath + fileName, displayTemplate)
        }
    }

    def private displayTemplate(Application it) '''
        {# Purpose of this template: show moderation block #}
        {% if moderationObjects|length > 0 %}
            <ul>
            {% for modItem in moderationObjects %}
                {% set itemObjectType = modItem.objectType|lower %}
                <li><a href="{{ path('«appName.formatForDB»_' ~ itemObjectType ~ '_adminview', {workflowState: modItem.state}) }}" class="bold">{{ modItem.message }}</a></li>
            {% endfor %}
            </ul>
        {% endif %}
    '''
}
