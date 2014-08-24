package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockModerationView {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getViewPath + (if (targets('1.3.5')) 'block' else 'Block') + '/'
        var fileName = 'moderation.tpl'
        if (!shouldBeSkipped(templatePath + fileName)) {
            if (shouldBeMarked(templatePath + fileName)) {
                fileName = 'moderation.generated.tpl'
            }
            fsa.generateFile(templatePath + fileName, displayTemplate)
        }
    }

    def private displayTemplate(Application it) '''
        {* Purpose of this template: show moderation block *}
        {if count($moderationObjects) gt 0}
            <ul>
            {foreach item='modItem' from=$moderationObjects}
                «IF targets('1.3.5')»
                    <li><a href="{modurl modname='«appName»' type='admin' func='view' ot=$modItem.objectType workflowState=$modItem.state}" class="z-bold">{$modItem.message}</a></li>
                «ELSE»
                    <li><a href="{route name="«appName.formatForDB»_`$modItem.objectType`_view" lct='admin' workflowState=$modItem.state}" class="bold">{$modItem.message}</a></li>
                «ENDIF»
            {/foreach}
            </ul>
        {/if}
    '''
}
