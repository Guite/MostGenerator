package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
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

    /**
     * This method creates the templates to be included into the edit forms.
     */
    def generateInclusionTemplate(Entity it, Application app, Controller controller, IFileSystemAccess fsa) '''
        «FOR relation : getBidirectionalIncomingJoinRelations.filter(e|e.source.container.application == app)»«relation.generate(app, controller, false, true, fsa)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations.filter(e|e.target.container.application == app)»«relation.generate(app, controller, false, false, fsa)»«ENDFOR»
    '''

    /**
     * Entry point for form sections treating related objects.
     * This method creates the Smarty include statement.
     */
    def generateIncludeStatement(Entity it, Application app, Controller controller, IFileSystemAccess fsa) '''
        «FOR relation : getBidirectionalIncomingJoinRelations.filter(e|e.source.container.application == app)»«relation.generate(app, controller, true, true, fsa)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations.filter(e|e.target.container.application == app)»«relation.generate(app, controller, true, false, fsa)»«ENDFOR»
    '''

    def private generate(JoinRelationship it, Application app, Controller controller, Boolean onlyInclude, Boolean incoming, IFileSystemAccess fsa) {
        val stageCode = getEditStageCode(incoming)
        if (stageCode < 1) {
            return ''''''
        }

        val useTarget = !incoming
        if (useTarget && !isManyToMany) {
            /* Exclude parent view for 1:1 1:n and n:1 for now - see https://github.com/Guite/MostGenerator/issues/10 */
            return ''''''
        }

        val hasEdit = (stageCode > 1)
        val editSnippet = if (hasEdit) 'Edit' else ''

        val templateName = getTemplateName(useTarget, editSnippet)

        val ownEntity = if (incoming) source else target
        val otherEntity = if (!incoming) source else target
        val many = isManySide(useTarget)

        if (onlyInclude) {
            val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital
            val relationAliasReverse = getRelationAliasName(!useTarget).formatForCodeCapital
            val incomingForUniqueRelationName = if (!isManyToMany) useTarget else incoming
            val uniqueNameForJs = getUniqueRelationNameForJs(app, otherEntity, many, incomingForUniqueRelationName, relationAliasName)
            return includeStatementForEditTemplate(templateName, controller, ownEntity, otherEntity, incoming, relationAliasName, relationAliasReverse, uniqueNameForJs, hasEdit)
        }

        // onlyInclude is false here, lets create the templates
        println('Generating ' + controller.formattedName + ' edit inclusion templates for entity "' + ownEntity.name.formatForDisplay + '"')
        var templateNameItemList = 'include_select' + editSnippet + 'ItemList' + getTargetMultiplicity(useTarget)
        val templateFileName = templateFile(controller, ownEntity.name, templateName)
        val templateFileNameItemList = templateFile(controller, ownEntity.name, templateNameItemList)
        fsa.generateFile(templateFileName, includedEditTemplate(app, controller, ownEntity, otherEntity, incoming, hasEdit, many))
        fsa.generateFile(templateFileNameItemList, component_ItemList(app, controller, ownEntity, many, incoming, hasEdit))
    }

    def private getTemplateName(JoinRelationship it, Boolean useTarget, String editSnippet) {
        var templateName = ''
        if (useTarget && !isManyToMany) {
            //templateName = 'include_createChildItem'
        } else {
            templateName = 'include_select' + editSnippet
        }
        templateName = templateName + getTargetMultiplicity(useTarget)

        templateName
    }

    def private includeStatementForEditTemplate(JoinRelationship it, String templateName, Controller controller, Entity ownEntity, Entity linkingEntity, Boolean incoming, String relationAliasName, String relationAliasReverse, String uniqueNameForJs, Boolean hasEdit) '''
        {include file='«IF container.application.targets('1.3.5')»«controller.formattedName»/«ownEntity.name.formatForCode»«ELSE»«controller.formattedName.toFirstUpper»/«ownEntity.name.formatForCodeCapital»«ENDIF»/«templateName».tpl' group='«linkingEntity.name.formatForDB»' alias='«relationAliasName.toFirstLower»' aliasReverse='«relationAliasReverse.toFirstLower»' mandatory=«(!nullable).displayBool» idPrefix='«uniqueNameForJs»' linkingItem=$«linkingEntity.name.formatForDB»«IF ownEntity.useGroupingPanels('edit')» panel=true«ENDIF» displayMode='«IF !usesAutoCompletion(!incoming)»dropdown«ELSE»autocomplete«ENDIF»' allowEditing=«hasEdit.displayBool»}
    '''

    def private includedEditTemplate(JoinRelationship it, Application app, Controller controller, Entity ownEntity, Entity linkingEntity, Boolean incoming, Boolean hasEdit, Boolean many) '''
        «val ownEntityName = ownEntity.getEntityNameSingularPlural(many)»
        {* purpose of this template: inclusion template for managing related «ownEntityName.formatForDisplay» in «controller.formattedName» area *}
        {if !isset($displayMode)}
            {assign var='displayMode' value='dropdown'}
        {/if}
        {if !isset($allowEditing)}
            {assign var='allowEditing' value=false}
        {/if}
        {if isset($panel) && $panel eq true}
            <h3 class="«ownEntityName.formatForDB» z-panel-header z-panel-indicator z-pointer">{gt text='«ownEntityName.formatForDisplayCapital»'}</h3>
            <fieldset class="«ownEntityName.formatForDB» z-panel-content" style="display: none">
        {else}
            <fieldset class="«ownEntityName.formatForDB»">
        {/if}
            <legend>{gt text='«ownEntityName.formatForDisplayCapital»'}</legend>
            <div class="z-formrow">
        «val pluginAttributes = formPluginAttributes(ownEntity, ownEntityName, ownEntity.name.formatForCode, many)»
        «val appnameLower = container.application.appName.formatForDB»
            {if $displayMode eq 'dropdown'}
                {formlabel for=$alias __text='Choose «ownEntityName.formatForDisplay»'«IF !nullable» mandatorysym='1'«ENDIF»}
                {«appnameLower»RelationSelectorList «pluginAttributes»}
            {elseif $displayMode eq 'autocomplete'}
                «IF !isManyToMany && !incoming»
                    «component_ParentEditing(ownEntity, many)»
                «ELSE»
                    {assign var='createLink' value=''}
                    {if $allowEditing eq true}
                        {modurl modname='«app.appName»' type='«controller.formattedName»' func='edit' ot='«ownEntity.name.formatForCode»'«controller.additionalUrlParametersForQuickViewLink» assign='createLink'}
                    {/if}
                    {«appnameLower»RelationSelectorAutoComplete «pluginAttributes» idPrefix=$idPrefix createLink=$createLink selectedEntityName='«ownEntityName.formatForDisplay»' withImage=«ownEntity.hasImageFieldsEntity.displayBool»}
                    «component_AutoComplete(app, controller, ownEntity, many, incoming, hasEdit)»
                «ENDIF»
            {/if}
            </div>
        </fieldset>
    '''

    def private formPluginAttributes(JoinRelationship it, Entity ownEntity, String ownEntityName, String objectType, Boolean many) '''group=$group id=$alias aliasReverse=$aliasReverse mandatory=$mandatory __title='Choose the «ownEntityName.formatForDisplay»' selectionMode='«IF many»multiple«ELSE»single«ENDIF»' objectType='«objectType»' linkingItem=$linkingItem'''

    def private component_ParentEditing(JoinRelationship it, Entity targetEntity, Boolean many) '''
        «/*just a reminder for the parent view which is not tested yet (see #10)
            Example: create children (e.g. an address) while creating a parent (e.g. a new customer).
            Problem: address must know the customerid.
            TODO: only for $mode ne create: 
                <p>TODO ADD: button to create «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
                <p>TODO EDIT: display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
        */»
    '''

    def private component_AutoComplete(JoinRelationship it, Application app, Controller controller, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        <div class="«app.prefix()»RelationLeftSide">
            «val includeStatement = component_IncludeStatementForAutoCompleterItemList(controller, targetEntity, many, incoming, includeEditing)»
            {if isset($linkingItem.$alias)}
                {«includeStatement» item«IF many»s«ENDIF»=$linkingItem.$alias}
            {else}
                {«includeStatement»}
            {/if}
        </div>
        <br class="z-clearer" />
    '''

    def private component_IncludeStatementForAutoCompleterItemList(JoinRelationship it, Controller controller, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        include file='«IF container.application.targets('1.3.5')»«controller.formattedName»/«targetEntity.name.formatForCode»«ELSE»«controller.formattedName.toFirstUpper»/«targetEntity.name.formatForCodeCapital»«ENDIF»/include_select«IF includeEditing»Edit«ENDIF»ItemList«IF !many»One«ELSE»Many«ENDIF».tpl' '''

    def private component_ItemList(JoinRelationship it, Application app, Controller controller, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        {* purpose of this template: inclusion template for display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» in «controller.formattedName» area *}
        «IF includeEditing»
            {icon type='edit' size='extrasmall' assign='editImageArray'}
            {assign var='editImage' value="<img src=\"`$editImageArray.src`\" width=\"16\" height=\"16\" alt=\"\" />"}
        «ENDIF»
        {icon type='delete' size='extrasmall' assign='removeImageArray'}
        {assign var='removeImage' value="<img src=\"`$removeImageArray.src`\" width=\"16\" height=\"16\" alt=\"\" />"}

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
                {if $item.«imageFieldName» ne '' && isset($item.«imageFieldName»FullPath) && $item.«imageFieldName»Meta.isImage}
                    {thumb image=$item.«imageFieldName»FullPath objectid="«targetEntity.name.formatForCode»«IF targetEntity.hasCompositeKeys»«FOR pkField : targetEntity.getPrimaryKeyFields»-`$item.«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$item.«targetEntity.primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$relationThumbPreset tag=true «IF leadingField != null»img_alt=$item.«leadingField.name.formatForCode»«ELSE»__img_alt='«targetEntity.name.formatForDisplayCapital»'«ENDIF»}
                {/if}
            «ENDIF»
        </li>
        «IF many»
            {/foreach}
        «ENDIF»
        {/if}
        </ul>
    '''

    def initJs(Entity it, Application app, Boolean insideLoader) '''
        «val incomingJoins = getBidirectionalIncomingJoinRelations.filter(e|e.source.container.application == app && e.usesAutoCompletion(false))»
        «val outgoingJoins = outgoingJoinRelations.filter(e|e.target.container.application == app && e.usesAutoCompletion(true))»
        «IF !incomingJoins.isEmpty || !outgoingJoins.isEmpty»
            «IF !insideLoader»
                var editImage = '<img src="{{$editImageArray.src}}" width="16" height="16" alt="" />';
                var removeImage = '<img src="{{$deleteImageArray.src}}" width="16" height="16" alt="" />';
                var relationHandler = new Array();
            «ENDIF»
            «FOR relation : incomingJoins»«relation.initJs(app, it, true, insideLoader)»«ENDFOR»
            «FOR relation : outgoingJoins»«relation.initJs(app, it, false, insideLoader)»«ENDFOR»
        «ENDIF»
    '''

    def private initJs(JoinRelationship it, Application app, Entity targetEntity, Boolean incoming, Boolean insideLoader) {
        val stageCode = getEditStageCode(incoming)
        if (stageCode < 1) {
            return ''''''
        }

        val useTarget = !incoming
        if (useTarget && !isManyToMany) {
            /* Exclude parent view for 1:1 and 1:n for now - see https://github.com/Guite/MostGenerator/issues/10 */
            return ''''''
        }

        if (!usesAutoCompletion(useTarget)) {
            return ''''''
        }

        val relationAliasName = getRelationAliasName(!incoming).formatForCodeCapital
        val many = isManySide(useTarget)
        val uniqueNameForJs = getUniqueRelationNameForJs(app, targetEntity, many, incoming, relationAliasName)
        val linkEntity = if (targetEntity == target) source else target
        if (!insideLoader) '''
            var newItem = new Object();
            newItem.ot = '«linkEntity.name.formatForCode»';
            newItem.alias = '«relationAliasName»';
            newItem.prefix = '«uniqueNameForJs»SelectorDoNew';
            newItem.moduleName = '«linkEntity.container.application.appName»';
            newItem.acInstance = null;
            newItem.windowInstance = null;
            relationHandler.push(newItem);
        '''
        else '''
            «app.prefix»InitRelationItemsForm('«linkEntity.name.formatForCode»', '«uniqueNameForJs»', «(stageCode > 1).displayBool»);
        '''
    }

    def private isManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }
}
