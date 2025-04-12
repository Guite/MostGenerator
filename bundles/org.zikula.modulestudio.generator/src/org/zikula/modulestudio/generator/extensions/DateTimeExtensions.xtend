package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateTimeRole
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Variables

/**
 * This class contains date and time related extension methods.
 */
class DateTimeExtensions {

    /**
     * Returns whether any date or time fields exist or not.
     */
    def hasAnyDateTimeFields(Application it) {
        !entities.filter[hasAnyDateTimeFieldsEntity].empty
    }

    /**
     * Checks whether this entity has at least one date or time field.
     */
    def hasAnyDateTimeFieldsEntity(Entity it) {
        !anyDateTimeFieldsEntity.empty
    }

    /**
     * Returns any date or time field from given entity.
     */
    def getAnyDateTimeFieldsEntity(Entity it) {
        fields.filter(DatetimeField)
    }

    /**
     * Returns whether an entity directly owns any date time fields or not.
     */
    def hasDirectDateTimeFields(Entity it) {
        !getDirectDateTimeFields.empty
    }

    /**
     * Returns date time fields directly owned by an entity.
     */
    def getDirectDateTimeFields(Entity it) {
        anyDateTimeFieldsEntity.filter[isDateTimeField]
    }

    /**
     * Returns whether an entity directly owns any date fields or not.
     */
    def hasDirectDateFields(Entity it) {
        !getDirectDateFields.empty
    }

    /**
     * Returns date time fields directly owned by an entity.
     */
    def getDirectDateFields(Entity it) {
        anyDateTimeFieldsEntity.filter[isDateField]
    }

    /**
     * Returns whether an entity directly owns any time fields or not.
     */
    def hasDirectTimeFields(Entity it) {
        !getDirectTimeFields.empty
    }

    /**
     * Returns date time fields directly owned by an entity.
     */
    def getDirectTimeFields(Entity it) {
        anyDateTimeFieldsEntity.filter[isTimeField]
    }

    /**
     * Returns whether a date time field represents a datetime value.
     */
    def isDateTimeField(DatetimeField it) {
        #[DateTimeRole.DATE_TIME, DateTimeRole.DATE_TIME_TZ].contains(role)
    }

    /**
     * Returns whether a date time field represents a date value.
     */
    def isDateField(DatetimeField it) {
        role == DateTimeRole.DATE
    }

    /**
     * Returns whether a date time field represents a time value.
     */
    def isTimeField(DatetimeField it) {
        role == DateTimeRole.TIME
    }

    /**
     * Determines the start date field of an entity if there is one.
     */
    def dispatch getStartDateField(Entity it) {
        val datetimeFields = fields.filter(DatetimeField).filter[startDate && role != DateTimeRole.TIME]
        if (!datetimeFields.empty) {
            return datetimeFields.head
        }
    }

    /**
     * Determines the end date field of an entity if there is one.
     */
    def dispatch getEndDateField(Entity it) {
        val datetimeFields = fields.filter(DatetimeField).filter[endDate && role != DateTimeRole.TIME]
        if (!datetimeFields.empty) {
            return datetimeFields.head
        }
    }

    /**
     * Determines the start date field of a variable container if there is one.
     */
    def dispatch getStartDateField(Variables it) {
        val datetimeFields = fields.filter(DatetimeField).filter[startDate]
        if (!datetimeFields.empty) {
            return datetimeFields.head
        }
    }

    /**
     * Determines the end date field of a variable container if there is one.
     */
    def dispatch getEndDateField(Variables it) {
        val datetimeFields = fields.filter(DatetimeField).filter[endDate]
        if (!datetimeFields.empty) {
            return datetimeFields.head
        }
    }

    def dispatch hasStartOrEndDateField(Entity it) {
        hasStartDateField || hasEndDateField
    }
    def dispatch hasStartAndEndDateField(Entity it) {
        hasStartDateField && hasEndDateField
    }
    def dispatch hasStartDateField(Entity it) {
        null !== getStartDateField
    }
    def dispatch hasEndDateField(Entity it) {
        null !== getEndDateField
    }

    def dispatch hasStartOrEndDateField(Variables it) {
        hasStartDateField || hasEndDateField
    }
    def dispatch hasStartAndEndDateField(Variables it) {
        hasStartDateField && hasEndDateField
    }
    def dispatch hasStartDateField(Variables it) {
        null !== getStartDateField
    }
    def dispatch hasEndDateField(Variables it) {
        null !== getEndDateField
    }

    /**
     * Returns a date expression for creating a default value for "now".
     */
    def defaultValueForNow(DatetimeField it) '''date('«defaultFormat»')'''

    /**
     * Returns the date format depending on the components property.
     */
    def defaultFormat(DatetimeField it) {
        if (isDateTimeField) {
            return 'Y-m-d H:i:s'
        }
        if (isDateField) {
            return 'Y-m-d'
        }
        if (isTimeField) {
            return 'H:i:s'
        }
        ''
    }
}
