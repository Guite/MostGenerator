package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.HookProviderMode
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.FormAwareProviderInnerForms
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.HookBundlesLegacy
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        if (hasHookSubscribers) {
            generateHookSubscribers(fsa)
        }
        if (hasHookProviders && targets('1.5')) {
            generateHookProviders(fsa)
        }
    }

    /**
     * Entry point for hook subscribers.
     */
    def private generateHookSubscribers(Application it, IFileSystemAccess fsa) {
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
            for (hookType : getHookTypes.entrySet) {
                val category = hookType.key
                val subscriberType = hookType.value
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
                        fh.phpFileContent(it, entity.hookSubscriberBaseImpl(category, subscriberType)), fh.phpFileContent(it, entity.hookClassImpl('subscriber', category, subscriberType))
                    )
                }
            }
        }
    }

    /**
     * Entry point for hook providers.
     */
    def private generateHookProviders(Application it, IFileSystemAccess fsa) {
        val fh = new FileHelper
        println('Generating hook provider classes')
        if (hasFilterHookProvider) {
            generateClassPair(fsa, getAppSourceLibPath + 'HookProvider/FilterHooksProvider.php',
                fh.phpFileContent(it, filterHooksProviderBaseImpl), fh.phpFileContent(it, filterHooksProviderImpl)
            )
        }
        if (hasFormAwareHookProviders || hasUiHooksProviders) {
            for (hookType : getHookTypes.entrySet) {
                val category = hookType.key
                val providerType = hookType.value
                for (entity : getAllEntities) {
                    var generateProvider = false
                    if (category == 'FilterHooks') {
                    } else if (category == 'FormAware' && entity.formAwareHookProvider != HookProviderMode.DISABLED) {
                        generateProvider = true
                    } else if (category == 'UiHooks' && entity.uiHooksProvider != HookProviderMode.DISABLED) {
                        generateProvider = true
                    }
                    if (true === generateProvider) {
                        generateClassPair(fsa, getAppSourceLibPath + 'HookProvider/' + entity.name.formatForCodeCapital + providerType + 'Provider.php',
                            fh.phpFileContent(it, entity.hookProviderBaseImpl(category, providerType)), fh.phpFileContent(it, entity.hookClassImpl('provider', category, providerType))
                        )
                    }
                }
            }
            if (hasFormAwareHookProviders) {
                new FormAwareProviderInnerForms().generate(it, fsa)
            }
        }
    }

    def private hookFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF targets('1.5')»
            use Symfony\Component\Form\Form;
        «ENDIF»
        use Zikula\Bundle\HookBundle\Dispatcher\HookDispatcher;
        «IF targets('1.5')»
            use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareHook;
            use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareResponse;
        «ENDIF»
        use Zikula\Bundle\HookBundle\Hook\Hook;
        use Zikula\Bundle\HookBundle\Hook\ProcessHook;
        use Zikula\Bundle\HookBundle\Hook\ValidationHook;
        use Zikula\Bundle\HookBundle\Hook\ValidationProviders;
        use Zikula\Core\Doctrine\EntityAccess;
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
         * @return string[] List of error messages returned by validators
         */
        public function callValidationHooks($entity, $hookType)
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            $hook = new ValidationHook(new ValidationProviders());
            $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();

            return $validators->getErrors();
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

        use Zikula\Bundle\HookBundle\AbstractHookContainer as ZikulaHookContainer;
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
         * Base class for «subscriberType.formatForDisplay» subscriber.
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

            «commonMethods(application, name, category, 'subscriber')»

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

    def private hookClassImpl(Entity it, String group, String category, String hookType) '''
        namespace «application.appNamespace»\Hook«group.formatForCodeCapital»;

        use «application.appNamespace»\Hook«group.formatForCodeCapital»\Base\Abstract«name.formatForCodeCapital»«hookType»«group.formatForCodeCapital»;

        /**
         * Implementation class for «hookType.formatForDisplay» «group.formatForDisplay».
         */
        class «name.formatForCodeCapital»«hookType»«group.formatForCodeCapital» extends Abstract«name.formatForCodeCapital»«hookType»«group.formatForCodeCapital»
        {
            // feel free to add your own convenience methods here
        }
    '''

    // 1.5+ only
    def private filterHooksProviderBaseImpl(Application it) '''
        namespace «appNamespace»\HookProvider\Base;

        use Zikula\Bundle\HookBundle\Category\FilterHooksCategory;
        use Zikula\Bundle\HookBundle\Hook\FilterHook;
        use Zikula\Bundle\HookBundle\«providerInterface(filterHookProvider)»
        use Zikula\Bundle\HookBundle\ServiceIdTrait;
        use Zikula\Common\Translator\TranslatorInterface;

        /**
         * Base class for filter hooks provider.
         */
        abstract class AbstractFilterHooksProvider implements «providerInterface(filterHookProvider)»
        {
            use ServiceIdTrait;

            /**
             * @var TranslatorInterface
             */
            private $translator;

            /**
             * FilterHooksProvider constructor.
             *
             * @param TranslatorInterface $translator
             */
            public function __construct(TranslatorInterface $translator)
            {
                $this->translator = $translator;
            }

            «commonMethods(name, 'FilterHooks', 'provider')»

            /**
             * @inheritDoc
             */
            public function getProviderTypes()
            {
                return [
                    FilterHooksCategory::TYPE_FILTER => ['applyFilter']
                ];
            }

            /**
             * Filters the given data.
             *
             * @param FilterHook $hook
             */
            public function applyFilter(FilterHook $hook)
            {
                $hook->setData($hook->getData() . '<p>' . $this->translator->__('This is a dummy addition by a generated filter provider.') . '</p>');
            }
        }
    '''

    def private filterHooksProviderImpl(Application it) '''
        namespace «appNamespace»\HookProvider;

        use Zikula\Bundle\HookBundle\Hook\FilterHook;
        use «appNamespace»\HookProvider\Base\AbstractFilterHooksProvider;

        /**
         * Implementation class for filter hooks provider.
         */
        class FilterHooksProvider extends AbstractFilterHooksProvider
        {
            /**
             * @inheritDoc
             */
            public function applyFilter(FilterHook $hook)
            {
                // replace this by your own filter operation
                parent::applyFilter($hook);
            }

            // feel free to add your own convenience methods here
        }
    '''

    def private hookProviderBaseImpl(Entity it, String category, String providerType) '''
        namespace «application.appNamespace»\HookProvider\Base;

        «IF category == 'FormAware'»
            use Symfony\Component\Form\FormFactoryInterface;
            use Symfony\Component\HttpFoundation\Session\SessionInterface;
        «ELSEIF category == 'UiHooks'»
            use Symfony\Component\HttpFoundation\RequestStack;
        «ENDIF»
        use Zikula\Bundle\HookBundle\Category\«category»Category;
        «IF category == 'FormAware'»
            use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareHook;
            use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareResponse;
        «ELSEIF category == 'UiHooks'»
            use Zikula\Bundle\HookBundle\Hook\DisplayHook;
            use Zikula\Bundle\HookBundle\Hook\DisplayHookResponse;
            use Zikula\Bundle\HookBundle\Hook\ProcessHook;
            use Zikula\Bundle\HookBundle\Hook\ValidationHook;
            use Zikula\Bundle\HookBundle\Hook\ValidationResponse;
        «ENDIF»
        use Zikula\Bundle\HookBundle\«providerInterface(if (category == 'FormAware') formAwareHookProvider else if (category == 'UiHooks') uiHooksProvider else HookProviderMode.ENABLED)»
        use Zikula\Bundle\HookBundle\ServiceIdTrait;
        use Zikula\Common\Translator\TranslatorInterface;
        «IF category == 'FormAware'»
            use «application.appNamespace»\Form\Type\Hook\Delete«name.formatForCodeCapital»Type;
            use «application.appNamespace»\Form\Type\Hook\Edit«name.formatForCodeCapital»Type;
        «ENDIF»

        /**
         * Base class for «providerType.formatForDisplay» provider.
         */
        abstract class Abstract«name.formatForCodeCapital»«providerType»Provider implements «providerInterface(if (category == 'FormAware') formAwareHookProvider else if (category == 'UiHooks') uiHooksProvider else HookProviderMode.ENABLED)»
        {
            use ServiceIdTrait;

            /**
             * @var TranslatorInterface
             */
            private $translator;

            «IF category == 'FormAware'»
                /**
                 * @var SessionInterface
                 */
                private $session;

                /**
                 * @var FormFactoryInterface
                 */
                private $formFactory;
            «ELSEIF category == 'UiHooks'»
                /**
                 * @var RequestStack
                 */
                private $requestStack;
            «ENDIF»

            /**
             * «name.formatForCodeCapital»«providerType»Provider constructor.
             *
             «IF category == 'FormAware'»
             * @param TranslatorInterface  $translator
             * @param SessionInterface     $session
             * @param FormFactoryInterface $formFactory
             «ELSEIF category == 'UiHooks'»
             * @param TranslatorInterface $translator
             «/*TODO*/»
             «ENDIF»
             */
            public function __construct(
                TranslatorInterface $translator,
                «IF category == 'FormAware'»
                    SessionInterface $session,
                    FormFactoryInterface $formFactory
                «ELSEIF category == 'UiHooks'»
                    RequestStack $requestStack
                «ENDIF»
            ) {
                $this->translator = $translator;
                «IF category == 'FormAware'»
                    $this->session = $session;
                    $this->formFactory = $formFactory;
                «ELSEIF category == 'UiHooks'»
                    $this->requestStack = $requestStack;
                «ENDIF»
            }

            «commonMethods(application, name, category, 'provider')»

            /**
             * @inheritDoc
             */
            public function getProviderTypes()
            {
                return [
                    «IF category == 'FormAware'»
                        «category»Category::TYPE_EDIT => 'edit',
                        «category»Category::TYPE_PROCESS_EDIT => 'processEdit',
                        «category»Category::TYPE_DELETE => 'delete',
                        «category»Category::TYPE_PROCESS_DELETE => 'processDelete'
                    «ELSEIF category == 'UiHooks'»
                        «category»Category::TYPE_DISPLAY_VIEW => 'view',«/*['view', 'display', 'display_more']*/»
                        «category»Category::TYPE_FORM_EDIT => 'edit',
                        «category»Category::TYPE_VALIDATE_EDIT => 'validateEdit',
                        «category»Category::TYPE_PROCESS_EDIT => 'processEdit',
                        «category»Category::TYPE_FORM_DELETE => 'delete',
                        «category»Category::TYPE_VALIDATE_DELETE => 'validateDelete',
                        «category»Category::TYPE_PROCESS_DELETE => 'processDelete'
                    «ENDIF»
                ];
            }

            «IF category == 'FormAware'»
                /**
                 * Provide the inner editing form.
                 *
                 * @param FormAwareHook $hook
                 */
                public function edit(FormAwareHook $hook)
                {
                    $innerForm = $this->formFactory->create(Edit«name.formatForCodeCapital»Type::class, null, [
                        'auto_initialize' => false,«/* required */»
                        'mapped' => false«/* required */»
                    ]);
                    $hook
                        ->formAdd($innerForm)
                        ->addTemplate('@«application.appName»/Hook/edit«name.formatForCodeCapital»Form.html.twig')
                    ;
                }

                /**
                 * Process the inner editing form.
                 *
                 * @param FormAwareResponse $hook
                 */
                public function processEdit(FormAwareResponse $hook)
                {
                    $innerForm = $hook->getFormData('«application.appName.formatForDB»_hook_edit«name.formatForDB»form');
                    $dummyOutput = $innerForm['dummyName'] . ' (Option ' . $innerForm['dummyChoice'] . ')';
                    $this->session->getFlashBag()->add('success', sprintf('The «name.formatForCodeCapital»«providerType»Provider edit form was processed and the answer was %s', $dummyOutput));
                }

                /**
                 * Provide the inner deletion form.
                 *
                 * @param FormAwareHook $hook
                 */
                public function delete(FormAwareHook $hook)
                {
                    $innerForm = $this->formFactory->create(Delete«name.formatForCodeCapital»Type::class, null, [
                        'auto_initialize' => false,«/* required */»
                        'mapped' => false«/* required */»
                    ]);
                    $hook
                        ->formAdd($innerForm)
                        ->addTemplate('@«application.appName»/Hook/delete«name.formatForCodeCapital»Form.html.twig')
                    ;
                }

                /**
                 * Process the inner deletion form.
                 *
                 * @param FormAwareResponse $hook
                 */
                public function processDelete(FormAwareResponse $hook)
                {
                    $innerForm = $hook->getFormData('«application.appName.formatForDB»_hook_delete«name.formatForDB»form');
                    $dummyOutput = $innerForm['dummyName'] . ' (Option ' . $innerForm['dummyChoice'] . ')';
                    $this->session->getFlashBag()->add('success', sprintf('The «name.formatForCodeCapital»«providerType»Provider delete form was processed and the answer was %s', $dummyOutput));
                }
            «ELSEIF category == 'UiHooks'»
                /**
                 * Display hook for view/display templates.
                 *
                 * @param DisplayHook $hook
                 */
                public function view(DisplayHook $hook)
                {
                    // $hook->getAreaId(), $hook->getId(), $hook->getUrl() [UrlInterface]
                    $hook->setResponse(new DisplayHookResponse($this->getAreaName(), 'This is the «name.formatForCodeCapital» Display Hook Response.'));
                }

                /**
                 * Display hook for create/edit forms.
                 *
                 * @param DisplayHook $hook
                 */
                public function edit(DisplayHook $hook)
                {
                    // $hook->getAreaId(), $hook->getId(), $hook->getUrl() [UrlInterface]
                    $hook->setResponse(new DisplayHookResponse($this->getAreaName(), '<div>«name.formatForCodeCapital» content hooked.</div><input name="«application.appName.formatForDB»[name]" value="zikula" type="hidden">'));
                }

                /**
                 * Validate input from an item to be edited.
                 *
                 * @param ValidationHook $hook
                 */
                public function validateEdit(ValidationHook $hook)
                {
                    $request = $this->requestStack->getCurrentRequest();
                    $post = $request->request->all();
                    if ($request->request->has('«application.appName.formatForDB»') && $post['«application.appName.formatForDB»']['name'] == 'zikula') {
                        return true;
                    }
                    $response = new ValidationResponse('mykey', $post['«application.appName.formatForDB»']);
                    $response->addError('name', sprintf('Name must be zikula but was %s', $post['«application.appName.formatForDB»']['name']));
                    $hook->setValidator($this->getAreaName(), $response);

                    return false;
                }

                /**
                 * Perform the final update actions for an edited item.
                 *
                 * @param ProcessHook $hook
                 */
                public function processEdit(ProcessHook $hook)
                {
                    // $hook->getAreaId(), $hook->getId(), $hook->getUrl() [UrlInterface]
                    $this->requestStack->getCurrentRequest()->getSession()->getFlashBag()->add('success', 'Ui hook properly processed!');
                }

                /**
                 * Display hook for delete forms.
                 *
                 * @param DisplayHook $hook
                 */
                public function delete(DisplayHook $hook)
                {
                    // $hook->getAreaId(), $hook->getId(), $hook->getUrl() [UrlInterface]
                    $hook->setResponse(new DisplayHookResponse($this->getAreaName(), '<div>«name.formatForCodeCapital» content hooked.</div><input name="«application.appName.formatForDB»[name]" value="zikula" type="hidden">'));
                }

                /**
                 * Validate input from an item to be deleted.
                 *
                 * @param ValidationHook $hook
                 */
                public function validateDelete(ValidationHook $hook)
                {
                    $request = $this->requestStack->getCurrentRequest();
                    $post = $request->request->all();
                    if ($request->request->has('«application.appName.formatForDB»') && $post['«application.appName.formatForDB»']['name'] == 'zikula') {
                        return true;
                    }
                    $response = new ValidationResponse('mykey', $post['«application.appName.formatForDB»']);
                    $response->addError('name', sprintf('Name must be zikula but was %s', $post['«application.appName.formatForDB»']['name']));
                    $hook->setValidator($this->getAreaName(), $response);

                    return false;
                }

                /**
                 * Perform the final delete actions for a deleted item.
                 *
                 * @param ProcessHook $hook
                 */
                public function processDelete(ProcessHook $hook)
                {
                    // $hook->getAreaId(), $hook->getId(), $hook->getUrl() [UrlInterface]
                    $this->requestStack->getCurrentRequest()->getSession()->getFlashBag()->add('success', 'Ui hook properly processed!');
                }

                /**
                 * Returns the area name used by this provider.
                 *
                 * @return string
                 */
                protected function getAreaName()
                {
                    return 'provider.«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB»';
                }
            «ENDIF»
        }
    '''

    def private commonMethods(Application it, String group, String category, String type) '''
        /**
         * @inheritDoc
         */
        public function getOwner()
        {
            return '«appName»';
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
            return $this->translator->__('«group.formatForDisplayCapital» «category.formatForDisplay» «type»');
        }
    '''
}
