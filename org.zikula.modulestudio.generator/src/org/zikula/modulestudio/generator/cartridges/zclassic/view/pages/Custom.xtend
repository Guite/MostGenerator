package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.modulestudio.Action
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.CustomAction
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

    def private customView(CustomAction it, Application app, Controller controller) '''
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

    def private templateHeader(Controller it, String actionName) {
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
}
