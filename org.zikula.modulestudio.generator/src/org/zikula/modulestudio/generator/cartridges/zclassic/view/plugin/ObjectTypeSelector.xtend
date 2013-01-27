package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ObjectTypeSelector {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(viewPluginFilePath('function', 'ObjectTypeSelector'), selectorObjectTypesFile)
    }

    def private selectorObjectTypesFile(Application it) '''
        «new FileHelper().phpFileHeader(it)»
        «selectorObjectTypesImpl»
    '''

    def private selectorObjectTypesImpl(Application it) '''
        /**
         * The «appName.formatForDB»ObjectTypeSelector plugin provides items for a dropdown selector.
         *
         * Available parameters:
         *   - assign: If set, the results are assigned to the corresponding variable instead of printed out.
         *
         * @param  array            $params All attributes passed to this function from the template.
         * @param  Zikula_Form_View $view   Reference to the view object.
         *
         * @return string The output of the plugin.
         */
        function smarty_function_«appName.formatForDB»ObjectTypeSelector($params, $view)
        {
            $result = array();

            «entityEntries»

            if (array_key_exists('assign', $params)) {
                $view->assign($params['assign'], $result);

                return;
            }

            return $result;
        }
    '''

    def private entityEntries(Application it) '''
        «FOR entity : getAllEntities»
            $result[] = array('text' => $view->__('«entity.nameMultiple.formatForDisplayCapital»'), 'value' => '«entity.name.formatForCode»');
        «ENDFOR»
    '''
}
