package org.zikula.modulestudio.generator.cartridges.symfony.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormatIcalText {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it) {
        formatIcalTextImpl
    }

    def private formatIcalTextImpl(Application it) '''
        /**
         * The «appName.formatForDB»_icalText filter outputs a given text for the ics output format.
         * Example:
         *     {{ 'someString'|«appName.formatForDB»_icalText }}.
         */
        public function formatIcalText(string $string): string
        {
            $result = preg_replace('/<a href="(.*)">.*<\/a>/i', '$1', $string);
            $result = str_replace('€', 'Euro', $result);
            $result = preg_replace("/(\r\n|\n|\r)/D", '=0D=0A', $result);

            $result = str_replace("\xA0", ' ', $result);
            $result = str_replace("\x0A", '', $result);

            $result = str_replace("\x0D", "\\n", $result);
            $result = strip_tags(htmlspecialchars_decode($result));

            return ';LANGUAGE=' . $this->requestStack->getCurrentRequest()->getLocale() . ';ENCODING=QUOTED-PRINTABLE:' . $result . "\r\n";
        }
    '''
}
