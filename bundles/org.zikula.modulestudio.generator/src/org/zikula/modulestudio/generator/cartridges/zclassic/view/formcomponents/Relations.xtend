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

    /**
     * This method creates the templates to be included into the edit forms.
     */
    def generateInclusionTemplate(Entity it, Application app, IFileSystemAccess fsa) '''
        «FOR relation : getEditableJoinRelations(true)»«relation.generate(app, false, true, fsa)»«ENDFOR»
        «FOR relation : getEditableJoinRelations(false)»«relation.generate(app, false, false, fsa)»«ENDFOR»
    '''

    /**
     * Entry point for form sections treating related objects.
     * This method creates the include statement contained in the including template.
     */
    def generateIncludeStatement(Entity it, Application app, IFileSystemAccess fsa) '''
        «FOR relation : getEditableJoinRelations(true)»«relation.generate(app, true, true, fsa)»«ENDFOR»
        «FOR relation : getEditableJoinRelations(false)»«relation.generate(app, true, false, fsa)»«ENDFOR»
    '''

    def private generate(JoinRelationship it, Application app, Boolean onlyInclude, Boolean incoming, IFileSystemAccess fsa) {
        val stageCode = getEditStageCode(incoming)
        if (stageCode < 1) {
            return ''''''
        }

        val useTarget = !incoming
        /*if (useTarget && !isManyToMany) {
            /* Exclude parent view for 1:1 and 1:n for now - see https://github.com/Guite/MostGenerator/issues/10 * /
            return ''''''
        }*/

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
            return includeStatementForEditTemplate(templateName, ownEntity, otherEntity, incoming, relationAliasName, relationAliasReverse, uniqueNameForJs)
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
            templateName = 'includeSelect' + editSnippet
        } else {
            templateName = 'includeSelect' + editSnippet
        }
        templateName = templateName + getTargetMultiplicity(useTarget)

        templateName
    }

    def private includeStatementForEditTemplate(JoinRelationship it, String templateName, Entity ownEntity, Entity linkingEntity, Boolean incoming, String relationAliasName, String relationAliasReverse, String uniqueNameForJs) '''
        {{ include(
            '@«application.appName»/«ownEntity.name.formatForCodeCapital»/«templateName».html.twig',
            { group: '«linkingEntity.name.formatForDB»', alias: '«relationAliasName.toFirstLower»', aliasReverse: '«relationAliasReverse.toFirstLower»', mandatory: «(!nullable).displayBool», idPrefix: '«uniqueNameForJs»', linkingItem: «linkingEntity.name.formatForDB»«IF linkingEntity.useGroupingPanels('edit')», panel: true«ENDIF», displayMode: '«IF usesAutoCompletion(incoming)»autocomplete«ELSE»choices«ENDIF»' }
        ) }}
    '''

    def private includedEditTemplate(JoinRelationship it, Application app, Entity ownEntity, Entity linkingEntity, Boolean incoming, Boolean hasEdit, Boolean many) '''
        «val ownEntityName = ownEntity.getEntityNameSingularPlural(many)»
        {# purpose of this template: inclusion template for managing related «ownEntityName.formatForDisplay» #}
        {% if displayMode is not defined or displayMode is empty %}
            {% set displayMode = 'choices' %}
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
    '''

    def private includedEditTemplateBody(JoinRelationship it, Application app, Entity ownEntity, Entity linkingEntity, Boolean incoming, Boolean hasEdit, Boolean many) '''
        {% if displayMode == 'choices' %}
            {{ form_row(attribute(form, alias)) }}
        {% elseif displayMode == 'autocomplete' %}
            «/*IF !isManyToMany && !incoming»
                «component_ParentEditing(ownEntity, many)»
            «ELSE*/»{{ form_row(attribute(form, alias)) }}
            «component_AutoComplete(app, ownEntity, many, incoming, hasEdit)»«/*ENDIF*/»
        {% endif %}
    '''
/*
    def private component_ParentEditing(JoinRelationship it, Entity targetEntity, Boolean many) '''
        «/* just a reminder for the parent view which is not tested yet (see #10)
            Example: create children (e.g. an address) while creating a parent (e.g. a new customer).
            Problem: address must know the customerid.
            To do only for $mode != create: 
                <p>ADD: button to create «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
                <p>EDIT: display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» with inline editing (form dialog)</p>
        * /»
    '''
*/
    def private component_AutoComplete(JoinRelationship it, Application app, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        <div class="«app.appName.toLowerCase»-relation-leftside">
            «val includeStatement = component_IncludeStatementForAutoCompleterItemList(targetEntity, many, incoming, includeEditing)»
            {{ include(
                «includeStatement»,
                attribute(linkingItem, alias) is defined ? { item«IF many»s«ENDIF»: attribute(linkingItem, alias) } : {}
            ) }}
        </div>
        <br style="clear: both" />
    '''

    def private component_IncludeStatementForAutoCompleterItemList(JoinRelationship it, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) {
        '''
            '@«application.appName»/«targetEntity.name.formatForCodeCapital»/includeSelect«IF includeEditing»Edit«ENDIF»ItemList«IF !many»One«ELSE»Many«ENDIF».html.twig'«''»'''
    }

    def private component_ItemList(JoinRelationship it, Application app, Entity targetEntity, Boolean many, Boolean incoming, Boolean includeEditing) '''
        {# purpose of this template: inclusion template for display of related «targetEntity.getEntityNameSingularPlural(many).formatForDisplay» #}
        «IF includeEditing»
            {% set editImage = '<span class="fa fa-pencil-square-o"></span>' %}
        «ENDIF»
        {% set removeImage = '<span class="fa fa-trash-o"></span>' %}

        <input type="hidden" id="{{ idPrefix }}" name="{{ idPrefix }}" value="{% if item«IF many»s«ENDIF» is defined«IF many» and items is iterable«ELSE»«FOR pkField : targetEntity.getPrimaryKeyFields» and item.«pkField.name.formatForCode» is defined«ENDFOR»«ENDIF» %}«IF many»{% for item in items %}«ENDIF»«FOR pkField : targetEntity.getPrimaryKeyFields SEPARATOR '_'»{{ item.«pkField.name.formatForCode» }}«ENDFOR»«IF many»{% if not loop.last %},{% endif %}{% endfor %}«ENDIF»{% endif %}" />
        <input type="hidden" id="{{ idPrefix }}Mode" name="{{ idPrefix }}Mode" value="«IF includeEditing»1«ELSE»0«ENDIF»" />

        <ul id="{{ idPrefix }}ReferenceList">
        {% if item«IF many»s«ENDIF» is defined«IF many» and items is iterable«ELSE»«FOR pkField : targetEntity.getPrimaryKeyFields» and item.«pkField.name.formatForCode» is defined«ENDFOR»«ENDIF» %}
        «IF many»
            {% for item in items %}
        «ENDIF»
        {% set idPrefixItem = idPrefix ~ 'Reference_'«FOR pkField : targetEntity.getPrimaryKeyFields» ~ item.«pkField.name.formatForCode»«ENDFOR» %}
        <li id="{{ idPrefixItem }}">
            {{ item.getTitleFromDisplayPattern() }}
            «IF includeEditing»
                <a id="{{ idPrefixItem }}Edit" href="{{ path('«app.appName.formatForDB»_«targetEntity.name.formatForDB»_' ~ routeArea ~ 'edit'«targetEntity.routeParams('item', true)») }}">{{ editImage|raw }}</a>
            «ENDIF»
             <a id="{{ idPrefixItem }}Remove" href="javascript:«app.vendorAndName»RemoveRelatedItem('{{ idPrefix }}', '«FOR pkField : targetEntity.getPrimaryKeyFields SEPARATOR '_'»{{ item.«pkField.name.formatForCode» }}«ENDFOR»');">{{ removeImage|raw }}</a>
            «IF targetEntity.hasImageFieldsEntity»
                <br />
                «val imageFieldName = targetEntity.getImageFieldsEntity.head.name.formatForCode»
                {% if item.«imageFieldName» is not empty and item.«imageFieldName»Meta.isImage %}
                    <img src="{{ item.«imageFieldName».getPathname()|imagine_filter('zkroot', relationThumbRuntimeOptions) }}" alt="{{ item.getTitleFromDisplayPattern()|e('html_attr') }}" width="{{ relationThumbRuntimeOptions.thumbnail.size[0] }}" height="{{ relationThumbRuntimeOptions.thumbnail.size[1] }}" class="img-rounded" />
                {% endif %}
            «ENDIF»
        </li>
        «IF many»
            {% endfor %}
        «ENDIF»
        {% endif %}
        </ul>
    '''

    def initJs(Entity it, Application app, Boolean insideLoader) '''
        «val incomingJoins = getEditableJoinRelations(true).filter[usesAutoCompletion(true)]»
        «val outgoingJoins = getEditableJoinRelations(false).filter[usesAutoCompletion(false)]»
        «IF !incomingJoins.empty || !outgoingJoins.empty»
            «IF !insideLoader»
                var editImage = '{{ editImage }}';
                var removeImage = '{{ removeImage }}';
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
        /*if (useTarget && !isManyToMany) {
            /* Exclude parent view for 1:1 and 1:n for now - see https://github.com/Guite/MostGenerator/issues/10 * /
            return ''''''
        }*/

        if (!usesAutoCompletion(incoming)) {
            return ''''''
        }

        val relationAliasName = getRelationAliasName(!incoming).formatForCodeCapital
        val many = isManySide(useTarget)
        val uniqueNameForJs = getUniqueRelationNameForJs(app, targetEntity, many, incoming, relationAliasName)
        val linkEntity = if (targetEntity == target) source else target
        if (!insideLoader) '''
            var newItem = {
                ot: '«linkEntity.name.formatForCode»',«/*alias: '«relationAliasName»',*/»
                prefix: '«uniqueNameForJs»SelectorDoNew',
                moduleName: '«linkEntity.application.appName»',
                acInstance: null,
                windowInstanceId: null
            };
            relationHandler.push(newItem);
        '''
        else '''
            «app.vendorAndName»InitRelationItemsForm('«linkEntity.name.formatForCode»', '«uniqueNameForJs»', «(stageCode > 1).displayBool»);
        '''
    }

    def private isManyToMany(JoinRelationship it) {
        switch it {
            ManyToManyRelationship: true
            default: false
        }
    }
}
