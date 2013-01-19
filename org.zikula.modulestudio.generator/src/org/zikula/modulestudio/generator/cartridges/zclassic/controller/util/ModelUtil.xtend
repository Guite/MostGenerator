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
        «IF !targets('1.3.5')»
            namespace «appName»\Util\Base;

        «ENDIF»
        /**
         * Utility base class for model helper methods.
         */
        «IF targets('1.3.5')»
        class «appName»_Util_Base_Model extends Zikula_AbstractBase
        «ELSE»
        class Model extends \Zikula_AbstractBase
        «ENDIF»
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
        class Model extends Base\Model
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''
}
