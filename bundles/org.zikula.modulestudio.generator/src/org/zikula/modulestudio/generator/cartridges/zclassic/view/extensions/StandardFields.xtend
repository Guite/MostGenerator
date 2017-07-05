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
        {% if (obj.createdBy|default and obj.createdBy.getUid() > 0) or (obj.updatedBy|default and obj.updatedBy.getUid() > 0) %}
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
        {% if obj.createdBy|default and obj.createdBy.getUid() > 0 %}
            <dt>{{ __('Creation') }}</dt>
            {% set profileLink = obj.createdBy.getUid()|profileLinkByUserId() %}
            «IF targets('1.5')»
                <dd class="avatar">{{ userAvatar(obj.createdBy.getUid(), { rating: 'g' }) }}</dd>
            «ELSE»
                <dd class="avatar">{{ «appName.toLowerCase»_userAvatar(uid=obj.createdBy.getUid(), rating='g') }}</dd>
            «ENDIF»
            <dd>
                {{ __f('Created by %user on %date', {'%user': profileLink, '%date': obj.createdDate|localizeddate('medium', 'short')})|raw }}
                {% if currentUser.loggedIn %}
                    {% set sendMessageUrl = obj.createdBy.getUid()|messageSendLink(urlOnly=true) %}
                    {% if sendMessageUrl != '#' %}
                        <a href="{{ sendMessageUrl }}" title="{{ __f('Send private message to %userName%', { '%userName%': obj.createdBy.getUname() }) }}"><i class="fa fa-envelope-o"></i></a>
                    {% endif %}
                {% endif %}
            </dd>
        {% endif %}
        {% if obj.updatedBy|default and obj.updatedBy.getUid() > 0 %}
            <dt>{{ __('Last update') }}</dt>
            {% set profileLink = obj.updatedBy.getUid()|profileLinkByUserId() %}
            «IF targets('1.5')»
                <dd class="avatar">{{ userAvatar(obj.updatedBy.getUid(), { rating: 'g' }) }}</dd>
            «ELSE»
                <dd class="avatar">{{ «appName.toLowerCase»_userAvatar(uid=obj.updatedBy.getUid(), rating='g') }}</dd>
            «ENDIF»
            <dd>
                {{ __f('Updated by %user on %date', {'%user': profileLink, '%date': obj.updatedDate|localizeddate('medium', 'short')})|raw }}
                {% if currentUser.loggedIn %}
                    {% set sendMessageUrl = obj.updatedBy.getUid()|messageSendLink(urlOnly=true) %}
                    {% if sendMessageUrl != '#' %}
                        <a href="{{ sendMessageUrl }}" title="{{ __f('Send private message to %userName%', { '%userName%': obj.updatedBy.getUname() }) }}"><i class="fa fa-envelope-o"></i></a>
                    {% endif %}
                {% endif %}
            </dd>
        {% endif %}
        </dl>
    '''

    def private standardFieldsEditImpl(Application it) '''
        {# purpose of this template: reusable editing of standard fields #}
        {% if (obj.createdBy|default and obj.createdBy.getUid() > 0) or (obj.updatedBy|default and obj.updatedBy.getUid() > 0) %}
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
        {% if obj.createdBy|default and obj.createdBy.getUid() > 0 %}
            <li>{{ __f('Created by %user', {'%user': obj.createdBy.getUname()}) }}</li>
            <li>{{ __f('Created on %date', {'%date': obj.createdDate|localizeddate('medium', 'short')}) }}</li>
        {% endif %}
        {% if obj.updatedBy|default and obj.updatedBy.getUid() > 0 %}
            <li>{{ __f('Updated by %user', {'%user': obj.updatedBy.getUname()}) }}</li>
            <li>{{ __f('Updated on %date', {'%date': obj.updatedDate|localizeddate('medium', 'short')}) }}</li>
        {% endif %}
        </ul>
    '''
}
