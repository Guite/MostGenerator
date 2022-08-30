package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
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
        «IF hasIndexActions»
            use Symfony\Component\Form\FormFactoryInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasIndexActions»
            use Symfony\Component\Routing\RouterInterface;
            use function Symfony\Component\String\s;
        «ENDIF»
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\Bundle\CoreBundle\Translation\TranslatorTrait;
        «IF hasIndexActions»
            use Zikula\Component\SortableColumns\SortableColumns;
        «ENDIF»
        «IF hasGeographical»
            use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
        «ENDIF»
        «IF hasIndexActions && hasUserFields»
            use Zikula\UsersBundle\Entity\UserEntity;
        «ENDIF»
        «IF hasIndexActions»
            use «appNamespace»\Entity\EntityInterface;
        «ENDIF»
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\CollectionFilterHelper;
        «IF hasAutomaticExpiryHandling || hasLoggable»
            use «appNamespace»\Helper\ExpiryHelper;
        «ENDIF»
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

        public function __construct(
            TranslatorInterface $translator,
            protected readonly RequestStack $requestStack,
            «IF hasIndexActions»
                protected readonly RouterInterface $router,
            «ENDIF»
            «IF hasIndexActions»
                protected readonly FormFactoryInterface $formFactory,
            «ENDIF»
            «IF hasGeographical»
                protected readonly LoggerInterface $logger,
                protected readonly CurrentUserApiInterface $currentUserApi,
            «ENDIF»
            protected readonly EntityFactory $entityFactory,
            protected readonly CollectionFilterHelper $collectionFilterHelper,
            protected readonly PermissionHelper $permissionHelper«IF !getUploadEntities.empty»,
            protected readonly ImageHelper $imageHelper«ENDIF»«IF needsFeatureActivationHelper»,
            protected readonly FeatureActivationHelper $featureActivationHelper«ENDIF»«IF hasAutomaticExpiryHandling || hasLoggable»,
            ExpiryHelper $expiryHelper«ENDIF»«IF hasIndexActions»,
            protected readonly array $listViewConfig«ENDIF»
        ) {
            $this->setTranslator($translator);
            «IF hasAutomaticExpiryHandling»

                $expiryHelper->handleObsoleteObjects(75);
            «ENDIF»
            «IF hasLoggable»

                $expiryHelper->purgeOldLogEntries(75);
            «ENDIF»
        }

        «getObjectTypes»

        «getDefaultObjectType»
        «IF hasIndexActions»

            «processIndexActionParameters»
        «ENDIF»
        «IF hasDetailActions»

            «processDetailActionParameters»
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
         *
         * @return string[] List of allowed object types
         */
        public function getObjectTypes(string $context = '', array $args = []): array
        {
            $allowedContexts = ['controllerAction', 'api', 'helper', 'actionHandler'];
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
         */
        public function getDefaultObjectType(string $context = '', array $args = []): string
        {
            $allowedContexts = ['controllerAction', 'api', 'helper', 'actionHandler'];
            if (!in_array($context, $allowedContexts, true)) {
                $context = 'controllerAction';
            }

            return '«getLeadingEntity.name.formatForCode»';
        }
    '''

    def private processIndexActionParameters(Application it) '''
        /**
         * Processes the parameters for a view action.
         * This includes handling pagination, quick navigation forms and other aspects.
         */
        public function processIndexActionParameters(
            string $objectType,
            SortableColumns $sortableColumns,
            array $templateParameters = []
        ): array {
            $contextArgs = ['controller' => $objectType, 'action' => 'index'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs), true)) {
                throw new Exception($this->trans('Error! Invalid object type received.'));
            }

            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                throw new Exception($this->trans('Error! Controller helper needs a request.'));
            }
            $repository = $this->entityFactory->getRepository($objectType);

            // parameter for used sorting field
            [$sort, $sortdir] = $this->determineDefaultIndexSorting($objectType);
            $templateParameters['sort'] = $sort;
            $templateParameters['sortdir'] = mb_strtolower($sortdir);
            «IF hasTrees»

                if ('tree' === $request->query->getAlnum('tpl')) {
                    $templateParameters['trees'] = $repository->selectAllTrees();

                    return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
                }
            «ENDIF»

            $configName = s($objectType)->snake();
            $templateParameters['all'] = 'csv' === $request->getRequestFormat() ? 1 : $request->query->getInt('all');
            $showOnlyOwnEntriesSetting = (bool) $request->query->getInt(
                'own',
                (int) $this->listViewConfig['show_only_own_entries']
            );
            $showOnlyOwnEntriesSetting = $showOnlyOwnEntriesSetting ? 1 : 0;
            «IF !getAllEntities.filter[ownerPermission].empty»
                $routeName = $request->get('_route');
                $isAdminArea = 'admin' === $templateParameters['routeArea'];
                if (!$isAdminArea && in_array($objectType, ['«getAllEntities.filter[ownerPermission].map[name.formatForCode].join('\',  \'')»'], true)) {
                    $showOnlyOwnEntries = $this->listViewConfig[$configName . '_private_mode'];
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
                    $resultsPerPage = $this->listViewConfig[$configName . '_entries_per_page'];
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
                    false === mb_stripos($parameterName, 'thumbRuntimeOptions')
                    && false === mb_stripos($parameterName, 'featureActivationHelper')
                    && false === mb_stripos($parameterName, 'permissionHelper')
                ) {
                    continue;
                }
                unset($urlParameters[$parameterName]);
            }

            $quickNavFormType = '«appNamespace»\Form\Type\QuickNavigation\\'
                . ucfirst($objectType) . 'QuickNavType'
            ;

            $quickNavForm = $this->formFactory->create($quickNavFormType, $templateParameters);
            $routeName = $request->get('_route', '');
            $routeParams = $request->attributes->get('_route_params');
            if (1 !== $templateParameters['all']) {
                // let form target page number 1 to avoid empty page if filters have been set
                $routeParams['page'] = 1;
            }
            $targetRoute = $this->router->generate($routeName, $routeParams);

            $quickNavForm = $this->formFactory->create($quickNavFormType, $templateParameters, [
                'action' => $targetRoute
            ]);
            $quickNavForm->handleRequest($request);
            if ($quickNavForm->isSubmitted()) {
                $quickNavData = $quickNavForm->getData();
                foreach ($quickNavData as $fieldName => $fieldValue) {
                    if ('routeArea' === $fieldName) {
                        continue;
                    }
                    if (in_array($fieldName, ['all', 'own', 'num'], true)) {
                        $templateParameters[$fieldName] = (int) $fieldValue;
                    } elseif ('sort' === $fieldName && !empty($fieldValue)) {
                        $sort = $fieldValue;
                    } elseif ('sortdir' === $fieldName && !empty($fieldValue)) {
                        $sortdir = $fieldValue;
                    } elseif (
                        false === mb_stripos($fieldName, 'thumbRuntimeOptions')
                        && false === mb_stripos($fieldName, 'featureActivationHelper')
                        && false === mb_stripos($fieldName, 'permissionHelper')
                    ) {
                        // set filter as query argument, fetched inside CollectionFilterHelper
                        «IF hasUserFields»
                            if ($fieldValue instanceof UserEntity) {
                                $fieldValue = $fieldValue->getUid();
                            }
                        «ENDIF»
                        $request->query->set($fieldName, $fieldValue);
                        if ($fieldValue instanceof EntityInterface) {
                            $fieldValue = $fieldValue->getKey();
                        }
                    }
                    $urlParameters[$fieldName] = $fieldValue;
                }
            }
            $sortableColumns->setOrderBy($sortableColumns->getColumn($sort), mb_strtoupper($sortdir));
            $resultsPerPage = $templateParameters['num'];
            $request->query->set('own', $templateParameters['own']);
«/*
            $sort = $sortableColumns->getSortColumn()->getName();
            $sortdir = $sortableColumns->getSortDirection();*/»
            $sortableColumns->setAdditionalUrlParameters($urlParameters);
            «IF hasCategorisableEntities»
                $useJoins = in_array($objectType, ['«getCategorisableEntities.map[name.formatForCode].join('\', \'')»'], true);
            «ENDIF»

            $where = '';
            if (1 === $templateParameters['all']) {
                // retrieve item list without pagination
                $entities = $repository->selectWhere($where, $sort . ' ' . $sortdir, «IF hasCategorisableEntities»$useJoins«ELSE»false«ENDIF»);
            } else {
                // the current offset which is used to calculate the pagination
                $currentPage = $request->query->getInt('page', 1);
                $templateParameters['currentPage'] = $currentPage;

                // retrieve item list with pagination
                $paginator = $repository->selectWherePaginated(
                    $where,
                    $sort . ' ' . $sortdir,
                    $currentPage,
                    $resultsPerPage,
                    «IF hasCategorisableEntities»$useJoins«ELSE»false«ENDIF»
                );
                $paginator->setRoute('«appName.formatForDB»_' . mb_strtolower($objectType) . '_' . $templateParameters['routeArea'] . 'index');
                $paginator->setRouteParameters($urlParameters);

                $templateParameters['paginator'] = $paginator;
                $entities = $paginator->getResults();
            }

            $templateParameters['sort'] = $sort;
            $templateParameters['sortdir'] = $sortdir;
            $templateParameters['items'] = $entities;
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
         */
        protected function determineDefaultIndexSorting(string $objectType): array
        {
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return ['', 'ASC'];
            }
            $repository = $this->entityFactory->getRepository($objectType);

            «new ControllerHelperFunctions().defaultSorting(it)»
            $sortdir = $request->query->get('sortdir', 'ASC');
            if (false !== mb_strpos($sort, ' DESC')) {
                $sort = str_replace(' DESC', '', $sort);
                $sortdir = 'desc';
            }

            return [$sort, $sortdir];
        }
    '''

    def private processDetailActionParameters(Application it) '''
        /**
         * Processes the parameters for a detail action.
         */
        public function processDetailActionParameters(
            string $objectType,
            array $templateParameters = []
        ): array {
            $contextArgs = ['controller' => $objectType, 'action' => 'detail'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs), true)) {
                throw new Exception($this->trans('Error! Invalid object type received.'));
            }

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private processEditActionParameters(Application it) '''
        /**
         * Processes the parameters for an edit action.
         */
        public function processEditActionParameters(
            string $objectType,
            array $templateParameters = []
        ): array {
            $contextArgs = ['controller' => $objectType, 'action' => 'edit'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs), true)) {
                throw new Exception($this->trans('Error! Invalid object type received.'));
            }

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private processDeleteActionParameters(Application it) '''
        /**
         * Processes the parameters for a delete action.
         */
        public function processDeleteActionParameters(
            string $objectType,
            array $templateParameters = []
        ): array {
            $contextArgs = ['controller' => $objectType, 'action' => 'delete'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs), true)) {
                throw new Exception($this->trans('Error! Invalid object type received.'));
            }

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private addTemplateParameters(Application it) '''
        /**
         * Returns an array of additional template variables which are specific to the object type.
         */
        public function addTemplateParameters(
            string $objectType = '',
            array $parameters = [],
            string $context = '',
            array $args = []
        ): array {
            $allowedContexts = ['controllerAction', 'api', 'helper', 'actionHandler'];
            if (!in_array($context, $allowedContexts, true)) {
                $context = 'controllerAction';
            }

            if ('controllerAction' === $context) {
                if (!isset($args['action'])) {
                    $routeName = $this->requestStack->getCurrentRequest()->get('_route');
                    $routeNameParts = explode('_', $routeName);
                    $args['action'] = end($routeNameParts);
                }
                if ('index' === $args['action']) {
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
                    if (in_array($args['action'], ['index', 'detail', 'edit'], true)) {
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
         */
        public function performGeoCoding(string $address): array
        {
            $url = 'https://nominatim.openstreetmap.org/search?limit=1&format=json&q=' . urlencode($address);

            $data = null;

            // inject Symfony\Contracts\HttpClient\HttpClientInterface and then do
            //$response = $this->client->request($url);
            //if (200 === $response->getStatusCode()) {
            //$data = $response->getContent()->toArray();
            //}

            // create the result array
            $result = [
                'latitude' => 0,
                'longitude' => 0,
            ];

            if (null === $data) {
                return $result;
            }

            if (0 < count($data)) {
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
