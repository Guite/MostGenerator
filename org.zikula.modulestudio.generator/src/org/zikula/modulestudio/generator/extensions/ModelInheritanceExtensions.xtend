package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.InheritanceRelationship

/**
 * This class contains model inheritance related extension methods.
 */
class ModelInheritanceExtensions {

    /**
     * Checks if this entity has child relations, but no parent.
     */
    def isTopSuperClass(DataObject it) {
        isInheriter && !isInheriting
    }

    /**
     * Checks if this entity has a parent.
     */
    def isInheriting(DataObject it) {
        !outgoing.filter(InheritanceRelationship).empty
    }

    /**
     * Returns the relationship pointing to the parent.
     */
    def getRelationToParentType(DataObject it) {
        outgoing.filter(InheritanceRelationship).head
    }

    /**
     * Returns the parent entity.
     */
    def parentType(DataObject it) {
        getRelationToParentType.target
    }

    /**
     * Checks if this entity has at least one child.
     */
    def isInheriter(DataObject it) {
        !getChildRelations.empty
    }

    /**
     * Returns a list of all child relationships.
     */
    def getChildRelations(DataObject it) {
        incoming.filter(InheritanceRelationship)
    }
}
