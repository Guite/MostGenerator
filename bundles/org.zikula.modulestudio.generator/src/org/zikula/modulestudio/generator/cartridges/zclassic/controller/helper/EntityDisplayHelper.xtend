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
import de.guite.modulestudio.metamodel.AbstractStringField
import org.zikula.modulestudio.generator.application.ImportList

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

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            appNamespace + '\\Entity\\EntityInterface'
        ])
        if (hasAnyDateTimeFields) {
            imports.add('IntlDateFormatter')
        }
        if (hasNumberFields) {
            imports.add('NumberFormatter')
        }
        if (hasAnyDateTimeFields || hasNumberFields) {
            imports.add('Symfony\\Component\\HttpFoundation\\RequestStack')
        }
        for (entity : getAllEntities) {
            imports.add(appNamespace + '\\Entity\\' + entity.name.formatForCodeCapital)
        }
        if (hasListFields) {
            imports.add(appNamespace + '\\Helper\\ListEntriesHelper')
        }
        imports
    }

    def private entityDisplayHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «collectBaseImports.print»

        /**
         * Entity display helper base class.
         */
        abstract class AbstractEntityDisplayHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        «IF hasAnyDateTimeFields»
            protected IntlDateFormatter $dateFormatter;

        «ENDIF»
        «IF hasNumberFields»
            protected NumberFormatter $numberFormatter;

            protected NumberFormatter $currencyFormatter;

        «ENDIF»

        public function __construct(
            protected readonly TranslatorInterface $translator«IF hasListFields»,
            protected readonly ListEntriesHelper $listEntriesHelper«ENDIF»«IF hasAnyDateTimeFields || hasNumberFields»,
            RequestStack $requestStack«ENDIF»
        ) {
            «IF hasAnyDateTimeFields || hasNumberFields»
                $locale = null !== $requestStack->getCurrentRequest() ? $requestStack->getCurrentRequest()->getLocale() : 'en';
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
         */
        public function getFormattedTitle(EntityInterface $entity): string
        {
            «FOR entity : getAllEntities»
                if ($entity instanceof «entity.name.formatForCodeCapital») {
                    return $this->format«entity.name.formatForCodeCapital»($entity);
                }
            «ENDFOR»

            return '';
        }

        /**
         * Returns an additional description for a given entity.
         */
        public function getDescription(EntityInterface $entity): string
        {
            «FOR entity : getAllEntities»
                if ($entity instanceof «entity.name.formatForCodeCapital») {
                    return $this->get«entity.name.formatForCodeCapital»Description($entity);
                }
            «ENDFOR»

            return '';
        }
        «FOR entity : getAllEntities»

            «entity.formatMethod»

            «entity.describeMethod»
        «ENDFOR»

        «fieldNameHelpers»
    '''

    def private formatMethod(Entity it) '''
        /**
         * Returns the formatted title for a given «name.formatForDisplay».
         */
        protected function format«name.formatForCodeCapital»(«name.formatForCodeCapital» $entity): string
        {
            «IF displayPatternParts.length < 2»«/* no field references, just pass to translator */»
                return $this->translator->trans('«getUsedDisplayPattern.formatForCodeCapital»', [], '«name.formatForCode»');
            «ELSE»
                return $this->translator->trans(
                    '«getUsedDisplayPattern.replaceAll('#', '%')»',
                    [
                        «displayPatternArguments»
                    ],
                    '«name.formatForCode»'
                );
            «ENDIF»
        }
    '''

    def private describeMethod(Entity it) '''
        /**
         * Returns an additional description for a given «name.formatForDisplay».
         */
        protected function get«name.formatForCodeCapital»Description(«name.formatForCodeCapital» $entity): string
        {
            $descriptionFieldName = $this->getDescriptionFieldName($entity->get_objectType());
            $getter = 'get' . ucfirst($descriptionFieldName);

            return $entity->$getter() ?? '';
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
         */
        public function getTitleFieldName(string $objectType = ''): string
        {
            «FOR entity : getAllEntities»
                if ('«entity.name.formatForCode»' === $objectType) {
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
         */
        public function getDescriptionFieldName(string $objectType = ''): string
        {
            «FOR entity : getAllEntities»
                if ('«entity.name.formatForCode»' === $objectType) {
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
         */
        public function getPreviewFieldName(string $objectType = ''): string
        {
            «FOR entity : getAllEntities.filter[hasImageFieldsEntity]»
                if ('«entity.name.formatForCode»' === $objectType) {
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
         */
        public function getStartDateFieldName(string $objectType = ''): string
        {
            «FOR entity : getAllEntities»
                if ('«entity.name.formatForCode»' === $objectType) {
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
                    formattedPart = '\'%' + patternPart + '%\' => ' + 'htmlspecialchars((is_array($entity->get' + patternPart.toFirstUpper + '()) ? $entity->get' + patternPart.toFirstUpper + '()[\'' + patternPart + '\'] : $entity->get' + patternPart.toFirstUpper + '())->getFilename())'
                } else if (geographical && #['latitude', 'longitude'].contains(matchedFields.head.name)) {
                    // geo field referencing part
                    formattedPart = '\'%' + patternPart + '%\' => ' + 'number_format($entity->get' + patternPart.toFirstUpper + '(), 7, \'.\', \'\')'
                } else {
                    formattedPart = '\'%' + patternPart + '%\' => ' + 'htmlspecialchars(' + (if (matchedFields.head instanceof AbstractStringField || matchedFields.head instanceof UserField) '' else '(string) ') + formatFieldValue(matchedFields.head, '$entity->get' + patternPart.toFirstUpper + '()') + ')'
                }
            } else {
                // static part
                // formattedPart = '\'' + patternPart.replace('\'', '') + '\''
            }
            if (formattedPart != '') {
                formattedPart = formattedPart + ','
                if (!result.empty) {
                    result = result.concat("\n")
                }
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
