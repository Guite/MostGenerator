package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

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
         «IF !targets('3.0')»
         *
         * @param string $string The given output string
         *
         * @return string Processed string for ics output
         «ENDIF»
         */
        public function formatIcalText«IF targets('3.0')»(string $string): string«ELSE»($string)«ENDIF»
        {
            $result = preg_replace('/<a href="(.*)">.*<\/a>/i', '$1', $string);
            $result = str_replace('€', 'Euro', $result);
            $result = preg_replace("/(\r\n|\n|\r)/D", '=0D=0A', $result);

            return ';LANGUAGE=' . $this->requestStack->getCurrentRequest()->getLocale() . ';ENCODING=QUOTED-PRINTABLE:' . $result . "\r\n";
        }
    '''
}
