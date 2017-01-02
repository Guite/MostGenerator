package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormatIcalText {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        formatIcalTextImpl
    }

    def private formatIcalTextImpl(Application it) '''
        /**
         * The «appName.formatForDB»_icalText filter outputs a given text for the ics output format.
         * Example:
         *     {{ 'someString'|«appName.formatForDB»_icalText }}
         *
         * @param string $string The given output string
         *
         * @return string Processed string for ics output
         */
        public function formatIcalText($string)
        {
            $result = preg_replace('/<a href="(.*)">.*<\/a>/i', "$1", $string);
            $result = str_replace('€', 'Euro', $result);
            $result = ereg_replace("(\r\n|\n|\r)", '=0D=0A', $result);

            return ';LANGUAGE=' . $this->request->getLocale() . ';ENCODING=QUOTED-PRINTABLE:' . $result . "\r\n";
        }
    '''
}
