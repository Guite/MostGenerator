package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModelUtil {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    /**
     * Entry point for the Util class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for model layer')
        val utilPath = appName.getAppSourceLibPath + 'Util/'
        fsa.generateFile(utilPath + 'Base/Model.php', modelFunctionsBaseFile)
        fsa.generateFile(utilPath + 'Model.php', modelFunctionsFile)
    }

    def private modelFunctionsBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «modelFunctionsBaseImpl»
    '''

    def private modelFunctionsFile(Application it) '''
        «fh.phpFileHeader(it)»
        «modelFunctionsImpl»
    '''

    def private modelFunctionsBaseImpl(Application it) '''
        /**
         * Utility base class for model helper methods.
         */
        class «appName»_«fillingUtil»Base_Model extends Zikula_AbstractBase
        {
        }
    '''

    def private modelFunctionsImpl(Application it) '''
        /**
         * Utility implementation class for model helper methods.
         */
        class «appName»_«fillingUtil»Model extends «appName»_«fillingUtil»Base_Model
        {
            // feel free to add your own convenience methods here
        }
    '''
}
