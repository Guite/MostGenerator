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
        if (targets('1.3.x')) {
            val pluginFilePath = viewPluginFilePath('modifier', 'GetListEntry')
            if (!shouldBeSkipped(pluginFilePath)) {
                fsa.generateFile(pluginFilePath, new FileHelper().phpFileContent(it, getListEntryImpl))
            }
        } else {
            getListEntryImpl
        }
    }

    def private getListEntryImpl(Application it) '''
        /**
         * The «appName.formatForDB»«IF targets('1.3.x')»GetListEntry modifier«ELSE»_listEntry filter«ENDIF» displays the name
         * or names for a given list item.
         * Example:
         *     «IF targets('1.3.x')»{$entity.listField|«appName.formatForDB»GetListEntry:'entityName':'fieldName'}«ELSE»{{ entity.listField|«appName.formatForDB»_listEntry('entityName', 'fieldName') }}«ENDIF»
         *
         * @param string $value      The dropdown value to process
         * @param string $objectType The treated object type
         * @param string $fieldName  The list field's name
         * @param string $delimiter  String used as separator for multiple selections
         *
         * @return string List item name
         */
        «IF !targets('1.3.x')»public «ENDIF»function «IF targets('1.3.x')»smarty_modifier_«appName.formatForDB»G«ELSE»g«ENDIF»etListEntry($value, $objectType = '', $fieldName = '', $delimiter = ', ')
        {
            if ((empty($value) && $value != '0') || empty($objectType) || empty($fieldName)) {
                return $value;
            }

            «IF targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $helper = new «appName»_Util_ListEntries($serviceManager);

            «ENDIF»
            return «IF targets('1.3.x')»$helper«ELSE»$this->listHelper«ENDIF»->resolve($value, $objectType, $fieldName, $delimiter);
        }
    '''
}
