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
import de.guite.modulestudio.metamodel.ObjectField
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
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ValidationConstraints {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def dispatch fieldAnnotations(DerivedField it) {
    }

    def private fieldAnnotationsMandatory(DerivedField it) '''
        «IF mandatory»
            «' '»* @Assert\NotBlank
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull
        «ENDIF»
    '''

    def dispatch fieldAnnotations(BooleanField it) '''
        «IF mandatory»
            «' '»* @Assert\IsTrue(message="This option is mandatory.")
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull
        «ENDIF»
        «' '»* @Assert\Type(type="bool")
    '''

    def private fieldAnnotationsNumeric(DerivedField it) '''
        «' '»* @Assert\Type(type="numeric")
        «IF mandatory»
            «' '»* @Assert\NotBlank
            «' '»* @Assert\NotEqualTo(value=0)
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull
        «ENDIF»
    '''

    def private fieldAnnotationsInteger(AbstractIntegerField it) '''
        «IF !notOnlyNumericInteger»
            «' '»* @Assert\Type(type="integer")
        «ENDIF»
        «IF mandatory && (!primaryKey || (null !== entity && entity.getVersionField == this))»
            «' '»* @Assert\NotBlank
            «IF !notOnlyNumericInteger»
                «' '»* @Assert\NotEqualTo(value=0)
            «ENDIF»
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull
        «ENDIF»
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
                    «' '»* @Assert\Range(min=«minValue», max=«maxValue»)
                «ELSEIF minValue.toString != '0'»
                    «' '»* @Assert\GreaterThanOrEqual(value=«minValue»)
                    «' '»* @Assert\LessThan(value=«BigInteger.valueOf((10 ** length) as long)»)
                «ELSEIF maxValue.toString != '0'»
                    «' '»* @Assert\LessThanOrEqual(value=«maxValue»)
                «ELSE»
                    «' '»* @Assert\LessThan(value=«BigInteger.valueOf((10 ** length) as long)»)
                «ENDIF»
            «ENDIF»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(NumberField it) '''
        «fieldAnnotationsNumeric»
        «IF minValue.toString != '0.0' && maxValue.toString != '0.0'»
            «' '»* @Assert\Range(min=«minValue», max=«maxValue»)
        «ELSEIF minValue.toString != '0.0'»
            «' '»* @Assert\GreaterThanOrEqual(value=«minValue»)
            «' '»* @Assert\LessThan(value=«BigInteger.valueOf((10 ** length) as long)»)
        «ELSEIF maxValue.toString != '0.0'»
            «' '»* @Assert\LessThanOrEqual(value=«maxValue»)
        «ELSE»
            «' '»* @Assert\LessThan(value=«BigInteger.valueOf((10 ** length) as long)»)
        «ENDIF»
    '''
    def dispatch fieldAnnotations(UserField it) '''
        «IF mandatory && !primaryKey»
            «' '»* @Assert\NotBlank
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull
        «ENDIF»
    '''

    def private fieldAnnotationsString(AbstractStringField it) '''
        «fieldAnnotationsMandatory»
        «IF null !== regexp && !regexp.empty»
            «' '»* @Assert\Regex(pattern="«regexp»"«IF regexpOpposite», match=false«ENDIF»)
        «ENDIF»
    '''

    def dispatch fieldAnnotations(AbstractStringField it) {
    }
    def dispatch fieldAnnotations(StringField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»"«IF application.targets('3.0')», allowEmptyString="«(if (mandatory) false else true).displayBool»"«ENDIF»)
        «IF fixed && minLength != length»
            «' '»* @Assert\Length(min="«length»", max="«length»"«IF application.targets('3.0')», allowEmptyString="«(if (mandatory) false else true).displayBool»"«ENDIF»)
        «ENDIF»
        «IF role == StringRole.BIC»
            «IF application.targets('3.0')»
                «IF null !== entity && !entity.getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.IBAN]].flatten.empty»
                    «' '»* @Assert\Bic(ibanPropertyPath = "«entity.getSelfAndParentDataObjects.map[fields.filter(StringField).filter[role == StringRole.IBAN]].flatten.head.name.formatForCode»")
                «ELSEIF null !== varContainer && !varContainer.fields.filter(StringField).filter[role == StringRole.IBAN].empty»
                    «' '»* @Assert\Bic(ibanPropertyPath = "«varContainer.fields.filter(StringField).filter[role == StringRole.IBAN].head.name.formatForCode»")
                «ELSE»
                    «' '»* @Assert\Bic
                «ENDIF»
            «ELSE»
                «' '»* @Assert\Bic
            «ENDIF»
        «ELSEIF role == StringRole.COLOUR»
            «' '»* @Assert\Regex(pattern="/^#?(([a-fA-F0-9]{3}){1,2})$/", message="This value must be a valid html colour code [#123 or #123456].")
        «ELSEIF role == StringRole.COUNTRY»
            «' '»* @Assert\Country
        «ELSEIF role == StringRole.CREDIT_CARD»
            «' '»* @Assert\Luhn(message="Please check your credit card number.")
            «' '»* @Assert\CardScheme(schemes={"AMEX", "CHINA_UNIONPAY", "DINERS", "DISCOVER", "INSTAPAYMENT", "JCB", "LASER", "MAESTRO", "MASTERCARD"«IF application.targets('3.0')», "UATP"«ENDIF», "VISA"})
        «ELSEIF role == StringRole.CURRENCY»
            «' '»* @Assert\Currency
        «ELSEIF role == StringRole.HOSTNAME && application.targets('3.0')»
            «' '»* @Assert\Hostname
        «ELSEIF role == StringRole.IBAN»
            «' '»* @Assert\Iban
        «ELSEIF role == StringRole.LANGUAGE»
            «' '»* @Assert\Language
        «ELSEIF role == StringRole.LOCALE»
            «' '»* @Assert\Locale
        «ELSEIF isbn != StringIsbnStyle.NONE»
            «' '»* @Assert\Isbn(«IF isbn != StringIsbnStyle.ALL»type="«IF isbn == StringIsbnStyle.ISBN10»isbn10«ELSEIF isbn == StringIsbnStyle.ISBN13»isbn13«ENDIF»"«ENDIF»)
        «ELSEIF issn != StringIssnStyle.NONE»
            «' '»* @Assert\Issn(caseSensitive=«(issn == StringIssnStyle.CASE_SENSITIVE || issn == StringIssnStyle.STRICT).displayBool», requireHyphen=«(issn == StringIssnStyle.REQUIRE_HYPHEN || issn == StringIssnStyle.STRICT).displayBool»)
        «ELSEIF ipAddress != IpAddressScope.NONE»
            «' '»* @Assert\Ip(version="«ipAddress.ipScopeAsConstant»")
        «ELSEIF role == StringRole.TIME_ZONE && application.targets('3.0')»
            «' '»@Assert\Timezone
        «ELSEIF role == StringRole.UUID»
            «' '»* @Assert\Uuid(strict=true)
        «ENDIF»
    '''
    def dispatch fieldAnnotations(TextField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»"«IF application.targets('3.0')», allowEmptyString="«(if (mandatory) false else true).displayBool»"«ENDIF»)
    '''
    def dispatch fieldAnnotations(EmailField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»"«IF application.targets('3.0')», allowEmptyString="«(if (mandatory) false else true).displayBool»"«ENDIF»)
        «IF mandatory»
            «IF application.targets('3.0')»
                «' '»* @Assert\Email(mode="«validationMode.validationModeAsString»")
            «ELSE»
                «' '»* @Assert\Email(checkMX=«checkMX.displayBool», checkHost=«checkHost.displayBool»)
            «ENDIF»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(UrlField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»"«IF application.targets('3.0')», allowEmptyString="«(if (mandatory) false else true).displayBool»"«ENDIF»)
        «IF application.targets('3.0')»
            «' '»* @Assert\Url
        «ELSE»
            «' '»* @Assert\Url(checkDNS=«IF application.targets('2.0') && checkDNS»'ANY'«ELSE»«checkDNS.displayBool»«ENDIF»«IF checkDNS», dnsMessage = "The host '{{ value }}' could not be resolved."«ENDIF»)
        «ENDIF»
    '''
    def dispatch fieldAnnotations(UploadField it) '''
        «fieldAnnotationsString»
        «' '»* @Assert\Length(min="«minLength»", max="«length»"«IF application.targets('3.0')», allowEmptyString="«(if (mandatory) false else true).displayBool»"«ENDIF»)
    '''
    def uploadFileAnnotations(UploadField it) '''
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

        if (!maxSize.empty) {
            constraints += '''maxSize = "«maxSize»"'''
        }
        if (!mimeTypes.empty && '*' != mimeTypes) {
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
        if (application.targets('2.0')) {
            if (minPixels > 0) {
                constraints += '''minPixels = «minPixels»'''
            }
            if (maxPixels > 0) {
                constraints += '''maxPixels = «maxPixels»'''
            }
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
        if (detectCorrupted && application.targets('2.0')) {
            constraints += 'detectCorrupted = true'
        }

        constraints
    }
    def dispatch fieldAnnotations(ListField it) '''
        «fieldAnnotationsMandatory»
        «' '»* @«application.name.formatForCodeCapital»Assert\ListEntry(entityName="«IF null !== entity»«entity.name.formatForCode»«ELSE»appSettings«ENDIF»", propertyName="«name.formatForCode»", multiple=«multiple.displayBool»«IF multiple»«IF min > 0», min=«min»«ENDIF»«IF max > 0», max=«max»«ENDIF»«ENDIF»)
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
    def dispatch fieldAnnotations(DatetimeField it) '''
        «fieldAnnotationsMandatory»
        «IF isDateTimeField || isDateField»
            «IF !application.targets('3.0')»«/* no constraint if the underlying model is type hinted already */»
                «IF isDateTimeField»
                    «' '»* @Assert\DateTime
                «ELSEIF isDateField»
                    «' '»* @Assert\Date
                «ENDIF»
            «ENDIF»
            «IF past»
                «' '»* @Assert\LessThan("now", message="Please select a value in the past.")
            «ELSEIF future»
                «' '»* @Assert\GreaterThan("now", message="Please select a value in the future.")
            «ENDIF»
            «IF endDate»
                «IF mandatory && application.targets('2.0')»
                    «IF null !== entity && entity.hasStartDateField»
                        «' '»* @Assert\GreaterThan(propertyPath="«entity.getStartDateField.name.formatForCode»", message="The start must be before the end.")
                    «ELSEIF null !== varContainer && varContainer.hasStartDateField»
                        «' '»* @Assert\GreaterThan(propertyPath="«varContainer.getStartDateField.name.formatForCode»", message="The start must be before the end.")
                    «ENDIF»
                «ELSE»
                    «IF null !== entity && entity.hasStartDateField»
                        «' '»* @Assert\Expression("«IF !mandatory»!value or «ENDIF»value > this.get«entity.getStartDateField.name.formatForCodeCapital»()", message="The start must be before the end.")
                    «ELSEIF null !== varContainer && varContainer.hasStartDateField»
                        «' '»* @Assert\Expression("«IF !mandatory»!value or «ENDIF»value > this.get«varContainer.getStartDateField.name.formatForCodeCapital»()", message="The start must be before the end.")
                    «ENDIF»
                «ENDIF»
            «ENDIF»
        «ELSEIF isTimeField»
            «' '»* @Assert\Time
        «ENDIF»
        «IF null !== validatorAddition && !validatorAddition.empty»
            «' '»* @Assert\«validatorAddition»
        «ENDIF»
    '''

    def dispatch validationMethods(UserField it) '''
        /**
         * Checks whether the «name.formatForCode» field contains a valid user reference.
         * This method is used for validation.
         *
         * @Assert\IsTrue(message="This value must be a valid user id.")
         «IF !application.targets('3.0')»
         *
         * @return boolean True if data is valid else false
         «ENDIF»
         */
        public function is«name.formatForCodeCapital»UserValid()«IF application.targets('3.0')»: bool«ENDIF»
        {
            return «IF !mandatory && nullable»null === $this['«name.formatForCode»'] || «ENDIF»$this['«name.formatForCode»'] instanceof UserEntity;
        }
    '''

    def dispatch validationMethods(DatetimeField it) '''
        «IF isTimeField»
        «IF past»
            /**
             * Checks whether the «name.formatForCode» field value is in the past.
             * This method is used for validation.
             *
             * @Assert\IsTrue(message="This value must be a time in the past.")
             «IF !application.targets('3.0')»
             *
             * @return boolean True if data is valid else false
             «ENDIF»
             */
            public function is«name.formatForCodeCapital»TimeValidPast()«IF application.targets('3.0')»: bool«ENDIF»
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
             «IF !application.targets('3.0')»
             *
             * @return boolean True if data is valid else false
             «ENDIF»
             */
            public function is«name.formatForCodeCapital»TimeValidFuture()«IF application.targets('3.0')»: bool«ENDIF»
            {
                $format = 'His';

                return «IF !mandatory»!$this['«name.formatForCode»'] || «ENDIF»$this['«name.formatForCode»']->format($format) > date($format);
            }
        «ENDIF»
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
