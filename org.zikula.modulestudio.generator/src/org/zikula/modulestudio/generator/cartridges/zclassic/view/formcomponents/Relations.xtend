package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship
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
    @Inject extension ViewExtensions = new ViewExtensions()
    @Inject extension Utils = new Utils()

    IFileSystemAccess fsa

    /**
     * Entry point for form sections treating related objects.
     * Note many-to-many is handled in a separate define further down.
     * If onlyInclude is true then only the Smarty include is created, otherwise the included file.
     */
    def dispatch generate(JoinRelationship it, Application app, Controller controller, Boolean onlyInclude, Boolean incoming, IFileSystemAccess fsa) {
    	this.fsa = fsa
        val stageCode = getEditStageCode(incoming)
        /* Look if we have to do anything by checking stage codes which represent different edit behaviors*/
        if ((!incoming && stageCode == 2) || (incoming && (stageCode == 1 || stageCode == 3))) {
            if (!incoming) {
                /* Exclude parent view for 1:1 and 1:n for now - see https://github.com/Guite/MostGenerator/issues/10*/
                /* activeParentImpl(app, controller, onlyInclude) */
            } else {
                passiveChildImpl(app, controller, onlyInclude, stageCode)
            }
        }
    }

    /**
     * Parent/active/source view for 1:1 and 1:n.
     * Not used yet because of https://github.com/Guite/MostGenerator/issues/10
     *
    def private activeParentImpl(JoinRelationship it, Application app, Controller controller, Boolean onlyInclude) {
        if (onlyInclude) {
            val relationAliasName = getRelationAliasName(true).formatForCodeCapital
            val many = isManySide(true)
            val uniqueNameForJs = getUniqueRelationNameForJs(app, target, many, true, relationAliasName)
            '''
                {include file='«controller.formattedName»/«target.name.formatForCode»/include_createChildItem«getTargetMultiplicity».tpl' aliasName='«relationAliasName.toFirstLower»' idPrefix='«uniqueNameForJs»'«IF source.useGroupingPanels('edit')» panel=true«ENDIF»}
            '''
        } else {
            println('Generating ' + controller.formattedName + ' edit inclusion templates for entity "' + target.name.formatForDisplay + '"')
            val usePlural = (!tempIsOneToOne)
            val templateFileName = templateFile(controller, target.name, 'include_createChildItem' + getTargetMultiplicity)
            fsa.generateFile(templateFileName, '''
                {* purpose of this template: inclusion template for managing related «target.getEntityNameSingularPlural(usePlural).formatForDisplay» in «controller.formattedName» area *}
                {if isset($panel) && $panel eq true}
                    <h3 class="«ownEntity.nameMultiple.formatForDB» z-panel-header z-panel-indicator z-pointer">{gt text='«target.getEntityNameSingularPlural(usePlural).formatForDisplayCapital»'}</h3>
                    <fieldset class="«target.getEntityNameSingularPlural(usePlural).formatForDB» z-panel-content" style="display: none">
                {else}
                    <fieldset class="«target.getEntityNameSingularPlural(usePlural).formatForDB»">
                {/if}
                    <legend>{gt text='«target.getEntityNameSingularPlural(usePlural).formatForDisplayCapital»'}</legend>
                    <div class="z-formrow">
                        «component_ParentEditing(app, controller, target, usePlural)»
                    </div>
                </fieldset>
            ''')
        }
    }
*/
    /**
     * Child/passive/target view for 1:1 and 1:n.
     */
    def private passiveChildImpl(JoinRelationship it, Application app, Controller controller, Boolean onlyInclude, Integer stageCode) {
        val hasEdit = (stageCode == 3)
        val editSnippet = if (hasEdit) 'Edit' else ''
        if (onlyInclude) {
            val relationAliasName = getRelationAliasName(false).formatForCodeCapital
            val many = isManySide(false)
            val uniqueNameForJs = getUniqueRelationNameForJs(app, target, many, false, relationAliasName)
            '''
                {include file='«controller.formattedName»/«source.name.formatForCode»/include_select«editSnippet»One.tpl' relItem=$«target.name.formatForDB» aliasName='«relationAliasName.toFirstLower»' idPrefix='«uniqueNameForJs»'«IF target.useGroupingPanels('edit')» panel=true«ENDIF»}
            '''
        } else {
            println('Generating ' + controller.formattedName + ' edit inclusion templates for entity "' + source.name.formatForDisplay + '"')
            val templateFileName = templateFile(controller, source.name, 'include_select' + editSnippet + 'One')
            val usePlural = (!tempIsOneToOne)
            fsa.generateFile(templateFileName, '''
                {* purpose of this template: inclusion template for managing related «source.getEntityNameSingularPlural(usePlural).formatForDisplay» in «controller.formattedName» area *}
                    {if isset($panel) && $panel eq true}
                        <h3 class="«source.name.formatForDB» z-panel-header z-panel-indicator z-pointer">{gt text='«source.name.formatForDisplayCapital»'}</h3>
                        <fieldset class="«source.name.formatForDB» z-panel-content" style="display: none">
                    {else}
                        <fieldset class="«source.name.formatForDB»">
                    {/if}
                    <legend>{gt text='«source.name.formatForDisplayCapital»'}</legend>
                    <div class="z-formrow">
                        «component_AutoComplete(app, controller, source, false, true, (hasEdit))»
                    </div>
                </fieldset>
            ''')
            val templateFileNameInclude = templateFile(controller, source.name, 'include_select' + editSnippet + 'ItemListOne')
            fsa.generateFile(templateFileNameInclude, component_ItemList(app, controller, source, false, true, (stageCode == 3)))
        }
    }

    def private tempIsOneToOne(JoinRelationship it) {
        switch it {
            OneToOneRelationship: true
            default: false
        }
    }

    def dispatch generate(ManyToManyRelationship it, Application app, Controller controller, Boolean onlyInclude, Boolean incoming, IFileSystemAccess fsa) {
        this.fsa = fsa
        val stageCode = getEditStageCode(incoming)
        val hasEdit = (stageCode == 3)
        val editSnippet = if (hasEdit) 'Edit' else ''
        val ownEntity = if (incoming) source else target
        val otherEntity = if (!incoming) source else target
        if (stageCode == 1 || stageCode == 3) {
            if (onlyInclude) {
                val relationAliasName = getRelationAliasName(!incoming).formatForCodeCapital
                val many = isManySide(!incoming)
                val uniqueNameForJs = getUniqueRelationNameForJs(app, otherEntity, many, incoming, relationAliasName)
                '''
                {include file='«controller.formattedName»/«ownEntity.name.formatForCode»/include_select«editSnippet»Many.tpl' relItem=$«otherEntity.name.formatForDB» aliasName='«relationAliasName.toFirstLower»' idPrefix='«uniqueNameForJs»'«IF otherEntity.useGroupingPanels('edit')» panel=true«ENDIF»}
                '''
            } else {
                println('Generating ' + controller.formattedName + ' edit inclusion templates for entity "' + ownEntity.name.formatForDisplay + '"')
                fsa.generateFile(templateFile(controller, ownEntity.name, 'include_select' + editSnippet + 'Many'), '''
                    {* purpose of this template: inclusion template for managing related «ownEntity.nameMultiple.formatForDisplayCapital» in «controller.formattedName» area *}
                    {if isset($panel) && $panel eq true}
                        <h3 class="«ownEntity.nameMultiple.formatForDB» z-panel-header z-panel-indicator z-pointer">{gt text='«ownEntity.nameMultiple.formatForDisplayCapital»'}</h3>
                        <fieldset class="«ownEntity.nameMultiple.formatForDB» z-panel-content" style="display: none">
                    {else}
                        <fieldset class="«ownEntity.nameMultiple.formatForDB»">
                    {/if}
                        <legend>{gt text='«ownEntity.nameMultiple.formatForDisplayCapital»'}</legend>
                        <div class="z-formrow">
                            «manyToManyHandling(app, controller, otherEntity, ownEntity, incoming, stageCode)»
                        </div>
                    </fieldset>
                ''')
                fsa.generateFile(templateFile(controller, ownEntity.name, 'include_select' + editSnippet + 'ItemListMany'),
                    component_ItemList(app, controller, ownEntity, true, incoming, hasEdit)
                )
            }
        }
    }

    def private manyToManyHandling(ManyToManyRelationship it, Application app, Controller controller, Entity source, Entity target, Boolean incoming, Integer stageCode) {
        component_AutoComplete(app, controller, target, true, incoming, (stageCode == 3))
    }

    def private component_AutoComplete(JoinRelationship it, Application app, Controller controller, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        <div class="«app.prefix»RelationRightSide">
            <a id="{$idPrefix}AddLink" href="javascript:void(0);" style="display: none">{gt text='«IF !many»Select«ELSE»Add«ENDIF» «targetEntity.name.formatForDisplay»'}</a>
            <div id="{$idPrefix}AddFields">
                <label for="{$idPrefix}Selector">{gt text='Find «targetEntity.name.formatForDisplay»'}</label>
                <br />
                {icon type='search' size='extrasmall' __alt='Search «targetEntity.name.formatForDisplay»'}
                <input type="text" name="{$idPrefix}Selector" id="{$idPrefix}Selector" value="" />
                <input type="hidden" name="{$idPrefix}Scope" id="{$idPrefix}Scope" value="«IF !many»0«ELSE»1«ENDIF»" />
                {img src='indicator_circle.gif' modname='core' set='ajax' alt='' id="`$idPrefix`Indicator" style='display: none'}
                <div id="{$idPrefix}SelectorChoices" class="«app.prefix»AutoComplete«IF targetEntity.hasImageFieldsEntity»WithImage«ENDIF»"></div>
                <input type="button" id="{$idPrefix}SelectorDoCancel" name="{$idPrefix}SelectorDoCancel" value="{gt text='Cancel'}" class="z-button «app.prefix»InlineButton" />
                «IF includeEditing»
                    <a id="{$idPrefix}SelectorDoNew" href="{modurl modname='«app.appName»' type='«controller.formattedName»' func='edit' ot='«targetEntity.name.formatForCode»'«controller.additionalUrlParametersForQuickViewLink»}" title="{gt text='Create new «targetEntity.name.formatForDisplay»'}" class="z-button «app.prefix»InlineButton">{gt text='Create'}</a>
                «ENDIF»
            </div>
            <noscript><p>{gt text='This function requires JavaScript activated!'}</p></noscript>
        </div>
        <div class="«app.prefix»RelationLeftSide">
            «val includeStatement = component_AutoCompleteIncludeStatement(controller, targetEntity, many, incoming, includeEditing)»
            {if isset($userSelection.$aliasName) && $userSelection.$aliasName ne ''}
                {* the user has submitted something *}
                {«includeStatement» item«IF many»s«ENDIF»=$userSelection.$aliasName}
            {elseif $mode ne 'create' || isset($relItem.$aliasName)}
                {«includeStatement» item«IF many»s«ENDIF»=$relItem.$aliasName}
            {else}
                {«includeStatement»}
            {/if}
        </div>
        <br style="clear: both" />
    '''

    def private component_AutoCompleteIncludeStatement(JoinRelationship it, Controller controller, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        include file='«controller.formattedName»/«targetEntity.name.formatForCode»/include_select«IF includeEditing»Edit«ENDIF»ItemList«IF !many»One«ELSE»Many«ENDIF».tpl' '''

    def private component_ItemList(JoinRelationship it, Application app, Controller controller, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        {* purpose of this template: inclusion template for display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplayCapital» in «controller.formattedName» area *}
        «IF includeEditing»
            {icon type='edit' size='extrasmall' assign='editImageArray'}
            {assign var="editImage" value="<img src=\"`$editImageArray.src`\" width=\"16\" height=\"16\" alt=\"\" />"}
        «ENDIF»
        {icon type='delete' size='extrasmall' assign='removeImageArray'}
        {assign var="removeImage" value="<img src=\"`$removeImageArray.src`\" width=\"16\" height=\"16\" alt=\"\" />"}

        <input type="hidden" id="{$idPrefix}ItemList" name="{$idPrefix}ItemList" value="{if isset($item«IF many»s«ENDIF») && (is_array($item«IF many»s«ENDIF») || is_object($item«IF many»s«ENDIF»))«IF !many»«FOR pkField : targetEntity.getPrimaryKeyFields» && isset($item.«pkField.name.formatForCode»)«ENDFOR»«ENDIF»}«IF many»{foreach name='relLoop' item='item' from=$items}«ENDIF»«FOR pkField : targetEntity.getPrimaryKeyFields SEPARATOR '_'»{$item.«pkField.name.formatForCode»}«ENDFOR»«IF many»{if $smarty.foreach.relLoop.last ne true},{/if}{/foreach}«ENDIF»{/if}" />
        <input type="hidden" id="{$idPrefix}Mode" name="{$idPrefix}Mode" value="«IF includeEditing»1«ELSE»0«ENDIF»" />

        <ul id="{$idPrefix}ReferenceList">
        {if isset($item«IF many»s«ENDIF») && (is_array($item«IF many»s«ENDIF») || is_object($item«IF many»s«ENDIF»))«IF !many»«FOR pkField : targetEntity.getPrimaryKeyFields» && isset($item.«pkField.name.formatForCode»)«ENDFOR»«ENDIF»}
        «IF many»
            {foreach name='relLoop' item='item' from=$items}
        «ENDIF»
        {assign var='idPrefixItem' value="`$idPrefix`Reference_«FOR pkField : targetEntity.getPrimaryKeyFields SEPARATOR '_'»`$item.«pkField.name.formatForCode»`«ENDFOR»"}
        <li id="{$idPrefixItem}">
            «val leadingField = targetEntity.getLeadingField»
            «IF leadingField != null»
                {$item.«leadingField.name.formatForCode»}
            «ELSE»
                {gt text='«targetEntity.name.formatForDisplayCapital»'}
            «ENDIF»
            «IF includeEditing»
             <a id="{$idPrefixItem}Edit" href="{modurl modname='«app.appName»' type='«controller.formattedName»' «targetEntity.modUrlEdit('item', true)»«IF controller.formattedName == 'user'» forcelongurl=true«ENDIF»}">{$editImage}</a>
            «ENDIF»
             <a id="{$idPrefixItem}Remove" href="javascript:«app.prefix»RemoveRelatedItem('{$idPrefix}', '«FOR pkField : targetEntity.getPrimaryKeyFields SEPARATOR '_'»{$item.«pkField.name.formatForCode»}«ENDFOR»');">{$removeImage}</a>
            «IF targetEntity.hasImageFieldsEntity»
                <br />
                «val imageFieldName = targetEntity.getImageFieldsEntity.head.name.formatForCode»
                {if $item.«imageFieldName» ne '' && isset($item.«imageFieldName»FullPath)}
                    <img src="{$item.«imageFieldName»FullPath|«app.appName.formatForDB»ImageThumb:50:40}" width="50" height="40" alt="«IF leadingField != null»{$item.«leadingField.name.formatForCode»«ELSE»{gt text='«targetEntity.name.formatForDisplayCapital»«ENDIF»|replace:"\"":""}" />
                {/if}
            «ENDIF»
        </li>
        «IF many»
            {/foreach}
        «ENDIF»
        {/if}
        </ul>
    '''
/*
    def private component_ParentEditing(JoinRelationship it, Application app, Controller controller, Entity targetEntity, Boolean many) '''
        «/*just a reminder for the parent view which is not tested yet (see #10)
            Example: create children (e.g. an address) while creating a parent (e.g. a new customer).
            Problem: address must know the customerid.
            TODO: only for $mode ne create: 
                <p>TODO ADD: button to create «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
                <p>TODO EDIT: display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
        *-/»
    '''
*/
    def initJs(JoinRelationship it, Application app, Entity targetEntity, Boolean incoming, Boolean insideLoader) {
        val stageCode = getEditStageCode(incoming)
        /*Look if we have to do anything by checking stage codes which represent different edit behaviors*/
        if ((!incoming && stageCode == 2) || ((incoming || tempInitJsIsManyToMany) && (stageCode == 1 || stageCode == 3))) {
            /*Exclude parent view for 1:1 and 1:n for now - see https://github.com/Guite/MostGenerator/issues/10*/
            if (incoming || tempInitJsIsManyToMany) {
                val relationAliasName = getRelationAliasName(!incoming).formatForCodeCapital
                val many = (!incoming || tempInitJsIsManyToMany)
                val uniqueNameForJs = getUniqueRelationNameForJs(app, targetEntity, many, incoming, relationAliasName)
                if (!insideLoader) '''
                    var newItem = new Object();
                    newItem['ot'] = '«(if (targetEntity == target) source else target).name.formatForCode»';
                    newItem['alias'] = '«relationAliasName.formatForCodeCapital»';
                    newItem['prefix'] = '«uniqueNameForJs»SelectorDoNew';
                    newItem['acInstance'] = null;
                    newItem['windowInstance'] = null;
                    relationHandler.push(newItem);
                '''
                else '''
                    «app.prefix»InitRelationItemsForm('«(if (targetEntity == target) source else target).name.formatForCode»', '«uniqueNameForJs»', «IF stageCode > 1»true«ELSE»false«ENDIF»);
                '''
            }
        }
    }

    def private tempInitJsIsManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }
}
