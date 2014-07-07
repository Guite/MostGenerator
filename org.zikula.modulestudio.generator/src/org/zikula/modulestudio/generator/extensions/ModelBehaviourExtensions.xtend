package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField
import de.guite.modulestudio.metamodel.modulestudio.AccountDeletionHandler
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntitySlugStyle
import de.guite.modulestudio.metamodel.modulestudio.EntityTimestampableType
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.IntegerField

import static de.guite.modulestudio.metamodel.modulestudio.EntitySlugStyle.*

/**
 * This class contains model behaviour related extension methods.
 */
class ModelBehaviourExtensions {

    /**
     * Extensions related to the model layer.
     */
    extension ModelExtensions = new ModelExtensions

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
        getAllEntities.filter[loggable]
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
        getAllEntities.filter[geographical]
    }

    /**
     * Checks whether the application contains at least one entity with the sluggable extension enabled.
     */
    def hasSluggable(Application it) {
        getAllEntities.exists[hasSluggableFields]
    }

    /**
     * Checks whether the application contains at least one entity with the softDeletable extension enabled.
     */
    def hasSoftDeleteable(Application it) {
        getAllEntities.exists[softDeleteable]
    }

    /**
     * Checks whether the application contains at least one entity with the sortable extension enabled.
     */
    def hasSortable(Application it) {
        getAllEntities.exists[hasSortableFields]
    }

    /**
     * Checks whether the application contains at least one entity with the timestampable extension enabled.
     */
    def hasTimestampable(Application it) {
        getAllEntities.exists[hasTimestampableFields]
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
        getAllEntities.filter[hasTranslatableFields]
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
        getAllEntities.filter[tree != EntityTreeType.NONE]
    }

    /**
     * Checks whether the application contains at least one entity with the categorisable extension enabled.
     */
    def hasCategorisableEntities(Application it) {
        !getCategorisableEntities.empty
    }

    /**
     * Returns a list of all entities with the categorisable extension enabled.
     */
    def getCategorisableEntities(Application it) {
        getAllEntities.filter[categorisable]
    }

    /**
     * Checks whether the application contains at least one entity with the meta data extension enabled.
     */
    def hasMetaDataEntities(Application it) {
        !getMetaDataEntities.empty
    }

    /**
     * Returns a list of all entities with the meta data extension enabled.
     */
    def getMetaDataEntities(Application it) {
        getAllEntities.filter[metaData]
    }

    /**
     * Checks whether the application contains at least one entity with the attributable extension enabled.
     */
    def hasAttributableEntities(Application it) {
        !getAttributableEntities.empty
    }

    /**
     * Returns a list of all entities with the attributable extension enabled.
     */
    def getAttributableEntities(Application it) {
        getAllEntities.filter[attributable]
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
        getAllEntities.filter[standardFields]
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
        getDerivedFields.filter(AbstractStringField).filter[sluggablePosition > 0].sortBy[sluggablePosition]
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
        fields.filter(IntegerField).filter[sortablePosition]
    }

    /**
     * Checks whether the entity contains at least one field with the timestampable extension enabled.
     */
    def hasTimestampableFields(Entity it) {
        !getTimestampableFields.empty
    }

    /**
     * Returns a list of all derived fields with the timestampable extension enabled.
     */
    def getTimestampableFields(Entity it) {
        fields.filter(AbstractDateField).filter[timestampable != EntityTimestampableType.NONE]
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
        getDerivedFields.filter[translatable]
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
     * Prints an output string corresponding to the given slug style.
     */
    def slugStyleAsConstant(EntitySlugStyle slugStyle) {
        switch slugStyle {
            case LOWERCASE  : 'lower'
            case UPPERCASE  : 'upper'
            case CAMEL      : 'camel'
            default: 'default'
        }
    }

    /**
     * Prints an output string corresponding to the given account deletion handler type.
     */
    def adhAsConstant(AccountDeletionHandler handler) {
        switch handler {
            case ADMIN  : 'admin'
            case GUEST  : 'guest'
            case DELETE : 'delete'
            default: '' 
        }
    }

    /**
     * Returns the uid fitting to a certain account deletion handler type.
     */
    def adhUid(AccountDeletionHandler handler) {
        switch handler {
            case ADMIN  : 2
            case GUEST  : 1
            case DELETE : 0
            default: 0 
        }
    }
}
