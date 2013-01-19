package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleFile {
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
        val modulePrefix = if (!targets('1.3.5')) appName else ''
        val moduleFileName = modulePrefix + 'Module.php'
        fsa.generateFile(getAppSourceLibPath + 'Base/' + moduleFileName, moduleBaseFile)
        fsa.generateFile(getAppSourceLibPath + moduleFileName, moduleFile)
    }

    def private moduleBaseFile(Application it) '''
        «fh.phpFileHeader(it)»
        «moduleBaseImpl»
    '''

    def private moduleFile(Application it) '''
        «fh.phpFileHeader(it)»
        «moduleInfoImpl»
    '''

    def private moduleBaseImpl(Application it) '''
        namespace «appName»\Base;

        use Zikula\Bundle\CoreBundle\AbstractModule;

        /**
         * Version information base class.
         */
        class «appName»Module extends AbstractModule
        {
        }
    '''

    def private moduleInfoImpl(Application it) '''
        namespace «appName»;

        /**
         * Module implementation class.
         */
        class «appName»Module extends Base\«appName»Module
        {
            // custom enhancements can go here
        }
    '''
}
