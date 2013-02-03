package org.zikula.modulestudio.generator.cartridges.zclassic.view.plugin

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ActionUrl {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    def generate(Application it, IFileSystemAccess fsa) {
        fsa.generateFile(viewPluginFilePath('modifier', 'ActionUrl'), actionUrlFile)
    }

    def private actionUrlFile(Application it) '''
        «new FileHelper().phpFileHeader(it)»
        «actionUrlImpl»
    '''

    def private actionUrlImpl(Application it) '''
        /**
         * The «appName.formatForDB»ActionUrl modifier creates the URL for a given action.
         *
         * @param string $urlType      The url type (admin, user, etc.)
         * @param string $urlFunc      The url func (view, display, edit, etc.)
         * @param array  $urlArguments The argument array containing ids and other additional parameters
         *
         * @return string Desired url in encoded form.
         */
        function smarty_modifier_«appName.formatForDB»ActionUrl($urlType, $urlFunc, $urlArguments)
        {
            return \DataUtil::formatForDisplay(\ModUtil::url('«appName»', $urlType, $urlFunc, $urlArguments));
        }
    '''
}
