package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
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
        «IF hasViewActions»
            use Zikula\ExtensionsModule\Api\VariableApi;
        «ENDIF»
        «IF hasGeographical»
            use Zikula\UsersModule\Api\CurrentUserApi;
        «ENDIF»
        use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;

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

                /**
                 * @var VariableApi
                 */
                protected $variableApi;
            «ENDIF»
            «IF hasGeographical»

                /**
                 * @var CurrentUserApi
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

            /**
             * @var SelectionHelper
             */
            protected $selectionHelper;
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
            «IF hasUploads»

                /**
                 * @var String
                 */
                protected $dataDirectory;
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
             * @param VariableApi         $variableApi     VariableApi service instance
             «ENDIF»
             «IF hasGeographical»
             * @param CurrentUserApi      $currentUserApi  CurrentUserApi service instance
             «ENDIF»
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
             «IF hasViewActions && hasEditActions»
             * @param ModelHelper         $modelHelper     ModelHelper service instance
             «ENDIF»
             * @param SelectionHelper     $selectionHelper SelectionHelper service instance
             «IF hasUploads»
             * @param ImageHelper         $imageHelper     ImageHelper service instance
             «ENDIF»
             «IF needsFeatureActivationHelper»
             * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
             «ENDIF»
             «IF hasUploads»
             * @param String              $dataDirectory   The data directory name
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
                    VariableApi $variableApi,
                «ENDIF»
                «IF hasGeographical»
                    CurrentUserApi $currentUserApi,
                «ENDIF»
                «name.formatForCodeCapital»Factory $entityFactory,
                «IF hasViewActions && hasEditActions»
                    ModelHelper $modelHelper,
                «ENDIF»
                SelectionHelper $selectionHelper«IF hasUploads»,
                    ImageHelper $imageHelper
                «ENDIF»«IF needsFeatureActivationHelper»,
                    FeatureActivationHelper $featureActivationHelper
                «ENDIF»«IF hasUploads»,
                    $dataDirectory«ENDIF»)
            {
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
                    $this->variableApi = $variableApi;
                «ENDIF»
                «IF hasGeographical»
                    $this->currentUserApi = $currentUserApi;
                «ENDIF»
                $this->entityFactory = $entityFactory;
                «IF hasViewActions && hasEditActions»
                    $this->modelHelper = $modelHelper;
                «ENDIF»
                $this->selectionHelper = $selectionHelper;
                «IF hasUploads»
                    $this->imageHelper = $imageHelper;
                «ENDIF»
                «IF needsFeatureActivationHelper»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
                «IF hasUploads»
                    $this->dataDirectory = $dataDirectory;
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
            «IF hasUploads»

                «getFileBaseFolder»

                «checkAndCreateAllUploadFolders»

                «checkAndCreateUploadFolder»
            «ENDIF»
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
        public function getObjectTypes($context = '', $args = [])
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
        public function getDefaultObjectType($context = '', $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'helper', 'actionHandler', 'block', 'contentType', 'util'])) {
                $context = 'controllerAction';
            }

            $defaultObjectType = '«getLeadingEntity.name.formatForCode»';

            return $defaultObjectType;
        }
    '''

    def private retrieveIdentifier(Application it) '''
        /**
         * Retrieve identifier parameters for a given object type.
         *
         * @param Request $request    The current request
         * @param array   $args       List of arguments used as fallback if request does not contain a field
         * @param string  $objectType Name of treated entity type
         * @param array   $idFields   List of identifier field names
         *
         * @return array List of fetched identifiers
         */
        public function retrieveIdentifier(Request $request, array $args, $objectType = '', array $idFields)
        {
            $idValues = [];
            $routeParams = $request->get('_route_params', []);
            foreach ($idFields as $idField) {
                $defaultValue = isset($args[$idField]) && is_numeric($args[$idField]) ? $args[$idField] : 0;
                if ($this->selectionHelper->hasCompositeKeys($objectType)) {
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
                throw new Exception('Error! Invalid object type received.');
            }

            $request = $this->request;
            $repository = $this->entityFactory->getRepository($objectType);
            $repository->setRequest($request);

            // parameter for used sorting field
            «new ControllerHelperFunctions().defaultSorting(it)»

            «IF hasTrees»

                if ('tree' == $request->query->getAlnum('tpl', '')) {
                    $templateParameters['trees'] = $this->selectionHelper->getAllTrees($objectType);
                    $templateParameters = array_merge($templateParameters, $repository->getAdditionalTemplateParameters(«IF hasUploads»$this->imageHelper, «ENDIF»'controllerAction', $contextArgs));
                    «IF needsFeatureActivationHelper»
                        $templateParameters['featureActivationHelper'] = $this->featureActivationHelper;
                    «ENDIF»

                    return $templateParameters;
                }
            «ENDIF»

            $showOwnEntries = $request->query->getInt('own', $this->variableApi->get('«appName»', 'showOnlyOwnEntries', 0));
            $showAllEntries = $request->query->getInt('all', 0);

            «IF generateCsvTemplates»
                if (!$showAllEntries && $request->getRequestFormat() == 'csv') {
                    $showAllEntries = 1;
                }

            «ENDIF»

            «IF hasHookSubscribers»
                if (true === $supportsHooks) {
                    $currentUrlArgs = [];
                    if ($showAllEntries == 1) {
                        $currentUrlArgs['all'] = 1;
                    }
                    if ($showOwnEntries == 1) {
                        $currentUrlArgs['own'] = 1;
                    }
                }

            «ENDIF»
            $resultsPerPage = 0;
            if ($showAllEntries != 1) {
                // the number of items displayed on a page for pagination
                $resultsPerPage = $request->query->getInt('num', 0);
                if (in_array($resultsPerPage, [0, 10])) {
                    $resultsPerPage = $this->variableApi->get('«appName»', $objectType . 'EntriesPerPage', 10);
                }
            }

            $additionalParameters = $repository->getAdditionalTemplateParameters(«IF hasUploads»$this->imageHelper, «ENDIF»'controllerAction', $contextArgs);

            $additionalUrlParameters = [
                'all' => $showAllEntries,
                'own' => $showOwnEntries,
                'num' => $resultsPerPage
            ];
            foreach ($additionalParameters as $parameterName => $parameterValue) {
                if (false !== stripos($parameterName, 'thumbRuntimeOptions')) {
                    continue;
                }
                $additionalUrlParameters[$parameterName] = $parameterValue;
            }

            $templateParameters['own'] = $showAllEntries;
            $templateParameters['all'] = $showOwnEntries;
            $templateParameters['num'] = $resultsPerPage;
            $templateParameters['tpl'] = $request->query->getAlnum('tpl', '');

            $quickNavForm = $this->formFactory->create('«appNamespace»\Form\Type\QuickNavigation\\' . ucfirst($objectType) . 'QuickNavType', $templateParameters);
            if ($quickNavForm->handleRequest($request) && $quickNavForm->isSubmitted()) {
                $quickNavData = $quickNavForm->getData();
                foreach ($quickNavData as $fieldName => $fieldValue) {
                    if ($fieldName == 'routeArea') {
                        continue;
                    }
                    if ($fieldName == 'all') {
                        $showAllEntries = $additionalUrlParameters['all'] = $templateParameters['all'] = $fieldValue;
                    } elseif ($fieldName == 'own') {
                        $showOwnEntries = $additionalUrlParameters['own'] = $templateParameters['own'] = $fieldValue;
                    } elseif ($fieldName == 'num') {
                        $resultsPerPage = $additionalUrlParameters['num'] = $fieldValue;
                    } else {
                        // set filter as query argument, fetched inside repository
                        $request->query->set($fieldName, $fieldValue);
                    }
                }
            }
            $sort = $request->query->get('sort');
            $sortdir = $request->query->get('sortdir');
            $sortableColumns->setOrderBy($sortableColumns->getColumn($sort), strtoupper($sortdir));
            $sortableColumns->setAdditionalUrlParameters($additionalUrlParameters);
            $templateParameters['sort'] = $sort;
            $templateParameters['sortdir'] = $sortdir;

            $where = '';
            if ($showAllEntries == 1) {
                // retrieve item list without pagination
                $entities = $this->selectionHelper->getEntities($objectType, [], $where, $sort . ' ' . $sortdir);
            } else {
                // the current offset which is used to calculate the pagination
                $currentPage = $request->query->getInt('pos', 1);

                // retrieve item list with pagination
                list($entities, $objectCount) = $this->selectionHelper->getEntitiesPaginated($objectType, $where, $sort . ' ' . $sortdir, $currentPage, $resultsPerPage);

                $templateParameters['currentPage'] = $currentPage;
                $templateParameters['pager'] = [
                    'amountOfItems' => $objectCount,
                    'itemsPerPage' => $resultsPerPage
                ];
            }

            «IF hasHookSubscribers»
                if (true === $supportsHooks) {
                    // build RouteUrl instance for display hooks
                    $currentUrlArgs['_locale'] = $request->getLocale();
                    $currentUrlObject = new RouteUrl('«appName.formatForDB»_' . $objectType . '_' . /*$templateParameters['routeArea'] . */'view', $currentUrlArgs);
                }

            «ENDIF»
            $templateParameters['items'] = $entities;
            $templateParameters['sort'] = $sort;
            $templateParameters['sortdir'] = $sortdir;
            $templateParameters['num'] = $resultsPerPage;
            «IF hasHookSubscribers»
                if (true === $supportsHooks) {
                    $templateParameters['currentUrlObject'] = $currentUrlObject;
                }
            «ENDIF»
            $templateParameters = array_merge($templateParameters, $additionalParameters);

            $templateParameters['sort'] = $sortableColumns->generateSortableColumns();
            $templateParameters['quickNavForm'] = $quickNavForm->createView();

            $templateParameters['showAllEntries'] = $templateParameters['all'];
            $templateParameters['showOwnEntries'] = $templateParameters['own'];

            «IF needsFeatureActivationHelper»
                $templateParameters['featureActivationHelper'] = $this->featureActivationHelper;
            «ENDIF»
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
                throw new Exception('Error! Invalid object type received.');
            }

            $repository = $this->entityFactory->getRepository($objectType);
            $repository->setRequest($this->request);
            $entity = $templateParameters[$objectType];
            «IF hasHookSubscribers»

                if (true === $supportsHooks) {
                    // build RouteUrl instance for display hooks
                    $currentUrlArgs = $entity->createUrlArgs();
                    $currentUrlArgs['_locale'] = $this->request->getLocale();
                    $currentUrlObject = new RouteUrl('«appName.formatForDB»_' . $objectType . '_' . /*$templateParameters['routeArea'] . */'display', $currentUrlArgs);
                    $templateParameters['currentUrlObject'] = $currentUrlObject;
                }
            «ENDIF»

            $additionalParameters = $repository->getAdditionalTemplateParameters(«IF hasUploads»$this->imageHelper, «ENDIF»'controllerAction', $contextArgs);
            $templateParameters = array_merge($templateParameters, $additionalParameters);
            «IF needsFeatureActivationHelper»
                $templateParameters['featureActivationHelper'] = $this->featureActivationHelper;
            «ENDIF»

            return $templateParameters;
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
                throw new Exception('Error! Invalid object type received.');
            }

            $repository = $this->entityFactory->getRepository($objectType);
            $repository->setRequest($this->request);

            $additionalParameters = $repository->getAdditionalTemplateParameters(«IF hasUploads»$this->imageHelper, «ENDIF»'controllerAction', $contextArgs);
            $templateParameters = array_merge($templateParameters, $additionalParameters);
            «IF needsFeatureActivationHelper»
                $templateParameters['featureActivationHelper'] = $this->featureActivationHelper;
            «ENDIF»

            return $templateParameters;
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
                throw new Exception('Error! Invalid object type received.');
            }

            $repository = $this->entityFactory->getRepository($objectType);
            $repository->setRequest($this->request);

            $additionalParameters = $repository->getAdditionalTemplateParameters(«IF hasUploads»$this->imageHelper, «ENDIF»'controllerAction', $contextArgs);
            $templateParameters = array_merge($templateParameters, $additionalParameters);

            return $templateParameters;
        }
    '''

    def private getFileBaseFolder(Application it) '''
        /**
         * Retrieve the base path for given object type and upload field combination.
         *
         * @param string  $objectType   Name of treated entity type
         * @param string  $fieldName    Name of upload field
         * @param boolean $ignoreCreate Whether to ignore the creation of upload folders on demand or not
         *
         * @return mixed Output
         *
         * @throws Exception If an invalid object type is used
         */
        public function getFileBaseFolder($objectType, $fieldName, $ignoreCreate = false)
        {
            $contextArgs = ['helper' => $objectType, 'action' => 'getFileBaseFolder'];
            if (!in_array($objectType, $this->getObjectTypes('helper', $contextArgs))) {
                throw new Exception('Error! Invalid object type received.');
            }

            $basePath = $this->dataDirectory . '/«appName»/';

            switch ($objectType) {
                «FOR entity : getUploadEntities.filter(Entity)»
                    «val uploadFields = entity.getUploadFieldsEntity»
                    case '«entity.name.formatForCode»':
                        «IF uploadFields.size > 1»
                            $basePath .= '«entity.nameMultiple.formatForDB»/';
                            switch ($fieldName) {
                                «FOR uploadField : uploadFields»
                                    case '«uploadField.name.formatForCode»':
                                        $basePath .= '«uploadField.subFolderPathSegment»/';
                                        break;
                                «ENDFOR»
                            }
                        «ELSE»
                            $basePath .= '«entity.nameMultiple.formatForDB»/«uploadFields.head.subFolderPathSegment»/';
                        «ENDIF»
                    break;
                «ENDFOR»
            }

            $result = $basePath;
            if (substr($result, -1, 1) != '/') {
                // reappend the removed slash
                $result .= '/';
            }

            if (!is_dir($result) && !$ignoreCreate) {
                $this->checkAndCreateAllUploadFolders();
            }

            return $result;
        }
    '''

    def private checkAndCreateAllUploadFolders(Application it) '''
        /**
         * Creates all required upload folders for this application.
         *
         * @return Boolean Whether everything went okay or not
         */
        public function checkAndCreateAllUploadFolders()
        {
            $result = true;
            «FOR uploadEntity : getUploadEntities»

                «FOR uploadField : uploadEntity.getUploadFieldsEntity»
                    $result &= $this->checkAndCreateUploadFolder('«uploadField.entity.name.formatForCode»', '«uploadField.name.formatForCode»', '«uploadField.allowedExtensions»');
                «ENDFOR»
            «ENDFOR»

            return $result;
        }
    '''

    def private checkAndCreateUploadFolder(Application it) '''
        /**
         * Creates upload folder including a subfolder for thumbnail and an .htaccess file within it.
         *
         * @param string $objectType        Name of treated entity type
         * @param string $fieldName         Name of upload field
         * @param string $allowedExtensions String with list of allowed file extensions (separated by ", ")
         *
         * @return Boolean Whether everything went okay or not
         */
        protected function checkAndCreateUploadFolder($objectType, $fieldName, $allowedExtensions = '')
        {
            $uploadPath = $this->getFileBaseFolder($objectType, $fieldName, true);

            $fs = new Filesystem();
            $flashBag = $this->session->getFlashBag();

            // Check if directory exist and try to create it if needed
            if (!$fs->exists($uploadPath)) {
                try {
                    $fs->mkdir($uploadPath, 0777);
                } catch (IOExceptionInterface $e) {
                    $flashBag->add('error', $this->__f('The upload directory "%s" does not exist and could not be created. Try to create it yourself and make sure that this folder is accessible via the web and writable by the webserver.', ['%s' => $e->getPath()]));
                    $this->logger->error('{app}: The upload directory {directory} does not exist and could not be created.', ['app' => '«appName»', 'directory' => $uploadPath]);

                    return false;
                }
            }

            // Check if directory is writable and change permissions if needed
            if (!is_writable($uploadPath)) {
                try {
                    $fs->chmod($uploadPath, 0777);
                } catch (IOExceptionInterface $e) {
                    $flashBag->add('warning', $this->__f('Warning! The upload directory at "%s" exists but is not writable by the webserver.', ['%s' => $e->getPath()]));
                    $this->logger->error('{app}: The upload directory {directory} exists but is not writable by the webserver.', ['app' => '«appName»', 'directory' => $uploadPath]);

                    return false;
                }
            }

            // Write a htaccess file into the upload directory
            $htaccessFilePath = $uploadPath . '/.htaccess';
            $htaccessFileTemplate = '«relativeAppRootPath»/«getAppDocPath»htaccessTemplate';
            if (!$fs->exists($htaccessFilePath) && $fs->exists($htaccessFileTemplate)) {
                try {
                    $extensions = str_replace(',', '|', str_replace(' ', '', $allowedExtensions));
                    $htaccessContent = str_replace('__EXTENSIONS__', $extensions, file_get_contents($htaccessFileTemplate, false));
                    $fs->dumpFile($htaccessFilePath, $htaccessContent);
                } catch (IOExceptionInterface $e) {
                    $flashBag->add('error', $this->__f('An error occured during creation of the .htaccess file in directory "%s".', ['%s' => $e->getPath()]));
                    $this->logger->error('{app}: An error occured during creation of the .htaccess file in directory {directory}.', ['app' => '«appName»', 'directory' => $uploadPath]);
                }
            }

            return true;
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
            $url = 'https://maps.googleapis.com/maps/api/geocode/json?address=' . urlencode($address);
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
