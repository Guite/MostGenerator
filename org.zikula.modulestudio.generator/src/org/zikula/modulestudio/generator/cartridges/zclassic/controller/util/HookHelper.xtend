package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.HookBundles
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookHelper {

    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            return
        }
        println('Generating utility class for hook bundles')
        generateClassPair(fsa, getAppSourceLibPath + 'Container/HookContainer.php',
            fh.phpFileContent(it, hookFunctionsBaseImpl), fh.phpFileContent(it, hookFunctionsImpl)
        )
    }

    def private hookFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Container\Base;

        use Zikula\Component\HookDispatcher\AbstractContainer;
        use Zikula\Component\HookDispatcher\SubscriberBundle;

        /**
         * Base class for hook container methods.
         */
        class HookContainer extends AbstractContainer
        {
            «setup»
        }
    '''

    def private setup(Application it) '''
        /**
         * Define the hook bundles supported by this module.
         *
         * @return void
         */
        protected function setupHookBundles()
        {
            «val hookHelper = new HookBundles()»
            «hookHelper.setup(it)»
        }
    '''

    def private hookFunctionsImpl(Application it) '''
        namespace «appNamespace»\Container;

        use «appNamespace»\Container\Base\HookContainer as BaseHookContainer;

        /**
         * Implementation class for hook container methods.
         */
        class HookHelper extends BaseHookContainer
        {
            // feel free to add your own convenience methods here
        }
    '''
}
