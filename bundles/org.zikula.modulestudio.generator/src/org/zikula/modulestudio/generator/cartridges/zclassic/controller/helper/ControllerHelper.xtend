package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
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
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for controller layer')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/ControllerHelper.php',
            fh.phpFileContent(it, controllerFunctionsBaseImpl), fh.phpFileContent(it, controllerFunctionsImpl)
        )
    }

    def private controllerFunctionsBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF hasUploads || hasGeographical»
            use Psr\Log\LoggerInterface;
        «ENDIF»
        «IF hasUploads»
            use Symfony\Component\Filesystem\Exception\IOExceptionInterface;
            use Symfony\Component\Filesystem\Filesystem;
        «ENDIF»
        «IF hasViewActions»
            use Symfony\Component\Form\FormFactoryInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasUploads»
            use Symfony\Component\HttpFoundation\Session\SessionInterface;
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Common\Translator\TranslatorTrait;
        «ENDIF»
        «IF hasViewActions»
            use Zikula\Component\SortableColumns\SortableColumns;
        «ENDIF»
        «IF (hasViewActions || hasDisplayActions) && hasHookSubscribers»
            use Zikula\Core\RouteUrl;
        «ENDIF»
        «IF hasViewActions || hasGeographical»
            use Zikula\ExtensionsModule\Api\«IF targets('1.5')»ApiInterface\VariableApiInterface«ELSE»VariableApi«ENDIF»;
        «ENDIF»
        «IF hasGeographical»
            use Zikula\UsersModule\Api\«IF targets('1.5')»ApiInterface\CurrentUserApiInterface«ELSE»CurrentUserApi«ENDIF»;
        «ENDIF»
        «IF hasViewActions && hasUserFields»
            use Zikula\UsersModule\Entity\UserEntity;
        «ENDIF»
        use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;
        «IF needsFeatureActivationHelper»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        «IF hasUploads»
            use «appNamespace»\Helper\ImageHelper;
        «ENDIF»
        «IF hasViewActions && hasEditActions»
            use «appNamespace»\Helper\ModelHelper;
        «ENDIF»

        /**
         * Helper base class for controller layer methods.
         */
        abstract class AbstractControllerHelper
        {
            «IF hasUploads»
                use TranslatorTrait;

            «ENDIF»
            /**
             * @var Request
             */
            protected $request;
            «IF hasUploads»

                /**
                 * @var SessionInterface
                 */
                protected $session;
            «ENDIF»
            «IF hasUploads || hasGeographical»

                /**
                 * @var LoggerInterface
                 */
                protected $logger;
            «ENDIF»
            «IF hasViewActions»

                /**
                 * @var FormFactoryInterface
                 */
                protected $formFactory;
            «ENDIF»
            «IF hasViewActions || hasGeographical»

                /**
                 * @var VariableApi«IF targets('1.5')»Interface«ENDIF»
                 */
                protected $variableApi;
            «ENDIF»
            «IF hasGeographical»

                /**
                 * @var CurrentUserApi«IF targets('1.5')»Interface«ENDIF»
                 */
                protected $currentUserApi;
            «ENDIF»

            /**
             * @var «name.formatForCodeCapital»Factory
             */
            protected $entityFactory;
            «IF hasViewActions && hasEditActions»

                /**
                 * @var ModelHelper
                 */
                protected $modelHelper;
            «ENDIF»
            «IF hasUploads»

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
             «IF hasUploads»
             * @param TranslatorInterface $translator      Translator service instance
             «ENDIF»
             * @param RequestStack        $requestStack    RequestStack service instance
             «IF hasUploads»
             * @param SessionInterface    $session         Session service instance
             «ENDIF»
             «IF hasUploads || hasGeographical»
             * @param LoggerInterface     $logger          Logger service instance
             «ENDIF»
             «IF hasViewActions»
             * @param FormFactoryInterface $formFactory    FormFactory service instance
             «ENDIF»
             «IF hasViewActions || hasGeographical»
             * @param VariableApi«IF targets('1.5')»Interface«ELSE»        «ENDIF» $variableApi     VariableApi service instance
             «ENDIF»
             «IF hasGeographical»
             * @param CurrentUserApi«IF targets('1.5')»Interface«ELSE»     «ENDIF» $currentUserApi  CurrentUserApi service instance
             «ENDIF»
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
             «IF hasViewActions && hasEditActions»
             * @param ModelHelper         $modelHelper     ModelHelper service instance
             «ENDIF»
             «IF hasUploads»
             * @param ImageHelper         $imageHelper     ImageHelper service instance
             «ENDIF»
             «IF needsFeatureActivationHelper»
             * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
             «ENDIF»
             */
            public function __construct(
                «IF hasUploads»
                    TranslatorInterface $translator,
                «ENDIF»
                RequestStack $requestStack,
                «IF hasUploads»
                    SessionInterface $session,
                «ENDIF»
                «IF hasUploads || hasGeographical»
                    LoggerInterface $logger,
                «ENDIF»
                «IF hasViewActions»
                    FormFactoryInterface $formFactory,
                «ENDIF»
                «IF hasViewActions || hasGeographical»
                    VariableApi«IF targets('1.5')»Interface«ENDIF» $variableApi,
                «ENDIF»
                «IF hasGeographical»
                    CurrentUserApi«IF targets('1.5')»Interface«ENDIF» $currentUserApi,
                «ENDIF»
                «name.formatForCodeCapital»Factory $entityFactory«IF hasViewActions && hasEditActions»,
                ModelHelper $modelHelper«ENDIF»«IF hasUploads»,
                ImageHelper $imageHelper«ENDIF»«IF needsFeatureActivationHelper»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
                «IF hasUploads»
                    $this->setTranslator($translator);
                «ENDIF»
                $this->request = $requestStack->getCurrentRequest();
                «IF hasUploads»
                    $this->session = $session;
                «ENDIF»
                «IF hasUploads || hasGeographical»
                    $this->logger = $logger;
                «ENDIF»
                «IF hasViewActions»
                    $this->formFactory = $formFactory;
                «ENDIF»
                «IF hasViewActions || hasGeographical»
                    $this->variableApi = $variableApi;
                «ENDIF»
                «IF hasGeographical»
                    $this->currentUserApi = $currentUserApi;
                «ENDIF»
                $this->entityFactory = $entityFactory;
                «IF hasViewActions && hasEditActions»
                    $this->modelHelper = $modelHelper;
                «ENDIF»
                «IF hasUploads»
                    $this->imageHelper = $imageHelper;
                «ENDIF»
                «IF needsFeatureActivationHelper»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
            }

            «IF hasUploads»
                «setTranslatorMethod»

            «ENDIF»
            «getObjectTypes»

            «getDefaultObjectType»

            «retrieveIdentifier»

            «isValidIdentifier»

            «formatPermalink»
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
        }
    '''

    def private getObjectTypes(Application it) '''
        /**
         * Returns an array of all allowed object types in «appName».
         *
         * @param string $context Usage context (allowed values: controllerAction, api, helper, actionHandler, block, contentType, util)
         * @param array  $args    Additional arguments
         *
         * @return array List of allowed object types
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

    def private retrieveIdentifier(Application it) '''
        /**
         * Retrieve identifier parameters for a given object type.
         *
         * @param Request $request    The current request
         * @param array   $args       List of arguments used as fallback if request does not contain a field
         * @param string  $objectType Name of treated entity type
         *
         * @return array List of fetched identifiers
         */
        public function retrieveIdentifier(Request $request, array $args, $objectType = '')
        {
            $idFields = $this->entityFactory->getIdFields($objectType);
            $idValues = [];
            $routeParams = $request->get('_route_params', []);
            foreach ($idFields as $idField) {
                $defaultValue = isset($args[$idField]) && is_numeric($args[$idField]) ? $args[$idField] : 0;
                if ($this->entityFactory->hasCompositeKeys($objectType)) {
                    // composite key may be alphanumeric
                    if (array_key_exists($idField, $routeParams)) {
                        $id = !empty($routeParams[$idField]) ? $routeParams[$idField] : $defaultValue;
                    } elseif ($request->query->has($idField)) {
                        $id = $request->query->getAlnum($idField, $defaultValue);
                    } else {
                        $id = $defaultValue;
                    }
                } else {
                    // single identifier
                    if (array_key_exists($idField, $routeParams)) {
                        $id = (int) !empty($routeParams[$idField]) ? $routeParams[$idField] : $defaultValue;
                    } elseif ($request->query->has($idField)) {
                        $id = $request->query->getInt($idField, $defaultValue);
                    } else {
                        $id = $defaultValue;
                    }
                }

                // fallback if id has not been found yet
                if (!$id && $idField != 'id' && count($idFields) == 1) {
                    $defaultValue = isset($args['id']) && is_numeric($args['id']) ? $args['id'] : 0;
                    if (array_key_exists('id', $routeParams)) {
                        $id = (int) !empty($routeParams['id']) ? $routeParams['id'] : $defaultValue;
                    } elseif ($request->query->has('id')) {
                        $id = (int) $request->query->getInt('id', $defaultValue);
                    } else {
                        $id = $defaultValue;
                    }
                }
                $idValues[$idField] = $id;
            }

            return $idValues;
        }
    '''

    def private isValidIdentifier(Application it) '''
        /**
         * Checks if all identifiers are set properly.
         *
         * @param array  $idValues List of identifier field values
         *
         * @return boolean Whether all identifiers are set or not
         */
        public function isValidIdentifier(array $idValues)
        {
            if (!count($idValues)) {
                return false;
            }

            foreach ($idValues as $idField => $idValue) {
                if (!$idValue) {
                    return false;
                }
            }

            return true;
        }
    '''

    def private formatPermalink(Application it) '''
        /**
         * Create nice permalinks.
         *
         * @param string $name The given object title
         *
         * @return string processed permalink
         * @deprecated made obsolete by Doctrine extensions
         */
        public function formatPermalink($name)
        {
            $name = str_replace(
                ['ä', 'ö', 'ü', 'Ä', 'Ö', 'Ü', 'ß', '.', '?', '"', '/', ':', 'é', 'è', 'â'],
                ['ae', 'oe', 'ue', 'Ae', 'Oe', 'Ue', 'ss', '', '', '', '-', '-', 'e', 'e', 'a'],
                $name
            );
            $name = preg_replace("#(\s*\/\s*|\s*\+\s*|\s+)#", '-', strtolower($name));

            return $name;
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
         * @param boolean         $supportsHooks      Whether hooks are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         */
        public function processViewActionParameters($objectType, SortableColumns $sortableColumns, array $templateParameters = []«IF hasHookSubscribers», $supportsHooks = false«ENDIF»)
        {
            $contextArgs = ['controller' => $objectType, 'action' => 'view'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs))) {
                throw new Exception($this->__('Error! Invalid object type received.'));
            }

            $request = $this->request;
            $repository = $this->entityFactory->getRepository($objectType);
            $repository->setRequest($request);

            // parameter for used sorting field
            «new ControllerHelperFunctions().defaultSorting(it)»

            «IF hasTrees»

                if ('tree' == $request->query->getAlnum('tpl', '')) {
                    $templateParameters['trees'] = $repository->selectAllTrees();

                    return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
                }
            «ENDIF»

            $templateParameters['all'] = 'csv' == $request->getRequestFormat() ? 1 : $request->query->getInt('all', 0);
            $templateParameters['own'] = $request->query->getInt('own', $this->variableApi->get('«appName»', 'showOnlyOwnEntries', 0));

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
                    } else {
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

            $urlParameters = $templateParameters;
            foreach ($urlParameters as $parameterName => $parameterValue) {
                if (false !== stripos($parameterName, 'thumbRuntimeOptions')) {
                    unset($urlParameters[$parameterName]);
                }
            }

            $sort = $sortableColumns->getSortColumn()->getName();
            $sortdir = $sortableColumns->getSortDirection();
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

                if (true === $supportsHooks) {
                    // build RouteUrl instance for display hooks
                    $urlParameters['_locale'] = $request->getLocale();
                    $templateParameters['currentUrlObject'] = new RouteUrl('«appName.formatForDB»_' . $objectType . '_' . /*$templateParameters['routeArea'] . */'view', $urlParameters);
                }
            «ENDIF»

            $templateParameters['sort'] = $sortableColumns->generateSortableColumns();
            $templateParameters['quickNavForm'] = $quickNavForm->createView();
            «IF hasEditActions»

                $templateParameters['canBeCreated'] = $this->modelHelper->canBeCreated($objectType);
            «ENDIF»

            return $templateParameters;
        }
    '''

    def private processDisplayActionParameters(Application it) '''
        /**
         * Processes the parameters for a display action.
         *
         * @param string  $objectType         Name of treated entity type
         * @param array   $templateParameters Template data
         «IF hasHookSubscribers»
         * @param boolean $supportsHooks      Whether hooks are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         */
        public function processDisplayActionParameters($objectType, array $templateParameters = []«IF hasHookSubscribers», $supportsHooks = false«ENDIF»)
        {
            $contextArgs = ['controller' => $objectType, 'action' => 'display'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs))) {
                throw new Exception($this->__('Error! Invalid object type received.'));
            }
            «IF hasHookSubscribers»

                if (true === $supportsHooks) {
                    // build RouteUrl instance for display hooks
                    $entity = $templateParameters[$objectType];
                    $urlParameters = $entity->createUrlArgs();
                    $urlParameters['_locale'] = $this->request->getLocale();
                    $templateParameters['currentUrlObject'] = new RouteUrl('«appName.formatForDB»_' . $objectType . '_' . /*$templateParameters['routeArea'] . */'display', $urlParameters);
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
                throw new Exception($this->__('Error! Invalid object type received.'));
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
         * @param boolean $supportsHooks      Whether hooks are supported or not
         «ENDIF»
         *
         * @return array Enriched template parameters used for creating the response
         */
        public function processDeleteActionParameters($objectType, array $templateParameters = []«IF hasHookSubscribers», $supportsHooks = false«ENDIF»)
        {
            $contextArgs = ['controller' => $objectType, 'action' => 'delete'];
            if (!in_array($objectType, $this->getObjectTypes('controllerAction', $contextArgs))) {
                throw new Exception($this->__('Error! Invalid object type received.'));
            }

            return $this->addTemplateParameters($objectType, $templateParameters, 'controllerAction', $contextArgs);
        }
    '''

    def private addTemplateParameters(Application it) '''
        /**
         * Returns an array of additional template variables which are specific to the object type treated by this repository.
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
                    $routeName = $this->request->get('_route');
                    $routeNameParts = explode('_', $routeName);
                    $args['action'] = end($routeNameParts);
                }
                if (in_array($args['action'], ['index', 'view'])) {
                    $repository = $this->entityFactory->getRepository($objectType); 
                    $parameters = array_merge($parameters, $repository->getViewQuickNavParameters($context, $args));
                }
                «IF hasUploads»

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
            «IF needsFeatureActivationHelper»

                $parameters['featureActivationHelper'] = $this->featureActivationHelper;
            «ENDIF»

            return $parameters;
        }
    '''

    def private performGeoCoding(Application it) '''
        /**
         * Example method for performing geo coding in PHP.
         * To use this please customise it to your needs in the concrete subclass.
         * Also you have to call this method in a PrePersist-Handler of the
         * corresponding entity class.
         * There is also a method on JS level available in «getAppJsPath»«appName».EditFunctions.js.
         *
         * @param string $address The address input string
         *
         * @return Array The determined coordinates
         */
        public function performGeoCoding($address)
        {
            $lang = $this->request->getLocale();
            $url = 'https://maps.googleapis.com/maps/api/geocode/json?key=' . $this->variableApi->get('«appName»', 'googleMapsApiKey', '') . '&address=' . urlencode($address);
            $url .= '&region=' . $lang . '&language=' . $lang . '&sensor=false';

            $json = '';

            // we can either use Snoopy if available
            //require_once('«relativeAppRootPath»/vendor/Snoopy/Snoopy.class.php');
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

            if ($json != '') {
                $data = json_decode($json);

                if (json_last_error() == JSON_ERROR_NONE && $data->status == 'OK') {
                    $jsonResult = reset($data->results);
                    $location = $jsonResult->geometry->location;

                    $result['latitude'] = str_replace(',', '.', $location->lat);
                    $result['longitude'] = str_replace(',', '.', $location->lng);
                } else {
                    $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname'), 'field' => $field, 'address' => $address];
                    $this->logger->warning('{app}: User {user} tried geocoding for address "{address}", but failed.', $logArgs);
                }
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
