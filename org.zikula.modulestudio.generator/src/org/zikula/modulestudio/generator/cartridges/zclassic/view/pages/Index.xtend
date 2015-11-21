package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
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
        val pageName = (if (app.targets('1.3.x')) 'main' else 'index')
        println('Generating ' + pageName + ' templates for entity "' + name.formatForDisplay + '"')
        val app = application
        val templatePath = app.getViewPath + (if (app.targets('1.3.x')) name.formatForCode else name.formatForCodeCapital) + '/'
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
        «IF app.targets('1.3.x')»
            {assign var='lct' value='user'}
            {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
                {assign var='lct' value='admin'}
            {/if}
            {include file="`$lct`/header.tpl"}
        «ELSE»
            {assign var='area' value='User'}
            {if $routeArea eq 'admin'}
                {assign var='area' value='Admin'}
            {/if}
            {include file="`$area`/header.tpl"}
        «ENDIF»
        <p>{gt text='Welcome to the «name.formatForDisplay» section of the «app.name.formatForDisplayCapital» application.'}</p>
        «IF app.targets('1.3.x')»
            {include file="`$lct`/footer.tpl"}
        «ELSE»
            {include file="`$area`/footer.tpl"}
        «ENDIF»
    '''
}
