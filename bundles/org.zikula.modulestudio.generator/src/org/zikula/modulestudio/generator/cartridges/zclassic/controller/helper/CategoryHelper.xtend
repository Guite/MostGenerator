package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class CategoryHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for category functions')
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/CategoryHelper.php',
            fh.phpFileContent(it, categoryHelperBaseClass), fh.phpFileContent(it, categoryHelperImpl)
        )
    }

    def private categoryHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        use Zikula\CategoriesModule\Api\CategoryRegistryApi;
        use Zikula\CategoriesModule\Api\CategoryPermissionApi;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\UsersModule\Api\CurrentUserApi;

        /**
         * Category helper base class.
         */
        abstract class AbstractCategoryHelper
        {
            /**
             * @var ContainerBuilder
             */
            protected $container;

            /**
             * @var TranslatorInterface
             */
            protected $translator;

            /**
             * @var SessionInterface
             */
            protected $session;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * @var RequestStack
             */
            protected $requestStack;

            /**
             * @var CurrentUserApi
             */
            private $currentUserApi;

            /**
             * @var CategoryRegistryApi
             */
            private $categoryRegistryApi;

            /**
             * @var CategoryPermissionApi
             */
            private $categoryPermissionApi;

            /**
             * CategoryHelper constructor.
             *
             * @param ContainerBuilder      $container             ContainerBuilder service instance
             * @param TranslatorInterface   $translator            Translator service instance
             * @param SessionInterface      $session               Session service instance
             * @param LoggerInterface       $logger                Logger service instance
             * @param RequestStack          $requestStack          RequestStack service instance
             * @param CurrentUserApi        $currentUserApi        CurrentUserApi service instance
             * @param CategoryRegistryApi   $categoryRegistryApi   CategoryRegistryApi service instance
             * @param CategoryPermissionApi $categoryPermissionApi CategoryPermissionApi service instance
             */
            public function __construct(
                ContainerBuilder $container,
                TranslatorInterface $translator,
                SessionInterface $session,
                LoggerInterface $logger,
                RequestStack $requestStack,
                CurrentUserApi $currentUserApi,
                CategoryRegistryApi $categoryRegistryApi,
                CategoryPermissionApi $categoryPermissionApi)
            {
                $this->container = $container;
                $this->translator = $translator;
                $this->session = $session;
                $this->logger = $logger;
                $this->requestStack = $requestStack;
                $this->currentUserApi = $currentUserApi;
                $this->categoryRegistryApi = $categoryRegistryApi;
                $this->categoryPermissionApi = $categoryPermissionApi;
            }

            «categoryBaseImpl»
        }
    '''

    def private categoryBaseImpl(Application it) '''
        /**
         * Retrieves the main/default category of «appName».
         *
         * @param string $objectType The object type to retrieve (optional)
         * @param string $registry   Name of category registry to be used (optional)
         * @deprecated Use the methods getAllProperties, getAllPropertiesWithMainCat, getMainCatForProperty and getPrimaryProperty instead
         *
         * @return mixed Category array on success, false on failure
         */
        public function getMainCat($objectType = '', $registry = '')
        {
            if (empty($registry)) {
                // default to the primary registry
                $registry = $this->getPrimaryProperty($objectType);
            }

            $objectType = $this->determineObjectType($objectType, 'getMainCat');

            $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')];
            $this->logger->warning('{app}: User {user} called CategoryHelper#getMainCat which is deprecated.', $logArgs);

            return $this->categoryRegistryApi->getModuleCategoryId('«appName»', ucfirst($objectType) . 'Entity', $registry, 32); // 32 == /__System/Modules/Global
        }

        /**
         * Defines whether multiple selection is enabled for a given object type
         * or not. Subclass can override this method to apply a custom behaviour
         * to certain category registries for example.
         *
         * @param string $objectType The object type to retrieve (optional)
         * @param string $registry   Name of category registry to be used (optional)
         *
         * @return boolean true if multiple selection is allowed, else false
         */
        public function hasMultipleSelection($objectType = '', $registry = '')
        {
            if (empty($args['registry'])) {
                // default to the primary registry
                $registry = $this->getPrimaryProperty($objectType);
            }

            $objectType = $this->determineObjectType($objectType, 'hasMultipleSelection');

            // we make no difference between different category registries here
            // if you need a custom behaviour you should override this method

            $result = false;
            switch ($objectType) {
                «FOR entity : getCategorisableEntities»
                    case '«entity.name.formatForCode»':
                        $result = «entity.categorisableMultiSelection.displayBool»;
                        break;
                «ENDFOR»
            }

            return $result;
        }

        /**
         * Retrieves input data from POST for all registries.
         *
         * @param string $objectType The object type to retrieve (optional)
         * @param string $source     Where to retrieve the data from (defaults to POST)
         *
         * @return array The fetched data indexed by the registry id
         */
        public function retrieveCategoriesFromRequest($objectType = '', $source = 'POST')
        {
            $request = $this->requestStack->getCurrentRequest();
            $dataSource = $source == 'GET' ? $request->query : $request->request;

            $catIdsPerRegistry = [];

            $objectType = $this->determineObjectType($objectType, 'retrieveCategoriesFromRequest');
            $properties = $this->getAllProperties($objectType);
            $inputValues = null;
            $inputName = '«appName.toLowerCase»_' . strtolower($objectType) . 'quicknav';
            if (!$dataSource->has($inputName)) {
                $inputName = '«appName.toLowerCase»_' . strtolower($objectType) . 'finder';
            }
            if ($dataSource->has($inputName)) {
                $inputValues = $dataSource->get($inputName);
            }
            if (null === $inputValues) {
                return $catIdsPerRegistry;
            }
            $inputCategories = isset($inputValues['categories']) ? $inputValues['categories'] : [];

            if (!count($inputCategories)) {
                return $catIdsPerRegistry;
            }

            foreach ($properties as $propertyName => $propertyId) {
                $inputValue = isset($inputCategories['registry_' . $propertyId]) ? $inputCategories['registry_' . $propertyId] : [];
                if (!is_array($inputValue)) {
                    $inputValue = [$inputValue];
                }

                // prevent "All" option hiding all entries
                foreach ($inputValue as $k => $v) {
                    if ($v == 0) {
                        unset($inputValue[$k]);
                    }
                }

                $catIdsPerRegistry[$propertyName] = $inputValue;
            }

            return $catIdsPerRegistry;
        }

        /**
         * Adds a list of where clauses for a certain list of categories to a given query builder.
         *
         * @param QueryBuilder $queryBuilder Query builder instance to be enhanced
         * @param string       $objectType   The object type to be treated (optional)
         * @param array        $catIds       Category ids grouped by property name
         *
         * @return QueryBuilder The enriched query builder instance
         */
        public function buildFilterClauses(QueryBuilder $queryBuilder, $objectType = '', $catIds = [])
        {
            $qb = $queryBuilder;

            $properties = $this->getAllProperties($objectType);

            $filtersPerRegistry = [];
            $filterParameters = [
                'values' => [],
                'registries' => []
            ];

            foreach ($properties as $propertyName => $propertyId) {
                if (!isset($catIds[$propertyName]) || !is_array($catIds[$propertyName]) || !count($catIds[$propertyName])) {
                    continue;
                }

                $filterParameters['values'][$propertyName] = $catIds[$propertyName];
                $filterParameters['registries'][$propertyName] = $propertyId;
                $filtersPerRegistry[] = '(tblCategories.category IN (:propName' . $propertyName . ') AND tblCategories.categoryRegistryId = :propId' . $propertyName . ')';
            }

            if (count($filtersPerRegistry) > 0) {
                if (count($filtersPerRegistry) == 1) {
                    $qb->andWhere($filtersPerRegistry[0]);
                } else {
                    «/* See http://stackoverflow.com/questions/9815047/chaining-orx-in-doctrine2-query-builder
                    $qb->andWhere($qb->expr()->orX()->addMultiple($filtersPerRegistry));*/»$qb->andWhere('(' . implode(' OR ', $filtersPerRegistry) . ')');
                }
                foreach ($filterParameters['values'] as $propertyName => $filterValue) {
                    $qb->setParameter('propName' . $propertyName, $filterValue)
                       ->setParameter('propId' . $propertyName, $filterParameters['registries'][$propertyName]);
                }
            }

            return $qb;
        }

        /**
         * Returns a list of all registries / properties for a given object type.
         *
         * @param string $objectType The object type to retrieve (optional)
         *
         * @return array list of the registries (property name as key, id as value)
         */
        public function getAllProperties($objectType = '')
        {
            $objectType = $this->determineObjectType($objectType, 'getAllProperties');

            return $this->categoryRegistryApi->getModuleRegistriesIds('«appName»', ucfirst($objectType) . 'Entity');
        }

        /**
         * Returns a list of all registries with main category for a given object type.
         *
         * @param string $objectType The object type to retrieve (optional)
         * @param string $arrayKey   Key for the result array (optional)
         *
         * @return array list of the registries (registry id as key, main category id as value)
         */
        public function getAllPropertiesWithMainCat($objectType = '', $arrayKey = '')
        {
            $objectType = $this->determineObjectType($objectType, 'getAllPropertiesWithMainCat');

            return $this->categoryRegistryApi->getModuleCategoryIds('«appName»', ucfirst($objectType) . 'Entity', $arrayKey);
        }

        /**
         * Returns the main category id for a given object type and a certain property name.
         *
         * @param string $objectType The object type to retrieve (optional)
         * @param string $property   The property name (optional)
         *
         * @return integer The main category id of desired tree
         */
        public function getMainCatForProperty($objectType = '', $property = '')
        {
            $objectType = $this->determineObjectType($objectType, 'getMainCatForProperty');

            return $this->categoryRegistryApi->getModuleCategoryId('«appName»', ucfirst($objectType) . 'Entity', $property);
        }

        /**
         * Returns the name of the primary registry.
         *
         * @param string $objectType The object type to retrieve (optional)
         *
         * @return string name of the main registry
         */
        public function getPrimaryProperty($objectType = '')
        {
            return 'Main';
        }

        /**
         * Checks whether permissions are granted to the given categories or not.
         *
         * @param object $entity The entity to check permission for
         *
         * @return boolean True if permissions are given, false otherwise
         */
        public function hasPermission($entity)
        {
            $objectType = $entity->get_objectType();
            $categories = $entity['categories'];

            $registries = $this->getAllProperties($objectType);
            $registries = array_flip($registries);

            $categoryInfo = [];
            foreach ($categories as $category) {
                $registryId = $category->getCategoryRegistryId();
                $registryName = $registries[$registryId];
                if (!isset($categoryInfo[$registryName])) {
                    $categoryInfo[$registryName] = [];
                }
                $categoryInfo[$registryName][] = $category->getCategory()->toArray();
            }

            return $this->categoryPermissionApi->hasCategoryAccess($categoryInfo, ACCESS_OVERVIEW);
        }

        /**
         * Determine object type using controller util methods.
         *
         * @param string $objectType The object type to retrieve (optional)
         * @param string $methodName Name of calling method
         *
         * @return string name of the determined object type
         */
        protected function determineObjectType($objectType = '', $methodName = '')
        {
            «/* we can not use the container here, because it is not available yet during installation */»
            $controllerHelper = new \«appNamespace»\Helper\ControllerHelper($this->container, $this->translator, $this->session, $this->logger);
            $utilArgs = ['api' => 'category', 'action' => $methodName];
            if (!in_array($objectType, $controllerHelper->getObjectTypes('api', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('api', $utilArgs);
            }

            return $objectType;
        }
    '''

    def private categoryHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractCategoryHelper;

        /**
         * Category helper implementation class.
         */
        class CategoryHelper extends AbstractCategoryHelper
        {
            // feel free to extend the category helper here
        }
    '''
}
