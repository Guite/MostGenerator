package org.zikula.modulestudio.generator.cartridges.zclassic.view.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class StandardFields {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate (Application it, Controller controller, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) controller.formattedName else controller.formattedName.toFirstUpper) + '/'
        if (controller.hasActions('view') || controller.hasActions('display'))
            fsa.generateFile(templatePath + 'include_standardfields_display.tpl', standardFieldsViewImpl(controller))
        if (controller.hasActions('edit'))
            fsa.generateFile(templatePath + 'include_standardfields_edit.tpl', standardFieldsEditImpl(controller))
    }

    def private standardFieldsViewImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable display of standard fields *}
        {if (isset($obj.createdUserId) && $obj.createdUserId) || (isset($obj.updatedUserId) && $obj.updatedUserId)}
            {if isset($panel) && $panel eq true}
                <h3 class="standardfields z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Creation and update'}</h3>
                <div class="standardfields z-panel-content" style="display: none">
            {else}
                <h3 class="standardfields">{gt text='Creation and update'}</h3>
            {/if}
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
                <dd>{gt text='Created by %1$s on %2$s' tag1=$profileLink tag2=$obj.createdDate|dateformat html=true}</dd>
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
                <dd>{gt text='Updated by %1$s on %2$s' tag1=$profileLink tag2=$obj.updatedDate|dateformat html=true}</dd>
            {/if}
            </dl>
            {if isset($panel) && $panel eq true}
                </div>
            {/if}
        {/if}
    '''

    def private standardFieldsEditImpl(Application it, Controller controller) '''
        {* purpose of this template: reusable editing of standard fields *}
        {if (isset($obj.createdUserId) && $obj.createdUserId) || (isset($obj.updatedUserId) && $obj.updatedUserId)}
            {if isset($panel) && $panel eq true}
                <h3 class="standardfields z-panel-header z-panel-indicator «IF targets('1.3.5')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Creation and update'}</h3>
                <fieldset class="standardfields z-panel-content" style="display: none">
            {else}
                <fieldset class="standardfields">
            {/if}
                <legend>{gt text='Creation and update'}</legend>
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
            </fieldset>
        {/if}
    '''
}
