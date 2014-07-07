package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship
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
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            println('Generating csv view templates for entity "' + name.formatForDisplay + '"')
            fsa.generateFile(templateFilePath, csvView(appName))
        }
    }

    def private csvView(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view csv view *}
        «IF container.application.targets('1.3.5')»
            {«appName.formatForDB»TemplateHeaders contentType='text/comma-separated-values; charset=iso-8859-15' asAttachment=true filename='«nameMultiple.formatForCodeCapital».csv'}
        «ENDIF»
        {strip}«FOR field : getDisplayFields.filter[name != 'workflowState'] SEPARATOR ';'»«field.headerLine»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{gt text='«geoFieldName.formatForDisplayCapital»'}"«ENDFOR»«ENDIF»«IF softDeleteable»;"{gt text='Deleted at'}"«ENDIF»;"{gt text='Workflow state'}"
        «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.headerLineRelation(true)»«ENDFOR»{/strip}
        «val objName = name.formatForCode»
        {foreach item='«objName»' from=$items}
        {strip}
            «FOR field : getDisplayFields.filter[e|e.name != 'workflowState'] SEPARATOR ';'»«field.displayEntry»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{$«name.formatForCode».«geoFieldName»|«appName.formatForDB»FormatGeoData}"«ENDFOR»«ENDIF»«IF softDeleteable»;"{$item.deletedAt|dateformat:'datebrief'}"«ENDIF»;"{$item.workflowState|«appName.formatForDB»ObjectState:false|lower}"
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntry(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayRelatedEntry(true)»«ENDFOR»
            «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntries(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
            «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
        {/strip}
        {/foreach}
    '''

    def private headerLine(DerivedField it) '''
        "{gt text='«name.formatForDisplayCapital»'}"'''

    def private headerLineRelation(JoinRelationship it, Boolean useTarget) ''';"{gt text='«getRelationAliasName(useTarget).formatForDisplayCapital»'}"'''

    def private dispatch displayEntry(DerivedField it) '''
        "«fieldHelper.displayField(it, entity.name.formatForCode, 'viewcsv')»"'''

    def private dispatch displayEntry(BooleanField it) '''
        "{if !$«entity.name.formatForCode».«name.formatForCode»}0{else}1{/if}"'''

    def private displayRelatedEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (!useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        ;"{if isset($«relObjName») && $«relObjName» ne null}{$«relObjName»->getTitleFromDisplayPattern()|default:''}{/if}"'''

    def private displayRelatedEntries(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (!useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        ;"
            {if isset($«relObjName») && $«relObjName» ne null}
                {foreach name='relationLoop' item='relatedItem' from=$«relObjName»}
                {$relatedItem->getTitleFromDisplayPattern()|default:''}{if !$smarty.foreach.relationLoop.last}, {/if}
                {/foreach}
            {/if}
        "'''
}
