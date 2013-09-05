package org.zikula.modulestudio.generator.extensions

import com.google.inject.Inject
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
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ListVar
import de.guite.modulestudio.metamodel.modulestudio.Models
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UploadNamingScheme
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import java.util.List

/**
 * This class contains model related extension methods.
 * TODO document class and methods.
 */
class ModelExtensions {
    @Inject extension CollectionUtils = new CollectionUtils()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions()
    @Inject extension Utils = new Utils()
    @Inject extension WorkflowExtensions = new WorkflowExtensions()

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
        getAllEntities.map(e|e.fields).flatten.toList
    }

    /**
     * Returns a list of all entity fields in a certain model container.
     */
    def getModelEntityFields(Models it) {
        entities.map(e|e.fields).flatten.toList
    }

    /**
     * Returns the leading entity in the primary model container.
     */
    def getLeadingEntity(Application it) {
        getEntitiesFromDefaultDataSource.findFirst(e|e.leading)
    }

    /**
     * Checks whether the application contains at least one entity with at least one image field.
     */
    def hasImageFields(Application it) {
        getAllEntities.exists(e|e.hasImageFieldsEntity)
    }

    /**
     * Checks whether the application contains at least one entity with at least one colour field.
     */
    def hasColourFields(Application it) {
        getAllEntities.exists(e|e.hasColourFieldsEntity)
    }

    /**
     * Checks whether the application contains at least one entity with at least one country field.
     */
    def hasCountryFields(Application it) {
        getAllEntities.exists(e|e.hasCountryFieldsEntity)
    }

    /**
     * Checks whether the application contains at least one entity with at least one upload field.
     */
    def hasUploads(Application it) {
        !getUploadEntities.isEmpty
    }

    /**
     * Returns a list of all entities with at least one upload field.
     */
    def getUploadEntities(Application it) {
        getAllEntities.filter(e|e.hasUploadFieldsEntity)
    }

    /**
     * Returns a list of all user fields in this application.
     */
    def getAllUserFields(Application it) {
        getAllEntityFields.filter(typeof(UserField))
    }

    /**
     * Checks whether the application contains at least one user field.
     */
    def boolean hasUserFields(Application it) {
        !getAllUserFields.isEmpty
    }

    /**
     * Returns a list of all list fields in this application.
     */
    def getAllListFields(Application it) {
        getAllEntityFields.filter(typeof(ListField))
    }

    /**
     * Checks whether the application contains at least one list field.
     */
    def hasListFields(Application it) {
        !getAllListFields.isEmpty
    }

    /**
     * Returns a list of all entities with at least one list field.
     */
    def getListEntities(Application it) {
        getAllEntities.filter(e|e.hasListFieldsEntity)
    }


    /**
     * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled.
     */
    def hasBooleansWithAjaxToggle(Application it) {
        !getEntitiesWithAjaxToggle.isEmpty
    }

    /**
     * Returns a list of all entities with at least one boolean field having ajax toggle enabled.
     */
    def getEntitiesWithAjaxToggle(Application it) {
        getAllEntities.filter(e|e.hasBooleansWithAjaxToggleEntity)
    }

    /**
     * Returns the first model container which is default data source.
     */
    def getDefaultDataSource(Application it) {
        models.findFirst(e|e.defaultDataSource == true)
    }

    /**
     * Prepends the application database prefix to a given string.
     * Beginning with Zikula 1.3.6 the vendor is prefixed, too.
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
        !getNormalIndexes.isEmpty
    }

    /**
     * Returns a list of all normal (non-unique) indexes for this entity.
     */
    def getNormalIndexes(Entity it) {
        indexes.filter(e|e.type == EntityIndexType::NORMAL)
    }

    /**
     * Checks whether this entity has at least one unique index.
     */
    def hasUniqueIndexes(Entity it) {
        !getUniqueIndexes.isEmpty
    }

    /**
     * Returns a list of all unique indexes for this entity.
     */
    def getUniqueIndexes(Entity it) {
        indexes.filter(e|e.type == EntityIndexType::UNIQUE)
    }

    /**
     * Returns a list of all derived fields (excluding calculated fields) of the given entity.
     */
    def getDerivedFields(Entity it) {
        fields.filter(typeof(DerivedField))
    }

    /**
     * Returns a list of all derived and unique fields of the given entity
     */
    def getUniqueDerivedFields(Entity it) {
        getDerivedFields.filter(e|e.unique)
    }

    /**
     * Returns the field having leading = true of this entity.
     */
    def DerivedField getLeadingField(Entity it) {
        if (!getDerivedFields.isEmpty)
            getDerivedFields.findFirst(e|e.leading == true)
        else if (isInheriting)
            parentType.getLeadingField
    }

    /**
     * Returns a list of all derived and primary key fields of the given entity.
     */
    def getPrimaryKeyFields(Entity it) {
        getDerivedFields.filter(e|e.primaryKey == true)
    }

    /**
     * Returns the first derived and primary key field of the given entity.
     */
    def getFirstPrimaryKey(Entity it) {
        getDerivedFields.findFirst(e|e.primaryKey == true)
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
        var fields = getDisplayFields.exclude(typeof(ArrayField)).exclude(typeof(ObjectField))
        fields.toList as List<DerivedField>
    }

    /**
     * Returns a list of all fields which should be displayed.
     */
    def getDisplayFields(Entity it) {
        var fields = getDerivedFields
        if (it.identifierStrategy != EntityIdentifierStrategy::NONE) {
            fields = fields.filter(e|!e.primaryKey)
        }
        if (!hasVisibleWorkflow) {
            fields = fields.filter(e|e.name != 'workflowState')
        }
        fields
    }

    /**
     * Returns a list of all fields which should be displayed.
     */
    def getLeadingDisplayFields(Entity it) {
        var fields = getDisplayFields.filter(e|e.name != 'workflowState')
        if (leadingField !== null && leadingField.showLeadingFieldInTitle) {
            fields = fields.filter(e|!e.leading)
        }
        fields
    }

    def showLeadingFieldInTitle(DerivedField it) {
        switch it {
            IntegerField: true
            StringField: true
            TextField: true
            default: false
        }
    }

    /**
     * Returns a list of all editable fields of the given entity.
     * At the moment instances of ArrayField and ObjectField are excluded.
     */
    def getEditableFields(Entity it) {
        var fields = getDerivedFields.filter(e|e.name != 'workflowState')
        if (it.identifierStrategy != EntityIdentifierStrategy::NONE) {
            fields = fields.filter(e|!e.primaryKey)
        }
        val wantedFields = fields.exclude(typeof(ArrayField)).exclude(typeof(ObjectField))
        wantedFields.toList as List<DerivedField>
    }

    /**
     * Returns a list of all fields of the given entity for which we provide example data.
     * At the moment instances of UploadField are excluded.
     */
    def getFieldsForExampleData(Entity it) {
        val exampleFields = getDerivedFields.filter(e|!e.primaryKey).exclude(typeof(UploadField))
        exampleFields.toList as List<DerivedField>
    }

    /**
     * Checks whether this entity has at least one user field.
     */
    def hasUserFieldsEntity(Entity it) {
        !getUserFieldsEntity.isEmpty;
    }

    /**
     * Returns a list of all user fields of this entity.
     */
    def getUserFieldsEntity(Entity it) {
        fields.filter(typeof(UserField))
    }

    /**
     * Checks whether this entity has at least one upload field.
     */
    def hasUploadFieldsEntity(Entity it) {
        !getUploadFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all upload fields of this entity.
     */
    def getUploadFieldsEntity(Entity it) {
        fields.filter(typeof(UploadField))
    }

    /**
     * Checks whether this entity has at least one list field.
     */
    def hasListFieldsEntity(Entity it) {
        !getListFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all list fields of this entity.
     */
    def getListFieldsEntity(Entity it) {
        fields.filter(typeof(ListField))
    }

    /**
     * Returns a list of all default items of this list.
     */
    def getDefaultItems(ListField it) {
        items.filter(e|e.^default)
    }

    /**
     * Returns a list of all default items of this list.
     */
    def getDefaultItems(ListVar it) {
        items.filter(e|e.^default)
    }

    /**
     * Checks whether this entity has at least one image field.
     */
    def hasImageFieldsEntity(Entity it) {
        !getImageFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all image fields of this entity.
     */
    def getImageFieldsEntity(Entity it) {
        getUploadFieldsEntity.filter(e|e.allowedExtensions.split(", ").forall(ext|ext == 'gif' || ext == 'jpeg' || ext == 'jpg' || ext == 'png'))
    }

    /**
     * Checks whether this entity has at least one colour field.
     */
    def hasColourFieldsEntity(Entity it) {
        !getColourFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all colour fields of this entity.
     */
    def getColourFieldsEntity(Entity it) {
        getDerivedFields.filter(typeof(StringField)).filter(e|e.htmlcolour)
    }

    /**
     * Checks whether this entity has at least one country field.
     */
    def hasCountryFieldsEntity(Entity it) {
        !getCountryFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all country fields of this entity.
     */
    def getCountryFieldsEntity(Entity it) {
        getDerivedFields.filter(typeof(StringField)).filter(e|e.country == true)
    }

    /**
     * Checks whether this entity has at least one language field.
     */
    def hasLanguageFieldsEntity(Entity it) {
        !getLanguageFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all language fields of this entity.
     */
    def getLanguageFieldsEntity(Entity it) {
        getDerivedFields.filter(typeof(StringField)).filter(e|e.language == true)
    }

    /**
     * Checks whether this entity has at least one textual field.
     */
    def hasAbstractStringFieldsEntity(Entity it) {
        !getAbstractStringFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all textual fields of this entity.
     */
    def getAbstractStringFieldsEntity(Entity it) {
        getDerivedFields.filter(typeof(AbstractStringField))
    }

    /**
     * Checks whether this entity has at least one string field.
     */
    def hasStringFieldsEntity(Entity it) {
        !getStringFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all string fields of this entity.
     */
    def getStringFieldsEntity(Entity it) {
        getDerivedFields.filter(typeof(StringField))
    }

    /**
     * Checks whether this entity has at least one text field.
     */
    def hasTextFieldsEntity(Entity it) {
        !getTextFieldsEntity.isEmpty
    }

    /**
     * Returns a list of all text fields of this entity.
     */
    def getTextFieldsEntity(Entity it) {
        getDerivedFields.filter(typeof(TextField))
    }


    /**
     * Returns a list of all boolean fields of this entity.
     */
    def getBooleanFieldsEntity(Entity it) {
        fields.filter(typeof(BooleanField))
    }

    /**
     * Checks whether this entity has at least one boolean field.
     */
    def hasBooleanFieldsEntity(Entity it) {
        !getBooleanFieldsEntity.isEmpty
    }

    /**
     * Checks whether this entity has at least one boolean field having ajax toggle enabled.
     */
    def hasBooleansWithAjaxToggleEntity(Entity it) {
        !getBooleansWithAjaxToggleEntity.isEmpty
    }

    /**
     * Returns a list of all boolean fields having ajax toggle enabled.
     */
    def getBooleansWithAjaxToggleEntity(Entity it) {
        getBooleanFieldsEntity.filter(e|e.ajaxTogglability)
    }

    /**
     * Returns a list of all integer fields which are used as aggregates.
     */
    def getAggregateFields(Entity it) {
        fields.filter(typeof(IntegerField)).filter(e|e.aggregateFor !== null && e.aggregateFor != '')
    }

    /**
     * Returns the subfolder path segment for this upload field,
     * that is either the subFolderName attribute (if set) or the name otherwise.
     */
    def subFolderPathSegment(UploadField it) {
        (if (subFolderName !== null && subFolderName != '') subFolderName else name).formatForDB
    }

    /**
     * Prints an output number corresponding to the given upload naming scheme.
     */
    def namingSchemeAsInt(UploadField it) {
        switch (namingScheme) {
            case UploadNamingScheme::ORIGINALWITHCOUNTER    : '0'
            case UploadNamingScheme::RANDOMCHECKSUM         : '1'
            case UploadNamingScheme::FIELDNAMEWITHCOUNTER   : '2'
            default: '0'
        }
    }

    /**
     * Prints an output string corresponding to the given identifier strategy.
     */
    def asConstant(EntityIdentifierStrategy strategy) {
        switch (strategy) {
            case EntityIdentifierStrategy::NONE                     : ''
            case EntityIdentifierStrategy::AUTO                     : 'AUTO'
            case EntityIdentifierStrategy::SEQUENCE                 : 'SEQUENCE'
            case EntityIdentifierStrategy::TABLE                    : 'TABLE'
            case EntityIdentifierStrategy::IDENTITY                 : 'IDENTITY'
            case EntityIdentifierStrategy::UUID                     : 'UUID'
            case EntityIdentifierStrategy::CUSTOM                   : 'CUSTOM'
            default: ''
        }
    }

    /**
     * Prints an output string corresponding to the given change tracking policy.
     */
    def asConstant(EntityChangeTrackingPolicy policy) {
        switch (policy) {
            case EntityChangeTrackingPolicy::DEFERRED_IMPLICIT      : 'DEFERRED_IMPLICIT'
            case EntityChangeTrackingPolicy::DEFERRED_EXPLICIT      : 'DEFERRED_EXPLICIT'
            case EntityChangeTrackingPolicy::NOTIFY                 : 'NOTIFY'
            default: 'DEFERRED_IMPLICIT'
        }
    }

    /**
     * Prints an output string corresponding to the given entity lock type.
     */
    def asConstant(EntityLockType lockType) {
        switch (lockType) {
            case EntityLockType::NONE                       : ''
            case EntityLockType::OPTIMISTIC                 : 'OPTIMISTIC'
            case EntityLockType::PESSIMISTIC_READ           : 'PESSIMISTIC_READ'
            case EntityLockType::PESSIMISTIC_WRITE          : 'PESSIMISTIC_WRITE'
            case EntityLockType::PAGELOCK                   : ''
            case EntityLockType::PAGELOCK_OPTIMISTIC        : 'OPTIMISTIC'
            case EntityLockType::PAGELOCK_PESSIMISTIC_READ  : 'PESSIMISTIC_READ'
            case EntityLockType::PAGELOCK_PESSIMISTIC_WRITE : 'PESSIMISTIC_WRITE'
            default: ''
        }
    }

    def hasNotifyPolicy(Entity it) {
        (changeTrackingPolicy == EntityChangeTrackingPolicy::NOTIFY)
    }

    def hasOptimisticLock(Entity it) {
        (lockType == EntityLockType::OPTIMISTIC || lockType == EntityLockType::PAGELOCK_OPTIMISTIC)
    }
    def hasPessimisticReadLock(Entity it) {
        (lockType == EntityLockType::PESSIMISTIC_READ || lockType == EntityLockType::PAGELOCK_PESSIMISTIC_READ)
    }
    def hasPessimisticWriteLock(Entity it) {
        (lockType == EntityLockType::PESSIMISTIC_WRITE || lockType == EntityLockType::PAGELOCK_PESSIMISTIC_WRITE)
    }
    def hasPageLockSupport(Entity it) {
        (lockType == EntityLockType::PAGELOCK || lockType == EntityLockType::PAGELOCK_OPTIMISTIC
         || lockType == EntityLockType::PAGELOCK_PESSIMISTIC_READ || lockType == EntityLockType::PAGELOCK_PESSIMISTIC_WRITE)
    }

    def getVersionField(Entity it) {
        val intVersions = fields.filter(typeof(IntegerField)).filter(e|e.version)
        if (!intVersions.isEmpty)
            intVersions.head
        else {
            val datetimeVersions = fields.filter(typeof(DatetimeField)).filter(e|e.version)
            if (!datetimeVersions.isEmpty)
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
        isDefaultIdFieldName(entity, l.head) || (l.size > 1 && containsDefaultIdField(l.tail, entity));
    }

    def getStartDateField(Entity it) {
        val datetimeFields = fields.filter(typeof(DatetimeField)).filter(e|e.startDate)
        if (!datetimeFields.isEmpty)
            datetimeFields.head
        else {
            val dateFields = fields.filter(typeof(DateField)).filter(e|e.startDate)
            if (!dateFields.isEmpty)
                dateFields.head
        }
    }

    def getEndDateField(Entity it) {
        val datetimeFields = fields.filter(typeof(DatetimeField)).filter(e|e.endDate)
        if (!datetimeFields.isEmpty)
            datetimeFields.head
        else {
            val dateFields = fields.filter(typeof(DateField)).filter(e|e.endDate)
            if (!dateFields.isEmpty)
                dateFields.head
        }
    }



    /**
     * Prints an output string describing the type of the given derived field.
     */
    def fieldTypeAsString(DerivedField it) {
        switch (it) {
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
