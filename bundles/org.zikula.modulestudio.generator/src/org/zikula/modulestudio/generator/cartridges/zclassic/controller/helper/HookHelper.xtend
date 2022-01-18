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

        use Symfony\Component\Form\FormInterface;
        use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
        use Zikula\Bundle\CoreBundle\UrlInterface;
        use Zikula\Bundle\HookBundle\Dispatcher\HookDispatcherInterface;
        use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareHook;
        use Zikula\Bundle\HookBundle\FormAwareHook\FormAwareResponse;
        use Zikula\Bundle\HookBundle\Hook\Hook;
        use Zikula\Bundle\HookBundle\Hook\ProcessHook;
        use Zikula\Bundle\HookBundle\Hook\ValidationHook;
        use Zikula\Bundle\HookBundle\Hook\ValidationProviders;

        /**
         * Helper base class for hook related methods.
         */
        abstract class AbstractHookHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        public function __construct(protected HookDispatcherInterface $hookDispatcher)
        {
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
         * @return string[] List of error messages returned by validators
         */
        public function callValidationHooks(EntityAccess $entity, string $hookType): array
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
         */
        public function callProcessHooks(EntityAccess $entity, string $hookType, ?UrlInterface $routeUrl = null): void
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();

            $hook = new ProcessHook($entity->getKey(), $routeUrl);
            $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
        }
    '''

    def private callFormDisplayHooks(Application it) '''
        /**
         * Calls form aware display hooks.
         */
        public function callFormDisplayHooks(FormInterface $form, EntityAccess $entity, string $hookType): FormAwareHook
        {
            $hookAreaPrefix = $entity->getHookAreaPrefix();
            $hookAreaPrefix = str_replace('.ui_hooks.', '.form_aware_hook.', $hookAreaPrefix);

            $hook = new FormAwareHook($form, $entity->getKey());
            $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);

            return $hook;
        }
    '''

    def private callFormProcessingHooks(Application it) '''
        /**
         * Calls form aware processing hooks.
         */
        public function callFormProcessHooks(
            FormInterface $form,
            EntityAccess $entity,
            string $hookType,
            ?UrlInterface $routeUrl = null
        ): void {
            $formResponse = new FormAwareResponse($form, $entity, $routeUrl);
            $hookAreaPrefix = $entity->getHookAreaPrefix();
            $hookAreaPrefix = str_replace('.ui_hooks.', '.form_aware_hook.', $hookAreaPrefix);

            $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $formResponse);
        }
    '''

    def private dispatchHooks(Application it) '''
        /**
         * Dispatch hooks.
         */
        public function dispatchHooks(string $eventName, Hook $hook)
        {
            return $this->hookDispatcher->dispatch($eventName, $hook);
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

        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\Bundle\HookBundle\Category\«category»Category;
        use Zikula\Bundle\HookBundle\HookSubscriberInterface;

        /**
         * Base class for «subscriberType.formatForDisplay» subscriber.
         */
        abstract class Abstract«name.formatForCodeCapital»«subscriberType»Subscriber implements HookSubscriberInterface
        {
            public function __construct(protected TranslatorInterface $translator)
            {
            }

            «commonMethods(application, name, category, 'subscriber', nameMultiple.formatForDB)»

            public function getEvents(): array
            {
                return [
                    «IF category == 'FilterHooks'»
                        «category»Category::TYPE_FILTER => '«application.appName.formatForDB».filter_hooks.«nameMultiple.formatForDB».filter',
                    «ELSEIF category == 'FormAware'»
                        «IF hasEditAction»
                            // Display hook for create/edit forms.
                            «category»Category::TYPE_EDIT => '«application.appName.formatForDB».form_aware_hook.«nameMultiple.formatForDB».edit',
                            // Process the results of the edit form after the main form is processed.
                            «category»Category::TYPE_PROCESS_EDIT => '«application.appName.formatForDB».form_aware_hook.«nameMultiple.formatForDB».process_edit',
                        «ENDIF»
                        «IF hasDeleteAction»
                            // Display hook for delete forms.
                            «category»Category::TYPE_DELETE => '«application.appName.formatForDB».form_aware_hook.«nameMultiple.formatForDB».delete',
                            // Process the results of the delete form after the main form is processed.
                            «category»Category::TYPE_PROCESS_DELETE => '«application.appName.formatForDB».form_aware_hook.«nameMultiple.formatForDB».process_delete',
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
                            «category»Category::TYPE_PROCESS_DELETE => '«application.appName.formatForDB».ui_hooks.«nameMultiple.formatForDB».process_delete',
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

        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\Bundle\HookBundle\Category\FilterHooksCategory;
        use Zikula\Bundle\HookBundle\Hook\FilterHook;
        use Zikula\Bundle\HookBundle\«providerInterface(filterHookProvider)»;

        /**
         * Base class for filter hooks provider.
         */
        abstract class AbstractFilterHooksProvider implements «providerInterface(filterHookProvider)»
        {
            public function __construct(protected TranslatorInterface $translator)
            {
            }

            «commonMethods(name, 'FilterHooks', 'provider', name.formatForDB)»

            public function getProviderTypes(): array
            {
                return [
                    FilterHooksCategory::TYPE_FILTER => ['applyFilter'],
                ];
            }

            /**
             * Filters the given data.
             */
            public function applyFilter(FilterHook $hook): void
            {
                $hook->setData(
                    $hook->getData()
                    . '<p>'
                    . $this->translator->trans('This is a dummy addition by a generated filter provider.'«IF !isSystemModule», [], 'hooks'«ENDIF»)
                    . '</p>'
                );
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
            public function applyFilter(FilterHook $hook): void
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
        «ELSEIF category == 'UiHooks'»
            use Doctrine\ORM\QueryBuilder;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Contracts\Translation\TranslatorInterface;
        «IF category == 'UiHooks'»
            use Twig\Environment;
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
            public function __construct(
                protected TranslatorInterface $translator,
                protected RequestStack $requestStack,
                «IF category == 'FormAware'»
                    protected FormFactoryInterface $formFactory
                «ELSEIF category == 'UiHooks'»
                    protected EntityFactory $entityFactory,
                    protected Environment $twig,
                    protected PermissionHelper $permissionHelper«IF !application.getUploadEntities.empty»,«ENDIF»
                    «IF !application.getUploadEntities.empty»
                        protected ImageHelper $imageHelper
                    «ENDIF»
                «ENDIF»
            ) {
            }

            «commonMethods(application, name, category, 'provider', nameMultiple.formatForDB)»

            public function getProviderTypes(): array
            {
                return [
                    «IF category == 'FormAware'»
                        «category»Category::TYPE_EDIT => 'edit',
                        «category»Category::TYPE_PROCESS_EDIT => 'processEdit',
                        «category»Category::TYPE_DELETE => 'delete',
                        «category»Category::TYPE_PROCESS_DELETE => 'processDelete',
                    «ELSEIF category == 'UiHooks'»
                        «category»Category::TYPE_DISPLAY_VIEW => 'view',«/*['view', 'display', 'display_more']*/»
                        «category»Category::TYPE_FORM_EDIT => 'displayEdit',
                        «category»Category::TYPE_VALIDATE_EDIT => 'validateEdit',
                        «category»Category::TYPE_PROCESS_EDIT => 'processEdit',
                        «category»Category::TYPE_FORM_DELETE => 'displayDelete',
                        «category»Category::TYPE_VALIDATE_DELETE => 'validateDelete',
                        «category»Category::TYPE_PROCESS_DELETE => 'processDelete',
                    «ENDIF»
                ];
            }

            «IF category == 'FormAware'»
                /**
                 * Provide the inner editing form.
                 */
                public function edit(FormAwareHook $hook): void
                {
                    $hook
                        ->formAdd('«application.appName.formatForDB»_hook_edit«name.formatForDB»', Edit«name.formatForCodeCapital»Type::class, [
                            'auto_initialize' => false,«/* required */»
                            'mapped' => false«/* required */»
                        ])
                        ->addTemplate('@«application.appName»/Hook/edit«name.formatForCodeCapital»Form.html.twig', [
                            'testMessage' => 'This is a test message coming from the «application.appName.formatForCode» hook provider.'
                        ])
                    ;
                }

                /**
                 * Process the inner editing form.
                 */
                public function processEdit(FormAwareResponse $hook): void
                {
                    $innerForm = $hook->getFormData('«application.appName.formatForDB»_hook_edit«name.formatForDB»');
                    $dummyOutput = $innerForm['dummyName'] . ' (Option ' . implode(', ', $innerForm['dummyChoice']) . ')';
                    $request = $this->requestStack->getCurrentRequest();
                    if ($request->hasSession() && ($session = $request->getSession())) {
                        $session->getFlashBag()->add(
                            'success',
                            sprintf('The «name.formatForCodeCapital»«providerType»Provider edit form was processed and the answer was %s', $dummyOutput)
                        );
                    }
                }

                /**
                 * Provide the inner deletion form.
                 */
                public function delete(FormAwareHook $hook): void
                {
                    $hook
                        ->formAdd('«application.appName.formatForDB»_hook_delete«name.formatForDB»', Delete«name.formatForCodeCapital»Type::class, [
                            'auto_initialize' => false,«/* required */»
                            'mapped' => false«/* required */»
                        ])
                        ->addTemplate('@«application.appName»/Hook/delete«name.formatForCodeCapital»Form.html.twig', [
                            'testMessage' => 'This is a test message coming from the «application.appName.formatForCode» hook provider.'
                        ])
                    ;
                }

                /**
                 * Process the inner deletion form.
                 */
                public function processDelete(FormAwareResponse $hook): void
                {
                    $innerForm = $hook->getFormData('«application.appName.formatForDB»_hook_delete«name.formatForDB»');
                    $dummyOutput = $innerForm['dummyName'] . ' (Option ' . implode(', ', $innerForm['dummyChoice']) . ')';
                    $request = $this->requestStack->getCurrentRequest();
                    if ($request->hasSession() && ($session = $request->getSession())) {
                        $session->getFlashBag()->add(
                            'success',
                            sprintf('The «name.formatForCodeCapital»«providerType»Provider delete form was processed and the answer was %s', $dummyOutput)
                        );
                    }
                }
            «ELSEIF category == 'UiHooks'»
                /**
                 * Display hook for view/display templates.
                 */
                public function view(DisplayHook $hook): void
                {
                    $response = $this->renderDisplayHookResponse($hook, 'hookDisplayView');
                    $hook->setResponse($response);
                }

                /**
                 * Display hook for create/edit forms.
                 */
                public function displayEdit(DisplayHook $hook): void
                {
                    $response = $this->renderDisplayHookResponse($hook, 'hookDisplayEdit');
                    $hook->setResponse($response);
                }

                /**
                 * Validate input from an item to be edited.
                 */
                public function validateEdit(ValidationHook $hook): bool
                {
                    return true;
                }

                /**
                 * Perform the final update actions for an edited item.
                 */
                public function processEdit(ProcessHook $hook): void
                {
                    $url = $hook->getUrl();
                    if (null === $url || !is_object($url)) {
                        return;
                    }
                    $url = $url->toArray();

                    $entityManager = $this->entityFactory->getEntityManager();

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
                 */
                public function displayDelete(DisplayHook $hook): void
                {
                    $response = $this->renderDisplayHookResponse($hook, 'hookDisplayDelete');
                    $hook->setResponse($response);
                }

                /**
                 * Validate input from an item to be deleted.
                 */
                public function validateDelete(ValidationHook $hook): bool
                {
                    return true;
                }

                /**
                 * Perform the final delete actions for a deleted item.
                 */
                public function processDelete(ProcessHook $hook): void
                {
                    // delete assignments of removed data object
                    $qb = $this->entityFactory->getEntityManager()->createQueryBuilder();
                    $qb->delete($this->getHookAssignmentEntity(), 'tbl');
                    $qb = $this->addContextFilters($qb, $hook);

                    $query = $qb->getQuery();
                    $query->execute();
                }

                /**
                 * Returns the entity for hook assignment data.
                 */
                protected function getHookAssignmentEntity(): string
                {
                    return '«application.vendor.formatForCodeCapital + '\\' + application.name.formatForCodeCapital + 'Module\\Entity\\HookAssignmentEntity'»';
                }

                /**
                 * Adds common hook-based filters to a given query builder.
                 */
                protected function addContextFilters(QueryBuilder $qb, Hook $hook): QueryBuilder
                {
                    $qb->where('tbl.subscriberOwner = :moduleName')
                       ->setParameter('moduleName', $hook->getCaller())
                       ->andWhere('tbl.subscriberAreaId = :areaId')
                       ->setParameter('areaId', $hook->getAreaId())
                       ->andWhere('tbl.subscriberObjectId = :objectId')
                       ->setParameter('objectId', $hook->getId())
                       ->andWhere('tbl.assignedEntity = :objectType')
                       ->setParameter('objectType', '«name.formatForCode»')
                   ;

                    return $qb;
                }

                /**
                 * Returns a list of assigned entities for a given hook context.
                 */
                protected function selectAssignedEntities(Hook $hook): array
                {
                    list($assignments, $assignedIds) = $this->selectAssignedIds($hook);
                    if (!count($assignedIds)) {
                        return [[], []];
                    }

                    $entities = $this->entityFactory->getRepository('«name.formatForCode»')->selectByIdList($assignedIds);

                    return [$assignments, $entities];
                }

                /**
                 * Returns a list of assigned entity identifiers for a given hook context.
                 */
                protected function selectAssignedIds(Hook $hook): array
                {
                    $qb = $this->entityFactory->getEntityManager()->createQueryBuilder();
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
                 */
                protected function renderDisplayHookResponse(Hook $hook, string $context): DisplayHookResponse
                {
                    list($assignments, $assignedEntities) = $this->selectAssignedEntities($hook);
                    $template = '@«application.appName»/«name.formatForCodeCapital»/includeDisplayItemListMany.html.twig';

                    $templateParameters = [
                        'items' => $assignedEntities,
                        'context' => $context,
                        'routeArea' => '',
                    ];

                    if ('hookDisplayView' === $context) {
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

                    $output = $this->twig->render($template, $templateParameters);

                    return new DisplayHookResponse($this->getAreaName(), $output);
                }
            «ENDIF»
        }
    '''

    def private commonMethods(Application it, String group, String category, String type, String areaSuffix) '''
        public function getOwner(): string
        {
            return '«appName»';
        }

        public function getCategory(): string
        {
            return «category»Category::NAME;
        }

        public function getTitle(): string
        {
            return $this->translator->trans('«group.formatForDisplayCapital» «category.formatForDisplay» «type»'«IF !isSystemModule», [], 'hooks'«ENDIF»);
        }

        public function getAreaName(): string
        {
            return '«type».«appName.formatForDB».«IF category == 'FilterHooks'»filter_hooks«ELSEIF category == 'FormAware'»form_aware_hook«ELSEIF category == 'UiHooks'»ui_hooks«ENDIF».«areaSuffix»';
        }
    '''
}
