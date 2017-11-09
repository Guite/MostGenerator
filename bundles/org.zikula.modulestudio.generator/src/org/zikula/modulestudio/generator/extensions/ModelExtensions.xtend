package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DateTimeComponents
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.EntityIdentifierStrategy
import de.guite.modulestudio.metamodel.EntityIndexType
import de.guite.modulestudio.metamodel.EntityLockType
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.FieldDisplayType
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.HookProviderMode
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.IpAddressScope
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
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
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
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
     * Checks whether the application contains at least one entity with hook subscribers.
     */
    def hasHookSubscribers(Application it) {
        !getAllEntities.filter[e|!e.skipHookSubscribers].empty
    }

    /**
     * Checks whether the application supports any kind of hook provider.
     */
    def hasHookProviders(Application it) {
        hasFilterHookProvider || hasFormAwareHookProviders || hasUiHooksProviders
    }

    /**
     * Checks whether the application supports a filter hook provider.
     */
    def hasFilterHookProvider(Application it) {
        filterHookProvider != HookProviderMode.DISABLED
    }

    /**
     * Checks whether the application contains at least one entity with a form aware hook provider.
     */
    def hasFormAwareHookProviders(Application it) {
        !getAllEntities.filter[e|e.formAwareHookProvider != HookProviderMode.DISABLED].empty
    }

    /**
     * Checks whether the application contains at least one entity with a UI hooks provider.
     */
    def hasUiHooksProviders(Application it) {
        !getAllEntities.filter[e|e.uiHooksProvider != HookProviderMode.DISABLED].empty
    }

    /**
     * Returns the interface class for a given hook provider mode.
     */
    def providerInterface(HookProviderMode it) {
        if (it == HookProviderMode.ENABLED) {
            return 'HookProviderInterface'
        }
        if (it == HookProviderMode.ENABLED_SELF) {
            return 'HookSelfAllowedProviderInterface'
        }
        return ''
    }

    /**
     * Returns a hash map with supported hook types.
     */
    def getHookTypes(Application it) {
        newHashMap(
            'FilterHooks' -> 'FilterHooks',
            'FormAware' -> 'FormAwareHook',
            'UiHooks' -> 'UiHooks'
        )
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
        getAllEntities.exists[hasColourFieldsEntity] || !variables.map[fields].filter(StringField).filter[role == StringRole.COLOUR].empty
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
        !getUploadEntities.empty || !variables.map[fields].filter(UploadField).empty
    }

    /**
     * Returns a list of all entities with at least one upload field.
     */
    def getUploadEntities(Application it) {
        getAllEntities.filter[hasUploadFieldsEntity]
    }

    /**
     * Checks whether the application contains at least one user field.
     */
    def hasUserFields(Application it) {
        !getAllEntityFields.filter(UserField).empty
    }

    /**
     * Checks whether the application contains at least one user variable.
     */
    def hasUserVariables(Application it) {
        !variables.map[fields].filter(UserField).empty
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
        !getAllListFields.empty || !variables.map[fields].flatten.filter(ListField).empty
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
        getAllEntities.filter[hasListFieldsEntity]
    }

    /**
     * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled.
     */
    def hasBooleansWithAjaxToggle(Application it) {
        !getEntitiesWithAjaxToggle.empty
    }

    /**
     * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled for it's view action.
     */
    def hasBooleansWithAjaxToggleInView(Application it) {
        !getAllEntities.filter[hasBooleansWithAjaxToggleEntity('view')].empty
    }

    /**
     * Checks whether the application contains at least one entity with at least one boolean field having ajax toggle enabled for it's display action.
     */
    def hasBooleansWithAjaxToggleInDisplay(Application it) {
        !getAllEntities.filter[hasBooleansWithAjaxToggleEntity('display')].empty
    }

    /**
     * Returns a list of all entities with at least one boolean field having ajax toggle enabled.
     */
    def getEntitiesWithAjaxToggle(Application it) {
        getAllEntities.filter[hasBooleansWithAjaxToggleEntity('')]
    }

    /**
     * Returns an application based on a given field.
     */
    def getApplication(Field it) {
        if (null !== entity) {
            return entity.application
        }
        if (null !== varContainer) {
            return varContainer.application
        }
        null
    }

    /**
     * Prepends the application vendor and the database prefix to a given string.
     */
    def tableNameWithPrefix(Application it, String inputString) {
        vendor.formatForDB + '_' + prefix() + '_' + inputString
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
     * Returns a list of all derived and unique fields of the given entity
     */
    def getUniqueDerivedFields(DataObject it) {
        getDerivedFields.filter[unique]
    }

    /**
     * Returns the primary key field of the given entity.
     */
    def DerivedField getPrimaryKey(DataObject it) {
        if (!getDerivedFields.filter[primaryKey].empty) {
            return getDerivedFields.findFirst[primaryKey]
        }
        if (!outgoing.filter(OneToOneRelationship).filter[primaryKey].empty) {
            return outgoing.filter(OneToOneRelationship).findFirst[primaryKey].source.getPrimaryKey
        }
        if (!outgoing.filter(ManyToOneRelationship).filter[primaryKey].empty) {
            return outgoing.filter(ManyToOneRelationship).findFirst[primaryKey].source.getPrimaryKey
        }
        null
    }

    /**
     * Returns a list of all fields which should be displayed on the view page.
     */
    def getFieldsForViewPage(Entity it) {
        var fields = getDisplayFields.filter[f|f.isVisibleOnViewPage].exclude(ArrayField).exclude(ObjectField)
        fields.toList as List<DerivedField>
    }

    /**
     * Returns a list of all fields which should be displayed on the display page.
     */
    def getFieldsForDisplayPage(Entity it) {
        getDisplayFields.filter[f|f.isVisibleOnDisplayPage]
    }

    /**
     * Returns a list of all fields which should be displayed.
     */
    def getDisplayFields(DataObject it) {
        var fields = getSelfAndParentDataObjects.map[getDerivedFields].flatten
        if (it instanceof Entity) {
            if (it.identifierStrategy != EntityIdentifierStrategy.NONE) {
                fields = fields.filter[!primaryKey]
            }
            if (!hasVisibleWorkflow) {
                fields = fields.filter[name != 'workflowState']
            }
        }
        fields
    }

    /**
     * Returns a list of all fields which may be used for sorting.
     */
    def getSortingFields(DataObject it) {
        var fields = getDisplayFields.filter[f|f.isSortField].exclude(UserField).exclude(ArrayField).exclude(ObjectField)
        fields.toList as List<Field>
    }

    /**
     * Returns a list of all editable fields of the given entity.
     * At the moment instances of ArrayField and ObjectField are excluded.
     * Also version fields are excluded as these are incremented automatically.
     */
    def getEditableFields(DataObject it) {
        var fields = getDerivedFields.filter[name != 'workflowState']
        if (it instanceof Entity && (it as Entity).identifierStrategy != EntityIdentifierStrategy.NONE) {
            fields = fields.filter[!primaryKey]
        }
        var filteredFields = fields.filter[!isVersionField].exclude(ObjectField)
        filteredFields.toList as List<DerivedField>
    }

    /**
     * Checks whether a given field is a version field or not.
     */
    def private isVersionField(Field it) {
        if (it instanceof IntegerField) {
            return it.version
        }

        false
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
     * Returns whether this field is visible on the view page.
     */
    def isVisibleOnViewPage(Field it) {
        #[FieldDisplayType.VIEW, FieldDisplayType.VIEW_SORTING, FieldDisplayType.VIEW_DISPLAY, FieldDisplayType.ALL].contains(displayType)
    }

    /**
     * Returns whether this field is visible on the display page.
     */
    def isVisibleOnDisplayPage(Field it) {
        #[FieldDisplayType.DISPLAY, FieldDisplayType.DISPLAY_SORTING, FieldDisplayType.VIEW_DISPLAY, FieldDisplayType.ALL].contains(displayType)
    }

    /**
     * Returns whether this field maybe used for sorting.
     */
    def isSortField(Field it) {
        #[FieldDisplayType.SORTING, FieldDisplayType.VIEW_SORTING, FieldDisplayType.DISPLAY_SORTING, FieldDisplayType.ALL].contains(displayType)
    }

    /**
     * Returns a list of all default items of this list.
     */
    def getDefaultItems(ListField it) {
        items.filter[^default]
    }

    /**
     * Returns the single parts of the display pattern for a given entity.
     */
    def displayPatternParts(Entity it) {
        getUsedDisplayPattern.split('#')
    }

    /**
     * Returns the actual display pattern for a given entity.
     */
    def getUsedDisplayPattern(Entity it) {
        var usedDisplayPattern = displayPattern

        if (isInheriting && (null === usedDisplayPattern || usedDisplayPattern == '')) {
            // fetch inherited display pattern from parent entity
            if (parentType instanceof Entity) {
                usedDisplayPattern = (parentType as Entity).displayPattern
            }
        }

        if (null === usedDisplayPattern || usedDisplayPattern == '') {
            usedDisplayPattern = name.formatForDisplay
        }

        usedDisplayPattern
    }

    /**
     * Returns whether any decimal or float fields exist or not.
     */
    def hasDecimalOrFloatNumberFields(Application it) {
        !getDecimalOrFloatNumberFields.empty
    }

    /**
     * Returns any decimal or float fields.
     */
    def getDecimalOrFloatNumberFields(Application it) {
        getAllEntities.map[getSelfAndParentDataObjects.map[
            fields.filter[f|f instanceof DecimalField || f instanceof FloatField]
        ].flatten].flatten
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
        !allowedExtensions.split(', ').filter[it == 'gif' || it == 'jpeg' || it == 'jpg' || it == 'png'].empty
    }

    /**
     * Checks whether an upload field is an image field without supporting other file types.
     */
    def isOnlyImageField(UploadField it) {
        allowedExtensions.split(', ').filter[it != 'gif' && it != 'jpeg' && it != 'jpg' && it != 'png'].empty
    }

    /**
     * Checks whether this entity has at least one string field which is not a password.
     */
    def hasDisplayStringFieldsEntity(DataObject it) {
        !getDisplayStringFieldsEntity.empty
    }

    /**
     * Returns a list of all string fields of this entity which are not passwords.
     */
    def getDisplayStringFieldsEntity(DataObject it) {
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role != StringRole.PASSWORD]].flatten
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
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.COLOUR]].flatten
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
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.COUNTRY]].flatten
    }

    /**
     * Checks whether locale-based filtering is possible or not.
     */
    def supportLocaleFilter(Application it) {
        !getAllEntities.filter[hasLanguageFieldsEntity || hasLocaleFieldsEntity].empty
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
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.LANGUAGE]].flatten
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
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.LOCALE]].flatten
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
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.TIME_ZONE]].flatten
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
        getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.CURRENCY]].flatten
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
    def hasBooleansWithAjaxToggleEntity(DataObject it, String context) {
        !getBooleansWithAjaxToggleEntity(context).empty
    }

    /**
     * Returns a list of all boolean fields having ajax toggle enabled.
     */
    def getBooleansWithAjaxToggleEntity(DataObject it, String context) {
        val fields = getBooleanFieldsEntity.filter[ajaxTogglability]
        if (fields.empty || context == '') {
            return fields
        }
        if (context == 'view') {
            return fields.filter[f|f.isVisibleOnViewPage]
        } else if (context == 'display') {
            return fields.filter[f|f.isVisibleOnDisplayPage]
        }
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
            UserField: 'UserEntity'
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
            DatetimeField: dateTimeFieldTypeAsString
            FloatField: 'float'
            default: ''
        }
    }

    /**
     * Prints an output string describing the type of the given date time field.
     */
    def dateTimeFieldTypeAsString(DatetimeField it) {
        if (components == DateTimeComponents.DATE_TIME) {
            return 'DateTime'
        }
        if (components == DateTimeComponents.DATE) {
            return 'date'
        }
        'time'
    }
}
