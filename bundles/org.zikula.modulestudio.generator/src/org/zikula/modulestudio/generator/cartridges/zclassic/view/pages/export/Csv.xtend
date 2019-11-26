package org.zikula.modulestudio.generator.cartridges.zclassic.view.pages.export

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Csv {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    SimpleFields fieldHelper = new SimpleFields

    def generate(Entity it, String appName, IMostFileSystemAccess fsa) {
        if (!hasViewAction) {
            return
        }
        ('Generating CSV view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFileWithExtension('view', 'csv')
        fsa.generateFile(templateFilePath, csvView(appName))

        if (application.separateAdminTemplates) {
            templateFilePath = templateFileWithExtension('Admin/view', 'csv')
            fsa.generateFile(templateFilePath, csvView(appName))
        }
    }

    def private csvView(Entity it, String appName) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» view csv view #}
        «FOR field : getDisplayFields.filter[name != 'workflowState'] SEPARATOR ';'»«field.headerLine»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{{ __('«geoFieldName.formatForDisplayCapital»') }}"«ENDFOR»«ENDIF»«IF hasVisibleWorkflow»;"{{ __('Workflow state') }}"«ENDIF»«headerLinesRelations»
        «val objName = name.formatForCode»
        {% for «objName» in items %}
        «FOR field : getDisplayFields.filter[f|f.name != 'workflowState'] SEPARATOR ';'»«field.displayEntry»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{{ «name.formatForCode».«geoFieldName»|«appName.formatForDB»_geoData }}"«ENDFOR»«ENDIF»«IF hasVisibleWorkflow»;"{{ «name.formatForCode».workflowState|«appName.formatForDB»_objectState(false)|lower }}"«ENDIF»«dataLinesRelations»
        {% endfor %}
    '''

    def private headerLinesRelations(Entity it) '''
        «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.headerLineRelation(true)»«ENDFOR»
    '''
    def private dataLinesRelations(Entity it) '''
        «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntry(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToOneRelationship)»«relation.displayRelatedEntry(true)»«ENDFOR»
        «FOR relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]»«relation.displayRelatedEntries(false)»«ENDFOR»
        «FOR relation : outgoing.filter(OneToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
        «FOR relation : outgoing.filter(ManyToManyRelationship)»«relation.displayRelatedEntries(true)»«ENDFOR»
    '''

    def private headerLine(DerivedField it) '''
        "{{ __('«name.formatForDisplayCapital»') }}"'''

    def private headerLineRelation(JoinRelationship it, Boolean useTarget) ''';"{{ __('«getRelationAliasName(useTarget).formatForDisplayCapital»') }}"'''

    def private dispatch displayEntry(DerivedField it) '''
        "«fieldHelper.displayField(it, entity.name.formatForCode, 'viewcsv')»"'''

    def private dispatch displayEntry(BooleanField it) '''
        "{% if not «entity.name.formatForCode».«name.formatForCode» %}0{% else %}1{% endif %}"'''

    def private displayRelatedEntry(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val mainEntity = (if (!useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        ;"{% if «relObjName»|default %}{{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}{% endif %}"'''

    def private displayRelatedEntries(JoinRelationship it, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCode»
        «val mainEntity = (if (!useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        ;"{% if «relObjName»|default %}{% for relatedItem in «relObjName» %}{{ relatedItem|«application.appName.formatForDB»_formattedTitle }}{% if not loop.last %}, {% endif %}{% endfor %}{% endif %}"'''
}
