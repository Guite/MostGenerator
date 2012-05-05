package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Main {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' main templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(appName.getAppSourcePath + 'templates/' + controller.formattedName + '/main.tpl', mainView(appName, controller))
    }

    def private mainView(Entity it, String appName, Controller controller) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» main view in «controller.formattedName» area *}
        «IF controller.hasActions('view')»
        {modfunc modname='«appName»' type='«controller.formattedName»' func='view'}
        «ELSE»
            {include file='«controller.formattedName»/header.tpl'}
            <p>{gt text='Welcome to the «controller.formattedName» section of the «appName.formatForDisplayCapital» application.'}</p>
            {include file='«controller.formattedName»/footer.tpl'}
        «ENDIF»
    '''
}
