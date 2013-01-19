package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.EntitySlugStyle
import de.guite.modulestudio.metamodel.modulestudio.EntityTimestampableType
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType

/**
 * This class contains model behaviour related extension methods.
 */
class ModelBehaviourExtensions {

    /**
     * Extensions related to the model layer.
     */
    @Inject extension ModelExtensions = new ModelExtensions()

    /**
     * Checks whether the application contains at least one entity with the loggable extension enabled.
     */
    def hasLoggable(Application it) {
        !getLoggableEntities.isEmpty
    }

    /**
     * Returns a list of all entities with the loggable extension enabled.
     */
    def getLoggableEntities(Application it) {
        getAllEntities.filter(e|e.loggable)
    }

    /**
     * Checks whether the application contains at least one entity with the geographical extension enabled.
     */
    def hasGeographical(Application it) {
        !getGeographicalEntities.isEmpty
    }

    /**
     * Returns a list of all entities with the geographical extension enabled.
     */
    def getGeographicalEntities(Application it) {
        getAllEntities.filter(e|e.geographical)
    }

    /**
     * Checks whether the application contains at least one entity with the sluggable extension enabled.
     */
    def hasSluggable(Application it) {
        getAllEntities.exists(e|e.hasSluggableFields)
    }

    /**
     * Checks whether the application contains at least one entity with the softDeletable extension enabled.
     */
    def hasSoftDeleteable(Application it) {
        getAllEntities.exists(e|e.softDeleteable)
    }

    /**
     * Checks whether the application contains at least one entity with the sortable extension enabled.
     */
    def hasSortable(Application it) {
        getAllEntities.exists(e|e.hasSortableFields)
    }

    /**
     * Checks whether the application contains at least one entity with the timestampable extension enabled.
     */
    def hasTimestampable(Application it) {
        getAllEntities.exists(e|e.hasTimestampableFields)
    }

    /**
     * Checks whether the application contains at least one entity with the translatable extension enabled.
     */
    def hasTranslatable(Application it) {
        !getTranslatableEntities.isEmpty
    }

    /**
     * Returns a list of all entities with the translatable extension enabled.
     */
    def getTranslatableEntities(Application it) {
        getAllEntities.filter(e|e.hasTranslatableFields)
    }

    /**
     * Checks whether the application contains at least one entity with the tree extension enabled.
     */
    def hasTrees(Application it) {
        !getTreeEntities.isEmpty
    }

    /**
     * Returns a list of all entities with the tree extension enabled.
     */
    def getTreeEntities(Application it) {
        getAllEntities.filter(e|e.tree != EntityTreeType::NONE)
    }

    /**
     * Checks whether the application contains at least one entity with the categorisable extension enabled.
     */
    def hasCategorisableEntities(Application it) {
        !getCategorisableEntities.isEmpty
    }

    /**
     * Returns a list of all entities with the categorisable extension enabled.
     */
    def getCategorisableEntities(Application it) {
        getAllEntities.filter(e|e.categorisable)
    }

    /**
     * Checks whether the application contains at least one entity with the meta data extension enabled.
     */
    def hasMetaDataEntities(Application it) {
        !getMetaDataEntities.isEmpty
    }

    /**
     * Returns a list of all entities with the meta data extension enabled.
     */
    def getMetaDataEntities(Application it) {
        getAllEntities.filter(e|e.metaData)
    }

    /**
     * Checks whether the application contains at least one entity with the attributable extension enabled.
     */
    def hasAttributableEntities(Application it) {
        !getAttributableEntities.isEmpty
    }

    /**
     * Returns a list of all entities with the attributable extension enabled.
     */
    def getAttributableEntities(Application it) {
        getAllEntities.filter(e|e.attributable)
    }

    /**
     * Checks whether the application contains at least one entity with the standard field extension enabled.
     */
    def hasStandardFieldEntities(Application it) {
        !getStandardFieldEntities.isEmpty
    }

    /**
     * Returns a list of all entities with the standard field extension enabled.
     */
    def getStandardFieldEntities(Application it) {
        getAllEntities.filter(e|e.standardFields)
    }



    /**
     * Checks whether the entity contains at least one field with the sluggable extension enabled.
     */
    def hasSluggableFields(Entity it) {
        !getSluggableFields.isEmpty
    }

    /**
     * Returns a list of all derived fields with the sluggable extension enabled.
     */
    def getSluggableFields(Entity it) {
        getDerivedFields.filter(e|e.sluggablePosition > 0)
    }

    /**
     * Checks whether the entity contains at least one field with the sortable extension enabled.
     */
    def hasSortableFields(Entity it) {
        !getSortableFields.isEmpty
    }

    /**
     * Returns a list of all derived fields with the sortable extension enabled.
     */
    def getSortableFields(Entity it) {
        fields.filter(typeof(IntegerField)).filter(e|e.sortablePosition == true)
    }

    /**
     * Checks whether the entity contains at least one field with the timestampable extension enabled.
     */
    def hasTimestampableFields(Entity it) {
        !getTimestampableFields.isEmpty
    }

    /**
     * Returns a list of all derived fields with the timestampable extension enabled.
     */
    def getTimestampableFields(Entity it) {
        fields.filter(typeof(AbstractDateField)).filter(e|e.timestampable != EntityTimestampableType::NONE)
    }

    /**
     * Checks whether the entity contains at least one field with the translatable extension enabled.
     */
    def hasTranslatableFields(Entity it) {
        !getTranslatableFields.isEmpty
    }

    /**
     * Returns a list of all derived fields with the translatable extension enabled.
     */
    def getTranslatableFields(Entity it) {
        getDerivedFields.filter(e|e.translatable)
    }

    /**
     * Returns a list of all editable fields with the translatable extension enabled.
     */
    def getEditableTranslatableFields(Entity it) {
        getEditableFields.filter(e|e.translatable)
    }

    /**
     * Returns a list of all editable fields with the translatable extension disabled.
     */
    def getEditableNonTranslatableFields(Entity it) {
        getEditableFields.filter(e|!e.translatable)
    }

    /**
     * Checks whether the entity contains at least one field with the translatable extension enabled.
     */
    def hasTranslatableSlug(Entity it) {
        !getSluggableFields.filter(e|e.translatable).isEmpty
    }

    /**
     * Prints an output string corresponding to the given slug style.
     */
    def dispatch asConstant(EntitySlugStyle slugStyle) {
        switch slugStyle {
            case EntitySlugStyle::LOWERCASE                  : 'default'
            case EntitySlugStyle::CAMEL                      : 'camel'
            default: 'default'
        }
    }

    /**
     * Prints an output string corresponding to the given timestampable type.
     */
    def dispatch asConstant(EntityTimestampableType tsType) {
        switch tsType {
            case EntityTimestampableType::UPDATE             : 'update'
            case EntityTimestampableType::CREATE             : 'create'
            case EntityTimestampableType::CHANGE             : 'change'
            default: 'update'
        }
    }

    /**
     * Prints an output string corresponding to the given tree type.
     */
    def dispatch asConstant(EntityTreeType treeType) {
        switch treeType {
            case EntityTreeType::NONE                        : ''
            case EntityTreeType::NESTED                      : 'nested'
            case EntityTreeType::CLOSURE                     : 'closure'
            default: ''
        }
    }
}
