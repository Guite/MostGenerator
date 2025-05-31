package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberRole
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.Relationship
import java.util.List

/**
 * This class contains model behaviour related extension methods.
 */
class ModelBehaviourExtensions {

    extension DateTimeExtensions = new DateTimeExtensions
    extension ModelExtensions = new ModelExtensions

    /**
     * Checks whether the feature activation helper class should be generated or not.
     */
    def needsFeatureActivationHelper(Application it) {
        hasTranslatable || hasTrees
    }

    /**
     * Checks whether a specific entity needs functionality of the feature activation helper.
     */
    def needsFeatureActivationHelperEntity(Entity it) {
        hasTranslatableFields || tree
    }

    /**
     * Checks whether the application contains at least one entity with the loggable extension enabled.
     */
    def hasLoggable(Application it) {
        !getLoggableEntities.empty
    }

    /**
     * Returns a list of all entities with the loggable extension enabled.
     */
    def getLoggableEntities(Application it) {
        entities.filter[loggable]
    }

    /**
     * Checks whether the application contains at least one entity with the geographical extension enabled.
     */
    def hasGeographical(Application it) {
        !getGeographicalEntities.empty
    }

    /**
     * Returns a list of all entities with the geographical extension enabled.
     */
    def getGeographicalEntities(Application it) {
        entities.filter[geographical]
    }

    /**
     * Checks whether the application contains at least one entity with the sluggable extension enabled.
     */
    def hasSluggable(Application it) {
        entities.exists[hasSluggableFields]
    }

    /**
     * Checks whether the application contains at least one entity with the sortable extension enabled.
     */
    def hasSortable(Application it) {
        entities.exists[hasSortableFields]
    }

    /**
     * Checks whether the application contains at least one entity with the translatable extension enabled.
     */
    def hasTranslatable(Application it) {
        !getTranslatableEntities.empty
    }

    /**
     * Returns a list of all entities with the translatable extension enabled.
     */
    def getTranslatableEntities(Application it) {
        entities.filter[hasTranslatableFields]
    }

    /**
     * Checks whether the application contains at least one entity with loggable and translatable extensions enabled.
     */
    def hasLoggableTranslatable(Application it) {
        !getLoggableTranslatableEntities.empty
    }

    /**
     * Returns a list of all entities with loggable and translatable extensions enabled.
     */
    def getLoggableTranslatableEntities(Application it) {
        entities.filter[loggable && hasTranslatableFields]
    }

    /**
     * Checks whether the application contains at least one entity with the tree extension enabled.
     */
    def hasTrees(Application it) {
        !getTreeEntities.empty
    }

    /**
     * Returns a list of all entities with the tree extension enabled.
     */
    def getTreeEntities(Application it) {
        entities.filter[tree]
    }

    /**
     * Checks whether the application contains at least one entity with the standard field extension enabled.
     */
    def hasStandardFieldEntities(Application it) {
        !getStandardFieldEntities.empty
    }

    /**
     * Returns a list of all entities with the standard field extension enabled.
     */
    def getStandardFieldEntities(Application it) {
        entities.filter[standardFields]
    }

    /**
     * Checks whether the application provides automatic archiving or deletion.
     */
    def hasAutomaticExpiryHandling(Application it) {
        hasAutomaticArchiving || hasAutomaticExpiryDeletion
    }

    /**
     * Checks whether the application provides automatic archiving.
     */
    def hasAutomaticArchiving(Application it) {
        !getArchivingEntities.empty
    }

    /**
     * Returns a list of all entities supporting automatic archiving.
     */
    def getArchivingEntities(Application it) {
        entities.filter[hasArchive && hasEndDateField]
    }

    /**
     * Checks whether the application provides automatic deletion.
     */
    def hasAutomaticExpiryDeletion(Application it) {
        !getExpiryDeletionEntities.empty
    }

    /**
     * Returns a list of all entities supporting automatic deletion.
     */
    def getExpiryDeletionEntities(Application it) {
        entities.filter[deleteExpired && hasEndDateField]
    }

    /**
     * Checks whether the entity contains at least one field with the sluggable extension enabled.
     */
    def hasSluggableFields(Entity it) {
        !getSluggableFields.empty
    }

    /**
     * Returns a list of all string type fields with the sluggable extension enabled.
     */
    def getSluggableFields(Entity it) {
        fields.filter(AbstractStringField).filter[sluggablePosition > 0].sortBy[sluggablePosition]
    }

    def needsSlugHandler(Entity it) {
        tree || needsRelativeOrInversedRelativeSlugHandler
    }

    def needsRelativeOrInversedRelativeSlugHandler(Entity it) {
        needsRelativeSlugHandler || needsInversedRelativeSlugHandler
    }

    def needsRelativeAndInversedRelativeSlugHandlers(Entity it) {
        needsRelativeSlugHandler && needsInversedRelativeSlugHandler
    }

    def needsRelativeSlugHandler(Entity it) {
        !getRelationsForRelativeSlugHandler.empty
    }

    def needsInversedRelativeSlugHandler(Entity it) {
        !getRelationsForInversedRelativeSlugHandler.empty
    }

    def getRelationsForRelativeSlugHandler(Entity it) {
        application.getSlugRelations.filter[target == it && (it instanceof OneToOneRelationship || it instanceof OneToManyRelationship)]
        + application.getSlugRelations.filter[source == it && (it instanceof ManyToOneRelationship)]
    }

    def getRelationsForInversedRelativeSlugHandler(Entity it) {
        application.getSlugRelations.filter[source == it && (it instanceof OneToOneRelationship || it instanceof OneToManyRelationship)]
        + application.getSlugRelations.filter[target == it && (it instanceof ManyToOneRelationship)]
    }

    /**
     * Returns a list of all relationships connecting two sluggable entities.
     * The list is filtered to have unique source-target entity combinations.
     */
    def getSlugRelations(Application it) {
        val allSlugRelations = relations
            .filter[r|r instanceof OneToOneRelationship || r instanceof OneToManyRelationship || r instanceof ManyToOneRelationship]
            .filter[r|r.source.hasSluggableFields && r.target.hasSluggableFields]
        val List<Relationship> uniqueSlugRelations = newArrayList
        for (relation : allSlugRelations) {
            var isRedundant = false
            for (uniqueRelation : uniqueSlugRelations) {
                if (uniqueRelation.source == relation.source && uniqueRelation.target == relation.target) {
                    isRedundant = true
                }
            }
            if (!isRedundant) {
                uniqueSlugRelations += relation
            }
        }

        uniqueSlugRelations
    }

    /**
     * Checks whether the entity contains at least one field with the sortable extension enabled.
     */
    def hasSortableFields(Entity it) {
        !getSortableFields.empty
    }

    /**
     * Returns a list of all derived fields with the sortable extension enabled.
     */
    def getSortableFields(Entity it) {
        fields.filter(NumberField).filter[NumberRole.SORTABLE_POSITION == role]
    }

    /**
     * Checks whether the entity contains at least one field with the translatable extension enabled.
     */
    def hasTranslatableFields(Entity it) {
        !getTranslatableFields.empty
    }

    /**
     * Returns a list of all derived fields with the translatable extension enabled.
     */
    def getTranslatableFields(Entity it) {
        fields.filter[translatable]
    }

    /**
     * Returns a list of all editable fields with the translatable extension enabled.
     */
    def getEditableTranslatableFields(Entity it) {
        getEditableFields.filter[translatable]
    }

    /**
     * Returns a list of all editable fields with the translatable extension disabled.
     */
    def getEditableNonTranslatableFields(Entity it) {
        getEditableFields.filter[!translatable]
    }

    /**
     * Checks whether the entity contains at least one field with the translatable extension enabled.
     */
    def hasTranslatableSlug(Entity it) {
        !getSluggableFields.filter[translatable].empty
    }

    /**
     * Determines the version field of an entity if there is one.
     */
    def getVersionField(Entity it) {
        fields.filter(NumberField).filter[NumberRole.VERSION == role].head
    }

    /**
     * Checks whether a composer execution is required before installing the application.
     */
    def needsComposerInstall(Application it) {
        hasGeographical 
    }
}
