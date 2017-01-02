package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ItemActionsView {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generateView(Entity it, String subject) '''
        «IF subject == 'markup'»
            {% set itemActions = knp_menu_get('«application.appName»:ItemActionsMenu:menu', [], { entity: «name.formatForCode», area: routeArea, context: 'view' }) %}
            «markup('view')»
        «ELSEIF subject == 'javascript'»
            «javaScript('view')»
        «ENDIF»
    '''

    def generateDisplay(Entity it) '''
        {% set itemActions = knp_menu_get('«application.appName»:ItemActionsMenu:menu', [], { entity: «name.formatForCode», area: routeArea, context: 'display' }) %}
        «markup('display')»
        «javaScript('display')»
    '''

    def private markup(Entity it, String context) '''
        <div class="dropdown">
            «trigger(context)»
            {{ knp_menu_render(itemActions, { template: 'ZikulaMenuModule:Override:actions.html.twig' }) }}
        </div>
    '''

    def private javaScript(Entity it, String context) '''
        «IF context == 'view'»
            $('.«application.appName.toLowerCase»-«name.formatForDB» .dropdown > ul').removeClass('list-inline').addClass('list-unstyled dropdown-menu dropdown-menu-right');
            $('.«application.appName.toLowerCase»-«name.formatForDB» .dropdown > ul a').each(function (index) {
                $(this).html($(this).html() + $(this).find('i').first().data('original-title'));
            });
            $('.«application.appName.toLowerCase»-«name.formatForDB» .dropdown > ul a i').addClass('fa-fw');
            $('.«application.appName.toLowerCase»-«name.formatForDB» .dropdown-toggle').removeClass('hidden').dropdown();
        «ELSE»
            <script type="text/javascript">
            /* <![CDATA[ */
                ( function($) {
                    $(document).ready(function() {
                        $('h2 .dropdown > ul, h3 .dropdown > ul').removeClass('list-inline').addClass('list-unstyled dropdown-menu');
                        $('h2 .dropdown > ul a, h3 .dropdown > ul a').each(function (index) {
                            $(this).html($(this).html() + $(this).find('i').first().data('original-title'));
                        });
                        $('h2 .dropdown > ul a i, h3 .dropdown > ul a i').addClass('fa-fw');
                        $('h2 .dropdown-toggle, h3 .dropdown-toggle').removeClass('hidden').dropdown();
                    });
                })(jQuery);
            /* ]]> */
            </script>
        «ENDIF»
    '''

    def trigger(Entity it, String context) '''
        <a id="«itemActionContainerViewId»DropDownToggle" role="button" data-toggle="dropdown" data-target="#" href="javascript:void(0);" class="hidden dropdown-toggle"><i class="fa fa-tasks"></i>«IF context == 'display'» {{ __('Actions') }}«ENDIF» <span class="caret"></span></a>
«/*        <button id="«itemActionContainerViewId»DropDownToggle" class="btn btn-default dropdown-toggle" type="button" data-toggle="dropdown"><i class="fa fa-tasks"></i>«IF context == 'display'» {{ __('Actions') }}«ENDIF» <span class="caret"></span></button>*/»
    '''

    def itemActionContainerViewId(Entity it) '''
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{ «name.formatForCode».«pkField.name.formatForCode» }}«ENDFOR»'''
}
