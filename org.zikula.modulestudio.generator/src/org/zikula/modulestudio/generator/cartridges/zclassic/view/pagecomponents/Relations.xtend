package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Relations {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def displayItemList(Entity it, Application app, Boolean many, IFileSystemAccess fsa) {
        val templatePath = templateFile('includeDisplayItemList' + (if (many) 'Many' else 'One'))
        if (!app.shouldBeSkipped(templatePath)) {
            fsa.generateFile(templatePath, if (app.targets('1.3.x')) inclusionTemplateLegacy(app, many) else inclusionTemplate(app, many))
        }
    }

    def private inclusionTemplateLegacy(Entity it, Application app, Boolean many) '''
        {* purpose of this template: inclusion template for display of related «nameMultiple.formatForDisplay» *}
        {assign var='lct' value='user'}
        {if isset($smarty.get.lct) && $smarty.get.lct eq 'admin'}
            {assign var='lct' value='admin'}
        {/if}
        {checkpermission component='«app.appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»' assign='hasAdminPermission'}
        «IF ownerPermission»
            {checkpermission component='«app.appName»:«name.formatForCodeCapital»:' instance='::' level='ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»' assign='hasEditPermission'}
        «ENDIF»
        «IF hasActions('display')»
            {if !isset($nolink)}
                {assign var='nolink' value=false}
            {/if}
        «ENDIF»
        «IF !many»
            <h4>
        «ELSE»
            {if isset($items) && $items ne null && count($items) gt 0}
            <ul class="«app.appName.toLowerCase»-related-item-list «name.formatForCode»">
            {foreach name='relLoop' item='item' from=$items}
                {if $hasAdminPermission || $item.workflowState eq 'approved'«IF ownerPermission» || ($item.workflowState eq 'defered' && $hasEditPermission && isset($uid) && $item.createdUserId eq $uid)«ENDIF»}
                <li>
        «ENDIF»
        «IF hasActions('display')»
            {strip}
            {if !$nolink}
                <a href="{modurl modname='«app.appName»' type=$lct func='display' ot='«name.formatForCode»' «routeParamsLegacy('item', true, true)»}" title="{$item->getTitleFromDisplayPattern()|replace:"\"":""}">
            {/if}
        «ENDIF»
            {$item->getTitleFromDisplayPattern()}
        «IF hasActions('display')»
            {if !$nolink}
                </a>
                <a id="«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{$item.«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«app.appName»' type=$lct func='display' ot='«name.formatForCode»' «routeParamsLegacy('item', true, true)» theme='Printer' forcelongurl=true}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
            {/if}
            {/strip}
        «ENDIF»
        «IF !many»</h4>
        «ENDIF»
        «IF hasActions('display')»
            {if !$nolink}
            <script type="text/javascript">
            /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                    «app.vendorAndName»InitInlineWindow($('«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$item.«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$item->getTitleFromDisplayPattern()|replace:"'":""}}');
                });
            /* ]]> */
            </script>
            {/if}
        «ENDIF»
        «IF hasImageFieldsEntity»
            <br />
            «val imageFieldName = getImageFieldsEntity.head.name.formatForCode»
            {if $item.«imageFieldName» ne '' && isset($item.«imageFieldName»FullPath) && $item.«imageFieldName»Meta.isImage}
                {thumb image=$item.«imageFieldName»FullPath objectid="«name.formatForCode»«IF hasCompositeKeys»«FOR pkField : getPrimaryKeyFields»-`$item.«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$item.«primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$relationThumbPreset tag=true img_alt=$item->getTitleFromDisplayPattern()}
            {/if}
        «ENDIF»
        «IF many»
                </li>
                {/if}
            {/foreach}
            </ul>
            {/if}
        «ENDIF»
    '''

    def private inclusionTemplate(Entity it, Application app, Boolean many) '''
        {# purpose of this template: inclusion template for display of related «nameMultiple.formatForDisplay» #}
        {% set hasAdminPermission = hasPermission('«app.appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
        «IF ownerPermission»
            {% set hasEditPermission = hasPermission('«app.appName»:«name.formatForCodeCapital»:', '::', 'ACCESS_«IF workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»') %}
        «ENDIF»
        «IF hasActions('display')»
            {% if nolink is not defined %}
                {% set nolink = false %}
            {% endif %}
        «ENDIF»
        «IF !many»
            <h4>
        «ELSE»
            {% if items|default and items|length > 0 %}
            <ul class="«app.appName.toLowerCase»-related-item-list «name.formatForCode»">
            {% for item in items %}
                {% if hasAdminPermission or item.workflowState == 'approved'«IF ownerPermission» || (item.workflowState == 'defered' and hasEditPermission and uid is defined and item.createdUserId == uid)«ENDIF» %}
                <li>
        «ENDIF»
        «IF hasActions('display')»
            {% spaceless %}
            {% if nolink != true %}
                <a href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routeParams('item', true)») }}" title="{{ item.getTitleFromDisplayPattern()|e('html_attr') }}">
            {% endif %}
        «ENDIF»
            {{ item.getTitleFromDisplayPattern() }}
        «IF hasActions('display')»
            {% if nolink != true %}
                </a>
                <a id="«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{ item.«pkField.name.formatForCode» }}«ENDFOR»Display" href="{{ path('«app.appName.formatForDB»_«name.formatForDB»_' ~ routeArea ~ 'display'«routePkParams('item', true)»«appendSlug('item', true)», 'theme': 'Printer'}) }}" title="{{ __('Open quick view window') }}" class="fa fa-search-plus hidden"></a>
            {% endif %}
            {% endspaceless %}
        «ENDIF»
        «IF !many»</h4>
        «ENDIF»
        «IF hasActions('display')»
            {% if nolink != true %}
            <script type="text/javascript">
            /* <![CDATA[ */
                ( function($) {
                    $(document).ready(function() {
                        «app.vendorAndName»InitInlineWindow($('#«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{ item.«pkField.name.formatForCode» }}«ENDFOR»Display'), '{{ item.getTitleFromDisplayPattern()|e('js') }}');
                    });
                })(jQuery);
            /* ]]> */
            </script>
            {% endif %}
        «ENDIF»
        «IF hasImageFieldsEntity»
            <br />
            «val imageFieldName = getImageFieldsEntity.head.name.formatForCode»
            {% if item.«imageFieldName» != '' and item.«imageFieldName»FullPath is defined and item.«imageFieldName»Meta.isImage %}
                {{ «app.appName.formatForDB»_thumb({ image: item.«imageFieldName»FullPath, objectid: '«name.formatForCode»«FOR pkField : getPrimaryKeyFields»-' ~ item.«pkField.name.formatForCode» ~ '«ENDFOR»', preset: relationThumbPreset, tag: true, img_alt: item.getTitleFromDisplayPattern(), img_class: 'img-rounded' }) }}
            {% endif %}
        «ENDIF»
        «IF many»
                </li>
                {% endif %}
            {% endfor %}
            </ul>
            {% endif %}
        «ENDIF»
    '''

    def displayRelatedItemsLegacy(JoinRelationship it, String appName, Entity relatedEntity) '''
        «val incoming = (if (target == relatedEntity && source != relatedEntity) true else false)»«/* use outgoing mode for self relations #547 */»
        «val useTarget = !incoming»
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode.toFirstLower»
        «val relationAliasNameParam = getRelationAliasName(!useTarget).formatForCode»
        «val otherEntity = (if (!useTarget) source else target) as Entity»
        «val many = isManySideDisplay(useTarget)»
        {if $lct eq 'admin'}
            <h4>{gt text='«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»'}</h4>
        {else}
            <h3>{gt text='«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»'}</h3>
        {/if}

        {if isset($«relatedEntity.name.formatForCode».«relationAliasName») && $«relatedEntity.name.formatForCode».«relationAliasName» ne null}
            {include file='«otherEntity.name.formatForCode»/includeDisplayItemList«IF many»Many«ELSE»One«ENDIF».tpl' item«IF many»s«ENDIF»=$«relatedEntity.name.formatForCode».«relationAliasName»}
        {/if}

        «IF otherEntity.hasActions('edit')»
            «IF !many»
                {if !isset($«relatedEntity.name.formatForCode».«relationAliasName») || $«relatedEntity.name.formatForCode».«relationAliasName» eq null}
            «ENDIF»
            {assign var='permLevel' value='ACCESS_«IF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»'}
            {if $lct eq 'admin'}
                {assign var='permLevel' value='ACCESS_ADMIN'}
            {/if}
            {checkpermission component='«appName»:«relatedEntity.name.formatForCodeCapital»:' instance='«relatedEntity.idFieldsAsParameterTemplate»::' level=$permLevel assign='mayManage'}
            {if $mayManage || (isset($uid) && isset($«relatedEntity.name.formatForCode».createdUserId) && $«relatedEntity.name.formatForCode».createdUserId eq $uid)}
            <p class="managelink">
                {gt text='Create «otherEntity.name.formatForDisplay»' assign='createTitle'}
                <a href="{modurl modname='«appName»' type=$lct func='edit' ot='«otherEntity.name.formatForCode»' «relationAliasNameParam»="«relatedEntity.idFieldsAsParameterTemplate»" returnTo="`$lct`Display«relatedEntity.name.formatForCodeCapital»"'}" title="{$createTitle}" class="z-icon-es-add">{$createTitle}</a>
            </p>
            {/if}
            «IF !many»
                {/if}
            «ENDIF»
        «ENDIF»
    '''

    def displayRelatedItems(JoinRelationship it, String appName, Entity relatedEntity) '''
        «val incoming = (if (target == relatedEntity && source != relatedEntity) true else false)»«/* use outgoing mode for self relations #547 */»
        «val useTarget = !incoming»
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode.toFirstLower»
        «val relationAliasNameParam = getRelationAliasName(!useTarget).formatForCode»
        «val otherEntity = (if (!useTarget) source else target) as Entity»
        «val many = isManySideDisplay(useTarget)»
        {% if routeArea == 'admin' %}
            <h4>{{ __('«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»') }}</h4>
        {% else %}
            <h3>{{ __('«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»') }}</h3>
        {% endif %}

        {% if «relatedEntity.name.formatForCode».«relationAliasName»|default %}
            {{ include(
                '@«application.appName»/«otherEntity.name.formatForCodeCapital»/includeDisplayItemList«IF many»Many«ELSE»One«ENDIF».html.twig',
                { 'item«IF many»s«ENDIF»': «relatedEntity.name.formatForCode».«relationAliasName»}
            ) }}
        {% endif %}

        «IF otherEntity.hasActions('edit')»
            «IF !many»
                {% if «relatedEntity.name.formatForCode».«relationAliasName» is not defined or «relatedEntity.name.formatForCode».«relationAliasName» == null %}
            «ENDIF»
            {% set permLevel = 'ACCESS_«IF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»' %}
            {% if routeArea == 'admin' %}
                {% set permLevel = 'ACCESS_ADMIN' %}
            {% endif %}
            {% set mayManage = hasPermission('«appName»:«relatedEntity.name.formatForCodeCapital»:', «relatedEntity.idFieldsAsParameterTemplate» ~ '::', permLevel) %}
            {% if mayManage or (uid is defined and «relatedEntity.name.formatForCode».createdUserId is defined and «relatedEntity.name.formatForCode».createdUserId == uid) %}
            <p class="managelink">
                {% set createTitle = __('Create «otherEntity.name.formatForDisplay»') %}
                <a href="{{ path('«appName.formatForDB»_«otherEntity.name.formatForDB»_' ~ routeArea ~ 'edit', { '«relationAliasNameParam»': «relatedEntity.idFieldsAsParameterTemplate», 'returnTo': area|lower ~ 'Display«relatedEntity.name.formatForCodeCapital»'}) }}" title="{{ createTitle }}" class="fa fa-plus">{{ createTitle }}</a>
            </p>
            {% endif %}
            «IF !many»
                {% endif %}
            «ENDIF»
        «ENDIF»
    '''
}
