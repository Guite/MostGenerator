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
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\CategoriesBundle\Api\ApiInterface\CategoryPermissionApiInterface;
        use Zikula\CategoriesBundle\Repository\CategoryRegistryRepositoryInterface;
        use Zikula\UsersBundle\Api\ApiInterface\CurrentUserApiInterface;
        use «appNamespace»\Entity\EntityInterface;

        /**
         * Category helper base class.
         */
        abstract class AbstractCategoryHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        public function __construct(
            protected readonly TranslatorInterface $translator,
            protected readonly RequestStack $requestStack,
            protected readonly LoggerInterface $logger,
            protected readonly CurrentUserApiInterface $currentUserApi,
            protected readonly CategoryRegistryRepositoryInterface $categoryRegistryRepository,
            protected readonly CategoryPermissionApiInterface $categoryPermissionApi
        ) {
        }

        /**
         * Defines whether multiple selection is enabled for a given object type
         * or not. Subclass can override this method to apply a custom behaviour
         * to certain category registries for example.
         */
        public function hasMultipleSelection(string $objectType = '', string $registry = ''): bool
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->trans('Invalid object type received.'));
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
         */
        public function retrieveCategoriesFromRequest(string $objectType = '', string $source = 'POST'): array
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->trans('Invalid object type received.'));
            }

            $request = $this->requestStack->getCurrentRequest();
            $dataSource = 'GET' === $source ? $request->query : $request->request;
            $catIdsPerRegistry = [];

            $properties = $this->getAllProperties($objectType);
            $inputValues = null;
            $inputName = '«appName.toLowerCase»_' . mb_strtolower($objectType) . 'quicknav';
            if (!$dataSource->has($inputName)) {
                $inputName = '«appName.toLowerCase»_' . mb_strtolower($objectType) . 'finder';
            }
            if ($dataSource->has($inputName)) {
                $inputValues = $dataSource->get($inputName);
            }
            if (null === $inputValues) {
                return $catIdsPerRegistry;
            }

            $inputCategories = $inputValues['categories'] ?? [];
            if (!count($inputCategories)) {
                return $catIdsPerRegistry;
            }

            foreach ($properties as $propertyName => $propertyId) {
                $registryKey = 'registry_' . $propertyId;
                $inputValue = $inputCategories[$registryKey] ?? [];
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
         * Adds a list of filters for a certain list of categories to a given query builder.
         */
        public function applyFilters(
            QueryBuilder $queryBuilder,
            string $objectType = '',
            array $catIds = []
        ): void {
            $qb = $queryBuilder;

            $properties = $this->getAllProperties($objectType);

            $filtersPerRegistry = [];
            $filterParameters = [
                'values' => [],
                'registries' => [],
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
        }

        /**
         * Returns a list of all registries / properties for a given object type.
         */
        public function getAllProperties(string $objectType = ''): array
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->trans('Invalid object type received.'));
            }

            $moduleRegistries = $this->categoryRegistryRepository->findBy([
                'modname' => '«appName»',
                'entityname' => ucfirst($objectType) . 'Entity',
            ]);

            $result = [];
            foreach ($moduleRegistries as $registry) {
                $result[$registry['property']] = $registry['id'];
            }

            return $result;
        }

        /**
         * Returns a list of all registries with main category for a given object type.
         */
        public function getAllPropertiesWithMainCat(string $objectType = '', string $arrayKey = 'property'): array
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->trans('Invalid object type received.'));
            }

            $moduleRegistries = $this->categoryRegistryRepository->findBy([
                'modname' => '«appName»',
                'entityname' => ucfirst($objectType) . 'Entity',
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
         */
        public function getMainCatForProperty(string $objectType = '', string $property = ''): ?int
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException($this->translator->trans('Invalid object type received.'));
            }

            $registries = $this->getAllPropertiesWithMainCat($objectType);
            if ($registries && isset($registries[$property]) && $registries[$property]) {
                return $registries[$property];
            }

            return null;
        }

        /**
         * Returns the name of the primary registry.
         */
        public function getPrimaryProperty(string $objectType = ''): string
        {
            return 'Main';
        }

        /**
         * Checks whether permissions are granted to the given categories or not.
         */
        public function hasPermission(EntityInterface $entity): bool
        {
            $requireAccessForAll = $this->requireAccessForAll($entity);

            return $this->categoryPermissionApi->hasCategoryAccess(
                $entity->getCategories()->toArray(),
                ACCESS_OVERVIEW,
                $requireAccessForAll
            );
        }

        /**
         * Returns whether permissions are required for all categories
         * of a specific entity or for only one category.
         *
         * Returning false allows access if the user has access
         * to at least one selected category.
         * Returning true only allows access if the user has access
         * to all selected categories.
         */
        protected function requireAccessForAll(EntityInterface $entity): bool
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
