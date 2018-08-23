package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityDisplayHelper {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for formatted entity display'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/EntityDisplayHelper.php', entityDisplayHelperBaseClass, entityDisplayHelperImpl)
    }

    def private entityDisplayHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF hasAnyDateTimeFields»
            use IntlDateFormatter;
        «ENDIF»
        «IF hasNumberFields»
            use NumberFormatter;
        «ENDIF»
        «IF hasAnyDateTimeFields || hasNumberFields»
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        «IF hasListFields»
            use «appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * Entity display helper base class.
         */
        abstract class AbstractEntityDisplayHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var TranslatorInterface
         */
        protected $translator;
        «IF hasListFields»

            /**
             * @var ListEntriesHelper Helper service for managing list entries
             */
            protected $listEntriesHelper;
        «ENDIF»
        «IF hasAnyDateTimeFields»

            /**
             * @var IntlDateFormatter Formatter for dates
             */
            protected $dateFormatter;
        «ENDIF»
        «IF hasNumberFields»

            /**
             * @var NumberFormatter Formatter for numbers
             */
            protected $numberFormatter;

            /**
             * @var NumberFormatter Formatter for currencies
             */
            protected $currencyFormatter;
        «ENDIF»

        /**
         * EntityDisplayHelper constructor.
         *
         * @param TranslatorInterface $translator «IF hasListFields»       «ENDIF»Translator service instance
         «IF hasAnyDateTimeFields || hasNumberFields»
         * @param RequestStack        $requestStack      RequestStack service instance
         «ENDIF»
         «IF hasListFields»
         * @param ListEntriesHelper   $listEntriesHelper Helper service for managing list entries
         «ENDIF»
         */
        public function __construct(
            TranslatorInterface $translator«IF hasAnyDateTimeFields || hasNumberFields»,
            RequestStack $requestStack«ENDIF»«IF hasListFields»,
            ListEntriesHelper $listEntriesHelper«ENDIF»
        ) {
            $this->translator = $translator;
            «IF hasListFields»
                $this->listEntriesHelper = $listEntriesHelper;
            «ENDIF»
            «IF hasAnyDateTimeFields || hasNumberFields»
                $locale = null !== $requestStack->getCurrentRequest() ? $requestStack->getCurrentRequest()->getLocale() : null;
            «ENDIF»
            «IF hasAnyDateTimeFields»
                $this->dateFormatter = new IntlDateFormatter($locale, IntlDateFormatter::NONE, IntlDateFormatter::NONE);
            «ENDIF»
            «IF hasNumberFields»
                $this->numberFormatter = new NumberFormatter($locale, NumberFormatter::DECIMAL);
                $this->currencyFormatter = new NumberFormatter($locale, NumberFormatter::CURRENCY);
            «ENDIF»
        }

        /**
         * Returns the formatted title for a given entity.
         *
         * @param object $entity The given entity instance
         *
         * @return string The formatted title
         */
        public function getFormattedTitle($entity)
        {
            «FOR entity : getAllEntities»
                if ($entity instanceof «entity.name.formatForCodeCapital»Entity) {
                    return $this->format«entity.name.formatForCodeCapital»($entity);
                }
            «ENDFOR»

            return '';
        }
        «FOR entity : getAllEntities»

            «entity.formatMethod»
        «ENDFOR»

        «fieldNameHelpers»
    '''

    def private formatMethod(Entity it) '''
        /**
         * Returns the formatted title for a given entity.
         *
         * @param «name.formatForCodeCapital»Entity $entity The given entity instance
         *
         * @return string The formatted title
         */
        protected function format«name.formatForCodeCapital»(«name.formatForCodeCapital»Entity $entity)
        {
            «IF displayPatternParts.length < 2»«/* no field references, just pass to translator */»
                return $this->translator->__('«getUsedDisplayPattern.formatForCodeCapital»');
            «ELSE»
                return $this->translator->__f('«getUsedDisplayPattern.replaceAll('#', '%')»', [
                    «displayPatternArguments»
                ]);
            «ENDIF»
        }
    '''

    def private fieldNameHelpers(Application it) '''
        «getTitleFieldName»

        «getDescriptionFieldName»
        «IF hasImageFields»

            «getPreviewFieldName»
        «ENDIF»

        «getStartDateFieldName»
    '''

    def private getTitleFieldName(Application it) '''
        /**
         * Returns name of the field used as title / name for entities of this repository.
         *
         * @param string $objectType Name of treated entity type
         *
         * @return string Name of field to be used as title
         */
        public function getTitleFieldName($objectType)
        {
            «FOR entity : getAllEntities»
                if ($objectType == '«entity.name.formatForCode»') {
                    «val stringFields = entity.fields.filter(StringField).filter[length >= 20 && !#[StringRole.COLOUR, StringRole.COUNTRY, StringRole.LANGUAGE, StringRole.LOCALE, StringRole.PASSWORD].contains(role)]»
                    return '«IF !stringFields.empty»«stringFields.head.name.formatForCode»«ENDIF»';
                }
            «ENDFOR»

            return '';
        }
    '''

    def private getDescriptionFieldName(Application it) '''
        /**
         * Returns name of the field used for describing entities of this repository.
         *
         * @param string $objectType Name of treated entity type
         *
         * @return string Name of field to be used as description
         */
        public function getDescriptionFieldName($objectType)
        {
            «FOR entity : getAllEntities»
                if ($objectType == '«entity.name.formatForCode»') {
                    «val textFields = entity.getSelfAndParentDataObjects.map[fields.filter(TextField)].flatten.filter[length >= 50]»
                    «val stringFields = entity.getDisplayStringFieldsEntity.filter[length >= 50 && !#[StringRole.COLOUR, StringRole.COUNTRY, StringRole.LANGUAGE, StringRole.LOCALE].contains(role)]»
                    «IF !textFields.empty»
                        return '«textFields.head.name.formatForCode»';
                    «ELSEIF !stringFields.empty»
                        «IF stringFields.size > 1»
                            return '«stringFields.get(1).name.formatForCode»';
                        «ELSE»
                            return '«stringFields.head.name.formatForCode»';
                        «ENDIF»
                    «ELSE»
                        return '';
                    «ENDIF»
                }
            «ENDFOR»

            return '';
        }
    '''

    def private getPreviewFieldName(Application it) '''
        /**
         * Returns name of first upload field which is capable for handling images.
         *
         * @param string $objectType Name of treated entity type
         *
         * @return string Name of field to be used for preview images
         */
        public function getPreviewFieldName($objectType)
        {
            «FOR entity : getAllEntities.filter[hasImageFieldsEntity]»
                if ($objectType == '«entity.name.formatForCode»') {
                    return '«entity.getImageFieldsEntity.head.name.formatForCode»';
                }
            «ENDFOR»

            return '';
        }
    '''

    def private getStartDateFieldName(Application it) '''
        /**
         * Returns name of the date(time) field to be used for representing the start
         * of this object. Used for providing meta data to the tag module.
         *
         * @param string $objectType Name of treated entity type
         *
         * @return string Name of field to be used as date
         */
        public function getStartDateFieldName($objectType)
        {
            «FOR entity : getAllEntities»
                if ($objectType == '«entity.name.formatForCode»') {
                    return '«IF null !== entity.getStartDateField»«entity.getStartDateField.name.formatForCode»«ELSEIF entity.standardFields»createdDate«ENDIF»';
                }
            «ENDFOR»

            return '';
        }
    '''

    def private displayPatternArguments(Entity it) {
        var result = ''
        for (patternPart : displayPatternParts) {
            var CharSequence formattedPart = ''
            // check if patternPart equals a field name
            var matchedFields = getSelfAndParentDataObjects.map[fields].flatten.filter[name == patternPart]
            if (!matchedFields.empty) {
                // field referencing part
                if (matchedFields.head instanceof UploadField) {
                    formattedPart = '\'%' + patternPart + '%\' => ' + 'is_array($entity->get' + patternPart.toFirstUpper + '()) ? $entity->get' + patternPart.toFirstUpper + '()[\'' + patternPart + '\'] : $entity->get' + patternPart.toFirstUpper + '()'
                } else {
                    formattedPart = '\'%' + patternPart + '%\' => ' + formatFieldValue(matchedFields.head, '$entity->get' + patternPart.toFirstUpper + '()')
                }
            } else if (geographical && #['latitude', 'longitude'].contains(patternPart)) {
                // geo field referencing part
                formattedPart = '\'%' + patternPart + '%\' => ' + 'number_format($entity->get' + patternPart.toFirstUpper + '(), 7, \'.\', \'\')'
            } else {
                // static part
                // formattedPart = '\'' + patternPart.replace('\'', '') + '\''
            }
            if (formattedPart != '' && !result.empty) {
                result = result.concat(",\n")
            }
            result = result.concat(formattedPart.toString)
        }
        result
    }

    def private formatFieldValue(Field it, CharSequence value) {
        switch it {
            NumberField: '''$this->«IF currency»currencyFormatter->formatCurrency(«value», 'EUR')«ELSE»numberFormatter->format(«value»)«ENDIF»'''
            UserField: '''(«value» ? «value»->getUname() : '')'''
            ListField: '''«IF null !== entity»$this->listEntriesHelper->resolve(«value», '«entity.name.formatForCode»', '«name.formatForCode»')«ELSE»«value»«ENDIF»'''
            DatetimeField: '''$this->dateFormatter->formatObject(«value», [«IF isDateTimeField»IntlDateFormatter::SHORT, IntlDateFormatter::SHORT«ELSEIF isDateField»IntlDateFormatter::SHORT, IntlDateFormatter::NONE«ELSEIF isTimeField»IntlDateFormatter::NONE, IntlDateFormatter::SHORT«ENDIF»])'''
            default: value
        }
    }

    def private entityDisplayHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractEntityDisplayHelper;

        /**
         * Entity display helper implementation class.
         */
        class EntityDisplayHelper extends AbstractEntityDisplayHelper
        {
            // feel free to extend the entity display helper here
        }
    '''
}
