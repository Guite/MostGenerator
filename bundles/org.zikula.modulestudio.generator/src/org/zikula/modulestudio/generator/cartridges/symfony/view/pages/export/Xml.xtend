package org.zikula.modulestudio.generator.cartridges.symfony.view.pages.export

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
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Xml {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    SimpleFields fieldHelper = new SimpleFields

    def generate(Entity it, IMostFileSystemAccess fsa) {
        if (!(hasIndexAction || hasDetailAction)) {
            return
        }
        ('Generating XML view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        var templateFilePath = ''
        if (hasIndexAction) {
            templateFilePath = templateFileWithExtension('index', 'xml')
            fsa.generateFile(templateFilePath, xmlIndex)
        }
        if (hasDetailAction) {
            templateFilePath = templateFileWithExtension('detail', 'xml')
            fsa.generateFile(templateFilePath, xmlDetail)
        }
        templateFilePath = templateFileWithExtension('include', 'xml')
        fsa.generateFile(templateFilePath, xmlInclude)
    }

    def private xmlIndex(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» index xml view #}
        {% trans_default_domain '«name.formatForCode»' %}
        <?xml version="1.0" encoding="{{ pageGetVar('meta.charset')|default('utf-8') }}" ?>
        <«nameMultiple.formatForCode»>
        {% for «name.formatForCode» in items %}
            {{ include('@«application.vendorAndName»/«name.formatForCodeCapital»/include.xml.twig') }}
        {% else %}
            <no«name.formatForCodeCapital» />
        {% endfor %}
        </«nameMultiple.formatForCode»>
    '''

    def private xmlDetail(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» detail xml view #}
        {% trans_default_domain '«name.formatForCode»' %}
        <?xml version="1.0" encoding="{{ pageGetVar('meta.charset') }}" ?>
        {{ include('@«application.vendorAndName»/«name.formatForCodeCapital»/include.xml.twig') }}
    '''

    def private xmlInclude(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» xml inclusion template #}
        {% trans_default_domain '«name.formatForCode»' %}
        <«name.formatForDB» «getPrimaryKey.name.formatForCode»="{{ «name.formatForCode».get«getPrimaryKey.name.formatForCodeCapital»() }}">
            «FOR field : getDerivedFields.filter[primaryKey]»«field.displayEntry»«ENDFOR»
            «FOR field : getDerivedFields.filter[!primaryKey && name != 'workflowState']»«field.displayEntry»«ENDFOR»
            «IF hasVisibleWorkflow»
                <workflowState>{{ «name.formatForCode».workflowState|«application.appName.formatForDB»_objectState(false)|lower }}</workflowState>
            «ENDIF»
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
        <«name.formatForCode»>{% if «entity.name.formatForCode».«name.formatForCode» %}1{% else %}0{% endif %}</«name.formatForCode»>
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
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val relObjName = (if (useTarget) source else target).name.formatForCode + '.' + relationAliasName»
        <«relationAliasName.toFirstLower»>{% if «relObjName»|default %}{{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}{% endif %}</«relationAliasName.toFirstLower»>
    '''

    def private displayRelatedEntries(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val relObjName = (if (useTarget) source else target).name.formatForCode + '.' + relationAliasName»
        «val linkEntity = (if (useTarget) target else source)»
        <«relationAliasName.toFirstLower»>
        {% if «relObjName»|default %}
            {% for relatedItem in «relObjName» %}
            <«linkEntity.name.formatForCode»>{{ relatedItem|«application.appName.formatForDB»_formattedTitle }}</«linkEntity.name.formatForCode»>
            {% endfor %}
        {% endif %}
        </«relationAliasName.toFirstLower»>
    '''
}
