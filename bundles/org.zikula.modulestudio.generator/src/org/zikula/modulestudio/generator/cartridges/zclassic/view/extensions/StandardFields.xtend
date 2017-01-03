package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class StandardFields {
    extension ControllerExtensions = new ControllerExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate (Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Helper/'
        val templateExtension = '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeStandardFieldsDisplay' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeStandardFieldsDisplay.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, standardFieldsViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'includeStandardFieldsEdit' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeStandardFieldsEdit.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, standardFieldsEditImpl)
            }
        }
    }

    def private standardFieldsViewImpl(Application it) '''
        {# purpose of this template: reusable display of standard fields #}
        {% if obj.createdBy|default or obj.updatedBy|default %}
            {% if panel|default(false) == true %}
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseStandardFields">{{ __('Creation and update') }}</a></h3>
                    </div>
                    <div id="collapseStandardFields" class="panel-collapse collapse in">
                        <div class="panel-body">
            {% else %}
                <h3 class="standard-fields">{{ __('Creation and update') }}</h3>
            {% endif %}
            «viewBody»
            {% if panel|default(false) == true %}
                        </div>
                    </div>
                </div>
            {% endif %}
        {% endif %}
    '''

    def private viewBody(Application it) '''
        <dl class="propertylist">
        {% if obj.createdBy|default %}
            <dt>{{ __('Creation') }}</dt>
            {% set profileLink = obj.createdBy.getUid()|profileLinkByUserId() %}
            <dd class="avatar">{{ «appName.toLowerCase»_userAvatar(uid=obj.createdBy.getUid(), rating='g') }}</dd>
            <dd>{{ __f('Created by %user on %date', {'%user': profileLink, '%date': obj.createdDate|localizeddate('medium', 'short')})|raw }}</dd>
        {% endif %}
        {% if obj.updatedBy|default %}
            <dt>{{ __('Last update') }}</dt>
            {% set profileLink = obj.updatedBy.getUid()|profileLinkByUserId() %}
            <dd class="avatar">{{ «appName.toLowerCase»_userAvatar(uid=obj.updatedBy.getUid(), rating='g') }}</dd>
            <dd>{{ __f('Updated by %user on %date', {'%user': profileLink, '%date': obj.updatedDate|localizeddate('medium', 'short')})|raw }}</dd>
        {% endif %}
        </dl>
    '''

    def private standardFieldsEditImpl(Application it) '''
        {# purpose of this template: reusable editing of standard fields #}
        {% if obj.createdBy|default or obj.updatedBy|default %}
            {% if panel|default(false) == true %}
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseStandardFields">{{ __('Creation and update') }}</a></h3>
                    </div>
                    <div id="collapseStandardFields" class="panel-collapse collapse in">
                        <div class="panel-body">
            {% else %}
                <fieldset class="standardfields">
            {% endif %}
                <legend>{{ __('Creation and update') }}</legend>
                «editBody»
            {% if panel|default(false) == true %}
                        </div>
                    </div>
                </div>
            {% else %}
                </fieldset>
            {% endif %}
        {% endif %}
    '''

    def private editBody(Application it) '''
        <ul>
        {% if obj.createdBy|default %}
            <li>{{ __f('Created by %user', {'%user': obj.createdBy.getUname()}) }}</li>
            <li>{{ __f('Created on %date', {'%date': obj.createdDate|localizeddate('medium', 'short')}) }}</li>
        {% endif %}
        {% if obj.updatedBy|default %}
            <li>{{ __f('Updated by %user', {'%user': obj.updatedBy.getUname()}) }}</li>
            <li>{{ __f('Updated on %date', {'%date': obj.updatedDate|localizeddate('medium', 'short')}) }}</li>
        {% endif %}
        </ul>
    '''
}
