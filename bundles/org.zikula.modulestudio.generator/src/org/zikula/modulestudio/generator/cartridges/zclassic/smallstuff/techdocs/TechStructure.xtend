package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.techdocs

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ApplicationDependencyType
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
        «IF !referredApplications.empty»
            <h2><i class="fas fa-link"></i> «IF language == 'de'»Abhängigkeiten«ELSE»Dependencies«ENDIF»</h2>
            «helper.table(it, dependenciesColumns, dependenciesHeader, dependenciesContent)»
        «ENDIF»
        «entityInfo»
        «IF needsConfig»
            «variableInfo»
        «ENDIF»
        «settingsInfo»
    '''

    def private dependenciesColumns(Application it) '''
        <colgroup>
            <col id="cDepApplicationName" />
            <col id="cDepMinVersion" />
            <col id="cDepMaxVersion" />
            <col id="cDepType" />
        </colgroup>
    '''

    def private dependenciesHeader(Application it) '''
        <tr>
            <th id="hDepApplicationName" scope="col">«IF language == 'de'»Anwendung«ELSE»Application«ENDIF»</th>
            <th id="hDepMinVersion" scope="col">«IF language == 'de'»Min. Version«ELSE»Min version«ENDIF»</th>
            <th id="hDepMaxVersion" scope="col">«IF language == 'de'»Max. Version«ELSE»Max version«ENDIF»</th>
            <th id="hDepType" scope="col">«IF language == 'de'»Art der Abhängigkeit«ELSE»Dependency type«ENDIF»</th>
        </tr>
    '''

    def private dependenciesContent(Application it) '''
        «FOR referredApp : referredApplications»
            <tr>
                <th id="hDep«referredApp.name.formatForCodeCapital»" scope="row" headers="hDepApplicationName">«referredApp.name.formatForCodeCapital»</th>
                <td headers="hDepMinVersion hDep«referredApp.name.formatForCodeCapital»">«referredApp.minVersion»</td>
                <td headers="hDepMaxVersion hDep«referredApp.name.formatForCodeCapital»">«referredApp.maxVersion»</td>
                <td headers="hDepType hDep«referredApp.name.formatForCodeCapital»">«referredApp.dependencyType.literal» &ndash; «referredApp.dependencyType.dependencyTypeDescription»</td>
            </tr>
        «ENDFOR»
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

    def private dependencyTypeDescription(ApplicationDependencyType it) {
        switch (it) {
            case REQUIREMENT:
                return if (language == 'de') 'wird benötigt, zum Beispiel zum Verknüpfen verbundener Entitäten' else 'is required, for example to join related entities'
            case RECOMMENDATION:
                return if (language == 'de') 'wird empfohlen, zum Beispiel zum Anbieten erweiterter Integrationsfunktionen' else 'is recommended, for example to provide enhanced integration functionality'
            case CONFLICT:
                return if (language == 'de') 'steht in Konflikt, zum Beispiel auf Grund überlappender Funktionalität' else 'is in conflict, for example due to overlapping functionality'
        }
    }
}
