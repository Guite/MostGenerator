package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

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
            <div class="btn-group«IF context == 'view'»-vertical«ENDIF» btn-group-sm item-actions" role="group" aria-label="«IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Actions{% endtrans %}«ELSE»{{ __('Actions') }}«ENDIF»">
                «application.renderItemActionsMenu(context)»
            </div>
        «ELSEIF application.useStyle(context, ItemActionsStyle.DROPDOWN)»
            <div class="dropdown item-actions">
                <a id="«itemActionContainerViewId»DropDownToggle«idSuffix»" role="button" data-toggle="dropdown" href="javascript:void(0);" class="«IF application.targets('3.0')»d-none«ELSE»hidden«ENDIF» dropdown-toggle"><i class="fa«IF application.targets('3.0')»s«ENDIF» fa-tasks"></i>«IF context == 'display'» «IF application.targets('3.0')»{% trans«IF !application.isSystemModule» from 'messages'«ENDIF» %}Actions{% endtrans %}«ELSE»{{ __('Actions') }}«ENDIF»«ENDIF»«IF !application.targets('3.0')» <span class="caret"></span>«ENDIF»</a>
                «application.renderItemActionsMenu(context)»
            </div>
        «ELSE»
            «application.renderItemActionsMenu(context)»
        «ENDIF»
    '''

    def private renderItemActionsMenu(Application it, String context) '''
        «IF targets('3.0')»
            {{ knp_menu_render(itemActions, {template: '@ZikulaMenuModule/Override/«IF useStyle(context, ItemActionsStyle.ICON)»actions«ELSE»bootstrap_fontawesome«ENDIF».html.twig'}) }}
        «ELSE»
            {{ knp_menu_render(itemActions, {template: 'ZikulaMenuModule:Override:«IF useStyle(context, ItemActionsStyle.ICON)»actions«ELSE»bootstrap_fontawesome«ENDIF».html.twig'}) }}
        «ENDIF»
    '''

    def private renderViewActionsMenu(Application it) '''
        «IF targets('3.0')»
            {{ knp_menu_render(viewActions, {template: '@ZikulaMenuModule/Override/bootstrap_fontawesome.html.twig'}) }}
        «ELSE»
            {{ knp_menu_render(viewActions, {template: 'ZikulaMenuModule:Override:bootstrap_fontawesome.html.twig'}) }}
        «ENDIF»
    '''

    def private useStyle(Application it, String context, ItemActionsStyle style) {
        (context == 'view' && viewActionsStyle == style) || (context == 'display' && displayActionsStyle == style)
    }

    def itemActionContainerViewId(Entity it) '''
        itemActions{{ «name.formatForCode».getKey() }}'''
}
