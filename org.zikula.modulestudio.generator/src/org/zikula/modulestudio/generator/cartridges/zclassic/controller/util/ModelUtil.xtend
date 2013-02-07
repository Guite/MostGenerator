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
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating utility class for model layer')
        val utilPath = getAppSourceLibPath + 'Util/'
        val utilSuffix = (if (targets('1.3.5')) '' else 'Util')
        fsa.generateFile(utilPath + 'Base/Model' + utilSuffix + '.php', modelFunctionsBaseFile)
        fsa.generateFile(utilPath + 'Model' + utilSuffix + '.php', modelFunctionsFile)
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
        «IF !targets('1.3.5')»
            namespace «appName»\Util\Base;

            use Zikula_AbstractBase;

        «ENDIF»
        /**
         * Utility base class for model helper methods.
         */
        class «IF targets('1.3.5')»«appName»_Util_Base_Model«ELSE»ModelUtil«ENDIF» extends Zikula_AbstractBase
        {
        }
    '''

    def private modelFunctionsImpl(Application it) '''
        «IF !targets('1.3.5')»
            namespace «appName»\Util;

        «ENDIF»
        /**
         * Utility implementation class for model helper methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_Model extends «appName»_Util_Base_Model
        «ELSE»
        class ModelUtil extends Base\ModelUtil
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
