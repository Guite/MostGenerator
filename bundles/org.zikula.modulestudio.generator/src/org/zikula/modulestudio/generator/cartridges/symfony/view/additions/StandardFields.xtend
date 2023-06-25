package org.zikula.modulestudio.generator.cartridges.symfony.view.additions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.IntegerField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class StandardFields {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions

    def generate (Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Helper/'
        val templateExtension = '.html.twig'

        var fileName = ''
        if (hasIndexActions || hasDetailActions) {
            fileName = 'includeStandardFieldsDisplay' + templateExtension
            fsa.generateFile(templatePath + fileName, standardFieldsViewImpl)
        }
        if (hasEditActions) {
            fileName = 'includeStandardFieldsEdit' + templateExtension
            fsa.generateFile(templatePath + fileName, standardFieldsEditImpl)
        }
    }

    def private standardFieldsViewImpl(Application it) '''
        {# purpose of this template: reusable display of standard fields #}
        {% if (obj.createdBy|default and obj.createdBy.uid > 0) or (obj.updatedBy|default and obj.updatedBy.uid > 0) %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabStandardFields" aria-labelledby="standardFieldsTab">
                    <h3>{% trans %}Creation and update{% endtrans %}</h3>
            {% else %}
                <h3 class="standard-fields">{% trans %}Creation and update{% endtrans %}</h3>
            {% endif %}
            «viewBody»
            {% if tabs|default(false) == true %}
                </div>
            {% endif %}
        {% endif %}
    '''

    def private viewBody(Application it) '''
        <dl class="propertylist">
        {% if obj.createdBy|default and obj.createdBy.uid > 0 %}
            <dt>{% trans %}Creation{% endtrans %}</dt>
            {% set profileLink = obj.createdBy.uid|profileLinkByUserId %}
            <dd class="avatar">{{ userAvatar(obj.createdBy.uid, {rating: 'g'}) }}</dd>
            <dd>{{ 'Created by %user% on %date%'|trans({'%user%': profileLink, '%date%': obj.createdDate|format_datetime('medium', 'short')})|raw }}</dd>
        {% endif %}
        {% if obj.updatedBy|default and obj.updatedBy.uid > 0 %}
            <dt>{% trans %}Last update{% endtrans %}</dt>
            {% set profileLink = obj.updatedBy.uid|profileLinkByUserId %}
            <dd class="avatar">{{ userAvatar(obj.updatedBy.uid, {rating: 'g'}) }}</dd>
            <dd>{{ 'Last update by %user% on %date%'|trans({'%user%': profileLink, '%date%': obj.updatedDate|format_datetime('medium', 'short')})|raw }}</dd>
        {% endif %}
        </dl>
    '''

    def private standardFieldsEditImpl(Application it) '''
        {# purpose of this template: reusable editing of standard fields #}
        {% if (obj.createdBy|default and obj.createdBy.uid > 0) or (obj.updatedBy|default and obj.updatedBy.uid > 0) %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabStandardFields" aria-labelledby="standardFieldsTab">
                    <h3>{% trans %}Creation and update{% endtrans %}</h3>
            {% else %}
                <fieldset class="standardfields">
            {% endif %}
                <legend>{% trans %}Creation and update{% endtrans %}</legend>
                «editBody»
            {% if tabs|default(false) == true %}
                </div>
            {% else %}
                </fieldset>
            {% endif %}
        {% endif %}
    '''

    def private editBody(Application it) '''
        <ul>
        {% if obj.createdBy|default and obj.createdBy.uid > 0 %}
            <li>{% trans with {'%user%': obj.createdBy.uname} %}Created by %user%{% endtrans %}</li>
            <li>{% trans with {'%date%': obj.createdDate|format_datetime('medium', 'short')} %}Created on %date%{% endtrans %}</li>
        {% endif %}
        {% if obj.updatedBy|default and obj.updatedBy.uid > 0 %}
            <li>{% trans with {'%user%': obj.updatedBy.uname} %}Last update by %user%{% endtrans %}</li>
            <li>{% trans with {'%date%': obj.updatedDate|format_datetime('medium', 'short')} %}Last update on %date%{% endtrans %}</li>
        {% endif %}
        «FOR entity : getLoggableEntities»
            {% if obj._objectType == '«entity.name.formatForCode»' %}
                <li>{% trans %}Current version{% endtrans %}: {{ obj.«entity.fields.filter(IntegerField).filter[version].head.name.formatForCode» }}</li>
            {% endif %}
        «ENDFOR»
        </ul>
    '''
}
