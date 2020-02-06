package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.HookProviderMode
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for the helper class creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for controller layer'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ControllerHelper.php', controllerFunctionsBaseImpl, controllerFunctionsImpl)
    }

    def private controllerFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Exception;
        «IF hasGeographical»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        «IF hasViewActions»
            use Symfony\Component\Form\FormFactoryInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasUiHooksProviders»
            use Symfony\Component\Routing\RouterInterface;
        «ENDIF»
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
            «IF hasViewActions»
                use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            «ENDIF»
            «IF (hasViewActions || hasDisplayActions) && hasHookSubscribers»
                use Zikula\Bundle\CoreBundle\RouteUrl;
            «ENDIF»
            use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Common\Translator\TranslatorTrait;
        «ENDIF»
        «IF hasViewActions»
            use Zikula\Component\SortableColumns\SortableColumns;
        «ENDIF»
        «IF !targets('3.0')»
            «IF hasViewActions»
                use Zikula\Core\Doctrine\EntityAccess;
            «ENDIF»
            «IF (hasViewActions || hasDisplayActions) && hasHookSubscribers»
                use Zikula\Core\RouteUrl;
            «ENDIF»
        «ENDIF»
        «IF hasViewActions»
            use Zikula\ExtensionsModule\Api\ApiInterface\VariableApiInterface;
        «ENDIF»
        «IF hasGeographical»
            use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        «ENDIF»
        «IF hasViewActions && hasUserFields»
            use Zikula\UsersModule\Entity\UserEntity;
        «ENDIF»
        use «appNamespace»\Entity\Factory\EntityFactory;
        «IF hasAutomaticArchiving»
            use «appNamespace»\Helper\ArchiveHelper;
        «ENDIF»
        use «appNamespace»\Helper\CollectionFilterHelper;
        «IF needsFeatureActivationHelper»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        «IF !getUploadEntities.empty»
            use «appNamespace»\Helper\ImageHelper;
        «ENDIF»
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Helper base class for controller layer methods.
         */
        abstract class AbstractControllerHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        use TranslatorTrait;

        /**
         * @var RequestStack
         */
        protected $requestStack;
        «IF hasUiHooksProviders»

            /**
             * @var RouterInterface
             */
            protected $router;
        «ENDIF»
        «IF hasViewActions»

            /**
             * @var FormFactoryInterface
             */
            protected $formFactory;
        «ENDIF»
        «IF hasViewActions»

            /**
             * @var VariableApiInterface
             */
            protected $variableApi;
        «ENDIF»
        «IF hasGeographical»

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * @var CurrentUserApiInterface
             */
            protected $currentUserApi;
        «ENDIF»

        /**
         * @var EntityFactory
         */
        protected $entityFactory;

        /**
         * @var CollectionFilterHelper
         */
        protected $collectionFilterHelper;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;
        «IF !getUploadEntities.empty»

            /**
             * @var ImageHelper
             */
            protected $imageHelper;
        «ENDIF»
        «IF needsFeatureActivationHelper»

            /**
             * @var FeatureActivationHelper
             */
            protected $featureActivationHelper;
        «ENDIF»

        public function __construct(
            TranslatorInterface $translator,
            RequestStack $requestStack,
            «IF hasAutomaticArchiving»
                ArchiveHelper $archiveHelper,
            «ENDIF»
            «IF hasUiHooksProviders»
                RouterInterface $router,
            «ENDIF»
            «IF hasViewActions»
                FormFactoryInterface $formFactory,
            «ENDIF»
            «IF hasViewActions»
                VariableApiInterface $variableApi,
            «ENDIF»
            «IF hasGeographical»
                LoggerInterface $logger,
                CurrentUserApiInterface $currentUserApi,
            «ENDIF»
            EntityFactory $entityFactory,
            CollectionFilterHelper $collectionFilterHelper,
            PermissionHelper $permissionHelper«IF !getUploadEntities.empty»,
            ImageHelper $imageHelper«ENDIF»«IF needsFeatureActivationHelper»,
            FeatureActivationHelper $featureActivationHelper«ENDIF»
        ) {
            $this->setTranslator($translator);
            $this->requestStack = $requestStack;
            «IF hasUiHooksProviders»
                $this->router = $router;
            «ENDIF»
            «IF hasViewActions»
                $this->formFactory = $formFactory;
            «ENDIF»
            «IF hasViewActions»
                $this->variableApi = $variableApi;
            «ENDIF»
            «IF hasGeographical»
                $this->logger = $logger;
                $this->currentUserApi = $currentUserApi;
            «ENDIF»
            $this->entityFactory = $entityFactory;
            $this->collectionFilterHelper = $collectionFilterHelper;
            $this->permissionHelper = $permissionHelper;
            «IF !getUploadEntities.empty»
                $this->imageHelper = $imageHelper;
            «ENDIF»
            «IF needsFeatureActivationHelper»
                $this->featureActivationHelper = $featureActivationHelper;
            «ENDIF»
            «IF hasAutomaticArchiving»

                $archiveHelper->archiveObsoleteObjects(75);
            «ENDIF»
        }
        «IF !targets('3.0')»

            «setTranslatorMethod»
        «ENDIF»

        «getObjectTypes»

        «getDefaultObjectType»
        «IF hasViewActions»

            «processViewActionParameters»
        «ENDIF»
        «IF hasDisplayActions»

            «processDisplayActionParameters»
        «ENDIF»
        «IF hasEditActions»

            «processEditActionParameters»
        «ENDIF»
        «IF hasDeleteActions»

            «processDeleteActionParameters»
        «ENDIF»

        «addTemplateParameters»
        «IF hasGeographical»

            «performGeoCoding»
        «ENDIF»
    '''

    def private getObjectTypes(Application it) '''
        /**
         * Returns an array of all allowed object types in «appName».
         «IF !targets('3.0')»
         *
         * @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler,
         *                        block, contentType, mailz)
         * @param array $args Additional arguments
         «ENDIF»
         *
         * @return string[] List of allowed object types
         */
        public function getObjectTypes(«IF targets('3.0')»string «ENDIF»$context = '', array $args = [])«IF targets('3.0')»: array«ENDIF»
        {
            $allowedContexts = ['controllerAction', 'api', 'helper', 'actionHandler', 'block', 'contentType', 'mailz'];
            if (!in_array($context, $allowedContexts, true)) {
                $context = 'controllerAction';
            }

            $allowedObjectTypes = [];
            «FOR entity : entities»
                $allowedObjectTypes[] = '«entity.name.formatForCode»';
            «ENDFOR»

            return $allowedObjectTypes;
        }
    '''

    def private getDefaultObjectType(Application it) '''
        /**
         * Returns the default object type in «appName».
         «IF !targets('3.0')»
         *
         * @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler,
         *                        block, contentType, mailz)
         * @param array $args Additional arguments
         *
         * @return string The name of the default object type
         «ENDIF»
         */
        public function getDefaultObjectType(«IF targets('3.0')»string «ENDIF»$context = '', array $args = [])«IF targets('3.0')»: string«ENDIF»
        {
            $allowedContexts = ['controllerAction', 'api', 'helper', 'actionHandler', 'block', 'contentType', 'mailz'];
            if (!in_array($context, $allowedContexts, true)) {
                $context = 'controllerAction';
            }

            return '«getLeadingEntity.name.formatForCode»';
        }
    '''

    def private processViewActionParameters(Application it) '''
        /**
         * Processes the parameters for a view action.
         * This includes handling pagination, quick navigation forms and other aspects.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         * @param SortableColumns $sortableColumns Used SortableColumns instance
         * @param array $templateParameters Template data
         «IF hasHookSubscribers»
         * @param bool $hasHookSubscriber Whether hook subscribers are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         «ENDIF»
         */
        public function processViewActionParameters(
            «IF targets('3.0')»string «ENDIF»$objectType,
            SortableColumns $sortableColumns,
            array $templateParameters = []«IF hasHookSubscribers»,
            «IF targets('3.0')»bool «ENDIF»$hasHookSubscriber = false«ENDIF»
        )«IF targets('3.0')»: array«ENDIF» {
            $contextArgs = ['controller' => $objectType, 'action' => 'view'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs), true)) {
                throw new Exception($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Invalid object type received.'));
            }

            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                throw new Exception($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Controller helper needs a request.'));
            }
            $repository = $this->entityFactory->getRepository($objectType);

            // parameter for used sorting field
            list ($sort, $sortdir) = $this->determineDefaultViewSorting($objectType);
            $templateParameters['sort'] = $sort;
            $templateParameters['sortdir'] = strtolower($sortdir);
            «IF hasTrees»

                if ('tree' === $request->query->getAlnum('tpl')) {
                    $templateParameters['trees'] = $repository->selectAllTrees();

                    return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
                }
            «ENDIF»

            $templateParameters['all'] = 'csv' === $request->getRequestFormat() ? 1 : $request->query->getInt('all');
            $showOnlyOwnEntriesSetting = (bool)$request->query->getInt(
                'own',
                (int) $this->variableApi->get('«appName»', 'showOnlyOwnEntries')
            );
            $showOnlyOwnEntriesSetting = $showOnlyOwnEntriesSetting ? 1 : 0;
            «IF !getAllEntities.filter[ownerPermission].empty»
                $routeName = $request->get('_route');
                $isAdminArea = false !== strpos($routeName, '«appName.toLowerCase»_' . strtolower($objectType) . '_admin');
                if (!$isAdminArea && in_array($objectType, ['«getAllEntities.filter[ownerPermission].map[name.formatForCode].join('\',  \'')»'], true)) {
                    $showOnlyOwnEntries = (bool)$this->variableApi->get('«appName»', $objectType . 'PrivateMode', false);
                    if (true === $showOnlyOwnEntries) {
                        $templateParameters['own'] = 1;
                    } else {
                        $templateParameters['own'] = $showOnlyOwnEntriesSetting;
                    }
                } else {
                    $templateParameters['own'] = $showOnlyOwnEntriesSetting;
                }
            «ELSE»
                $templateParameters['own'] = $showOnlyOwnEntriesSetting;
            «ENDIF»

            $resultsPerPage = 0;
            if (1 !== $templateParameters['all']) {
                // the number of items displayed on a page for pagination
                $resultsPerPage = $request->query->getInt('num');
                if (in_array($resultsPerPage, [0, 10], true)) {
                    $resultsPerPage = $this->variableApi->get('«appName»', $objectType . 'EntriesPerPage', 10);
                }
            }
            $templateParameters['num'] = $resultsPerPage;
            $templateParameters['tpl'] = $request->query->getAlnum('tpl');

            $templateParameters = $this->addTemplateParameters(
                $objectType,
                $templateParameters,
                'controllerAction',
                $contextArgs
            );

            $urlParameters = $templateParameters;
            foreach ($urlParameters as $parameterName => $parameterValue) {
                if (
                    false === stripos($parameterName, 'thumbRuntimeOptions')
                    && false === stripos($parameterName, 'featureActivationHelper')
                    && false === stripos($parameterName, 'permissionHelper')
                ) {
                    continue;
                }
                unset($urlParameters[$parameterName]);
            }

            $quickNavFormType = '«appNamespace»\Form\Type\QuickNavigation\\'
                . ucfirst($objectType) . 'QuickNavType'
            ;
            $quickNavForm = $this->formFactory->create($quickNavFormType, $templateParameters);
            $quickNavForm->handleRequest($request);
            if ($quickNavForm->isSubmitted()) {
                $quickNavData = $quickNavForm->getData();
                foreach ($quickNavData as $fieldName => $fieldValue) {
                    if ('routeArea' === $fieldName) {
                        continue;
                    }
                    if (in_array($fieldName, ['all', 'own', 'num'], true)) {
                        $templateParameters[$fieldName] = $fieldValue;
                        $urlParameters[$fieldName] = $fieldValue;
                    } elseif ('sort' === $fieldName && !empty($fieldValue)) {
                        $sort = $fieldValue;
                    } elseif ('sortdir' === $fieldName && !empty($fieldValue)) {
                        $sortdir = $fieldValue;
                    } elseif (
                        false === stripos($fieldName, 'thumbRuntimeOptions')
                        && false === stripos($fieldName, 'featureActivationHelper')
                        && false === stripos($fieldName, 'permissionHelper')
                    ) {
                        // set filter as query argument, fetched inside CollectionFilterHelper
                        if ($fieldValue instanceof EntityAccess) {
                            $fieldValue = $fieldValue->getKey();
                        }
                        «IF hasUserFields»
                            if ($fieldValue instanceof UserEntity) {
                                $fieldValue = $fieldValue->getUid();
                            }
                        «ENDIF»
                        $request->query->set($fieldName, $fieldValue);
                        $urlParameters[$fieldName] = $fieldValue;
                    }
                }
            }
            $sortableColumns->setOrderBy($sortableColumns->getColumn($sort), strtoupper($sortdir));
            $resultsPerPage = $templateParameters['num'];
            $request->query->set('own', $templateParameters['own']);
«/*
            $sort = $sortableColumns->getSortColumn()->getName();
            $sortdir = $sortableColumns->getSortDirection();*/»
            $sortableColumns->setAdditionalUrlParameters($urlParameters);
            «IF hasCategorisableEntities»
                $useJoins = in_array($objectType, ['«getCategorisableEntities.map[name.formatForCode].join('\', \'')»']);
            «ENDIF»

            $where = '';
            if (1 === $templateParameters['all']) {
                // retrieve item list without pagination
                $entities = $repository->selectWhere($where, $sort . ' ' . $sortdir, «IF hasCategorisableEntities»$useJoins«ELSE»false«ENDIF»);
            } else {
                // the current offset which is used to calculate the pagination
                $currentPage = $request->query->getInt('pos', 1);

                // retrieve item list with pagination
                list($entities, $objectCount) = $repository->selectWherePaginated(
                    $where,
                    $sort . ' ' . $sortdir,
                    $currentPage,
                    $resultsPerPage,
                    «IF hasCategorisableEntities»$useJoins«ELSE»false«ENDIF»
                );

                $templateParameters['currentPage'] = $currentPage;
                $templateParameters['pager'] = [
                    'amountOfItems' => $objectCount,
                    'itemsPerPage' => $resultsPerPage
                ];
            }

            $templateParameters['sort'] = $sort;
            $templateParameters['sortdir'] = $sortdir;
            $templateParameters['items'] = $entities;
            «IF hasHookSubscribers»

                if (true === $hasHookSubscriber) {
                    // build RouteUrl instance for display hooks
                    $urlParameters['_locale'] = $request->getLocale();
                    $routeName = '«appName.formatForDB»_' . strtolower($objectType) . '_view';
                    $templateParameters['currentUrlObject'] = new RouteUrl($routeName, $urlParameters);
                }
            «ENDIF»

            $templateParameters['sort'] = $sortableColumns->generateSortableColumns();
            $templateParameters['quickNavForm'] = $quickNavForm->createView();

            $request->query->set('sort', $sort);
            $request->query->set('sortdir', $sortdir);
            // set current sorting in route parameters (e.g. for the pager)
            $routeParams = $request->attributes->get('_route_params');
            $routeParams['sort'] = $sort;
            $routeParams['sortdir'] = $sortdir;
            $request->attributes->set('_route_params', $routeParams);

            return $templateParameters;
        }

        /**
         * Determines the default sorting criteria.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         *
         * @return array with sort field and sort direction
         «ENDIF»
         */
        protected function determineDefaultViewSorting(«IF targets('3.0')»string «ENDIF»$objectType)«IF targets('3.0')»: array«ENDIF»
        {
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return ['', 'ASC'];
            }
            $repository = $this->entityFactory->getRepository($objectType);

            «new ControllerHelperFunctions().defaultSorting(it)»
            $sortdir = $request->query->get('sortdir', 'ASC');
            if (false !== strpos($sort, ' DESC')) {
                $sort = str_replace(' DESC', '', $sort);
                $sortdir = 'desc';
            }

            return [$sort, $sortdir];
        }
    '''

    def private processDisplayActionParameters(Application it) '''
        /**
         * Processes the parameters for a display action.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         * @param array $templateParameters Template data
         «IF hasHookSubscribers»
         * @param bool $hasHookSubscriber Whether hook subscribers are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         «ENDIF»
         */
        public function processDisplayActionParameters(
            «IF targets('3.0')»string «ENDIF»$objectType,
            array $templateParameters = []«IF hasHookSubscribers»,
            «IF targets('3.0')»bool «ENDIF»$hasHookSubscriber = false«ENDIF»
        )«IF targets('3.0')»: array«ENDIF» {
            $contextArgs = ['controller' => $objectType, 'action' => 'display'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs), true)) {
                throw new Exception($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Invalid object type received.'));
            }
            «IF hasHookSubscribers»

                if (true === $hasHookSubscriber) {
                    // build RouteUrl instance for display hooks
                    $entity = $templateParameters[$objectType];
                    $urlParameters = $entity->createUrlArgs();
                    $urlParameters['_locale'] = $this->requestStack->getCurrentRequest()->getLocale();
                    $routeName = '«appName.formatForDB»_' . strtolower($objectType) . '_display';
                    $templateParameters['currentUrlObject'] = new RouteUrl($routeName, $urlParameters);
                }
            «ENDIF»
            «IF hasUiHooksProviders»

                if (in_array($objectType, ['«getAllEntities.filter[uiHooksProvider != HookProviderMode.DISABLED].map[name.formatForCode].join('\', \'')»'], true)) {
                    $qb = $this->entityFactory->getEntityManager()->createQueryBuilder();
                    $qb->select('tbl')
                       ->from('«vendor.formatForCodeCapital + '\\' + name.formatForCodeCapital + 'Module\\Entity\\HookAssignmentEntity'»', 'tbl')
                       ->where('tbl.assignedEntity = :objectType')
                       ->setParameter('objectType', $objectType)
                       ->andWhere('tbl.assignedId = :entityId')
                       ->setParameter('entityId', $entity->getKey())
                       ->add('orderBy', 'tbl.updatedDate DESC');

                    $query = $qb->getQuery();
                    $hookAssignments = $query->getResult();

                    $assignments = [];
                    foreach ($hookAssignments as $assignment) {
                        $url = 'javascript:void(0);';
                        $subscriberUrl = $assignment->getSubscriberUrl();
                        if (null !== $subscriberUrl && !empty($subscriberUrl)) {
                            «IF targets('2.0')»
                                $url = $this->router->generate($subscriberUrl['route'], $subscriberUrl['args']);
                            «ELSE»
                                if (!isset($subscriberUrl['route'])) {
                                    // legacy module
                                    $url = \ModUtil::url($subscriberUrl['application'], $subscriberUrl['controller'], $subscriberUrl['action'], $subscriberUrl['args'], null, null, true, true);
                                } else {
                                    $url = $this->router->generate($subscriberUrl['route'], $subscriberUrl['args']);
                                }
                            «ENDIF»

                            $fragment = $subscriberUrl['fragment'];
                            if (!empty($fragment)) {
                                if ('#' !== $fragment[0]) {
                                    $fragment = '#' . $fragment;
                            	}
                                $url .= $fragment;
                            }
                        }
                        $assignments[] = [
                            'url' => $url,
                            'text' => $assignment->getSubscriberOwner(),
                            'date' => $assignment->getUpdatedDate()
                        ];
                    }
                    $templateParameters['hookAssignments'] = $assignments;
                }
            «ENDIF»

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private processEditActionParameters(Application it) '''
        /**
         * Processes the parameters for an edit action.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         * @param array $templateParameters Template data
         *
         * @return array Enriched template parameters used for creating the response
         «ENDIF»
         */
        public function processEditActionParameters(
            «IF targets('3.0')»string «ENDIF»$objectType,
            array $templateParameters = []
        )«IF targets('3.0')»: array«ENDIF» {
            $contextArgs = ['controller' => $objectType, 'action' => 'edit'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs), true)) {
                throw new Exception($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Invalid object type received.'));
            }

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private processDeleteActionParameters(Application it) '''
        /**
         * Processes the parameters for a delete action.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         * @param array $templateParameters Template data
         «IF hasHookSubscribers»
         * @param bool $hasHookSubscriber Whether hook subscribers are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         «ENDIF»
         */
        public function processDeleteActionParameters(
            «IF targets('3.0')»string «ENDIF»$objectType,
            array $templateParameters = []«IF hasHookSubscribers»,
            «IF targets('3.0')»bool «ENDIF»$hasHookSubscriber = false«ENDIF»
        )«IF targets('3.0')»: array«ENDIF» {
            $contextArgs = ['controller' => $objectType, 'action' => 'delete'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs), true)) {
                throw new Exception($this->«IF targets('3.0')»trans«ELSE»__«ENDIF»('Error! Invalid object type received.'));
            }

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private addTemplateParameters(Application it) '''
        /**
         * Returns an array of additional template variables which are specific to the object type.
         «IF !targets('3.0')»
         *
         * @param string $objectType Name of treated entity type
         * @param array $parameters Given parameters to enrich
         * @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler,
         *                        block, contentType, mailz)
         * @param array $args Additional arguments
         *
         * @return array List of template variables to be assigned
         «ENDIF»
         */
        public function addTemplateParameters(
            «IF targets('3.0')»string «ENDIF»$objectType = '',
            array $parameters = [],
            «IF targets('3.0')»string «ENDIF»$context = '',
            array $args = []
        )«IF targets('3.0')»: array«ENDIF» {
            $allowedContexts = ['controllerAction', 'api', 'helper', 'actionHandler', 'block', 'contentType', 'mailz'];
            if (!in_array($context, $allowedContexts, true)) {
                $context = 'controllerAction';
            }

            if ('controllerAction' === $context) {
                if (!isset($args['action'])) {
                    $routeName = $this->requestStack->getCurrentRequest()->get('_route');
                    $routeNameParts = explode('_', $routeName);
                    $args['action'] = end($routeNameParts);
                }
                if (in_array($args['action'], ['index', 'view'])) {
                    $parameters = array_merge(
                        $parameters,
                        $this->collectionFilterHelper->getViewQuickNavParameters($objectType, $context, $args)
                    );
                }
                «IF !getUploadEntities.empty»

                    // initialise Imagine runtime options
                    «FOR entity : getUploadEntities»
                        if ('«entity.name.formatForCode»' === $objectType) {
                            $thumbRuntimeOptions = [];
                            «FOR uploadField : entity.getUploadFieldsEntity»
                                $thumbRuntimeOptions[$objectType . '«uploadField.name.formatForCodeCapital»'] = $this->imageHelper->getRuntimeOptions(
                                    $objectType,
                                    '«uploadField.name.formatForCode»',
                                    $context,
                                    $args
                                );
                            «ENDFOR»
                            $parameters['thumbRuntimeOptions'] = $thumbRuntimeOptions;
                        }
                    «ENDFOR»
                    if (in_array($args['action'], ['display', 'edit', 'view'], true)) {
                        // use separate preset for images in related items
                        $parameters['relationThumbRuntimeOptions'] = $this->imageHelper->getCustomRuntimeOptions(
                            '',
                            '',
                            '«appName»_relateditem',
                            $context,
                            $args
                        );
                    }
                «ENDIF»
            }
            $parameters['permissionHelper'] = $this->permissionHelper;
            «IF needsFeatureActivationHelper»

                $parameters['featureActivationHelper'] = $this->featureActivationHelper;
            «ENDIF»

            return $parameters;
        }
    '''

    def private performGeoCoding(Application it) '''
        /**
         * Example method for performing geocoding in PHP.
         * To use this please extend it or customise it to your needs in the concrete subclass.
         *
         * You can also easily do geocoding on JS level with some Leaflet plugins, see https://leafletjs.com/plugins.html#geocoding
         «IF !targets('3.0')»
         *
         * @param string $address The address input string
         *
         * @return array The determined coordinates
         «ENDIF»
         */
        public function performGeoCoding(«IF targets('3.0')»string «ENDIF»$address)«IF targets('3.0')»: array«ENDIF»
        {
            $url = 'https://nominatim.openstreetmap.org/search?limit=1&format=json&q=' . urlencode($address);

            $json = '';

            // we can either use Snoopy if available
            //require_once '«relativeAppRootPath»/vendor/Snoopy/Snoopy.class.php';
            //$snoopy = new Snoopy();
            //$snoopy->fetch($url);
            //$json = $snoopy->results;

            // we can also use curl
            if (function_exists('curl_version')) {
                $ch = curl_init();
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
                curl_setopt($ch, CURLOPT_HEADER, 0);
                if (!ini_get('open_basedir')) {
                    // This option does not work with open_basedir set in php.ini
                    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
                }
                curl_setopt($ch, CURLOPT_URL, $url);
                $json = curl_exec($ch);
                curl_close($ch);
            } else {
                // or we can use the plain file_get_contents method
                // requires allow_url_fopen = true in php.ini which is NOT good for security
                $json = file_get_contents($url);
            }

            // create the result array
            $result = [
                'latitude' => 0,
                'longitude' => 0
            ];

            if ('' === $json) {
                return $result;
            }

            $data = json_decode($json);
            if (JSON_ERROR_NONE === json_last_error() && 'OK' === $data->status && 0 < count($data)) {
                $location = $data[0];
                $result['latitude'] = str_replace(',', '.', $location->lat);
                $result['longitude'] = str_replace(',', '.', $location->lng);
            } else {
                $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'field' => $field, 'address' => $address];
                $this->logger->warning('{app}: User {user} tried geocoding for address "{address}", but failed.', $logArgs);
            }

            return $result;
        }
    '''

    def private controllerFunctionsImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractControllerHelper;

        /**
         * Helper implementation class for controller layer methods.
         */
        class ControllerHelper extends AbstractControllerHelper
        {
            // feel free to add your own convenience methods here
        }
    '''
}
