package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ItemActionsStyle
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemActionsView {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Entity it, String context, String idSuffix) '''
        {% set itemActions = knp_menu_get('«application.vendorAndName.toFirstLower»MenuItemActions', [], {entity: «name.formatForCode», area: routeArea, context: '«context»'}) %}
        «markup(context, idSuffix)»
    '''

    def private markup(Entity it, String context, String idSuffix) '''
        «IF application.useStyle(context, ItemActionsStyle.BUTTON_GROUP)»
            <div class="btn-group«IF context == 'view'»-vertical«ENDIF» btn-group-sm item-actions" role="group" aria-label="{{ __('Actions') }}">
                «application.renderMenu(context)»
            </div>
        «ELSEIF application.useStyle(context, ItemActionsStyle.DROPDOWN)»
            <div class="dropdown item-actions">
                <a id="«itemActionContainerViewId»DropDownToggle«idSuffix»" role="button" data-toggle="dropdown" href="javascript:void(0);" class="hidden dropdown-toggle"><i class="fa fa-tasks"></i>«IF context == 'display'» {{ __('Actions') }}«ENDIF» <span class="caret"></span></a>
                «application.renderMenu(context)»
            </div>
        «ELSE»
            «application.renderMenu(context)»
        «ENDIF»
    '''

    def private renderMenu(Application it, String context) '''
        «IF targets('3.0')»
            {{ knp_menu_render(itemActions, {template: '@ZikulaMenuModule/Override/«IF useStyle(context, ItemActionsStyle.ICON)»actions«ELSE»bootstrap_fontawesome«ENDIF».html.twig'}) }}
        «ELSE»
            {{ knp_menu_render(itemActions, {template: 'ZikulaMenuModule:Override:«IF useStyle(context, ItemActionsStyle.ICON)»actions«ELSE»bootstrap_fontawesome«ENDIF».html.twig'}) }}
        «ENDIF»
    '''

    def private useStyle(Application it, String context, ItemActionsStyle style) {
        (context == 'view' && viewActionsStyle == style) || (context == 'display' && displayActionsStyle == style)
    }

    def itemActionContainerViewId(Entity it) '''
        itemActions{{ «name.formatForCode».getKey() }}'''
}
