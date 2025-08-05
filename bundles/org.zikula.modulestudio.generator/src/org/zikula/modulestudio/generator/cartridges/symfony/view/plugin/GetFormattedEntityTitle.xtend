package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetFormattedEntityTitle {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        /**
         * The «appName.formatForDB»_formattedTitle filter outputs a formatted title for a given entity.
         * Example:
         *     {{ myPost|«appName.formatForDB»_formattedTitle }}.
         */
        #[AsTwigFilter('«appName.formatForDB»_formattedTitle')]
        public function getFormattedEntityTitle(EntityInterface $entity): string
        {
            return $this->entityDisplayHelper->getFormattedTitle($entity);
        }
    '''
}
