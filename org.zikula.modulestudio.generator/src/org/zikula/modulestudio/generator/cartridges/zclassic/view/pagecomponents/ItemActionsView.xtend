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
        {if count($«name.formatForCode»._actions) gt 0}
            «markup(context)»

            «javaScript(context)»
        {/if}
    '''

    def private markup(Entity it, String context) '''
        «IF application.targets('1.3.5')»
            «IF context == 'display'»
                <p id="«itemActionContainerViewId»">
                    «linkList(context)»
                </p>
            «ELSEIF context == 'view'»
                «trigger(context)»
                «linkList(context)»
            «ENDIF»
        «ELSE»
            «IF context == 'view'»
                «trigger(context)»
            «ENDIF»
            <div class="dropdown">
                <ul class="dropdown-menu" role="menu" aria-labelledby="«itemActionContainerViewId»DropDownToggle">
                    «linkList(context)»
                </ul>
            </div>
        «ENDIF»
    '''

    def private linkList(Entity it, String context) '''
        {foreach item='option' from=$«name.formatForCode»._actions}
            «linkEntry(context)»
        {/foreach}
    '''

    def private linkEntry(Entity it, String context) '''
        «IF application.targets('1.3.5')»
            «IF context == 'display'»
                <a «linkEntryCommonAttributes» class="z-icon-es-{$option.icon}">{$option.linkText|safetext}</a>
            «ELSEIF context == 'view'»
                <a «linkEntryCommonAttributes»{if $option.icon eq 'preview'} target="_blank"{/if}>{icon type=$option.icon size='extrasmall' alt=$option.linkText|safetext}</a>
            «ENDIF»
        «ELSE»
            <li role="presentation"><a «linkEntryCommonAttributes» role="menuitem" tabindex="-1" class="fa fa-{$option.icon}">{$option.linkText|safetext}</a></li>
«/*
    <li role="presentation" class="dropdown-header">Dropdown group heading</li>
    <li role="presentation" class="disabled"><a role="menuitem" tabindex="-1" href="#">Disabled link</a></li>
    <li role="presentation" class="divider"></li>
*/»
        «ENDIF»
    '''

    def private linkEntryCommonAttributes(Entity it) '''href="{$option.url.type|«application.appName.formatForDB»ActionUrl:$option.url.func:$option.url.arguments}" title="{$option.linkTitle|safetext}"'''

    def private javaScript(Entity it, String context) '''
        <script type="text/javascript">
        /* <![CDATA[ */
            «IF application.targets('1.3.5')»
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
    '''

    def trigger(Entity it, String context) '''
        «IF application.targets('1.3.5')»
            {icon id="«itemActionContainerViewIdForSmarty»Trigger" type='options' size='extrasmall' __alt='Actions' class='z-pointer z-hide'}
        «ELSE»
            <a id="«itemActionContainerViewId»DropDownToggle" role="button" data-toggle="dropdown" data-target="#" href="javascript:void(0);" class="dropdown-toggle"><i class="fa fa-tasks"></i>«IF context == 'display'» {gt text='Actions'}«ENDIF» <span class="caret"></span></a>
«/*            <button id="«itemActionContainerViewId»DropDownToggle" class="btn btn-default dropdown-toggle" type="button" data-toggle="dropdown"><i class="fa fa-tasks"></i>«IF context == 'display'» {gt text='Actions'}«ENDIF» <span class="caret"></span></button>*/»
        «ENDIF»
    '''

    def itemActionContainerViewId(Entity it) '''
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{$«name.formatForCode».«pkField.name.formatForCode»}«ENDFOR»'''

    def private itemActionContainerViewIdForJs(Entity it) '''
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$«name.formatForCode».«pkField.name.formatForCode»}}«ENDFOR»'''

    def private itemActionContainerViewIdForSmarty(Entity it) '''
        itemActions«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»'''
}
