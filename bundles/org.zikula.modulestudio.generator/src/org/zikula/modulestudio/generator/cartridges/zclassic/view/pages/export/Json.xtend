package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Json {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    SimpleFields fieldHelper = new SimpleFields

    def generate(Entity it, IMostFileSystemAccess fsa) {
        if (!(hasViewAction || hasDisplayAction)) {
            return
        }
        ('Generating JSON view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        var templateFilePath = ''
        if (hasViewAction) {
            templateFilePath = templateFileWithExtension('view', 'json')
            fsa.generateFile(templateFilePath, jsonView)
        }
        if (hasDisplayAction) {
            templateFilePath = templateFileWithExtension('display', 'json')
            fsa.generateFile(templateFilePath, jsonDisplay)
        }
        templateFilePath = templateFileWithExtension('include', 'json')
        fsa.generateFile(templateFilePath, jsonInclude)
    }

    def private jsonView(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» view json view #}
        «IF !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        [
        {% for «name.formatForCode» in items %}
            {% if not loop.first %},{% endif %}
            {
                {{ include('@«application.appName»/«name.formatForCodeCapital»/include.json.twig') }}
            }
        {% endfor %}
        ]
    '''

    def private jsonDisplay(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» display json view #}
        «IF !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        {
            {{ include('@«application.appName»/«name.formatForCodeCapital»/include.json.twig') }}
        }
    '''

    def private jsonInclude(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» json inclusion template #}
        «IF !application.isSystemModule»
            {% trans_default_domain '«name.formatForCode»' %}
        «ENDIF»
        «FOR field : getDerivedFields.filter[primaryKey]»«field.displayEntry»,«ENDFOR»
        «IF standardFields»
            "createdOn": "{{ «name.formatForCode».createdDate|format_datetime('medium', 'short') }}",
            "updatedOn": "{{ «name.formatForCode».updatedDate|format_datetime('medium', 'short') }}",
        «ENDIF»
        «FOR field : getDerivedFields.filter[!primaryKey && name != 'workflowState']»«field.displayEntry»,«ENDFOR»
        «IF geographical»
            «FOR geoFieldName : newArrayList('latitude', 'longitude')»
                "«geoFieldName»": "{{ «name.formatForCode».«geoFieldName»|«application.appName.formatForDB»_geoData }}",
            «ENDFOR»
        «ENDIF»
        «IF hasVisibleWorkflow»
            "workflowState": "{{ «name.formatForCode».workflowState|«application.appName.formatForDB»_objectState(false)|lower }}",
        «ENDIF»
        «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntry(false)»,«ENDFOR»
        «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayRelatedEntry(true)»,«ENDFOR»
        «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntries(false)»,«ENDFOR»
        «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.displayRelatedEntries(true)»,«ENDFOR»
        «FOR relation : outgoing.filter(ManyToManyRelationship) SEPARATOR ','»«relation.displayRelatedEntries(true)»«ENDFOR»
    '''

    def private dispatch displayEntry(DerivedField it) '''
        "«name.formatForCode»": "«fieldHelper.displayField(it, entity.name.formatForCode, 'viewjson')»"
    '''

    def private dispatch displayEntry(BooleanField it) '''
        "«name.formatForCode»": {% if «entity.name.formatForCode».«name.formatForCode» %}true{% else %}false{% endif %}
    '''

    def private dispatch displayEntry(UploadField it) '''
        "«name.formatForCode»": {«fieldHelper.displayField(it, entity.name.formatForCode, 'viewjson')»}
    '''

    def private displayRelatedEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val relObjName = (if (useTarget) source else target).name.formatForCode + '.' + relationAliasName»
        "«relationAliasName.toFirstLower»": "{% if «relObjName»|default %}{{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}{% endif %}"
    '''

    def private displayRelatedEntries(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val relObjName = (if (useTarget) source else target).name.formatForCode + '.' + relationAliasName»
        «/*val linkEntity = (if (useTarget) target else source)*/»
        "«relationAliasName.toFirstLower»": [
            {% if «relObjName»|default %}
                {% for relatedItem in «relObjName» %}
                    {
                        "key": "{{ relatedItem.getKey() }}",
                        "title": "{{ relatedItem|«application.appName.formatForDB»_formattedTitle }}"
                    }{% if not loop.last %},{% endif %}
                {% endfor %}
            {% endif %}
        ]
    '''
}
