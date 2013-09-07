package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Json {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' json view templates for entity "' + name.formatForDisplay + '"')
        if (controller.hasActions('view'))
            fsa.generateFile(templateFileWithExtension(controller, name, 'view', 'json'), jsonView(appName, controller))
        if (controller.hasActions('display'))
            fsa.generateFile(templateFileWithExtension(controller, name, 'display', 'json'), jsonDisplay(appName, controller))
    }

    def private jsonView(Entity it, String appName, Controller controller) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view json view in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='application/json'}
        [
        {foreach item='item' from=$items name='«nameMultiple.formatForCode»'}
            {if not $smarty.foreach.«nameMultiple.formatForCode».first},{/if}
            {$item->toJson()}
        {/foreach}
        ]
    '''

    def private jsonDisplay(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display json view in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='application/json'}
        {$«objName»->toJson()}
    '''
}
