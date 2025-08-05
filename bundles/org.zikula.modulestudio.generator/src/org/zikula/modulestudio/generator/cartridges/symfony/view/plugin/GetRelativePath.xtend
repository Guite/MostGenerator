package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetRelativePath {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        /**
         * The «appName.formatForDB»_relativePath filter returns the relative web path to a file.
         * Example:
         *     {{ myPerson.image.getPathname()|«appName.formatForDB»_relativePath }}.
         */
        #[AsTwigFilter('«appName.formatForDB»_relativePath')]
        public function getRelativePath(string $absolutePath): string
        {
            return str_replace($this->projectDir . '/public', '', $absolutePath);
        }
    '''
}
