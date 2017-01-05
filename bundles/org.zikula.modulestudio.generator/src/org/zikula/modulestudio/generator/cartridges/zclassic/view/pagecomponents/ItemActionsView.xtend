package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemActionsView {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Entity it, String context) '''
        {% set itemActions = knp_menu_get('«application.appName»:ItemActionsMenu:menu', [], { entity: «name.formatForCode», area: routeArea, context: '«context»' }) %}
        «markup(context)»
    '''

    def private markup(Entity it, String context) '''
        <div class="dropdown">
            <a id="«itemActionContainerViewId»DropDownToggle" role="button" data-toggle="dropdown" data-target="#" href="javascript:void(0);" class="hidden dropdown-toggle"><i class="fa fa-tasks"></i>«IF context == 'display'» {{ __('Actions') }}«ENDIF» <span class="caret"></span></a>
            {{ knp_menu_render(itemActions, { template: 'ZikulaMenuModule:Override:actions.html.twig' }) }}
        </div>
    '''

    def itemActionContainerViewId(Entity it) '''
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{ «name.formatForCode».«pkField.name.formatForCode» }}«ENDFOR»'''
}
