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
        val templatePath = getViewPath + (if (targets('1.3.x')) 'helper' else 'Helper') + '/'
        val templateExtension = if (targets('1.3.x')) '.tpl' else '.html.twig'

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'includeStandardFieldsDisplay' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeStandardFieldsDisplay.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) standardFieldsViewImplLegacy else standardFieldsViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'includeStandardFieldsEdit' + templateExtension
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'includeStandardFieldsEdit.generated' + templateExtension
                }
                fsa.generateFile(templatePath + fileName, if (targets('1.3.x')) standardFieldsEditImplLegacy else standardFieldsEditImpl)
            }
        }
    }

    def private standardFieldsViewImplLegacy(Application it) '''
        {* purpose of this template: reusable display of standard fields *}
        {if (isset($obj.createdUserId) && $obj.createdUserId) || (isset($obj.updatedUserId) && $obj.updatedUserId)}
            {if isset($panel) && $panel eq true}
                <h3 class="standard-fields z-panel-header z-panel-indicator z-pointer">{gt text='Creation and update'}</h3>
                <div class="standard-fields z-panel-content" style="display: none">
            {else}
                <h3 class="standard-fields">{gt text='Creation and update'}</h3>
            {/if}
            «viewBodyLegacy»
            {if isset($panel) && $panel eq true}
                </div>
            {/if}
        {/if}
    '''

    def private standardFieldsViewImpl(Application it) '''
        {# purpose of this template: reusable display of standard fields #}
        {% if obj.createdUserId|default or obj.updatedUserId|default %}
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

    def private viewBodyLegacy(Application it) '''
        <dl class="propertylist">
        {if isset($obj.createdUserId) && $obj.createdUserId}
            <dt>{gt text='Creation'}</dt>
            {usergetvar name='uname' uid=$obj.createdUserId assign='cr_uname'}
            {if $modvars.ZConfig.profilemodule ne ''}
                {* if we have a profile module link to the user profile *}
                {modurl modname=$modvars.ZConfig.profilemodule type='user' func='view' uname=$cr_uname assign='profileLink'}
                {assign var='profileLink' value=$profileLink|safetext}
                {assign var='profileLink' value="<a href=\"`$profileLink`\">`$cr_uname`</a>"}
            {else}
                {* else just show the user name *}
                {assign var='profileLink' value=$cr_uname}
            {/if}
            <dd class="avatar">{useravatar uid=$obj.createdUserId rating='g'}</dd>
            <dd>{gt text='Created by %1$s on %2$s' tag1=$profileLink tag2=$obj.createdDate|dateformat:'datetimebrief' html=true}</dd>
        {/if}
        {if isset($obj.updatedUserId) && $obj.updatedUserId}
            <dt>{gt text='Last update'}</dt>
            {usergetvar name='uname' uid=$obj.updatedUserId assign='lu_uname'}
            {if $modvars.ZConfig.profilemodule ne ''}
                {* if we have a profile module link to the user profile *}
                {modurl modname=$modvars.ZConfig.profilemodule type='user' func='view' uname=$lu_uname assign='profileLink'}
                {assign var='profileLink' value=$profileLink|safetext}
                {assign var='profileLink' value="<a href=\"`$profileLink`\">`$lu_uname`</a>"}
            {else}
                {* else just show the user name *}
                {assign var='profileLink' value=$lu_uname}
            {/if}
            <dd class="avatar">{useravatar uid=$obj.updatedUserId rating='g'}</dd>
            <dd>{gt text='Updated by %1$s on %2$s' tag1=$profileLink tag2=$obj.updatedDate|dateformat:'datetimebrief' html=true}</dd>
        {/if}
        </dl>
    '''

    def private viewBody(Application it) '''
        <dl class="propertylist">
        {% if obj.createdUserId|default %}
            <dt>{{ __('Creation') }}</dt>
            {% set profileLink = obj.createdUserId.getUid()|profileLinkByUserId() %}
            <dd class="avatar">{{ «appName.toLowerCase»_userAvatar(uid=obj.createdUserId.getUid(), rating='g') }}</dd>
            <dd>{{ __f('Created by %user on %date', {'%user': profileLink, '%date': obj.createdDate|localizeddate('medium', 'short')})|raw }}</dd>
        {% endif %}
        {% if obj.updatedUserId|default %}
            <dt>{{ __('Last update') }}</dt>
            {% set profileLink = obj.updatedUserId.getUid()|profileLinkByUserId() %}
            <dd class="avatar">{{ «appName.toLowerCase»_userAvatar(uid=obj.updatedUserId.getUid(), rating='g') }}</dd>
            <dd>{{ __f('Updated by %user on %date', {'%user': profileLink, '%date': obj.updatedDate|localizeddate('medium', 'short')})|raw }}</dd>
        {% endif %}
        </dl>
    '''

    def private standardFieldsEditImplLegacy(Application it) '''
        {* purpose of this template: reusable editing of standard fields *}
        {if (isset($obj.createdUserId) && $obj.createdUserId) || (isset($obj.updatedUserId) && $obj.updatedUserId)}
            {if isset($panel) && $panel eq true}
                <h3 class="standardfields z-panel-header z-panel-indicator z-pointer">{gt text='Creation and update'}</h3>
                <fieldset class="standardfields z-panel-content" style="display: none">
            {else}
                <fieldset class="standardfields">
            {/if}
                <legend>{gt text='Creation and update'}</legend>
                «editBodyLegacy»
            {if isset($panel) && $panel eq true}
                </fieldset>
            {else}
                </fieldset>
            {/if}
        {/if}
    '''

    def private standardFieldsEditImpl(Application it) '''
        {# purpose of this template: reusable editing of standard fields #}
        {% if obj.createdUserId|default or obj.updatedUserId|default %}
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

    def private editBodyLegacy(Application it) '''
        <ul>
        {if isset($obj.createdUserId) && $obj.createdUserId}
            {usergetvar name='uname' uid=$obj.createdUserId assign='username'}
            <li>{gt text='Created by %s' tag1=$username}</li>
            <li>{gt text='Created on %s' tag1=$obj.createdDate|dateformat}</li>
        {/if}
        {if isset($obj.updatedUserId) && $obj.updatedUserId}
            {usergetvar name='uname' uid=$obj.updatedUserId assign='username'}
            <li>{gt text='Updated by %s' tag1=$username}</li>
            <li>{gt text='Updated on %s' tag1=$obj.updatedDate|dateformat}</li>
        {/if}
        </ul>
    '''

    def private editBody(Application it) '''
        <ul>
        {% if obj.createdUserId|default %}
            <li>{{ __f('Created by %user', {'%user': obj.createdUserId.getUname()}) }}</li>
            <li>{{ __f('Created on %date', {'%date': obj.createdDate|localizeddate('medium', 'short')}) }}</li>
        {% endif %}
        {% if obj.updatedUserId|default %}
            <li>{{ __f('Updated by %user', {'%user': obj.updatedUserId.getUname()}) }}</li>
            <li>{{ __f('Updated on %date', {'%date': obj.updatedDate|localizeddate('medium', 'short')}) }}</li>
        {% endif %}
        </ul>
    '''
}
