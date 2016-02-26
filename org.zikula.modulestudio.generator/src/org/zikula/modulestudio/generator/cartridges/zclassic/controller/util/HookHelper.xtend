package org.zikula.modulestudio.generator.cartridges.zclassic.controller.util

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

    FileHelper fh = new FileHelper

    /**
     * Entry point for the utility class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (!hasHookSubscribers) {
            return
        }

        println('Generating utility class for hook calls')
        val helperFolder = if (targets('1.3.x')) 'Util' else 'Helper'
        generateClassPair(fsa, getAppSourceLibPath + helperFolder + '/Hook' + (if (targets('1.3.x')) '' else 'Helper') + '.php',
            fh.phpFileContent(it, hookFunctionsBaseImpl), fh.phpFileContent(it, hookFunctionsImpl)
        )
        if (targets('1.3.x')) {
            return
        }
        println('Generating utility class for hook bundles')
        generateClassPair(fsa, getAppSourceLibPath + 'Container/HookContainer.php',
            fh.phpFileContent(it, hookContainerBaseImpl), fh.phpFileContent(it, hookContainerImpl)
        )
    }

    def private hookFunctionsBaseImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Helper\Base;

            use Zikula\Component\HookDispatcher\Hook;
            use Zikula\Component\HookDispatcher\HookDispatcher;
            use Zikula\Core\Doctrine\EntityAccess;
            use Zikula\Core\Hook\ProcessHook;
            use Zikula\Core\Hook\ValidationHook;
            use Zikula\Core\Hook\ValidationProviders;
            use Zikula\Core\RouteUrl;

        «ENDIF»
        /**
         * Utility base class for hook related helper methods.
         */
        class «IF targets('1.3.x')»«appName»_Util_Base_Hook extends Zikula_AbstractBase«ELSE»HookHelper«ENDIF»
        {
            «IF !targets('1.3.x')»
                /**
                 * @var HookDispatcher
                 */
                protected $hookDispatcher;

                /**
                 * Constructor.
                 * Initialises member vars.
                 *
                 * @param HookDispatcher $hookDispatcher Hook dispatcher service instance.
                 */
                public function __construct($hookDispatcher)
                {
                    $this->hookDispatcher = $hookDispatcher;
                }

            «ENDIF»
            «callValidationHooks»

            «callProcessHooks»

            «dispatchHooks»
        }
    '''

    def private callValidationHooks(Application it) '''
        /**
         * Calls validation hooks.
         *
         * @param «IF targets('1.3.x')»Zikula_«ENDIF»EntityAccess $entity   The currently processed entity.
         * @param string«IF targets('1.3.x')»       «ENDIF»       $hookType Name of hook type to be called.
         *
         * @return boolean Whether validation is passed or not.
         */
        public function callValidationHooks($entity, $hookType)
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            «IF targets('1.3.x')»
                $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
                $validators = $this->notifyHooks($hook)->getValidators();
            «ELSE»
                $hook = new ValidationHook(new ValidationProviders());
                $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
            «ENDIF»

            return !$validators->hasErrors();
        }
    '''

    def private callProcessHooks(Application it) '''
        /**
         * Calls process hooks.
         *
         * @param «IF targets('1.3.x')»Zikula_«ENDIF»EntityAccess $entity The currently processed entity.
         * @param string«IF targets('1.3.x')»       «ENDIF»       $hookType Name of hook type to be called.
        «IF targets('1.3.x')»
            «' '»* @param Zikula_ModUrl       $url      The url object.
        «ELSE»
            «' '»* @param RouteUrl     $url      The url object.
        «ENDIF»
         */
        public function callProcessHooks($entity, $hookType, $url)
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            «IF targets('1.3.x')»
                $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier(), $url);
                $this->notifyHooks($hook);
            «ELSE»
                $hook = new ProcessHook($entity->createCompositeIdentifier(), $url);
                $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
            «ENDIF»
        }
    '''

    def private dispatchHooks(Application it) '''
        «IF targets('1.3.x')»
            /**
             * Notify any hookable events.
             *
             * @param Zikula_HookInterface $hook Hook interface.
             *
             * @return Zikula_HookInterface
             */
            public function notifyHooks(Hook $hook)
            {
                $serviceManager = ServiceUtil::getManager();

                return $serviceManager->getService('zikula.hookmanager')->notify($hook);
            }
        «ELSE»
            /**
             * Dispatch hooks.
             *
             * @param string $name Hook event name.
             * @param Hook   $hook Hook interface.
             *
             * @return Hook
             */
            public function dispatchHooks($name, Hook $hook)
            {
                return $this->hookDispatcher->dispatch($name, $hook);
            }
        «ENDIF»
    '''

    def private hookFunctionsImpl(Application it) '''
        «IF !targets('1.3.x')»
            namespace «appNamespace»\Helper;

            use «appNamespace»\Helper\Base\HookHelper as BaseHookHelper;

        «ENDIF»
        /**
         * Utility implementation class for hook related helper methods.
         */
        «IF targets('1.3.x')»
        class «appName»_Util_Hook extends «appName»_Util_Base_Hook
        «ELSE»
        class HookHelper extends BaseHookHelper
        «ENDIF»
        {
            // feel free to add your own convenience methods here
        }
    '''

    def private hookContainerBaseImpl(Application it) '''
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

    def private hookContainerImpl(Application it) '''
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
