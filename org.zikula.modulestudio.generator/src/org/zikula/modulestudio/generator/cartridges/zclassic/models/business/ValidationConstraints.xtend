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
        «' '»* @Assert\Type(type="integer")
        «IF mandatory && (!primaryKey || entity.hasCompositeKeys || entity.getVersionField == this)»
            «' '»* @Assert\NotBlank()
            «' '»* @Assert\NotEqualTo(value=0)
        «ELSEIF !nullable»
            «' '»* @Assert\NotNull()
        «ENDIF»
    '''
    def dispatch fieldAnnotations(AbstractIntegerField it) '''
        «IF entity.incoming.filter(JoinRelationship).filter[e|e.targetField == name].empty
         && entity.outgoing.filter(JoinRelationship).filter[e|e.sourceField == name].empty»
            «fieldAnnotationsInteger»
        «ENDIF»
    '''
    def dispatch fieldAnnotations(IntegerField it) '''
        «IF entity.incoming.filter(JoinRelationship).filter[e|e.targetField == name].empty
         && entity.outgoing.filter(JoinRelationship).filter[e|e.sourceField == name].empty»
            «fieldAnnotationsInteger»
            «IF minValue.toString != '0' && maxValue.toString != '0'»
                «' '»* @Assert\Range(min=«minValue», max=«maxValue»)
            «ELSEIF minValue.toString != '0'»
                «' '»* @Assert\GreaterThanOrEqual(value=«minValue»)
            «ELSEIF maxValue.toString != '0'»
                «' '»* @Assert\LessThanOrEqual(value=«maxValue»)
            «ENDIF»
            «' '»* @Assert\LessThan(value=«(10 ** length) as int», message="Length of field value must not be higher than «length».")) {
        «ENDIF»
    '''
    def dispatch fieldAnnotations(DecimalField it) '''
        «fieldAnnotationsNumeric»
        «IF minValue.toString != '0.0'»
            «' '»* @Assert\GreaterThanOrEqual(value=«minValue»)
        «ENDIF»
        «IF maxValue.toString != '0.0'»
            «' '»* @Assert\LessThanOrEqual(value=«maxValue»)
        «ENDIF»
        «' '»* @Assert\LessThan(value=«(10 ** (length + scale)) as int», message="Length of field value must not be higher than «length».")) {
    '''
    def dispatch fieldAnnotations(FloatField it) '''
        «fieldAnnotationsNumeric»
        «IF minValue.toString != '0.0'»
            «' '»* @Assert\GreaterThanOrEqual(value=«minValue»)
        «ENDIF»
        «IF maxValue.toString != '0.0'»
            «' '»* @Assert\LessThanOrEqual(value=«maxValue»)
        «ENDIF»
        «' '»* @Assert\LessThan(value=«(10 ** length) as int», message="Length of field value must not be higher than «length».")) {
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
        «IF country»
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
    '''
    def dispatch fieldAnnotations(ListField it) '''
        «fieldAnnotationsMandatory»
        «IF !multiple»
            «' '»* @Assert\Choice(callback="get«name.formatForCodeCapital»AllowedValues", multiple=«multiple.displayBool»«IF multiple»«IF min > 0», min=«min»«ENDIF»«IF max > 0», max=«max»«ENDIF»«ENDIF»)
        «ENDIF»
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

    def dispatch validationMethods(ListField it) '''
        «val app = entity.application»
        «IF !multiple»
            /**
             * Returns a list of possible choices for the «name.formatForCode» list field.
             * This method is used for validation.
             *
             * @return array List of allowed choices
             */
            public static function get«name.formatForCodeCapital»AllowedValues()
            {
                $serviceManager = ServiceUtil::getManager();
                «IF app.targets('1.3.x')»
                    $helper = new «app.appName»_Util_ListEntries($serviceManager);
                «ELSE»
                    $helper = $serviceManager->get('«app.appService».listentries_helper');
                «ENDIF»
                $listEntries = $helper->get«name.formatForCodeCapital»EntriesFor«entity.name.formatForCodeCapital»();

                $allowedValues = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                foreach ($listEntries as $entry) {
                    $allowedValues[] = $entry['value'];
                }

                return $allowedValues;
            }
        «ELSE»
            /**
             * @Assert\Callback()
             */
            public function is«name.formatForCodeCapital»ValueAllowed(ExecutionContextInterface $context)
            {
                $serviceManager = ServiceUtil::getManager();
                «IF app.targets('1.3.x')»
                    $helper = new «app.appName»_Util_ListEntries($serviceManager);
                «ELSE»
                    $helper = $serviceManager->get('«app.appService».listentries_helper');
                «ENDIF»
                $listEntries = $helper->get«name.formatForCodeCapital»EntriesFor«entity.name.formatForCodeCapital»();
                $dom = ZLanguage::getModuleDomain('«app.appName»');

                $allowedValues = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                foreach ($listEntries as $entry) {
                    $allowedValues[] = $entry['value'];
                }

                $selected = explode('###', $this->«name.formatForCode»);
                foreach ($selected as $value) {
                    if ($value == '') {
                        continue;
                    }
                    if (!in_array($value, $allowedValues, true)) {
                        $context->buildViolation(__('Invalid value provided', $dom))
                            ->atPath('«name.formatForCode»')
                            ->addViolation();
                    }
                }
            }
        «ENDIF»
    '''

    def dispatch validationMethods(UserField it) '''
        /**
         * Checks whether the «name.formatForCode» field contains a valid user id.
         * This method is used for validation.
         *
         * @Assert\IsTrue(message="This value must be a valid user id.")
         *
         * @return boolean True if data is valid else false
         */
        public function is«name.formatForCodeCapital»UserValid()
        {
            «IF !mandatory»
                if ($this['«name.formatForCode»'] < 1) {
                    return true;
                }
            «ENDIF»

            $uname = UserUtil::getVar('uname', $this['«name.formatForCode»']);

            return (!is_null($uname) && !empty($uname));
        }
    '''

    def dispatch validationMethods(DatetimeField it) '''
        «IF startDate»
            «val endDateField = entity.getEndDateField»
            «IF null !== endDateField»
                /**
                 * Checks whether the «name.formatForCode» value is earlier than the «endDateField.name.formatForCode» value.
                 * This method is used for validation.
                 *
                 * @Assert\IsTrue(message="The start date must be before the end date.")
                 *
                 * @return boolean True if data is valid else false
                 */
                public function is«name.formatForCodeCapital»Before«endDateField.name.formatForCodeCapital»()
                {
                    return ($this['«name.formatForCode»'] < $this['«endDateField.name.formatForCode»']);
                }
            «ENDIF»
        «ENDIF»
    '''

    def dispatch validationMethods(DateField it) '''
        «IF startDate»
            «val endDateField = entity.getEndDateField»
            «IF null !== endDateField»
                /**
                 * Checks whether the «name.formatForCode» value is earlier than the «endDateField.name.formatForCode» value.
                 * This method is used for validation.
                 *
                 * @Assert\IsTrue(message="The start date must be before the end date.")
                 *
                 * @return boolean True if data is valid else false
                 */
                public function is«name.formatForCodeCapital»Before«endDateField.name.formatForCodeCapital»()
                {
                    return ($this['«name.formatForCode»'] < $this['«endDateField.name.formatForCode»']);
                }
            «ENDIF»
        «ENDIF»
    '''

    def dispatch validationMethods(TimeField it) '''
        «IF mandatory»
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
                    return $this['«name.formatForCode»']->format($format) < date($format);
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
                    return $this['«name.formatForCode»']->format($format) > date($format);
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
        «var includesNotNullableField = false»
        «FOR item : items SEPARATOR ', '»
            «val referencedField = entity.getDerivedFields.filter[name == item.name]?.head»
            «IF null !== referencedField && !referencedField.nullable»
                «includesNotNullableField = true»
            «ENDIF»
        «ENDFOR»
        «' '»* @UniqueEntity(fields={«FOR item : items SEPARATOR ', '»"«item.name.formatForCode»"«ENDFOR»}, ignoreNull="«(!includesNotNullableField).displayBool»")
    '''
}
