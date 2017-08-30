package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validation {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def fieldValidationCssClass(DerivedField it) '''«IF unique»validate-unique«ENDIF»«IF null !== cssClass && !cssClass.equals('')» «cssClass»«ENDIF»«fieldValidationCssClassAdditions»'''
    def fieldValidationCssClassOptional(UploadField it)'''«IF unique»validate-unique«ENDIF»«IF null !== cssClass && !cssClass.equals('')» «cssClass»«ENDIF»«fieldValidationCssClassAdditions»'''

    def private fieldValidationCssClassAdditions(DerivedField it) {
        switch it {
            StringField case it.role == StringRole.COLOUR: ' validate-nospace validate-colour ' + entity.application.appName.formatForDB + '-colour-picker'
            StringField case it.nospace: ' validate-nospace'
            TextField case it.nospace: ' validate-nospace'
            EmailField case it.nospace: ' validate-nospace'
            UrlField case it.nospace: ' validate-nospace'
            UploadField case it.nospace: ' validate-nospace validate-upload'
            UploadField: ' validate-upload'
            ListField case it.nospace: ' validate-nospace'
            TimeField: fieldValidationCssClassAdditionsDefault
            AbstractDateField: '''«fieldValidationCssClassAdditionsDefault»«fieldValidationCssClassDateRange»'''
            default: ''
        }
    }

    def private fieldValidationCssClassAdditionsDefault(AbstractDateField it) '''«IF it.past» validate-«fieldTypeAsString.toLowerCase»-past«ELSEIF it.future» validate-«fieldTypeAsString.toLowerCase»-future«ENDIF»'''

    def private dispatch fieldValidationCssClassDateRange(DatetimeField it) '''«IF null !== entity.startDateField && null !== entity.endDateField» validate-daterange-«entity.name.formatForDB»«ENDIF»'''
    def private dispatch fieldValidationCssClassDateRange(DateField it) '''«IF null !== entity.startDateField && null !== entity.endDateField» validate-daterange-«entity.name.formatForDB»«ENDIF»'''
}
