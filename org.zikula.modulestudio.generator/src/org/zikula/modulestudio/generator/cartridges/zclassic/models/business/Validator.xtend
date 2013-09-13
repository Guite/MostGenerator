package org.zikula.modulestudio.generator.cartridges.zclassic.models.business

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.AbstractStringField
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validator {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Creates a base validator class encapsulating common checks.
     */
    def generateCommon(Application it, IFileSystemAccess fsa) {
        println("Generating base validator class")
        var fileName = 'Validator.php'
        if (!targets('1.3.5')) {
            fileName = 'Abstract' + fileName
        }
        fsa.generateFile(getAppSourceLibPath + 'Base/' + fileName, validatorCommonBaseFile)
        fsa.generateFile(getAppSourceLibPath + fileName, validatorCommonFile)
    }

    def private validatorCommonBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «validatorCommonBaseImpl»
    '''

    def private validatorCommonFile(Application it) '''
        «fh.phpFileHeader(it)»
        «validatorCommonImpl»
    '''

    def private validatorCommonBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Base;

            use UserUtil;
            use Zikula_AbstractBase;
            use Zikula_EntityAccess;
            use ZLanguage;

        «ENDIF»
        /**
         * Validator class for encapsulating common entity validation methods.
         *
         * This is the base validation class with general checks.
         */
        abstract class «IF targets('1.3.5')»«appName»_Base_Validator«ELSE»AbstractValidator«ENDIF» extends Zikula_AbstractBase
        {
            /**
             * @var Zikula_EntityAccess The entity instance which is treated by this validator.
             */
            protected $entity = null;

            /**
             * Constructor.
             *
             * @param Zikula_EntityAccess $entity The entity to be validated.
             */
            public function __construct(Zikula_EntityAccess $entity)
            {
                $this->entity = $entity;
            }

            /**
             * Checks if field value is a valid boolean.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidBoolean($fieldName)
            {
                return (is_bool($this->entity[$fieldName]));
            }

            /**
             * Checks if field value is a valid number.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidNumber($fieldName)
            {
                return (is_numeric($this->entity[$fieldName]));
            }

            /**
             * Checks if field value is a valid integer.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidInteger($fieldName)
            {
                $val = $this->entity[$fieldName];

                return ($val == intval($val));
            }

            /**
             * Checks if integer field value is not lower than a given value.
             *
             * @param string $fieldName The name of the property to be checked
             * @param int    $value     The maximum allowed value
             * @return boolean result of this check
             */
            public function isIntegerNotLowerThan($fieldName, $value)
            {
                return ($this->isValidInteger($fieldName) && $this->entity[$fieldName] >= $value);
            }

            /**
             * Checks if integer field value is not higher than a given value.
             *
             * @param string $fieldName The name of the property to be checked
             * @param int    $value     The maximum allowed value
             * @return boolean result of this check
             */
            public function isIntegerNotHigherThan($fieldName, $value)
            {
                return ($this->isValidInteger($fieldName) && $this->entity[$fieldName] <= $value);
            }

            /**
             * Checks if field value is a valid user id.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidUser($fieldName)
            {
                if (!$this->isValidInteger($fieldName)) {
                    return false;
                }
                $uname = UserUtil::getVar('uname', $this->entity[$fieldName]);

                return (!is_null($uname) && !empty($uname));
            }

            /**
             * Checks if numeric field value has a value other than 0.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isNumberNotEmpty($fieldName)
            {
                return $this->entity[$fieldName] != 0;
            }

            /**
             * Checks if string field value has a value other than ''.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isStringNotEmpty($fieldName)
            {
                return $this->entity[$fieldName] != '';
            }

            /**
             * Checks if numeric field value has a given minimum field length
             *
             * @param string $fieldName The name of the property to be checked
             * @param int    $length    The minimum length
             * @return boolean result of this check
             */
            public function isNumberNotShorterThan($fieldName, $length)
            {
                $minValue = pow(10, $length-1);

                return ($this->isValidNumber($fieldName) && $this->entity[$fieldName] > $minValue);
            }

            /**
             * Checks if numeric field value does fit into given field length.
             *
             * @param string $fieldName The name of the property to be checked
             * @param int    $length    The maximum allowed length
             * @return boolean result of this check
             */
            public function isNumberNotLongerThan($fieldName, $length)
            {
                $maxValue = pow(10, $length);

                return ($this->isValidNumber($fieldName) && $this->entity[$fieldName] < $maxValue);
            }

            /**
             * Checks if string field value has a given minimum field length.
             *
             * @param string $fieldName The name of the property to be checked
             * @param int    $length    The minimum length
             * @return boolean result of this check
             */
            public function isStringNotShorterThan($fieldName, $length)
            {
                return (strlen($this->entity[$fieldName]) >= $length);
            }

            /**
             * Checks if string field value does fit into given field length.
             *
             * @param string $fieldName The name of the property to be checked
             * @param int    $length    The maximum allowed length
             * @return boolean result of this check
             */
            public function isStringNotLongerThan($fieldName, $length)
            {
                return (strlen($this->entity[$fieldName]) <= $length);
            }

            /**
             * Checks if string field value does conform to given fixed field length.
             *
             * @param string $fieldName The name of the property to be checked
             * @param int    $length    The fixed length
             * @return boolean result of this check
             */
            public function isStringWithFixedLength($fieldName, $length)
            {
                return (strlen($this->entity[$fieldName]) == $length);
            }

            /**
             * Checks if string field value does not contain a given string.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param string  $keyword   The char or string to search for
             * @param boolean $caseSensitive Whether the search should be case sensitive or not (default false)
             * @return boolean result of this check
             */
            public function isStringNotContaining($fieldName, $keyword, $caseSensitive = false)
            {
                if ($caseSensitive === true) {
                    return (strstr($this->entity[$fieldName], $keyword) === false);
                }

                return (stristr($this->entity[$fieldName], $keyword) === false);
            }

            /**
             * Checks if string field value conforms to a given regular expression.
             *
             * @param string  $fieldName  The name of the property to be checked
             * @param string  $expression Regular expression string
             * @return boolean result of this check
             */
            public function isValidRegExp($fieldName, $expression)
            {
                return preg_match($expression, $this->entity[$fieldName]);
            }

            /**
             * Checks if string field value is a valid language code.
             *
             * @param string  $fieldName     The name of the property to be checked
             * @param boolean $onlyInstalled Whether to accept only installed languages (default false)
             * @return boolean result of this check
             */
            public function isValidLanguage($fieldName, $onlyInstalled = false)
            {
                $languageMap = ZLanguage::languagemap[);
                $result = in_array($this->entity[$fieldName], array_keys($languageMap));        
                if (!$result || !$onlyInstalled) {
                    return $result;
                } 
                $available = ZLanguage::getInstalledLanguages();

                return in_array($this->entity[$fieldName], $available);
            }

            /**
             * Checks if string field value is a valid country code.
             *
             * @param string  $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidCountry($fieldName)
            {
                $countryMap = ZLanguage::countrymap[);

                return in_array($this->entity[$fieldName], array_keys($countryMap));
            }

            /**
             * Checks if string field value is a valid html colour.
             *
             * @param string  $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidHtmlColour($fieldName)
            {
                $regex = '/^#?(([a-fA-F0-9]{3}){1,2})$/';

                return preg_match($regex, $this->entity[$fieldName]);
            }

            /**
             * Checks if field value is a valid email address.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidEmail($fieldName)
            {
                return filter_var($this->entity[$fieldName], FILTER_VALIDATE_EMAIL);
            }

            /**
             * Checks if field value is a valid url.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidUrl($fieldName)
            {
                return filter_var($this->entity[$fieldName], FILTER_VALIDATE_URL);
            }

            /**
             * Checks if field value is a valid DateTime instance.
             *
             * @param string $fieldName The name of the property to be checked
             * @return boolean result of this check
             */
            public function isValidDateTime($fieldName)
            {
                return ($this->entity[$fieldName] instanceof \DateTime);
            }

            /**
             * Checks if field value has a value in the past.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param string  $format    The date format used for comparison
             * @param boolean $mandatory Whether the property is mandatory or not.
             * @return boolean result of this check
             */
            protected function isDateTimeValueInPast($fieldName, $format, $mandatory = true)
            {
                if ($mandatory === false) {
                    return true;
                }

                return ($this->isValidDateTime($fieldName) && $this->entity[$fieldName]->format($format) < date($format));
            }

            /**
             * Checks if field value has a value in the future.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param string  $format    The date format used for comparison
             * @param boolean $mandatory Whether the property is mandatory or not.
             * @return boolean result of this check
             */
            protected function isDateTimeValueInFuture($fieldName, $format, $mandatory = true)
            {
                if ($mandatory === false) {
                    return true;
                }

                return ($this->isValidDateTime($fieldName) && $this->entity[$fieldName]->format($format) > date($format));
            }

            /**
             * Checks if field value is a datetime in the past.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param boolean $mandatory Whether the property is mandatory or not.
             * @return boolean result of this check
             */
            public function isDateTimeInPast($fieldName, $mandatory = true)
            {
                return $this->isDateTimeValueInPast($fieldName, 'U', $mandatory);
            }

            /**
             * Checks if field value is a datetime in the future.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param boolean $mandatory Whether the property is mandatory or not.
             * @return boolean result of this check
             */
            public function isDateTimeInFuture($fieldName, $mandatory = true)
            {
                return $this->isDateTimeValueInFuture($fieldName, 'U', $mandatory);
            }

            /**
             * Checks if field value is a date in the past.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param boolean $mandatory Whether the property is mandatory or not.
             * @return boolean result of this check
             */
            public function isDateInPast($fieldName, $mandatory = true)
            {
                return $this->isDateTimeValueInPast($fieldName, 'Ymd', $mandatory);
            }

            /**
             * Checks if field value is a date in the future.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param boolean $mandatory Whether the property is mandatory or not.
             * @return boolean result of this check
             */
            public function isDateInFuture($fieldName, $mandatory = true)
            {
                return $this->isDateTimeValueInFuture($fieldName, 'Ymd', $mandatory);
            }

            /**
             * Checks if field value is a time in the past.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param boolean $mandatory Whether the property is mandatory or not.
             * @return boolean result of this check
             */
            public function isTimeInPast($fieldName, $mandatory = true)
            {
                return $this->isDateTimeValueInPast($fieldName, 'His', $mandatory);
            }

            /**
             * Checks if field value is a time in the future.
             *
             * @param string  $fieldName The name of the property to be checked
             * @param boolean $mandatory Whether the property is mandatory or not.
             * @return boolean result of this check
             */
            public function isTimeInFuture($fieldName, $mandatory = true)
            {
                return $this->isDateTimeValueInFuture($fieldName, 'His', $mandatory);
            }
        }
    '''

    def private validatorCommonImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»;

            use «appNamespace»\Base\AbstractValidator as BaseAbstractValidator;

        «ENDIF»
        /**
         * Validator class for encapsulating common entity validation methods.
         *
         * This is the concrete validation class with general checks.
         */
        «IF targets('1.3.5')»
        class «appName»_Validator extends «appName»_Base_Validator
        «ELSE»
        class AbstractValidator extends BaseAbstractValidator
        «ENDIF»
        {
            // here you can add custom validation methods or override existing checks
        }
    '''

    /**
     * Creates a validator class for every Entity instance.
     */
    def generateWrapper(Entity it, Application app, IFileSystemAccess fsa) {
        println('Generating validator classes for entity "' + name.formatForDisplay + '"')
        val validatorPath = app.getAppSourceLibPath + 'Entity/Validator/'
        val validatorSuffix = (if (app.targets('1.3.5')) '' else 'Validator')
        val validatorFileName = name.formatForCodeCapital + validatorSuffix + '.php'
        if (!isInheriting) {
            fsa.generateFile(validatorPath + 'Base/' + validatorFileName, validatorBaseFile(app))
        }
        fsa.generateFile(validatorPath + validatorFileName, validatorFile(app))
    }

    def private validatorBaseFile(Entity it, Application app) '''
        «fh.phpFileHeader(app)»
        «validatorBaseImpl(app)»
    '''

    def private validatorFile(Entity it, Application app) '''
        «fh.phpFileHeader(app)»
        «validatorImpl(app)»
    '''

    def private validatorBaseImpl(Entity it, Application app) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity\Validator\Base;

            use «app.appNamespace»\AbstractValidator as BaseAbstractValidator;

            use ServiceUtil;
            use ZLanguage;

        «ENDIF»
        /**
         * Validator class for encapsulating entity validation methods.
         *
         * This is the base validation class for «name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Validator_Base_«name.formatForCodeCapital» extends «app.appName»_Validator
        «ELSE»
        class «name.formatForCodeCapital»Validator extends BaseAbstractValidator
        «ENDIF»
        {
            «validatorBaseImplBody(app, false)»
        }
    '''

    def private validatorImpl(Entity it, Application app) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity\Validator;

            «IF isInheriting»
                use «app.appNamespace»\Entity\Validator\«parentType.name.formatForCodeCapital»Validator as Base«parentType.name.formatForCodeCapital»Validator;
            «ELSE»
                use «app.appNamespace»\Entity\Validator\Base\«name.formatForCodeCapital»Validator as Base«name.formatForCodeCapital»Validator;
            «ENDIF»
            «IF isInheriting»

                use ServiceUtil;
                use ZLanguage;
            «ENDIF»

        «ENDIF»
        /**
         * Validator class for encapsulating entity validation methods.
         *
         * This is the concrete validation class for «name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Validator_«name.formatForCodeCapital» extends «IF isInheriting»«app.appName»_Entity_Validator_«parentType.name.formatForCodeCapital»«ELSE»«app.appName»_Entity_Validator_Base_«name.formatForCodeCapital»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital»Validator extends Base«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»Validator
        «ENDIF»
        {
            // here you can add custom validation methods or override existing checks
        «IF isInheriting»
            «validatorBaseImplBody(app, true)»
        «ENDIF»
        }
    '''

    def private validatorBaseImplBody(Entity it, Application app, Boolean isInheriting) '''
        /**
         * Performs all validation rules.
         *
         * @return mixed either array with error information or true on success
         */
        public function validateAll()
        {
            $errorInfo = array('message' => '', 'code' => 0, 'debugArray' => array());
            $dom = ZLanguage::getModuleDomain('«app.appName»');
            «IF isInheriting»
                parent::validateAll();
            «ENDIF» 
            «FOR df : getDerivedFields»
                «validationCalls(df)»
            «ENDFOR»
            «validationCallDateRange»
            «FOR udf : getUniqueDerivedFields.filter[!primaryKey]»
                «validationCallUnique(udf)»
            «ENDFOR»

            return true;
        }

        «checkForUniqueValues(app)»

        «fh.getterAndSetterMethods(app, 'entity', 'Zikula_EntityAccess', false, true, 'null', '')»
    '''

    def private checkForUniqueValues(Entity it, Application app) '''
        /**
         * Check for unique values.
         *
         * This method determines if there already exist «nameMultiple.formatForDisplay» with the same «name.formatForDisplay».
         *
         * @param string $fieldName The name of the property to be checked
         * @return boolean result of this check, true if the given «name.formatForDisplay» does not already exist
         */
        public function isUniqueValue($fieldName)
        {
            if ($this->entity[$fieldName] == '') {
                return false;
            }

            «IF app.targets('1.3.5')»
                $entityClass = '«app.appName»_Entity_«name.formatForCodeCapital»';
            «ELSE»
                $entityClass = '\\«app.vendor.formatForCodeCapital»\\«app.name.formatForCodeCapital»Module\\Entity\\«name.formatForCodeCapital»Entity';
            «ENDIF»
            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository($entityClass);

            $excludeid = $this->entity['«getFirstPrimaryKey.name.formatForCode»'];

            return $repository->detectUniqueState($fieldName, $this->entity[$fieldName], $excludeid);
        }
    '''


    def private dispatch validationCalls(DerivedField it) {
    }

    def private validationCallDateRange(Entity it) '''
        «val startDateField = getStartDateField»
        «val endDateField = getEndDateField»
        «IF startDateField !== null && endDateField !== null»
            if ($this->entity['«startDateField.name.formatForCode»'] > $this->entity['«endDateField.name.formatForCode»']) {
                $errorInfo['message'] = __f('Error! The start date (%1$s) must be before the end date (%2$s).', array('«startDateField.name.formatForDisplay»', '«endDateField.name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''

    def private validationCallUnique(DerivedField it) '''
        if (!$this->isUniqueValue('«name.formatForCode»')) {
            $errorInfo['message'] = __f('The %1$s %2$s is already assigned. Please choose another %1$s.', array('«name.formatForDisplay»', $this->entity['«name.formatForCode»']), $dom);
            return $errorInfo;
        }
    '''

    def private dispatch validationCalls(BooleanField it) '''
        if (!$this->isValidBoolean('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be a valid boolean (%s).', array('«name.formatForDisplay»'), $dom);
            return $errorInfo;
        }
    '''
/** replace by switch ? */
    def private validationCallsNumeric(DerivedField it) '''
        if (!$this->isValidNumber('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be numeric (%s).', array('«name.formatForDisplay»'), $dom);
            return $errorInfo;
        }
        «IF mandatory»
            if (!$this->isNumberNotEmpty('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must not be 0 (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''

    def private validationCallsInteger(AbstractIntegerField it) '''
        if (!$this->isValidInteger('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value may only contain digits (%s).', array('«name.formatForDisplay»'), $dom);
            return $errorInfo;
        }
        «IF mandatory && (!primaryKey || entity.hasCompositeKeys || entity.getVersionField == this)»
            if (!$this->isNumberNotEmpty('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must not be 0 (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(AbstractIntegerField it) {
        if (entity.incoming.filter(JoinRelationship).filter[e|e.targetField == name].empty
         && entity.outgoing.filter(JoinRelationship).filter[e|e.sourceField == name].empty)
            validationCallsInteger
    }
    def private dispatch validationCalls(IntegerField it) '''
        «IF entity.incoming.filter(JoinRelationship).filter[e|e.targetField == name].empty
         && entity.outgoing.filter(JoinRelationship).filter[e|e.sourceField == name].empty»
            «validationCallsInteger»
            «IF minValue.toString != '0'»
                if (!$this->isIntegerNotLowerThan('«name.formatForCode»', «minValue»)) {
                    $errorInfo['message'] = __f('Error! Field value must not be lower than %2$s (%1$s).', array('«name.formatForDisplay»', «minValue»), $dom);
                    return $errorInfo;
                }
            «ENDIF»
            «IF maxValue.toString != '0'»
                if (!$this->isIntegerNotHigherThan('«name.formatForCode»', «maxValue»)) {
                    $errorInfo['message'] = __f('Error! Field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «maxValue»), $dom);
                    return $errorInfo;
                }
            «ENDIF»
            if (!$this->isNumberNotLongerThan('«name.formatForCode»', «length»)) {
                $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «length»), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(DecimalField it) '''
        «validationCallsNumeric»
        if (!$this->isNumberNotLongerThan('«name.formatForCode»', «(length+scale)»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «(length+scale)»), $dom);
            return $errorInfo;
        }
    '''
    def private dispatch validationCalls(UserField it) '''
        «validationCallsInteger»
        if («IF !mandatory»$this->entity['«name.formatForCode»'] > 0 && «ENDIF»!$this->isValidUser('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be a valid user id (%s).', array('«name.formatForDisplay»'), $dom);
            return $errorInfo;
        }
    '''

    def private validationCallsString(AbstractStringField it) '''
        «IF mandatory»
            if (!$this->isStringNotEmpty('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must not be empty (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF nospace»
            if (!$this->isStringNotContaining('«name.formatForCode»', ' ')) {
                $errorInfo['message'] = __f('Error! Field value must not contain space chars (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF minLength > 0»
            if (!$this->isStringNotShorterThan('«name.formatForCode»', «minLength»)) {
                $errorInfo['message'] = __f('Error! Length of field value must not be smaller than %2$s (%1$s).', array('«name.formatForDisplay»', «minLength»), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF regexp !== null && regexp != ''»
            if (!$this->isValidRegExp('«name.formatForCode»', '«regexp»')) {
                $errorInfo['message'] = __f('Error! Field value must conform to regular expression [%2$s] (%1$s).', array('«name.formatForDisplay»', '«regexp»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(AbstractStringField it) '''
    '''
    def private dispatch validationCalls(StringField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
        «IF fixed»
            if (!$this->isStringWithFixedLength('«name.formatForCode»', «length»)) {
                $errorInfo['message'] = __f('Error! Length of field value must be %2$s (%1$s).', array('«name.formatForDisplay»', «length»), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF language»
            if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidLanguage('«name.formatForCode»', false)) {
                $errorInfo['message'] = __f('Error! Field value must be a valid language code (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF country»
            if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidCountry('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must be a valid country code (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF htmlcolour»
            if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidHtmlColour('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must be a valid html colour code [#123 or #123456] (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(TextField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
    '''
    def private dispatch validationCalls(EmailField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
        if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidEmail('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be a valid email address (%s).', array('«name.formatForDisplay»'), $dom);
            return $errorInfo;
        }
    '''
    def private dispatch validationCalls(UrlField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
        if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidUrl('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be a valid url (%s).', array('«name.formatForDisplay»'), $dom);
            return $errorInfo;
        }
    '''
    def private dispatch validationCalls(UploadField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
    '''
    def private dispatch validationCalls(ListField it) '''
        «IF mandatory»
            if (!$this->isStringNotEmpty('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must not be empty (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(ArrayField it) {
    }
    def private dispatch validationCalls(ObjectField it) {
    }
    def private validationCallsDateTime(AbstractDateField it) '''
        «IF mandatory»
            if (!$this->isValidDateTime('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must be a valid datetime (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(AbstractDateField it) {
        validationCallsDateTime
    }
    def private dispatch validationCalls(DatetimeField it) '''
        «validationCallsDateTime»
        «IF past»
            if (!$this->isDateTimeInPast('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a date in the past (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ELSEIF future»
            if (!$this->isDateTimeInFuture('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a date in the future (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(DateField it) '''
        «validationCallsDateTime»
        «IF past»
            if (!$this->isDateInPast('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a date in the past (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ELSEIF future»
            if (!$this->isDateInFuture('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a date in the future (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(TimeField it) '''
        «validationCallsDateTime»
        «IF past»
            if (!$this->isTimeInPast('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a time in the past (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ELSEIF future»
            if (!$this->isTimeInFuture('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a time in the future (%s).', array('«name.formatForDisplay»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(FloatField it) '''
        «validationCallsNumeric»
        if (!$this->isNumberNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForDisplay»', «length»), $dom);
            return $errorInfo;
        }
    '''
}
