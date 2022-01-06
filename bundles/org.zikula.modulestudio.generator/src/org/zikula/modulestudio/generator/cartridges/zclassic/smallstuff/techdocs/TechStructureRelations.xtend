package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.techdocs

import de.guite.modulestudio.metamodel.CascadeType
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.InheritanceRelationship
import de.guite.modulestudio.metamodel.InheritanceStrategyType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyPermissionInheritanceType
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.RelationAutoCompletionUsage
import de.guite.modulestudio.metamodel.RelationEditMode
import de.guite.modulestudio.metamodel.RelationFetchType
import de.guite.modulestudio.metamodel.Relationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class TechStructureRelations {

    extension FormattingExtensions = new FormattingExtensions

    TechHelper helper = new TechHelper
    String language

    def generate(DataObject it, String language) {
        this.language = language
        helper.table(application, relationColumns, relationHeader, relationContent)
    }

    def private relationColumns(DataObject it) '''
        <colgroup>
            <col id="c«name.formatForCodeCapital»RelationName" />
            <col id="c«name.formatForCodeCapital»RelationType" />
            <col id="c«name.formatForCodeCapital»RelationIncoming" />
            <col id="c«name.formatForCodeCapital»RelationRemarks" />
        </colgroup>
    '''

    def private relationHeader(DataObject it) '''
        <tr>
            <th id="h«name.formatForCodeCapital»RelationName" scope="col">Name</th>
            <th id="h«name.formatForCodeCapital»RelationType" scope="col">«IF language == 'de'»Typ«ELSE»Type«ENDIF»</th>
            <th id="h«name.formatForCodeCapital»RelationIncoming" scope="col">«IF language == 'de'»Eingehend«ELSE»Incoming«ENDIF»</th>
            <th id="h«name.formatForCodeCapital»RelationRemarks" scope="col">«IF language == 'de'»Anmerkungen«ELSE»Remarks«ENDIF»</th>
        </tr>
    '''

    def private relationContent(DataObject it) '''
        «var counter = 0»
        «FOR relation : outgoing»
            <span class="d-none">«counter = counter + 1»</span>
            «relationSingle(relation, counter, false)»
        «ENDFOR»
        «FOR relation : incoming»
            <span class="d-none">«counter = counter + 1»</span>
            «relationSingle(relation, counter, true)»
        «ENDFOR»
    '''

    def private relationSingle(DataObject it, Relationship relation, Integer counter, Boolean incoming) '''
        <tr>
            <th id="h«name.formatForCodeCapital»Relation«counter»" scope="row" headers="h«name.formatForCodeCapital»RelationName">«relation.relationName»</th>
            <td headers="h«name.formatForCodeCapital»Relation«counter» h«name.formatForCodeCapital»RelationType">«relation.relationType»</td>
            <td headers="h«name.formatForCodeCapital»Relation«counter» h«name.formatForCodeCapital»RelationIncoming" class="text-center">«helper.flag(application, incoming)»</td>
            <td headers="h«name.formatForCodeCapital»Relation«counter» h«name.formatForCodeCapital»RelationRemarks">
                <ul>
                    «FOR remark : relation.remarks»
                        <li>«remark»</li>
                    «ENDFOR»
                </ul>
            </td>
        </tr>
    '''

    def dispatch private relationName(Relationship it) {
        ''
    }
    def dispatch private relationName(OneToOneRelationship it) {
        if (language == 'de') {
            return '1 ' + sourceAlias.formatForDisplay + ' hat 1 ' + targetAlias.formatForDisplay
        }
        '1 ' + sourceAlias.formatForDisplay + ' has 1 ' + targetAlias.formatForDisplay
    }
    def dispatch private relationName(OneToManyRelationship it) {
        if (language == 'de') {
            return '1 ' + sourceAlias.formatForDisplay + ' hat n ' + targetAlias.formatForDisplay
        }
        '1 ' + sourceAlias.formatForDisplay + ' has n ' + targetAlias.formatForDisplay
    }
    def dispatch private relationName(ManyToOneRelationship it) {
        if (language == 'de') {
            return 'm ' + sourceAlias.formatForDisplay + ' haben 1 ' + targetAlias.formatForDisplay
        }
        'm ' + sourceAlias.formatForDisplay + ' have 1 ' + targetAlias.formatForDisplay
    }
    def dispatch private relationName(ManyToManyRelationship it) {
        if (language == 'de') {
            return 'm ' + sourceAlias.formatForDisplay + ' haben n ' + targetAlias.formatForDisplay
        }
        'm ' + sourceAlias.formatForDisplay + ' have n ' + targetAlias.formatForDisplay
    }
    def dispatch private relationName(InheritanceRelationship it) {
        if (language == 'de') {
            return sourceAlias.formatForDisplay + ' erweitert ' + targetAlias.formatForDisplay
        }
        sourceAlias.formatForDisplay + ' extends ' + targetAlias.formatForDisplay
    }

    def dispatch private relationType(Relationship it) {
        ''
    }
    def dispatch private relationType(OneToOneRelationship it) {
        '1:1'
    }
    def dispatch private relationType(OneToManyRelationship it) {
        '1:n'
    }
    def dispatch private relationType(ManyToOneRelationship it) {
        'm:1'
    }
    def dispatch private relationType(ManyToManyRelationship it) {
        'm:n'
    }
    def dispatch private relationType(InheritanceRelationship it) {
        if (language == 'de') {
            return 'Vererbung'
        }
        'Inheritance'
    }

    def dispatch private remarks(Relationship it) {
    }
    def private commonRemarks(JoinRelationship it) {
        val result = newArrayList
        if (language == 'de') {
            result += 'Diese Relation ist ' + (if (!unique) 'nicht ' else '') + 'eindeutig und erlaubt ' + (if (!nullable) 'keine ' else '') + 'Null-Werte.'
            result += 'Sie verwendet den Abruftyp "' + fetchType.enumDescription + '".'
            result += 'Aus Sicht der Quelle ' + cascade.enumDescription + '.'
            result += 'Aus Sicht des Ziels ' + cascadeReverse.enumDescription + '.'
            if (!onDelete.empty) result += 'Auf Datenbankebene werden zusätzliche Löschoperationen angewendet: ' + onDelete + '.'
        } else {
            result += 'This relation is ' + (if (!unique) 'not ' else '') + 'unique and allows ' + (if (!nullable) 'no ' else '') + 'null values.'
            result += 'It uses the "' + fetchType.enumDescription + '" fetch type.'
            result += 'From source view ' + cascade.enumDescription + '.'
            result += 'From target view ' + cascadeReverse.enumDescription + '.'
            if (!onDelete.empty) result += 'On database level additional delete operations are applied: ' + onDelete + '.'
        }
        result
    }
    def private editRemarks(JoinRelationship it, Boolean useTarget, RelationEditMode editMode, Boolean bidirectional, Boolean isMultiValued) {
        val result = newArrayList
        if (language == 'de') {
            if (!useTarget) {
                if (editMode == RelationEditMode.NONE) {
                    result += 'Das Bearbeiten der Quellseite beinhaltet keine Funktionalität bezüglich der Zielelemente.'
                } else if (editMode == RelationEditMode.CHOOSE || editMode == RelationEditMode.INLINE) {
                    result += 'Das Bearbeiten der Quellseite beinhaltet das Auswählen von Zielelementen, die durch ' + (
                        if (#[RelationAutoCompletionUsage.ONLY_TARGET_SIDE, RelationAutoCompletionUsage.BOTH_SIDES].contains(useAutoCompletion)) 'Auto Completion'
                        else {
                            if (isMultiValued) {
                                if (expandedTarget) 'Checkboxen'
                                else 'eine mehrwertige Dropdownliste'
                            } else {
                                if (expandedTarget) 'Radio Buttons'
                                else 'eine einwertige Dropdownliste'
                            }
                        }
                    ) + ' repräsentiert werden.'
                    if (editMode == RelationEditMode.INLINE) {
                        result += 'Außerdem können Zielelemente mittels innerer modaler Fenster erstellt und bearbeitet werden.'
                    }
                } else if (editMode == RelationEditMode.EMBEDDED) {
                    result += 'Das Bearbeiten der Quellseite erlaubt die eingebettete Erstellung und Bearbeitung von Zielelementen.'
                }
            } else {
                if (!bidirectional || editMode == RelationEditMode.NONE) {
                    result += 'Das Bearbeiten der Zielseite beinhaltet keine Funktionalität bezüglich der Quellelemente.'
                } else if (editMode == RelationEditMode.CHOOSE || editMode == RelationEditMode.INLINE) {
                    result += 'Das Bearbeiten der Zielseite beinhaltet das Auswählen von Quellelementen, die durch ' + (
                        if (#[RelationAutoCompletionUsage.ONLY_SOURCE_SIDE, RelationAutoCompletionUsage.BOTH_SIDES].contains(useAutoCompletion)) 'Auto Completion'
                        else {
                            if (isMultiValued) {
                                if (expandedSource) 'Checkboxen'
                                else 'eine mehrwertige Dropdownliste'
                            } else {
                                if (expandedSource) 'Radio Buttons'
                                else 'eine einwertige Dropdownliste'
                            }
                        }
                    ) + ' repräsentiert werden.'
                    if (editMode == RelationEditMode.INLINE) {
                        result += 'Außerdem können Quellelemente mittels innerer modaler Fenster erstellt und bearbeitet werden.'
                    }
                } else if (editMode == RelationEditMode.EMBEDDED) {
                    result += 'Das Bearbeiten der Zielseite erlaubt die eingebettete Erstellung und Bearbeitung von Quellelementen.'
                }
            }
        } else {
            if (!useTarget) {
                if (editMode == RelationEditMode.NONE) {
                    result += 'Editing the source side includes no behaviour regarding target elements.'
                } else if (editMode == RelationEditMode.CHOOSE || editMode == RelationEditMode.INLINE) {
                    result += 'Editing the source side includes choosing target elements that are represented as ' + (
                        if (#[RelationAutoCompletionUsage.ONLY_TARGET_SIDE, RelationAutoCompletionUsage.BOTH_SIDES].contains(useAutoCompletion)) 'auto completion'
                        else {
                            if (isMultiValued) {
                                if (expandedTarget) 'checkboxes'
                                else 'a multi-valued dropdown list'
                            } else {
                                if (expandedTarget) 'radio buttons'
                                else 'a single-valued dropdown list'
                            }
                        }
                    ) + '.'
                    if (editMode == RelationEditMode.INLINE) {
                        result += 'In addition, target elements can be created and edited using inline modal windows.'
                    }
                } else if (editMode == RelationEditMode.EMBEDDED) {
                    result += 'Editing the source side allows embedded creation and editing of target elements.'
                }
            } else {
                if (!bidirectional || editMode == RelationEditMode.NONE) {
                    result += 'Editing the target side includes no behaviour regarding source elements.'
                } else if (editMode == RelationEditMode.CHOOSE || editMode == RelationEditMode.INLINE) {
                    result += 'Editing the target side includes choosing source elements that are represented as ' + (
                        if (#[RelationAutoCompletionUsage.ONLY_SOURCE_SIDE, RelationAutoCompletionUsage.BOTH_SIDES].contains(useAutoCompletion)) 'auto completion'
                        else {
                            if (isMultiValued) {
                                if (expandedSource) 'checkboxes'
                                else 'a multi-valued dropdown list'
                            } else {
                                if (expandedSource) 'radio buttons'
                                else 'a single-valued dropdown list'
                            }
                        }
                    ) + '.'
                    if (editMode == RelationEditMode.INLINE) {
                        result += 'In addition, source elements can be created and edited using inline modal windows.'
                    }
                } else if (editMode == RelationEditMode.EMBEDDED) {
                    result += 'Editing the target side allows embedded creation and editing of source elements.'
                }
            }
        }
        result
    }
    def dispatch private remarks(OneToOneRelationship it) {
        val result = commonRemarks
        if (language == 'de') {
            result += 'Diese Relation wird durch eine ' + (if (bidirectional) 'bidirektionale' else 'unidirektionale') + ' Assoziation realisiert.'
            if (primaryKey) result += 'Der Fremdschlüssel der Relation fungiert als Primärschlüssel.'
            if (orphanRemoval) result += 'Waisen werden automatisch entfernt.'
            if (inheritPermissions) result += 'Die Sichtbarkeit der Quelle beeinflusst die Sichtbarkeit des Ziels durch Vererbung von Zugriffsrechten.'
        } else {
            result += 'This relation is realised by ' + (if (bidirectional) 'a bidirectional' else 'an unidirectional') + ' association.'
            if (primaryKey) result += 'The relation\'s foreign key acts as primary key.'
            if (orphanRemoval) result += 'Orphans get removed automatically.'
            if (inheritPermissions) result += 'Source visibility affects target visibility by permission inheritance.'
        }
        result += editRemarks(false, sourceEditing, bidirectional, false)
        result += editRemarks(true, targetEditing, bidirectional, false)
        result
    }
    def dispatch private remarks(OneToManyRelationship it) {
        val result = commonRemarks
        if (language == 'de') {
            result += 'Diese Relation wird durch eine ' + (if (bidirectional) 'bidirektionale' else 'unidirektionale') + ' Assoziation realisiert.'
            if (orphanRemoval) result += 'Waisen werden automatisch entfernt.'
            if (null !== orderBy && !orderBy.empty) result += 'Die ' + targetAlias.formatForDisplay + ' werden nach dem Feld "' + orderBy + '" sortiert.'
            if (null !== indexBy && !indexBy.empty) result += 'Die ' + targetAlias.formatForDisplay + ' werden nach dem Feld "' + indexBy + '" indiziert.'
            if (minTarget > 0 || maxTarget > 0) {
                if (minTarget > 0 && maxTarget > 0) {
                    result += 'Es können mindestens ' + minTarget + ' und höchstens ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (minTarget > 0) {
                    result += 'Es können mindestens ' + minTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (maxTarget > 0) {
                    result += 'Es können höchstens ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                }
            }
            if (inheritPermissions) result += 'Die Sichtbarkeit der Quelle beeinflusst die Sichtbarkeit des Ziels durch Vererbung von Zugriffsrechten.'
        } else {
            result += 'This relation is realised by ' + (if (bidirectional) 'a bidirectional' else 'an unidirectional') + ' association.'
            if (orphanRemoval) result += 'Orphans get removed automatically.'
            if (null !== orderBy && !orderBy.empty) result += 'The ' + targetAlias.formatForDisplay + ' are sorted by the "' + orderBy + '" field.'
            if (null !== indexBy && !indexBy.empty) result += 'The ' + targetAlias.formatForDisplay + ' are indexed by the "' + indexBy + '" field.'
            if (minTarget > 0 || maxTarget > 0) {
                if (minTarget > 0 && maxTarget > 0) {
                    result += 'At least ' + minTarget + ' and at most ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                } else if (minTarget > 0) {
                    result += 'At least ' + minTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                } else if (maxTarget > 0) {
                    result += 'At most ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                }
            }
            if (inheritPermissions) result += 'Source visibility affects target visibility by permission inheritance.'
        }
        result += editRemarks(false, sourceEditing, bidirectional, true)
        result += editRemarks(true, targetEditing, bidirectional, false)
        result
    }
    def dispatch private remarks(ManyToOneRelationship it) {
        val result = commonRemarks
        if (language == 'de') {
            if (primaryKey) result += 'Der Fremdschlüssel der Relation fungiert als Primärschlüssel.'
            if (sortableGroup) result += 'Der Fremdschlüssel der Relation fungiert als Gruppierkriterium für die Sortable-Erweiterung.'
        } else {
            if (primaryKey) result += 'The relation\'s foreign key acts as primary key.'
            if (sortableGroup) result += 'The relation\'s foreign key acts as grouping criteria for the Sortable extension.'
        }
        result += editRemarks(false, sourceEditing, false, false)
        result += editRemarks(true, RelationEditMode.NONE, false, true)
        result
    }
    def dispatch private remarks(ManyToManyRelationship it) {
        val result = commonRemarks
        if (language == 'de') {
            result += 'Diese Relation wird durch eine ' + (if (bidirectional) 'bidirektionale' else 'unidirektionale') + ' Assoziation realisiert.'
            result += 'Die für die verbindende Tabelle erstellte Referenzklasse heißt "' + refClass + '".'
            if (orphanRemoval) result += 'Waisen werden automatisch entfernt.'
            if (null !== orderByReverse && !orderByReverse.empty) result += 'Die ' + sourceAlias.formatForDisplay + ' werden nach dem Feld "' + orderByReverse + '" sortiert.'
            if (null !== orderBy && !orderBy.empty) result += 'Die ' + targetAlias.formatForDisplay + ' werden nach dem Feld "' + orderBy + '" sortiert.'
            if (null !== indexBy && !indexBy.empty) result += 'Die ' + targetAlias.formatForDisplay + ' werden nach dem Feld "' + indexBy + '" indiziert.'
            if (minSource > 0 || maxSource > 0) {
                if (minSource > 0 && maxSource > 0) {
                    result += 'Es können mindestens ' + minSource + ' und höchstens ' + maxSource + ' ' + sourceAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (minSource > 0) {
                    result += 'Es können mindestens ' + minSource + ' ' + sourceAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (maxSource > 0) {
                    result += 'Es können höchstens ' + maxSource + ' ' + sourceAlias.formatForDisplay + ' zugewiesen werden.'
                }
            }
            if (minTarget > 0 || maxTarget > 0) {
                if (minTarget > 0 && maxTarget > 0) {
                    result += 'Es können mindestens ' + minTarget + ' und höchstens ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (minTarget > 0) {
                    result += 'Es können mindestens ' + minTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                } else if (maxTarget > 0) {
                    result += 'Es können höchstens ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' zugewiesen werden.'
                }
            }
            if (inheritPermissions != ManyToManyPermissionInheritanceType.NONE) {
                result += 'Die Sichtbarkeit der Quelle beeinflusst die Sichtbarkeit des Ziels durch Vererbung von Zugriffsrechten.'
                if (inheritPermissions == ManyToManyPermissionInheritanceType.AFFIRMATIVE) {
                    result += 'Zugriff ist gewährt, sobald Zugriff auf ein Quellobjekt besteht.'
                } else if (inheritPermissions == ManyToManyPermissionInheritanceType.UNANIMOUS) {
                    result += 'Zugriff ist nur gewährt, wenn Zugriff auf alle Quellobjekte besteht.'
                }
            }
        } else {
            result += 'This relation is realised by ' + (if (bidirectional) 'a bidirectional' else 'an unidirectional') + ' association.'
            result += 'The reference class created for the linking table is named "' + refClass + '".'
            if (orphanRemoval) result += 'Orphans get removed automatically.'
            if (null !== orderByReverse && !orderByReverse.empty) result += 'The ' + sourceAlias.formatForDisplay + ' are sorted by the "' + orderByReverse + '" field.'
            if (null !== orderBy && !orderBy.empty) result += 'The ' + targetAlias.formatForDisplay + ' are sorted by the "' + orderBy + '" field.'
            if (null !== indexBy && !indexBy.empty) result += 'The ' + targetAlias.formatForDisplay + ' are indexed by the "' + indexBy + '" field.'
            if (minSource > 0 || maxSource > 0) {
                if (minSource > 0 && maxSource > 0) {
                    result += 'At least ' + minSource + ' and at most ' + maxSource + ' ' + sourceAlias.formatForDisplay + ' may be assigned.'
                } else if (minSource > 0) {
                    result += 'At least ' + minSource + ' ' + sourceAlias.formatForDisplay + ' may be assigned.'
                } else if (maxSource > 0) {
                    result += 'At most ' + maxSource + ' ' + sourceAlias.formatForDisplay + ' may be assigned.'
                }
            }
            if (minTarget > 0 || maxTarget > 0) {
                if (minTarget > 0 && maxTarget > 0) {
                    result += 'At least ' + minTarget + ' and at most ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                } else if (minTarget > 0) {
                    result += 'At least ' + minTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                } else if (maxTarget > 0) {
                    result += 'At most ' + maxTarget + ' ' + targetAlias.formatForDisplay + ' may be assigned.'
                }
            }
            if (inheritPermissions != ManyToManyPermissionInheritanceType.NONE) {
                result += 'Source visibility affects target visibility by permission inheritance.'
                if (inheritPermissions == ManyToManyPermissionInheritanceType.AFFIRMATIVE) {
                    result += 'Access is granted as soon as there is one source object accessible.'
                } else if (inheritPermissions == ManyToManyPermissionInheritanceType.UNANIMOUS) {
                    result += 'Access is only granted if all source objects are accessible.'
                }
            }
        }
        result += editRemarks(false, sourceEditing, bidirectional, true)
        result += editRemarks(true, targetEditing, bidirectional, true)
        result
    }

    def dispatch private remarks(InheritanceRelationship it) {
        val result = newArrayList
        if (language == 'de') {
            if (strategy == InheritanceStrategyType.SINGLE_TABLE) {
                result += 'Verwendet einfache Vererbung: alles wird in der Elterntabelle geteilt und gespeichert.'
            } else if (strategy == InheritanceStrategyType.JOINED) {
                result += 'Verwendet konkrete Vererbung: jede Entität speichert alles in ihrer eigenen Tabelle.'
            }
            result += 'Der Typ der Entität wird in dem Feld "' + discriminatorColumn + '" gespeichert.'
        } else {
            if (strategy == InheritanceStrategyType.SINGLE_TABLE) {
                result += 'Uses simple inheritance: everything is shared and stored in the parent table.'
            } else if (strategy == InheritanceStrategyType.JOINED) {
                result += 'Uses concrete inheritance: each entity stores everything in its own table.'
            }
            result += 'The entity type is stored in the "' + discriminatorColumn + '" field.'
        }
        result
    }

    def dispatch private enumDescription(RelationFetchType it) {
        switch it {
            case LAZY:
                return if (language == 'de') 'Lazy' else 'lazy'
            case EAGER:
                return if (language == 'de') 'Eager' else 'eager'
            case EXTRA_LAZY:
                return if (language == 'de') 'Extra Lazy' else 'extra lazy'
        }
    }

    def dispatch private enumDescription(CascadeType it) {
        switch it {
            case NONE:
                return if (language == 'de') 'wird keine Kaskade angewendet' else 'no cascading is applied'
            case PERSIST:
                return if (language == 'de') 'wird eine Kaskade auf Persist-Operationen angewendet' else 'cascading is applied for persist operations'
            case REMOVE:
                return if (language == 'de') 'wird eine Kaskade auf Remove-Operationen angewendet' else 'cascading is applied for remove operations'
            case MERGE:
                return if (language == 'de') 'wird eine Kaskade auf Merge-Operationen angewendet' else 'cascading is applied for merge operations'
            case DETACH:
                return if (language == 'de') 'wird eine Kaskade auf Detach-Operationen angewendet' else 'cascading is applied for detach operations'
            case PERSIST_REMOVE:
                return if (language == 'de') 'wird eine Kaskade auf Persist- und Remove-Operationen angewendet' else 'cascading is applied for persist and remove operations'
            case PERSIST_MERGE:
                return if (language == 'de') 'wird eine Kaskade auf Persist- und Merge-Operationen angewendet' else 'cascading is applied for persist and merge operations'
            case PERSIST_DETACH:
                return if (language == 'de') 'wird eine Kaskade auf Persist- und Detach-Operationen angewendet' else 'cascading is applied for persist and detach operations'
            case REMOVE_MERGE:
                return if (language == 'de') 'wird eine Kaskade auf Remove- und Merge-Operationen angewendet' else 'cascading is applied for remove and merge operations'
            case REMOVE_DETACH:
                return if (language == 'de') 'wird eine Kaskade auf Remove- und Detach-Operationen angewendet' else 'cascading is applied for remove and detach operations'
            case MERGE_DETACH:
                return if (language == 'de') 'wird eine Kaskade auf Merge- und Detach-Operationen angewendet' else 'cascading is applied for merge and detach operations'
            case PERSIST_REMOVE_MERGE:
                return if (language == 'de') 'wird eine Kaskade auf Persist-, Remove- und Merge-Operationen angewendet' else 'cascading is applied for persist, remove and merge operations'
            case PERSIST_REMOVE_DETACH:
                return if (language == 'de') 'wird eine Kaskade auf Persist-, Remove- und Detach-Operationen angewendet' else 'cascading is applied for persist, remove and detach operations'
            case PERSIST_MERGE_DETACH:
                return if (language == 'de') 'wird eine Kaskade auf Persist-, Merge- und Detach-Operationen angewendet' else 'cascading is applied for persist, merge and detach operations'
            case REMOVE_MERGE_DETACH:
                return if (language == 'de') 'wird eine Kaskade auf Remove-, Merge- und Detach-Operationen angewendet' else 'cascading is applied for remove, merge and detach operations'
            case ALL:
                return if (language == 'de') 'wird eine Kaskade auf Persist-, Remove-, Merge- und Detach-Operationen angewendet' else 'cascading is applied for persist, remove, merge and detach operations'
        }
    }
}
