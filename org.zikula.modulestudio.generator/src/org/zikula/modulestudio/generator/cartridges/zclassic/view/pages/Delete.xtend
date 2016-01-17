package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Entity
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
        if (!application.shouldBeSkipped(templateFilePath)) {
            println('Generating delete templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, deleteView(appName))
        }
    }

    def private deleteView(Entity it, String appName) '''
        «val app = application»
        «IF app.targets('1.3.x')»
            {* purpose of this template: «nameMultiple.formatForDisplay» delete confirmation view *}
            {assign var='lct' value='user'}
            {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                {assign var='lct' value='admin'}
            {/if}
            {include file="`$lct`/header.tpl"}
            <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-delete">
                {gt text='Delete «name.formatForDisplay»' assign='templateTitle'}
                {pagesetvar name='title' value=$templateTitle}
                «templateHeader»

                <p class="z-warningmsg">{gt text='Do you really want to delete this «name.formatForDisplay» ?'}</p>

                <form class="z-form" action="{modurl modname='«appName»' type=$lct func='delete' ot='«name.formatForCode»' «routeParamsLegacy(name, true, false)»}" method="post">
                    <div>
                        <input type="hidden" name="csrftoken" value="{insert name='csrftoken'}" />
                        <input type="hidden" id="confirmation" name="confirmation" value="1" />
                        <fieldset>
                            <legend>{gt text='Confirmation prompt'}</legend>
                            <div class="z-buttons z-formbuttons">
                                {gt text='Delete' assign='deleteTitle'}
                                {button src='14_layer_deletelayer.png' set='icons/small' text=$deleteTitle title=$deleteTitle class='z-btred'}
                                <a href="{modurl modname='«appName»' type=$lct func='view' ot='«name.formatForCode»'}">{icon type='cancel' size='small' __alt='Cancel' __title='Cancel'} {gt text='Cancel'}</a>
                            </div>
                        </fieldset>
                        «IF !skipHookSubscribers»

                            «callDisplayHooks(appName)»
                        «ENDIF»
                    </div>
                </form>
            </div>
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {# purpose of this template: «nameMultiple.formatForDisplay» delete confirmation view #}
            {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
            {% block title __('Delete «name.formatForDisplay»') %}
            {% block admin_page_icon 'trash-o' %}
            {% block content %}
                <div class="«appName.toLowerCase»-«name.formatForDB» «appName.toLowerCase»-delete">
                    <p class="alert alert-warning">{{ __f('Do you really want to delete this «name.formatForDisplay»: "%name%" ?', {'%name%': «name.formatForCode».getTitleFromDisplayPattern()}) }}</p>

                    {% form_theme deleteForm with [
                        '@«appName»/Form/bootstrap_3.html.twig',
                        '@ZikulaFormExtensionBundle/Form/form_div_layout.html.twig'
                    ] %}
                    {{ form_start(deleteForm) }}
                    {{ form_errors(deleteForm) }}

                    <fieldset>
                        <legend>{{ __('Confirmation prompt') }}</legend>
                        <div class="form-group">
                            <div class="col-sm-offset-3 col-sm-9">
                                {{ form_widget(deleteForm.delete, {attr: {class: 'btn btn-success'}, icon: 'fa-trash-o'}) }}
                                {{ form_widget(deleteForm.cancel, {attr: {class: 'btn btn-default', formnovalidate: 'formnovalidate'}, icon: 'fa-times'}) }}
                            </div>
                        </div>
                    </fieldset>
                    «IF !skipHookSubscribers»

                        {{ block('display_hooks') }}
                    «ENDIF»
                    {{ form_end(form) }}
                </div>
            {% endblock %}
            «IF !skipHookSubscribers»
                {% block display_hooks %}
                    «callDisplayHooks(appName)»
                {% endblock %}
            «ENDIF»
        «ENDIF»
    '''

    // 1.3.x only
    def private templateHeader(Entity it) '''
        {if $lct eq 'admin'}
            <div class="z-admin-content-pagetitle">
                {icon type='delete' size='small' __alt='Delete'}
                <h3>{$templateTitle}</h3>
            </div>
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''

    def private callDisplayHooks(Entity it, String appName) '''
        «IF application.targets('1.3.x')»
            {notifydisplayhooks eventname='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_delete' id="«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»" assign='hooks'}
            {foreach key='providerArea' item='hook' from=$hooks}
                <fieldset>
                    {*<legend>{$hookName}</legend>*}
                    {$hook}
                </fieldset>
            {/foreach}
        «ELSE»
            {% set hooks = notifyDisplayHooks(eventName='«appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_delete', id=«FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ '»«name.formatForCode».«pkField.name.formatForCode»«ENDFOR») %}
            {% if hooks is iterable and hooks|length > 0 %}
                {% for providerArea, hook in hooks %}
                    <fieldset>
                        {# <legend>{{ hookName }}</legend> #}
                        {{ hook }}
                    </fieldset>
                {% endfor %}
            {% endif %}
        «ENDIF»
    '''
}
