package org.zikula.modulestudio.generator.cartridges.zclassic.controller.apis

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Category {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating category api')
        if (isLegacy) {
            generateClassPair(fsa, getAppSourceLibPath + 'Api/Category.php',
                fh.phpFileContent(it, categoryApiBaseClass), fh.phpFileContent(it, categoryApiImpl)
            )
        } else {
            generateClassPair(fsa, getAppSourceLibPath + 'Helper/CategoryHelper.php',
                fh.phpFileContent(it, categoryHelperBaseClass), fh.phpFileContent(it, categoryHelperImpl)
            )
        }
    }

    def private categoryApiBaseClass(Application it) '''
        use Doctrine\ORM\QueryBuilder;

        /**
         * Category api base class.
         */
        abstract class «appName»_Api_Base_AbstractCategory extends Zikula_AbstractApi
        {
            «categoryBaseImpl»
        }
    '''

    def private categoryHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «IF !targets('1.4-dev')»
            use CategoryRegistryUtil;
        «ENDIF»
        use Doctrine\ORM\QueryBuilder;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\DependencyInjection\ContainerBuilder;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        «IF targets('1.4-dev')»
            use Zikula\CategoriesModule\Api\CategoryRegistryApi;
        «ENDIF»
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
            «IF targets('1.4-dev')»

                /**
                 * @var CategoryRegistryApi
                 */
                private $categoryRegistryApi;
            «ENDIF»

            /**
             * Constructor.
             * Initialises member vars.
             *
             * @param ContainerBuilder    $container      ContainerBuilder service instance
             * @param TranslatorInterface $translator     Translator service instance
             * @param SessionInterface    $session        Session service instance
             * @param LoggerInterface     $logger         Logger service instance
             * @param RequestStack        $requestStack   RequestStack service instance
             * @param CurrentUserApi      $currentUserApi CurrentUserApi service instance
             «IF targets('1.4-dev')»
                 «' '»* @param CategoryRegistryApi $categoryRegistryApi CategoryRegistryApi service instance
             «ENDIF»
             */
            public function __construct(
                ContainerBuilder $container,
                TranslatorInterface $translator,
                SessionInterface $session,
                LoggerInterface $logger,
                RequestStack $requestStack,
                CurrentUserApi $currentUserApi«IF targets('1.4-dev')»,
                CategoryRegistryApi $categoryRegistryApi«ENDIF»)
            {
                $this->container = $container;
                $this->translator = $translator;
                $this->session = $session;
                $this->logger = $logger;
                $this->requestStack = $requestStack;
                $this->currentUserApi = $currentUserApi;
                «IF targets('1.4-dev')»
                    $this->categoryRegistryApi = $categoryRegistryApi;
                «ENDIF»
            }

            «categoryBaseImpl»
        }
    '''

    def private categoryBaseImpl(Application it) '''
        /**
         * Retrieves the main/default category of «appName».
         *
         «IF isLegacy»
         * @param string $args['ot']       The object type to retrieve (optional)
         * @param string $args['registry'] Name of category registry to be used (optional)
         «ELSE»
         * @param string $objectType The object type to retrieve (optional)
         * @param string $registry   Name of category registry to be used (optional)
         «ENDIF»
         * @deprecated Use the methods getAllProperties, getAllPropertiesWithMainCat, getMainCatForProperty and getPrimaryProperty instead
         *
         * @return mixed Category array on success, false on failure
         */
        public function getMainCat(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $registry = ''«ENDIF»)
        {
            «IF isLegacy»
                if (!isset($args['registry']) || empty($args['registry'])) {
                    // default to the primary registry
                    $args['registry'] = $this->getPrimaryProperty($args);
                }
            «ELSE»
                if (empty($registry)) {
                    // default to the primary registry
                    $registry = $this->getPrimaryProperty($objectType);
                }
            «ENDIF»

            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getMainCat');
            «IF !isLegacy»

                $logArgs = ['app' => '«appName»', 'user' => $this->currentUserApi->get('uname')];
                $this->logger->warning('{app}: User {user} called CategoryHelper#getMainCat which is deprecated.', $logArgs);
            «ENDIF»

            «IF targets('1.4-dev')»
                return $this->categoryRegistryApi->getModuleCategoryId('«appName»', ucfirst($objectType), $registry, 32); // 32 == /__System/Modules/Global
            «ELSE»
                return CategoryRegistryUtil::getRegisteredModuleCategory(«IF isLegacy»$this->name«ELSE»'«appName»'«ENDIF», ucfirst($objectType), «IF isLegacy»$args['registry']«ELSE»$registry«ENDIF», 32); // 32 == /__System/Modules/Global
            «ENDIF»
        }

        /**
         * Defines whether multiple selection is enabled for a given object type
         * or not. Subclass can override this method to apply a custom behaviour
         * to certain category registries for example.
         *
         «IF isLegacy»
         * @param string $args['ot']       The object type to retrieve (optional)
         * @param string $args['registry'] Name of category registry to be used (optional)
         «ELSE»
         * @param string $objectType The object type to retrieve (optional)
         * @param string $registry   Name of category registry to be used (optional)
         «ENDIF»
         *
         * @return boolean true if multiple selection is allowed, else false
         */
        public function hasMultipleSelection(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $registry = ''«ENDIF»)
        {
            «IF isLegacy»
                if (!isset($args['registry']) || empty($args['registry'])) {
                    // default to the primary registry
                    $args['registry'] = $this->getPrimaryProperty($args);
                }
            «ELSE»
                if (empty($args['registry'])) {
                    // default to the primary registry
                    $registry = $this->getPrimaryProperty($objectType);
                }
            «ENDIF»

            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'hasMultipleSelection');

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
         «IF isLegacy»
         * @param string $args['ot']       The object type to retrieve (optional)
         * @param string $args['source'] Where to retrieve the data from (defaults to POST)
         «ELSE»
         * @param string $objectType The object type to retrieve (optional)
         * @param string $source     Where to retrieve the data from (defaults to POST)
         «ENDIF»
         *
         * @return array The fetched data indexed by the registry id
         */
        public function retrieveCategoriesFromRequest(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $source = 'POST'«ENDIF»)
        {
            «IF isLegacy»
                $dataSource = $this->request->request;
                if (isset($args['source']) && $args['source'] == 'GET') {
                    $dataSource = $this->request->query;
                }
            «ELSE»
                $request = $this->requestStack->getCurrentRequest();
                $dataSource = $source == 'GET' ? $request->query : $request->request;
            «ENDIF»

            $catIdsPerRegistry = «IF isLegacy»array()«ELSE»[]«ENDIF»;

            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'retrieveCategoriesFromRequest');
            $properties = $this->getAllProperties(«IF isLegacy»$args«ELSE»$objectType«ENDIF»);
            foreach ($properties as $propertyName => $propertyId) {
                $hasMultiSelection = $this->hasMultipleSelection(«IF isLegacy»array(«ELSE»[«ENDIF»
                    'ot' => $objectType,
                    'registry' => $propertyName
                «IF isLegacy»)«ELSE»]«ENDIF»);
                if (true === $hasMultiSelection) {
                    $argName = 'catids' . $propertyName;
                    $inputValue = $dataSource->get($argName, «IF isLegacy»array()«ELSE»[]«ENDIF»);
                    if (!is_array($inputValue)) {
                        $inputValue = explode(',', $inputValue);
                    }
                } else {
                    $argName = 'catid' . $propertyName;
                    «IF isLegacy»
                        $inputVal = (int) $dataSource->filter($argName, 0, FILTER_VALIDATE_INT);
                    «ELSE»
                        $inputVal = $dataSource->getInt($argName, 0);
                    «ENDIF»
                    $inputValue = «IF isLegacy»array()«ELSE»[]«ENDIF»;
                    if ($inputVal > 0) {
                        $inputValue[] = $inputVal;
                    }
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
         «IF isLegacy»
         * @param QueryBuilder $args['qb']     Query builder instance to be enhanced
         * @param string       $args['ot']     The object type to be treated (optional)
         * @param array        $args['catids'] Category ids grouped by property name
         «ELSE»
         * @param QueryBuilder $queryBuilder Query builder instance to be enhanced
         * @param string       $objectType   The object type to be treated (optional)
         * @param array        $catIds       Category ids grouped by property name
         «ENDIF»
         *
         * @return QueryBuilder The enriched query builder instance
         */
        public function buildFilterClauses(«IF isLegacy»array $args = array()«ELSE»QueryBuilder $queryBuilder, $objectType = '', $catIds = []«ENDIF»)
        {
            $qb = «IF isLegacy»$args['qb']«ELSE»$queryBuilder«ENDIF»;

            $properties = $this->getAllProperties(«IF isLegacy»$args«ELSE»$objectType«ENDIF»);
            «IF isLegacy»
                $catIds = $args['catids'];
            «ENDIF»

            $filtersPerRegistry = «IF isLegacy»array()«ELSE»[]«ENDIF»;
            «IF isLegacy»
                $filterParameters = array(
                    'values' => array(),
                    'registries' => array()
                );
            «ELSE»
                $filterParameters = [
                    'values' => [],
                    'registries' => []
                ];
            «ENDIF»

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
         «IF isLegacy»
         * @param string $args['ot'] The object type to retrieve (optional)
         «ELSE»
         * @param string $objectType The object type to retrieve (optional)
         «ENDIF»
         *
         * @return array list of the registries (property name as key, id as value)
         */
        public function getAllProperties(«IF isLegacy»array $args = array()«ELSE»$objectType = ''«ENDIF»)
        {
            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getAllProperties');

            «IF targets('1.4-dev')»
                $propertyIdsPerName = $this->categoryRegistryApi->getModuleRegistriesIds('«appName»', ucfirst($objectType));
            «ELSE»
                $propertyIdsPerName = CategoryRegistryUtil::getRegisteredModuleCategoriesIds(«IF isLegacy»$this->name«ELSE»'«appName»'«ENDIF», ucfirst($objectType));
            «ENDIF»

            return $propertyIdsPerName;
        }

        /**
         * Returns a list of all registries with main category for a given object type.
         *
         «IF isLegacy»
         * @param string $args['ot']       The object type to retrieve (optional)
         * @param string $args['arraykey'] Key for the result array (optional)
         «ELSE»
         * @param string $objectType The object type to retrieve (optional)
         * @param string $arrayKey   Key for the result array (optional)
         «ENDIF»
         *
         * @return array list of the registries (registry id as key, main category id as value)
         */
        public function getAllPropertiesWithMainCat(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $arrayKey = ''«ENDIF»)
        {
            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getAllPropertiesWithMainCat');

            «IF isLegacy»
                if (!isset($args['arraykey'])) {
                    $args['arraykey'] = '';
                }

            «ENDIF»
            «IF targets('1.4-dev')»
                $registryInfo = $this->categoryRegistryApi->getModuleCategoryIds('«appName»', ucfirst($objectType), $arrayKey);
            «ELSE»
                $registryInfo = CategoryRegistryUtil::getRegisteredModuleCategories(«IF isLegacy»$this->name«ELSE»'«appName»'«ENDIF», ucfirst($objectType), «IF isLegacy»$args['arraykey']«ELSE»$arrayKey«ENDIF»);
            «ENDIF»

            return $registryInfo;
        }

        /**
         * Returns the main category id for a given object type and a certain property name.
         *
         «IF isLegacy»
         * @param string $args['ot']       The object type to retrieve (optional)
         * @param string $args['property'] The property name (optional)
         «ELSE»
         * @param string $objectType The object type to retrieve (optional)
         * @param string $property   The property name (optional)
         «ENDIF»
         *
         * @return integer The main category id of desired tree
         */
        public function getMainCatForProperty(«IF isLegacy»array $args = array()«ELSE»$objectType = '', $property = ''«ENDIF»)
        {
            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getMainCatForProperty');

            «IF targets('1.4-dev')»
                $catId = $this->categoryRegistryApi->getModuleCategoryId('«appName»', ucfirst($objectType), $property);
            «ELSE»
                $catId = CategoryRegistryUtil::getRegisteredModuleCategory(«IF isLegacy»$this->name«ELSE»'«appName»'«ENDIF», ucfirst($objectType), «IF isLegacy»$args['property']«ELSE»$property«ENDIF»);
            «ENDIF»

            return $catId;
        }

        /**
         * Returns the name of the primary registry.
         *
         «IF isLegacy»
         * @param string $args['ot'] The object type to retrieve (optional)
         «ELSE»
         * @param string $objectType The object type to retrieve (optional)
         «ENDIF»
         *
         * @return string name of the main registry
         */
        public function getPrimaryProperty(«IF isLegacy»array $args = array()«ELSE»$objectType = ''«ENDIF»)
        {
            $objectType = $this->determineObjectType(«IF isLegacy»$args«ELSE»$objectType«ENDIF», 'getPrimaryProperty');

            $registry = 'Main';

            return $registry;
        }

        /**
         * Determine object type using controller util methods.
         *
         «IF isLegacy»
         * @param string $args['ot'] The object type to retrieve (optional)
         * @param string $methodName Name of calling method
         «ELSE»
         * @param string $objectType The object type to retrieve (optional)
         * @param string $methodName Name of calling method
         «ENDIF»
         *
         * @return string name of the determined object type
         */
        protected function determineObjectType(«IF isLegacy»array $args = array()«ELSE»$objectType = ''«ENDIF», $methodName = '')
        {
            «IF isLegacy»
                $objectType = isset($args['ot']) ? $args['ot'] : '';
                $controllerHelper = new «appName»_Util_Controller($this->serviceManager);
            «ELSE»«/* we can not use the container here, because it is not available yet during installation */»
                $controllerHelper = new \«appNamespace»\Helper\ControllerHelper($this->container, $this->translator, $this->session, $this->logger);
            «ENDIF»
            $utilArgs = «IF isLegacy»array(«ELSE»[«ENDIF»'api' => 'category', 'action' => $methodName«IF isLegacy»)«ELSE»]«ENDIF»;
            if (!in_array($objectType, $controllerHelper->getObjectTypes('api', $utilArgs))) {
                $objectType = $controllerHelper->getDefaultObjectType('api', $utilArgs);
            }

            return $objectType;
        }
    '''

    def private categoryApiImpl(Application it) '''
        /**
         * Category api implementation class.
         */
        class «appName»_Api_Category extends «appName»_Api_Base_AbstractCategory
        {
            // feel free to extend the category api here
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

    def private isLegacy(Application it) {
        targets('1.3.x')
    }
}
