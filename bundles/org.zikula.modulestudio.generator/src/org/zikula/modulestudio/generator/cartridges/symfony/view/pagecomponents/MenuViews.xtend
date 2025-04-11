package org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

// TODO https://symfony.com/bundles/EasyAdminBundle/current/actions.html#dropdown-and-inline-entity-actions
class MenuViews {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def itemActions(Entity it, String context) '''
        {% set itemActions = knp_menu_get('«application.vendorAndName.toFirstLower»MenuItemActions', [], {entity: «name.formatForCode», area: routeArea, context: '«context»'}) %}
        «markup(context)»
    '''

    def viewActions(Entity it) '''
        {% set viewActions = knp_menu_get('«application.vendorAndName.toFirstLower»MenuViewActions', [], {objectType: '«name.formatForCode»', area: routeArea}) %}
        «application.renderViewActionsMenu»
    '''

    def private markup(Entity it, String context) '''
        <div class="dropdown item-actions">
            <a id="«itemActionContainerViewId»DropDownToggle" role="button" data-toggle="dropdown" href="javascript:void(0);" class="d-none dropdown-toggle"><i class="fas fa-tasks"></i>«IF context == 'detail'» {% trans from 'messages' %}Actions{% endtrans %}«ENDIF»</a>
            «application.renderItemActionsMenu(context)»
        </div>
    '''

    def private renderItemActionsMenu(Application it, String context) '''
        {{ knp_menu_render(itemActions, {template: '@ZikulaTheme/Menu/«/*IF useStyle(context, ItemActionsStyle.ICON)»actions«ELSE*/»bootstrap_fontawesome«/*ENDIF*/».html.twig'}) }}
    '''

    def private renderViewActionsMenu(Application it) '''
        {{ knp_menu_render(viewActions, {template: '@ZikulaTheme/Menu/bootstrap_fontawesome.html.twig'}) }}
    '''

    def itemActionContainerViewId(Entity it) '''
        itemActions{{ «name.formatForCode».getKey() }}'''
}
