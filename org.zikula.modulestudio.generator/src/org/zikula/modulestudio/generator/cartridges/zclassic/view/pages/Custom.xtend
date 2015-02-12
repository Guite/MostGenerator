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
        val templatePath = app.getViewPath + (if (app.targets('1.3.5')) controller.formattedName else controller.formattedName.toFirstUpper) + '/'
        var fileName = name.formatForCode.toFirstLower + '.tpl'
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            println('Generating ' + controller.formattedName + ' templates for custom action "' + name.formatForDisplay + '"')
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = name.formatForCode.toFirstLower + '.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, customView(it, app, controller))
        }
        ''' '''
    }

    def dispatch generate(CustomAction it, Application app, Entity entity, IFileSystemAccess fsa) {
        val templatePath = app.getViewPath + (if (app.targets('1.3.5')) entity.name.formatForDisplay else entity.name.formatForDisplayCapital) + '/'
        var fileName = name.formatForCode.toFirstLower + '.tpl'
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            println('Generating ' + entity.name.formatForDisplay + ' templates for custom action "' + name.formatForDisplay + '"')
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = name.formatForCode.toFirstLower + '.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, customView(it, app, entity))
        }
        ''' '''
    }

    def private dispatch customView(CustomAction it, Application app, Controller controller) '''
        {* purpose of this template: show output of «name.formatForDisplay» action in «controller.formattedName» area *}
        {include file='«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/header.tpl'}
        <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
            {gt text='«name.formatForDisplayCapital»' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            «controller.templateHeader(name)»

            <p>Please override this template by moving it from <em>/«app.rootFolder»/«app.appName»/«IF app.targets('1.3.5')»templates/«controller.formattedName»«ELSE»«app.getViewPath»«controller.formattedName.toFirstUpper»«ENDIF»/«name.formatForCode.toFirstLower».tpl</em> to either your <em>/themes/YourTheme/templates/modules/«app.appName»/«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/«name.formatForCode.toFirstLower».tpl</em> or <em>/config/templates/«app.appName»/«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/«name.formatForCode.toFirstLower».tpl</em>.</p>
        </div>
        {include file='«IF app.targets('1.3.5')»«controller.formattedName»«ELSE»«controller.formattedName.toFirstUpper»«ENDIF»/footer.tpl'}
    '''

    def private dispatch customView(CustomAction it, Application app, Entity controller) '''
        {* purpose of this template: show output of «name.formatForDisplay» action in «entity.name.formatForDisplay» area *}
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
        <div class="«app.appName.toLowerCase»-«name.formatForDB» «app.appName.toLowerCase»-«name.formatForDB»">
            {gt text='«name.formatForDisplayCapital»' assign='templateTitle'}
            {pagesetvar name='title' value=$templateTitle}
            «entity.templateHeader(name)»

            <p>Please override this template by moving it from <em>/«app.rootFolder»/«app.appName»/«IF app.targets('1.3.5')»templates/«entity.name.formatForDisplay»«ELSE»«app.getViewPath»«entity.name.formatForDisplayCapital»«ENDIF»/«name.formatForCode.toFirstLower».tpl</em> to either your <em>/themes/YourTheme/templates/modules/«app.appName»/«IF app.targets('1.3.5')»«entity.name.formatForDisplay»«ELSE»«entity.name.formatForDisplayCapital»«ENDIF»/«name.formatForCode.toFirstLower».tpl</em> or <em>/config/templates/«app.appName»/«IF app.targets('1.3.5')»«entity.name.formatForDisplay»«ELSE»«entity.name.formatForDisplayCapital»«ENDIF»/«name.formatForCode.toFirstLower».tpl</em>.</p>
        </div>
        «IF app.targets('1.3.5')»
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {include file="`$lctUc`/footer.tpl"}
        «ENDIF»
    '''

    def private dispatch templateHeader(Controller it, String actionName) {
        switch it {
            AdminController: '''
                «IF application.targets('1.3.5')»
                    <div class="z-admin-content-pagetitle">
                        {icon type='options' size='small' __alt='«actionName.formatForDisplayCapital»'}
                        <h3>{$templateTitle}</h3>
                    </div>
                «ELSE»
                    <h3>
                        <span class="fa fa-square"></span>
                        {$templateTitle}
                    </h3>
                «ENDIF»
            '''
            default: '''
                <h2>{$templateTitle}</h2>
            '''
        }
    }

    def private dispatch templateHeader(Entity it, String actionName) '''
        {if $lct eq 'admin'}
            «IF application.targets('1.3.5')»
                <div class="z-admin-content-pagetitle">
                    {icon type='options' size='small' __alt='«actionName.formatForDisplayCapital»'}
                    <h3>{$templateTitle}</h3>
                </div>
            «ELSE»
                <h3>
                    <span class="fa fa-square"></span>
                    {$templateTitle}
                </h3>
            «ENDIF»
        {else}
            <h2>{$templateTitle}</h2>
        {/if}
    '''
}
