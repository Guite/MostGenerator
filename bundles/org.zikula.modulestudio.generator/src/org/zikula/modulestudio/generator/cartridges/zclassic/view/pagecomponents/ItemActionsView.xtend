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
            «IF application.targets('1.3.x')»
                {if count($«name.formatForCode»._actions) gt 0}
                    «markup('view')»
                    «IF application.targets('1.3.x')»
                        «javaScript('view')»
                    «ENDIF»
                {/if}
            «ELSE»
                {% set actionLinks = «application.appName.toLowerCase»_actions(entity=«name.formatForCode», area=routeArea, context='view') %}
                {% if actionLinks|length > 0 %}
                    «markup('view')»
                {% endif %}
            «ENDIF»
        «ELSEIF subject == 'javascript'»
            «javaScript('view')»
        «ENDIF»
    '''

    def generateDisplay(Entity it) '''
        «IF application.targets('1.3.x')»
            {if count($«name.formatForCode»._actions) gt 0}
                «markup('display')»
                «javaScript('display')»
            {/if}
        «ELSE»
            {% set actionLinks = «application.appName.toLowerCase»_actions(entity=«name.formatForCode», area=routeArea, context='display') %}
            {% if actionLinks|length > 0 %}
                «markup('display')»
                «javaScript('display')»
            {% endif %}
        «ENDIF»
    '''

    def private markup(Entity it, String context) '''
        «IF application.targets('1.3.x')»
            «IF context == 'display'»
                <p id="«itemActionContainerViewId»">
                    «linkList(context)»
                </p>
            «ELSEIF context == 'view'»
                «trigger(context)»
                «linkList(context)»
            «ENDIF»
        «ELSE»
            <div class="dropdown">
                «trigger(context)»
                <ul class="dropdown-menu«IF context == 'view'» dropdown-menu-right«ENDIF»" role="menu" aria-labelledby="«itemActionContainerViewId»DropDownToggle">
                    «linkList(context)»
                </ul>
            </div>
        «ENDIF»
    '''

    def private linkList(Entity it, String context) '''
        «IF application.targets('1.3.x')»
            {foreach item='option' from=$«name.formatForCode»._actions}
                «linkEntry(context)»
            {/foreach}
        «ELSE»
            {% for option in actionLinks %}
                «linkEntry(context)»
            {% endfor %}
        «ENDIF»
    '''

    def private linkEntry(Entity it, String context) '''
        «IF application.targets('1.3.x')»
            «IF context == 'display'»
                <a «linkEntryCommonAttributesLegacy» class="z-icon-es-{$option.icon}">{$option.linkText|safetext}</a>
            «ELSEIF context == 'view'»
                <a «linkEntryCommonAttributesLegacy»{if $option.icon eq 'preview'} target="_blank"{/if}>{icon type=$option.icon size='extrasmall' alt=$option.linkText|safetext}</a>
            «ENDIF»
        «ELSE»
            <li role="presentation"><a «linkEntryCommonAttributes» role="menuitem" tabindex="-1" class="fa fa-{{ option.icon }}">{{ option.linkText }}</a></li>
«/*
    <li role="presentation" class="dropdown-header">Dropdown group heading</li>
    <li role="presentation" class="disabled"><a role="menuitem" tabindex="-1" href="#">Disabled link</a></li>
    <li role="presentation" class="divider"></li>
*/»
        «ENDIF»
    '''

    def private linkEntryCommonAttributesLegacy(Entity it) '''href="{$option.url.type|«application.appName.formatForDB»ActionUrl:$option.url.func:$option.url.arguments}" title="{$option.linkTitle|safetext}"'''

    def private linkEntryCommonAttributes(Entity it) '''href="{{ option.url }}" title="{{ option.linkTitle|e('html_attr') }}"'''

    def private javaScript(Entity it, String context) '''
        «IF !application.targets('1.3.x') && context == 'view'»
            $('.dropdown-toggle').dropdown();
            $('a.fa-zoom-in').attr('target', '_blank');
        «ELSE»
            <script type="text/javascript">
            /* <![CDATA[ */
                «IF application.targets('1.3.x')»
                    document.observe('dom:loaded', function() {
                        «application.vendorAndName»InitItemActions('«name.formatForCode»', '«context»', '«itemActionContainerViewIdForJs»');
                    });
                «ELSE»
                    ( function($) {
                        $(document).ready(function() {
                            $('.dropdown-toggle').dropdown();
                            $('a.fa-zoom-in').attr('target', '_blank');
                        });
                    })(jQuery);
                «ENDIF»
            /* ]]> */
            </script>
        «ENDIF»
    '''

    def trigger(Entity it, String context) '''
        «IF application.targets('1.3.x')»
            {icon id="«itemActionContainerViewIdForSmarty»Trigger" type='options' size='extrasmall' __alt='Actions' class='z-pointer z-hide'}
        «ELSE»
            <a id="«itemActionContainerViewId»DropDownToggle" role="button" data-toggle="dropdown" data-target="#" href="javascript:void(0);" class="dropdown-toggle"><i class="fa fa-tasks"></i>«IF context == 'display'» {{ __('Actions') }}«ENDIF» <span class="caret"></span></a>
«/*            <button id="«itemActionContainerViewId»DropDownToggle" class="btn btn-default dropdown-toggle" type="button" data-toggle="dropdown"><i class="fa fa-tasks"></i>«IF context == 'display'» {{ __('Actions') }}«ENDIF» <span class="caret"></span></button>*/»
        «ENDIF»
    '''

    def itemActionContainerViewId(Entity it) '''
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»«IF application.targets('1.3.x')»{$«name.formatForCode».«pkField.name.formatForCode»}«ELSE»{{ «name.formatForCode».«pkField.name.formatForCode» }}«ENDIF»«ENDFOR»'''

    // 1.3.x only
    def private itemActionContainerViewIdForJs(Entity it) '''
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$«name.formatForCode».«pkField.name.formatForCode»}}«ENDFOR»'''

    // 1.3.x only
    def private itemActionContainerViewIdForSmarty(Entity it) '''
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»'''
}
