package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Json {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating json view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = ''
        if (hasActions('view')) {
            templateFilePath = templateFileWithExtension('view', 'json')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, jsonView(appName))
            }
        }
        if (hasActions('display')) {
            templateFilePath = templateFileWithExtension('display', 'json')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, jsonDisplay(appName))
            }
        }
    }

    def private jsonView(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view json view *}
        «IF application.targets('1.3.5')»
            {«appName.formatForDB»TemplateHeaders contentType='application/json'}
        «ENDIF»
        [
        {foreach item='item' from=$items name='«nameMultiple.formatForCode»'}
            {if not $smarty.foreach.«nameMultiple.formatForCode».first},{/if}
            {$item->toJson()}
        {/foreach}
        ]
    '''

    def private jsonDisplay(Entity it, String appName) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display json view *}
        «IF application.targets('1.3.5')»
            {«appName.formatForDB»TemplateHeaders contentType='application/json'}
        «ENDIF»
        {$«objName»->toJson()}
    '''
}
