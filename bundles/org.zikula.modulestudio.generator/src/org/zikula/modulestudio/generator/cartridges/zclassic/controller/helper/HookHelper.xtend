package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.HookBundlesLegacy
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
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
        if (!targets('1.5')) {
            println('Generating helper class for hook bundles')
            generateClassPair(fsa, getAppSourceLibPath + 'Container/HookContainer.php',
                fh.phpFileContent(it, legacyHookContainerBaseImpl), fh.phpFileContent(it, legacyHookContainerImpl)
            )
            return
        }
        println('Generating hook subscriber classes')
        for (entity : getAllEntities.filter[e|!e.skipHookSubscribers]) {
            for (subscriber : getHookSubscriberTypes.entrySet) {
                val category = subscriber.key
                val subscriberType = subscriber.value
                var generateSubscriber = false
                if (category == 'FilterHooks') {
                    generateSubscriber = true
                } else if (category == 'FormAware' && (entity.hasEditAction || entity.hasDeleteAction)) {
                    generateSubscriber = true
                } else if (category == 'UiHooks' && (entity.hasViewAction || entity.hasDisplayAction || entity.hasEditAction || entity.hasDeleteAction)) {
                    generateSubscriber = true
                }
                if (true === generateSubscriber) {
                    generateClassPair(fsa, getAppSourceLibPath + 'HookSubscriber/' + entity.name.formatForCodeCapital + subscriberType + 'Subscriber.php',
                        fh.phpFileContent(it, entity.hookSubscriberBaseImpl(category, subscriberType)), fh.phpFileContent(it, entity.hookSubscriberImpl(category, subscriberType))
                    )
                }
            }
        }
    }

    def private hookFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF targets('1.5')»
            use Symfony\Component\Form\Form;
            «IF targets('2.0')»
                use Zikula\Bundle\HookBundle\Dispatcher\HookDispatcher;
            «ENDIF»
            use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareHook;
            use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareResponse;
        «ENDIF»
        «IF targets('2.0')»
            use Zikula\Bundle\HookBundle\Hook\Hook;
            use Zikula\Bundle\HookBundle\Hook\ProcessHook;
            use Zikula\Bundle\HookBundle\Hook\ValidationHook;
            use Zikula\Bundle\HookBundle\Hook\ValidationProviders;
        «ELSE»
            use Zikula\Component\HookDispatcher\Hook;
            use Zikula\Component\HookDispatcher\HookDispatcher;
        «ENDIF»
        use Zikula\Core\Doctrine\EntityAccess;
        «IF !targets('2.0')»
            use Zikula\Core\Hook\ProcessHook;
            use Zikula\Core\Hook\ValidationHook;
            use Zikula\Core\Hook\ValidationProviders;
        «ENDIF»
        use Zikula\Core\UrlInterface;

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

            «IF targets('1.5')»
                «callFormDisplayHooks»

                «callFormProcessingHooks»

            «ENDIF»
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
         * @param EntityAccess $entity   The currently processed entity
         * @param string       $hookType Name of hook type to be called
         * @param UrlInterface $routeUrl The route url object
         */
        public function callProcessHooks($entity, $hookType, UrlInterface $routeUrl = null)
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            $hook = new ProcessHook($entity->getKey(), $routeUrl);
            $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
        }
    '''

    def private callFormDisplayHooks(Application it) '''
        /**
         * Calls form aware display hooks.
         *
         * @param Form         $form     The form instance
         * @param EntityAccess $entity   The currently processed entity
         * @param string       $hookType Name of hook type to be called
         *
         * @return FormAwareHook The created hook instance
         */
        public function callFormDisplayHooks(Form $form, $entity, $hookType)
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            $hook = new FormAwareHook($form);
            $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);

            return $hook;
        }
    '''

    def private callFormProcessingHooks(Application it) '''
        /**
         * Calls form aware processing hooks.
         *
         * @param Form         $form     The form instance
         * @param EntityAccess $entity   The currently processed entity
         * @param string       $hookType Name of hook type to be called
         * @param UrlInterface $routeUrl The route url object
         */
        public function callFormProcessHooks(Form $form, $entity, $hookType, UrlInterface $routeUrl = null)
        {
            $formResponse = new FormAwareResponse($form, $entity, $routeUrl);
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $formResponse);
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

    // 1.4 only
    def private legacyHookContainerBaseImpl(Application it) '''
        namespace «appNamespace»\Container\Base;

        use Zikula\Bundle\HookBundle\AbstractHookContainer as ZikulaHookContainer;«/* TODO see #15 use Zikula\Bundle\HookBundle\Bundle\ProviderBundle; */»
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
            «val hookHelper = new HookBundlesLegacy()»
            «hookHelper.setup(it)»
        }
    '''

    // 1.4 only
    def private legacyHookContainerImpl(Application it) '''
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

    // 1.5+ only
    def private hookSubscriberBaseImpl(Entity it, String category, String subscriberType) '''
        namespace «application.appNamespace»\HookSubscriber\Base;

        use Zikula\Bundle\HookBundle\Category\«category»Category;
        use Zikula\Bundle\HookBundle\HookSubscriberInterface;
        use Zikula\Common\Translator\TranslatorInterface;

        /**
         * Base class for form aware hook subscriber.
         */
        abstract class Abstract«name.formatForCodeCapital»«subscriberType»Subscriber implements HookSubscriberInterface
        {
            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * «name.formatForCodeCapital»«subscriberType»Subscriber constructor.
             *
             * @param TranslatorInterface $translator
             */
            public function __construct(TranslatorInterface $translator)
            {
                $this->translator = $translator;
            }

            /**
             * @inheritDoc
             */
            public function getOwner()
            {
                return '«application.appName»';
            }

            /**
             * @inheritDoc
             */
            public function getCategory()
            {
                return «category»Category::NAME;
            }

            /**
             * @inheritDoc
             */
            public function getTitle()
            {
                return $this->translator->__('«name.formatForDisplayCapital» «category.formatForDisplay» subscribers');
            }

            /**
             * @inheritDoc
             */
            public function getEvents()
            {
                return [
                    «IF category == 'FilterHooks'»
                        «category»Category::TYPE_FILTER => '«application.appName.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter'
                    «ELSEIF category == 'FormAware'»
                        «IF hasEditAction»
                            // Display hook for create/edit forms.
                            «category»Category::TYPE_EDIT => '«application.appName.formatForDB».form_aware_hook.«nameMultiple.formatForDB».edit',
                            // Process the results of the edit form after the main form is processed.
                            «category»Category::TYPE_PROCESS_EDIT => '«application.appName.formatForDB».form_aware_hook.«nameMultiple.formatForDB».process_edit'«IF hasDeleteAction»,«ENDIF»
                        «ENDIF»
                        «IF hasDeleteAction»
                            // Display hook for delete forms.
                            «category»Category::TYPE_DELETE => '«application.appName.formatForDB».form_aware_hook.«nameMultiple.formatForDB».delete',
                            // Process the results of the delete form after the main form is processed.
                            «category»Category::TYPE_PROCESS_DELETE => '«application.appName.formatForDB».form_aware_hook.«nameMultiple.formatForDB».process_delete'
                        «ENDIF»
                    «ELSEIF category == 'UiHooks'»
                        «IF hasViewAction || hasDisplayAction»
                            // Display hook for view/display templates.
                            «category»Category::TYPE_DISPLAY_VIEW => '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».display_view',
                        «ENDIF»
                        «IF hasViewAction || hasEditAction»
                            «IF hasEditAction»
                                // Display hook for create/edit forms.
                                «category»Category::TYPE_FORM_EDIT => '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_edit',
                            «ENDIF»
                            // Validate input from an item to be edited.
                            «category»Category::TYPE_VALIDATE_EDIT => '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».validate_edit',
                            // Perform the final update actions for an edited item.
                            «category»Category::TYPE_PROCESS_EDIT => '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».process_edit',
                        «ENDIF»
                        «IF hasDeleteAction»
                            // Display hook for delete forms.
                            «category»Category::TYPE_FORM_DELETE => '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».form_delete',
                        «ENDIF»
                        «IF hasViewAction || hasEditAction || hasDeleteAction»
                            // Validate input from an item to be deleted.
                            «category»Category::TYPE_VALIDATE_DELETE => '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».validate_delete',
                            // Perform the final delete actions for a deleted item.
                            «category»Category::TYPE_PROCESS_DELETE => '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».process_delete'
                        «ENDIF»
                    «ENDIF»
                ];
            }
        }
    '''

    def private hookSubscriberImpl(Entity it, String category, String subscriberType) '''
        namespace «application.appNamespace»\HookSubscriber;

        use «application.appNamespace»\HookSubscriber\Base\Abstract«name.formatForCodeCapital»«subscriberType»Subscriber;

        /**
         * Implementation class for «subscriberType.formatForDisplay» subscriber.
         */
        class «name.formatForCodeCapital»«subscriberType»Subscriber extends Abstract«name.formatForCodeCapital»«subscriberType»Subscriber
        {
            // feel free to add your own convenience methods here
        }
    '''
}
