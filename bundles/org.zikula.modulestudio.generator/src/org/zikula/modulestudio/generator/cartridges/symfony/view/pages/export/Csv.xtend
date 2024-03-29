package org.zikula.modulestudio.generator.cartridges.symfony.view.pages.export

import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.symfony.view.pagecomponents.SimpleFields
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

    def generate(Entity it, IMostFileSystemAccess fsa) {
        if (!hasIndexAction) {
            return
        }
        ('Generating CSV view templates for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)

        var templateFilePath = templateFileWithExtension('index', 'csv')
        fsa.generateFile(templateFilePath, csvIndex)
    }

    def private csvIndex(Entity it) '''
        {# purpose of this template: «nameMultiple.formatForDisplay» index csv view #}
        {% trans_default_domain '«name.formatForCode»' %}
        «FOR field : getDisplayFields.filter[name != 'workflowState'] SEPARATOR ';'»«field.headerLine»«ENDFOR»«IF hasVisibleWorkflow»;"{% trans %}Workflow state{% endtrans %}"«ENDIF»«headerLinesRelations»
        «val objName = name.formatForCode»
        {% for «objName» in items %}
        «FOR field : getDisplayFields.filter[name != 'workflowState'] SEPARATOR ';'»«field.displayEntry»«ENDFOR»«IF hasVisibleWorkflow»;"{{ «name.formatForCode».workflowState|«application.appName.formatForDB»_objectState(false)|lower }}"«ENDIF»«dataLinesRelations»
        {% endfor %}
    '''

    def private headerLinesRelations(Entity it) {
        var output = ''
        for (relation : incoming.filter(OneToManyRelationship).filter[bidirectional]) output += relation.headerLineRelation(false)
        for (relation : outgoing.filter(OneToOneRelationship)) output += relation.headerLineRelation(true)
        for (relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]) output += relation.headerLineRelation(false)
        for (relation : outgoing.filter(OneToManyRelationship)) output += relation.headerLineRelation(true)
        for (relation : outgoing.filter(ManyToManyRelationship)) output += relation.headerLineRelation(true)
        output
    }
    def private dataLinesRelations(Entity it) {
        var output = ''
        for (relation : incoming.filter(OneToManyRelationship).filter[bidirectional]) output += relation.displayRelatedEntries(false, false)
        for (relation : outgoing.filter(OneToOneRelationship)) output += relation.displayRelatedEntries(true, false)
        for (relation : incoming.filter(ManyToManyRelationship).filter[bidirectional]) output += relation.displayRelatedEntries(false, true)
        for (relation : outgoing.filter(OneToManyRelationship)) output += relation.displayRelatedEntries(true, true)
        for (relation : outgoing.filter(ManyToManyRelationship)) output += relation.displayRelatedEntries(true, true)
        output
    }

    def private headerLine(DerivedField it) '''"{% trans %}«name.formatForDisplayCapital»{% endtrans %}"'''

    def private headerLineRelation(JoinRelationship it, Boolean useTarget) ''';"{% trans %}«getRelationAliasName(useTarget).formatForDisplayCapital»{% endtrans %}"'''

    def private dispatch displayEntry(DerivedField it) '''"«fieldHelper.displayField(it, entity.name.formatForCode, 'viewcsv')»"'''

    def private dispatch displayEntry(BooleanField it) '''"{% if not «entity.name.formatForCode».«name.formatForCode» %}0{% else %}1{% endif %}"'''

    def private displayRelatedEntries(JoinRelationship it, Boolean useTarget, Boolean multiple) {
        val relationAliasName = getRelationAliasName(useTarget).formatForCode
        val mainEntity = (if (!useTarget) target else source)
        val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName
        if (multiple) {
            return ''';"{% if «relObjName»|default %}{% for relatedItem in «relObjName» %}{{ relatedItem|«application.appName.formatForDB»_formattedTitle }}{% if not loop.last %}, {% endif %}{% endfor %}{% endif %}"'''
        }
        return ''';"{% if «relObjName»|default %}{{ «relObjName»|«application.appName.formatForDB»_formattedTitle }}{% endif %}"'''
    }
}
