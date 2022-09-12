package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.RelationEditMode
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.Forms
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

    IMostFileSystemAccess fsa
    Application app

    /**
     * Constructor
     */
    new(IMostFileSystemAccess fsa, Application app) {
        this.fsa = fsa
        this.app = app
    }

    /**
     * This method creates the templates to be included into the edit forms.
     */
    def CharSequence generateInclusionTemplate(Entity it) '''
        «FOR relation : getJoinRelationsWithEntities(true)»«relation.generate(false, false, false)»«ENDFOR»
        «FOR relation : getJoinRelationsWithEntities(false)»«relation.generate(false, false, true)»«ENDFOR»
    '''

    /**
     * Entry point for form sections treating related objects.
     * This method creates the tab titles for included relationship sections on edit pages.
     */
    def generateTabTitles(Entity it) '''
        «FOR relation : getJoinRelationsWithEntities(true)»«relation.generate(true, false, false)»«ENDFOR»
        «FOR relation : getJoinRelationsWithEntities(false)»«relation.generate(true, false, true)»«ENDFOR»
    '''

    /**
     * Entry point for form sections treating related objects.
     * This method creates the include statement contained in the including template.
     */
    def generateIncludeStatement(Entity it) '''
        «FOR relation : getJoinRelationsWithEntities(true)»«relation.generate(false, true, false)»«ENDFOR»
        «FOR relation : getJoinRelationsWithEntities(false)»«relation.generate(false, true, true)»«ENDFOR»
    '''

    def private generate(JoinRelationship it, Boolean onlyTabTitle, Boolean onlyInclude, Boolean useTarget) {
        val stageCode = getEditStageCode(!useTarget)
        if (stageCode < 1) {
            return ''''''
        }

        val hasEdit = (stageCode > 1)
        val editSnippet = if (hasEdit) 'Edit' else ''

        val ownEntity = (if (!useTarget) source else target) as Entity
        val otherEntity = (if (useTarget) source else target) as Entity
        val many = isManySide(useTarget)

        if (onlyTabTitle) {
            return tabTitleForEditTemplate(ownEntity, many)
        }


        val templateName = getTemplateName(useTarget, editSnippet)

        if (onlyInclude) {
            val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital
            val uniqueNameForJs = getUniqueRelationNameForJs(otherEntity, relationAliasName)
            return includeStatementForEditTemplate(templateName, ownEntity, otherEntity, useTarget, relationAliasName, uniqueNameForJs)
        }

        // onlyTabTitle and onlyInclude are false here, so lets create the inclusion templates
        ('Generating edit inclusion templates for entity "' + ownEntity.name.formatForDisplay + '"').printIfNotTesting(fsa)
        var templateNameItemList = 'includeSelect' + editSnippet + 'ItemList' + getTargetMultiplicity(useTarget)

        var templateFileName = templateFile(ownEntity, templateName)
        var templateFileNameItemList = templateFile(ownEntity, templateNameItemList)
        fsa.generateFile(templateFileName, includedEditTemplate(ownEntity, otherEntity, hasEdit, many))
        fsa.generateFile(templateFileNameItemList, component_ItemList(ownEntity, many, hasEdit))
    }

    def private getTemplateName(JoinRelationship it, Boolean useTarget, String editSnippet) {
        var templateName = ''
        if (useTarget && !isManyToMany) {
            //templateName = 'includeCreateChildItem'
            templateName = 'includeSelect' + editSnippet
        } else {
            templateName = 'includeSelect' + editSnippet
        }
        templateName = templateName + getTargetMultiplicity(useTarget)

        templateName
    }

    def private tabTitleForEditTemplate(JoinRelationship it, Entity ownEntity, Boolean many) '''
        «val ownEntityName = ownEntity.getEntityNameSingularPlural(many)»
        <li class="nav-item" role="presentation">
            <a id="«ownEntityName.formatForCode»Tab" href="#tab«ownEntityName.formatForCodeCapital»" title="{{ '«ownEntityName.formatForDisplayCapital»'|trans({}, '«ownEntity.name.formatForCode»')|e('html_attr') }}" role="tab" data-toggle="tab" class="nav-link">{% trans from '«ownEntity.name.formatForCode»' %}«ownEntityName.formatForDisplayCapital»{% endtrans %}</a>
        </li>
    '''

    def private isEmbedded(JoinRelationship it, Boolean useTarget) {
        (if (useTarget) getTargetEditMode else getSourceEditMode) == RelationEditMode.EMBEDDED
    }

    def private includeStatementForEditTemplate(JoinRelationship it, String templateName, Entity ownEntity, Entity linkingEntity, Boolean useTarget, String relationAliasName, String uniqueNameForJs) '''
        {{ include(
            '@«application.vendorAndName»/«ownEntity.name.formatForCodeCapital»/«templateName».html.twig',
            {group: '«linkingEntity.name.formatForDB»', heading: '«getRelationAliasName(useTarget).formatForDisplayCapital»'|trans({}, '«ownEntity.name.formatForCode»'), alias: '«relationAliasName.toFirstLower»', mandatory: «(!nullable).displayBool», idPrefix: '«uniqueNameForJs»', linkingItem: «linkingEntity.name.formatForCode»«IF linkingEntity.useGroupingTabs('edit')», tabs: true«ENDIF», displayMode: '«IF isEmbedded(!useTarget)»embedded«ELSEIF usesAutoCompletion(useTarget)»autocomplete«ELSE»choices«ENDIF»'}
        ) }}
    '''

    def private includedEditTemplate(JoinRelationship it, Entity ownEntity, Entity linkingEntity, Boolean hasEdit, Boolean many) '''
        «val ownEntityName = ownEntity.getEntityNameSingularPlural(many)»
        {# purpose of this template: inclusion template for managing related «ownEntityName.formatForDisplay» #}
        {% if attribute(form, alias) is defined %}
            {% if displayMode is not defined or displayMode is empty %}
                {% set displayMode = 'choices' %}
            {% endif %}
            {% if tabs|default(false) == true %}
                <div role="tabpanel" class="tab-pane fade" id="tab«ownEntityName.formatForCodeCapital»" aria-labelledby="«ownEntityName.formatForCode»Tab">
                    <h3>{{ heading|default ? heading : '«ownEntityName.formatForDisplayCapital»'|trans({}, '«ownEntity.name.formatForCode»') }}</h3>
            {% else %}
                <fieldset class="«ownEntityName.formatForDB»">
            {% endif %}
                <legend>{{ heading|default ? heading : '«ownEntityName.formatForDisplayCapital»'|trans({}, '«ownEntity.name.formatForCode»') }}</legend>
                «IF app.needsInlineEditing»
                    <div id="{{ alias }}InlineEditingContainer">
                        «includedEditTemplateBody(ownEntity, linkingEntity, hasEdit, many)»
                    </div>
                «ELSE»
                    «includedEditTemplateBody(ownEntity, linkingEntity, hasEdit, many)»
                «ENDIF»
            {% if tabs|default(false) == true %}
                </div>
            {% else %}
                </fieldset>
            {% endif %}
        {% endif %}
    '''

    def private includedEditTemplateBody(JoinRelationship it, Entity ownEntity, Entity linkingEntity, Boolean hasEdit, Boolean many) '''
        {% if displayMode == 'embedded' %}
            {% set subFields = attribute(form, alias) %}
            «new Forms().fieldDetails(ownEntity, 'subFields')»
        {% elseif displayMode == 'choices' %}
            {{ form_row(attribute(form, alias), {required: mandatory}) }}
        {% elseif displayMode == 'autocomplete' %}
            {{ form_row(attribute(form, alias), {required: mandatory}) }}
            «component_AutoComplete(ownEntity, many, hasEdit)»
        {% endif %}
    '''

    def private component_AutoComplete(JoinRelationship it, Entity targetEntity, Boolean many, Boolean includeEditing) '''
        <div class="«app.appName.toLowerCase»-relation-leftside">
            «val includeStatement = component_IncludeStatementForAutoCompleterItemList(targetEntity, many, includeEditing)»
            {{ include(
                «includeStatement»,
                attribute(linkingItem, alias) is defined ? {item«IF many»s«ENDIF»: attribute(linkingItem, alias)} : {}
            ) }}
        </div>
        <br style="clear: both" />
    '''

    def private component_IncludeStatementForAutoCompleterItemList(JoinRelationship it, Entity targetEntity, Boolean many, Boolean includeEditing) {
        '''
            '@«application.vendorAndName»/«targetEntity.name.formatForCodeCapital»/includeSelect«IF includeEditing»Edit«ENDIF»ItemList«IF !many»One«ELSE»Many«ENDIF».html.twig'«''»'''
    }

    def private component_ItemList(JoinRelationship it, Entity targetEntity, Boolean many, Boolean includeEditing) '''
        {# purpose of this template: inclusion template for display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» #}
        <ul id="{{ idPrefix }}ReferenceList">
        {% if item«IF many»s«ENDIF» is defined«IF many» and items is iterable«ELSE» and item.getKey()|default«ENDIF» %}
        «IF many»
            {% for item in items %}
        «ENDIF»
        {% set idPrefixItem = idPrefix ~ 'Reference_' ~ item.getKey() %}
        <li id="{{ idPrefixItem }}">
            {{ item|«app.appName.formatForDB»_formattedTitle }}
            «IF includeEditing»
                <a id="{{ idPrefixItem }}Edit" href="{{ path('«app.appName.formatForDB»_«targetEntity.name.formatForDB»_edit'«targetEntity.routeParams('item', true)») }}"><i class="fas fa-edit"></i></a>
            «ENDIF»
             <a id="{{ idPrefixItem }}Remove" href="javascript:«app.vendorAndName»RemoveRelatedItem('{{ idPrefix }}', '{{ item.getKey() }}');"><i class="fas fa-trash-alt"></i></a>
            «IF targetEntity.hasImageFieldsEntity»
                <br />
                «val imageFieldName = targetEntity.getImageFieldsEntity.head.name.formatForCode»
                {% if item.«imageFieldName» is not empty and item.«imageFieldName»Meta.isImage %}
                    <img src="{{ item.«imageFieldName».getPathname()|«app.appName.formatForDB»_relativePath|imagine_filter('zkroot', relationThumbRuntimeOptions) }}" alt="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ relationThumbRuntimeOptions.thumbnail.size[0] }}" height="{{ relationThumbRuntimeOptions.thumbnail.size[1] }}" class="rounded" />
                {% endif %}
            «ENDIF»
        </li>
        «IF many»
            {% endfor %}
        «ENDIF»
        {% endif %}
        </ul>
    '''

    def jsInitDefinitions(Entity it) '''
        «val incomingJoins = getJoinRelationsWithEntities(true).filter[getEditStageCode(true) > 0 && getEditStageCode(true) < 3]»
        «val outgoingJoins = getJoinRelationsWithEntities(false).filter[getEditStageCode(false) > 0 && getEditStageCode(false) < 3]»
        «IF !incomingJoins.empty || !outgoingJoins.empty»
            «FOR relation : incomingJoins»«relation.jsInitDefinition(it, true)»«ENDFOR»
            «FOR relation : outgoingJoins»«relation.jsInitDefinition(it, false)»«ENDFOR»
        «ENDIF»
    '''

    def private jsInitDefinition(JoinRelationship it, Entity targetEntity, Boolean incoming) {
        val useTarget = !incoming
        val stageCode = getEditStageCode(incoming)
        if (stageCode < 1 || (!usesAutoCompletion(useTarget) && stageCode < 2)) {
            return ''''''
        }

        val relationAliasName = getRelationAliasName(!incoming).formatForCodeCapital
        val uniqueNameForJs = getUniqueRelationNameForJs(targetEntity, relationAliasName)
        val linkEntity = if (targetEntity == target) source else target
        '''
            <div class="relation-editing-definition" data-object-type="«linkEntity.name.formatForCode»" data-alias="«relationAliasName.toFirstLower»" data-prefix="«uniqueNameForJs»" data-inline-prefix="«uniqueNameForJs»SelectorDoNew" data-module-name="«linkEntity.application.appName»" data-include-editing="«IF stageCode > 1»1«ELSE»0«ENDIF»" data-input-type="«getFieldTypeForInlineEditing(incoming)»" data-create-url="{{ path('«app.appName.formatForDB»_«linkEntity.name.formatForDB»_edit')|e('html_attr') }}"></div>
        '''
    }

    def private isManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }
}
