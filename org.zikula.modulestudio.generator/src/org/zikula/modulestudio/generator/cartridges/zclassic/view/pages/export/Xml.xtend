package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Xml {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    SimpleFields fieldHelper = new SimpleFields

    def generate(Entity it, String appName, IFileSystemAccess fsa) {
        println('Generating xml view templates for entity "' + name.formatForDisplay + '"')
        var templateFilePath = ''
        if (hasActions('view')) {
            templateFilePath = templateFileWithExtension('view', 'xml')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, if (application.targets('1.3.x')) xmlViewLegacy(appName) else xmlView(appName))
            }
        }
        if (hasActions('display')) {
            templateFilePath = templateFileWithExtension('display', 'xml')
            if (!application.shouldBeSkipped(templateFilePath)) {
                fsa.generateFile(templateFilePath, if (application.targets('1.3.x')) xmlDisplayLegacy(appName) else xmlDisplay(appName))
            }
        }
        templateFilePath = templateFileWithExtension('include', 'xml')
        if (!application.shouldBeSkipped(templateFilePath)) {
            fsa.generateFile(templateFilePath, if (application.targets('1.3.x')) xmlIncludeLegacy(appName) else xmlInclude(appName))
        }
    }

    def private xmlViewLegacy(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» view xml view *}
        {«appName.formatForDB»TemplateHeaders contentType='text/xml'}<?xml version="1.0" encoding="{charset}" ?>
        <«nameMultiple.formatForCode»>
        {foreach item='«name.formatForCode»' from=$items}
            {include file='«name.formatForCode»/include.xml.tpl'}
        {foreachelse}
            <no«name.formatForCodeCapital» />
        {/foreach}
        </«nameMultiple.formatForCode»>
    '''

    def private xmlView(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» view xml view #}
        {{ «appName.formatForDB»_templateHeaders(contentType='text/xml') }}<?xml version="1.0" encoding="{{ pageGetVar('meta.charset') }}" ?>
        <«nameMultiple.formatForCode»>
        {% for «name.formatForCode» in items %}
            {{ include('@«application.appName»/«name.formatForCodeCapital»/include.xml.twig') }}
        {% else %}
            <no«name.formatForCodeCapital» />
        {% endfor %}
        </«nameMultiple.formatForCode»>
    '''

    def private xmlDisplayLegacy(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» display xml view *}
        {«appName.formatForDB»TemplateHeaders contentType='text/xml'}<?xml version="1.0" encoding="{charset}" ?>
        {include file='«name.formatForCode»/include.xml.tpl' item=$«name.formatForCode»}
    '''

    def private xmlDisplay(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» display xml view #}
        {{ «appName.formatForDB»_templateHeaders(contentType='text/xml') }}<?xml version="1.0" encoding="{{ pageGetVar('meta.charset') }}" ?>
        {{ include('@«application.appName»/«name.formatForCodeCapital»/include.xml.twig') }}
    '''

    def private xmlIncludeLegacy(Entity it, String appName) '''
        {* purpose of this template: «nameMultiple.formatForDisplay» xml inclusion template *}
        <«name.formatForDB»«FOR pkField : getPrimaryKeyFields» «pkField.name.formatForCode»="{$«name.formatForCode».«pkField.name.formatForCode»}"«ENDFOR»«IF standardFields» createdon="{$«name.formatForCode».createdDate|dateformat}" updatedon="{$«name.formatForCode».updatedDate|dateformat}"«ENDIF»>
            «FOR field : getDerivedFields.filter[primaryKey]»«field.displayEntry»«ENDFOR»
            «FOR field : getDerivedFields.filter[!primaryKey && name != 'workflowState']»«field.displayEntry»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    <«geoFieldName»>{$«name.formatForCode».«geoFieldName»|«appName.formatForDB»FormatGeoData}</«geoFieldName»>
                «ENDFOR»
            «ENDIF»
            «IF softDeleteable»
                <deletedAt>{$«name.formatForCode».deletedAt|dateformat:'datebrief'}</deletedAt>
            «ENDIF»
            <workflowState>{$«name.formatForCode».workflowState|«appName.formatForDB»ObjectState:false|lower}</workflowState>
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntry(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayRelatedEntry(true)»«ENDFOR»
            «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntries(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
            «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
        </«name.formatForDB»>
    '''

    def private xmlInclude(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» xml inclusion template #}
        <«name.formatForDB»«FOR pkField : getPrimaryKeyFields» «pkField.name.formatForCode»="{{ «name.formatForCode».«pkField.name.formatForCode» }}"«ENDFOR»«IF standardFields» createdon="{{ «name.formatForCode».createdDate|localizeddate('medium', 'short') }}" updatedon="{{ «name.formatForCode».updatedDate|localizeddate('medium', 'short') }}"«ENDIF»>
            «FOR field : getDerivedFields.filter[primaryKey]»«field.displayEntry»«ENDFOR»
            «FOR field : getDerivedFields.filter[!primaryKey && name != 'workflowState']»«field.displayEntry»«ENDFOR»
            «IF geographical»
                «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                    <«geoFieldName»>{{ «name.formatForCode».«geoFieldName»|«appName.formatForDB»_geoData }}</«geoFieldName»>
                «ENDFOR»
            «ENDIF»
            «IF softDeleteable»
                <deletedAt>{{ «name.formatForCode».deletedAt|localizeddate('medium', 'short') }}</deletedAt>
            «ENDIF»
            <workflowState>{{ «name.formatForCode».workflowState|«appName.formatForDB»_objectState(false)|lower }}</workflowState>
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntry(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayRelatedEntry(true)»«ENDFOR»
            «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntries(false)»«ENDFOR»
            «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
            «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
        </«name.formatForDB»>
    '''

    def private dispatch displayEntry(DerivedField it) '''
        <«name.formatForCode»>«fieldHelper.displayField(it, entity.name.formatForCode, 'viewxml')»</«name.formatForCode»>
    '''

    def private dispatch displayEntry(BooleanField it) '''
        «IF entity.application.targets('1.3.x')»
            <«name.formatForCode»>{if !$«entity.name.formatForCode».«name.formatForCode»}0{else}1{/if}</«name.formatForCode»>
        «ELSE»
            <«name.formatForCode»>{% if «entity.name.formatForCode».«name.formatForCode» != true %}0{% else %}1{% endif %}</«name.formatForCode»>
        «ENDIF»
    '''

    def private displayEntryCdata(DerivedField it) '''
        <«name.formatForCode»><![CDATA[«fieldHelper.displayField(it, entity.name.formatForCode, 'viewxml')»]]></«name.formatForCode»>
    '''

    def private dispatch displayEntry(StringField it) {
        displayEntryCdata
    }
    def private dispatch displayEntry(TextField it) {
        displayEntryCdata
    }

    def private dispatch displayEntry(UploadField it) '''
        <«name.formatForCode»«fieldHelper.displayField(it, entity.name.formatForCode, 'viewxml')»</«name.formatForCode»>
    '''

    def private displayRelatedEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val relObjName = (if (useTarget) source else target).name.formatForCode + '.' + relationAliasName»
        «IF application.targets('1.3.x')»
            <«relationAliasName.toFirstLower»>{if isset($«relObjName») && $«relObjName» ne null}{$«relObjName»->getTitleFromDisplayPattern()|default:''}{/if}</«relationAliasName.toFirstLower»>
        «ELSE»
            <«relationAliasName.toFirstLower»>{% if «relObjName»|default %}{{ «relObjName».getTitleFromDisplayPattern() }}{% endif %}</«relationAliasName.toFirstLower»>
        «ENDIF»
    '''

    def private displayRelatedEntries(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val relObjName = (if (useTarget) source else target).name.formatForCode + '.' + relationAliasName»
        «val linkEntity = (if (useTarget) target else source)»
        <«relationAliasName.toFirstLower»>
        «IF application.targets('1.3.x')»
            {if isset($«relObjName») && $«relObjName» ne null}
                {foreach name='relationLoop' item='relatedItem' from=$«relObjName»}
                <«linkEntity.name.formatForCode»>{$relatedItem->getTitleFromDisplayPattern()|default:''}</«linkEntity.name.formatForCode»>
                {/foreach}
            {/if}
        «ELSE»
            {% if «relObjName»|default %}
                {% for relatedItem in «relObjName» %}
                <«linkEntity.name.formatForCode»>{{ relatedItem.getTitleFromDisplayPattern() }}</«linkEntity.name.formatForCode»>
                {% endfor %}
            {% endif %}
        «ENDIF»
        </«relationAliasName.toFirstLower»>
    '''
}
