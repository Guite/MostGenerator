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
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.view.pagecomponents.SimpleFields
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Csv {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    SimpleFields fieldHelper = new SimpleFields()

    def generate(Entity it, String appName, Controller controller, IFileSystemAccess fsa) {
        println('Generating ' + controller.formattedName + ' csv view templates for entity "' + name.formatForDisplay + '"')
        fsa.generateFile(templateFileWithExtension(controller, name, 'view', 'csv'), csvView(appName, controller))
    }

    def private csvView(Entity it, String appName, Controller controller) '''
        «val displayFields = getDisplayFields»
        {* purpose of this template: «nameMultiple.formatForDisplay» view csv view in «controller.formattedName» area *}
        {«appName.formatForDB»TemplateHeaders contentType='text/comma-separated-values; charset=iso-8859-15' asAttachment=true filename='«nameMultiple.formatForCodeCapital».csv'}
        «FOR field : displayFields SEPARATOR ';'»«field.headerLine»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"«geoFieldName.toFirstUpper»"«ENDFOR»«ENDIF»
        «FOR relation : incoming.filter(typeof(OneToManyRelationship)).filter(e|e.bidirectional)»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(typeof(OneToOneRelationship))»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : incoming.filter(typeof(ManyToManyRelationship)).filter(e|e.bidirectional)»«relation.headerLineRelation(false)»«ENDFOR»
        «FOR relation : outgoing.filter(typeof(OneToManyRelationship))»«relation.headerLineRelation(true)»«ENDFOR»
        «FOR relation : outgoing.filter(typeof(ManyToManyRelationship))»«relation.headerLineRelation(true)»«ENDFOR»
        «val objName = name.formatForCode»
        {foreach item='«objName»' from=$items}
            «FOR field : displayFields SEPARATOR ';'»«field.displayEntry(controller)»«ENDFOR»«IF geographical»«FOR geoFieldName : newArrayList('latitude', 'longitude')»;"{$«name.formatForCode».«geoFieldName»|formatnumber:7}"«ENDFOR»«ENDIF»
            «FOR relation : incoming.filter(typeof(OneToManyRelationship)).filter(e|e.bidirectional)»«relation.displayRelatedEntry(controller, false)»«ENDFOR»
            «FOR relation : outgoing.filter(typeof(OneToOneRelationship))»«relation.displayRelatedEntry(controller, true)»«ENDFOR»
            «FOR relation : incoming.filter(typeof(ManyToManyRelationship)).filter(e|e.bidirectional)»«relation.displayRelatedEntries(controller, false)»«ENDFOR»
            «FOR relation : outgoing.filter(typeof(OneToManyRelationship))»«relation.displayRelatedEntries(controller, true)»«ENDFOR»
            «FOR relation : outgoing.filter(typeof(ManyToManyRelationship))»«relation.displayRelatedEntries(controller, true)»«ENDFOR»
        {/foreach}
    '''

    def private headerLine(DerivedField it) '''
        "{gt text='«name.formatForDisplayCapital»'}"'''

    def private headerLineRelation(JoinRelationship it, Boolean useTarget) ''';"{gt text='«getRelationAliasName(useTarget).formatForDisplayCapital»'}"'''

    def private dispatch displayEntry(DerivedField it, Controller controller) '''
        "«fieldHelper.displayField(it, entity.name.formatForCode, 'viewcsv')»"'''

    def private dispatch displayEntry(BooleanField it, Controller controller) '''
        "{if !$«entity.name.formatForCode».«name.formatForCode»}0{else}1{/if}"'''

    def private displayRelatedEntry(JoinRelationship it, Controller controller, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (!useTarget) target else source)»
        «val linkEntity = (if (useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        «val leadingField = linkEntity.getLeadingField»
        ;"{if isset($«relObjName») && $«relObjName» ne null}«IF leadingField != null»{$«relObjName».«linkEntity.getLeadingField.name.formatForCode»«/*|nl2br*/»|default:""}«ELSE»«/*TODO*/»«ENDIF»{/if}"'''

    def private displayRelatedEntries(JoinRelationship it, Controller controller, Boolean useTarget) '''
        «val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital»
        «val mainEntity = (if (!useTarget) target else source)»
        «val linkEntity = (if (useTarget) target else source)»
        «val relObjName = mainEntity.name.formatForCode + '.' + relationAliasName»
        «val leadingField = linkEntity.getLeadingField»
        ;"«IF leadingField != null»
            {if isset($«relObjName») && $«relObjName» ne null}
                {foreach name='relationLoop' item='relatedItem' from=$«relObjName»}
                {$relatedItem.«leadingField.name.formatForCode»«/*|nl2br*/»|default:''}{if !$smarty.foreach.relationLoop.last}, {/if}
                {/foreach}
            {/if}
        «ELSE»
            «/*TODO*/»
        «ENDIF»"'''
}
