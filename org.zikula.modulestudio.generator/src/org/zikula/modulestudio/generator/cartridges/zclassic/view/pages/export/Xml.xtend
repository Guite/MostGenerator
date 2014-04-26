package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Xml {

    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    SimpleFields fieldHelper = new SimpleFields

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating xml view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = ''
        if (hasActions('view')) {
            templateFilePath = templateFileWithExtension('view', 'xml')
            if (!container.application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, xmlView(appName))
            }
        }
        if (hasActions('display')) {
            templateFilePath = templateFileWithExtension('display', 'xml')
            if (!container.application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, xmlDisplay(appName))
            }
        }
        templateFilePath = templateFileWithExtension('include', 'xml')
        if (!container.application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, xmlInclude(appName))
        }
    }

    def private xmlView(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view xml view *}
        «IF container.application.targets('1.3.5')»{«appName.formatForDB»TemplateHeaders contentType='text/xml'}«ENDIF»<?xml version="1.0" encoding="{charset}" ?>
        <«nameMultiple.formatForCode»>
        {foreach item='item' from=$items}
            {include file='«name.formatForCode»/include.xml'}
        {foreachelse}
            <no«name.formatForCodeCapital» />
        {/foreach}
        </«nameMultiple.formatForCode»>
    '''

    def private xmlDisplay(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» display xml view *}
        «IF container.application.targets('1.3.5')»{«appName.formatForDB»TemplateHeaders contentType='text/xml'}«ENDIF»<?xml version="1.0" encoding="{charset}" ?>
        {getbaseurl assign='baseurl'}
        {include file='«name.formatForCode»/include.xml' item=$«name.formatForCode»}
    '''

    def private xmlInclude(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» xml inclusion template *}
        <«name.formatForDB»«FOR pkField : getPrimaryKeyFields» «pkField.name.formatForCode»="{$item.«pkField.name.formatForCode»}"«ENDFOR»«IF standardFields» createdon="{$item.createdDate|dateformat}" updatedon="{$item.updatedDate|dateformat}"«ENDIF»>
            «FOR field : getDerivedFields.filter[primaryKey]»«field.displayEntry»«ENDFOR»
            «FOR field : getDerivedFields.filter[!primaryKey && name != 'workflowState']»«field.displayEntry»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    <«geoFieldName»>{$item.«geoFieldName»|«appName.formatForDB»FormatGeoData}</«geoFieldName»>
                «ENDFOR»
            «ENDIF»
            «IF softDeleteable»
                <deletedAt>{$item.deletedAt|dateformat:'datebrief'}</deletedAt>
            «ENDIF»
            <workflowState>{$item.workflowState|«appName.formatForDB»ObjectState:false|lower}</workflowState>
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntry(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayRelatedEntry(true)»«ENDFOR»
            «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntries(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
            «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
        </«name.formatForDB»>
    '''

    def private dispatch displayEntry(DerivedField it) '''
        <«name.formatForCode»>«fieldHelper.displayField(it, 'item', 'viewxml')»</«name.formatForCode»>
    '''

    def private dispatch displayEntry(BooleanField it) '''
        <«name.formatForCode»>{if !$item.«name.formatForCode»}0{else}1{/if}</«name.formatForCode»>
    '''

    def private displayEntryCdata(DerivedField it) '''
        <«name.formatForCode»><![CDATA[«fieldHelper.displayField(it, 'item', 'viewxml')»]]></«name.formatForCode»>
    '''

    def private dispatch displayEntry(StringField it) {
        displayEntryCdata
    }
    def private dispatch displayEntry(TextField it) {
        displayEntryCdata
    }

    def private dispatch displayEntry(UploadField it) '''
        <«name.formatForCode»«fieldHelper.displayField(it, 'item', 'viewxml')»</«name.formatForCode»>
    '''

    def private displayRelatedEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val relObjName = 'item.' + relationAliasName»
        <«relationAliasName.toFirstLower»>{if isset($«relObjName») && $«relObjName» ne null}{$«relObjName»->getTitleFromDisplayPattern()|default:''}{/if}</«relationAliasName.toFirstLower»>
    '''

    def private displayRelatedEntries(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val linkEntity = (if (useTarget) target else source)»
        «val relObjName = 'item.' + relationAliasName»
        <«relationAliasName.toFirstLower»>
        {if isset($«relObjName») && $«relObjName» ne null}
            {foreach name='relationLoop' item='relatedItem' from=$«relObjName»}
            <«linkEntity.name.formatForCode»>{$relatedItem->getTitleFromDisplayPattern()|default:''}</«linkEntity.name.formatForCode»>
            {/foreach}
        {/if}
        </«relationAliasName.toFirstLower»>
    '''
}
