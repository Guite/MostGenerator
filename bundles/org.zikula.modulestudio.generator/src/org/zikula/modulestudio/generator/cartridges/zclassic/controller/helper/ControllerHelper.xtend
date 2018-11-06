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
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        «IF hasViewActions»
            use Zikula\Component\SortableColumns\SortableColumns;
        «ENDIF»
        «IF (hasViewActions || hasDisplayActions) && hasHookSubscribers»
            use Zikula\Core\RouteUrl;
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
        «IF hasViewActions && hasEditActions»
            use «appNamespace»\Helper\ModelHelper;
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
        «IF hasViewActions && hasEditActions»

            /**
             * @var ModelHelper
             */
            protected $modelHelper;
        «ENDIF»
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

        /**
         * ControllerHelper constructor.
         *
         * @param TranslatorInterface $translator       Translator service instance
         * @param RequestStack        $requestStack     RequestStack service instance
         «IF hasAutomaticArchiving»
         * @param ArchiveHelper       $archiveHelper    ArchiveHelper service instance
         «ENDIF»
         «IF hasUiHooksProviders»
         * @param Routerinterface     $router           Router service instance
         «ENDIF»
         «IF hasViewActions»
         * @param FormFactoryInterface $formFactory     FormFactory service instance
         «ENDIF»
         «IF hasViewActions»
         * @param VariableApiInterface $variableApi     VariableApi service instance
         «ENDIF»
         «IF hasGeographical»
         * @param LoggerInterface     $logger           Logger service instance
         * @param CurrentUserApiInterface $currentUserApi  CurrentUserApi service instance
         «ENDIF»
         * @param EntityFactory       $entityFactory    EntityFactory service instance
         * @param CollectionFilterHelper $collectionFilterHelper CollectionFilterHelper service instance
         * @param PermissionHelper    $permissionHelper PermissionHelper service instance
         «IF hasViewActions && hasEditActions»
         * @param ModelHelper         $modelHelper      ModelHelper service instance
         «ENDIF»
         «IF !getUploadEntities.empty»
         * @param ImageHelper         $imageHelper      ImageHelper service instance
         «ENDIF»
         «IF needsFeatureActivationHelper»
         * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
         «ENDIF»
         */
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
            PermissionHelper $permissionHelper«IF hasViewActions && hasEditActions»,
            ModelHelper $modelHelper«ENDIF»«IF !getUploadEntities.empty»,
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
            «IF hasViewActions && hasEditActions»
                $this->modelHelper = $modelHelper;
            «ENDIF»
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

        «setTranslatorMethod»

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
         *
         * @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler, block, contentType, util)
         * @param array  $args    Additional arguments
         *
         * @return string[] List of allowed object types
         */
        public function getObjectTypes($context = '', array $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'helper', 'actionHandler', 'block', 'contentType', 'util'])) {
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
         *
         * @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler, block, contentType, util)
         * @param array  $args    Additional arguments
         *
         * @return string The name of the default object type
         */
        public function getDefaultObjectType($context = '', array $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'helper', 'actionHandler', 'block', 'contentType', 'util'])) {
                $context = 'controllerAction';
            }

            return '«getLeadingEntity.name.formatForCode»';
        }
    '''

    def private processViewActionParameters(Application it) '''
        /**
         * Processes the parameters for a view action.
         * This includes handling pagination, quick navigation forms and other aspects.
         *
         * @param string          $objectType         Name of treated entity type
         * @param SortableColumns $sortableColumns    Used SortableColumns instance
         * @param array           $templateParameters Template data
         «IF hasHookSubscribers»
         * @param boolean         $hasHookSubscriber  Whether hook subscribers are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         */
        public function processViewActionParameters($objectType, SortableColumns $sortableColumns, array $templateParameters = []«IF hasHookSubscribers», $hasHookSubscriber = false«ENDIF»)
        {
            $contextArgs = ['controller' => $objectType, 'action' => 'view'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs))) {
                throw new \Exception($this->__('Error! Invalid object type received.'));
            }

            $request = $this->requestStack->getCurrentRequest();
            $repository = $this->entityFactory->getRepository($objectType);

            // parameter for used sorting field
            list ($sort, $sortdir) = $this->determineDefaultViewSorting($objectType);
            $templateParameters['sort'] = $sort;
            $templateParameters['sortdir'] = strtolower($sortdir);
            «IF hasTrees»

                if ('tree' == $request->query->getAlnum('tpl', '')) {
                    $templateParameters['trees'] = $repository->selectAllTrees();

                    return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
                }
            «ENDIF»

            $templateParameters['all'] = 'csv' == $request->getRequestFormat() ? 1 : $request->query->getInt('all', 0);
            $templateParameters['own'] = (bool)$request->query->getInt('own', $this->variableApi->get('«appName»', 'showOnlyOwnEntries', false)) ? 1 : 0;

            $resultsPerPage = 0;
            if ($templateParameters['all'] != 1) {
                // the number of items displayed on a page for pagination
                $resultsPerPage = $request->query->getInt('num', 0);
                if (in_array($resultsPerPage, [0, 10])) {
                    $resultsPerPage = $this->variableApi->get('«appName»', $objectType . 'EntriesPerPage', 10);
                }
            }
            $templateParameters['num'] = $resultsPerPage;
            $templateParameters['tpl'] = $request->query->getAlnum('tpl', '');

            $templateParameters = $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);

            $quickNavForm = $this->formFactory->create('«appNamespace»\Form\Type\QuickNavigation\\' . ucfirst($objectType) . 'QuickNavType', $templateParameters);
            if ($quickNavForm->handleRequest($request) && $quickNavForm->isSubmitted()) {
                $quickNavData = $quickNavForm->getData();
                foreach ($quickNavData as $fieldName => $fieldValue) {
                    if ($fieldName == 'routeArea') {
                        continue;
                    }
                    if (in_array($fieldName, ['all', 'own', 'num'])) {
                        $templateParameters[$fieldName] = $fieldValue;
                    } elseif ($fieldName == 'sort' && !empty($fieldValue)) {
                        $sort = $fieldValue;
                    } elseif ($fieldName == 'sortdir' && !empty($fieldValue)) {
                        $sortdir = $fieldValue;
                    } elseif (false === stripos($fieldName, 'thumbRuntimeOptions') && false === stripos($fieldName, 'featureActivationHelper') && false === stripos($fieldName, 'permissionHelper')) {
                        // set filter as query argument, fetched inside repository
                        «IF hasUserFields»
                            if ($fieldValue instanceof UserEntity) {
                                $fieldValue = $fieldValue->getUid();
                            }
                        «ENDIF»
                        $request->query->set($fieldName, $fieldValue);
                    }
                }
            }
            $sortableColumns->setOrderBy($sortableColumns->getColumn($sort), strtoupper($sortdir));
            $resultsPerPage = $templateParameters['num'];
            $request->query->set('own', $templateParameters['own']);

            $urlParameters = $templateParameters;
            foreach ($urlParameters as $parameterName => $parameterValue) {
                if (false === stripos($parameterName, 'thumbRuntimeOptions')
                    && false === stripos($parameterName, 'featureActivationHelper')
                ) {
                    continue;
                }
                unset($urlParameters[$parameterName]);
            }
«/*
            $sort = $sortableColumns->getSortColumn()->getName();
            $sortdir = $sortableColumns->getSortDirection();*/»
            $sortableColumns->setAdditionalUrlParameters($urlParameters);

            $where = '';
            if ($templateParameters['all'] == 1) {
                // retrieve item list without pagination
                $entities = $repository->selectWhere($where, $sort . ' ' . $sortdir);
            } else {
                // the current offset which is used to calculate the pagination
                $currentPage = $request->query->getInt('pos', 1);

                // retrieve item list with pagination
                list($entities, $objectCount) = $repository->selectWherePaginated($where, $sort . ' ' . $sortdir, $currentPage, $resultsPerPage);

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
                    $templateParameters['currentUrlObject'] = new RouteUrl('«appName.formatForDB»_' . strtolower($objectType) . '_view', $urlParameters);
                }
            «ENDIF»

            $templateParameters['sort'] = $sortableColumns->generateSortableColumns();
            $templateParameters['quickNavForm'] = $quickNavForm->createView();
            «IF hasEditActions»

                $templateParameters['canBeCreated'] = $this->modelHelper->canBeCreated($objectType);
            «ENDIF»

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
         *
         * @param string $objectType Name of treated entity type
         *
         * @return array with sort field and sort direction
         */
        protected function determineDefaultViewSorting($objectType)
        {
            $request = $this->requestStack->getCurrentRequest();
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
         *
         * @param string  $objectType         Name of treated entity type
         * @param array   $templateParameters Template data
         «IF hasHookSubscribers»
         * @param boolean $hasHookSubscriber  Whether hook subscribers are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         */
        public function processDisplayActionParameters($objectType, array $templateParameters = []«IF hasHookSubscribers», $hasHookSubscriber = false«ENDIF»)
        {
            $contextArgs = ['controller' => $objectType, 'action' => 'display'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs))) {
                throw new \Exception($this->__('Error! Invalid object type received.'));
            }
            «IF hasHookSubscribers»

                if (true === $hasHookSubscriber) {
                    // build RouteUrl instance for display hooks
                    $entity = $templateParameters[$objectType];
                    $urlParameters = $entity->createUrlArgs();
                    $urlParameters['_locale'] = $this->requestStack->getCurrentRequest()->getLocale();
                    $templateParameters['currentUrlObject'] = new RouteUrl('«appName.formatForDB»_' . strtolower($objectType) . '_display', $urlParameters);
                }
            «ENDIF»
            «IF hasUiHooksProviders»

                if (in_array($objectType, ['«getAllEntities.filter[uiHooksProvider != HookProviderMode.DISABLED].map[name.formatForCode].join('\', \'')»'])) {
                    $qb = $this->entityFactory->getObjectManager()->createQueryBuilder();
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
                                if ($fragment[0] != '#') {
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
         *
         * @param string  $objectType         Name of treated entity type
         * @param array   $templateParameters Template data
         *
         * @return array Enriched template parameters used for creating the response
         */
        public function processEditActionParameters($objectType, array $templateParameters = [])
        {
            $contextArgs = ['controller' => $objectType, 'action' => 'edit'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs))) {
                throw new \Exception($this->__('Error! Invalid object type received.'));
            }

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private processDeleteActionParameters(Application it) '''
        /**
         * Processes the parameters for a delete action.
         *
         * @param string  $objectType         Name of treated entity type
         * @param array   $templateParameters Template data
         «IF hasHookSubscribers»
         * @param boolean $hasHookSubscriber  Whether hook subscribers are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         */
        public function processDeleteActionParameters($objectType, array $templateParameters = []«IF hasHookSubscribers», $hasHookSubscriber = false«ENDIF»)
        {
            $contextArgs = ['controller' => $objectType, 'action' => 'delete'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs))) {
                throw new \Exception($this->__('Error! Invalid object type received.'));
            }

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private addTemplateParameters(Application it) '''
        /**
         * Returns an array of additional template variables which are specific to the object type.
         *
         * @param string $objectType Name of treated entity type
         * @param array  $parameters Given parameters to enrich
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args       Additional arguments
         *
         * @return array List of template variables to be assigned
         */
        public function addTemplateParameters($objectType = '', array $parameters = [], $context = '', array $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'actionHandler', 'block', 'contentType', 'mailz'])) {
                $context = 'controllerAction';
            }

            if ($context == 'controllerAction') {
                if (!isset($args['action'])) {
                    $routeName = $this->requestStack->getCurrentRequest()->get('_route');
                    $routeNameParts = explode('_', $routeName);
                    $args['action'] = end($routeNameParts);
                }
                if (in_array($args['action'], ['index', 'view'])) {
                    $parameters = array_merge($parameters, $this->collectionFilterHelper->getViewQuickNavParameters($objectType, $context, $args));
                }
                «IF !getUploadEntities.empty»

                    // initialise Imagine runtime options
                    «FOR entity : getUploadEntities»
                        if ($objectType == '«entity.name.formatForCode»') {
                            $thumbRuntimeOptions = [];
                            «FOR uploadField : entity.getUploadFieldsEntity»
                                $thumbRuntimeOptions[$objectType . '«uploadField.name.formatForCodeCapital»'] = $this->imageHelper->getRuntimeOptions($objectType, '«uploadField.name.formatForCode»', $context, $args);
                            «ENDFOR»
                            $parameters['thumbRuntimeOptions'] = $thumbRuntimeOptions;
                        }
                    «ENDFOR»
                    if (in_array($args['action'], ['display', 'edit', 'view'])) {
                        // use separate preset for images in related items
                        $parameters['relationThumbRuntimeOptions'] = $this->imageHelper->getCustomRuntimeOptions('', '', '«appName»_relateditem', $context, $args);
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
         * You can also easily do geocoding on JS level with some Leaflet plugins, see http://leafletjs.com/plugins.html#geocoding
         *
         * @param string $address The address input string
         *
         * @return Array The determined coordinates
         */
        public function performGeoCoding($address)
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
                //curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1); // can cause problems with open_basedir
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

            if ('' == $json) {
                return $result;
            }

            $data = json_decode($json);
            if (JSON_ERROR_NONE == json_last_error() && 'OK' == $data->status && 0 < count($data)) {
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
