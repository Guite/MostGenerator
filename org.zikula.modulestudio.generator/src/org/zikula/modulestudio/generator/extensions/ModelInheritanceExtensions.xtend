package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.InheritanceRelationship

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
        !outgoing.filter(InheritanceRelationship).empty
    }

    /**
     * Returns the relationship pointing to the parent.
     */
    def getRelationToParentType(Entity it) {
        outgoing.filter(InheritanceRelationship).head
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
        !getChildRelations.empty
    }

    /**
     * Returns a list of all child relationships.
     */
    def getChildRelations(Entity it) {
        incoming.filter(InheritanceRelationship)
    }
}
