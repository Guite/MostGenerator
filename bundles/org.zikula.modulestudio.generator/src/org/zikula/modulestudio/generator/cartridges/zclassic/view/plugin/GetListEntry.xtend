package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetListEntry {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        getListEntryImpl
    }

    def private getListEntryImpl(Application it) '''
        /**
         * The «appName.formatForDB»_listEntry filter displays the name
         * or names for a given list item.
         * Example:
         *     {{ entity.listField|«appName.formatForDB»_listEntry('entityName', 'fieldName') }}
         *
         * @param string $value      The dropdown value to process
         * @param string $objectType The treated object type
         * @param string $fieldName  The list field's name
         * @param string $delimiter  String used as separator for multiple selections
         *
         * @return string List item name
         */
        public function getListEntry($value, $objectType = '', $fieldName = '', $delimiter = ', ')
        {
            if ((empty($value) && $value != '0') || empty($objectType) || empty($fieldName)) {
                return $value;
            }

            return $this->listHelper->resolve($value, $objectType, $fieldName, $delimiter);
        }
    '''
}
