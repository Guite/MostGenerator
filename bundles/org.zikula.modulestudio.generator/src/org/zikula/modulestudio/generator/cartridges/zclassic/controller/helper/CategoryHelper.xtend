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
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;

        /**
         * Category helper base class.
         */
        abstract class AbstractCategoryHelper
        {
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

            /**
             * CategoryHelper constructor.
             *
             * @param TranslatorInterface                 $translator                 Translator service instance
             * @param RequestStack                        $requestStack               RequestStack service instance
             * @param LoggerInterface                     $logger                     Logger service instance
             * @param CurrentUserApiInterface             $currentUserApi             CurrentUserApi service instance
             * @param CategoryRegistryRepositoryInterface $categoryRegistryRepository CategoryRegistryRepository service instance
             * @param CategoryPermissionApiInterface      $categoryPermissionApi      CategoryPermissionApi service instance
             */
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

            «categoryBaseImpl»
        }
    '''

    def private categoryBaseImpl(Application it) '''
        /**
         * Defines whether multiple selection is enabled for a given object type
         * or not. Subclass can override this method to apply a custom behaviour
         * to certain category registries for example.
         *
         * @param string $objectType The object type to retrieve
         * @param string $registry   Name of category registry to be used (optional)
         *
         * @return boolean true if multiple selection is allowed, else false
         */
        public function hasMultipleSelection($objectType = '', $registry = '')
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
         *
         * @param string $objectType The object type to retrieve
         * @param string $source     Where to retrieve the data from (defaults to POST)
         *
         * @return array The fetched data indexed by the registry id
         */
        public function retrieveCategoriesFromRequest($objectType = '', $source = 'POST')
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
        	}

            $request = $this->requestStack->getCurrentRequest();
            $dataSource = $source == 'GET' ? $request->query : $request->request;
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
         * @param string       $objectType   The treated object type (optional)
         * @param array        $catIds       Category ids grouped by property name
         *
         * @return QueryBuilder The enriched query builder instance
         */
        public function buildFilterClauses(QueryBuilder $queryBuilder, $objectType = '', array $catIds = [])
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

                $filtersPerRegistry[] = '(
                    tblCategories.categoryRegistryId = :propId' . $propertyName . '
                    AND tblCategories.category IN (:categories' . $propertyName . ')
                )';
                $filterParameters['registries'][$propertyName] = $propertyId;
                $filterParameters['values'][$propertyName] = $catIdsForProperty;
            }

            if (count($filtersPerRegistry) > 0) {
                if (count($filtersPerRegistry) == 1) {
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
         *
         * @param string $objectType The object type to retrieve
         *
         * @return array list of the registries (property name as key, id as value)
         */
        «IF targets('2.0')»protected«ELSE»public«ENDIF» function getAllProperties($objectType = '')
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
         *
         * @param string $objectType The object type to retrieve
         * @param string $arrayKey   Key for the result array (optional)
         *
         * @return array list of the registries (registry id as key, main category id as value)
         */
        «IF targets('2.0')»protected«ELSE»public«ENDIF» function getAllPropertiesWithMainCat($objectType = '', $arrayKey = 'property')
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
         *
         * @param string $objectType The object type to retrieve
         * @param string $property   The property name (optional)
         *
         * @return integer The main category id of desired tree
         */
        public function getMainCatForProperty($objectType = '', $property = '')
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
        	}

            $registries = $this->getAllPropertiesWithMainCat($objectType, 'property');
            if ($registries && isset($registries[$property]) && $registries[$property]) {
                return $registries[$property];
            }

            return null;
        }

        /**
         * Returns the name of the primary registry.
         *
         * @param string $objectType The object type to retrieve
         *
         * @return string name of the main registry
         */
        public function getPrimaryProperty($objectType = '')
        {
            return 'Main';
        }

        /**
         * Filters a given list of entities to these the current user has permissions for.
         *
         * @param array|ArrayCollection $entities The given list of entities
         *
         * @return array The filtered list of entities
         */
        public function filterEntitiesByPermission($entities)
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
         *
         * @param object $entity The entity to check permission for
         *
         * @return boolean True if permissions are given, false otherwise
         */
        public function hasPermission($entity)
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
         *
         * @param object $entity The entity to check permission for
         *
         * @return boolean True if access is required for all categories, false otherwise
         */
        protected function requireAccessForAll($entity)
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
