package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CascadeType
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ManyToManyPermissionInheritanceType
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.RelationAutoCompletionUsage
import de.guite.modulestudio.metamodel.Relationship

/**
 * This class contains model join relationship related extension methods.
 */
class ModelJoinExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    /**
     * Returns the table name for a certain join side, including the application specific prefix.
     */
    def fullJoinTableName(Relationship it, Boolean useTarget, Entity joinedEntityForeign) {
        tableNameWithPrefix((if (useTarget) target.application else source.application), getJoinTableName(useTarget, joinedEntityForeign))
    }

    /**
     * Returns the table name for a certain join side.
     */
    def private getJoinTableName(Relationship it, Boolean useTarget, Entity joinedEntityForeign) {
        switch it {
            OneToManyRelationship case useTarget: sourceAlias.formatForDB + targetAlias.formatForDB
            //ManyToManyRelationship: source.name.formatForDB + '_' + target.name.formatForDB
            ManyToManyRelationship: {
                if (application.relations.filter(ManyToManyRelationship).filter[e|e.source == source && e.target == target].size > 1) {
                    source.name.formatForDB + '_' + refClass.formatForDB
                } else {
                    source.name.formatForDB + '_' + target.name.formatForDB
                }
            }
            default: joinedEntityForeign.name.formatForDB
        }
    }

    /**
     * Whether the application requires auto completion components.
     */
    def needsAutoCompletion(Application it) {
        hasAutoCompletionRelation
    }

    /**
     * Whether the application contains any relationships using auto completion.
     */
    def hasAutoCompletionRelation(Application it) {
        !relations.filter(Relationship).filter[useAutoCompletion != RelationAutoCompletionUsage.NONE].empty
    }

    /**
     * Returns a list of all incoming bidirectional join relations.
     */
    def getBidirectionalIncomingRelations(Entity it) {
        incoming.filter(OneToOneRelationship).filter[bidirectional]
            + incoming.filter(OneToManyRelationship).filter[bidirectional]
            + incoming.filter(ManyToManyRelationship).filter[bidirectional]
    }

    /**
     * Returns a list of all incoming bidirectional join relations which inherit permissions.
     */
    def getBidirectionalIncomingPermissionInheriters(Entity it) {
        incoming.filter(OneToOneRelationship).filter[bidirectional && inheritPermissions]
            + incoming.filter(OneToManyRelationship).filter[bidirectional && inheritPermissions]
            + incoming.filter(ManyToManyRelationship).filter[bidirectional && inheritPermissions != ManyToManyPermissionInheritanceType.NONE]
    }

    /**
     * Returns a list of all incoming bidirectional join relations (excluding inheritance)
     * which are not nullable.
     */
    def getBidirectionalIncomingAndMandatoryRelations(Entity it) {
        getBidirectionalIncomingRelations.filter[!nullable]
    }

    /**
     * Returns a list of all incoming bidirectional join relations which are either one2one or one2many.
     */
    def getBidirectionalIncomingRelationsWithOneSource(Entity it) {
        incoming.filter(OneToOneRelationship).filter[bidirectional]
            + incoming.filter(OneToManyRelationship).filter[bidirectional]
    }

    /**
     * Returns a list of all incoming bidirectional join relations (excluding inheritance) 
     * which have the many cardinality on the source side and cascade persist active.
     */
    def getIncomingRelationsForCloning(Entity it) {
        getBidirectionalIncomingRelations.filter[isManySide(false) && hasCascadePersist]
    }

    /**
     * Returns a list of all outgoing join relations (excluding inheritance) 
     * which have the many cardinality on the target side and cascade persist active.
     */
    def getOutgoingRelationsForCloning(Entity it) {
        outgoing.filter[isManySide(true) && hasCascadePersist]
    }

    /**
     * Returns a list of all outgoing join relations which do not have a delete cascade.
     */
    def getOutgoingRelationsWithoutDeleteCascade(Entity it) {
        val excludedCascadeTypes = #[CascadeType.REMOVE, CascadeType.PERSIST_REMOVE, CascadeType.REMOVE_MERGE, CascadeType.REMOVE_DETACH, CascadeType.PERSIST_REMOVE_MERGE, CascadeType.PERSIST_REMOVE_DETACH, CascadeType.ALL]
        outgoing.filter[!excludedCascadeTypes.contains(cascade)].filter[!(it instanceof ManyToOneRelationship)]
    }

    /**
     * Returns a list of all relationships for a given entity connecting entities.
     */
    def getCommonRelations(Entity it, Boolean incoming) {
        if (incoming) {
            getBidirectionalIncomingRelations
        } else {
            outgoing
        }
    }

    def hasCascadePersist(Relationship it) {
        newArrayList(
            CascadeType.PERSIST_VALUE,
            CascadeType.PERSIST_REMOVE_VALUE,
            CascadeType.PERSIST_MERGE_VALUE,
            CascadeType.PERSIST_DETACH_VALUE,
            CascadeType.PERSIST_REMOVE_MERGE_VALUE,
            CascadeType.PERSIST_REMOVE_DETACH_VALUE,
            CascadeType.PERSIST_MERGE_DETACH_VALUE,
            CascadeType.ALL_VALUE
        ).contains(cascade.value);
    }

    /**
     * Returns a list of all outgoing join relations which are either one2many or many2many.
     */
    def getOutgoingCollections(Entity it) {
        outgoing.filter(OneToManyRelationship) + outgoing.filter(ManyToManyRelationship)
    }

    /**
     * Returns a list of all incoming join relations which are either many2one or many2many.
     */
    def getIncomingCollections(Entity it) {
        outgoing.filter(ManyToOneRelationship) + incoming.filter(ManyToManyRelationship).filter[bidirectional]
    }

    /**
     * Returns a list combining all outgoing join relations which are either one2many or many2many
     * with all incoming join relations which are either many2one or many2many.
     */
    def getCollections(Entity it) {
        getOutgoingCollections + getIncomingCollections
    }

    /**
     * Checks for whether the entity has outgoing join relations which are either one2many or many2many.
     */
    def hasOutgoingCollections(Entity it) {
        !getOutgoingCollections.empty
    }

    /**
     * Checks for whether the entity has incoming join relations which are either many2one or many2many.
     */
    def hasIncomingCollections(Entity it) {
        !getIncomingCollections.empty
    }

    /**
     * Checks for whether the entity has either outgoing join relations which are either
     * one2many or many2many, or incoming join relations which are either many2one or many2many.
     */
    def hasCollections(Entity it) {
        !getCollections.empty
    }

    /**
     * Returns a concatenated list of all source fields.
     */
    def getSourceFields(Relationship it) {
        sourceField.split(', ')
    }
    /**
     * Returns a concatenated list of all target fields.
     */
    def getTargetFields(Relationship it) {
        targetField.split(', ')
    }

    /**
     * Checks whether the given string is the name of the default (= no custom) identifier field.
     */
    def isDefaultIdFieldName(Entity it, String s) {
        newArrayList('id', name.formatForDB + 'id', name.formatForDB + '_id').contains(s)
    }

    /**
     * Checks whether the given list contains the name of a default (= no custom) identifier field.
     */
    def boolean containsDefaultIdField(Iterable<String> l, Entity entity) {
        isDefaultIdFieldName(entity, l.head) || (l.size > 1 && containsDefaultIdField(l.tail, entity))
    }

    /**
     * Checks for whether a certain relationship side has a multiplicity of one or many.
     */
    def isManySide(Relationship it, boolean useTarget) {
        switch it {
            OneToOneRelationship: false
            OneToManyRelationship: useTarget
            ManyToOneRelationship: !useTarget
            ManyToManyRelationship: true
            default: false
        }
    }

    /**
     * Checks for whether a certain relationship side has a multiplicity of one or many.
     * Special version used in view.pagecomponents.Relations to decide about template visibility.
     */
    def isManySideDisplay(Relationship it, boolean useTarget) {
        switch it {
            OneToOneRelationship: false
            OneToManyRelationship: useTarget
            ManyToOneRelationship: false/*!useTarget*/
            ManyToManyRelationship: true
            default: false
        }
    }

    /**
     * Returns a unique name for a relationship used by JavaScript during editing entities with auto completion fields.
     * The name is concatenated from the edited entity as well as the relation alias name.
     */
    def getUniqueRelationNameForJs(Relationship it, Entity targetEntity, String relationAliasName) {
        application.prefix
        + targetEntity.name.formatForCodeCapital
        + '_'
        + relationAliasName
    }

    /**
     * Returns a constant for the multiplicity of the target side of a join relationship.
     */
    def getTargetMultiplicity(Relationship it, Boolean useTarget) {
        switch it {
            OneToOneRelationship: 'One'
            OneToManyRelationship: if (!useTarget) 'One' else 'Many'
            ManyToOneRelationship: if (!useTarget) 'Many' else 'One'
            default: 'Many' // ManyToMany
        }
    }

    /**
     * Checks whether the entity is target of an indexed relationship.
     * That is true if at least one incoming relation has an indexBy field set. 
     */
    def isIndexByTarget(Entity it) {
        !incoming.filter[null !== getIndexByField && !getIndexByField.empty].empty
    }

    /**
     * Checks whether this field is used by an indexed relationship.
     * That is true if at least one incoming relation of it's entity has an indexBy field set to it's name. 
     */
    def isIndexByField(Field it) {
        null !== entity && !entity.incoming.filter[r|r.getIndexByField == name].empty
    }

    /**
     * Returns if the relationship is an indexed relation or not.
     */
    def isIndexed(Relationship it) {
        switch it {
            OneToManyRelationship: null !== it.indexBy && !it.indexBy.empty
            ManyToManyRelationship: null !== it.indexBy && !it.indexBy.empty
            default: false
        }
    }

    /**
     * Returns the name of the index field.
     */
    def getIndexByField(Relationship it) {
        switch it {
            OneToManyRelationship: it.indexBy
            ManyToManyRelationship: it.indexBy
            default: ''
        }
    }
}
