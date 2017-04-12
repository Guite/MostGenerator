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

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for category functions')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/CategoryHelper.php',
            fh.phpFileContent(it, categoryHelperBaseClass), fh.phpFileContent(it, categoryHelperImpl)
        )
    }

    def private categoryHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use InvalidArgumentException;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        «IF !targets('1.5')»
            use Zikula\CategoriesModule\Api\CategoryRegistryApi;
        «ENDIF»
        use Zikula\CategoriesModule\Api\«IF targets('1.5')»ApiInterface\CategoryPermissionApiInterface«ELSE»CategoryPermissionApi«ENDIF»;
        «IF targets('1.5')»
            use Zikula\CategoriesModule\Entity\RepositoryInterface\CategoryRegistryRepositoryInterface;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\UsersModule\Api\«IF targets('1.5')»ApiInterface\CurrentUserApiInterface«ELSE»CurrentUserApi«ENDIF»;

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
             * @var SessionInterface
             */
            protected $session;

            /**
             * @var Request
             */
            protected $request;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * @var CurrentUserApi«IF targets('1.5')»Interface«ENDIF»
             */
            protected $currentUserApi;

            «IF targets('1.5')»
                /**
                 * @var CategoryRegistryRepositoryInterface
                 */
                protected $categoryRegistryRepository;
            «ELSE»
                /**
                 * @var CategoryRegistryApi
                 */
                protected $categoryRegistryApi;
            «ENDIF»

            /**
             * @var CategoryPermissionApi«IF targets('1.5')»Interface«ENDIF»
             */
            protected $categoryPermissionApi;

            /**
             * CategoryHelper constructor.
             *
             * @param TranslatorInterface   $translator            Translator service instance
             * @param SessionInterface      $session               Session service instance
             * @param RequestStack          $requestStack          RequestStack service instance
             * @param LoggerInterface       $logger                Logger service instance
             * @param CurrentUserApi«IF targets('1.5')»Interface«ELSE»       «ENDIF» $currentUserApi        CurrentUserApi service instance
             «IF targets('1.5')»
             * @param CategoryRegistryRepositoryInterface $categoryRegistryRepository CategoryRegistryRepository service instance
             «ELSE»
             * @param CategoryRegistryApi   $categoryRegistryApi   CategoryRegistryApi service instance
             «ENDIF»
             * @param CategoryPermissionApi«IF targets('1.5')»Interface«ENDIF» $categoryPermissionApi CategoryPermissionApi service instance
             */
            public function __construct(
                TranslatorInterface $translator,
                SessionInterface $session,
                RequestStack $requestStack,
                LoggerInterface $logger,
                CurrentUserApi«IF targets('1.5')»Interface«ENDIF» $currentUserApi,
                «IF targets('1.5')»
                    CategoryRegistryRepositoryInterface $categoryRegistryRepository,
                «ELSE»
                    CategoryRegistryApi $categoryRegistryApi,
                «ENDIF»
                CategoryPermissionApi«IF targets('1.5')»Interface«ENDIF» $categoryPermissionApi
            ) {
                $this->translator = $translator;
                $this->session = $session;
                $this->request = $requestStack->getCurrentRequest();
                $this->logger = $logger;
                $this->currentUserApi = $currentUserApi;
                «IF targets('1.5')»
                    $this->categoryRegistryRepository = $categoryRegistryRepository;
                «ELSE»
                    $this->categoryRegistryApi = $categoryRegistryApi;
                «ENDIF»
                $this->categoryPermissionApi = $categoryPermissionApi;
            }

            «categoryBaseImpl»
        }
    '''

    def private categoryBaseImpl(Application it) '''
        /**
         * Retrieves the main/default category of «appName».
         *
         * @param string $objectType The object type to retrieve
         * @param string $property   Name of category registry property to be used (optional)
         * @deprecated Use the methods getAllProperties, getAllPropertiesWithMainCat, getMainCatForProperty and getPrimaryProperty instead
         *
         * @return mixed Category array on success, false on failure
         */
        public function getMainCat($objectType = '', $property = '')
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
        	}
            if (empty($property)) {
                // default to the primary registry
                $property = $this->getPrimaryProperty($objectType);
            }

            $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')];
            $this->logger->warning('{app}: User {user} called CategoryHelper#getMainCat which is deprecated.', $logArgs);

            «IF targets('1.5')»
                $moduleRegistries = $this->categoryRegistryRepository->findBy([
                    'modname' => '«appName»',
                    'entityname' => ucfirst($objectType) . 'Entity',
                    'property' => $property
                ]);

                return count($moduleRegistries) > 0 ? $moduleRegistries[0]['category']->getId() : 32; // 32 == /__System/Modules/Global
            «ELSE»
                return $this->categoryRegistryApi->getModuleCategoryId('«appName»', ucfirst($objectType) . 'Entity', $property, 32); // 32 == /__System/Modules/Global
            «ENDIF»
        }

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

            $dataSource = $source == 'GET' ? $this->request->query : $this->request->request;
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

                $filtersPerRegistry[] = '(
                    tblCategories.categoryRegistryId = :propId' . $propertyName . '
                    AND tblCategories.category IN (:categories' . $propertyName . ')
                )';
                $filterParameters['registries'][$propertyName] = $propertyId;
                $filterParameters['values'][$propertyName] = $catIds[$propertyName];
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
        public function getAllProperties($objectType = '')
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
        	}

            «IF targets('1.5')»
                $moduleRegistries = $this->categoryRegistryRepository->findBy([
                    'modname' => '«appName»',
                    'entityname' => ucfirst($objectType) . 'Entity'
                ]);

                $result = [];
                foreach ($moduleRegistries as $registry) {
                    $result[$registry['property']] = $registry['id'];
                }

                return $result;
            «ELSE»
                return $this->categoryRegistryApi->getModuleRegistriesIds('«appName»', ucfirst($objectType) . 'Entity');
            «ENDIF»
        }

        /**
         * Returns a list of all registries with main category for a given object type.
         *
         * @param string $objectType The object type to retrieve
         * @param string $arrayKey   Key for the result array (optional)
         *
         * @return array list of the registries (registry id as key, main category id as value)
         */
        public function getAllPropertiesWithMainCat($objectType = '', $arrayKey = 'property')
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->__('Invalid object type received.'));
        	}

            «IF targets('1.5')»
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
            «ELSE»
                return $this->categoryRegistryApi->getModuleCategoryIds('«appName»', ucfirst($objectType) . 'Entity', $arrayKey);
            «ENDIF»
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

            «IF targets('1.5')»
                $registries = $this->getAllPropertiesWithMainCat($objectType, 'property');
                if ($registries && isset($registries[$property]) && $registries[$property]) {
                    return $registries[$property];
                }

                return null;
            «ELSE»
                return $this->categoryRegistryApi->getModuleCategoryId('«appName»', ucfirst($objectType) . 'Entity', $property);
            «ENDIF»
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
         * @param array $entities The given list of entities
         *
         * @return array The filtered list of entities
         */
        public function filterEntitiesByPermission($entities)
        {
            $filteredEntities = [];
            foreach ($entities as $entity) {
                if ($this->hasPermission($entity)) {
                    $filteredEntities[] = $entity;
                }
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
            «IF targets('1.5')»
            return $this->categoryPermissionApi->hasCategoryAccess($entity['categories'], ACCESS_OVERVIEW);
            «ELSE»
            $objectType = $entity->get_objectType();
            $categories = $entity['categories'];

            $registries = $this->getAllProperties($objectType);
            $registries = array_flip($registries);

            $categoryInfo = [];
            foreach ($categories as $category) {
                $registryId = $category->getCategoryRegistryId();
                if (!isset($registries[$registryId])) {
                    // seems this registry has been deleted
                    continue;
                }
                $registryName = $registries[$registryId];
                if (!isset($categoryInfo[$registryName])) {
                    $categoryInfo[$registryName] = [];
                }
                $categoryInfo[$registryName][] = $category->getCategory()->toArray();
            }

            return $this->categoryPermissionApi->hasCategoryAccess($categoryInfo, ACCESS_OVERVIEW);
            «ENDIF»
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
