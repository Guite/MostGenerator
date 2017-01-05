package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.HookBundles
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookHelper {

    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasHookSubscribers) {
            return
        }
        val fh = new FileHelper
        println('Generating helper class for hook calls')
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/HookHelper.php',
            fh.phpFileContent(it, hookFunctionsBaseImpl), fh.phpFileContent(it, hookFunctionsImpl)
        )
        println('Generating helper class for hook bundles')
        generateClassPair(fsa, getAppSourceLibPath + 'Container/HookContainer.php',
            fh.phpFileContent(it, hookContainerBaseImpl), fh.phpFileContent(it, hookContainerImpl)
        )
    }

    def private hookFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Zikula\Component\HookDispatcher\Hook;
        use Zikula\Component\HookDispatcher\HookDispatcher;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\Core\Hook\ProcessHook;
        use Zikula\Core\Hook\ValidationHook;
        use Zikula\Core\Hook\ValidationProviders;
        use Zikula\Core\RouteUrl;

        /**
         * Helper base class for hook related methods.
         */
        abstract class AbstractHookHelper
        {
            /**
             * @var HookDispatcher
             */
            protected $hookDispatcher;

            /**
             * HookHelper constructor.
             *
             * @param HookDispatcher $hookDispatcher Hook dispatcher service instance
             */
            public function __construct($hookDispatcher)
            {
                $this->hookDispatcher = $hookDispatcher;
            }

            «callValidationHooks»

            «callProcessHooks»

            «dispatchHooks»
        }
    '''

    def private callValidationHooks(Application it) '''
        /**
         * Calls validation hooks.
         *
         * @param EntityAccess $entity   The currently processed entity
         * @param string       $hookType Name of hook type to be called
         *
         * @return boolean Whether validation is passed or not
         */
        public function callValidationHooks($entity, $hookType)
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            $hook = new ValidationHook(new ValidationProviders());
            $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();

            return !$validators->hasErrors();
        }
    '''

    def private callProcessHooks(Application it) '''
        /**
         * Calls process hooks.
         *
         * @param EntityAccess $entity The currently processed entity
         * @param string       $hookType Name of hook type to be called
         * @param RouteUrl     $url      The url object
         */
        public function callProcessHooks($entity, $hookType, $url)
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            $hook = new ProcessHook($entity->createCompositeIdentifier(), $url);
            $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
        }
    '''

    def private dispatchHooks(Application it) '''
        /**
         * Dispatch hooks.
         *
         * @param string $name Hook event name
         * @param Hook   $hook Hook interface
         *
         * @return Hook
         */
        public function dispatchHooks($name, Hook $hook)
        {
            return $this->hookDispatcher->dispatch($name, $hook);
        }
    '''

    def private hookFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractHookHelper;

        /**
         * Helper implementation class for hook related methods.
         */
        class HookHelper extends AbstractHookHelper
        {
            // feel free to add your own convenience methods here
        }
    '''

    def private hookContainerBaseImpl(Application it) '''
        namespace «appNamespace»\Container\Base;

        use Zikula\Bundle\HookBundle\AbstractHookContainer as ZikulaHookContainer;
        «/* TODO see #15 use Zikula\Bundle\HookBundle\Bundle\ProviderBundle; */»
        use Zikula\Bundle\HookBundle\Bundle\SubscriberBundle;

        /**
         * Base class for hook container methods.
         */
        abstract class AbstractHookContainer extends ZikulaHookContainer
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

    def private hookContainerImpl(Application it) '''
        namespace «appNamespace»\Container;

        use «appNamespace»\Container\Base\AbstractHookContainer;

        /**
         * Implementation class for hook container methods.
         */
        class HookContainer extends AbstractHookContainer
        {
            // feel free to add your own convenience methods here
        }
    '''
}
