package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
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

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension UrlExtensions = new UrlExtensions
    extension ViewExtensions = new ViewExtensions
    extension Utils = new Utils

    /* TODO migrate to Symfony forms #416 */

    /**
     * This method creates the templates to be included into the edit forms.
     */
    def generateInclusionTemplate(Entity it, Application app, IFileSystemAccess fsa) '''
        «FOR relation : getBidirectionalIncomingJoinRelations.filter[source.application == app]»«relation.generate(app, false, true, fsa)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations.filter[target.application == app]»«relation.generate(app, false, false, fsa)»«ENDFOR»
    '''

    /**
     * Entry point for form sections treating related objects.
     * This method creates the include statement contained in the including template.
     */
    def generateIncludeStatement(Entity it, Application app, IFileSystemAccess fsa) '''
        «FOR relation : getBidirectionalIncomingJoinRelations.filter[source.application == app && source instanceof Entity]»«relation.generate(app, true, true, fsa)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations.filter[target.application == app && target instanceof Entity]»«relation.generate(app, true, false, fsa)»«ENDFOR»
    '''

    def private generate(JoinRelationship it, Application app, Boolean onlyInclude, Boolean incoming, IFileSystemAccess fsa) {
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

        val ownEntity = (if (incoming) source else target) as Entity
        val otherEntity = (if (!incoming) source else target) as Entity
        val many = isManySide(useTarget)

        if (onlyInclude) {
            val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital
            val relationAliasReverse = getRelationAliasName(!useTarget).formatForCodeCapital
            val incomingForUniqueRelationName = if (!isManyToMany) useTarget else incoming
            val uniqueNameForJs = getUniqueRelationNameForJs(app, otherEntity, many, incomingForUniqueRelationName, relationAliasName)
            return includeStatementForEditTemplate(templateName, ownEntity, otherEntity, incoming, relationAliasName, relationAliasReverse, uniqueNameForJs, hasEdit)
        }

        // onlyInclude is false here, lets create the templates
        println('Generating edit inclusion templates for entity "' + ownEntity.name.formatForDisplay + '"')
        var templateNameItemList = 'includeSelect' + editSnippet + 'ItemList' + getTargetMultiplicity(useTarget)
        val templateFileName = templateFile(ownEntity, templateName)
        val templateFileNameItemList = templateFile(ownEntity, templateNameItemList)
        if (!app.shouldBeSkipped(templateFileName)) {
            fsa.generateFile(templateFileName, includedEditTemplate(app, ownEntity, otherEntity, incoming, hasEdit, many))
        }
        if (!app.shouldBeSkipped(templateFileNameItemList)) {
            fsa.generateFile(templateFileNameItemList, component_ItemList(app, ownEntity, many, incoming, hasEdit))
        }
    }

    def private getTemplateName(JoinRelationship it, Boolean useTarget, String editSnippet) {
        var templateName = ''
        if (useTarget && !isManyToMany) {
            //templateName = 'includeCreateChildItem'
        } else {
            templateName = 'includeSelect' + editSnippet
        }
        templateName = templateName + getTargetMultiplicity(useTarget)

        templateName
    }

    def private includeStatementForEditTemplate(JoinRelationship it, String templateName, Entity ownEntity, Entity linkingEntity, Boolean incoming, String relationAliasName, String relationAliasReverse, String uniqueNameForJs, Boolean hasEdit) '''
        «IF application.targets('1.3.x')»
            {include file='«ownEntity.name.formatForCode»/«templateName».tpl' group='«linkingEntity.name.formatForDB»' alias='«relationAliasName.toFirstLower»' aliasReverse='«relationAliasReverse.toFirstLower»' mandatory=«(!nullable).displayBool» idPrefix='«uniqueNameForJs»' linkingItem=$«linkingEntity.name.formatForDB»«IF linkingEntity.useGroupingPanels('edit')» panel=true«ENDIF» displayMode='«IF usesAutoCompletion(incoming)»autocomplete«ELSE»choices«ENDIF»' allowEditing=«hasEdit.displayBool»}
        «ELSE»
            {{ include(
                '@«application.appName»/«ownEntity.name.formatForCodeCapital»/«templateName».html.twig',
                { group: '«linkingEntity.name.formatForDB»', alias: '«relationAliasName.toFirstLower»', aliasReverse: '«relationAliasReverse.toFirstLower»', mandatory: «(!nullable).displayBool», idPrefix: '«uniqueNameForJs»', linkingItem: «linkingEntity.name.formatForDB»«IF linkingEntity.useGroupingPanels('edit')», panel: true«ENDIF», displayMode: '«IF usesAutoCompletion(incoming)»autocomplete«ELSE»choices«ENDIF»', allowEditing: «hasEdit.displayBool» }
            ) }}
        «ENDIF»
    '''

    def private includedEditTemplate(JoinRelationship it, Application app, Entity ownEntity, Entity linkingEntity, Boolean incoming, Boolean hasEdit, Boolean many) '''
        «val ownEntityName = ownEntity.getEntityNameSingularPlural(many)»
        «IF app.targets('1.3.x')»
            {* purpose of this template: inclusion template for managing related «ownEntityName.formatForDisplay» *}
            {if !isset($displayMode)}
                {assign var='displayMode' value='choices'}
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
                «includedEditTemplateBodyLegacy(app, ownEntity, linkingEntity, incoming, hasEdit, many)»
            {if isset($panel) && $panel eq true}
                </fieldset>
            {else}
                </fieldset>
            {/if}
        «ELSE»
            {# purpose of this template: inclusion template for managing related «ownEntityName.formatForDisplay» #}
            {% displayMode is not defined or displayMode is empty %}
                {% set displayMode = 'choices' %}
            {% endif %}
            {% if allowEditing is not defined or allowEditing is empty %}
                {% set allowEditing = false %}
            {% endif %}
            {% if panel|default(false) == true %}
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h3 class="panel-title"><a class="accordion-toggle" data-toggle="collapse" data-parent="#accordion" href="#collapse«ownEntityName.formatForCodeCapital»">{{ __('«ownEntityName.formatForDisplayCapital»') }}</a></h3>
                    </div>
                    <div id="collapse«ownEntityName.formatForCodeCapital»" class="panel-collapse collapse in">
                        <div class="panel-body">
            {% else %}
                <fieldset class="«ownEntityName.formatForDB»">
            {% endif %}
                <legend>{{ __('«ownEntityName.formatForDisplayCapital»') }}</legend>
                «includedEditTemplateBody(app, ownEntity, linkingEntity, incoming, hasEdit, many)»
            {% if panel|default(false) == true %}
                        </div>
                    </div>
                </div>
            {% else %}
                </fieldset>
            {% endif %}
        «ENDIF»
    '''

    // 1.3.x only
    def private includedEditTemplateBodyLegacy(JoinRelationship it, Application app, Entity ownEntity, Entity linkingEntity, Boolean incoming, Boolean hasEdit, Boolean many) '''
        «val ownEntityName = ownEntity.getEntityNameSingularPlural(many)»
        <div class="z-formrow">
        «val pluginAttributes = formPluginAttributesLegacy(ownEntity, ownEntityName, ownEntity.name.formatForCode, many)»
        «val appnameLower = application.appName.formatForDB»
        {if $displayMode eq 'choices'}
            {formlabel for=$alias __text='Choose «ownEntityName.formatForDisplay»'«IF !nullable» mandatorysym='1'«ENDIF»}
            {«appnameLower»RelationSelectorList «pluginAttributes»«IF !application.targets('1.3.x')» cssClass='form-control'«ENDIF»}
        {elseif $displayMode eq 'autocomplete'}
            «IF !isManyToMany && !incoming»
                «component_ParentEditing(ownEntity, many)»
            «ELSE»
                {assign var='createLink' value=''}
                {if $allowEditing eq true}
                    {modurl modname='«app.appName»' type=$lct func='edit' ot='«ownEntity.name.formatForCode»' forcelongurl=true assign='createLink'}
                {/if}
                {«appnameLower»RelationSelectorAutoComplete «pluginAttributes» idPrefix=$idPrefix createLink=$createLink withImage=«ownEntity.hasImageFieldsEntity.displayBool»}
                «component_AutoComplete(app, ownEntity, many, incoming, hasEdit)»
            «ENDIF»
        {/if}
        </div>
    '''

    def private includedEditTemplateBody(JoinRelationship it, Application app, Entity ownEntity, Entity linkingEntity, Boolean incoming, Boolean hasEdit, Boolean many) '''
        «val aliasName = getRelationAliasName(!incoming)»
        «val appnameLower = application.appName.formatForDB»
        {% if displayMode == 'choices' %}
            {{ form_row(form.«aliasName.formatForCode») }}
        {% elseif displayMode == 'autocomplete' %}
            «/* TODO add auto completion support */»
            <div class="form-group">
                «IF !isManyToMany && !incoming»
                    «component_ParentEditing(ownEntity, many)»
                «ELSE»
                    {% set createLink = '' %}
                    {% if allowEditing == true %}
                        {% set createLink = path('«app.appName.formatForDB»_«ownEntity.name.formatForDB»_' ~ routeArea ~ 'edit') %}
                    {% endif %}
                    {«appnameLower»RelationSelectorAutoComplete idPrefix=$idPrefix createLink=$createLink withImage=«ownEntity.hasImageFieldsEntity.displayBool» cssClass='form-control'}
                    «component_AutoComplete(app, ownEntity, many, incoming, hasEdit)»
                «ENDIF»
            </div>
        {% endif %}
    '''

    // 1.3.x only
    def private formPluginAttributesLegacy(JoinRelationship it, Entity ownEntity, String ownEntityName, String objectType, Boolean many) '''group=$group id=$alias aliasReverse=$aliasReverse mandatory=$mandatory __title='Choose the «ownEntityName.formatForDisplay»' selectionMode='«IF many»multiple«ELSE»single«ENDIF»' objectType='«objectType»' linkingItem=$linkingItem'''

    def private component_ParentEditing(JoinRelationship it, Entity targetEntity, Boolean many) '''
        «/*just a reminder for the parent view which is not tested yet (see #10)
            Example: create children (e.g. an address) while creating a parent (e.g. a new customer).
            Problem: address must know the customerid.
            TODO: only for $mode ne create: 
                <p>TODO ADD: button to create «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
                <p>TODO EDIT: display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
        */»
    '''

    def private component_AutoComplete(JoinRelationship it, Application app, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        <div class="«app.appName.toLowerCase»-relation-leftside">
            «val includeStatement = component_IncludeStatementForAutoCompleterItemList(targetEntity, many, incoming, includeEditing)»
            «IF app.targets('1.3.x')»
                {if isset($linkingItem.$alias)}
                    {include «includeStatement» item«IF many»s«ENDIF»=$linkingItem.$alias}
                {else}
                    {include «includeStatement»}
                {/if}
            «ELSE»
                {% if attribute(linkingItem, alias) is defined %}
                    {{ include(
                        «includeStatement»,
                        { item«IF many»s«ENDIF»: attribute(linkingItem, alias) }
                    ) }}
                {% else %}
                    {{ include(«includeStatement») }}
                {% endif %}
            «ENDIF»
        </div>
        <br «IF app.targets('1.3.x')»class="z-clearer"«ELSE»style="clear: both"«ENDIF» />
    '''

    def private component_IncludeStatementForAutoCompleterItemList(JoinRelationship it, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) {
        if (application.targets('1.3.x')) '''
            file='«targetEntity.name.formatForCode»/includeSelect«IF includeEditing»Edit«ENDIF»ItemList«IF !many»One«ELSE»Many«ENDIF».tpl' '''
        else '''
            '«targetEntity.name.formatForCodeCapital»/includeSelect«IF includeEditing»Edit«ENDIF»ItemList«IF !many»One«ELSE»Many«ENDIF».html.twig' '''
    }

    def private component_ItemList(JoinRelationship it, Application app, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        «IF app.targets('1.3.x')»
            {* purpose of this template: inclusion template for display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» *}
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
                {$item->getTitleFromDisplayPattern()}
                «IF includeEditing»
                    <a id="{$idPrefixItem}Edit" href="{modurl modname='«app.appName»' type=$lct func='edit' ot='«targetEntity.name.formatForCode»' «targetEntity.routeParamsLegacy('item', true, false)» forcelongurl=true}">{$editImage}</a>
                «ENDIF»
                 <a id="{$idPrefixItem}Remove" href="javascript:«app.prefix()»RemoveRelatedItem('{$idPrefix}', '«FOR pkField : targetEntity.getPrimaryKeyFields SEPARATOR '_'»{$item.«pkField.name.formatForCode»}«ENDFOR»');">{$removeImage}</a>
                «IF targetEntity.hasImageFieldsEntity»
                    <br />
                    «val imageFieldName = targetEntity.getImageFieldsEntity.head.name.formatForCode»
                    {if $item.«imageFieldName» ne '' && isset($item.«imageFieldName»FullPath) && $item.«imageFieldName»Meta.isImage}
                        {thumb image=$item.«imageFieldName»FullPath objectid="«targetEntity.name.formatForCode»«IF targetEntity.hasCompositeKeys»«FOR pkField : targetEntity.getPrimaryKeyFields»-`$item.«pkField.name.formatForCode»`«ENDFOR»«ELSE»-`$item.«targetEntity.primaryKeyFields.head.name.formatForCode»`«ENDIF»" preset=$relationThumbPreset tag=true img_alt=$item->getTitleFromDisplayPattern()}
                    {/if}
                «ENDIF»
            </li>
            «IF many»
                {/foreach}
            «ENDIF»
            {/if}
            </ul>
        «ELSE»
            {# purpose of this template: inclusion template for display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» #}
            «IF includeEditing»
                {% set editImage = '<span class="fa fa-pencil-square-o"></span>' %}
            «ENDIF»
            {% set removeImage = '<span class="fa fa-trash-o"></span>' %}

            <input type="hidden" id="{{ idPrefix }}ItemList" name="{{ idPrefix }}ItemList" value="{% if item«IF many»s«ENDIF» is defined and item«IF many»s«ENDIF» is iterable«IF !many»«FOR pkField : targetEntity.getPrimaryKeyFields» and item.«pkField.name.formatForCode» is defined«ENDFOR»«ENDIF» %}«IF many»{% for item in items %}«ENDIF»«FOR pkField : targetEntity.getPrimaryKeyFields SEPARATOR '_'»{{ item.«pkField.name.formatForCode» }}«ENDFOR»«IF many»{% if not loop.last %},{% endif %}{% endfor %}«ENDIF»{% endif %}" />
            <input type="hidden" id="{{ idPrefix }}Mode" name="{{ idPrefix }}Mode" value="«IF includeEditing»1«ELSE»0«ENDIF»" />

            <ul id="{{ idPrefix }}ReferenceList">
            {% if item«IF many»s«ENDIF» is defined and item«IF many»s«ENDIF» is iterable«IF !many»«FOR pkField : targetEntity.getPrimaryKeyFields» and item.«pkField.name.formatForCode» is defined«ENDFOR»«ENDIF» %}
            «IF many»
                {% for item in items %}
            «ENDIF»
            {% set idPrefixItem = idPrefix ~ 'Reference_'«FOR pkField : targetEntity.getPrimaryKeyFields» ~ item.«pkField.name.formatForCode»«ENDFOR» %}
            <li id="{{ idPrefixItem }}">
                {{ item.getTitleFromDisplayPattern() }}
                «IF includeEditing»
                    <a id="{{ idPrefixItem }}Edit" href="{{ path('«app.appName.formatForDB»_«targetEntity.name.formatForDB»_' ~ routeArea ~ 'edit'«targetEntity.routeParams('item', true)») }}">{{ editImage }}</a>
                «ENDIF»
                 <a id="{{ idPrefixItem }}Remove" href="javascript:«app.prefix()»RemoveRelatedItem('{{ idPrefix }}', '«FOR pkField : targetEntity.getPrimaryKeyFields SEPARATOR '_'»{{ item.«pkField.name.formatForCode» }}«ENDFOR»');">{{ removeImage }}</a>
                «IF targetEntity.hasImageFieldsEntity»
                    <br />
                    «val imageFieldName = targetEntity.getImageFieldsEntity.head.name.formatForCode»
                    {% if item.«imageFieldName» != '' and item.«imageFieldName»FullPath is defined and item.«imageFieldName»Meta.isImage %}
                        {{ «app.appName.formatForDB»_thumb({ image: item.«imageFieldName»FullPath, objectid: '«targetEntity.name.formatForCode»«FOR pkField : targetEntity.getPrimaryKeyFields»-' ~ item.«pkField.name.formatForCode» ~ '«ENDFOR»', preset: relationThumbPreset, tag: true, img_alt: item.getTitleFromDisplayPattern(), img_class: 'img-rounded'}) }}
                    {% endif %}
                «ENDIF»
            </li>
            «IF many»
                {% endfor %}
            «ENDIF»
            {% endif %}
            </ul>
        «ENDIF»
    '''

    def initJs(Entity it, Application app, Boolean insideLoader) '''
        «val incomingJoins = getBidirectionalIncomingJoinRelations.filter[source.application == app && usesAutoCompletion(true)]»
        «val outgoingJoins = outgoingJoinRelations.filter[target.application == app && usesAutoCompletion(false)]»
        «IF !incomingJoins.empty || !outgoingJoins.empty»
            «IF !insideLoader»
                «IF app.targets('1.3.x')»
                    var editImage = '<img src="{{$editImageArray.src}}" width="16" height="16" alt="" />';
                    var removeImage = '<img src="{{$removeImageArray.src}}" width="16" height="16" alt="" />';
                «ELSE»
                    var editImage = '{{ editImage }}';
                    var removeImage = '{{ removeImage }}';
                «ENDIF»
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

        if (!usesAutoCompletion(incoming)) {
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
            newItem.moduleName = '«linkEntity.application.appName»';
            newItem.acInstance = null;
            newItem.windowInstance = null;
            relationHandler.push(newItem);
        '''
        else '''
            «app.prefix()»InitRelationItemsForm('«linkEntity.name.formatForCode»', '«uniqueNameForJs»', «(stageCode > 1).displayBool»);
        '''
    }

    def private isManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }
}
