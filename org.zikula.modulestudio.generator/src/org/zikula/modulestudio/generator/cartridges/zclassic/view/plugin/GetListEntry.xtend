package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetListEntry {
    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('modifier', 'GetListEntry')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, getListEntryImpl))
        }
    }

    def private getListEntryImpl(Application it) '''
        /**
         * The «appName.formatForDB»GetListEntry modifier displays the name
         * or names for a given list item.
         *
         * @param string $value      The dropdown value to process.
         * @param string $objectType The treated object type.
         * @param string $fieldName  The list field's name.
         * @param string $delimiter  String used as separator for multiple selections.
         *
         * @return string List item name.
         */
        function smarty_modifier_«appName.formatForDB»GetListEntry($value, $objectType = '', $fieldName = '', $delimiter = ', ')
        {
            if ((empty($value) && $value != '0') || empty($objectType) || empty($fieldName)) {
                return $value;
            }

            $serviceManager = ServiceUtil::getManager();
            «IF targets('1.3.x')»
                $helper = new «appName»_Util_ListEntries($serviceManager);
            «ELSE»
                $helper = $serviceManager->get('«appName.formatForDB».listentries_helper');
            «ENDIF»

            return $helper->resolve($value, $objectType, $fieldName, $delimiter);
        }
    '''
}
