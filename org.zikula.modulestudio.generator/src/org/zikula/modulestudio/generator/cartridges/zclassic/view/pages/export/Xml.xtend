package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.Controller
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

class Xml {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    SimpleFields fieldHelper = new SimpleFields()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' xml view templates for entity "' + name.formatForDisplay + '"')
        if (controller.hasActions('view'))
            fsa.generateFile(templateFileWithExtension(controller, name, 'view', 'xml'), xmlView(appName, controller))
        if (controller.hasActions('display'))
            fsa.generateFile(templateFileWithExtension(controller, name, 'display', 'xml'), xmlDisplay(appName, controller))
        fsa.generateFile(templateFileWithExtension(controller, name, 'include', 'xml'), xmlInclude(appName, controller))
    }

    def private xmlView(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» view xml view in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='text/xml'}<?xml version="1.0" encoding="{charset}" ?>
        <«nameMultiple.formatForCode»>
        {foreach item='item' from=$items}
            {include file='«controller.formattedName»/«objName»/include.xml'}
        {foreachelse}
            <no«name.formatForCodeCapital» />
        {/foreach}
        </«nameMultiple.formatForCode»>
    '''

    def private xmlDisplay(Entity it, String appName, Controller controller) '''
        «val objName = name.formatForCode»
        {* purpose of this template: «nameMultiple.formatForDisplay» display xml view in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='text/xml'}<?xml version="1.0" encoding="{charset}" ?>
        {getbaseurl assign='baseurl'}
        {include file='«controller.formattedName»/«objName»/include.xml' item=$«objName»}
    '''

    def private xmlInclude(Entity it, String appName, Controller controller) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» xml inclusion template in «controller.formattedName» area *}
        <«name.formatForDB»«FOR pkField : getPrimaryKeyFields» «pkField.name.formatForCode»="{$item.«pkField.name.formatForCode»}"«ENDFOR»«IF standardFields» createdon="{$item.createdDate|dateformat}" updatedon="{$item.updatedDate|dateformat}"«ENDIF»>
            «FOR field : getDerivedFields.filter(e|e.primaryKey)»«field.displayEntry(controller)»«ENDFOR»
            «FOR field : getDerivedFields.filter(e|!e.primaryKey && e.name != 'workflowState')»«field.displayEntry(controller)»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    <«geoFieldName»>{$item.«geoFieldName»|formatnumber:7}</«geoFieldName»>
                «ENDFOR»
            «ENDIF»
            <workflowState>{$item.workflowState|«appName.formatForDB»ObjectState:false|lower}</workflowState>
            «FOR relation : incoming.filter(typeof(OneToManyRelationship)).filter(e|e.bidirectional)»«relation.displayRelatedEntry(controller, false)»«ENDFOR»
            «FOR relation : outgoing.filter(typeof(OneToOneRelationship))»«relation.displayRelatedEntry(controller, true)»«ENDFOR»
            «FOR relation : incoming.filter(typeof(ManyToManyRelationship)).filter(e|e.bidirectional)»«relation.displayRelatedEntries(controller, false)»«ENDFOR»
            «FOR relation : outgoing.filter(typeof(OneToManyRelationship))»«relation.displayRelatedEntries(controller, true)»«ENDFOR»
            «FOR relation : outgoing.filter(typeof(ManyToManyRelationship))»«relation.displayRelatedEntries(controller, true)»«ENDFOR»
        </«name.formatForDB»>
    '''

    def private dispatch displayEntry(DerivedField it, Controller controller) '''
        <«name.formatForCode»>«fieldHelper.displayField(it, 'item', 'viewxml')»</«name.formatForCode»>
    '''

    def private dispatch displayEntry(BooleanField it, Controller controller) '''
        <«name.formatForCode»>{if !$item.«name.formatForCode»}0{else}1{/if}</«name.formatForCode»>
    '''

    def private displayEntryCdata(DerivedField it, Controller controller) '''
        <«name.formatForCode»><![CDATA[«fieldHelper.displayField(it, 'item', 'viewxml')»]]></«name.formatForCode»>
    '''

    def private dispatch displayEntry(StringField it, Controller controller) {
        displayEntryCdata(controller)
    }
    def private dispatch displayEntry(TextField it, Controller controller) {
        displayEntryCdata(controller)
    }

    def private dispatch displayEntry(UploadField it, Controller controller) '''
        <«name.formatForCode»«fieldHelper.displayField(it, 'item', 'viewxml')»</«name.formatForCode»>
    '''

    def private displayRelatedEntry(JoinRelationship it, Controller controller, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val linkEntity = (if (useTarget) target else source)»
        «val relObjName = 'item.' + relationAliasName»
        «val leadingField = linkEntity.getLeadingField»
        «IF leadingField != null»
            <«relationAliasName.toFirstLower»>{if isset($«relObjName») && $«relObjName» ne null}{$«relObjName».«leadingField.name.formatForCode»«/*|nl2br*/»|default:''}{/if}</«relationAliasName.toFirstLower»>
        «ELSE»
            «linkEntity.name.formatForDisplay»
        «ENDIF»
    '''

    def private displayRelatedEntries(JoinRelationship it, Controller controller, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val linkEntity = (if (useTarget) target else source)»
        «val relObjName = 'item.' + relationAliasName»
        «val leadingField = linkEntity.getLeadingField»
        «IF leadingField != null»
            <«relationAliasName.toFirstLower»>
            {if isset($«relObjName») && $«relObjName» ne null}
                {foreach name='relationLoop' item='relatedItem' from=$«relObjName»}
                <«linkEntity.name.formatForCode»>{$relatedItem.«leadingField.name.formatForCode»«/*|nl2br*/»|default:''}</«linkEntity.name.formatForCode»>
                {/foreach}
            {/if}
            </«relationAliasName.toFirstLower»>
        «ELSE»
            «linkEntity.nameMultiple.formatForDisplay»
        «ENDIF»
    '''
}
