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
    Boolean isSeparateAdminTemplate

    /**
     * Constructor
     */
    new(IMostFileSystemAccess fsa, Application app, Boolean isAdmin) {
        this.fsa = fsa
        this.app = app
        this.isSeparateAdminTemplate = isAdmin
    }

    /**
     * This method creates the templates to be included into the edit forms.
     */
    def CharSequence generateInclusionTemplate(Entity it) '''
        «FOR relation : getEditableJoinRelations(true)»«relation.generate(false, false, false)»«ENDFOR»
        «FOR relation : getEditableJoinRelations(false)»«relation.generate(false, false, true)»«ENDFOR»
    '''

    /**
     * Entry point for form sections treating related objects.
     * This method creates the tab titles for included relationship sections on edit pages.
     */
    def generateTabTitles(Entity it) '''
        «FOR relation : getEditableJoinRelations(true)»«relation.generate(true, false, false)»«ENDFOR»
        «FOR relation : getEditableJoinRelations(false)»«relation.generate(true, false, true)»«ENDFOR»
    '''

    /**
     * Entry point for form sections treating related objects.
     * This method creates the include statement contained in the including template.
     */
    def generateIncludeStatement(Entity it) '''
        «FOR relation : getEditableJoinRelations(true)»«relation.generate(false, true, false)»«ENDFOR»
        «FOR relation : getEditableJoinRelations(false)»«relation.generate(false, true, true)»«ENDFOR»
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

        if (app.separateAdminTemplates) {
            templateFileName = templateFile(ownEntity, 'Admin/' + templateName)
            templateFileNameItemList = templateFile(ownEntity, 'Admin/' + templateNameItemList)
            fsa.generateFile(templateFileName, includedEditTemplate(ownEntity, otherEntity, hasEdit, many))
            fsa.generateFile(templateFileNameItemList, component_ItemList(ownEntity, many, hasEdit))
        }
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
        <li«IF application.targets('3.0')» class="nav-item"«ENDIF» role="presentation">
            <a id="«ownEntityName.formatForCode»Tab" href="#tab«ownEntityName.formatForCodeCapital»" title="{{ __('«ownEntityName.formatForDisplayCapital»') }}" role="tab" data-toggle="tab"«IF application.targets('3.0')» class="nav-link"«ENDIF»>{{ __('«ownEntityName.formatForDisplayCapital»') }}</a>
        </li>
    '''

    def private isEmbedded(JoinRelationship it, Boolean useTarget) {
        (if (useTarget) getTargetEditMode else getSourceEditMode) == RelationEditMode.EMBEDDED
    }

    def private includeStatementForEditTemplate(JoinRelationship it, String templateName, Entity ownEntity, Entity linkingEntity, Boolean useTarget, String relationAliasName, String uniqueNameForJs) '''
        {{ include(
            '@«application.appName»/«ownEntity.name.formatForCodeCapital»/«IF isSeparateAdminTemplate»Admin/«ENDIF»«templateName».html.twig',
            {group: '«linkingEntity.name.formatForDB»', heading: __('«getRelationAliasName(useTarget).formatForDisplayCapital»'), alias: '«relationAliasName.toFirstLower»', mandatory: «(!nullable).displayBool», idPrefix: '«uniqueNameForJs»', linkingItem: «linkingEntity.name.formatForDB»«IF linkingEntity.useGroupingTabs('edit')», tabs: true«ENDIF», displayMode: '«IF isEmbedded(!useTarget)»embedded«ELSEIF usesAutoCompletion(useTarget)»autocomplete«ELSE»choices«ENDIF»'}
        ) }}
    '''

    def private includedEditTemplate(JoinRelationship it, Entity ownEntity, Entity linkingEntity, Boolean hasEdit, Boolean many) '''
        «val ownEntityName = ownEntity.getEntityNameSingularPlural(many)»
        {# purpose of this template: inclusion template for managing related «ownEntityName.formatForDisplay» #}
        {% if displayMode is not defined or displayMode is empty %}
            {% set displayMode = 'choices' %}
        {% endif %}
        {% if tabs|default(false) == true %}
            <div role="tabpanel" class="tab-pane fade" id="tab«ownEntityName.formatForCodeCapital»" aria-labelledby="«ownEntityName.formatForCode»Tab">
                <h3>{{ heading|default ? heading : __('«ownEntityName.formatForDisplayCapital»') }}</h3>
        {% else %}
            <fieldset class="«ownEntityName.formatForDB»">
        {% endif %}
            <legend>{{ heading|default ? heading : __('«ownEntityName.formatForDisplayCapital»') }}</legend>
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
            '@«application.appName»/«targetEntity.name.formatForCodeCapital»/«IF isSeparateAdminTemplate»Admin/«ENDIF»includeSelect«IF includeEditing»Edit«ENDIF»ItemList«IF !many»One«ELSE»Many«ENDIF».html.twig'«''»'''
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
                <a id="{{ idPrefixItem }}Edit" href="{{ path('«app.appName.formatForDB»_«targetEntity.name.formatForDB»_' ~ routeArea ~ 'edit'«targetEntity.routeParams('item', true)») }}"><i class="fa fa-«IF app.targets('3.0')»edit«ELSE»pencil-square-o«ENDIF»"></i></a>
            «ENDIF»
             <a id="{{ idPrefixItem }}Remove" href="javascript:«app.vendorAndName»RemoveRelatedItem('{{ idPrefix }}', '{{ item.getKey() }}');"><i class="fa fa-trash-«IF app.targets('3.0')»alt«ELSE»o«ENDIF»"></i></a>
            «IF targetEntity.hasImageFieldsEntity»
                <br />
                «val imageFieldName = targetEntity.getImageFieldsEntity.head.name.formatForCode»
                {% if item.«imageFieldName» is not empty and item.«imageFieldName»Meta.isImage %}
                    <img src="{{ item.«imageFieldName».getPathname()|imagine_filter('zkroot', relationThumbRuntimeOptions) }}" alt="{{ item|«app.appName.formatForDB»_formattedTitle|e('html_attr') }}" width="{{ relationThumbRuntimeOptions.thumbnail.size[0] }}" height="{{ relationThumbRuntimeOptions.thumbnail.size[1] }}" class="img-rounded" />
                {% endif %}
            «ENDIF»
        </li>
        «IF many»
            {% endfor %}
        «ENDIF»
        {% endif %}
        </ul>
    '''

    def initJs(Entity it, Boolean insideLoader) '''
        «val incomingJoins = getEditableJoinRelations(true).filter[getEditStageCode(true) > 0 && getEditStageCode(true) < 3]»
        «val outgoingJoins = getEditableJoinRelations(false).filter[getEditStageCode(false) > 0 && getEditStageCode(false) < 3]»
        «IF !incomingJoins.empty || !outgoingJoins.empty»
            «IF !insideLoader»
                var «app.vendorAndName»InlineEditHandlers = [];
                var «app.vendorAndName»EditHandler = null;
            «ENDIF»
            «FOR relation : incomingJoins»«relation.initJs(it, true, insideLoader)»«ENDFOR»
            «FOR relation : outgoingJoins»«relation.initJs(it, false, insideLoader)»«ENDFOR»
        «ENDIF»
    '''

    def private initJs(JoinRelationship it, Entity targetEntity, Boolean incoming, Boolean insideLoader) {
        val useTarget = !incoming
        val stageCode = getEditStageCode(incoming)
        if (stageCode < 1 || (!usesAutoCompletion(useTarget) && stageCode < 2)) {
            return ''''''
        }

        val relationAliasName = getRelationAliasName(!incoming).formatForCodeCapital
        val uniqueNameForJs = getUniqueRelationNameForJs(targetEntity, relationAliasName)
        val linkEntity = if (targetEntity == target) source else target
        if (!insideLoader) '''
            «app.vendorAndName»EditHandler = {
                alias: '«relationAliasName.toFirstLower»',
                prefix: '«uniqueNameForJs»SelectorDoNew',
                moduleName: '«linkEntity.application.appName»',
                objectType: '«linkEntity.name.formatForCode»',
                inputType: '«getFieldTypeForInlineEditing(incoming)»',
                windowInstanceId: null
            };
            «app.vendorAndName»InlineEditHandlers.push(«app.vendorAndName»EditHandler);
        '''
        else '''
            «app.vendorAndName»InitRelationHandling('«linkEntity.name.formatForCode»', '«relationAliasName.toFirstLower»', '«uniqueNameForJs»', «(stageCode > 1).displayBool», '«getFieldTypeForInlineEditing(incoming)»', '{{ path('«app.appName.formatForDB»_«linkEntity.name.formatForDB»_' ~ routeArea ~ 'edit') }}');
        '''
    }

    def private isManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }
}
