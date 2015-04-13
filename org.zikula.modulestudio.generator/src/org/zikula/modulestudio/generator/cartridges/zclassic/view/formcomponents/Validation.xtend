package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validation {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def dispatch mandatoryValidationMessage(DerivedField it, String idSuffix) '''
        «IF isLegacyApp»
            «IF mandatory»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='required'}
            «ENDIF»
            «IF unique»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-unique'}
            «ENDIF»
        «ENDIF»
    '''
    def dispatch mandatoryValidationMessage(ListField it, String idSuffix) {
    }

    def dispatch additionalValidationMessages(DerivedField it, String idSuffix) {
    }
    def dispatch additionalValidationMessages(AbstractIntegerField it, String idSuffix) '''
        «IF isLegacyApp»
            {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-digits'}
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(UserField it, String idSuffix) '''
    '''
    def dispatch additionalValidationMessages(DecimalField it, String idSuffix) '''
        «IF isLegacyApp»
            {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-number'}
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(FloatField it, String idSuffix) '''
        «IF isLegacyApp»
            {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-number'}
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(AbstractStringField it, String idSuffix) '''
        «IF isLegacyApp»
            «IF nospace»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-nospace'}
            «ENDIF»
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(StringField it, String idSuffix) '''
        «IF isLegacyApp»
            «IF nospace && !country && !language && !locale»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-nospace'}
            «ENDIF»
            «IF htmlcolour»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-htmlcolour'}
            «ENDIF»
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(EmailField it, String idSuffix) '''
        «IF isLegacyApp»
            {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-email'}
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(UrlField it, String idSuffix) '''
        «IF isLegacyApp»
            {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-url'}
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(UploadField it, String idSuffix) '''
        «IF isLegacyApp»
            {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-upload'}
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(ListField it, String idSuffix) {
    }
    def dispatch additionalValidationMessages(AbstractDateField it, String idSuffix) '''
        «additionalValidationMessagesDefault(idSuffix)»
    '''
    def dispatch additionalValidationMessages(DatetimeField it, String idSuffix) '''
        «additionalValidationMessagesDefault(idSuffix)»
        «additionalValidationMessagesDateRange(idSuffix)»
    '''
    def dispatch additionalValidationMessages(DateField it, String idSuffix) '''
        «additionalValidationMessagesDefault(idSuffix)»
        «additionalValidationMessagesDateRange(idSuffix)»
    '''
    def private additionalValidationMessagesDefault(AbstractDateField it, String idSuffix) '''
        «IF isLegacyApp»
            «IF past»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-«fieldTypeAsString.toLowerCase»-past'}
            «ELSEIF future»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-«fieldTypeAsString.toLowerCase»-future'}
            «ENDIF»
        «ENDIF»
    '''
    def private dispatch additionalValidationMessagesDateRange(DatetimeField it, String idSuffix) '''
        «IF isLegacyApp»
            «IF entity.getStartDateField !== null && entity.getEndDateField !== null»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-daterange-«entity.name.formatForDB»'}
            «ENDIF»
        «ENDIF»
    '''
    def private dispatch additionalValidationMessagesDateRange(DateField it, String idSuffix) '''
        «IF isLegacyApp»
            «IF entity.getStartDateField !== null && entity.getEndDateField !== null»
                {«entity.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-daterange-«entity.name.formatForDB»'}
            «ENDIF»
        «ENDIF»
    '''

    def fieldValidationCssClass(DerivedField it, Boolean addFormControl) ''' cssClass='«IF addFormControl && !isLegacyApp»form-control «ENDIF»«IF mandatory»required«IF unique» «ENDIF»«ENDIF»«IF unique»validate-unique«ENDIF»«IF cssClass !== null && cssClass !== ''» «cssClass»«ENDIF»«fieldValidationCssClassAdditions»' '''
    def fieldValidationCssClassOptional(UploadField it, Boolean addFormControl)''' cssClass='«IF addFormControl && !isLegacyApp»form-control «ENDIF»«IF unique»validate-unique«ENDIF»«IF cssClass !== null && cssClass !== ''» «cssClass»«ENDIF»«fieldValidationCssClassAdditions»' '''
    def private fieldValidationCssClassAdditions(DerivedField it) {
        switch it {
            AbstractIntegerField: ' validate-digits'
            DecimalField: ' validate-number'
            FloatField: ' validate-number'
            StringField case it.htmlcolour: ' validate-nospace validate-htmlcolour ' + entity.application.appName.formatForDB + 'ColourPicker'
            StringField case it.nospace: ' validate-nospace'
            TextField case it.nospace: ' validate-nospace'
            EmailField case it.nospace: ' validate-nospace validate-email'
            EmailField: ' validate-email'
            UrlField case it.nospace: ' validate-nospace validate-url'
            UrlField: ' validate-url'
            UploadField case it.nospace: ' validate-nospace validate-upload'
            UploadField: ' validate-upload'
            ListField case it.nospace: ' validate-nospace'
            ListField: ''
            TimeField: fieldValidationCssClassAdditionsDefault
            AbstractDateField: '''«fieldValidationCssClassAdditionsDefault»«fieldValidationCssClassDateRange»'''
        }
    }

    def private fieldValidationCssClassAdditionsDefault(AbstractDateField it) '''«IF it.past» validate-«fieldTypeAsString.toLowerCase»-past«ELSEIF it.future» validate-«fieldTypeAsString.toLowerCase»-future«ENDIF»'''

    def private dispatch fieldValidationCssClassDateRange(DatetimeField it) '''«IF entity.getStartDateField !== null && entity.getEndDateField !== null» validate-daterange-«entity.name.formatForDB»«ENDIF»'''
    def private dispatch fieldValidationCssClassDateRange(DateField it) '''«IF entity.getStartDateField !== null && entity.getEndDateField !== null» validate-daterange-«entity.name.formatForDB»«ENDIF»'''

    def private isLegacyApp(DerivedField it) {
        entity.application.targets('1.3.x')
    }
}
