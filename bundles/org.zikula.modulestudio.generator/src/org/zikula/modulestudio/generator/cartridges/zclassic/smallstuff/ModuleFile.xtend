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
        use Zikula\ExtensionsBundle\AbstractModule;

        /**
         * Bundle base class.
         */
        abstract class Abstract«appName» extends AbstractModule
        {
        }
    '''

    def private moduleInfoImpl(Application it) '''
        namespace «appNamespace»;

        use «appNamespace»\Base\Abstract«appName»;

        /**
         * Bundle implementation class.
         */
        class «appName» extends Abstract«appName»
        {
            // custom enhancements can go here
        }
    '''
}
