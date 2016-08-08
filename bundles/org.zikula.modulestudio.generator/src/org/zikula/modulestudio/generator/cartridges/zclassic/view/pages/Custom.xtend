package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Action
import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.CustomAction
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Custom {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def dispatch generate(Action it, Application app, Controller controller, IFileSystemAccess fsa) {
    }

    def dispatch generate(CustomAction it, Application app, Controller controller, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + (if (app.targets('1.3.x')) controller.formattedName else controller.formattedName.toFirstUpper) + '/'
        val templateExtension = if (app.targets('1.3.x')) '.tpl' else '.html.twig'
        var fileName = name.formatForCode.toFirstLower + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            println('Generating ' + controller.formattedName + ' templates for custom action "' + name.formatForDisplay + '"')
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = name.formatForCode.toFirstLower + '.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, customView(it, app, controller))
        }
        ''' '''
    }

    def dispatch generate(CustomAction it, Application app, Entity entity, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + (if (app.targets('1.3.x')) entity.name.formatForDisplay else entity.name.formatForDisplayCapital) + '/'
        val templateExtension = if (app.targets('1.3.x')) '.tpl' else '.html.twig'
        var fileName = name.formatForCode.toFirstLower + templateExtension
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            println('Generating ' + entity.name.formatForDisplay + ' templates for custom action "' + name.formatForDisplay + '"')
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = name.formatForCode.toFirstLower + '.generated' + templateExtension
            }
            fsa.generateFile(templatePath + fileName, customView(it, app, entity))
        }
        ''' '''
    }

    def private dispatch customView(CustomAction it, Application app, Controller controller) '''
        «IF app.targets('1.3.x')»
            {* purpose of this template: show output of «name.formatForDisplay» action in «controller.formattedName» area *}
            {include file='«controller.formattedName»/header.tpl'}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                {gt text='«name.formatForDisplayCapital»' assign='templateTitle'}
                {pagesetvar name='title' value=$templateTitle}
                «controller.templateHeader(name)»

                <p>Please override this template by moving it from <em>/«app.rootFolder»/«app.appName»/templates/«controller.formattedName»/«name.formatForCode.toFirstLower».tpl</em> to either your <em>/themes/YourTheme/templates/modules/«app.appName»/«controller.formattedName»/«name.formatForCode.toFirstLower».tpl</em> or <em>/config/templates/«app.appName»/«controller.formattedName»/«name.formatForCode.toFirstLower».tpl</em>.</p>
            </div>
            {include file='«controller.formattedName»/footer.tpl'}
        «ELSE»
            {# purpose of this template: show output of «name.formatForDisplay» action in «controller.formattedName» area #}
            {% extends '«app.appName»::«IF controller instanceof AdminController»adminBase«ELSE»base«ENDIF».html.twig' %}
            {% block title __('«name.formatForDisplayCapital»') %}
            «IF controller instanceof AdminController»
                {% block admin_page_icon 'square' %}
            «ENDIF»
            {% block content %}
                <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                    <p>Please override this template by moving it from <em>/«app.rootFolder»/«if (app.systemModule) app.name.formatForCode else app.appName»/«app.getViewPath»«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».html.twig</em> to either your <em>/themes/YourTheme/Resources/views/modules/«app.appName»/«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».html.twig</em> or <em>/config/templates/«app.appName»/«controller.formattedName.toFirstUpper»/«name.formatForCode.toFirstLower».html.twig</em>.</p>
                </div>
            {% endblock %}
        «ENDIF»
    '''

    def private dispatch customView(CustomAction it, Application app, Entity controller) '''
        «IF app.targets('1.3.x')»
            {* purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» area *}
            {assign var='lct' value='user'}
            {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                {assign var='lct' value='admin'}
            {/if}
            {include file="`$lct`/header.tpl"}
            <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                {gt text='«name.formatForDisplayCapital»' assign='templateTitle'}
                {pagesetvar name='title' value=$templateTitle}
                «entity.templateHeader(name)»

                <p>Please override this template by moving it from <em>/«app.rootFolder»/«app.appName»/templates/«entity.name.formatForDisplay»/«name.formatForCode.toFirstLower».tpl</em> to either your <em>/themes/YourTheme/templates/modules/«app.appName»/«entity.name.formatForDisplayCapital»/«name.formatForCode.toFirstLower».tpl</em> or <em>/config/templates/«app.appName»/«entity.name.formatForDisplayCapital»/«name.formatForCode.toFirstLower».tpl</em>.</p>
            </div>
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {# purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» area #}
            {% extends routeArea == 'admin' ? '«app.appName»::adminBase.html.twig' : '«app.appName»::base.html.twig' %}
            {% block title %}
                {{ __('«name.formatForDisplayCapital»') }}
            {% endblock %}
            {% block adminPageIcon %}square{% endblock %}
            {% block content %}
                <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
                    <p>Please override this template by moving it from <em>/«app.rootFolder»/«if (app.systemModule) app.name.formatForCode else app.appName»/«app.getViewPath»«entity.name.formatForDisplayCapital»/«name.formatForCode.toFirstLower».tpl</em> to either your <em>/themes/YourTheme/Resources/views/modules/«app.appName»/«entity.name.formatForDisplayCapital»/«name.formatForCode.toFirstLower».tpl</em> or <em>/config/templates/«app.appName»/«entity.name.formatForDisplayCapital»/«name.formatForCode.toFirstLower».tpl</em>.</p>
                </div>
            {% endblock %}
        «ENDIF»
    '''

    // 1.3.x only
    def private dispatch templateHeader(Controller it, String actionName) {
        switch it {
            AdminController: '''
                <div class="z-admin-content-pagetitle">
                    {icon type='options' size='small' __alt='«actionName.formatForDisplayCapital»'}
                    <h3>{$templateTitle}</h3>
                </div>
            '''
            default: '''
                <h2>{$templateTitle}</h2>
            '''
        }
    }

    // 1.3.x only
    def private dispatch templateHeader(Entity it, String actionName) '''
        {if $lct eq 'admin'}
            <div class="z-admin-content-pagetitle">
                {icon type='options' size='small' __alt='«actionName.formatForDisplayCapital»'}
                <h3>{$templateTitle}</h3>
            </div>
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''
}
