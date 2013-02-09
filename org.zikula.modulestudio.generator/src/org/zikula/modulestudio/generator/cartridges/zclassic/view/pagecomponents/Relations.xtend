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
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.TimeField

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
            {* purpose of this template: inclusion template for display of related «nameMultiple.formatForDisplay» in «controller.formattedName» area *}
            «IF controller.hasActions('display')»
                {if !isset($nolink)}
                    {assign var='nolink' value=false}
                {/if}
            «ENDIF»
            «IF !many»
                <h4>
            «ELSE»
                {if isset($items) && $items ne null && count($items) gt 0}
                <ul class="relatedItemList «name.formatForCode»">
                {foreach name='relLoop' item='item' from=$items}
                    <li>
            «ENDIF»
            «IF controller.hasActions('display')»
                {strip}
                {if !$nolink}
                    <a href="{modurl modname='«app.appName»' type='«controller.formattedName»' «modUrlDisplay('item', true)»}" title="{$item.«leadingField.displayLeadingField»|replace:"\"":""}">
                {/if}
            «ENDIF»
            «val leadingField = getLeadingField»
            «IF leadingField != null»
                {$item.«leadingField.displayLeadingField»}
            «ELSE»
                {gt text='«name.formatForDisplayCapital»'}
            «ENDIF»
            «IF controller.hasActions('display')»
                {if !$nolink}
                    </a>
                    <a id="«name.formatForCode»Item«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»{$item.«pkField.name.formatForCode»}«ENDFOR»Display" href="{modurl modname='«app.appName»' type='«controller.formattedName»' «modUrlDisplay('item', true)» theme='Printer'«controller.additionalUrlParametersForQuickViewLink»}" title="{gt text='Open quick view window'}" class="z-hide">{icon type='view' size='extrasmall' __alt='Quick view'}</a>
                {/if}
                {/strip}
            «ENDIF»
            «IF !many»</h4>
            «ENDIF»
            «IF controller.hasActions('display')»
                {if !$nolink}
                <script type="text/javascript">
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
                {/if}
            «ENDIF»
            «IF hasImageFieldsEntity»
                <br />
                «val imageFieldName = getImageFieldsEntity.head.name.formatForCode»
                {if $item.«imageFieldName» ne '' && isset($item.«imageFieldName»FullPath) && $item.«imageFieldName»Meta.isImage}
                    {thumb image=$item.«imageFieldName»FullPath objectid="«name.formatForCode»«IF hasCompositeKeys»«FOR pkField : getPrimaryKeyFields»-`$item.«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$item.«primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$relationThumbPreset tag=true «IF leadingField != null»img_alt=$item.«leadingField.name.formatForCode»«ELSE»__img_alt='«name.formatForDisplayCapital»'«ENDIF»}
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

    def private displayLeadingField(DerivedField it) {
        switch (it) {
            ListField: '''«it.name.formatForCode»|«entity.container.application.appName.formatForDB»GetListEntry:'«entity.name.formatForCode»':'«name.formatForCode»'|safetext'''
            DateField: '''«it.name.formatForCode»|dateformat:"datebrief"'''
            DatetimeField: '''«it.name.formatForCode»|dateformat:"datetimebrief"'''
            TimeField: '''«it.name.formatForCode»|dateformat:"timebrief"'''
            default: '''«it.name.formatForCode»'''
        }
    }

    def displayRelatedItems(JoinRelationship it, String appName, Controller controller, Entity relatedEntity) '''
        «val incoming = (if (target == relatedEntity) true else false)»
        «val useTarget = !incoming»
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode.toFirstLower»
        «val relationAliasNameParam = getRelationAliasName(!useTarget).formatForCodeCapital»
        «val otherEntity = (if (!useTarget) source else target)»
        «val many = isManySideDisplay(useTarget)»
        «IF controller.name.formatForDB == 'admin'»
            <h4>{gt text='«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»'}</h4>
        «ELSE»
            <h3>{gt text='«otherEntity.getEntityNameSingularPlural(many).formatForDisplayCapital»'}</h3>
        «ENDIF»

        {if isset($«relatedEntity.name.formatForCode».«relationAliasName») && $«relatedEntity.name.formatForCode».«relationAliasName» ne null}
            {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»/«otherEntity.name.formatForCode»«ELSE»«controller.formattedName.toFirstUpper»/«otherEntity.name.formatForCodeCapital»«ENDIF»/include_displayItemList«IF many»Many«ELSE»One«ENDIF».tpl' item«IF many»s«ENDIF»=$«relatedEntity.name.formatForCode».«relationAliasName»}
        {/if}

        «IF controller.hasActions('edit')»
            «IF !many»
                {if !isset($«relatedEntity.name.formatForCode».«relationAliasName») || $«relatedEntity.name.formatForCode».«relationAliasName» eq null}
            «ENDIF»
            {checkpermission component='«appName»:«relatedEntity.name.formatForCodeCapital»:' instance="«relatedEntity.idFieldsAsParameterTemplate»::" level='ACCESS_ADMIN' assign='authAdmin'}
            {if $authAdmin || (isset($uid) && isset($«relatedEntity.name.formatForCode».createdUserId) && $«relatedEntity.name.formatForCode».createdUserId eq $uid)}
            <p class="manageLink">
                {gt text='Create «otherEntity.name.formatForDisplay»' assign='createTitle'}
                <a href="{modurl modname='«appName»' type='«controller.formattedName»' func='edit' ot='«otherEntity.name.formatForCode»' «relationAliasNameParam.formatForDB»="«relatedEntity.idFieldsAsParameterTemplate»" returnTo='«controller.formattedName»Display«relatedEntity.name.formatForCodeCapital»'}" title="{$createTitle}" class="z-icon-es-add">{$createTitle}</a>
            </p>
            {/if}
            «IF !many»
                {/if}
            «ENDIF»
        «ENDIF»
    '''
}
