package org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.ViewExtensions

class Relations {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension UrlExtensions = new UrlExtensions()
    @Inject extension Utils = new Utils()
    @Inject extension ViewExtensions = new ViewExtensions()

    def displayItemList(Entity it, Application app, Controller controller, Boolean many, IFileSystemAccess fsa) {
        fsa.generateFile(templateFile(controller, name, 'include_displayItemList' + (if (many) 'Many' else 'One')), '''
            {* purpose of this template: inclusion template for display of related «nameMultiple.formatForDisplayCapital» in «controller.formattedName» area *}

            «IF !many»
                <h4>
            «ELSE»
                {if isset($items) && $items ne null}
                <ul class="relatedItemList «name.formatForCodeCapital»">
                {foreach name='relLoop' item='item' from=$items}
                    <li>
            «ENDIF»
            <a href="{modurl modname='«app.appName»' type='«controller.formattedName»' «modUrlDisplay('item', true)»}">
            «val leadingField = getLeadingField»
            «IF leadingField != null»
                {$item.«leadingField.name.formatForCode»}
            «ELSE»
                {gt text='«name.formatForDisplayCapital»'}
            «ENDIF»
            </a>
            <a id="«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{$item.«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«app.appName»' type='«controller.formattedName»' «modUrlDisplay('item', true)» theme='Printer'«controller.additionalUrlParametersForQuickViewLink»}" title="{gt text='Open quick view window'}" style="display: none">
                {icon type='view' size='extrasmall' __alt='Quick view'}
            </a>
            «IF !many»</h4>
            «ENDIF»
            <script type="text/javascript" charset="utf-8">
            /* <![CDATA[ */
                document.observe('dom:loaded', function() {
                    «IF leadingField != null»
                        «app.prefix»InitInlineWindow($('«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$item.«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{$item.«leadingField.name.formatForCode»|replace:"'":""}}');
                    «ELSE»
                         «app.prefix»InitInlineWindow($('«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{{$item.«pkField.name.formatForCode»}}«ENDFOR»Display'), '{{gt text='«name.formatForDisplayCapital»'|replace:"'":""}}');
                    «ENDIF»
                });
            /* ]]> */
            </script>
            «IF hasImageFieldsEntity»
                <br />
                «val imageFieldName = getImageFieldsEntity.head.name.formatForCode»
                {if $item.«imageFieldName» ne '' && isset($item.«imageFieldName»FullPathURL)}
                    «IF leadingField != null»
                        <img src="{$item.«imageFieldName»|«app.appName.formatForDB»ImageThumb:$item.«imageFieldName»FullPathURL:50:40}" width="50" height="40" alt="{$item.«leadingField.name.formatForCode»|replace:"\"":""}" />
                    «ELSE»
                        <img src="{$item.«imageFieldName»|«app.appName.formatForDB»ImageThumb:$item.«imageFieldName»FullPathURL:50:40}" width="50" height="40" alt="{gt text='«name.formatForDisplayCapital»'|replace:"\"":""}" />
                    «ENDIF»
                {/if}
            «ENDIF»
            «IF many»
                    </li>
                {/foreach}
                </ul>
                {/if}
            «ENDIF»
        ''')
    }

    def displayRelatedItems(JoinRelationship it, String appName, Controller controller, Entity relatedEntity) '''
        «val incoming = (if (target == relatedEntity) true else false)»
        «val useTarget = !incoming»
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode.toFirstLower»
        «val relationAliasNameParam = getRelationAliasName(!useTarget).formatForCodeCapital»
        «val otherEntity = (if (!useTarget) source else target)»
        «val many = isManySideDisplay(useTarget)»
        <h3>{gt text='«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»'}</h3>

        {if isset($«relatedEntity.name.formatForCode».«relationAliasName») && $«relatedEntity.name.formatForCode».«relationAliasName» ne null}
            {include file='«controller.formattedName»/«otherEntity.name.formatForCode»/include_displayItemList«IF many»Many«ELSE»One«ENDIF».tpl' item«IF many»s«ENDIF»=$«relatedEntity.name.formatForCode».«relationAliasName»}
        {/if}

        «IF !many»
            {if !isset($«relatedEntity.name.formatForCode».«relationAliasName») || $«relatedEntity.name.formatForCode».«relationAliasName» eq null}
        «ENDIF»
        {checkpermission component='«appName»::' instance='.*' level='ACCESS_ADMIN' assign='authAdmin'}
        {if $authAdmin || (isset($uid) && isset($«relatedEntity.name.formatForCode».createdUserId) && $«relatedEntity.name.formatForCode».createdUserId eq $uid)}
        <p class="manageLink">
            {gt text='Create «otherEntity.name.formatForDisplay»' assign='createTitle'}
            <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='edit' ot='«otherEntity.name.formatForCode»' «relationAliasNameParam.formatForDB»="«FOR pkField : relatedEntity.getPrimaryKeyFields SEPARATOR '_'»`$«relatedEntity.name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»" returnTo='«controller.formattedName»Display«relatedEntity.name.formatForCodeCapital»'}" title="{$createTitle}" class="z-icon-es-add">
                {$createTitle}
            </a>
        </p>
        {/if}
        «IF !many»
            {/if}
        «ENDIF»
    '''
}
