package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Index {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app

    def generate(Entity it, IFileSystemAccess fsa) {
        /*if (hasActions('view')) {
            return
        }*/
        app = application
        val pageName = (if (app.targets('1.3.5')) 'main' else 'index')
        println('Generating ' + pageName + ' templates for entity "' + name.formatForDisplay + '"')
        val app = application
        val templatePath = app.getViewPath + (if (app.targets('1.3.5')) name.formatForCode else name.formatForCodeCapital) + '/'
        var fileName = pageName + '.tpl'
        if (!app.shouldBeSkipped(templatePath + fileName)) {
            if (app.shouldBeMarked(templatePath + fileName)) {
                fileName = pageName + '.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, indexView(pageName))
        }
    }

    def private indexView(Entity it, String pageName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» «pageName» view *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        «IF application.targets('1.3.5')»
            {include file="`$lct`/header.tpl"}
        «ELSE»
            {assign var='lctUc' value=$lct|ucfirst}
            {include file="`$lctUc`/header.tpl"}
        «ENDIF»
        <p>{gt text='Welcome to the «name.formatForDisplay» section of the «app.name.formatForDisplayCapital» application.'}</p>
        «IF application.targets('1.3.5')»
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {include file="`$lctUc`/footer.tpl"}
        «ENDIF»
    '''
}
