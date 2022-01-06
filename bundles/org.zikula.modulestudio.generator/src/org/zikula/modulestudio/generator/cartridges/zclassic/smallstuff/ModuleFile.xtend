package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.Utils

class ModuleFile {

    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateClassPair(appName + '.php', moduleBaseClass, moduleInfoImpl)
    }

    def private moduleBaseClass(Application it) '''
        namespace «appNamespace»\Base;

        «moduleBaseImpl»
    '''

    def private moduleBaseImpl(Application it) '''
        «IF isSystemModule»
            use Zikula\ExtensionsModule\AbstractCoreModule;
        «ELSE»
            use Zikula\ExtensionsModule\AbstractModule;
        «ENDIF»

        /**
         * Module base class.
         */
        abstract class Abstract«appName» extends Abstract«IF isSystemModule»Core«ENDIF»Module
        {
        }
    '''

    def private moduleInfoImpl(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\Abstract«appName»;

        /**
         * Module implementation class.
         */
        class «appName» extends Abstract«appName»
        {
            // custom enhancements can go here
        }
    '''
}
