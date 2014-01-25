package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GetListEntry {
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        val pluginFilePath = viewPluginFilePath('modifier', 'GetListEntry')
        if (!shouldBeSkipped(pluginFilePath)) {
            fsa.generateFile(pluginFilePath, getListEntryFile)
        }
    }

    def private getListEntryFile(Application it) '''
        «new FileHelper().phpFileHeader(it)»
        «getListEntryImpl»
    '''

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
            if (empty($value) || empty($objectType) || empty($fieldName)) {
                return $value;
            }

            $serviceManager = ServiceUtil::getManager();
            $helper = new «IF targets('1.3.5')»«appName»_Util_ListEntries«ELSE»«appNamespace»\Util\ListEntriesUtil«ENDIF»($serviceManager«IF !targets('1.3.5')», ModUtil::getModule('«appName»')«ENDIF»);

            return $helper->resolve($value, $objectType, $fieldName, $delimiter);
        }
    '''
}
