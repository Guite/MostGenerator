package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ListEntriesHelper {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for list entries')
        val helperFolder = if (targets('1.3.x')) 'Util' else 'Helper'
        generateClassPair(fsa, getAppSourceLibPath + helperFolder + '/ListEntries' + (if (targets('1.3.x')) '' else 'Helper') + '.php',
            fh.phpFileContent(it, listFieldFunctionsBaseImpl), fh.phpFileContent(it, listFieldFunctionsImpl)
        )
    }

    def private listFieldFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Helper\Base;

            use Zikula\Common\Translator\Translator;

        «ENDIF»
        /**
         * Utility base class for list field entries related methods.
         */
        class «IF targets('1.3.x')»«appName»_Util_Base_ListEntries extends Zikula_AbstractBase«ELSE»ListEntriesHelper«ENDIF»
        {
            «IF !targets('1.3.x')»
                /**
                 * @var Translator
                 */
                protected $translator;

                /**
                 * Constructor.
                 * Initialises member vars.
                 *
                 * @param Translator $translator Translator service instance.
                 *
                 * @return void
                 */
                public function __construct($translator)
                {
                    $this->translator = $translator;
                }

            «ENDIF»
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
         * @param string $value      The dropdown value to process.
         * @param string $objectType The treated object type.
         * @param string $fieldName  The list field's name.
         * @param string $delimiter  String used as separator for multiple selections.
         *
         * @return string List item name.
         */
        public function resolve($value, $objectType = '', $fieldName = '', $delimiter = ', ')
        {
            if ((empty($value) && $value != '0') || empty($objectType) || empty($fieldName)) {
                return $value;
            }

            $isMulti = $this->hasMultipleSelection($objectType, $fieldName);
            if ($isMulti === true) {
                $value = $this->extractMultiList($value);
            }

            $options = $this->getEntries($objectType, $fieldName);
            $result = '';

            if ($isMulti === true) {
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
         * @param string  $value The dropdown value to process.
         *
         * @return array List of single values.
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
         * @param string $objectType The treated object type.
         * @param string $fieldName  The list field's name.
         *
         * @return boolean True if this is a multi list false otherwise.
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
            }

            return $result;
        }

    '''

    def private getEntries(Application it) '''
        /**
         * Get entries for a certain dropdown field.
         *
         * @param string  $objectType The treated object type.
         * @param string  $fieldName  The list field's name.
         *
         * @return array Array with desired list entries.
         */
        public function getEntries($objectType, $fieldName)
        {
            if (empty($objectType) || empty($fieldName)) {
                return array();
            }

            $entries = array();
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

    def private additions(Application it) '''
        «FOR listField : getAllListFields»

            «listField.getItemsImpl»
        «ENDFOR»
    '''

    def private getItemsImpl(ListField it) '''
        /**
         * Get '«name.formatForDisplay»' list entries.
         *
         * @return array Array with desired list entries.
         */
        public function get«name.formatForCodeCapital»EntriesFor«entity.name.formatForCodeCapital»()
        {
            $states = array();
            «IF name == 'workflowState'»
                «val visibleStates = items.filter[value != 'initial' && value != 'deleted']»
                «FOR item : visibleStates»«item.entryInfo(entity.application)»«ENDFOR»
                «FOR item : visibleStates»«item.entryInfoNegative(entity.application)»«ENDFOR»
            «ELSE»
                «FOR item : items»«item.entryInfo(entity.application)»«ENDFOR»
            «ENDIF»

            return $states;
        }
    '''

    def private entryInfo(ListFieldItem it, Application app) '''
        $states[] = array('value'   => '«value.replace("'", "")»',
                          'text'    => $this->«IF !app.targets('1.3.x')»translator->«ENDIF»__('«name.formatForDisplayCapital.replace("'", "")»'),
                          'title'   => «IF documentation !== null && documentation != ''»$this->«IF !app.targets('1.3.x')»translator->«ENDIF»__('«documentation.replace("'", "")»')«ELSE»''«ENDIF»,
                          'image'   => '«IF image !== null && image != ''»«image».png«ENDIF»',
                          'default' => «^default.displayBool»);
    '''

    def private entryInfoNegative(ListFieldItem it, Application app) '''
        $states[] = array('value'   => '!«value.replace("'", "")»',
                          'text'    => $this->«IF !app.targets('1.3.x')»translator->«ENDIF»__('All except «name.formatForDisplay.replace("'", "")»'),
                          'title'   => $this->«IF !app.targets('1.3.x')»translator->«ENDIF»__('Shows all items except these which are «name.formatForDisplay.replace("'", "")»'),
                          'image'   => '',
                          'default' => false);
    '''

    def private listFieldFunctionsImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Helper;

            use «appNamespace»\Helper\Base\ListEntriesHelper as BaseListEntriesHelper;

        «ENDIF»
        /**
         * Utility implementation class for list field entries related methods.
         */
        «IF targets('1.3.x')»
        class «appName»_Util_ListEntries extends «appName»_Util_Base_ListEntries
        «ELSE»
        class ListEntriesHelper extends BaseListEntriesHelper
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
