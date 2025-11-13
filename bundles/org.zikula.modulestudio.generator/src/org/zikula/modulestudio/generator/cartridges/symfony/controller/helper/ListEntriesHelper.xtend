package org.zikula.modulestudio.generator.cartridges.symfony.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ListEntriesHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for list entries'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ListEntriesHelper.php', listFieldFunctionsBaseImpl, listFieldFunctionsImpl)
    }

    def private listFieldFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\CoreBundle\Translation\TranslatorTrait;
        use function Symfony\Component\Translation\t;

        /**
         * Helper base class for list field entries related methods.
         */
        abstract class AbstractListEntriesHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        use TranslatorTrait;

        public function __construct(TranslatorInterface $translator)
        {
            $this->setTranslator($translator);
        }

        «resolve»

        «extractMultiList»

        «hasMultipleSelection»

        «getEntries»

        «getFormChoices»
        «additions»
    '''

    def private resolve(Application it) '''
        /**
         * Return the name or names for a given list item.
         */
        public function resolve(
            string $value,
            string $objectType = '',
            string $fieldName = '',
            string $delimiter = ', '
        ): string {
            if ((empty($value) && '0' !== $value) || empty($objectType) || empty($fieldName)) {
                return $value;
            }

            $isMulti = $this->hasMultipleSelection($objectType, $fieldName);
            $values = $isMulti ? $this->extractMultiList($value) : [];

            $options = $this->getEntries($objectType, $fieldName);
            $result = '';

            if (true === $isMulti) {
                foreach ($options as $option) {
                    if (!in_array($option['value'], $values, true)) {
                        continue;
                    }
                    if (!empty($result)) {
                        $result .= $delimiter;
                    }
                    $result .= $option['text'];
                }
            } else {
                foreach ($options as $option) {
                    if ($option['value'] !== $value) {
                        continue;
                    }
                    $result = $option['text'];
                    break;
                }
            }

            return $result;
        }
    '''

    def private extractMultiList(Application it) '''
        /**
         * Extract concatenated multi selection.
         */
        public function extractMultiList(string $value): array
        {
            $listValues = explode('###', $value);
            $amountOfValues = count($listValues);
            if ($amountOfValues > 1 && '' === $listValues[$amountOfValues - 1]) {
                unset($listValues[$amountOfValues - 1]);
            }
            if ('' === $listValues[0]) {
                // use array_shift instead of unset for proper key reindexing
                // keys must start with 0, otherwise the dropdownlist form plugin gets confused
                array_shift($listValues);
            }

            return $listValues;
        }
    '''

    def private hasMultipleSelection(Application it) '''
        /**
         * Determine whether a certain dropdown field has a multi selection or not.
         */
        public function hasMultipleSelection(string $objectType, string $fieldName): bool
        {
            if (empty($objectType) || empty($fieldName)) {
                return false;
            }

            $result = false;
            switch ($objectType) {
                «FOR entity : entities.filter[hasListFieldsEntity]»
                    case '«entity.name.formatForCode»':
                        switch ($fieldName) {
                            «FOR listField : entity.getListFieldsEntity»
                                case '«listField.name.formatForCode»':
                                    $result = «listField.multiple.displayBool»;
                                    break;
                            «ENDFOR»
                        }
                        break;
                «ENDFOR»
            }

            return $result;
        }
    '''

    def private getEntries(Application it) '''
        /**
         * Get entries for a certain dropdown field.
         */
        public function getEntries(string $objectType, string $fieldName): array
        {
            if (empty($objectType) || empty($fieldName)) {
                return [];
            }

            $entries = [];
            switch ($objectType) {
                «FOR entity : entities.filter[hasListFieldsEntity]»
                    case '«entity.name.formatForCode»':
                        switch ($fieldName) {
                            «FOR listField : entity.getListFieldsEntity»
                                case '«listField.name.formatForCode»':
                                    $entries = $this->get«listField.name.formatForCodeCapital»EntriesFor«entity.name.formatForCodeCapital»();
                                    break;
                            «ENDFOR»
                        }
                        break;
                «ENDFOR»
            }

            return $entries;
        }
    '''

    def private getFormChoices(Application it) '''
        /**
         * Get form choices for a certain dropdown field.
         */
        public function getFormChoices(string $objectType, string $fieldName, bool $withAttributes = false): array
        {
            $entries = $this->getEntries($objectType, $fieldName);

            $choices = [];
            $choiceAttributes = [];
            foreach ($entries as $entry) {
                $choices[$entry['value']] = $entry['text'];
                if ($withAttributes) {
                    $choiceAttributes[$entry['value']] = ['title' => $entry['title']];
                }
            }

            return $withAttributes ? [$choices, $choiceAttributes] : $choices;
        }
    '''

    def private additions(Application it) '''
        «FOR listField : getAllListFields»

            «listField.getItemsImpl»
        «ENDFOR»
    '''

    def private getItemsImpl(ListField it) '''
        /**
         * Get '«name.formatForDisplay»' list entries.
         */
        public function get«name.formatForCodeCapital»EntriesFor«entity.name.formatForCodeCapital»(): array
        {
            $states = [];
            «IF name == 'workflowState'»
                «val visibleStates = items.filter[value != 'initial' && value != 'deleted']»
                «FOR item : visibleStates»«item.entryInfo(application, '')»«ENDFOR»
                «FOR item : visibleStates»«item.entryInfoNegative(application, '')»«ENDFOR»
            «ELSE»
                «FOR item : items»«item.entryInfo(application, entity.name.formatForCode)»«ENDFOR»
            «ENDIF»

            return $states;
        }
    '''

    def private entryInfo(ListFieldItem it, Application app, String domain) '''
        $states[] = [
            'value' => '«IF null !== value»«value.replace("'", "")»«ELSE»«name.formatForCode.replace("'", "")»«ENDIF»',
            'text' => t('«name.toFirstUpper.replace("'", "")»'«IF !domain.empty», [], '«domain»'«ENDIF»),
            'title' => «IF null !== documentation && !documentation.empty»t('«documentation.replace("'", "")»'«IF !domain.empty», [], '«domain»'«ENDIF»)«ELSE»''«ENDIF»,
            'default' => «^default.displayBool»,
        ];
    '''

    def private entryInfoNegative(ListFieldItem it, Application app, String domain) '''
        $states[] = [
            'value' => '!«IF null !== value»«value.replace("'", "")»«ELSE»«name.formatForCode.replace("'", "")»«ENDIF»',
            'text' => t('All except «name.toFirstLower.replace("'", "")»'«IF !domain.empty», [], '«domain»'«ENDIF»),
            'title' => t('Shows all items except these which are «name.formatForDisplay.replace("'", "")»'«IF !domain.empty», [], '«domain»'«ENDIF»),
            'default' => false,
        ];
    '''

    def private listFieldFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractListEntriesHelper;

        /**
         * Helper implementation class for list field entries related methods.
         */
        class ListEntriesHelper extends AbstractListEntriesHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
