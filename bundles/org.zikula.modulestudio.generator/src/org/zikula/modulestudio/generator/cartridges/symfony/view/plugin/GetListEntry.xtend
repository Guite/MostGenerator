package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetListEntry {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        /**
         * The «appName.formatForDB»_listEntry filter displays the name
         * or names for a given list item.
         * Example:
         *     {{ entity.listField|«appName.formatForDB»_listEntry('entityName', 'fieldName') }}.
         */
        #[AsTwigFilter('«appName.formatForDB»_listEntry')]
        public function getListEntry(
            «IF getAllListFields.filter[nullable].empty»?«ENDIF»string $value,
            string $objectType = '',
            string $fieldName = '',
            string $delimiter = ', '
        ): string {
            if ((empty($value) && '0' !== $value) || empty($objectType) || empty($fieldName)) {
                return $value;
            }

            return $this->listHelper->resolve($value, $objectType, $fieldName, $delimiter);
        }
    '''
}
