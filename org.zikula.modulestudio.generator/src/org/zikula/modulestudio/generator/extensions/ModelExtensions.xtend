package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.modulestudio.EntityIdentifierStrategy
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexType
import de.guite.modulestudio.metamodel.modulestudio.EntityLockType
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.IpAddressScope
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ListVar
import de.guite.modulestudio.metamodel.modulestudio.Models
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import java.util.List

import static de.guite.modulestudio.metamodel.modulestudio.EntityLockType.*
import static de.guite.modulestudio.metamodel.modulestudio.IpAddressScope.*

/**
 * This class contains model related extension methods.
 * TODO document class and methods.
 */
class ModelExtensions {
    extension CollectionUtils = new CollectionUtils
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    /**
     * Returns a list of all entities in this application.
     */
    def getAllEntities(Application it) {
        var allEntities = models.head.entities
        for (entityContainer : models.tail)
            allEntities.addAll(entityContainer.entities)
        allEntities
    }

    /**
     * Returns a list of all entities in the primary model container.
     */
    def getEntitiesFromDefaultDataSource(Application it) {
        getDefaultDataSource.entities
    }

    /**
     * Returns a list of all entity fields in this application.
     */
    def getAllEntityFields(Application it) {
        getAllEntities.map[fields].flatten.toList
    }

    /**
     * Returns a list of all entity fields in a certain model container.
     */
    def getModelEntityFields(Models it) {
        entities.map[fields].flatten.toList
    }

    /**
     * Returns the leading entity in the primary model container.
     */
    def getLeadingEntity(Application it) {
        getEntitiesFromDefaultDataSource.findFirst[leading]
    }

    /**
     * Checks whether the application contains at least one entity with at least one image field.
     */
    def hasImageFields(Application it) {
        getAllEntities.exists[hasImageFieldsEntity]
    }

    /**
     * Checks whether the application contains at least one entity with at least one colour field.
     */
    def hasColourFields(Application it) {
        getAllEntities.exists[hasColourFieldsEntity]
    }

    /**
     * Checks whether the application contains at least one entity with at least one country field.
     */
    def hasCountryFields(Application it) {
        getAllEntities.exists[hasCountryFieldsEntity]
    }

    /**
     * Checks whether the application contains at least one entity with at least one upload field.
     */
    def hasUploads(Application it) {
        !getUploadEntities.empty
    }

    /**
     * Returns a list of all entities with at least one upload field.
     */
    def getUploadEntities(Application it) {
        getAllEntities.filter[hasUploadFieldsEntity]
    }

    /**
     * Returns a list of all user fields in this application.
     */
    def getAllUserFields(Application it) {
        getAllEntityFields.filter(UserField)
    }

    /**
     * Checks whether the application contains at least one user field.
     */
    def boolean hasUserFields(Application it) {
        !getAllUserFields.empty
    }

    /**
     * Returns a list of all list fields in this application.
     */
    def getAllListFields(Application it) {
        getAllEntityFields.filter(ListField)
    }

    /**
     * Checks whether the application contains at least one list field.
     */
    def hasListFields(Application it) {
        !getAllListFields.empty
    }

    /**
     * Returns a list of all entities with at least one list field.
     */
    def getListEntities(Application it) {
        getAllEntities.filter[hasListFieldsEntity]
    }


    /**
     * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled.
     */
    def hasBooleansWithAjaxToggle(Application it) {
        !getEntitiesWithAjaxToggle.empty
    }

    /**
     * Returns a list of all entities with at least one boolean field having ajax toggle enabled.
     */
    def getEntitiesWithAjaxToggle(Application it) {
        getAllEntities.filter[hasBooleansWithAjaxToggleEntity]
    }

    /**
     * Returns the first model container which is default data source.
     */
    def getDefaultDataSource(Application it) {
        models.findFirst[defaultDataSource]
    }

    /**
     * Prepends the application database prefix to a given string.
     * Beginning with Zikula 1.4.0 the vendor is prefixed, too.
     */
    def tableNameWithPrefix(Application it, String inputString) {
        if (targets('1.3.5')) {
            prefix + '_' + inputString
        } else {
            vendor.formatForDB + '_' + prefix() + '_' + inputString
        }
    }

    /**
     * Returns the full table name for a given entity instance.
     */
    def fullEntityTableName(Entity it) {
        tableNameWithPrefix(container.application, name.formatForDB)
    }

    /**
     * Returns either the plural or the singular entity name, depending on a given boolean.
     */
    def getEntityNameSingularPlural(Entity it, Boolean usePlural) {
        if (usePlural) nameMultiple else name
    }

    /**
     * Checks whether this entity has at least one normal (non-unique) index.
     */
    def hasNormalIndexes(Entity it) {
        !getNormalIndexes.empty
    }

    /**
     * Returns a list of all normal (non-unique) indexes for this entity.
     */
    def getNormalIndexes(Entity it) {
        indexes.filter[type == EntityIndexType.NORMAL]
    }

    /**
     * Checks whether this entity has at least one unique index.
     */
    def hasUniqueIndexes(Entity it) {
        !getUniqueIndexes.empty
    }

    /**
     * Returns a list of all unique indexes for this entity.
     */
    def getUniqueIndexes(Entity it) {
        indexes.filter[type == EntityIndexType.UNIQUE]
    }

    /**
     * Returns a list of all derived fields (excluding calculated fields) of the given entity.
     */
    def getDerivedFields(Entity it) {
        fields.filter(DerivedField)
    }

    /**
     * Returns a list of all derived and unique fields of the given entity
     */
    def getUniqueDerivedFields(Entity it) {
        getDerivedFields.filter[unique]
    }

    /**
     * Returns a list of all derived and primary key fields of the given entity.
     */
    def getPrimaryKeyFields(Entity it) {
        getDerivedFields.filter[primaryKey]
    }

    /**
     * Returns the first derived and primary key field of the given entity.
     */
    def getFirstPrimaryKey(Entity it) {
        getDerivedFields.findFirst[primaryKey]
    }

    /**
     * Checks whether the entity has more than one primary key fields.
     */
    def hasCompositeKeys(Entity it) {
        getPrimaryKeyFields.size > 1
    }

    /**
     * Concatenates all id strings using underscore as delimiter.
     * Used for generating some controller classes. 
     */
    def idFieldsAsParameterCode(Entity it, String objVar) '''«IF hasCompositeKeys»«FOR pkField : getPrimaryKeyFields SEPARATOR ' . \'_\' . '»$this->«pkField.name.formatForCode»«ENDFOR»«ELSE»$this->«getFirstPrimaryKey.name.formatForCode»«ENDIF»'''

    /**
     * Concatenates all id strings using underscore as delimiter.
     * Used for generating some view templates. 
     */
    def idFieldsAsParameterTemplate(Entity it) '''«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»'''

    /**
     * Returns a list of all fields which should be displayed.
     */
    def getDisplayFieldsForView(Entity it) {
        var fields = getDisplayFields.exclude(ArrayField).exclude(ObjectField)
        fields.toList as List<DerivedField>
    }

    /**
     * Returns a list of all fields which should be displayed.
     */
    def getDisplayFields(Entity it) {
        var fields = getDerivedFields
        if (it.identifierStrategy != EntityIdentifierStrategy.NONE) {
            fields = fields.filter[!primaryKey]
        }
        if (!hasVisibleWorkflow) {
            fields = fields.filter[name != 'workflowState']
        }
        fields
    }

    /**
     * Returns a list of all editable fields of the given entity.
     * At the moment instances of ArrayField and ObjectField are excluded.
     */
    def getEditableFields(Entity it) {
        var fields = getDerivedFields.filter[name != 'workflowState']
        if (it.identifierStrategy != EntityIdentifierStrategy.NONE) {
            fields = fields.filter[!primaryKey]
        }
        val wantedFields = fields.exclude(ArrayField).exclude(ObjectField)
        wantedFields.toList as List<DerivedField>
    }

    /**
     * Returns a list of all fields of the given entity for which we provide example data.
     * At the moment instances of UploadField are excluded.
     */
    def getFieldsForExampleData(Entity it) {
        val exampleFields = getDerivedFields.filter[!primaryKey].exclude(UploadField)
        exampleFields.toList as List<DerivedField>
    }

    /**
     * Checks whether this entity has at least one user field.
     */
    def hasUserFieldsEntity(Entity it) {
        !getUserFieldsEntity.empty
    }

    /**
     * Returns a list of all user fields of this entity.
     */
    def getUserFieldsEntity(Entity it) {
        fields.filter(UserField)
    }

    /**
     * Checks whether this entity has at least one upload field.
     */
    def hasUploadFieldsEntity(Entity it) {
        !getUploadFieldsEntity.empty
    }

    /**
     * Returns a list of all upload fields of this entity.
     */
    def getUploadFieldsEntity(Entity it) {
        fields.filter(UploadField)
    }

    /**
     * Checks whether this entity has at least one list field.
     */
    def hasListFieldsEntity(Entity it) {
        !getListFieldsEntity.empty
    }

    /**
     * Returns a list of all list fields of this entity.
     */
    def getListFieldsEntity(Entity it) {
        fields.filter(ListField)
    }

    /**
     * Returns a list of all default items of this list.
     */
    def getDefaultItems(ListField it) {
        items.filter[^default]
    }

    /**
     * Returns a list of all default items of this list.
     */
    def getDefaultItems(ListVar it) {
        items.filter[^default]
    }

    /**
     * Checks whether this entity has at least one image field.
     */
    def hasImageFieldsEntity(Entity it) {
        !getImageFieldsEntity.empty
    }

    /**
     * Returns a list of all image fields of this entity.
     */
    def getImageFieldsEntity(Entity it) {
        getUploadFieldsEntity.filter[allowedExtensions.split(', ').forall[it == 'gif' || it == 'jpeg' || it == 'jpg' || it == 'png']]
    }

    /**
     * Checks whether this entity has at least one colour field.
     */
    def hasColourFieldsEntity(Entity it) {
        !getColourFieldsEntity.empty
    }

    /**
     * Returns a list of all colour fields of this entity.
     */
    def getColourFieldsEntity(Entity it) {
        getDerivedFields.filter(StringField).filter[htmlcolour]
    }

    /**
     * Checks whether this entity has at least one country field.
     */
    def hasCountryFieldsEntity(Entity it) {
        !getCountryFieldsEntity.empty
    }

    /**
     * Returns a list of all country fields of this entity.
     */
    def getCountryFieldsEntity(Entity it) {
        getDerivedFields.filter(StringField).filter[country]
    }

    /**
     * Checks whether this entity has at least one language field.
     */
    def hasLanguageFieldsEntity(Entity it) {
        !getLanguageFieldsEntity.empty
    }

    /**
     * Returns a list of all language fields of this entity.
     */
    def getLanguageFieldsEntity(Entity it) {
        getDerivedFields.filter(StringField).filter[language]
    }

    /**
     * Checks whether this entity has at least one locale field.
     */
    def hasLocaleFieldsEntity(Entity it) {
        !getLocaleFieldsEntity.empty
    }

    /**
     * Returns a list of all locale fields of this entity.
     */
    def getLocaleFieldsEntity(Entity it) {
        getDerivedFields.filter(StringField).filter[locale]
    }

    /**
     * Checks whether this entity has at least one textual field.
     */
    def hasAbstractStringFieldsEntity(Entity it) {
        !getAbstractStringFieldsEntity.empty
    }

    /**
     * Returns a list of all textual fields of this entity.
     */
    def getAbstractStringFieldsEntity(Entity it) {
        getDerivedFields.filter(AbstractStringField)
    }

    /**
     * Checks whether this entity has at least one string field.
     */
    def hasStringFieldsEntity(Entity it) {
        !getStringFieldsEntity.empty
    }

    /**
     * Returns a list of all string fields of this entity.
     */
    def getStringFieldsEntity(Entity it) {
        getDerivedFields.filter(StringField)
    }

    /**
     * Checks whether this entity has at least one text field.
     */
    def hasTextFieldsEntity(Entity it) {
        !getTextFieldsEntity.empty
    }

    /**
     * Returns a list of all text fields of this entity.
     */
    def getTextFieldsEntity(Entity it) {
        getDerivedFields.filter(TextField)
    }


    /**
     * Returns a list of all boolean fields of this entity.
     */
    def getBooleanFieldsEntity(Entity it) {
        fields.filter(BooleanField)
    }

    /**
     * Checks whether this entity has at least one boolean field.
     */
    def hasBooleanFieldsEntity(Entity it) {
        !getBooleanFieldsEntity.empty
    }

    /**
     * Checks whether this entity has at least one boolean field having ajax toggle enabled.
     */
    def hasBooleansWithAjaxToggleEntity(Entity it) {
        !getBooleansWithAjaxToggleEntity.empty
    }

    /**
     * Returns a list of all boolean fields having ajax toggle enabled.
     */
    def getBooleansWithAjaxToggleEntity(Entity it) {
        getBooleanFieldsEntity.filter[ajaxTogglability]
    }

    /**
     * Returns a list of all integer fields which are used as aggregates.
     */
    def getAggregateFields(Entity it) {
        fields.filter(IntegerField).filter[aggregateFor !== null && aggregateFor != '']
    }

    /**
     * Returns the subfolder path segment for this upload field,
     * that is either the subFolderName attribute (if set) or the name otherwise.
     */
    def subFolderPathSegment(UploadField it) {
        (if (subFolderName !== null && subFolderName != '') subFolderName else name).formatForDB
    }

    /**
     * Prints an output string corresponding to the given entity lock type.
     */
    def lockTypeAsConstant(EntityLockType lockType) {
        switch lockType {
            case NONE                       : ''
            case OPTIMISTIC                 : 'OPTIMISTIC'
            case PESSIMISTIC_READ           : 'PESSIMISTIC_READ'
            case PESSIMISTIC_WRITE          : 'PESSIMISTIC_WRITE'
            case PAGELOCK                   : ''
            case PAGELOCK_OPTIMISTIC        : 'OPTIMISTIC'
            case PAGELOCK_PESSIMISTIC_READ  : 'PESSIMISTIC_READ'
            case PAGELOCK_PESSIMISTIC_WRITE : 'PESSIMISTIC_WRITE'
            default: ''
        }
    }

    def hasNotifyPolicy(Entity it) {
        (changeTrackingPolicy == EntityChangeTrackingPolicy.NOTIFY)
    }

    def hasOptimisticLock(Entity it) {
        (lockType == EntityLockType.OPTIMISTIC || lockType == EntityLockType.PAGELOCK_OPTIMISTIC)
    }
    def hasPessimisticReadLock(Entity it) {
        (lockType == EntityLockType.PESSIMISTIC_READ || lockType == EntityLockType.PAGELOCK_PESSIMISTIC_READ)
    }
    def hasPessimisticWriteLock(Entity it) {
        (lockType == EntityLockType.PESSIMISTIC_WRITE || lockType == EntityLockType.PAGELOCK_PESSIMISTIC_WRITE)
    }
    def hasPageLockSupport(Entity it) {
        (lockType == EntityLockType.PAGELOCK || lockType == EntityLockType.PAGELOCK_OPTIMISTIC
         || lockType == EntityLockType.PAGELOCK_PESSIMISTIC_READ || lockType == EntityLockType.PAGELOCK_PESSIMISTIC_WRITE)
    }

    def getVersionField(Entity it) {
        val intVersions = fields.filter(IntegerField).filter[version]
        if (!intVersions.empty)
            intVersions.head
        else {
            val datetimeVersions = fields.filter(DatetimeField).filter[version]
            if (!datetimeVersions.empty)
                datetimeVersions.head
        }
    }


    def isDefaultIdField(DerivedField it) {
        isDefaultIdFieldName(entity, name.formatForDB)
    }

    def isDefaultIdFieldName(Entity it, String s) {
        newArrayList('id', name.formatForDB + 'id', name.formatForDB + '_id').contains(s)
    }

    def boolean containsDefaultIdField(Iterable<String> l, Entity entity) {
        isDefaultIdFieldName(entity, l.head) || (l.size > 1 && containsDefaultIdField(l.tail, entity))
    }

    def getStartDateField(Entity it) {
        val datetimeFields = fields.filter(DatetimeField).filter[startDate]
        if (!datetimeFields.empty)
            datetimeFields.head
        else {
            val dateFields = fields.filter(DateField).filter[startDate]
            if (!dateFields.empty)
                dateFields.head
        }
    }

    def getEndDateField(Entity it) {
        val datetimeFields = fields.filter(DatetimeField).filter[endDate]
        if (!datetimeFields.empty)
            datetimeFields.head
        else {
            val dateFields = fields.filter(DateField).filter[endDate]
            if (!dateFields.empty)
                dateFields.head
        }
    }

    /**
     * Prints an output string corresponding to the given entity lock type.
     */
    def ipScopeAsConstant(IpAddressScope scope) {
        switch scope {
            case NONE           : ''
            case IP4            : '4'
            case IP6            : '6'
            case ALL            : 'all'
            case IP4_NO_PRIV    : '4_no_priv'
            case IP6_NO_PRIV    : '6_no_priv'
            case ALL_NO_PRIV    : 'all_no_priv'
            case IP4_NO_RES     : '4_no_res'
            case IP6_NO_RES     : '6_no_res'
            case ALL_NO_RES     : 'all_no_res'
            case IP4_PUBLIC     : '4_public'
            case IP6_PUBLIC     : '6_public'
            case ALL_PUBLIC     : 'all_public'
            default: ''
        }
    }



    /**
     * Prints an output string describing the type of the given derived field.
     */
    def fieldTypeAsString(DerivedField it) {
        switch it {
            BooleanField: 'boolean'
            AbstractIntegerField: {
                    // choose mapping type depending on length
                    // a SMALLINT ranges up to 32767 and is therefore not appropriate for 5 digits
                    // an INT ranges up to 2147483647 and is therefore good for up to 9 digits
                    // maximal length of 18 is enforced in model validation
                    if (it.length < 5) 'smallint'
                    else if (it.length < 10) 'integer'
                    else 'bigint'
            }
            DecimalField: 'decimal'
            StringField: 'string'
            TextField: 'text'
            EmailField: 'string'
            UrlField: 'string'
            UploadField: 'string'
            ListField: 'string'
            ArrayField: 'array'
            ObjectField: 'object'
            DatetimeField: 'DateTime'
            DateField: 'date'
            TimeField: 'time'
            FloatField: 'float'
            default: ''
        }
    }
}
