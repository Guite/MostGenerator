package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Delete {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        val templateFilePath = templateFile('delete')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            println('Generating delete templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, deleteView(appName))
        }
    }

    def private deleteView(Entity it, String appName) '''
        «val app = container.application»
        {* purpose of this template: «nameMultiple.formatForDisplay» delete confirmation view *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        «IF app.targets('1.3.5')»
            {include file="`$lct`/header.tpl"}
        «ELSE»
            {assign var='lctUc' value=$lct|ucfirst}
            {include file="`$lctUc`/header.tpl"}
        «ENDIF»
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-delete">
            {gt text='Delete «name.formatForDisplay»' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            «templateHeader»

            <p class="«IF app.targets('1.3.5')»z-warningmsg«ELSE»alert alert-warningmsg«ENDIF»">{gt text='Do you really want to delete this «name.formatForDisplay» ?'}</p>

            <form class="«IF app.targets('1.3.5')»z-form«ELSE»form-horizontal«ENDIF»" action="«IF app.targets('1.3.5')»{modurl modname='«appName»' type=$lct func='delete' ot='«name.formatForCode»' «routeParamsLegacy(name, true, false)»}«ELSE»{route name='«appName.formatForDB»_«name.formatForCode»_delete' «routeParams(name, true)» lct=$lct}«ENDIF»" method="post"«IF !app.targets('1.3.5')» role="form"«ENDIF»>
                <div>
                    <input type="hidden" name="csrftoken" value="{insert name='csrftoken'}" />
                    <input type="hidden" id="confirmation" name="confirmation" value="1" />
                    <fieldset>
                        <legend>{gt text='Confirmation prompt'}</legend>
                        <div class="«IF app.targets('1.3.5')»z-buttons z-formbuttons«ELSE»form-group form-buttons«ENDIF»">
                        «IF !app.targets('1.3.5')»
                            <div class="col-lg-offset-3 col-lg-9">
                        «ENDIF»
                            {gt text='Delete' assign='deleteTitle'}
                            {button src='14_layer_deletelayer.png' set='icons/small' text=$deleteTitle title=$deleteTitle class='«IF app.targets('1.3.5')»z-btred«ELSE»btn btn-danger«ENDIF»'}
                            «IF app.targets('1.3.5')»
                                <a href="{modurl modname='«appName»' type=$lct func='view' ot='«name.formatForCode»'}">{icon type='cancel' size='small' __alt='Cancel' __title='Cancel'} {gt text='Cancel'}</a>
                            «ELSE»
                                <a href="{route name='«appName.formatForDB»_«name.formatForCode»_view' lct=$lct}" class="btn btn-default" role="button"><span class="fa fa-times"></span> {gt text='Cancel'}</a>
                            «ENDIF»
                        «IF !app.targets('1.3.5')»
                            </div>
                        «ENDIF»
                        </div>
                    </fieldset>

                    «callDisplayHooks(appName)»
                </div>
            </form>
        </div>
        «IF app.targets('1.3.5')»
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {include file="`$lctUc`/footer.tpl"}
        «ENDIF»
    '''

    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            «IF container.application.targets('1.3.5')»
                <div class="z-admin-content-pagetitle">
                    {icon type='delete' size='small' __alt='Delete'}
                    <h3>{$templateTitle}</h3>
                </div>
            «ELSE»
                <h3>
                    <span class="fa fa-trash-o"></span>
                    {$templateTitle}
                </h3>
            «ENDIF»
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        {notifydisplayhooks eventname='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_delete' id="«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»" assign='hooks'}
        {foreach key='providerArea' item='hook' from=$hooks}
        <fieldset>
            <legend>{$hookName}</legend>
            {$hook}
        </fieldset>
        {/foreach}
    '''
}
