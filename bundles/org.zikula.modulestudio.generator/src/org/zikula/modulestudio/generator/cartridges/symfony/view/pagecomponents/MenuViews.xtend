package org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ItemActionsStyle
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MenuViews {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def itemActions(Entity it, String context, String idSuffix) '''
        {% set itemActions = knp_menu_get('«application.vendorAndName.toFirstLower»MenuItemActions', [], {entity: «name.formatForCode», area: routeArea, context: '«context»'}) %}
        «markup(context, idSuffix)»
    '''

    def viewActions(Entity it) '''
        {% set viewActions = knp_menu_get('«application.vendorAndName.toFirstLower»MenuViewActions', [], {objectType: '«name.formatForCode»', area: routeArea}) %}
        «application.renderViewActionsMenu»
    '''

    def private markup(Entity it, String context, String idSuffix) '''
        «IF application.useStyle(context, ItemActionsStyle.BUTTON_GROUP)»
            <div class="btn-group«IF context == 'index'»-vertical«ENDIF» btn-group-sm item-actions" role="group" aria-label="{% trans from 'messages' %}Actions{% endtrans %}">
                «application.renderItemActionsMenu(context)»
            </div>
        «ELSEIF application.useStyle(context, ItemActionsStyle.DROPDOWN)»
            <div class="dropdown item-actions">
                <a id="«itemActionContainerViewId»DropDownToggle«idSuffix»" role="button" data-toggle="dropdown" href="javascript:void(0);" class="d-none dropdown-toggle"><i class="fas fa-tasks"></i>«IF context == 'detail'» {% trans from 'messages' %}Actions{% endtrans %}«ENDIF»</a>
                «application.renderItemActionsMenu(context)»
            </div>
        «ELSE»
            «application.renderItemActionsMenu(context)»
        «ENDIF»
    '''

    def private renderItemActionsMenu(Application it, String context) '''
        {{ knp_menu_render(itemActions, {template: '@ZikulaTheme/Menu/«IF useStyle(context, ItemActionsStyle.ICON)»actions«ELSE»bootstrap_fontawesome«ENDIF».html.twig'}) }}
    '''

    def private renderViewActionsMenu(Application it) '''
        {{ knp_menu_render(viewActions, {template: '@ZikulaTheme/Menu/bootstrap_fontawesome.html.twig'}) }}
    '''

    def private useStyle(Application it, String context, ItemActionsStyle style) {
        (context == 'index' && indexActionsStyle == style) || (context == 'detail' && detailActionsStyle == style)
    }

    def itemActionContainerViewId(Entity it) '''
        itemActions{{ «name.formatForCode».getKey() }}'''
}
