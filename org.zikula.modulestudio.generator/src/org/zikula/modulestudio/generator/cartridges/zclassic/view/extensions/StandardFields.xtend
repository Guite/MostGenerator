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

        var fileName = ''
        if (hasViewActions || hasDisplayActions) {
            fileName = 'include_standardfields_display.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'include_standardfields_display.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, standardFieldsViewImpl)
            }
        }
        if (hasEditActions) {
            fileName = 'include_standardfields_edit.tpl'
            if (!shouldBeSkipped(templatePath + fileName)) {
                if (shouldBeMarked(templatePath + fileName)) {
                    fileName = 'include_standardfields_edit.generated.tpl'
                }
                fsa.generateFile(templatePath + fileName, standardFieldsEditImpl)
            }
        }
    }

    def private standardFieldsViewImpl(Application it) '''
        {* purpose of this template: reusable display of standard fields *}
        {if (isset($obj.createdUserId) && $obj.createdUserId) || (isset($obj.updatedUserId) && $obj.updatedUserId)}
            {if isset($panel) && $panel eq true}
                «IF targets('1.3.x')»
                    <h3 class="standardfields z-panel-header z-panel-indicator «IF targets('1.3.x')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Creation and update'}</h3>
                    <div class="standardfields z-panel-content" style="display: none">
                «ELSE»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseStandardFields">{gt text='Creation and update'}</a></h3>
                        </div>
                        <div id="collapseStandardFields" class="panel-collapse collapse in">
                            <div class="panel-body">
                «ENDIF»
            {else}
                <h3 class="standardfields">{gt text='Creation and update'}</h3>
            {/if}
            «viewBody»
            {if isset($panel) && $panel eq true}
                «IF targets('1.3.x')»
                    </div>
                «ELSE»
                            </div>
                        </div>
                    </div>
                «ENDIF»
            {/if}
        {/if}
    '''

    def private viewBody(Application it) '''
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
            <dd class="avatar">{useravatar uid=$obj.updatedUserId rating='g'}</dd>
            <dd>{gt text='Updated by %1$s on %2$s' tag1=$profileLink tag2=$obj.updatedDate|dateformat html=true}</dd>
        {/if}
        </dl>
    '''

    def private standardFieldsEditImpl(Application it) '''
        {* purpose of this template: reusable editing of standard fields *}
        {if (isset($obj.createdUserId) && $obj.createdUserId) || (isset($obj.updatedUserId) && $obj.updatedUserId)}
            {if isset($panel) && $panel eq true}
                «IF targets('1.3.x')»
                    <h3 class="standardfields z-panel-header z-panel-indicator «IF targets('1.3.x')»z«ELSE»cursor«ENDIF»-pointer">{gt text='Creation and update'}</h3>
                    <fieldset class="standardfields z-panel-content" style="display: none">
                «ELSE»
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapseStandardFields">{gt text='Creation and update'}</a></h3>
                        </div>
                        <div id="collapseStandardFields" class="panel-collapse collapse in">
                            <div class="panel-body">
                «ENDIF»
            {else}
                <fieldset class="standardfields">
            {/if}
                <legend>{gt text='Creation and update'}</legend>
                «editBody»
            {if isset($panel) && $panel eq true}
                «IF targets('1.3.x')»
                    </fieldset>
                «ELSE»
                            </div>
                        </div>
                    </div>
                «ENDIF»
            {else}
                </fieldset>
            {/if}
        {/if}
    '''

    def private editBody(Application it) '''
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
}
