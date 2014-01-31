package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ListEntries {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for list entries')
        generateClassPair(fsa, getAppSourceLibPath + 'Util/ListEntries' + (if (targets('1.3.5')) '' else 'Util') + '.php', listFieldFunctionsBaseFile, listFieldFunctionsFile)
    }

    def private listFieldFunctionsBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «listFieldFunctionsBaseImpl»
    '''

    def private listFieldFunctionsFile(Application it) '''
        «fh.phpFileHeader(it)»
        «listFieldFunctionsImpl»
    '''

    def private listFieldFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Util\Base;

            use Zikula_AbstractBase;
        «ENDIF»
        /**
         * Utility base class for list field entries related methods.
         */
        class «IF targets('1.3.5')»«appName»_Util_Base_ListEntries«ELSE»ListEntriesUtil«ENDIF» extends Zikula_AbstractBase
        {
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
            if (empty($value) || empty($objectType) || empty($fieldName)) {
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
            $numValues = count($listValues);
            if ($numValues > 1 && $listValues[$numValues-1] == '') {
                unset($listValues[$numValues-1]);
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
                «FOR entity : getAllEntities.filter[hasListFieldsEntity]»
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
                «FOR entity : getAllEntities.filter[hasListFieldsEntity]»
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
                «FOR item : visibleStates»«item.entryInfo»«ENDFOR»
                «FOR item : visibleStates»«item.entryInfoNegative»«ENDFOR»
            «ELSE»
                «FOR item : items»«item.entryInfo»«ENDFOR»
            «ENDIF»

            return $states;
        }
    '''

    def private entryInfo(ListFieldItem it) '''
        $states[] = array('value'   => '«value.replace("'", "")»',
                          'text'    => $this->__('«name.formatForDisplayCapital.replace("'", "")»'),
                          'title'   => «IF documentation !== null && documentation != ''»$this->__('«documentation.replace("'", "")»')«ELSE»''«ENDIF»,
                          'image'   => '«IF image !== null && image != ''»«image».png«ENDIF»',
                          'default' => «^default.displayBool»);
    '''

    def private entryInfoNegative(ListFieldItem it) '''
        $states[] = array('value'   => '!«value.replace("'", "")»',
                          'text'    => $this->__('All except «name.formatForDisplay.replace("'", "")»'),
                          'title'   => $this->__('Shows all items except these which are «name.formatForDisplay.replace("'", "")»'),
                          'image'   => '',
                          'default' => false);
    '''

    def private listFieldFunctionsImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appNamespace»\Util;

            use «appNamespace»\Util\Base\ListEntriesUtil as BaseListEntriesUtil;

        «ENDIF»
        /**
         * Utility implementation class for list field entries related methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_ListEntries extends «appName»_Util_Base_ListEntries
        «ELSE»
        class ListEntriesUtil extends BaseListEntriesUtil
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
