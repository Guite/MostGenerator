package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DateTimeRole
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityLockType
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberFieldType
import de.guite.modulestudio.metamodel.NumberRole
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TextRole
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import java.math.BigInteger

/**
 * This class contains model related extension methods.
 */
class ModelExtensions {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    /**
     * Returns a list of all entity fields in this application.
     */
    def dispatch getAllEntityFields(Application it) {
        entities.map[fields].flatten.toList
    }

    /**
     * Returns the leading entity in the primary model container.
     */
    def getLeadingEntity(Application it) {
        entities.findFirst[leading]
    }

    /**
     * Checks whether the application contains at least one entity with at least one image field.
     */
    def hasImageFields(Application it) {
        entities.exists[hasImageFieldsEntity]
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
     * Returns a list of all upload fields.
     */
    def getAllUploadFields(Application it) {
        getUploadEntities.map[fields].flatten.filter(UploadField)
    }

    /**
     * Returns a list of all entities with at least one upload field.
     */
    def getUploadEntities(Application it) {
        entities.filter[hasUploadFieldsEntity]
    }

    def mappingName(UploadField it) {
        val containerSegment = if (null !== entity) entity.name.formatForDB else 'settings'
        application.vendor.formatForDB + '_' + application.name.formatForDB + '_' + containerSegment + '_' + name.formatForDB
    }

    def mappingPath(UploadField it) {
        val containerSegment = if (null !== entity) entity.nameMultiple.formatForDB else 'settings'
        containerSegment + '/' + name.formatForCode
    }

    /**
     * Checks whether the application contains at least one user field.
     */
    def hasUserFields(Application it) {
        !getAllEntityFields.filter(UserField).empty
    }

    /**
     * Checks whether the application contains at least one non-nullable user field.
     */
    def hasNonNullableUserFields(Application it) {
        !getAllEntityFields.filter(UserField).filter[!nullable].empty
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
        !getAllListFields.filter[multiple].empty
    }

    /**
     * Returns a list of all entities with at least one list field.
     */
    def getListEntities(Application it) {
        entities.filter[hasListFieldsEntity]
    }

    /**
     * Returns an application based on a given field.
     */
    def getApplication(Field it) {
        if (null !== entity) {
            return entity.application
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
    def fullEntityTableName(Entity it) {
        tableNameWithPrefix(application, name.formatForDB)
    }

    /**
     * Returns either the plural or the singular entity name, depending on a given boolean.
     */
    def getEntityNameSingularPlural(Entity it, Boolean usePlural) {
        if (usePlural) nameMultiple else name
    }

    /**
     * Returns a list of all unique fields of the given entity
     */
    def getUniqueFields(Entity it) {
        fields.filter[unique].filter[!primaryKey]
    }

    /**
     * Returns the primary key field of the given entity.
     */
    def Field getPrimaryKey(Entity it) {
        if (!fields.filter[primaryKey].empty) {
            return fields.findFirst[primaryKey]
        }
        // TODO check these cases more thoroughly
        if (!outgoing.filter(OneToOneRelationship).filter[primaryKey].empty) {
            return outgoing.filter(OneToOneRelationship).findFirst[primaryKey].source.getPrimaryKey
        }
        if (!outgoing.filter(ManyToOneRelationship).filter[primaryKey].empty) {
            return outgoing.filter(ManyToOneRelationship).findFirst[primaryKey].source.getPrimaryKey
        }
        null
    }

    /**
     * Returns a list of all fields which should be displayed on the index page.
     */
    def getFieldsForIndexPage(Entity it) {
        fields.filter[f|f.visibleOnIndex].toList
    }

    /**
     * Returns a list of all fields which should be displayed on the detail page.
     */
    def getFieldsForDetailPage(Entity it) {
        fields.filter[f|f.visibleOnDetail]
    }

    /**
     * Returns a list of all fields which may be used for sorting.
     */
    def getSortingFields(Entity it) {
        fields.filter[f|f.visibleOnSort].reject(UserField).reject(ArrayField).toList
    }

    /**
     * Returns a list of all editable fields of the given entity.
     * At the moment version fields are excluded as these are incremented automatically.
     * In addition all fields which are used as join columns are excluded as well.
     */
    def getEditableFields(Entity it) {
        var fields = fields.filter[name != 'workflowState' && name != 'translationData']
        var filteredFields = fields.filter[!isVersionField]
        val joinFieldNames = newArrayList
        for (relation : incoming.filter[targetField != 'id']) {
            joinFieldNames += relation.targetField
        }
        for (relation : outgoing.filter[sourceField != 'id']) {
            joinFieldNames += relation.sourceField
        }

        filteredFields = filteredFields.filter[!joinFieldNames.contains(name)]

        filteredFields.toList
    }

    /**
     * Checks whether a given field is a version field or not.
     */
    def private isVersionField(Field it) {
        if (it instanceof NumberField) {
            return NumberRole.VERSION == role;
        }

        false
    }

    def hasMinValue(NumberField it) {
        if (NumberFieldType.INTEGER == numberType) {
            return minValueInteger.compareTo(BigInteger.ZERO) > 0
        }
		null !== minValueFloat && 0 < minValueFloat
    }

    def getFormattedMinValue(NumberField it) {
        if (!hasMinValue) {
            return 0
        }
        if (NumberFieldType.INTEGER == numberType) {
            return minValueInteger
        }
        minValueFloat
    }

    def hasMaxValue(NumberField it) {
        if (NumberFieldType.INTEGER == numberType) {
            return maxValueInteger.compareTo(BigInteger.ZERO) > 0
        }
        null !== maxValueFloat && 0 < maxValueFloat
    }

    def getFormattedMaxValue(NumberField it) {
        if (!hasMaxValue) {
            return 0
        }
        if (NumberFieldType.INTEGER == numberType) {
            return maxValueInteger
        }
        maxValueFloat
    }

    /**
     * Checks whether this entity has at least one user field.
     */
    def hasUserFieldsEntity(Entity it) {
        !getUserFieldsEntity.empty
    }

    /**
     * Returns a list of all fields of this entity.
     */
    def dispatch getAllEntityFields(Entity it) {
        it.fields.filter[f|f.primaryKey]
        + 
        fields.filter[f|!f.primaryKey]
    }

    /**
     * Returns a list of all user fields of this entity.
     */
    def getUserFieldsEntity(Entity it) {
        getAllEntityFields.filter(UserField)
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
        getAllEntityFields.filter(UploadField)
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
        getAllEntityFields.filter(ListField)
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

        if (null === usedDisplayPattern || usedDisplayPattern.empty) {
            usedDisplayPattern = name.formatForDisplay
        }

        usedDisplayPattern
    }

    /**
     * Returns whether any number fields exist or not.
     */
    def hasNumberFields(Application it) {
        !getNumberFields.empty
    }

    /**
     * Returns any decimal or float fields.
     */
    def getNumberFields(Application it) {
        entities.map[fields.filter(NumberField)].flatten
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
        getUploadFieldsEntity.filter[isImageField]
    }

    /**
     * Checks whether an upload field is an image field.
     */
    def isImageField(UploadField it) {
        '*' == allowedExtensions || !allowedExtensions.split(', ').filter[imageExtensions.contains(it)].empty
    }

    /**
     * Checks whether an upload field is an image field without supporting other file types.
     */
    def isOnlyImageField(UploadField it) {
        allowedExtensions.split(', ').filter[!imageExtensions.contains(it)].empty
    }

    def private getImageExtensions() {
        #['gif', 'jpeg', 'jpg', 'png', 'svg']
    }

    /**
     * Checks whether this entity has at least one string field which is not a password.
     */
    def hasDisplayStringFieldsEntity(Entity it) {
        !getDisplayStringFieldsEntity.empty
    }

    /**
     * Returns a list of all string fields of this entity which are not passwords.
     */
    def getDisplayStringFieldsEntity(Entity it) {
        fields.filter(StringField).filter[!#[StringRole.PASSWORD, StringRole.ULID, StringRole.UUID].contains(role)]
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
        fields.filter(StringField).filter[role == StringRole.COUNTRY]
    }

    /**
     * Checks whether this entity has at least one dateInterval field.
     */
    def hasDateIntervalFieldsEntity(Entity it) {
        !getDateIntervalFieldsEntity.empty
    }

    /**
     * Returns a list of all dateInterval fields of this entity.
     */
    def getDateIntervalFieldsEntity(Entity it) {
        fields.filter(StringField).filter[role == StringRole.DATE_INTERVAL]
    }

    /**
     * Checks whether locale-based filtering is possible or not.
     */
    def supportLocaleFilter(Application it) {
        !entities.filter[hasLanguageFieldsEntity || hasLocaleFieldsEntity].empty
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
        fields.filter(StringField).filter[role == StringRole.LANGUAGE]
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
        fields.filter(StringField).filter[role == StringRole.LOCALE]
    }

    /**
     * Checks whether this entity has at least one time zone field.
     */
    def hasTimezoneFieldsEntity(Entity it) {
        !getTimezoneFieldsEntity.empty
    }

    /**
     * Returns a list of all time zone fields of this entity.
     */
    def getTimezoneFieldsEntity(Entity it) {
        fields.filter(StringField).filter[role == StringRole.TIME_ZONE]
    }

    /**
     * Checks whether this entity has at least one currency field.
     */
    def hasCurrencyFieldsEntity(Entity it) {
        !getCurrencyFieldsEntity.empty
    }

    /**
     * Returns a list of all currency fields of this entity.
     */
    def getCurrencyFieldsEntity(Entity it) {
        fields.filter(StringField).filter[role == StringRole.CURRENCY]
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
        fields.filter(AbstractStringField)
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
        fields.filter(StringField)
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
        fields.filter(TextField)
    }

    /**
     * Checks whether this entity has at least one boolean field.
     */
    def hasBooleanFieldsEntity(Entity it) {
        !getBooleanFieldsEntity.empty
    }

    /**
     * Returns a list of all boolean fields of this entity.
     */
    def getBooleanFieldsEntity(Entity it) {
        fields.filter(BooleanField)
    }

    /**
     * Returns the sub folder path segment for this upload field,
     * that is actually field name by default.
     */
    def subFolderPathSegment(UploadField it) {
        name.formatForCode
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
            default: ''
        }
    }

    /**
     * Checks whether this entity has enabled optimistic locking.
     */
    def hasOptimisticLock(Entity it) {
        lockType == EntityLockType.OPTIMISTIC
    }
    /**
     * Checks whether this entity has enabled pessimistic read locking.
     */
    def hasPessimisticReadLock(Entity it) {
        lockType == EntityLockType.PESSIMISTIC_READ
    }
    /**
     * Checks whether this entity has enabled pessimistic write locking.
     */
    def hasPessimisticWriteLock(Entity it) {
        lockType == EntityLockType.PESSIMISTIC_WRITE
    }

    /**
     * Prints an output string describing the type of the given derived field.
     */
    def fieldTypeAsString(Field it, Boolean forPhp) {
        switch it {
            BooleanField: if (forPhp) 'bool' else 'boolean'
            UserField: 'User'
            NumberField:
                if (NumberFieldType.INTEGER == numberType) {
                    if (forPhp) 'int'
                    else {
                        // choose mapping type depending on length
                        if (it.length < 5) 'smallint'
                        else if (it.length < 12) 'integer'
                        else 'bigint'
                    }
                } else {
                    if (forPhp) 'float' else {
                        if (NumberFieldType.DECIMAL === numberType) 'decimal' else 'float'
                    }
                }
            StringField:
                if (StringRole.DATE_INTERVAL == role) '\\DateInterval'
                else if (treatAsUuidType) 'Uuid'
                else 'string'
            TextField: if (forPhp) 'string' else 'text'
            UploadField: 'string'
            ListField: if (multiple) 'array' else 'string'
            ArrayField: 'array'
            DatetimeField: if (forPhp) 'DateTime' else dateTimeFieldTypeAsString
            default: ''
        }
    }

    /**
     * Prints an output string describing the type of the given date time field.
     */
    def private dateTimeFieldTypeAsString(DatetimeField it) {
        if (role == DateTimeRole.DATE_TIME) 'datetime' else
        if (role == DateTimeRole.DATE_TIME_TZ) 'datetimetz' else
        if (role == DateTimeRole.DATE) 'date' else
        if (role == DateTimeRole.TIME) 'time' else
        ''
    }

    /**
     * Whether a field should be treated as UUID or not.
     */
    def treatAsUuidType(StringField it) {
        StringRole.UUID === role && primaryKey
    }

    /**
     * Returns the string value for a given text role.
     */
    def textRoleAsCodeLanguage(TextRole role) {
        switch role {
            case CODE_CSS: 'css'
            case CODE_DOCKERFILE: 'dockerfile'
            case CODE_JS: 'js'
            case CODE_MARKDOWN: 'markdown'
            case CODE_NGINX: 'nginx'
            case CODE_PHP: 'php'
            case CODE_SHELL: 'shell'
            case CODE_SQL: 'sql'
            case CODE_TWIG: 'twig'
            case CODE_XML: 'xml'
            case CODE_YAML: 'yaml'
            case CODE_YAML_FM: 'yaml-frontmatter'
            default: ''
        }
    }
}
