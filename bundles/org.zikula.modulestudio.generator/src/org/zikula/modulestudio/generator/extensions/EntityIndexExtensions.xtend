package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.EntityIndex
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.EntityIndexItem
import de.guite.modulestudio.metamodel.OneToManyRelationship

class EntityIndexExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions

    def indexItemForEntity(EntityIndexItem it) {
        // check if index item references a field
        val referencedField = getReferencedField
        if (null !== referencedField) {
            return referencedField.name.formatForCode
        }

        // check if index item references a foreign key
        val referencedIncoming = getReferencedIncomingAssociation
        if (null !== referencedIncoming) {
            if ('id'.equals(referencedIncoming.sourceField)) {
                return referencedIncoming.sourceAlias + '_id'
            }
            return referencedIncoming.sourceField
        }

        return 'id'
    }

    def indexItemForSymfonyValidator(EntityIndexItem it) {
        // check if index item references a field
        val referencedField = getReferencedField
        if (null !== referencedField) {
            return referencedField.name.formatForCode
        }

        // check if index item references a foreign key
        val referencedIncoming = getReferencedIncomingAssociation
        if (null !== referencedIncoming) {
            return referencedIncoming.sourceAlias
        }

        return 'id'
    }

    def includesNotNullableItem(EntityIndex it) {
        for (item : items) {
            // check if index item references a field
            val referencedField = item.getReferencedField
            if (null !== referencedField) {
                if (referencedField instanceof DerivedField && !(referencedField as DerivedField).nullable) {
                    return true
                }
            } else {
                // check if index item references a foreign key
                val referencedIncoming = item.getReferencedIncomingAssociation
                if (null !== referencedIncoming) {
                    if (!referencedIncoming.nullable) {
                        return true
                    }
                }
            }
        }
        false
    }

    def private getPossibleIndexFields(DataObject it) {
        return getSelfAndParentDataObjects.map[fields].flatten
    }

    def private getReferencedField(EntityIndexItem it) {
        val itemName = name
        val fields = index.entity.possibleIndexFields.filter[name == itemName]
        if (!fields.empty) {
            return fields.head
        }

        null
    }

    def private getReferencedIncomingAssociation(EntityIndexItem it) {
        val relations = index.entity.incoming.filter(OneToManyRelationship).filter[r|r.bidirectional && r.sourceAlias.equals(name)]
        if (!relations.empty) {
            return relations.head
        }

        null
    }
}
