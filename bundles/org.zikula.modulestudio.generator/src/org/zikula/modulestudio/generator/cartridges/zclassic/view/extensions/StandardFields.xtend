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
        «IF !isSystemModule && targets('3.0')»
            {% trans_default_domain '«appName.formatForDB»' %}
        «ENDIF»
        {% if (obj.createdBy|default and obj.createdBy.uid > 0) or (obj.updatedBy|default and obj.updatedBy.uid > 0) %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabStandardFields" aria-labelledby="standardFieldsTab">
                    <h3>«IF targets('3.0')»{% trans %}Creation and update{% endtrans %}«ELSE»{{ __('Creation and update') }}«ENDIF»</h3>
            {% else %}
                <h3 class="standard-fields">«IF targets('3.0')»{% trans %}Creation and update{% endtrans %}«ELSE»{{ __('Creation and update') }}«ENDIF»</h3>
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
            <dt>«IF targets('3.0')»{% trans %}Creation{% endtrans %}«ELSE»{{ __('Creation') }}«ENDIF»</dt>
            {% set profileLink = obj.createdBy.uid|profileLinkByUserId %}
            <dd class="avatar">{{ userAvatar(obj.createdBy.uid, {rating: 'g'}) }}</dd>
            <dd>
                «IF targets('3.0')»
                    {{ 'Created by %user% on %date%'|trans({'%user%': profileLink|raw, '%date%': obj.createdDate|format_datetime('medium', 'short')}) }}
                «ELSE»
                    {{ __f('Created by %user on %date', {'%user': profileLink, '%date': obj.createdDate|localizeddate('medium', 'short')})|raw }}
                «ENDIF»
                {% if currentUser.loggedIn %}
                    {% set sendMessageUrl = obj.createdBy.uid|messageSendLink(urlOnly=true) %}
                    {% if sendMessageUrl != '#' %}
                        <a href="{{ sendMessageUrl }}" title="«IF targets('3.0')»{% trans with {'%userName%': obj.createdBy.uname} %}Send private message to %userName%{% endtrans %}«ELSE»{{ __f('Send private message to %userName%', {'%userName%': obj.createdBy.uname}) }}«ENDIF»"><i class="fa fa-envelope«IF !targets('3.0')»-o«ENDIF»"></i></a>
                    {% endif %}
                {% endif %}
            </dd>
        {% endif %}
        {% if obj.updatedBy|default and obj.updatedBy.uid > 0 %}
            <dt>«IF targets('3.0')»{% trans %}Last update{% endtrans %}«ELSE»{{ __('Last update') }}«ENDIF»</dt>
            {% set profileLink = obj.updatedBy.uid|profileLinkByUserId %}
            <dd class="avatar">{{ userAvatar(obj.updatedBy.uid, {rating: 'g'}) }}</dd>
            <dd>
                «IF targets('3.0')»
                    {{ 'Updated by %user% on %date%'|trans({'%user%': profileLink|raw, '%date%': obj.updatedDate|format_datetime('medium', 'short')}) }}
                «ELSE»
                    {{ __f('Updated by %user on %date', {'%user': profileLink, '%date': obj.updatedDate|localizeddate('medium', 'short')})|raw }}
                «ENDIF»
                {% if currentUser.loggedIn %}
                    {% set sendMessageUrl = obj.updatedBy.uid|messageSendLink(urlOnly=true) %}
                    {% if sendMessageUrl != '#' %}
                        <a href="{{ sendMessageUrl }}" title="«IF targets('3.0')»{% trans with {'%userName': obj.updatedBy.uname} %}Send private message to %userName{% endtrans %}«ELSE»{{ __f('Send private message to %userName%', {'%userName%': obj.updatedBy.uname}) }}«ENDIF»"><i class="fa fa-envelope«IF !targets('3.0')»-o«ENDIF»"></i></a>
                    {% endif %}
                {% endif %}
            </dd>
        {% endif %}
        </dl>
    '''

    def private standardFieldsEditImpl(Application it) '''
        {# purpose of this template: reusable editing of standard fields #}
        «IF !isSystemModule && targets('3.0')»
            {% trans_default_domain '«appName.formatForDB»' %}
        «ENDIF»
        {% if (obj.createdBy|default and obj.createdBy.uid > 0) or (obj.updatedBy|default and obj.updatedBy.uid > 0) %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tabStandardFields" aria-labelledby="standardFieldsTab">
                    <h3>«IF targets('3.0')»{% trans %}Creation and update{% endtrans %}«ELSE»{{ __('Creation and update') }}«ENDIF»</h3>
            {% else %}
                <fieldset class="standardfields">
            {% endif %}
                <legend>«IF targets('3.0')»{% trans %}Creation and update{% endtrans %}«ELSE»{{ __('Creation and update') }}«ENDIF»</legend>
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
            «IF targets('3.0')»
                <li>{% trans with {'%user%': obj.createdBy.uname} %}Created by %user%{% endtrans %}</li>
                <li>{% trans with {'%date%': obj.createdDate|format_datetime('medium', 'short')} %}Created on %date%{% endtrans %}</li>
            «ELSE»
                <li>{{ __f('Created by %user', {'%user': obj.createdBy.uname}) }}</li>
                <li>{{ __f('Created on %date', {'%date': obj.createdDate|localizeddate('medium', 'short')}) }}</li>
            «ENDIF»
        {% endif %}
        {% if obj.updatedBy|default and obj.updatedBy.uid > 0 %}
            «IF targets('3.0')»
                <li>{% trans with {'%user%': obj.updatedBy.uname} %}Updated by %user%{% endtrans %}</li>
                <li>{% trans with {'%date%': obj.updatedDate|format_datetime('medium', 'short')} %}Updated on %date%{% endtrans %}</li>
            «ELSE»
                <li>{{ __f('Updated by %user', {'%user': obj.updatedBy.uname}) }}</li>
                <li>{{ __f('Updated on %date', {'%date': obj.updatedDate|localizeddate('medium', 'short')}) }}</li>
            «ENDIF»
        {% endif %}
        «FOR entity : getLoggableEntities»
            {% if obj._objectType == '«entity.name.formatForCode»' %}
                <li>«IF targets('3.0')»{% trans %}Current version{% endtrans %}«ELSE»{{ __('Current version') }}«ENDIF»: {{ obj.«entity.fields.filter(IntegerField).filter[version].head.name.formatForCode» }}</li>
            {% endif %}
        «ENDFOR»
        </ul>
    '''
}
