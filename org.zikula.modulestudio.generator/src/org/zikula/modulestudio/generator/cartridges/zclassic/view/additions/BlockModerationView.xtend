package org.zikula.modulestudio.generator.cartridges.zclassic.view.additions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockModerationView {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        val templatePath = getAppSourcePath + 'templates/block/'
        fsa.generateFile(templatePath + 'moderation.tpl', displayTemplate)
    }

    def private displayTemplate(Application it) '''
        {* Purpose of this template: show moderation block *}
        {if count($moderationObjects) gt 0}
            <ul>
            {foreach item='modItem' from=$moderationObjects}
                <li><a href="{modurl modname='«appName»' type='admin' func='view' ot=$modItem.objectType workflowState=$modItem.state}" class="z-bold">{$modItem.message}</a></li>
            {/foreach}
            </ul>
        {/if}
    '''
}
