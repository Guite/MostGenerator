package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockModerationView {
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

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
                <li><a href="{modurl modname='«appName»' type='admin' func='view' ot=$modItem.objectType workflowState=$modItem.state}" class="«IF targets('1.3.5')»z-«ENDIF»bold">{$modItem.message}</a></li>
            {/foreach}
            </ul>
        {/if}
    '''
}
