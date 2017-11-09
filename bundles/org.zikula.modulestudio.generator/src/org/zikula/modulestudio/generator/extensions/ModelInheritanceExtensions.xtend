package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.InheritanceRelationship
import java.util.ArrayList
import java.util.List

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

    /**
     * Returns a list of all inheriting entities.
     */
    def ArrayList<Entity> getInheritingEntities(DataObject it) {
        var children = <Entity>newArrayList()

        for (child : getChildRelations) {
            val entity = child.source
            if (!children.contains(entity)) {
                children += entity as Entity
                children += entity.getInheritingEntities
            }
        }

        children
    }

    /**
     * Returns a list of inheriting data objects.
     */
    def List<DataObject> getParentDataObjects(DataObject it, List<DataObject> parents) {
        val inheritanceRelation = outgoing.filter(InheritanceRelationship).filter[null !== target]
        if (!inheritanceRelation.empty) {
            parents.add(inheritanceRelation.head.target)
            inheritanceRelation.head.target.getParentDataObjects(parents)
        }
        parents
    }

    /**
     * Returns a list of an object and it's inheriting data objects.
     */
    def getSelfAndParentDataObjects(DataObject it) {
        getParentDataObjects(newArrayList) + newArrayList(it)
    }
}
