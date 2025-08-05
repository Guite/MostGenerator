package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetLogDescription {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        /**
         * The «appName.formatForDB»_logDescription filter returns the translated clear text
         * description for a given log entry.
         * Example:
         *     {{ logEntry|«appName.formatForDB»_logDescription }}.
         */
        #[AsTwigFilter('«appName.formatForDB»_logDescription')]
        public function getLogDescription(AbstractLogEntry $logEntry): string
        {
            return $this->loggableHelper->translateActionDescription($logEntry);
        }
    '''
}
