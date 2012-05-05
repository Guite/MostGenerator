package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.InheritanceRelationship
import de.guite.modulestudio.metamodel.modulestudio.InheritanceStrategyType

/**
 * This class contains model inheritance related extension methods.
 */
class ModelInheritanceExtensions {

    /**
     * Checks if this entity has child relations, but no parent.
     */
    def isTopSuperClass(Entity it) {
        isInheriter && !isInheriting
    }

    /**
     * Checks if this entity has a parent.
     */
    def isInheriting(Entity it) {
        !outgoing.filter(typeof(InheritanceRelationship)).isEmpty
    }

    /**
     * Returns the relationship pointing to the parent.
     */
    def getRelationToParentType(Entity it) {
        outgoing.filter(typeof(InheritanceRelationship)).head
    }

    /**
     * Returns the parent entity.
     */
    def parentType(Entity it) {
        getRelationToParentType.target
    }

    /**
     * Checks if this entity has at least one child.
     */
    def isInheriter(Entity it) {
        !getChildRelations.isEmpty
    }

    /**
     * Returns a list of all child relationships.
     */
    def getChildRelations(Entity it) {
        incoming.filter(typeof(InheritanceRelationship))
    }

    /**
     * Prints an output string corresponding to the given inheritance type.
     */
    def asConstant(InheritanceStrategyType inheritanceType) {
        switch inheritanceType {
            case InheritanceStrategyType::SINGLE_TABLE       : 'SINGLE_TABLE'
            case InheritanceStrategyType::JOINED             : 'JOINED'
            default: ''
        }
    }
}
