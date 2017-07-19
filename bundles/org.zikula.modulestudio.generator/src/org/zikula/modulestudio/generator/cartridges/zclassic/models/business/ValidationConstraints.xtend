package org.zikula.modulestudio.generator.cartridges.zclassic.models.business

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityIndex
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.IpAddressScope
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringIsbnStyle
import de.guite.modulestudio.metamodel.StringIssnStyle
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import java.math.BigInteger
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ValidationConstraints {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def dispatch fieldAnnotations(DerivedField it) {
    }

    def private fieldAnnotationsMandatory(DerivedField it) '''
        «IF mandatory»
            «' '»* @Assert\NotBlank()
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull()
        «ENDIF»
    '''

    def dispatch fieldAnnotations(BooleanField it) '''
        «IF mandatory»
            «' '»* @Assert\IsTrue(message="This option is mandatory.")
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull()
        «ENDIF»
        «' '»* @Assert\Type(type="bool")
    '''

    def private fieldAnnotationsNumeric(DerivedField it) '''
        «' '»* @Assert\Type(type="numeric")
        «IF mandatory»
            «' '»* @Assert\NotBlank()
            «' '»* @Assert\NotEqualTo(value=0)
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull()
        «ENDIF»
    '''

    def private fieldAnnotationsInteger(AbstractIntegerField it) '''
        «IF !(it instanceof UserField)»
            «' '»* @Assert\Type(type="integer")
        «ENDIF»
        «IF mandatory && (!primaryKey || entity.getVersionField == this)»
            «' '»* @Assert\NotBlank()
            «IF !(it instanceof UserField)»
                «' '»* @Assert\NotEqualTo(value=0)
            «ENDIF»
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull()
        «ENDIF»
    '''
    def dispatch fieldAnnotations(AbstractIntegerField it) '''
        «IF entity.incoming.filter(JoinRelationship).filter[r|r.targetField == name].empty
         && entity.outgoing.filter(JoinRelationship).filter[r|r.sourceField == name].empty»
            «fieldAnnotationsInteger»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(IntegerField it) '''
        «IF entity.incoming.filter(JoinRelationship).filter[r|r.targetField == name].empty
         && entity.outgoing.filter(JoinRelationship).filter[r|r.sourceField == name].empty»
            «fieldAnnotationsInteger»
            «IF minValue.toString != '0' && maxValue.toString != '0'»
                «' '»* @Assert\Range(min=«minValue», max=«maxValue»)
            «ELSEIF minValue.toString != '0'»
                «' '»* @Assert\GreaterThanOrEqual(value=«minValue»)
            «ELSEIF maxValue.toString != '0'»
                «' '»* @Assert\LessThanOrEqual(value=«maxValue»)
            «ELSE»
                «' '»* @Assert\LessThan(value=«BigInteger.valueOf((10 ** length) as long)»)
            «ENDIF»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(DecimalField it) '''
        «fieldAnnotationsNumeric»
        «IF minValue.toString != '0.0'»
            «' '»* @Assert\GreaterThanOrEqual(value=«minValue»)
        «ENDIF»
        «IF maxValue.toString != '0.0'»
            «' '»* @Assert\LessThanOrEqual(value=«maxValue»)
        «ELSE»
            «' '»* @Assert\LessThan(value=«BigInteger.valueOf((10 ** length) as long)»)
        «ENDIF»
    '''
    def dispatch fieldAnnotations(FloatField it) '''
        «fieldAnnotationsNumeric»
        «IF minValue.toString != '0.0'»
            «' '»* @Assert\GreaterThanOrEqual(value=«minValue»)
        «ENDIF»
        «IF maxValue.toString != '0.0'»
            «' '»* @Assert\LessThanOrEqual(value=«maxValue»)
        «ELSE»
            «' '»* @Assert\LessThan(value=«BigInteger.valueOf((10 ** length) as long)»)
        «ENDIF»
    '''
    def dispatch fieldAnnotations(UserField it) '''
        «fieldAnnotationsInteger»
    '''

    def private fieldAnnotationsString(AbstractStringField it) '''
        «fieldAnnotationsMandatory»
        «IF nospace»
            «' '»* @Assert\Regex(pattern="/\s/", match=false, message="This value must not contain space chars.")
        «ENDIF»
        «IF null !== regexp && regexp != ''»
            «' '»* @Assert\Regex(pattern="«regexp»"«IF regexpOpposite», match=false«ENDIF»)
        «ENDIF»
    '''

    def dispatch fieldAnnotations(AbstractStringField it) {
    }
    def dispatch fieldAnnotations(StringField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»")
        «IF fixed»
            «' '»@Assert\Length(min="«length»", max="«length»")
        «ENDIF»
        «IF bic»
            «' '»* @Assert\Bic()
        «ELSEIF country»
            «' '»* @Assert\Country()
        «ELSEIF creditCard»
            «' '»* @Assert\Luhn(message="Please check your credit card number.")
            «' '»* @Assert\CardScheme(schemes={"AMEX", "CHINA_UNIONPAY", "DINERS", "DISCOVER", "INSTAPAYMENT", "JCB", "LASER", "MAESTRO", "MASTERCARD", "VISA"})
        «ELSEIF currency»
            «' '»* @Assert\Currency()
        «ELSEIF language»
            «' '»* @Assert\Language()
        «ELSEIF locale»
            «' '»* @Assert\Locale()
        «ELSEIF htmlcolour»
            «' '»* @Assert\Regex(pattern="/^#?(([a-fA-F0-9]{3}){1,2})$/", message="This value must be a valid html colour code [#123 or #123456].")
        «ELSEIF iban»
            «' '»* @Assert\Iban()
        «ELSEIF isbn != StringIsbnStyle.NONE»
            «' '»* @Assert\Isbn(isbn10=«(isbn == StringIsbnStyle.ISBN10 || isbn == StringIsbnStyle.ALL).displayBool», isbn13=«(isbn == StringIsbnStyle.ISBN13 || isbn == StringIsbnStyle.ALL).displayBool»)
        «ELSEIF issn != StringIssnStyle.NONE»
            «' '»* @Assert\Issn(caseSensitive=«(issn == StringIssnStyle.CASE_SENSITIVE || issn == StringIssnStyle.STRICT).displayBool», requireHyphen=«(issn == StringIssnStyle.REQUIRE_HYPHEN || issn == StringIssnStyle.STRICT).displayBool»)
        «ELSEIF ipAddress != IpAddressScope.NONE»
            «' '»* @Assert\Ip(version="«ipAddress.ipScopeAsConstant»")
        «ELSEIF uuid»
            «' '»* @Assert\Uuid(strict=true)
        «ENDIF»
    '''
    def dispatch fieldAnnotations(TextField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»")
    '''
    def dispatch fieldAnnotations(EmailField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»")
        «IF mandatory»
            «' '»* @Assert\Email(checkMX=«checkMX.displayBool», checkHost=«checkHost.displayBool»)
        «ENDIF»
    '''
    def dispatch fieldAnnotations(UrlField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»")
        «' '»* @Assert\Url(checkDNS=«checkDNS.displayBool»«IF checkDNS», dnsMessage = "The host '{{ value }}' could not be resolved."«ENDIF»«/* , protocols={"http", "https"} */»)
    '''
    def dispatch fieldAnnotations(UploadField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»")
        «' '»* @Assert\File(
            «FOR constraint : getUploadConstraints»
        «' '»*    «constraint»«IF constraint != getUploadConstraints.last»,«ENDIF»
            «ENDFOR»
        «' '»* )
        «IF isOnlyImageField»
            «' '»* @Assert\Image(
                «FOR constraint : getUploadImageConstraints»
            «' '»*    «constraint»«IF constraint != getUploadImageConstraints.last»,«ENDIF»
                «ENDFOR»
            «' '»* )
        «ENDIF»
    '''
    def private getUploadConstraints(UploadField it) {
        val constraints = newArrayList

        if (maxSize != '') {
            constraints += '''maxSize = "«maxSize»"'''
        }
        if (mimeTypes != '') {
            val mimeTypesList = mimeTypes.replaceAll(', ', ',').split(',')
            var mimeTypeString = '"' + mimeTypesList.join('", "') + '"'
            constraints += '''mimeTypes = {«mimeTypeString»}'''
        }

        constraints
    }
    def private getUploadImageConstraints(UploadField it) {
        val constraints = newArrayList

        if (minWidth > 0) {
            constraints += '''minWidth = «minWidth»'''
        }
        if (maxWidth > 0) {
            constraints += '''maxWidth = «maxWidth»'''
        }
        if (minHeight > 0) {
            constraints += '''minHeight = «minHeight»'''
        }
        if (maxHeight > 0) {
            constraints += '''maxHeight = «maxHeight»'''
        }
        if (minRatio > 0) {
            constraints += '''minRatio = «minRatio»'''
        }
        if (maxRatio > 0) {
            constraints += '''maxRatio = «maxRatio»'''
        }
        if (!allowSquare) {
            constraints += 'allowSquare = false'
        }
        if (!allowLandscape) {
            constraints += 'allowLandscape = false'
        }
        if (!allowPortrait) {
            constraints += 'allowPortrait = false'
        }
        if (detectCorrupted && entity.application.targets('2.0')) {
            constraints += 'detectCorrupted = true'
        }

        constraints
    }
    def dispatch fieldAnnotations(ListField it) '''
        «fieldAnnotationsMandatory»
        «' '»* @«entity.application.name.formatForCodeCapital»Assert\ListEntry(entityName="«entity.name.formatForCode»", propertyName="«name.formatForCode»", multiple=«multiple.displayBool»«IF multiple»«IF min > 0», min=«min»«ENDIF»«IF max > 0», max=«max»«ENDIF»«ENDIF»)
    '''
    def dispatch fieldAnnotations(ArrayField it) '''
        «fieldAnnotationsMandatory»
        «' '»* @Assert\Type(type="array")
        «IF max > 0»
            «' '»* @Assert\Count(min="«min»", max="«max»")
        «ENDIF»
    '''
    def dispatch fieldAnnotations(ObjectField it) '''
        «fieldAnnotationsMandatory»
    '''
    def dispatch fieldAnnotations(AbstractDateField it) '''
        «fieldAnnotationsMandatory»
    '''
    def dispatch fieldAnnotations(DatetimeField it) '''
        «fieldAnnotationsMandatory»
        «' '»* @Assert\DateTime()
        «IF past»
            «' '»* @Assert\LessThan("now")
        «ELSEIF future»
            «' '»* @Assert\GreaterThan("now")
        «ENDIF»
        «IF endDate && null !== entity.getStartDateField»
            «' '»* @Assert\Expression("«IF !mandatory»!value or «ENDIF»value > this.get«entity.getStartDateField.name.formatForCodeCapital»()")
        «ENDIF»
        «IF null !== validatorAddition && validatorAddition != ''»
            «' '»* @Assert\«validatorAddition»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(DateField it) '''
        «fieldAnnotationsMandatory»
        «' '»* @Assert\Date()
        «IF past»
            «' '»* @Assert\LessThan("now")
        «ELSEIF future»
            «' '»* @Assert\GreaterThan("now")
        «ENDIF»
        «IF endDate && null !== entity.getStartDateField»
            «' '»* @Assert\Expression("«IF !mandatory»!value or «ENDIF»value > this.get«entity.getStartDateField.name.formatForCodeCapital»()")
        «ENDIF»
        «IF null !== validatorAddition && validatorAddition != ''»
            «' '»* @Assert\«validatorAddition»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(TimeField it) '''
        «fieldAnnotationsMandatory»
        «' '»* @Assert\Time()
        «IF null !== validatorAddition && validatorAddition != ''»
            «' '»* @Assert\«validatorAddition»
        «ENDIF»
    '''

    def dispatch validationMethods(UserField it) '''
        /**
         * Checks whether the «name.formatForCode» field contains a valid user reference.
         * This method is used for validation.
         *
         * @Assert\IsTrue(message="This value must be a valid user id.")
         *
         * @return boolean True if data is valid else false
         */
        public function is«name.formatForCodeCapital»UserValid()
        {
            return «IF !mandatory»null === $this['«name.formatForCode»'] || «ENDIF»$this['«name.formatForCode»'] instanceof UserEntity;
        }
    '''

    def dispatch validationMethods(TimeField it) '''
        «IF past»
            /**
             * Checks whether the «name.formatForCode» field value is in the past.
             * This method is used for validation.
             *
             * @Assert\IsTrue(message="This value must be a time in the past.")
             *
             * @return boolean True if data is valid else false
             */
            public function is«name.formatForCodeCapital»TimeValidPast()
            {
                $format = 'His';

                return «IF !mandatory»!$this['«name.formatForCode»'] || «ENDIF»$this['«name.formatForCode»']->format($format) < date($format);
            }
        «ELSEIF future»
            /**
             * Checks whether the «name.formatForCode» field value is in the future.
             * This method is used for validation.
             *
             * @Assert\IsTrue(message="This value must be a time in the future.")
             *
             * @return boolean True if data is valid else false
             */
            public function is«name.formatForCodeCapital»TimeValidFuture()
            {
                $format = 'His';

                return «IF !mandatory»!$this['«name.formatForCode»'] || «ENDIF»$this['«name.formatForCode»']->format($format) > date($format);
            }
        «ENDIF»
    '''

    def classAnnotations(DataObject it) '''
        «IF !getUniqueDerivedFields.filter[!primaryKey].empty»
            «FOR udf : getUniqueDerivedFields.filter[!primaryKey]»
                «' '»* @UniqueEntity(fields="«udf.name.formatForCode»", ignoreNull="«udf.nullable.displayBool»")
            «ENDFOR»
        «ENDIF»
        «IF it instanceof Entity && (it as Entity).slugUnique && (it as Entity).hasSluggableFields»
            «' '»* @UniqueEntity(fields="slug", ignoreNull="false")
        «ENDIF»
        «IF !getIncomingJoinRelations.filter[unique].empty»
            «FOR rel : getIncomingJoinRelations.filter[unique]»
                «val aliasName = rel.getRelationAliasName(false).toFirstLower»
                «' '»* @UniqueEntity(fields="«aliasName.formatForCode»", ignoreNull="«rel.nullable.displayBool»")
            «ENDFOR»
        «ENDIF»
        «IF !getOutgoingJoinRelations.filter[unique].empty»
            «FOR rel : getOutgoingJoinRelations.filter[unique]»
                «val aliasName = rel.getRelationAliasName(true).toFirstLower»
                «' '»* @UniqueEntity(fields="«aliasName.formatForCode»", ignoreNull="«rel.nullable.displayBool»")
            «ENDFOR»
        «ENDIF»
        «IF it instanceof Entity && !(it as Entity).getUniqueIndexes.empty»
            «FOR index : (it as Entity).getUniqueIndexes»
                «index.uniqueAnnotation»
            «ENDFOR»
        «ENDIF»
    '''

    def private uniqueAnnotation(EntityIndex it) '''
        «' '»* @UniqueEntity(fields={«FOR item : items SEPARATOR ', '»"«item.name.formatForCode»"«ENDFOR»}, ignoreNull="«(!includesNotNullableField).displayBool»")
    '''

    def private includesNotNullableField(EntityIndex it) {
        val nonNullableFields = entity.getDerivedFields.filter[!nullable]
        for (item : items) {
            if (!nonNullableFields.filter[item.name.equals(name)].empty) {
                return true
            }
        }
        false
    }
}
