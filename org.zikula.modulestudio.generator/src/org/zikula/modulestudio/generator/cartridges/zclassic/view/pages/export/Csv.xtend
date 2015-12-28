package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Csv {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    SimpleFields fieldHelper = new SimpleFields

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        val templateFilePath = templateFileWithExtension('view', 'csv')
        if (!application.shouldBeSkipped(templateFilePath)) {
            println('Generating csv view templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, if (application.targets('1.3.x')) csvViewLegacy(appName) else csvView(appName))
        }
    }

    def private csvViewLegacy(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view csv view *}
        {«appName.formatForDB»TemplateHeaders contentType='text/comma-separated-values; charset=iso-8859-15' asAttachment=true fileName='«nameMultiple.formatForCodeCapital».csv'}
        {strip}«FOR field : getDisplayFields.filter[name != 'workflowState'] SEPARATOR ';'»«field.headerLine»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{gt text='«geoFieldName.formatForDisplayCapital»'}"«ENDFOR»«ENDIF»«IF softDeleteable»;"{gt text='Deleted at'}"«ENDIF»;"{gt text='Workflow state'}"
        «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.headerLineRelation(true)»«ENDFOR»{/strip}
        «val objName = name.formatForCode»
        {foreach item='«objName»' from=$items}
        {strip}
            «FOR field : getDisplayFields.filter[e|e.name != 'workflowState'] SEPARATOR ';'»«field.displayEntry»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{$«name.formatForCode».«geoFieldName»|«appName.formatForDB»FormatGeoData}"«ENDFOR»«ENDIF»«IF softDeleteable»;"{$«name.formatForCode».deletedAt|dateformat:'datebrief'}"«ENDIF»;"{$«name.formatForCode».workflowState|«appName.formatForDB»ObjectState:false|lower}"
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntry(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayRelatedEntry(true)»«ENDFOR»
            «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntries(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
            «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
        {/strip}
        {/foreach}
    '''

    def private csvView(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view csv view *}
        {{ «appName.formatForDB»_templateHeaders(contentType='text/comma-separated-values; charset=iso-8859-15', asAttachment=true, fileName='«nameMultiple.formatForCodeCapital».csv') }}
        {% spaceless %}«FOR field : getDisplayFields.filter[name != 'workflowState'] SEPARATOR ';'»«field.headerLine»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{{ __('«geoFieldName.formatForDisplayCapital»') }}"«ENDFOR»«ENDIF»«IF softDeleteable»;"{{ __('Deleted at') }}"«ENDIF»;"{{ __('Workflow state') }}"
        «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.headerLineRelation(true)»«ENDFOR»{% endspaceless %}
        «val objName = name.formatForCode»
        {% for «objName» in items %}
        {% spaceless %}
            «FOR field : getDisplayFields.filter[e|e.name != 'workflowState'] SEPARATOR ';'»«field.displayEntry»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{{ «name.formatForCode».«geoFieldName»|«appName.formatForDB»_geoData }}"«ENDFOR»«ENDIF»«IF softDeleteable»;"{{ «name.formatForCode».deletedAt|localizeddate('medium', 'short') }}"«ENDIF»;"{{ «name.formatForCode».workflowState|«appName.formatForDB»_objectState(false)|lower }}"
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntry(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayRelatedEntry(true)»«ENDFOR»
            «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntries(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
            «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
        {% endspaceless %}
        {% endfor %}
    '''

    def private headerLine(DerivedField it) '''
        "«IF entity.application.targets('1.3.x')»{gt text='«name.formatForDisplayCapital»'}«ELSE»{{ __('«name.formatForDisplayCapital»') }}«ENDIF»"'''

    def private headerLineRelation(JoinRelationship it, Boolean useTarget) ''';"«IF application.targets('1.3.x')»{gt text='«getRelationAliasName(useTarget).formatForDisplayCapital»'}«ELSE»{{ __('«getRelationAliasName(useTarget).formatForDisplayCapital»') }}«ENDIF»"'''

    def private dispatch displayEntry(DerivedField it) '''
        "«fieldHelper.displayField(it, entity.name.formatForCode, 'viewcsv')»"'''

    def private dispatch displayEntry(BooleanField it) '''
        "«IF entity.application.targets('1.3.x')»{if !$«entity.name.formatForCode».«name.formatForCode»}0{else}1{/if}«ELSE»{% if «entity.name.formatForCode».«name.formatForCode» != true %}0{% else %}1{% endif %}«ENDIF»"'''

    def private displayRelatedEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (!useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        ;"«IF application.targets('1.3.x')»{if isset($«relObjName») && $«relObjName» ne null}{$«relObjName»->getTitleFromDisplayPattern()|default:''}{/if}«ELSE»{% if «relObjName»|default %}{{ «relObjName».getTitleFromDisplayPattern() }}{% endif %}«ENDIF»"'''

    def private displayRelatedEntries(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (!useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        ;"
        «IF application.targets('1.3.x')»
            {if isset($«relObjName») && $«relObjName» ne null}
                {foreach name='relationLoop' item='relatedItem' from=$«relObjName»}
                {$relatedItem->getTitleFromDisplayPattern()|default:''}{if !$smarty.foreach.relationLoop.last}, {/if}
                {/foreach}
            {/if}
        «ELSE»
            {% if «relObjName»|default %}
                {% for relatedItem in «relObjName» %}
                {{ relatedItem.getTitleFromDisplayPattern() }}{% if loop.last != true %}, {% endif %}
                {% endfor %}
            {% endif %}
        «ENDIF»
        "'''
}
