package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class FormatIcalText {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('modifier', 'FormatIcalText')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, formatIcalTextImpl))
        }
    }

    def private formatIcalTextImpl(Application it) '''
        /**
         * The «appName.formatForDB»FormatIcalText modifier outputs a given text for the ics output format.
         *
         * @param string $string The given output string.
         *
         * @return string Processed string for ics.
         */
        function smarty_modifier_«appName.formatForDB»FormatIcalText($string)
        {
            $result = preg_replace('/<a href="(.*)">.*<\/a>/i', "$1", $string);
            $result = str_replace("€", "Euro", $result);
            $result = ereg_replace("(\r\n|\n|\r)", "=0D=0A", $result);

            return ';LANGUAGE={usergetlang};ENCODING=QUOTED-PRINTABLE:' . $result . "\r\n";
        }
    '''
}
