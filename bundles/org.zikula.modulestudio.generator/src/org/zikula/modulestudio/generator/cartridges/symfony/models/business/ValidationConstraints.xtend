package org.zikula.modulestudio.generator.cartridges.symfony.models.business

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import java.math.BigInteger
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class ValidationConstraints {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions

    def dispatch fieldAnnotations(Field it) {
    }

    def private fieldAnnotationsMandatory(Field it) '''
        «IF mandatory»
            #[Assert\NotBlank]
        «/*ELSEIF !nullable»
            #[Assert\NotNull]
        */»«ENDIF»
    '''

    def dispatch fieldAnnotations(BooleanField it) '''
        «IF mandatory»
            #[Assert\IsTrue(message: 'This option is mandatory.')]
        «/*ELSEIF !nullable»
            #[Assert\NotNull]
        */»«ENDIF»
    '''

    def private fieldAnnotationsNumeric(Field it) '''
        #[Assert\Type(type: 'numeric')]
        «IF mandatory»
            #[Assert\NotBlank]
            #[Assert\NotEqualTo(value: 0)]
        «/*ELSEIF !nullable»
            #[Assert\NotNull]
        */»«ENDIF»
    '''

    def private fieldAnnotationsInteger(AbstractIntegerField it) '''
        «IF mandatory && (!primaryKey || (null !== entity && entity.getVersionField == this))»
            #[Assert\NotBlank]
            #[Assert\NotEqualTo(value: 0)]
        «/*ELSEIF !nullable»
            #[Assert\NotNull]
        */»«ENDIF»
    '''
    def dispatch fieldAnnotations(AbstractIntegerField it) '''
        «IF null === entity
         || (
            entity.incoming.filter[r|r.targetField == name].empty
             && entity.outgoing.filter[r|r.sourceField == name].empty
         )»
            «fieldAnnotationsInteger»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(IntegerField it) '''
        «IF null === entity
         || (
            entity.incoming.filter[r|r.targetField == name].empty
             && entity.outgoing.filter[r|r.sourceField == name].empty
         )»
            «fieldAnnotationsInteger»
            «IF minValue.toString != '0' && maxValue.toString != '0'»
                #[Assert\Range(min: «minValue», max: «maxValue»)]
            «ELSEIF minValue.toString != '0'»
                #[Assert\GreaterThanOrEqual(value: «minValue»)]
                #[Assert\LessThan(value: «BigInteger.valueOf((10 ** length) as long)»)]
            «ELSEIF maxValue.toString != '0'»
                #[Assert\LessThanOrEqual(value: «maxValue»)]
            «ELSE»
                #[Assert\LessThan(value: «BigInteger.valueOf((10 ** length) as long)»)]
            «ENDIF»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(NumberField it) '''
        «fieldAnnotationsNumeric»
        «IF minValue.toString != '0.0' && maxValue.toString != '0.0'»
            #[Assert\Range(min: «minValue», max: «maxValue»)]
        «ELSEIF minValue.toString != '0.0'»
            #[Assert\GreaterThanOrEqual(value: «minValue»)]
            #[Assert\LessThan(value: «BigInteger.valueOf((10 ** length) as long)»)]
        «ELSEIF maxValue.toString != '0.0'»
            #[Assert\LessThanOrEqual(value: «maxValue»)]
        «ELSE»
            #[Assert\LessThan(value: «BigInteger.valueOf((10 ** length) as long)»)]
        «ENDIF»
    '''
    def dispatch fieldAnnotations(UserField it) '''
        «IF mandatory && !primaryKey»
            #[Assert\NotBlank]
        «/*ELSEIF !nullable»
            #[Assert\NotNull]
        */»«ENDIF»
    '''

    def private fieldAnnotationsString(AbstractStringField it) '''
        «fieldAnnotationsMandatory»
    '''

    def dispatch fieldAnnotations(AbstractStringField it) {
    }
    def dispatch fieldAnnotations(StringField it) '''
        «fieldAnnotationsString»
        «IF mandatory»
            #[Assert\Length(min: «minLength», max: «length»)]
        «ELSE»
            #[Assert\AtLeastOneOf(
                constraints: [
                    new Assert\Blank(),
                    new Assert\Length(min: «minLength», max: «length»),
                ]
            )]
        «ENDIF»
        «IF role == StringRole.BIC»
            «IF null !== entity && !entity.allEntityFields.filter(StringField).filter[role == StringRole.IBAN].empty»
                #[Assert\Bic(ibanPropertyPath: '«entity.allEntityFields.filter(StringField).filter[role == StringRole.IBAN].head.name.formatForCode»')]
            «ELSE»
                #[Assert\Bic]
            «ENDIF»
        «ELSEIF role == StringRole.CIDR»
            #[Assert\Cidr]
        «ELSEIF role == StringRole.COLOUR»
            #[Assert\CssColor]
        «ELSEIF role == StringRole.COUNTRY»
            #[Assert\Country]
        «ELSEIF role == StringRole.CREDIT_CARD»
            #[Assert\Luhn(message: 'Please check your credit card number.')]
            #[Assert\CardScheme(schemes: ['AMEX', 'CHINA_UNIONPAY', 'DINERS', 'DISCOVER', 'INSTAPAYMENT', 'JCB', 'LASER', 'MAESTRO', 'MASTERCARD', 'UATP', 'VISA'])]
        «ELSEIF role == StringRole.CURRENCY»
            #[Assert\Currency]
        «ELSEIF role == StringRole.HOSTNAME»
            #[Assert\Hostname]
        «ELSEIF role == StringRole.IBAN»
            #[Assert\Iban]
        «ELSEIF role == StringRole.ISIN»
            #[Assert\Isin]
        «ELSEIF role == StringRole.LANGUAGE»
            #[Assert\Language]
        «ELSEIF role == StringRole.LOCALE»
            #[Assert\Locale]
        «ELSEIF role == StringRole.MAIL»
            #[Assert\Email]
        «ELSEIF role == StringRole.PASSWORD»
            #[Assert\NotCompromisedPassword]
            #[Assert\PasswordStrength]
        «ELSEIF role == StringRole.TIME_ZONE»
            #[Assert\Timezone]
        «ELSEIF role == StringRole.ULID»
            #[Assert\Ulid]
        «ELSEIF role == StringRole.URL»
            #[Assert\Url]
            #[Assert\NoSuspiciousCharacters]
        «ELSEIF role == StringRole.UUID»
            #[Assert\Uuid(strict: true)]
        «ENDIF»
    '''
    private def lengthAnnotationString(AbstractStringField it, int length) '''
        «IF mandatory»
            #[Assert\Length(min: «minLength», max: «length»)]
        «ELSE»
            #[Assert\AtLeastOneOf(
                constraints: [
                    new Assert\Blank(),
                    new Assert\Length(min: «minLength», max: «length»),
                ]
            )]
        «ENDIF»
    '''
    def dispatch fieldAnnotations(TextField it) '''
        «fieldAnnotationsString»
        «lengthAnnotationString(length)»
    '''
    def dispatch fieldAnnotations(UploadField it) '''
        «fieldAnnotationsString»
        «lengthAnnotationString(length)»
    '''
    def uploadFileAnnotations(UploadField it) '''
        #[Assert\File(
            «FOR constraint : getUploadConstraints»
        «' '»    «constraint»,
            «ENDFOR»
        )]
        «IF isOnlyImageField»
            #[Assert\Image(
                «FOR constraint : getUploadImageConstraints»
            «' '»    «constraint»,
                «ENDFOR»
            )]
        «ENDIF»
    '''
    def private getUploadConstraints(UploadField it) {
        val constraints = newArrayList

        if (!maxSize.empty) {
            constraints += '''maxSize: '«maxSize»'«''»'''
        }

        val extensionsString = '\'' + allowedExtensions.split(', ').join('\', \'') + '\''
        constraints += '''extensions: [«extensionsString»]'''

        if (!mimeTypes.empty && '*' != mimeTypes) {
            val mimeTypesList = mimeTypes.replaceAll(', ', ',').split(',')
            var mimeTypeString = '\'' + mimeTypesList.join('\', \'') + '\''
            constraints += '''mimeTypes: [«mimeTypeString»]'''
        }

        constraints
    }
    def private getUploadImageConstraints(UploadField it) {
        val constraints = newArrayList

        if (!allowSquare) {
            constraints += 'allowSquare: false'
        }
        if (!allowLandscape) {
            constraints += 'allowLandscape: false'
        }
        if (!allowPortrait) {
            constraints += 'allowPortrait: false'
        }

        constraints
    }
    def dispatch fieldAnnotations(ListField it) '''
        «fieldAnnotationsMandatory»
        #[«application.name.formatForCodeCapital»Assert\ListEntry(entityName: '«entity.name.formatForCode»', propertyName: '«name.formatForCode»', multiple: «multiple.displayBool»«IF multiple»«IF min > 0», min: «min»«ENDIF»«IF max > 0», max: «max»«ENDIF»«ENDIF»)]
    '''
    def dispatch fieldAnnotations(ArrayField it) '''
        «fieldAnnotationsMandatory»
        «IF max > 0»
            #[Assert\Count(min: «min», max: «max»)]
        «ENDIF»
    '''
    def dispatch fieldAnnotations(DatetimeField it) '''
        «fieldAnnotationsMandatory»
        «IF isDateTimeField || isDateField»
            «/*IF false»«/* no constraint as the underlying model is type hinted already * /»
                «IF isDateTimeField»
                    #[Assert\DateTime]
                «ELSEIF isDateField»
                    #[Assert\Date]
                «ENDIF»
            «ENDIF*/»«IF past»
                #[Assert\LessThan(value: 'now', message: 'Please select a value in the past.')]
            «ELSEIF future»
                #[Assert\GreaterThan(value: 'now', message: 'Please select a value in the future.')]
            «ENDIF»
            «IF endDate && null !== entity && entity.hasStartDateField»
                «IF mandatory»
                    #[Assert\GreaterThan(propertyPath: '«entity.getStartDateField.name.formatForCode»', message: 'The start must be before the end.')]
                «ELSE»
                    #[Assert\Expression('«IF !mandatory»!value or «ENDIF»value > this.get«entity.getStartDateField.name.formatForCodeCapital»()', message: 'The start must be before the end.')]
                «ENDIF»
            «ENDIF»«/*ELSEIF isTimeField» causes issues with EABs TimeField during editing
            #[Assert\Time] */»
        «ENDIF»
    '''

    def validationMethods(DatetimeField it) '''
        «IF isTimeField»
        «IF past»
            /**
             * Checks whether the «name.formatForCode» field value is in the past.
             * This method is used for validation.
             */
            #[Assert\IsTrue(message: 'This value must be a time in the past.')]
            public function is«name.formatForCodeCapital»TimeValidPast(): bool
            {
                $format = 'His';

                return «IF !mandatory»!$this->get«name.formatForCodeCapital»() || «ENDIF»$this->get«name.formatForCodeCapital»()->format($format) < date($format);
            }
        «ELSEIF future»
            /**
             * Checks whether the «name.formatForCode» field value is in the future.
             * This method is used for validation.
             */
            #[Assert\IsTrue(message: 'This value must be a time in the future.')]
            public function is«name.formatForCodeCapital»TimeValidFuture(): bool
            {
                $format = 'His';

                return «IF !mandatory»!$this->get«name.formatForCodeCapital»() || «ENDIF»$this->get«name.formatForCodeCapital»()->format($format) > date($format);
            }
        «ENDIF»
        «ENDIF»
    '''

    def classAnnotations(Entity it) '''
        «IF !getUniqueFields.empty»
            «FOR udf : getUniqueFields»
                #[UniqueEntity(fields: '«udf.name.formatForCode»', ignoreNull: «udf.nullable.displayBool»)]
            «ENDFOR»
        «ENDIF»
        «IF slugUnique && hasSluggableFields»
            #[UniqueEntity(fields: 'slug', ignoreNull: false)]
        «ENDIF»
        «IF !incoming.filter[unique].empty»
            «FOR rel : incoming.filter[unique]»
                «val aliasName = rel.getRelationAliasName(false).toFirstLower»
                #[UniqueEntity(fields: '«aliasName.formatForCode»', ignoreNull: «rel.nullable.displayBool»)]
            «ENDFOR»
        «ENDIF»
        «IF !outgoing.filter[unique].empty»
            «FOR rel : outgoing.filter[unique]»
                «val aliasName = rel.getRelationAliasName(true).toFirstLower»
                #[UniqueEntity(fields: '«aliasName.formatForCode»', ignoreNull: «rel.nullable.displayBool»)]
            «ENDFOR»
        «ENDIF»
    '''
}
