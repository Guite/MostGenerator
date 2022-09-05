package org.zikula.modulestudio.generator.cartridges.zclassic.models.business

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityIndex
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.IpAddressScope
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringIsbnStyle
import de.guite.modulestudio.metamodel.StringIssnStyle
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import java.math.BigInteger
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.EntityIndexExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class ValidationConstraints {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension EntityIndexExtensions = new EntityIndexExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def dispatch fieldAnnotations(DerivedField it) {
    }

    def private fieldAnnotationsMandatory(DerivedField it) '''
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

    def private fieldAnnotationsNumeric(DerivedField it) '''
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
            «IF !notOnlyNumericInteger»
                #[Assert\NotEqualTo(value: 0)]
            «ENDIF»
        «/*ELSEIF !nullable»
            #[Assert\NotNull]
        */»«ENDIF»
    '''
    def dispatch fieldAnnotations(AbstractIntegerField it) '''
        «IF null === entity
         || (
            entity.incoming.filter(JoinRelationship).filter[r|r.targetField == name].empty
             && entity.outgoing.filter(JoinRelationship).filter[r|r.sourceField == name].empty
         )»
            «fieldAnnotationsInteger»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(IntegerField it) '''
        «IF null === entity
         || (
            entity.incoming.filter(JoinRelationship).filter[r|r.targetField == name].empty
             && entity.outgoing.filter(JoinRelationship).filter[r|r.sourceField == name].empty
         )»
            «fieldAnnotationsInteger»
            «IF !notOnlyNumericInteger»
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
        «IF null !== regexp && !regexp.empty»
            #[Assert\Regex(pattern: '«regexp»'«IF regexpOpposite», match: false«ENDIF»)]
        «ENDIF»
    '''

    def dispatch fieldAnnotations(AbstractStringField it) {
    }
    def dispatch fieldAnnotations(StringField it) '''
        «fieldAnnotationsString»
        «IF mandatory»
            #[Assert\Length(min: «minLength», max: «length»)]
            «IF fixed && minLength != length»
                #[Assert\Length(min: «length», max: «length»)]
            «ENDIF»
        «ELSE»
            #[Assert\AtLeastOneOf(
                constraints: [
                    new Assert\Blank(),
                    new Assert\Length(min: «minLength», max: «length»),
                ]
            )]
            «IF fixed && minLength != length»
                #[Assert\AtLeastOneOf(
                    constraints: [
                        new Assert\Blank(),
                        new Assert\Length(min: «length», max: «length»),
                    ]
                )]
            «ENDIF»
        «ENDIF»
        «IF role == StringRole.BIC»
            «IF null !== entity && !entity.getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.IBAN]].flatten.empty»
                #[Assert\Bic(ibanPropertyPath: '«entity.getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.IBAN]].flatten.head.name.formatForCode»')]
            «ELSEIF null !== varContainer && !varContainer.fields.filter(StringField).filter[role == StringRole.IBAN].empty»
                #[Assert\Bic(ibanPropertyPath: '«varContainer.fields.filter(StringField).filter[role == StringRole.IBAN].head.name.formatForCode»')]
            «ELSE»
                #[Assert\Bic]
            «ENDIF»
        «ELSEIF role == StringRole.COLOUR»
            #[Assert\Regex(pattern: '/^#?(([a-fA-F0-9]{3}){1,2})$/', message: 'This value must be a valid html colour code [#123 or #123456].')]
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
        «ELSEIF role == StringRole.LANGUAGE»
            #[Assert\Language]
        «ELSEIF role == StringRole.LOCALE»
            #[Assert\Locale]
        «ELSEIF isbn != StringIsbnStyle.NONE»
            #[Assert\Isbn(«IF isbn != StringIsbnStyle.ALL»type: '«IF isbn == StringIsbnStyle.ISBN10»isbn10«ELSEIF isbn == StringIsbnStyle.ISBN13»isbn13«ENDIF»'«ENDIF»)]
        «ELSEIF issn != StringIssnStyle.NONE»
            #[Assert\Issn(caseSensitive: «(issn == StringIssnStyle.CASE_SENSITIVE || issn == StringIssnStyle.STRICT).displayBool», requireHyphen: «(issn == StringIssnStyle.REQUIRE_HYPHEN || issn == StringIssnStyle.STRICT).displayBool»)]
        «ELSEIF ipAddress != IpAddressScope.NONE»
            #[Assert\Ip(version: '«ipAddress.ipScopeAsConstant»')]
        «ELSEIF role == StringRole.TIME_ZONE»
            #[Assert\Timezone]
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
    def dispatch fieldAnnotations(EmailField it) '''
        «fieldAnnotationsString»
        «lengthAnnotationString(length)»
        «IF mandatory»
            #[Assert\Email(mode: '«validationMode.validationModeAsString»')]
        «ENDIF»
    '''
    def dispatch fieldAnnotations(UrlField it) '''
        «fieldAnnotationsString»
        «lengthAnnotationString(length)»
        #[Assert\Url]
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
        if (!mimeTypes.empty && '*' != mimeTypes) {
            val mimeTypesList = mimeTypes.replaceAll(', ', ',').split(',')
            var mimeTypeString = '\'' + mimeTypesList.join('\', \'') + '\''
            constraints += '''mimeTypes: [«mimeTypeString»]'''
        }

        constraints
    }
    def private getUploadImageConstraints(UploadField it) {
        val constraints = newArrayList

        if (minWidth > 0) {
            constraints += '''minWidth: «minWidth»'''
        }
        if (maxWidth > 0) {
            constraints += '''maxWidth: «maxWidth»'''
        }
        if (minHeight > 0) {
            constraints += '''minHeight: «minHeight»'''
        }
        if (maxHeight > 0) {
            constraints += '''maxHeight: «maxHeight»'''
        }
        if (minPixels > 0) {
            constraints += '''minPixels: «minPixels»'''
        }
        if (maxPixels > 0) {
            constraints += '''maxPixels: «maxPixels»'''
        }
        if (minRatio > 0) {
            constraints += '''minRatio: «minRatio»'''
        }
        if (maxRatio > 0) {
            constraints += '''maxRatio: «maxRatio»'''
        }
        if (!allowSquare) {
            constraints += 'allowSquare: false'
        }
        if (!allowLandscape) {
            constraints += 'allowLandscape: false'
        }
        if (!allowPortrait) {
            constraints += 'allowPortrait: false'
        }
        if (detectCorrupted) {
            constraints += 'detectCorrupted: true'
        }

        constraints
    }
    def dispatch fieldAnnotations(ListField it) '''
        «fieldAnnotationsMandatory»
        #[«application.name.formatForCodeCapital»Assert\ListEntry(entityName: '«IF null !== entity»«entity.name.formatForCode»«ELSE»appSettings«ENDIF»', propertyName: '«name.formatForCode»', multiple: «multiple.displayBool»«IF multiple»«IF min > 0», min: «min»«ENDIF»«IF max > 0», max: «max»«ENDIF»«ENDIF»)]
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
            «IF endDate»
                «IF mandatory»
                    «IF null !== entity && entity.hasStartDateField»
                        #[Assert\GreaterThan(propertyPath: '«entity.getStartDateField.name.formatForCode»', message: 'The start must be before the end.')]
                    «ELSEIF null !== varContainer && varContainer.hasStartDateField»
                        #[Assert\GreaterThan(propertyPath: '«varContainer.getStartDateField.name.formatForCode»', message: 'The start must be before the end.')]
                    «ENDIF»
                «ELSE»
                    «IF null !== entity && entity.hasStartDateField»
                        #[Assert\Expression('«IF !mandatory»!value or «ENDIF»value > this.get«entity.getStartDateField.name.formatForCodeCapital»()', message: 'The start must be before the end.')]
                    «ELSEIF null !== varContainer && varContainer.hasStartDateField»
                        #[Assert\Expression('«IF !mandatory»!value or «ENDIF»value > this.get«varContainer.getStartDateField.name.formatForCodeCapital»()', message: 'The start must be before the end.')]
                    «ENDIF»
                «ENDIF»
            «ENDIF»
        «ELSEIF isTimeField»
            #[Assert\Time]
        «ENDIF»
        «IF null !== validatorAddition && !validatorAddition.empty»
            #[Assert\«validatorAddition»]
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

    def classAnnotations(DataObject it) '''
        «IF !getUniqueDerivedFields.filter[!primaryKey].empty»
            «FOR udf : getUniqueDerivedFields.filter[!primaryKey]»
                #[UniqueEntity(fields: '«udf.name.formatForCode»', ignoreNull: «udf.nullable.displayBool»)]
            «ENDFOR»
        «ENDIF»
        «IF it instanceof Entity && (it as Entity).slugUnique && (it as Entity).hasSluggableFields»
            #[UniqueEntity(fields: 'slug', ignoreNull: false)]
        «ENDIF»
        «IF !getIncomingJoinRelations.filter[unique].empty»
            «FOR rel : getIncomingJoinRelations.filter[unique]»
                «val aliasName = rel.getRelationAliasName(false).toFirstLower»
                #[UniqueEntity(fields: '«aliasName.formatForCode»', ignoreNull: «rel.nullable.displayBool»)]
            «ENDFOR»
        «ENDIF»
        «IF !getOutgoingJoinRelations.filter[unique].empty»
            «FOR rel : getOutgoingJoinRelations.filter[unique]»
                «val aliasName = rel.getRelationAliasName(true).toFirstLower»
                #[UniqueEntity(fields: '«aliasName.formatForCode»', ignoreNull: «rel.nullable.displayBool»)]
            «ENDFOR»
        «ENDIF»
        «IF it instanceof Entity && !(it as Entity).getUniqueIndexes.empty»
            «FOR index : (it as Entity).getUniqueIndexes»
                «index.uniqueAnnotation»
            «ENDFOR»
        «ENDIF»
    '''

    def private uniqueAnnotation(EntityIndex it) '''
        #[UniqueEntity(fields: [«FOR item : items SEPARATOR ', '»'«item.indexItemForSymfonyValidator»'«ENDFOR»], ignoreNull: «(!includesNotNullableItem).displayBool»)]
    '''
}
