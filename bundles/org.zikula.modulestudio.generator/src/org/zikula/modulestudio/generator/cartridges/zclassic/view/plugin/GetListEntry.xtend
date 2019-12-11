package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetListEntry {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) {
        getListEntryImpl
    }

    def private getListEntryImpl(Application it) '''
        /**
         * The «appName.formatForDB»_listEntry filter displays the name
         * or names for a given list item.
         * Example:
         *     {{ entity.listField|«appName.formatForDB»_listEntry('entityName', 'fieldName') }}
         «IF !targets('3.0')»
         *
         * @param string $value The dropdown value to process
         * @param string $objectType The treated object type
         * @param string $fieldName The list field's name
         * @param string $delimiter String used as separator for multiple selections
         *
         * @return string List item name
         «ENDIF»
         */
        public function getListEntry«IF targets('3.0')»(
            string $value,
            string $objectType = '',
            string $fieldName = '',
            string $delimiter = ', '
        ): string«ELSE»($value, $objectType = '', $fieldName = '', $delimiter = ', ')«ENDIF»
        {
            if ((empty($value) && '0' !== $value) || empty($objectType) || empty($fieldName)) {
                return $value;
            }
            «IF !isSystemModule»

                $this->translator->setDomain('«appName.formatForDB»');
            «ENDIF»

            return $this->listHelper->resolve($value, $objectType, $fieldName, $delimiter);
        }
    '''
}
