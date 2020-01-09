package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validation {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def fieldValidationCssClass(DerivedField it) '''«IF unique»validate-unique«ENDIF»«IF null !== cssClass && !cssClass.equals('')»«IF unique» «ENDIF»«cssClass»«ENDIF»«fieldValidationCssClassAdditions»'''
    def fieldValidationCssClassOptional(UploadField it)'''«IF unique»validate-unique«ENDIF»«IF null !== cssClass && !cssClass.equals('')»«IF unique» «ENDIF»«cssClass»«ENDIF»«fieldValidationCssClassAdditions»'''

    def private fieldValidationCssClassAdditions(DerivedField it) {
        switch it {
            StringField case it.role == StringRole.COLOUR: ' validate-colour ' + application.appName.formatForDB + '-colour-picker'
            UploadField: ' validate-upload'
            DatetimeField: '''«fieldValidationCssClassAdditionsDefault»«IF !isTimeField»«fieldValidationCssClassDateRange»«ENDIF»'''
            default: ''
        }
    }

    def private fieldValidationCssClassAdditionsDefault(DatetimeField it) '''«IF it.past» validate-«fieldTypeAsString(false).toLowerCase»-past«ELSEIF it.future» validate-«fieldTypeAsString(false).toLowerCase»-future«ENDIF»'''

    def private fieldValidationCssClassDateRange(DatetimeField it) '''«IF null !== entity && entity.hasStartAndEndDateField && (startDate || endDate)» validate-daterange-entity-«entity.name.formatForDB»«ELSEIF null !== varContainer && varContainer.hasStartAndEndDateField && (startDate || endDate)» validate-daterange-vars-«varContainer.name.formatForDB»«ENDIF»'''
}
