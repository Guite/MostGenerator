package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class CategoryHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for category functions'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/CategoryHelper.php', categoryHelperBaseClass, categoryHelperImpl)
    }

    def private categoryHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use InvalidArgumentException;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\CategoriesModule\Api\ApiInterface\CategoryPermissionApiInterface;
        use Zikula\CategoriesModule\Entity\RepositoryInterface\CategoryRegistryRepositoryInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\Doctrine\EntityAccess;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;

        /**
         * Category helper base class.
         */
        abstract class AbstractCategoryHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var TranslatorInterface
         */
        protected $translator;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var LoggerInterface
         */
        protected $logger;

        /**
         * @var CurrentUserApiInterface
         */
        protected $currentUserApi;

        /**
         * @var CategoryRegistryRepositoryInterface
         */
        protected $categoryRegistryRepository;

        /**
         * @var CategoryPermissionApiInterface
         */
        protected $categoryPermissionApi;

        public function __construct(
            TranslatorInterface $translator,
            RequestStack $requestStack,
            LoggerInterface $logger,
            CurrentUserApiInterface $currentUserApi,
            CategoryRegistryRepositoryInterface $categoryRegistryRepository,
            CategoryPermissionApiInterface $categoryPermissionApi
        ) {
            $this->translator = $translator;
            $this->requestStack = $requestStack;
            $this->logger = $logger;
            $this->currentUserApi = $currentUserApi;
            $this->categoryRegistryRepository = $categoryRegistryRepository;
            $this->categoryPermissionApi = $categoryPermissionApi;
        }

        /**
         * Defines whether multiple selection is enabled for a given object type
         * or not. Subclass can override this method to apply a custom behaviour
         * to certain category registries for example.
         «IF !targets('3.0')»
         *
         * @param string $objectType The object type to retrieve
         * @param string $registry Name of category registry to be used (optional)
         *
         * @return bool true if multiple selection is allowed, else false
         «ENDIF»
         */
        public function hasMultipleSelection(«IF targets('3.0')»string «ENDIF»$objectType = '', «IF targets('3.0')»string «ENDIF»$registry = '')«IF targets('3.0')»: bool«ENDIF»
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
            }
            if (empty($args['registry'])) {
                // default to the primary registry
                $registry = $this->getPrimaryProperty($objectType);
            }

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
         «IF !targets('3.0')»
         *
         * @param string $objectType The object type to retrieve
         * @param string $source Where to retrieve the data from (defaults to POST)
         *
         * @return array The fetched data indexed by the registry id
         «ENDIF»
         */
        public function retrieveCategoriesFromRequest(«IF targets('3.0')»string «ENDIF»$objectType = '', «IF targets('3.0')»string «ENDIF»$source = 'POST')«IF targets('3.0')»: array«ENDIF»
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
            }

            $request = $this->requestStack->getCurrentRequest();
            $dataSource = 'GET' === $source ? $request->query : $request->request;
            $catIdsPerRegistry = [];

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
            «IF targets('3.0')»
                $inputCategories = $inputValues['categories'] ?? [];
            «ELSE»
                $inputCategories = isset($inputValues['categories']) ? $inputValues['categories'] : [];
            «ENDIF»

            if (!count($inputCategories)) {
                return $catIdsPerRegistry;
            }

            foreach ($properties as $propertyName => $propertyId) {
                $registryKey = 'registry_' . $propertyId;
                «IF targets('3.0')»
                    $inputValue = $inputCategories[$registryKey] ?? [];
                «ELSE»
                    $inputValue = isset($inputCategories[$registryKey]) ? $inputCategories[$registryKey] : [];
                «ENDIF»
                if (!is_array($inputValue)) {
                    $inputValue = [$inputValue];
                }

                // prevent "All" option hiding all entries
                foreach ($inputValue as $k => $v) {
                    if (0 === $v) {
                        unset($inputValue[$k]);
                    }
                }

                $catIdsPerRegistry[$propertyName] = $inputValue;
            }

            return $catIdsPerRegistry;
        }

        /**
         * Adds a list of where clauses for a certain list of categories to a given query builder.
         «IF !targets('3.0')»
         *
         * @param QueryBuilder $queryBuilder Query builder instance to be enhanced
         * @param string $objectType The treated object type (optional)
         * @param array $catIds Category ids grouped by property name
         *
         * @return QueryBuilder The enriched query builder instance
         «ENDIF»
         */
        public function buildFilterClauses(QueryBuilder $queryBuilder, «IF targets('3.0')»string «ENDIF»$objectType = '', array $catIds = [])«IF targets('3.0')»: QueryBuilder«ENDIF»
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
                $catIdsForProperty = [];
                foreach ($catIds[$propertyName] as $catId) {
                    if (!$catId) {
                        continue;
                    }
                    $catIdsForProperty[] = $catId;
                }
                if (!count($catIdsForProperty)) {
                    continue;
                }

                $propertyName = str_replace(' ', '', $propertyName);
                $filtersPerRegistry[] = '(
                    tblCategories.categoryRegistryId = :propId' . $propertyName . '
                    AND tblCategories.category IN (:categories' . $propertyName . ')
                )';
                $filterParameters['registries'][$propertyName] = $propertyId;
                $filterParameters['values'][$propertyName] = $catIdsForProperty;
            }

            if (0 < count($filtersPerRegistry)) {
                if (1 === count($filtersPerRegistry)) {
                    $qb->andWhere($filtersPerRegistry[0]);
                } else {
                    «/* See http://stackoverflow.com/questions/9815047/chaining-orx-in-doctrine2-query-builder
                    $qb->andWhere($qb->expr()->orX()->addMultiple($filtersPerRegistry));*/»$qb->andWhere('(' . implode(' OR ', $filtersPerRegistry) . ')');
                }
                foreach ($filterParameters['values'] as $propertyName => $filterValue) {
                    $qb->setParameter('propId' . $propertyName, $filterParameters['registries'][$propertyName])
                       ->setParameter('categories' . $propertyName, $filterValue);
                }
            }

            return $qb;
        }

        /**
         * Returns a list of all registries / properties for a given object type.
         «IF !targets('3.0')»
         *
         * @param string $objectType The object type to retrieve
         *
         * @return array List of the registries (property name as key, id as value)
         «ENDIF»
         */
        public function getAllProperties(«IF targets('3.0')»string «ENDIF»$objectType = '')«IF targets('3.0')»: array«ENDIF»
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
            }

            $moduleRegistries = $this->categoryRegistryRepository->findBy([
                'modname' => '«appName»',
                'entityname' => ucfirst($objectType) . 'Entity'
            ]);

            $result = [];
            foreach ($moduleRegistries as $registry) {
                $result[$registry['property']] = $registry['id'];
            }

            return $result;
        }

        /**
         * Returns a list of all registries with main category for a given object type.
         «IF !targets('3.0')»
         *
         * @param string $objectType The object type to retrieve
         * @param string $arrayKey Key for the result array (optional)
         *
         * @return array List of the registries (registry id as key, main category id as value)
         «ENDIF»
         */
        public function getAllPropertiesWithMainCat(«IF targets('3.0')»string «ENDIF»$objectType = '', «IF targets('3.0')»string «ENDIF»$arrayKey = 'property')«IF targets('3.0')»: array«ENDIF»
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
            }

            $moduleRegistries = $this->categoryRegistryRepository->findBy([
                'modname' => '«appName»',
                'entityname' => ucfirst($objectType) . 'Entity'
            ], ['id' => 'ASC']);

            $result = [];
            foreach ($moduleRegistries as $registry) {
                $registry = $registry->toArray();
                $result[$registry[$arrayKey]] = $registry['category']->getId();
            }

            return $result;
        }

        /**
         * Returns the main category id for a given object type and a certain property name.
         «IF !targets('3.0')»
         *
         * @param string $objectType The object type to retrieve
         * @param string $property The property name (optional)
         *
         * @return int The main category id of desired tree
         «ENDIF»
         */
        public function getMainCatForProperty(«IF targets('3.0')»string «ENDIF»$objectType = '', «IF targets('3.0')»string «ENDIF»$property = '')«IF targets('3.0')»: ?int«ENDIF»
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
            }

            $registries = $this->getAllPropertiesWithMainCat($objectType);
            if ($registries && isset($registries[$property]) && $registries[$property]) {
                return $registries[$property];
            }

            return null;
        }

        /**
         * Returns the name of the primary registry.
         «IF !targets('3.0')»
         *
         * @param string $objectType The object type to retrieve
         *
         * @return string Name of the main registry
         «ENDIF»
         */
        public function getPrimaryProperty(«IF targets('3.0')»string «ENDIF»$objectType = '')«IF targets('3.0')»: string«ENDIF»
        {
            return 'Main';
        }

        /**
         * Filters a given list of entities to these the current user has permissions for.
         *
         * @param array|ArrayCollection $entities The given list of entities
         «IF !targets('3.0')»
         *
         * @return array The filtered list of entities
         «ENDIF»
         */
        public function filterEntitiesByPermission($entities)«IF targets('3.0')»: array«ENDIF»
        {
            $filteredEntities = [];
            foreach ($entities as $entity) {
                if (!$this->hasPermission($entity)) {
                    continue;
                }
                $filteredEntities[] = $entity;
            }

            return $filteredEntities;
        }

        /**
         * Checks whether permissions are granted to the given categories or not.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity The entity to check permission for
         *
         * @return bool True if permissions are given, false otherwise
         «ENDIF»
         */
        public function hasPermission(EntityAccess $entity)«IF targets('3.0')»: bool«ENDIF»
        {
            $requireAccessForAll = $this->requireAccessForAll($entity);

            return $this->categoryPermissionApi->hasCategoryAccess($entity->getCategories()->toArray(), ACCESS_OVERVIEW, $requireAccessForAll);
        }

        /**
         * Returns whether permissions are required for all categories
         * of a specific entity or for only one category.
         *
         * Returning false allows access if the user has access
         * to at least one selected category.
         * Returning true only allows access if the user has access
         * to all selected categories.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity The entity to check permission for
         *
         * @return bool True if access is required for all categories, false otherwise
         «ENDIF»
         */
        protected function requireAccessForAll(EntityAccess $entity)«IF targets('3.0')»: bool«ENDIF»
        {
            return false;
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
