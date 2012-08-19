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
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Validator {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Creates a base validator class encapsulating common checks.
     */
    def generateCommon(Application it, IFileSystemAccess fsa) {
        println("Generating base validator class")
        fsa.generateFile(appName.getAppSourcePath + baseClassDefault(it, '', 'Validator').asFile, validatorCommonBaseFile)
        fsa.generateFile(appName.getAppSourcePath + implClassDefault(it, '', 'Validator').asFile, validatorCommonFile)
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
        /**
         * Validator class for encapsulating common entity validation methods.
         *
         * This is the base validation class with general checks.
         */
        abstract class «baseClassDefault('', 'Validator')» extends Zikula_AbstractBase
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
                $languageMap = ZLanguage::languageMap();
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
                $countryMap = ZLanguage::countryMap();
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
                return ($this->entity[$fieldName] instanceof DateTime);
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
        /**
         * Validator class for encapsulating common entity validation methods.
         *
         * This is the concrete validation class with general checks.
         */
        class «implClassDefault('', 'Validator')» extends «baseClassDefault('', 'Validator')»
        {
            // here you can add custom validation methods or override existing checks
        }
    '''

    /**
     * Creates a validator class for every Entity instance.
     */
    def generateWrapper(Entity it, Application app, IFileSystemAccess fsa) {
        println('Generating validator classes for entity "' + name.formatForDisplay + '"')
        if (!isInheriting) {
            fsa.generateFile(app.appName.getAppSourcePath + baseClassModel('validator', '').asFile, validatorBaseFile(app))
        }
        fsa.generateFile(app.appName.getAppSourcePath + implClassModel('validator', '').asFile, validatorFile(app))
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
        /**
         * Validator class for encapsulating entity validation methods.
         *
         * This is the base validation class for «name.formatForDisplay» entities.
         */
        class «baseClassModel('validator', '')» extends «implClassDefault(app, '', 'Validator')»
        {
            «validatorBaseImplBody(app, false)»
        }
    '''

    def private validatorImpl(Entity it, Application app) '''
        /**
         * Validator class for encapsulating entity validation methods.
         *
         * This is the concrete validation class for «name.formatForDisplay» entities.
         */
        class «implClassModel('validator', '')» extends «IF isInheriting»«parentType.implClassModel('validator', '')»«ELSE»«baseClassModel('validator', '')»«ENDIF»
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
            «FOR udf : getUniqueDerivedFields.filter(e|!e.primaryKey)»
                «validationCallUnique(udf)»
            «ENDFOR»
            «/* no slug input element yet, see https://github.com/l3pp4rd/DoctrineExtensions/issues/140
            «IF hasSluggableFields && slugUpdatable && slugUnique»
                «validationCallUniqueSlug»
            «ENDIF»
            */»
            return true;
        }

        «checkForUniqueValues(app)»
        «IF hasSluggableFields && slugUpdatable && slugUnique»
            «checkForUniqueSlugValues(app)»
        «ENDIF»

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
            if (empty($this->entity[$fieldName])) {
                return false;
            }

            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository('«app.appName»_Entity_«name.formatForCodeCapital»');

            $excludeid = $this->entity['«getFirstPrimaryKey.name.formatForCode»'];
            return $repository->detectUniqueState($fieldName, $this->entity[$fieldName], $excludeid);
        }
    '''

    def private checkForUniqueSlugValues(Entity it, Application app) '''
        /**
         * Check for unique slug values.
         *
         * This method determines if there already exist «nameMultiple.formatForDisplay» with the same slug.
         *
         * @return boolean result of this check, true if the given slug does not already exist
         */
        public function isUniqueSlug()
        {
            $value = $this->entity['slug'];
            if (empty($value)) {
                return false;
            }

            $serviceManager = ServiceUtil::getManager();
            $entityManager = $serviceManager->getService('doctrine.entitymanager');
            $repository = $entityManager->getRepository('«app.appName»_Entity_«name.formatForCodeCapital»');

            $excludeid = $this->entity['«getFirstPrimaryKey.name.formatForCode»'];
            return $repository->detectUniqueState('slug', $value, $excludeid);
        }
    '''


    def private dispatch validationCalls(DerivedField it) {
    }

    def private validationCallUnique(DerivedField it) '''
        if (!$this->isUniqueValue('«name.formatForCode»')) {
            $errorInfo['message'] = __f('The «name.formatForDisplay» %s is already assigned. Please choose another «name.formatForDisplay».', array($this->entity['«name.formatForCode»']), $dom);
            return $errorInfo;
        }
    '''
/*
    def private validationCallUniqueSlug(Entity it) '''
        if (!$this->isUniqueSlug()) {
            $errorInfo['message'] = __f('The slug %s is already assigned. Please choose another slug.', array($this->entity['slug']), $dom);
            return $errorInfo;
        }
    '''
*/
    def private dispatch validationCalls(BooleanField it) '''
        if (!$this->isValidBoolean('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be a valid boolean (%s).', array('«name.formatForCode»'), $dom);
            return $errorInfo;
        }
    '''
/** replace by switch ? */
    def private validationCallsNumeric(DerivedField it) '''
        if (!$this->isValidNumber('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be numeric (%s).', array('«name.formatForCode»'), $dom);
            return $errorInfo;
        }
        «IF mandatory»
            if (!$this->isNumberNotEmpty('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must not be 0 (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''

    def private validationCallsInteger(AbstractIntegerField it) '''
        if (!$this->isValidInteger('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value may only contain digits (%s).', array('«name.formatForCode»'), $dom);
            return $errorInfo;
        }
        «IF mandatory && (!primaryKey || entity.hasCompositeKeys || entity.getVersionField == this)»
            if (!$this->isNumberNotEmpty('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must not be 0 (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(AbstractIntegerField it) {
        if (entity.incoming.filter(typeof(JoinRelationship)).filter(e|e.targetField == name).isEmpty
         && entity.outgoing.filter(typeof(JoinRelationship)).filter(e|e.sourceField == name).isEmpty)
            validationCallsInteger
    }
    def private dispatch validationCalls(IntegerField it) '''
        «IF entity.incoming.filter(typeof(JoinRelationship)).filter(e|e.targetField == name).isEmpty
         && entity.outgoing.filter(typeof(JoinRelationship)).filter(e|e.sourceField == name).isEmpty»
            «validationCallsInteger»
            «IF minValue != 0»
                if (!$this->isIntegerNotLowerThan('«name.formatForCode»', «minValue»)) {
                    $errorInfo['message'] = __f('Error! Field value must not be lower than %2$s (%1$s).', array('«name.formatForCode»', «minValue»), $dom);
                    return $errorInfo;
                }
            «ENDIF»
            «IF maxValue != 0»
                if (!$this->isIntegerNotHigherThan('«name.formatForCode»', «maxValue»)) {
                    $errorInfo['message'] = __f('Error! Field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «maxValue»), $dom);
                    return $errorInfo;
                }
            «ENDIF»
            if (!$this->isNumberNotLongerThan('«name.formatForCode»', «length»)) {
                $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «length»), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(DecimalField it) '''
        «validationCallsNumeric»
        if (!$this->isNumberNotLongerThan('«name.formatForCode»', «(length+scale)»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «(length+scale)»), $dom);
            return $errorInfo;
        }
    '''
    def private dispatch validationCalls(UserField it) '''
        «validationCallsInteger»
        if («IF !mandatory»$this->entity['«name.formatForCode»'] > 0 && «ENDIF»!$this->isValidUser('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be a valid user id (%s).', array('«name.formatForCode»'), $dom);
            return $errorInfo;
        }
    '''

    def private validationCallsString(AbstractStringField it) '''
        «IF mandatory»
            if (!$this->isStringNotEmpty('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must not be empty (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF nospace»
            if (!$this->isStringNotContaining('«name.formatForCode»', ' ')) {
                $errorInfo['message'] = __f('Error! Field value must not contain space chars (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF minLength > 0»
            if (!$this->isStringNotShorterThan('«name.formatForCode»', «minLength»)) {
                $errorInfo['message'] = __f('Error! Length of field value must not be smaller than %2$s (%1$s).', array('«name.formatForCode»', «minLength»), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF regexp != null && regexp != ''»
            if (!$this->isValidRegExp('«name.formatForCode»', '«regexp»')) {
                $errorInfo['message'] = __f('Error! Field value must conform to regular expression [%2$s] (%1$s).', array('«name.formatForCode»', '«regexp»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(AbstractStringField it) '''
    '''
    def private dispatch validationCalls(StringField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
        «IF fixed»
            if (!$this->isStringWithFixedLength('«name.formatForCode»', «length»)) {
                $errorInfo['message'] = __f('Error! Length of field value must be %2$s (%1$s).', array('«name.formatForCode»', «length»), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF language»
            if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidLanguage('«name.formatForCode»', false)) {
                $errorInfo['message'] = __f('Error! Field value must be a valid language code (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF country»
            if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidCountry('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must be a valid country code (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
        «IF htmlcolour»
            if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidHtmlColour('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must be a valid html colour code [#123 or #123456] (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(TextField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
    '''
    def private dispatch validationCalls(EmailField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
        if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidEmail('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be a valid email address (%s).', array('«name.formatForCode»'), $dom);
            return $errorInfo;
        }
    '''
    def private dispatch validationCalls(UrlField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
        if («IF !mandatory»$this->entity['«name.formatForCode»'] != '' && «ENDIF»!$this->isValidUrl('«name.formatForCode»')) {
            $errorInfo['message'] = __f('Error! Field value must be a valid url (%s).', array('«name.formatForCode»'), $dom);
            return $errorInfo;
        }
    '''
    def private dispatch validationCalls(UploadField it) '''
        if (!$this->isStringNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «length»), $dom);
            return $errorInfo;
        }
        «validationCallsString»
    '''
    def private dispatch validationCalls(ListField it) '''
        «IF mandatory»
            if (!$this->isStringNotEmpty('«name.formatForCode»')) {
                $errorInfo['message'] = __f('Error! Field value must not be empty (%s).', array('«name.formatForCode»'), $dom);
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
                $errorInfo['message'] = __f('Error! Field value must be a valid datetime (%s).', array('«name.formatForCode»'), $dom);
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
                $errorInfo['message'] = __f('Error! Field value must be a date in the past (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ELSEIF future»
            if (!$this->isDateTimeInFuture('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a date in the future (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(DateField it) '''
        «validationCallsDateTime»
        «IF past»
            if (!$this->isDateInPast('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a date in the past (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ELSEIF future»
            if (!$this->isDateInFuture('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a date in the future (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(TimeField it) '''
        «validationCallsDateTime»
        «IF past»
            if (!$this->isTimeInPast('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a time in the past (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ELSEIF future»
            if (!$this->isTimeInFuture('«name.formatForCode»', «mandatory.displayBool»)) {
                $errorInfo['message'] = __f('Error! Field value must be a time in the future (%s).', array('«name.formatForCode»'), $dom);
                return $errorInfo;
            }
        «ENDIF»
    '''
    def private dispatch validationCalls(FloatField it) '''
        «validationCallsNumeric»
        if (!$this->isNumberNotLongerThan('«name.formatForCode»', «length»)) {
            $errorInfo['message'] = __f('Error! Length of field value must not be higher than %2$s (%1$s).', array('«name.formatForCode»', «length»), $dom);
            return $errorInfo;
        }
    '''
}
