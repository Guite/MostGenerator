package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.techdocs

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Variables
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TechStructure {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    TechHelper helper = new TechHelper
    String language

    def CharSequence generate(Application it, String language) {
        this.language = language
        helper.docPage(it, language, title, content)
    }

    def private title(Application it) {
        if (language == 'de') {
            return 'Technische Struktur'
        }
        'Technical structure'
    }

    def private content(Application it) '''
        «helper.basicInfo(it, language)»
        «entityInfo»
        «IF needsConfig»
            «variableInfo»
        «ENDIF»
        «settingsInfo»
    '''

    def dispatch private CharSequence entityInfo(Application it) '''
        <h2><i class="fas fa-database"></i> «IF language == 'de'»Datentabellen«ELSE»Data tables«ENDIF»</h2>
        «FOR entity : entities»
            «entity.entityInfo»
        «ENDFOR»
    '''

    def dispatch private entityInfo(DataObject it) '''
        <h3><i class="fas fa-address-chard"></i> «name.formatForDisplayCapital»«IF it instanceof Entity» / «nameMultiple.formatForDisplayCapital»«ENDIF»</h3>
        «IF null !== documentation && !documentation.empty»
            <p>«documentation»</p>
        «ENDIF»
        «IF it instanceof Entity»
            <h4><i class="fas fa-cog"></i> «IF language == 'de'»Grundlegende Einstellungen«ELSE»Basic settings«ENDIF»</h4>
            «new TechStructureEntity().generateBasic(it, language)»
        «ENDIF»
        «IF !fields.empty»
            <h4><i class="fas fa-bars"></i> «IF language == 'de'»Felder«ELSE»Fields«ENDIF»</h4>
            «new TechStructureFields().generate(it, language)»
        «ENDIF»
        «IF !incoming.empty || !outgoing.empty»
            <h4><i class="fas fa-arrows-alt-h"></i> «IF language == 'de'»Relationen«ELSE»Relations«ENDIF»</h4>
            «new TechStructureRelations().generate(it, language)»
        «ENDIF»
        «IF it instanceof Entity»
            «IF !indexes.empty»
                <h4><i class="fas fa-key"></i> «IF language == 'de'»Indexe«ELSE»Indexes«ENDIF»</h4>
                «new TechStructureEntity().generateIndexes(it, language)»
            «ENDIF»
            «IF !actions.empty»
                <h4><i class="fas fa-paw"></i> «IF language == 'de'»Aktionen«ELSE»Actions«ENDIF»</h4>
                «new TechStructureEntity().generateActions(it, language)»
            «ENDIF»
            <h4><i class="fas fa-map-signs"></i> Workflow</h4>
            «new TechStructureEntity().generateWorkflows(it, language)»
            <h4><i class="fas fa-magic"></i> «IF language == 'de'»Verhalten«ELSE»Behaviour«ENDIF»</h4>
            «new TechStructureEntity().generateBehaviour(it, language)»
        «ENDIF»
    '''

    def dispatch private CharSequence variableInfo(Application it) '''
        <h2><i class="fas fa-wrench"></i> «IF language == 'de'»Variablen zur Konfiguration«ELSE»Configuration variables«ENDIF»</h2>
        «FOR varContainer : getSortedVariableContainers»
            «varContainer.variableInfo»
        «ENDFOR»
    '''

    def dispatch private variableInfo(Variables it) '''
        <h3><i class="fas fa-server"></i> «name.formatForDisplayCapital»</h3>
        «IF null !== documentation && !documentation.empty»
            <p>«documentation»</p>
        «ENDIF»
        «IF application.variables.length > 1»
            <p>«IF language == 'de'»Sortierwert«ELSE»Sort value«ENDIF»: «sortOrder»</p>
        «ENDIF»
        «IF !fields.empty»
            <h4><i class="fas fa-bars"></i> «IF language == 'de'»Felder«ELSE»Fields«ENDIF»</h4>
            «new TechStructureFields().generate(it, language)»
        «ENDIF»
    '''

    def private settingsInfo(Application it) '''
        <h2><i class="fas fa-puzzle-piece"></i> «IF language == 'de'»Integrationseinstellungen«ELSE»Integration settings«ENDIF»</h2>
        «new TechStructureSettings().generate(it, language)»
    '''
}
