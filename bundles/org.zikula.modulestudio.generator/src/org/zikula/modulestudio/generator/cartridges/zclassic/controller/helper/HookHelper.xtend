package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.HookProviderMode
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.FormAwareProviderInnerForms
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        if (hasHookSubscribers) {
            generateHookSubscribers(fsa)
        }
        if (hasHookProviders) {
            generateHookProviders(fsa)
        }
    }

    /**
     * Entry point for hook subscribers.
     */
    def private generateHookSubscribers(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for hook calls'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/HookHelper.php', hookFunctionsBaseImpl, hookFunctionsImpl)
        'Generating hook subscriber classes'.printIfNotTesting(fsa)
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
                    fsa.generateClassPair('HookSubscriber/' + entity.name.formatForCodeCapital + subscriberType + 'Subscriber.php',
                        entity.hookSubscriberBaseImpl(category, subscriberType), entity.hookClassImpl('subscriber', category, subscriberType)
                    )
                }
            }
        }
    }

    /**
     * Entry point for hook providers.
     */
    def private generateHookProviders(Application it, IMostFileSystemAccess fsa) {
        'Generating hook provider classes'.printIfNotTesting(fsa)
        if (hasFilterHookProvider) {
            fsa.generateClassPair('HookProvider/FilterHooksProvider.php', filterHooksProviderBaseImpl, filterHooksProviderImpl)
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
                        fsa.generateClassPair('HookProvider/' + entity.name.formatForCodeCapital + providerType + 'Provider.php',
                            entity.hookProviderBaseImpl(category, providerType), entity.hookClassImpl('provider', category, providerType)
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

        use Symfony\Component\Form\Form;
        use Zikula\Bundle\HookBundle\Dispatcher\HookDispatcherInterface;
        use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareHook;
        use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareResponse;
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
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var HookDispatcherInterface
         */
        protected $hookDispatcher;

        /**
         * HookHelper constructor.
         *
         * @param HookDispatcherInterface $hookDispatcher Hook dispatcher service instance
         */
        public function __construct($hookDispatcher)
        {
            $this->hookDispatcher = $hookDispatcher;
        }

        «callValidationHooks»

        «callProcessHooks»

        «callFormDisplayHooks»

        «callFormProcessingHooks»

        «dispatchHooks»
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
            $hookAreaPrefix = str_replace('.ui_hooks.', '.form_aware_hook.', $hookAreaPrefix);

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
            $hookAreaPrefix = str_replace('.ui_hooks.', '.form_aware_hook.', $hookAreaPrefix);

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
            protected $translator;

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

    def private filterHooksProviderBaseImpl(Application it) '''
        namespace «appNamespace»\HookProvider\Base;

        use Zikula\Bundle\HookBundle\Category\FilterHooksCategory;
        use Zikula\Bundle\HookBundle\Hook\FilterHook;
        use Zikula\Bundle\HookBundle\«providerInterface(filterHookProvider)»;
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
            protected $translator;

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
            use Doctrine\ORM\QueryBuilder;
            use Symfony\Component\HttpFoundation\RequestStack;
            use Twig_Environment;
        «ENDIF»
        use Zikula\Bundle\HookBundle\Category\«category»Category;
        «IF category == 'FormAware'»
            use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareHook;
            use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareResponse;
        «ELSEIF category == 'UiHooks'»
            use Zikula\Bundle\HookBundle\Hook\DisplayHook;
            use Zikula\Bundle\HookBundle\Hook\DisplayHookResponse;
            use Zikula\Bundle\HookBundle\Hook\Hook;
            use Zikula\Bundle\HookBundle\Hook\ProcessHook;
            use Zikula\Bundle\HookBundle\Hook\ValidationHook;
        «ENDIF»
        use Zikula\Bundle\HookBundle\«providerInterface(if (category == 'FormAware') formAwareHookProvider else if (category == 'UiHooks') uiHooksProvider else HookProviderMode.ENABLED)»;
        use Zikula\Bundle\HookBundle\ServiceIdTrait;
        use Zikula\Common\Translator\TranslatorInterface;
        «IF category == 'FormAware'»
            use «application.appNamespace»\Form\Type\Hook\Delete«name.formatForCodeCapital»Type;
            use «application.appNamespace»\Form\Type\Hook\Edit«name.formatForCodeCapital»Type;
        «ELSEIF category == 'UiHooks'»
            use «application.appNamespace»\Entity\Factory\EntityFactory;
            «IF !application.getUploadEntities.empty»
                use «application.appNamespace»\Helper\ImageHelper;
            «ENDIF»
            use «application.appNamespace»\Helper\PermissionHelper;
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
            protected $translator;

            «IF category == 'FormAware'»
                /**
                 * @var SessionInterface
                 */
                protected $session;

                /**
                 * @var FormFactoryInterface
                 */
                protected $formFactory;
            «ELSEIF category == 'UiHooks'»
                /**
                 * @var RequestStack
                 */
                protected $requestStack;

                /**
                 * @var EntityFactory
                 */
                protected $entityFactory;

                /**
                 * @var Twig_Environment
                 */
                protected $templating;

                /**
                 * @var PermissionHelper
                 */
                protected $permissionHelper;
                «IF !application.getUploadEntities.empty»

                    /**
                     * @var ImageHelper
                     */
                    protected $imageHelper;
                «ENDIF»
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
             * @param RequestStack        $requestStack
             * @param EntityFactory       $entityFactory
             * @param Twig_Environment    $twig
             * @param PermissionHelper    $permissionHelper
             «IF !application.getUploadEntities.empty»
             * @param ImageHelper         $imageHelper
             «ENDIF»
             «ENDIF»
             */
            public function __construct(
                TranslatorInterface $translator,
                «IF category == 'FormAware'»
                    SessionInterface $session,
                    FormFactoryInterface $formFactory
                «ELSEIF category == 'UiHooks'»
                    RequestStack $requestStack,
                    EntityFactory $entityFactory,
                    Twig_Environment $twig,
                    PermissionHelper $permissionHelper«IF !application.getUploadEntities.empty»,«ENDIF»
                    «IF !application.getUploadEntities.empty»
                        ImageHelper $imageHelper
                    «ENDIF»
                «ENDIF»
            ) {
                $this->translator = $translator;
                «IF category == 'FormAware'»
                    $this->session = $session;
                    $this->formFactory = $formFactory;
                «ELSEIF category == 'UiHooks'»
                    $this->requestStack = $requestStack;
                    $this->entityFactory = $entityFactory;
                    $this->templating = $twig;
                    $this->permissionHelper = $permissionHelper;
                    «IF !application.getUploadEntities.empty»
                        $this->imageHelper = $imageHelper;
                    «ENDIF»
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
                        «category»Category::TYPE_FORM_EDIT => 'displayEdit',
                        «category»Category::TYPE_VALIDATE_EDIT => 'validateEdit',
                        «category»Category::TYPE_PROCESS_EDIT => 'processEdit',
                        «category»Category::TYPE_FORM_DELETE => 'displayDelete',
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
                    $response = $this->renderDisplayHookResponse($hook, 'hookDisplayView');
                    $hook->setResponse($response);
                }

                /**
                 * Display hook for create/edit forms.
                 *
                 * @param DisplayHook $hook
                 */
                public function displayEdit(DisplayHook $hook)
                {
                    $response = $this->renderDisplayHookResponse($hook, 'hookDisplayEdit');
                    $hook->setResponse($response);
                }

                /**
                 * Validate input from an item to be edited.
                 *
                 * @param ValidationHook $hook
                 */
                public function validateEdit(ValidationHook $hook)
                {
                    return true;
                }

                /**
                 * Perform the final update actions for an edited item.
                 *
                 * @param ProcessHook $hook
                 */
                public function processEdit(ProcessHook $hook)
                {
                    $url = $hook->getUrl();
                    if (null === $url || !is_object($url)) {
                        return;
                    }
                    $url = $url->toArray();

                    $entityManager = $this->entityFactory->getObjectManager();

                    // update url information for assignments of updated data object
                    $qb = $entityManager->createQueryBuilder();
                    $qb->select('tbl')
                       ->from($this->getHookAssignmentEntity(), 'tbl');
                    $qb = $this->addContextFilters($qb, $hook);

                    $query = $qb->getQuery();
                    $assignments = $query->getResult();

                    foreach ($assignments as $assignment) {
                        $assignment->setSubscriberUrl($url);
                    }

                    $entityManager->flush();
                }

                /**
                 * Display hook for delete forms.
                 *
                 * @param DisplayHook $hook
                 */
                public function displayDelete(DisplayHook $hook)
                {
                    $response = $this->renderDisplayHookResponse($hook, 'hookDisplayDelete');
                    $hook->setResponse($response);
                }

                /**
                 * Validate input from an item to be deleted.
                 *
                 * @param ValidationHook $hook
                 */
                public function validateDelete(ValidationHook $hook)
                {
                    return true;
                }

                /**
                 * Perform the final delete actions for a deleted item.
                 *
                 * @param ProcessHook $hook
                 */
                public function processDelete(ProcessHook $hook)
                {
                    // delete assignments of removed data object
                    $qb = $this->entityFactory->getObjectManager()->createQueryBuilder();
                    $qb->delete($this->getHookAssignmentEntity(), 'tbl');
                    $qb = $this->addContextFilters($qb, $hook);

                    $query = $qb->getQuery();
                    $query->execute();
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

                /**
                 * Returns the entity for hook assignment data.
                 *
                 * @return string
                 */
                protected function getHookAssignmentEntity()
                {
                    return '«application.vendor.formatForCodeCapital + '\\' + application.name.formatForCodeCapital + 'Module\\Entity\\HookAssignmentEntity'»';
                }

                /**
                 * Adds common hook-based filters to a given query builder.
                 *
                 * @param QueryBuilder $qb
                 * @param Hook $hook
                 *
                 * @return QueryBuilder
                 */
                protected function addContextFilters(QueryBuilder $qb, Hook $hook)
                {
                    $qb->where('tbl.subscriberOwner = :moduleName')
                       ->setParameter('moduleName', $hook->getCaller())
                       ->andWhere('tbl.subscriberAreaId = :areaId')
                       ->setParameter('areaId', $hook->getAreaId())
                       ->andWhere('tbl.subscriberObjectId = :objectId')
                       ->setParameter('objectId', $hook->getId())
                       ->andWhere('tbl.assignedEntity = :objectType')
                       ->setParameter('objectType', '«name.formatForCode»');

                    return $qb;
                }

                /**
                 * Returns a list of assigned entities for a given hook context.
                 *
                 * @param Hook $hook
                 *
                 * @return array List of assignments and assigned entities
                 */
                protected function selectAssignedEntities(Hook $hook)
                {
                    list ($assignments, $assignedIds) = $this->selectAssignedIds($hook);
                    if (!count($assignedIds)) {
                        return [[], []];
                    }

                    $entities = $this->entityFactory->getRepository('«name.formatForCode»')->selectByIdList($assignedIds);

                    return [$assignments, $entities];
                }

                /**
                 * Returns a list of assigned entity identifiers for a given hook context.
                 *
                 * @param Hook $hook
                 *
                 * @return array List of assignments and identifiers of assigned entities
                 */
                protected function selectAssignedIds(Hook $hook)
                {
                    $qb = $this->entityFactory->getObjectManager()->createQueryBuilder();
                    $qb->select('tbl')
                       ->from($this->getHookAssignmentEntity(), 'tbl');
                    $qb = $this->addContextFilters($qb, $hook);
                    $qb->add('orderBy', 'tbl.updatedDate DESC');

                    $query = $qb->getQuery();
                    $assignments = $query->getResult();

                    $assignedIds = [];
                    foreach ($assignments as $assignment) {
                        $assignedIds[] = $assignment->getAssignedId();
                    }

                    return [$assignments, $assignedIds];
                }

                /**
                 * Returns the response for a display hook of a given context.
                 *
                 * @param Hook   $hook
                 * @param string $context
                 *
                 * @return DisplayHookResponse
                 */
                protected function renderDisplayHookResponse(Hook $hook, $context)
                {
                    list ($assignments, $assignedEntities) = $this->selectAssignedEntities($hook);
                    $template = '@«application.appName»/«name.formatForCodeCapital»/includeDisplayItemListMany.html.twig';

                    $templateParameters = [
                        'items' => $assignedEntities,
                        'context' => $context,
                        'routeArea' => ''
                    ];

                    if ($context == 'hookDisplayView') {
                        // add context information to template parameters in order to provide means
                        // for adding new assignments and removing existing assignments
                        $templateParameters['assignments'] = $assignments;
                        $templateParameters['subscriberOwner'] = $hook->getCaller();
                        $templateParameters['subscriberAreaId'] = $hook->getAreaId();
                        $templateParameters['subscriberObjectId'] = $hook->getId();
                        $url = method_exists($hook, 'getUrl') ? $hook->getUrl() : null;
                        $templateParameters['subscriberUrl'] = (null !== $url && is_object($url)) ? $url->serialize() : serialize([]);
                    }
                    «IF !application.getUploadEntities.empty»

                        $templateParameters['relationThumbRuntimeOptions'] = $this->imageHelper->getCustomRuntimeOptions('', '', '«application.appName»_relateditem', 'controllerAction', ['action' => 'display']);
                    «ENDIF»
                    $templateParameters['permissionHelper'] = $this->permissionHelper;

                    $output = $this->templating->render($template, $templateParameters);

                    return new DisplayHookResponse($this->getAreaName(), $output);
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
