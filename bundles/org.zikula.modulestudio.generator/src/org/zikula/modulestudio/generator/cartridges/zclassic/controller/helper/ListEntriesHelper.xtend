package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ListEntriesHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for list entries')
        val fh = new FileHelper
        generateClassPair(fsa, 'Helper/ListEntriesHelper.php',
            fh.phpFileContent(it, listFieldFunctionsBaseImpl), fh.phpFileContent(it, listFieldFunctionsImpl)
        )
    }

    def private listFieldFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;

        /**
         * Helper base class for list field entries related methods.
         */
        abstract class AbstractListEntriesHelper
        {
            use TranslatorTrait;

            /**
             * ListEntriesHelper constructor.
             *
             * @param TranslatorInterface $translator Translator service instance
             */
            public function __construct(TranslatorInterface $translator)
            {
                $this->setTranslator($translator);
            }

            «setTranslatorMethod»

            «resolve»

            «extractMultiList»

            «hasMultipleSelection»

            «getEntries»

            «additions»
        }
    '''

    def private resolve(Application it) '''
        /**
         * Return the name or names for a given list item.
         *
         * @param string $value      The dropdown value to process
         * @param string $objectType The treated object type
         * @param string $fieldName  The list field's name
         * @param string $delimiter  String used as separator for multiple selections
         *
         * @return string List item name
         */
        public function resolve($value, $objectType = '', $fieldName = '', $delimiter = ', ')
        {
            if ((empty($value) && $value != '0') || empty($objectType) || empty($fieldName)) {
                return $value;
            }

            $isMulti = $this->hasMultipleSelection($objectType, $fieldName);
            if (true === $isMulti) {
                $value = $this->extractMultiList($value);
            }

            $options = $this->getEntries($objectType, $fieldName);
            $result = '';

            if (true === $isMulti) {
                foreach ($options as $option) {
                    if (!in_array($option['value'], $value)) {
                        continue;
                    }
                    if (!empty($result)) {
                        $result .= $delimiter;
                    }
                    $result .= $option['text'];
                }
            } else {
                foreach ($options as $option) {
                    if ($option['value'] != $value) {
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
         *
         * @param string  $value The dropdown value to process
         *
         * @return array List of single values
         */
        public function extractMultiList($value)
        {
            $listValues = explode('###', $value);
            $amountOfValues = count($listValues);
            if ($amountOfValues > 1 && $listValues[$amountOfValues - 1] == '') {
                unset($listValues[$amountOfValues - 1]);
            }
            if ($listValues[0] == '') {
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
         *
         * @param string $objectType The treated object type
         * @param string $fieldName  The list field's name
         *
         * @return boolean True if this is a multi list false otherwise
         */
        public function hasMultipleSelection($objectType, $fieldName)
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
                «IF !getAllVariables.filter(ListField).empty»
                    case 'appSettings':
                        switch ($fieldName) {
                            «FOR listField : getAllVariables.filter(ListField)»
                                case '«listField.name.formatForCode»':
                                    $result = «listField.multiple.displayBool»;
                                    break;
                            «ENDFOR»
                        }
                        break;
                «ENDIF»
            }

            return $result;
        }

    '''

    def private getEntries(Application it) '''
        /**
         * Get entries for a certain dropdown field.
         *
         * @param string  $objectType The treated object type
         * @param string  $fieldName  The list field's name
         *
         * @return array Array with desired list entries
         */
        public function getEntries($objectType, $fieldName)
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
                                    «IF entity.isInheriting»
                                        $entries = $this->get«listField.name.formatForCodeCapital»EntriesFor«listField.entity.name.formatForCodeCapital»();
                                    «ELSE»
                                        $entries = $this->get«listField.name.formatForCodeCapital»EntriesFor«entity.name.formatForCodeCapital»();
                                    «ENDIF»
                                    break;
                            «ENDFOR»
                        }
                        break;
                «ENDFOR»
                «IF !getAllVariables.filter(ListField).empty»
                    case 'appSettings':
                        switch ($fieldName) {
                            «FOR listField : getAllVariables.filter(ListField)»
                                case '«listField.name.formatForCode»':
                                    $entries = $this->get«listField.name.formatForCodeCapital»EntriesForAppSettings();
                                    break;
                            «ENDFOR»
                        }
                        break;
                «ENDIF»
            }

            return $entries;
        }
    '''

    def private additions(Application it) '''
        «FOR listField : getAllListFields»

            «listField.getItemsImpl»
        «ENDFOR»
        «FOR listField : getAllVariables.filter(ListField)»

            «listField.getItemsImpl»
        «ENDFOR»
    '''

    def private getItemsImpl(ListField it) '''
        /**
         * Get '«name.formatForDisplay»' list entries.
         *
         * @return array Array with desired list entries
         */
        public function get«name.formatForCodeCapital»EntriesFor«IF null !== entity»«entity.name.formatForCodeCapital»«ELSE»AppSettings«ENDIF»()
        {
            $states = [];
            «IF name == 'workflowState'»
                «val visibleStates = items.filter[value != 'initial' && value != 'deleted']»
                «FOR item : visibleStates»«item.entryInfo(application)»«ENDFOR»
                «FOR item : visibleStates»«item.entryInfoNegative(application)»«ENDFOR»
            «ELSE»
                «FOR item : items»«item.entryInfo(application)»«ENDFOR»
            «ENDIF»

            return $states;
        }
    '''

    def private entryInfo(ListFieldItem it, Application app) '''
        $states[] = [
            'value'   => '«IF null !== value»«value.replace("'", "")»«ELSE»«name.formatForCode.replace("'", "")»«ENDIF»',
            'text'    => $this->__('«name.toFirstUpper.replace("'", "")»'),
            'title'   => «IF null !== documentation && documentation != ''»$this->__('«documentation.replace("'", "")»')«ELSE»''«ENDIF»,
            'image'   => '«IF null !== image && image != ''»«image».png«ENDIF»',
            'default' => «^default.displayBool»
        ];
    '''

    def private entryInfoNegative(ListFieldItem it, Application app) '''
        $states[] = [
            'value'   => '!«IF null !== value»«value.replace("'", "")»«ELSE»«name.formatForCode.replace("'", "")»«ENDIF»',
            'text'    => $this->__('All except «name.toFirstLower.replace("'", "")»'),
            'title'   => $this->__('Shows all items except these which are «name.formatForDisplay.replace("'", "")»'),
            'image'   => '',
            'default' => false
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
