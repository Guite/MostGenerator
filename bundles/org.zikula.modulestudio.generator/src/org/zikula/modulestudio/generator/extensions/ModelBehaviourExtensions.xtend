package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.AccountDeletionHandler
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityIpTraceableType
import de.guite.modulestudio.metamodel.EntitySlugStyle
import de.guite.modulestudio.metamodel.EntityTimestampableType
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.StringField

/**
 * This class contains model behaviour related extension methods.
 */
class ModelBehaviourExtensions {

    /**
     * Extensions related to the model layer.
     */
    extension ModelExtensions = new ModelExtensions

    /**
     * Extensions related to generator settings.
     */
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions

    /**
     * Checks whether the feature activation helper class should be generated or not.
     */
    def needsFeatureActivationHelper(Application it) {
        hasCategorisableEntities || hasAttributableEntities || hasTranslatable || hasTrees
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
     * Checks whether the generation of ics templates is needed or not.
     */
    def hasEntitiesWithIcsTemplates(Application it) {
        generateIcsTemplates && getAllEntities.exists[supportsIcsTemplates]
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
     * Checks whether the entity contains at least one field with the ipTraceable extension enabled.
     */
    def hasIpTraceableFields(Entity it) {
        !getIpTraceableFields.empty
    }

    /**
     * Returns a list of all derived fields with the ipTraceable extension enabled.
     */
    def getIpTraceableFields(Entity it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[ipTraceable != EntityIpTraceableType.NONE]].flatten
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
        getAllEntities.filter[hasArchive && null !== getEndDateField]
    }



    /**
     * Checks whether the entity supports ics templates.
     */
    def supportsIcsTemplates(Entity it) {
        null !== startDateField && null !== endDateField
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
        getSelfAndParentDataObjects.map[fields.filter(IntegerField).filter[sortablePosition]].flatten
    }

    /**
     * Returns whether form input fields for slug elements can be used or not.
     */
    def supportsSlugInputFields(Application it) {
        false // no slug input element yet, see https://github.com/Atlantic18/DoctrineExtensions/issues/140
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
        getSelfAndParentDataObjects.map[fields.filter(AbstractDateField).filter[timestampable != EntityTimestampableType.NONE]].flatten
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
        getSelfAndParentDataObjects.map[getDerivedFields.filter[translatable]].flatten
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
    def getEditableNonTranslatableFields(DataObject it) {
        if (it instanceof Entity) {
            getEditableFields.filter[!translatable]
        } else {
            getEditableFields
        }
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

    def setTranslatorMethod(Application it) '''
        /**
         * Sets the translator.
         *
         * @param TranslatorInterface $translator Translator service instance
         */
        public function setTranslator(/*TranslatorInterface */$translator)
        {
            $this->translator = $translator;
        }
    '''
}
