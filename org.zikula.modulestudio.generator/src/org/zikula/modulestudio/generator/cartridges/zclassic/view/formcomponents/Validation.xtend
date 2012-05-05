package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validation {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension Utils = new Utils()

    def dispatch mandatoryValidationMessage(DerivedField it, String idSuffix) '''
        «IF mandatory»
            {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='required'}
        «ENDIF»
        «IF unique»
            {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-unique'}
        «ENDIF»
    '''
    def dispatch mandatoryValidationMessage(ListField it, String idSuffix) {
    }

    def dispatch additionalValidationMessages(DerivedField it, String idSuffix) {
    }
    def dispatch additionalValidationMessages(AbstractIntegerField it, String idSuffix) '''
        {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-digits'}
    '''
    def dispatch additionalValidationMessages(UserField it, String idSuffix) '''
        {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-alphanum'}
    '''
    def dispatch additionalValidationMessages(DecimalField it, String idSuffix) '''
        {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-number'}
    '''
    def dispatch additionalValidationMessages(FloatField it, String idSuffix) '''
        {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-number'}
    '''
    def dispatch additionalValidationMessages(AbstractStringField it, String idSuffix) '''
        «IF nospace»
            {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-nospace'}
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(StringField it, String idSuffix) '''
        «IF nospace && !country && !language»
            {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-nospace'}
        «ENDIF»
        «IF htmlcolour»
            {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-htmlcolour'}
        «ENDIF»
    '''
    def dispatch additionalValidationMessages(EmailField it, String idSuffix) '''
        {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-email'}
    '''
    def dispatch additionalValidationMessages(UrlField it, String idSuffix) '''
        {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-url'}
    '''
    def dispatch additionalValidationMessages(ListField it, String idSuffix) {
    }
    def dispatch additionalValidationMessages(AbstractDateField it, String idSuffix) '''
        «IF past»
            {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-«fieldTypeAsString»-past'}
        «ELSEIF future»
            {«entity.container.application.appName.formatForDB»ValidationError id=«templateIdWithSuffix(name.formatForCode, idSuffix)» class='validate-«fieldTypeAsString»-past'}
        «ENDIF»
    '''

    def fieldValidationCssClass(DerivedField it) ''' cssClass='«IF mandatory»required«IF unique» «ENDIF»«ENDIF»«IF unique»validate-unique«ENDIF»«fieldValidationCssClassAdditions»' '''
    def fieldValidationCssClassEdit(UploadField it)''' cssClass='«IF unique»validate-unique«ENDIF»«fieldValidationCssClassAdditions»' '''
    def private fieldValidationCssClassAdditions(DerivedField it) {
        switch it {
            AbstractIntegerField: ' validate-digits'
            DecimalField: ' validate-number'
            FloatField: ' validate-number'
            AbstractStringField case it.nospace: ' validate-nospace'
            StringField case it.nospace: ' validate-nospace'
            StringField case it.htmlcolour: ' validate-htmlcolour ' + entity.container.application.appName.formatForDB + 'ColourPicker'
            EmailField: ' validate-email'
            UrlField: ' validate-url'
            ListField: ''
            AbstractDateField: '''«IF it.past» validate-«fieldTypeAsString»-past«ELSEIF it.future» validate-«fieldTypeAsString»-future«ENDIF»'''
        }
    }
}
