package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.techdocs

import de.guite.modulestudio.metamodel.AccountDeletionHandler
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.EntityIdentifierStrategy
import de.guite.modulestudio.metamodel.EntityIndexType
import de.guite.modulestudio.metamodel.EntityLockType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class TechStructureEntity {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions

    TechHelper helper = new TechHelper
    String language

    def generateBasic(Entity it, String language) {
        this.language = language
        helper.table(application, entitySettingsColumns, entitySettingsHeader, entitySettingsContent)
    }

    def generateIndexes(Entity it, String language) {
        this.language = language
        helper.table(application, entityIndexColumns, entityIndexHeader, entityIndexContent)
    }

    def generateActions(Entity it, String language) {
        this.language = language
        helper.table(application, entityActionColumns, entityActionHeader, entityActionContent)
    }

    def generateWorkflows(Entity it, String language) {
        this.language = language
        helper.table(application, entityWorkflowColumns, entityWorkflowHeader, entityWorkflowContent)
    }

    def generateBehaviour(Entity it, String language) {
        this.language = language
        helper.table(application, entityBehaviourColumns, entityBehaviourHeader, entityBehaviourContent)
    }

    def private entitySettingsColumns(Entity it) '''
        <colgroup>
            <col id="c«name.formatForCodeCapital»SettingsName" />
            <col id="c«name.formatForCodeCapital»SettingsValue" />
            <col id="c«name.formatForCodeCapital»SettingsDescription" />
        </colgroup>
    '''

    def private entitySettingsHeader(Entity it) '''
        <tr>
            <th id="h«name.formatForCodeCapital»SettingsName" scope="col">Name</th>
            <th id="h«name.formatForCodeCapital»SettingsValue" scope="col">«IF language == 'de'»Wert«ELSE»Value«ENDIF»</th>
            <th id="h«name.formatForCodeCapital»SettingsDescription" scope="col">«IF language == 'de'»Beschreibung«ELSE»Description«ENDIF»</th>
        </tr>
    '''

    def private entitySettingsContent(Entity it) '''
        <tr>
            <th id="h«name.formatForCodeCapital»SettingsLeading" scope="row" headers="h«name.formatForCodeCapital»SettingsName">«IF language == 'de'»Führend«ELSE»Leading«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»SettingsLeading h«name.formatForCodeCapital»SettingsValue" class="text-center">«helper.flag(application, leading)»</td>
            <td headers="h«name.formatForCodeCapital»SettingsLeading h«name.formatForCodeCapital»SettingsDescription">«IF language == 'de'»Ob dies die primäre Entität der Anwendung darstellt«ELSE»Whether this represents the primary entity of the application«ENDIF»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»SettingsDisplayPattern" scope="row" headers="h«name.formatForCodeCapital»SettingsName">«IF language == 'de'»Anzeigemuster«ELSE»Display pattern«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»SettingsDisplayPattern h«name.formatForCodeCapital»SettingsValue">«displayPattern»</td>
            <td headers="h«name.formatForCodeCapital»SettingsDisplayPattern h«name.formatForCodeCapital»SettingsDescription">«IF language == 'de'»Muster zur Anzeige von Instanzen dieser Entität«ELSE»Pattern for displaying instances of this entity«ENDIF»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»SettingsIdentifierStrategy" scope="row" headers="h«name.formatForCodeCapital»SettingsName">«IF language == 'de'»ID-Strategie«ELSE»ID strategy«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»SettingsIdentifierStrategy h«name.formatForCodeCapital»SettingsValue">«identifierStrategy.literal» &ndash; «identifierStrategy.enumDescription»</td>
            <td headers="h«name.formatForCodeCapital»SettingsIdentifierStrategy h«name.formatForCodeCapital»SettingsDescription">«IF language == 'de'»Ob und welche Strategie zur Generierung von IDs angewendet wird«ELSE»Whether and which identifier generation strategy is applied«ENDIF»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»SettingsChangeTrackingPolicy" scope="row" headers="h«name.formatForCodeCapital»SettingsName">«IF language == 'de'»Methode zur Erkennung von Änderungen«ELSE»Change tracking policy«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»SettingsChangeTrackingPolicy h«name.formatForCodeCapital»SettingsValue">«changeTrackingPolicy.literal» &ndash; «changeTrackingPolicy.enumDescription»</td>
            <td headers="h«name.formatForCodeCapital»SettingsChangeTrackingPolicy h«name.formatForCodeCapital»SettingsDescription">«IF language == 'de'»Wie die Erkennung von Änderungen durchgeführt wird«ELSE»How change detection is being done«ENDIF»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»SettingsLockType" scope="row" headers="h«name.formatForCodeCapital»SettingsName">«IF language == 'de'»Sperrstrategie«ELSE»Locking strategy«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»SettingsLockType h«name.formatForCodeCapital»SettingsValue">«lockType.literal» &ndash; «lockType.enumDescription»</td>
            <td headers="h«name.formatForCodeCapital»SettingsLockType h«name.formatForCodeCapital»SettingsDescription">«IF language == 'de'»Ob und welche Strategie zum Sperren angewendet wird«ELSE»Whether and which locking strategy is applied«ENDIF»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»SettingsReadOnly" scope="row" headers="h«name.formatForCodeCapital»SettingsName">«IF language == 'de'»Nur Lesen«ELSE»Read only«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»SettingsReadOnly h«name.formatForCodeCapital»SettingsValue" class="text-center">«helper.flag(application, readOnly)»</td>
            <td headers="h«name.formatForCodeCapital»SettingsReadOnly h«name.formatForCodeCapital»SettingsDescription">«IF language == 'de'»Ob diese Entität nur gelesen werden darf oder nicht. Falls ja, ist das Bearbeiten nicht möglich.«ELSE»Whether this entity is read only or not. If yes, editing is not possible.«ENDIF»</td>
        </tr>
    '''

    def private entityIndexColumns(Entity it) '''
        <colgroup>
            <col id="c«name.formatForCodeCapital»IndexName" />
            <col id="c«name.formatForCodeCapital»IndexType" />
            <col id="c«name.formatForCodeCapital»IndexSize" />
            <col id="c«name.formatForCodeCapital»IndexDescription" />
        </colgroup>
    '''

    def private entityIndexHeader(Entity it) '''
        <tr>
            <th id="h«name.formatForCodeCapital»IndexName" scope="col">Name</th>
            <th id="h«name.formatForCodeCapital»IndexType" scope="col">«IF language == 'de'»Typ«ELSE»Type«ENDIF»</th>
            <th id="h«name.formatForCodeCapital»IndexSize" scope="col">«IF language == 'de'»Größe«ELSE»Size«ENDIF»</th>
            <th id="h«name.formatForCodeCapital»IndexDescription" scope="col">«IF language == 'de'»Beschreibung«ELSE»Description«ENDIF»</th>
        </tr>
    '''

    def private entityIndexContent(Entity it) '''
        «FOR index : indexes»
            <tr>
                <th id="h«name.formatForCodeCapital»Index«index.name.formatForCodeCapital»" scope="row" headers="h«name.formatForCodeCapital»IndexName">«index.name.formatForDisplayCapital»</th>
                <td headers="h«name.formatForCodeCapital»Index«index.name.formatForCodeCapital» h«name.formatForCodeCapital»IndexType">«index.type.literal» &ndash; «index.type.enumDescription»</td>
                <td headers="h«name.formatForCodeCapital»Index«index.name.formatForCodeCapital» h«name.formatForCodeCapital»IndexSize">«index.items.length» «IF language == 'de'»Feld«ELSE»field«ENDIF»«IF index.items.length > 1»«IF language == 'de'»er«ELSE»s«ENDIF»«ENDIF»</td>
                <td headers="h«name.formatForCodeCapital»Index«index.name.formatForCodeCapital» h«name.formatForCodeCapital»IndexDescription">«IF null !== index.documentation && !index.documentation.empty»«index.documentation»«ENDIF»</td>
            </tr>
        «ENDFOR»
    '''

    def private entityActionColumns(Entity it) '''
        <colgroup>
            <col id="c«name.formatForCodeCapital»ActionName" />
            <col id="c«name.formatForCodeCapital»ActionDescription" />
        </colgroup>
    '''

    def private entityActionHeader(Entity it) '''
        <tr>
            <th id="h«name.formatForCodeCapital»ActionName" scope="col">Name</th>
            <th id="h«name.formatForCodeCapital»ActionDescription" scope="col">«IF language == 'de'»Beschreibung«ELSE»Description«ENDIF»</th>
        </tr>
    '''

    def private entityActionContent(Entity it) '''
        «FOR action : actions»
            <tr>
                <th id="h«name.formatForCodeCapital»Action«action.name.formatForCodeCapital»" scope="row" headers="h«name.formatForCodeCapital»ActionName">«action.name.formatForDisplayCapital»</th>
                <td headers="h«name.formatForCodeCapital»Action«action.name.formatForCodeCapital» h«name.formatForCodeCapital»ActionDescription">«IF null !== action.documentation && !action.documentation.empty»«action.documentation»«ELSE»«action.name.formatForCodeCapital»«IF language == 'de'»-Aktion im «name.formatForCodeCapital»-Controller«ELSE» action in «name.formatForCodeCapital» controller«ENDIF»«ENDIF»</td>
            </tr>
        «ENDFOR»
    '''

    def private entityWorkflowColumns(Entity it) '''
        <colgroup>
            <col id="c«name.formatForCodeCapital»WorkflowName" />
            <col id="c«name.formatForCodeCapital»WorkflowDescription" />
        </colgroup>
    '''

    def private entityWorkflowHeader(Entity it) '''
        <tr>
            <th id="h«name.formatForCodeCapital»WorkflowName" scope="col">Name</th>
            <th id="h«name.formatForCodeCapital»WorkflowDescription" scope="col">«IF language == 'de'»Beschreibung«ELSE»Description«ENDIF»</th>
        </tr>
    '''

    def private entityWorkflowContent(Entity it) '''
        <tr>
            <th id="h«name.formatForCodeCapital»WorkflowType" scope="row" headers="h«name.formatForCodeCapital»WorkflowName">«IF language == 'de'»Workflow-Typ«ELSE»Workflow type«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»WorkflowType h«name.formatForCodeCapital»WorkflowDescription">«workflow.literal» &ndash; «workflow.enumDescription»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»WorkflowStates" scope="row" headers="h«name.formatForCodeCapital»WorkflowName">«IF language == 'de'»Zustände«ELSE»States«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»WorkflowStates h«name.formatForCodeCapital»WorkflowDescription">
                <ul>
                    <li><strong>Initial:</strong> «IF language == 'de'»Inhalt wurde soeben erstellt und noch nicht persistiert.«ELSE»content is just created and not persisted yet.«ENDIF»</li>
                    «IF ownerPermission»
                        <li><strong>«IF language == 'de'»Zurückgestellt«ELSE»Deferred«ENDIF»:</strong> «IF language == 'de'»Inhalt wurde noch nicht eingereicht oder wartete und wurde zurückgewiesen. Erlaubt es Benutzern, ihre Einreichungen zu verwalten, ansonsten würden zurückgewiesene Inhalte gelöscht.«ELSE»content has not been submitted yet or has been waiting, but was rejected. Allows users to manage their contributions, otherwise rejected content would be deleted.«ENDIF»</li>
                    «ENDIF»
                    «IF workflow != EntityWorkflowType.NONE»
                        <li><strong>«IF language == 'de'»Wartend«ELSE»Waiting«ENDIF»:</strong> «IF language == 'de'»Inhalt wurde eingereicht und wartet auf Freigabe.«ELSE»content has been submitted and waits for approval.«ENDIF»</li>
                        «IF workflow == EntityWorkflowType.ENTERPRISE»
                            <li><strong>«IF language == 'de'»Akzeptiert«ELSE»Accepted«ENDIF»:</strong> «IF language == 'de'»Inhalt wurde eingereicht und akzeptiert, aber wartet noch auf Freigabe.«ELSE»content has been submitted and accepted, but still waits for approval.«ENDIF»</li>
                        «ENDIF»
                    «ENDIF»
                    <li><strong>«IF language == 'de'»Freigegeben«ELSE»Approved«ENDIF»:</strong> «IF language == 'de'»Inhalt wurde freigegeben und ist online verfügbar.«ELSE»content has been approved and is available online.«ENDIF»</li>
                    «IF hasTray»
                        <li><strong>«IF language == 'de'»Ausgesetzt«ELSE»Suspended«ENDIF»:</strong> «IF language == 'de'»Inhalt wurde freigegeben, aber übergangsweise offline.«ELSE»content has been approved, but is temporarily offline.«ENDIF»</li>
                    «ENDIF»
                    «IF hasArchive»
                        <li><strong>«IF language == 'de'»Archiviert«ELSE»Archived«ENDIF»:</strong> «IF language == 'de'»Inhalt hat sein Ende erreicht und wurde archiviert.«ELSE»content has reached the end and became archived.«ENDIF»</li>
                    «ENDIF»
                    <li><strong>«IF language == 'de'»Gelöscht«ELSE»Deleted«ENDIF»:</strong> «IF language == 'de'»Inhalt wurde aus der Datenbank gelöscht.«ELSE»content has been deleted from the database.«ENDIF»</li>
                </ul>
            </td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»WorkflowOwnerPermission" scope="row" headers="h«name.formatForCodeCapital»WorkflowName">«IF language == 'de'»Benutzer können ihre eigenen Daten verwalten und bearbeiten«ELSE»Users are able to manage and edit their own data«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»WorkflowOwnerPermission h«name.formatForCodeCapital»WorkflowDescription" class="text-center">«helper.flag(application, ownerPermission)»</td>
        </tr>
        «IF hasEndDateField»
            <tr>
                <th id="h«name.formatForCodeCapital»WorkflowDeleteExpired" scope="row" headers="h«name.formatForCodeCapital»WorkflowName">«IF language == 'de'»Veraltete Daten werden automatisch gelöscht«ELSE»Obsolete data is automatically deleted«ENDIF»</th>
                <td headers="h«name.formatForCodeCapital»WorkflowDeleteExpired h«name.formatForCodeCapital»WorkflowDescription" class="text-center">«helper.flag(application, deleteExpired)»</td>
            </tr>
        «ENDIF»
        «IF standardFields»
            <tr>
                <th id="h«name.formatForCodeCapital»WorkflowAccountDeletionCreator" scope="row" headers="h«name.formatForCodeCapital»WorkflowName">«IF language == 'de'»Wenn Ersteller gelöscht wird«ELSE»If creator is deleted«ENDIF»</th>
                <td headers="h«name.formatForCodeCapital»WorkflowAccountDeletionCreator h«name.formatForCodeCapital»WorkflowDescription">«onAccountDeletionCreator.enumDescription»</td>
            </tr>
            <tr>
                <th id="h«name.formatForCodeCapital»WorkflowAccountDeletionLastEditor" scope="row" headers="h«name.formatForCodeCapital»WorkflowName">«IF language == 'de'»Wenn letzter Bearbeiter gelöscht wird«ELSE»If last editor is deleted«ENDIF»</th>
                <td headers="h«name.formatForCodeCapital»WorkflowAccountDeletionLastEditor h«name.formatForCodeCapital»WorkflowDescription">«onAccountDeletionLastEditor.enumDescription»</td>
            </tr>
        «ENDIF»
        «IF hasUserFieldsEntity»
            «FOR userField : getUserFieldsEntity»
                <tr>
                    <th id="h«name.formatForCodeCapital»WorkflowAccountDeletion«userField.name.formatForCodeCapital»" scope="row" headers="h«name.formatForCodeCapital»WorkflowName">«IF language == 'de'»Wenn "«userField.name.formatForDisplay»" gelöscht wird«ELSE»If "«userField.name.formatForDisplay»" is deleted«ENDIF»</th>
                    <td headers="h«name.formatForCodeCapital»WorkflowAccountDeletion«userField.name.formatForCodeCapital» h«name.formatForCodeCapital»WorkflowDescription">«userField.onAccountDeletion.enumDescription»</td>
                </tr>
            «ENDFOR»
        «ENDIF»
    '''

    def private entityBehaviourColumns(Entity it) '''
        <colgroup>
            <col id="c«name.formatForCodeCapital»BehaviourName1" />
            <col id="c«name.formatForCodeCapital»BehaviourValue1" />
            <col id="c«name.formatForCodeCapital»BehaviourName2" />
            <col id="c«name.formatForCodeCapital»BehaviourValue2" />
        </colgroup>
    '''

    def private entityBehaviourHeader(Entity it) '''
        <tr class="sr-only">
            <th id="h«name.formatForCodeCapital»BehaviourName1" scope="col">Name</th>
            <th id="h«name.formatForCodeCapital»BehaviourValue1" scope="col">«IF language == 'de'»Wert«ELSE»Value«ENDIF»</th>
            <th id="h«name.formatForCodeCapital»BehaviourName2" scope="col">Name</th>
            <th id="h«name.formatForCodeCapital»BehaviourValue2" scope="col">«IF language == 'de'»Wert«ELSE»Value«ENDIF»</th>
        </tr>
    '''

    def private entityBehaviourContent(Entity it) '''
        <tr>
            <th id="h«name.formatForCodeCapital»BehaviourStandardFields" scope="row" headers="h«name.formatForCodeCapital»BehaviourName1">«IF language == 'de'»Standardfelder«ELSE»Standard fields«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»BehaviourStandardFields h«name.formatForCodeCapital»BehaviourValue1" class="text-center">«helper.flag(application, standardFields)»</td>
            <th id="h«name.formatForCodeCapital»BehaviourLoggable" scope="row" headers="h«name.formatForCodeCapital»BehaviourName2">«IF language == 'de'»Versionierbar«ELSE»Versionable«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»BehaviourLoggable h«name.formatForCodeCapital»BehaviourValue2" class="text-center">«helper.flag(application, loggable)»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»BehaviourCategorisable" scope="row" headers="h«name.formatForCodeCapital»BehaviourName1">«IF language == 'de'»Kategorisierbar«ELSE»Categorisable«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»BehaviourCategorisable h«name.formatForCodeCapital»BehaviourValue1" class="text-center">«helper.flag(application, categorisable)»</td>
            <th id="h«name.formatForCodeCapital»BehaviourCategorisableMulti" scope="row" headers="h«name.formatForCodeCapital»BehaviourName2">«IF language == 'de'»Kategorien Mehrfachauswahl«ELSE»Categories multi selection«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»BehaviourCategorisableMulti h«name.formatForCodeCapital»BehaviourValue2" class="text-center">«helper.flag(application, categorisableMultiSelection)»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»BehaviourSluggable" scope="row" headers="h«name.formatForCodeCapital»BehaviourName1">«IF language == 'de'»Permalinks«ELSE»Slugs«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»BehaviourSluggable h«name.formatForCodeCapital»BehaviourValue1" class="text-center">«helper.flag(application, hasSluggableFields)»</td>
            <td headers="h«name.formatForCodeCapital»BehaviourSluggable h«name.formatForCodeCapital»BehaviourValue2" class="text-center">«IF hasSluggableFields»«IF !slugUpdatable»«IF language == 'de'»nicht«ELSE»not«ENDIF» «ENDIF»«IF language == 'de'»änderbar«ELSE»updatable«ENDIF»«ENDIF»</td>
            <td headers="h«name.formatForCodeCapital»BehaviourSluggable h«name.formatForCodeCapital»BehaviourValue2" class="text-center">«IF hasSluggableFields»«IF !slugUnique»«IF language == 'de'»nicht«ELSE»not«ENDIF» «ENDIF»«IF language == 'de'»eindeutig«ELSE»unique«ENDIF»«ENDIF»</td>
        </tr>
        <tr>
            <th id="h«name.formatForCodeCapital»BehaviourTree" scope="row" headers="h«name.formatForCodeCapital»BehaviourName1">«IF language == 'de'»Baum«ELSE»Tree«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»BehaviourTree h«name.formatForCodeCapital»BehaviourValue1" class="text-center">«tree.literal»</td>
            <th id="h«name.formatForCodeCapital»BehaviourGeographical" scope="row" headers="h«name.formatForCodeCapital»BehaviourName2">«IF language == 'de'»Geografisch«ELSE»Geographical«ENDIF»</th>
            <td headers="h«name.formatForCodeCapital»BehaviourGeographical h«name.formatForCodeCapital»BehaviourValue2" class="text-center">«helper.flag(application, geographical)»</td>
        </tr>
    '''

    def dispatch private enumDescription(EntityWorkflowType it) {
        switch it {
            case NONE:
                return if (language == 'de') 'keine Freigabe.' else 'no approval.'
            case STANDARD:
                return if (language == 'de') 'einfache Freigabe.' else 'single approval.'
            case ENTERPRISE:
                return if (language == 'de') 'doppelte Freigabe.' else 'double approval.'
        }
    }

    def dispatch private enumDescription(AccountDeletionHandler it) {
        switch it {
            case ADMIN:
                return if (language == 'de') 'wird als Nutzer "Admin" zugewiesen.' else 'the "admin" user will be assigned.'
            case GUEST:
                return if (language == 'de') 'wird als Nutzer "Gast" zugewiesen.' else 'the "guest" user will be assigned.'
            case DELETE:
                return if (language == 'de') 'wird die Entität gelöscht.' else 'the entity will be deleted.'
        }
    }

    def dispatch private enumDescription(EntityIdentifierStrategy it) {
        switch it {
            case AUTO:
                return if (language == 'de') 'Automatische Auswahl.' else 'Choose automatically.'
            case SEQUENCE:
                return if (language == 'de') 'Verwendet eine Datenbanksequenz.' else 'Uses a database sequence.'
            case IDENTITY:
                return if (language == 'de') 'Verwendet spezielle Identitätsspalten (auto_increment).' else 'Uses special identity columns (auto_increment).'
            case NONE:
                return if (language == 'de') 'Keine explizite Strategie.' else 'No explicit strategy.'
            case UUID:
                return if (language == 'de') 'Generiert Universally Unique Identifier.' else 'Generates universally unique identifiers.'
            case ULID:
                return if (language == 'de') 'Generiert Universally Unique Lexicographically Sortable Identifier.' else 'Generates universally unique lexicographically sortable identifiers.'
            case CUSTOM:
                return if (language == 'de') 'Eigene Strategie.' else 'Custom strategy.'
        }
    }

    def dispatch private enumDescription(EntityChangeTrackingPolicy it) {
        switch it {
            case DEFERRED_IMPLICIT:
                return if (language == 'de') 'Änderungen werden durch Vergleich der Eigenschaften während des Commits ermittelt.' else 'Changes are determined by comparing properties during commit.'
            case DEFERRED_EXPLICIT:
                return if (language == 'de') 'Änderungen werden durch Scannen lediglich der für Änderungserkennung markierten Entitäten ermittelt.' else 'Changes are determined by scanning only entities marked for change detection.'
        }
    }

    def dispatch private enumDescription(EntityLockType it) {
        switch it {
            case NONE:
                return if (language == 'de') 'Keine Sperre.' else 'No locking support.'
            case OPTIMISTIC:
                return if (language == 'de') 'Optimistische Sperre.' else 'Optimistic locking.'
            case PESSIMISTIC_READ:
                return if (language == 'de') 'Pessimistische Lesesperre.' else 'Pessimistic read locking.'
            case PESSIMISTIC_WRITE:
                return if (language == 'de') 'Pessimistische Schreibsperre.' else 'Pessimistic write locking.'
        }
    }

    def dispatch private enumDescription(EntityIndexType it) {
        switch it {
            case NORMAL:
                return if (language == 'de') 'normaler Index' else 'normal index'
            case UNIQUE:
                return if (language == 'de') 'eindeutiger Index' else 'unique index'
            case FULLTEXT:
                return if (language == 'de') 'Volltext Index' else 'fulltext index'
        }
    }
}
