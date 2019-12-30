package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.IntegerField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class StandardFields {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate (Application it, IMostFileSystemAccess fsa) {
        val templatePath = getViewPath + 'Helper/'
        val templateExtension = '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
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
                    <h3>{{ __('Creation and update') }}</h3>
            {% else %}
                <h3 class="standard-fields">{{ __('Creation and update') }}</h3>
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
            <dt>{{ __('Creation') }}</dt>
            {% set profileLink = obj.createdBy.uid|profileLinkByUserId %}
            <dd class="avatar">{{ userAvatar(obj.createdBy.uid, {rating: 'g'}) }}</dd>
            <dd>
                {{ __f('Created by %user on %date', {'%user': profileLink, '%date': obj.createdDate|«IF targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('medium', 'short')})|raw }}
                {% if currentUser.loggedIn %}
                    {% set sendMessageUrl = obj.createdBy.uid|messageSendLink(urlOnly=true) %}
                    {% if sendMessageUrl != '#' %}
                        <a href="{{ sendMessageUrl }}" title="{{ __f('Send private message to %userName%', {'%userName%': obj.createdBy.uname}) }}"><i class="fa fa-envelope«IF !targets('3.0')»-o«ENDIF»"></i></a>
                    {% endif %}
                {% endif %}
            </dd>
        {% endif %}
        {% if obj.updatedBy|default and obj.updatedBy.uid > 0 %}
            <dt>{{ __('Last update') }}</dt>
            {% set profileLink = obj.updatedBy.uid|profileLinkByUserId %}
            <dd class="avatar">{{ userAvatar(obj.updatedBy.uid, {rating: 'g'}) }}</dd>
            <dd>
                {{ __f('Updated by %user on %date', {'%user': profileLink, '%date': obj.updatedDate|«IF targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('medium', 'short')})|raw }}
                {% if currentUser.loggedIn %}
                    {% set sendMessageUrl = obj.updatedBy.uid|messageSendLink(urlOnly=true) %}
                    {% if sendMessageUrl != '#' %}
                        <a href="{{ sendMessageUrl }}" title="{{ __f('Send private message to %userName%', {'%userName%': obj.updatedBy.uname}) }}"><i class="fa fa-envelope«IF !targets('3.0')»-o«ENDIF»"></i></a>
                    {% endif %}
                {% endif %}
            </dd>
        {% endif %}
        </dl>
    '''

    def private standardFieldsEditImpl(Application it) '''
        {# purpose of this template: reusable editing of standard fields #}
        {% if (obj.createdBy|default and obj.createdBy.uid > 0) or (obj.updatedBy|default and obj.updatedBy.uid > 0) %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabStandardFields" aria-labelledby="standardFieldsTab">
                    <h3>{{ __('Creation and update') }}</h3>
            {% else %}
                <fieldset class="standardfields">
            {% endif %}
                <legend>{{ __('Creation and update') }}</legend>
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
            <li>{{ __f('Created by %user', {'%user': obj.createdBy.uname}) }}</li>
            <li>{{ __f('Created on %date', {'%date': obj.createdDate|«IF targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('medium', 'short')}) }}</li>
        {% endif %}
        {% if obj.updatedBy|default and obj.updatedBy.uid > 0 %}
            <li>{{ __f('Updated by %user', {'%user': obj.updatedBy.uname}) }}</li>
            <li>{{ __f('Updated on %date', {'%date': obj.updatedDate|«IF targets('3.0')»format_datetime«ELSE»localizeddate«ENDIF»('medium', 'short')}) }}</li>
        {% endif %}
        «FOR entity : getLoggableEntities»
            {% if obj._objectType == '«entity.name.formatForCode»' %}
                <li>{{ __('Current version') }}: {{ obj.«entity.fields.filter(IntegerField).filter[version].head.name.formatForCode» }}</li>
            {% endif %}
        «ENDFOR»
        </ul>
    '''
}
