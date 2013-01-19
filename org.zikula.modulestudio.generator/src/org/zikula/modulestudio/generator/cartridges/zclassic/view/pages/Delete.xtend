package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Delete {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension UrlExtensions = new UrlExtensions()
    @Inject extension Utils = new Utils()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' delete templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(templateFile(controller, name, 'delete'), deleteView(appName, controller))
    }

    def private deleteView(Entity it, String appName, Controller controller) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» delete confirmation view in «controller.formattedName» area *}
        {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/header.tpl'}
        <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-delete">
        {gt text='Delete «name.formatForDisplay»' assign='templateTitle'}
        {pagesetvar name='title' value=$templateTitle}
        «controller.templateHeader»

        <p class="z-warningmsg">{gt text='Do you really want to delete this «name.formatForDisplay» ?'}</p>

        <form class="z-form" action="{modurl modname='«appName»' type='«controller.formattedName»' «modUrlDelete(name, true)»}" method="post">
            <div>
                <input type="hidden" name="csrftoken" value="{insert name='csrftoken'}" />
                <input type="hidden" id="confirmation" name="confirmation" value="1" />
                <fieldset>
                    <legend>{gt text='Confirmation prompt'}</legend>
                    <div class="z-buttons z-formbuttons">
                        {gt text='Delete' assign='deleteTitle'}
                        {button src='14_layer_deletelayer.png' set='icons/small' text=$deleteTitle title=$deleteTitle class='z-btred'}
                        <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='view' ot='«name.formatForCode»'}">{icon type='cancel' size='small' __alt='Cancel' __title='Cancel'} {gt text='Cancel'}</a>
                    </div>
                </fieldset>

                «callDisplayHooks(appName, controller)»
            </div>
        </form>
        «controller.templateFooter»
        </div>
        {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/footer.tpl'}
    '''

    def private templateHeader(Controller it) {
        switch it {
            AdminController: '''
                <div class="z-admin-content-pagetitle">
                    {icon type='delete' size='small' __alt='Delete'}
                    <h3>{$templateTitle}</h3>
                </div>
            '''
            default: '''
                <div class="z-frontendcontainer">
                    <h2>{$templateTitle}</h2>
            '''
        }
    }

    def private templateFooter(Controller it) {
        switch it {
            AdminController: ''
            default: '''
                </div>
            '''
        }
    }

    def private callDisplayHooks(Entity it, String appName, Controller controller) '''
        {notifydisplayhooks eventname='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_delete' id="«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»" assign='hooks'}
        {foreach key='providerArea' item='hook' from=$hooks}
        <fieldset>
            <legend>{$hookName}</legend>
            {$hook}
        </fieldset>
        {/foreach}
    '''
}
