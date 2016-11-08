package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.EntityIdentifierStrategy
import de.guite.modulestudio.metamodel.EntityIndexType
import de.guite.modulestudio.metamodel.EntityLockType
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.InheritanceRelationship
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.IpAddressScope
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListVar
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import java.util.List

/**
 * This class contains model related extension methods.
 */
class ModelExtensions {
    extension CollectionUtils = new CollectionUtils
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    /**
     * Returns a list of all entity fields in this application.
     */
    def getAllEntityFields(Application it) {
        entities.map[fields].flatten.toList
    }

    /**
     * Returns a list of all entities (data objects except mapped super classes).
     */
    def getAllEntities(Application it) {
        entities.filter(Entity)
    }

    /**
     * Returns the leading entity in the primary model container.
     */
    def getLeadingEntity(Application it) {
        getAllEntities.findFirst[leading]
    }

    /**
     * Checks whether the application contains at least one entity with hook subscriber capability.
     */
    def hasHookSubscribers(Application it) {
        !getAllEntities.filter[e|!e.skipHookSubscribers].empty
    }

    /**
     * Checks whether the application contains at least one entity with at least one image field.
     */
    def hasImageFields(Application it) {
        entities.exists[hasImageFieldsEntity]
    }

    /**
     * Checks whether the application contains at least one entity with at least one colour field.
     */
    def hasColourFields(Application it) {
        entities.exists[hasColourFieldsEntity]
    }

    /**
     * Checks whether the application contains at least one entity with at least one country field.
     */
    def hasCountryFields(Application it) {
        entities.exists[hasCountryFieldsEntity]
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
        entities.filter[hasUploadFieldsEntity]
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
     * Checks whether the application contains at least one list field with multi selection.
     */
    def hasMultiListFields(Application it) {
        !getAllListFields.filter[l|l.multiple].empty
    }

    /**
     * Returns a list of all entities with at least one list field.
     */
    def getListEntities(Application it) {
        entities.filter[hasListFieldsEntity]
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
        entities.filter[hasBooleansWithAjaxToggleEntity]
    }

    /**
     * Prepends the application database prefix to a given string.
     * Beginning with Zikula 1.4.0 the vendor is prefixed, too.
     */
    def tableNameWithPrefix(Application it, String inputString) {
        if (targets('1.3.x')) {
            prefix + '_' + inputString
        } else {
            vendor.formatForDB + '_' + prefix() + '_' + inputString
        }
    }

    /**
     * Returns the full table name for a given entity instance.
     */
    def fullEntityTableName(DataObject it) {
        tableNameWithPrefix(application, name.formatForDB)
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
    def getDerivedFields(DataObject it) {
        fields.filter(DerivedField)
    }

    /**
     * Returns a list of all derived and unique fields of the given entity
     */
    def getUniqueDerivedFields(DataObject it) {
        getDerivedFields.filter[unique]
    }

    /**
     * Returns a list of all derived and primary key fields of the given entity.
     */
    def getPrimaryKeyFields(DataObject it) {
        getDerivedFields.filter[primaryKey]
    }

    /**
     * Returns the first derived and primary key field of the given entity.
     */
    def getFirstPrimaryKey(DataObject it) {
        getDerivedFields.findFirst[primaryKey]
    }

    /**
     * Checks whether the entity has more than one primary key fields.
     */
    def hasCompositeKeys(DataObject it) {
        getPrimaryKeyFields.size > 1
    }

    /**
     * Concatenates all id strings using underscore as delimiter.
     * Used for generating some controller classes. 
     */
    def idFieldsAsParameterCode(DataObject it, String objVar) '''«IF hasCompositeKeys»«FOR pkField : getPrimaryKeyFields SEPARATOR ' . \'_\' . '»$«objVar»['«pkField.name.formatForCode»']«ENDFOR»«ELSE»$«objVar»['«getFirstPrimaryKey.name.formatForCode»']«ENDIF»'''

    /**
     * Concatenates all id strings using underscore as delimiter.
     * Used for generating some view templates. 
     */
    def idFieldsAsParameterTemplate(DataObject it) '''«IF application.targets('1.3.x')»«FOR pkField : getPrimaryKeyFields SEPARATOR '_'»`$«name.formatForCode».«pkField.name.formatForCode»`«ENDFOR»«ELSE»«FOR pkField : getPrimaryKeyFields SEPARATOR ' ~ \'_\' ~ '»«name.formatForCode».«pkField.name.formatForCode»«ENDFOR»«ENDIF»'''

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
    def getEditableFields(DataObject it) {
        var fields = getDerivedFields.filter[name != 'workflowState']
        if (it instanceof Entity && (it as Entity).identifierStrategy != EntityIdentifierStrategy.NONE) {
            fields = fields.filter[!primaryKey]
        }
        val wantedFields = fields.exclude(ArrayField).exclude(ObjectField)
        wantedFields.toList as List<DerivedField>
    }

    /**
     * Returns a list of all fields of the given entity for which we provide example data.
     * At the moment instances of UploadField are excluded.
     */
    def getFieldsForExampleData(DataObject it) {
        val exampleFields = getDerivedFields.filter[!primaryKey].exclude(UploadField)
        exampleFields.toList as List<DerivedField>
    }

    /**
     * Checks whether this entity has at least one user field.
     */
    def hasUserFieldsEntity(DataObject it) {
        !getUserFieldsEntity.empty
    }

    /**
     * Returns a list of all user fields of this entity.
     */
    def getUserFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(UserField)].flatten
    }

    /**
     * Checks whether this entity has at least one upload field.
     */
    def hasUploadFieldsEntity(DataObject it) {
        !getUploadFieldsEntity.empty
    }

    /**
     * Returns a list of all upload fields of this entity.
     */
    def getUploadFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(UploadField)].flatten
    }

    /**
     * Checks whether this entity has at least one list field.
     */
    def hasListFieldsEntity(DataObject it) {
        !getListFieldsEntity.empty
    }

    /**
     * Returns a list of all list fields of this entity.
     */
    def getListFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(ListField)].flatten
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
        getParentDataObjects(#[]) + #[it]
    }

    /**
     * Checks whether this entity has at least one image field.
     */
    def hasImageFieldsEntity(DataObject it) {
        !getImageFieldsEntity.empty
    }

    /**
     * Returns a list of all image fields of this entity.
     */
    def getImageFieldsEntity(DataObject it) {
        getUploadFieldsEntity.filter[isImageField]
    }

    /**
     * Checks whether an upload field is an image field.
     */
    def isImageField(UploadField it) {
        allowedExtensions.split(', ').forall[it == 'gif' || it == 'jpeg' || it == 'jpg' || it == 'png']
    }

    /**
     * Checks whether this entity has at least one colour field.
     */
    def hasColourFieldsEntity(DataObject it) {
        !getColourFieldsEntity.empty
    }

    /**
     * Returns a list of all colour fields of this entity.
     */
    def getColourFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[htmlcolour]].flatten
    }

    /**
     * Checks whether this entity has at least one country field.
     */
    def hasCountryFieldsEntity(DataObject it) {
        !getCountryFieldsEntity.empty
    }

    /**
     * Returns a list of all country fields of this entity.
     */
    def getCountryFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[country]].flatten
    }

    /**
     * Checks whether this entity has at least one language field.
     */
    def hasLanguageFieldsEntity(DataObject it) {
        !getLanguageFieldsEntity.empty
    }

    /**
     * Returns a list of all language fields of this entity.
     */
    def getLanguageFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[language]].flatten
    }

    /**
     * Checks whether this entity has at least one locale field.
     */
    def hasLocaleFieldsEntity(DataObject it) {
        !getLocaleFieldsEntity.empty
    }

    /**
     * Returns a list of all locale fields of this entity.
     */
    def getLocaleFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[locale]].flatten
    }

    /**
     * Checks whether this entity has at least one time zone field.
     */
    def hasTimezoneFieldsEntity(DataObject it) {
        !getTimezoneFieldsEntity.empty
    }

    /**
     * Returns a list of all time zone fields of this entity.
     */
    def getTimezoneFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[timezone]].flatten
    }

    /**
     * Checks whether this entity has at least one currency field.
     */
    def hasCurrencyFieldsEntity(DataObject it) {
        !getCurrencyFieldsEntity.empty
    }

    /**
     * Returns a list of all currency fields of this entity.
     */
    def getCurrencyFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[currency]].flatten
    }

    /**
     * Checks whether this entity has at least one textual field.
     */
    def hasAbstractStringFieldsEntity(DataObject it) {
        !getAbstractStringFieldsEntity.empty
    }

    /**
     * Returns a list of all textual fields of this entity.
     */
    def getAbstractStringFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(AbstractStringField)].flatten
    }

    /**
     * Checks whether this entity has at least one string field.
     */
    def hasStringFieldsEntity(DataObject it) {
        !getStringFieldsEntity.empty
    }

    /**
     * Returns a list of all string fields of this entity.
     */
    def getStringFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField)].flatten
    }

    /**
     * Checks whether this entity has at least one text field.
     */
    def hasTextFieldsEntity(DataObject it) {
        !getTextFieldsEntity.empty
    }

    /**
     * Returns a list of all text fields of this entity.
     */
    def getTextFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(TextField)].flatten
    }

    /**
     * Checks whether this entity has at least one boolean field.
     */
    def hasBooleanFieldsEntity(DataObject it) {
        !getBooleanFieldsEntity.empty
    }

    /**
     * Returns a list of all boolean fields of this entity.
     */
    def getBooleanFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(BooleanField)].flatten
    }

    /**
     * Checks whether this entity has at least one boolean field having ajax toggle enabled.
     */
    def hasBooleansWithAjaxToggleEntity(DataObject it) {
        !getBooleansWithAjaxToggleEntity.empty
    }

    /**
     * Returns a list of all boolean fields having ajax toggle enabled.
     */
    def getBooleansWithAjaxToggleEntity(DataObject it) {
        getBooleanFieldsEntity.filter[ajaxTogglability]
    }

    /**
     * Returns a list of all integer fields which are used as aggregates.
     */
    def getAggregateFields(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(IntegerField).filter[null !== aggregateFor && aggregateFor != '']].flatten
    }

    /**
     * Returns the sub folder path segment for this upload field,
     * that is either the subFolderName attribute (if set) or the name otherwise.
     */
    def subFolderPathSegment(UploadField it) {
        (if (null !== subFolderName && subFolderName != '') subFolderName else name).formatForDB
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

    /**
     * Checks whether this entity has enabled the notify tracking policy.
     */
    def hasNotifyPolicy(Entity it) {
        (changeTrackingPolicy == EntityChangeTrackingPolicy.NOTIFY)
    }

    /**
     * Checks whether this entity has enabled optimistic locking.
     */
    def hasOptimisticLock(Entity it) {
        (lockType == EntityLockType.OPTIMISTIC || lockType == EntityLockType.PAGELOCK_OPTIMISTIC)
    }
    /**
     * Checks whether this entity has enabled pessimistic read locking.
     */
    def hasPessimisticReadLock(Entity it) {
        (lockType == EntityLockType.PESSIMISTIC_READ || lockType == EntityLockType.PAGELOCK_PESSIMISTIC_READ)
    }
    /**
     * Checks whether this entity has enabled pessimistic write locking.
     */
    def hasPessimisticWriteLock(Entity it) {
        (lockType == EntityLockType.PESSIMISTIC_WRITE || lockType == EntityLockType.PAGELOCK_PESSIMISTIC_WRITE)
    }
    /**
     * Checks whether this entity has enabled support for the PageLock module.
     */
    def hasPageLockSupport(Entity it) {
        (lockType == EntityLockType.PAGELOCK || lockType == EntityLockType.PAGELOCK_OPTIMISTIC
         || lockType == EntityLockType.PAGELOCK_PESSIMISTIC_READ || lockType == EntityLockType.PAGELOCK_PESSIMISTIC_WRITE)
    }

    /**
     * Determines the version field of a data object if there is one.
     */
    def getVersionField(DataObject it) {
        val intVersions = getSelfAndParentDataObjects.map[fields.filter(IntegerField).filter[version]].flatten
        if (!intVersions.empty) {
            return intVersions.head
        }

        val datetimeVersions = getSelfAndParentDataObjects.map[fields.filter(DatetimeField).filter[version]].flatten
        if (!datetimeVersions.empty) {
            datetimeVersions.head
        }
    }

    /**
     * Checks whether the given field is a default (= no custom) identifier field.
     */
    def isDefaultIdField(DerivedField it) {
        isDefaultIdFieldName(entity, name.formatForDB)
    }

    /**
     * Checks whether the given string is the name of the default (= no custom) identifier field.
     */
    def isDefaultIdFieldName(DataObject it, String s) {
        newArrayList('id', name.formatForDB + 'id', name.formatForDB + '_id').contains(s)
    }

    /**
     * Checks whether the given list contains the name of a default (= no custom) identifier field.
     */
    def boolean containsDefaultIdField(Iterable<String> l, DataObject dataObject) {
        isDefaultIdFieldName(dataObject, l.head) || (l.size > 1 && containsDefaultIdField(l.tail, dataObject))
    }

    /**
     * Determines the start date field of a data object if there is one.
     */
    def getStartDateField(DataObject it) {
        val datetimeFields = getSelfAndParentDataObjects.map[fields.filter(DatetimeField).filter[startDate]].flatten
        if (!datetimeFields.empty) {
            return datetimeFields.head
        }

        val dateFields = getSelfAndParentDataObjects.map[fields.filter(DateField).filter[startDate]].flatten
        if (!dateFields.empty) {
            dateFields.head
        }
    }

    /**
     * Determines the end date field of a data object if there is one.
     */
    def getEndDateField(DataObject it) {
        val datetimeFields = getSelfAndParentDataObjects.map[fields.filter(DatetimeField).filter[endDate]].flatten
        if (!datetimeFields.empty) {
            return datetimeFields.head
        }

        val dateFields = getSelfAndParentDataObjects.map[fields.filter(DateField).filter[endDate]].flatten
        if (!dateFields.empty) {
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
                    if (it.length < 5) 'smallint'
                    else if (it.length < 12) 'integer'
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
