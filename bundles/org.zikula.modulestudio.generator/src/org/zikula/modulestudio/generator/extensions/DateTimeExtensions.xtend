package org.zikula.modulestudio.generator.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DateTimeComponents
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Variables

/**
 * This class contains date and time related extension methods.
 */
class DateTimeExtensions {

    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions

    /**
     * Returns whether any date or time fields exist or not.
     */
    def hasAnyDateTimeFields(Application it) {
        !getAllEntities.filter[!getSelfAndParentDataObjects.map[
            fields.filter(DatetimeField)
        ].flatten.empty].empty
    }

    /**
     * Returns whether a data object directly owns any date time fields or not.
     */
    def hasDirectDateTimeFields(DataObject it) {
        !getDirectDateTimeFields.empty
    }

    /**
     * Returns date time fields directly owned by a data object.
     */
    def getDirectDateTimeFields(DataObject it) {
        fields.filter(DatetimeField).filter[isDateTimeField]
    }

    /**
     * Returns whether a data object directly owns any date fields or not.
     */
    def hasDirectDateFields(DataObject it) {
        !getDirectDateFields.empty
    }

    /**
     * Returns date time fields directly owned by a data object.
     */
    def getDirectDateFields(DataObject it) {
        fields.filter(DatetimeField).filter[isDateField]
    }

    /**
     * Returns whether a data object directly owns any time fields or not.
     */
    def hasDirectTimeFields(DataObject it) {
        !getDirectTimeFields.empty
    }

    /**
     * Returns date time fields directly owned by a data object.
     */
    def getDirectTimeFields(DataObject it) {
        fields.filter(DatetimeField).filter[isTimeField]
    }

    /**
     * Returns whether a date time field represents a datetime value.
     */
    def isDateTimeField(DatetimeField it) {
        components == DateTimeComponents.DATE_TIME
    }

    /**
     * Returns whether a date time field represents a date value.
     */
    def isDateField(DatetimeField it) {
        components == DateTimeComponents.DATE
    }

    /**
     * Returns whether a date time field represents a time value.
     */
    def isTimeField(DatetimeField it) {
        components == DateTimeComponents.TIME
    }

    /**
     * Determines the start date field of a data object if there is one.
     */
    def dispatch getStartDateField(DataObject it) {
        val datetimeFields = getSelfAndParentDataObjects.map[fields.filter(DatetimeField).filter[startDate && components != DateTimeComponents.TIME]].flatten
        if (!datetimeFields.empty) {
            return datetimeFields.head
        }
    }

    /**
     * Determines the end date field of a data object if there is one.
     */
    def dispatch getEndDateField(DataObject it) {
        val datetimeFields = getSelfAndParentDataObjects.map[fields.filter(DatetimeField).filter[endDate && components != DateTimeComponents.TIME]].flatten
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

    def dispatch hasStartOrEndDateField(DataObject it) {
        hasStartDateField || hasEndDateField
    }
    def dispatch hasStartAndEndDateField(DataObject it) {
        hasStartDateField && hasEndDateField
    }
    def dispatch hasStartDateField(DataObject it) {
        null !== getStartDateField
    }
    def dispatch hasEndDateField(DataObject it) {
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
