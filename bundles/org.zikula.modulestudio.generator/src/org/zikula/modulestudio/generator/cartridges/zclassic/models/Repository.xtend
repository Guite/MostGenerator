package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.CalculatedField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityField
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Joins
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.LinkTable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Tree
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.UserDeletion
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class Repository {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    IFileSystemAccess fsa
    FileHelper fh = new FileHelper
    Application app

    /**
     * Entry point for Doctrine repository classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        app = it
        getAllEntities.forEach(e|e.generate)

        val linkTable = new LinkTable
        for (relation : getJoinRelations.filter(ManyToManyRelationship)) linkTable.generate(relation, it, fsa)
    }

    /**
     * Creates a repository class file for every Entity instance.
     */
    def private generate(Entity it) {
        println('Generating repository classes for entity "' + name.formatForDisplay + '"')
        val repositoryPath = app.getAppSourceLibPath + 'Entity/Repository/'
        var fileSuffix = 'Repository'

        var fileName = 'Base/Abstract' + name.formatForCodeCapital + fileSuffix + '.php'
        if (!isInheriting && !app.shouldBeSkipped(repositoryPath + fileName)) {
            if (app.shouldBeMarked(repositoryPath + fileName)) {
                fileName = 'Base/' + name.formatForCodeCapital + fileSuffix + '.generated.php'
            }
            fsa.generateFile(repositoryPath + fileName, fh.phpFileContent(app, modelRepositoryBaseImpl))
        }

        fileName = name.formatForCodeCapital + fileSuffix + '.php'
        if (!app.generateOnlyBaseClasses && !app.shouldBeSkipped(repositoryPath + fileName)) {
            if (app.shouldBeMarked(repositoryPath + fileName)) {
                fileName = name.formatForCodeCapital + fileSuffix + '.generated.php'
            }
            fsa.generateFile(repositoryPath + fileName, fh.phpFileContent(app, modelRepositoryImpl))
        }
    }

    def private getDefaultSortingField(Entity it) {
        if (hasSortableFields) {
            getSortableFields.head
        } else if (!getSortingFields.empty) {
            if (getSortingFields.size > 1 && getSortingFields.head.name.formatForCode == 'workflowState') {
                getSortingFields.get(1)
            } else {
                getSortingFields.head
            }
        } else {
            val stringFields = fields.filter(StringField).filter[!password]
            if (!stringFields.empty) {
                stringFields.head
            } else {
                getDerivedFields.head
            }
        }
    }

    def private modelRepositoryBaseImpl(Entity it) '''
        «imports»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «name.formatForDisplay» entities.
         */
        abstract class Abstract«name.formatForCodeCapital»Repository extends «IF tree != EntityTreeType.NONE»«tree.literal.toLowerCase.toFirstUpper»TreeRepository«ELSEIF hasSortableFields»SortableRepository«ELSE»EntityRepository«ENDIF»
        {
            «/*IF tree != EntityTreeType.NONE»
                use «tree.literal.toLowerCase.toFirstUpper»TreeRepositoryTrait;

            «ENDIF*/»
            /**
             * @var string The default sorting field/expression
             */
            protected $defaultSortingField = '«getDefaultSortingField.name.formatForCode»';

            /**
             * @var Request The request object given by the calling controller
             */
            protected $request;
            «/*IF tree != EntityTreeType.NONE»

                /**
                 * «name.formatForCodeCapital»Repository constructor.
                 *
                 * @param EntityManager $entityManager The entity manager
                 * @param ClassMetadata $class         The class meta data
                 * /
                public function __construct(EntityManager $entityManager, ClassMetadata $class)
                {
                    parent::__construct($entityManager, $class);

                    $this->initializeTreeRepository($entityManager, $class);
                }
                «IF tree == EntityTreeType.NESTED»

                    /**
                     * Call interceptor.
                     *
                     * @param string $method Name of called method
                     * @param array  $args   Additional arguments
                     *
                     * @return mixed $result
                     * /
                    public function __call($method, $args)
                    {
                        $result = $this->callTreeUtilMethods($method, $args);

                        if (null !== $result) {
                            return $result;
                        }

                        return parent::__call($method, $args);
                    }
                «ENDIF»
            «ENDIF*/»

            /**
             * Retrieves an array with all fields which can be used for sorting instances.
             *
             * @return array Sorting fields array
             */
            public function getAllowedSortingFields()
            {
                return [
                    «FOR field : getSortingFields»«field.singleSortingField»«ENDFOR»
                    «extensionSortingFields»
                ];
            }

            «fh.getterAndSetterMethods(it, 'defaultSortingField', 'string', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'request', 'Request', false, true, false, '', '')»

            «getViewQuickNavParameters»

            «truncateTable»
            «new UserDeletion().generate(it)»

            «selectById»
            «IF hasSluggableFields && slugUnique»

                «selectBySlug»
            «ENDIF»

            «addExclusion»

            «IF ownerPermission»
                «addCreatorFilter»

            «ENDIF»
            «selectWhere»

            «selectWherePaginated»

            «selectSearch»

            «retrieveCollectionResult»

            «selectCount»

            «new Tree().generate(it, app)»

            «detectUniqueState»

            «genericBaseQuery»

            «genericBaseQueryWhere»

            «genericBaseQueryOrderBy»

            «getQueryFromBuilder»

            «new Joins().generate(it, app)»
        }
    '''

    def private imports(Entity it) '''
        namespace «app.appNamespace»\Entity\Repository\Base;

        use Doctrine\Common\Collections\ArrayCollection;
        «IF tree != EntityTreeType.NONE»
            use Gedmo\Tree\Entity\Repository\«tree.literal.toLowerCase.toFirstUpper»TreeRepository;
            «/* use Gedmo\Tree\Traits\Repository\«tree.literal.toLowerCase.toFirstUpper»TreeRepositoryTrait; */ »
            use Doctrine\ORM\EntityManager;
        «ELSEIF hasSortableFields»
            use Gedmo\Sortable\Entity\Repository\SortableRepository;
        «ELSE»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»
        «/*IF tree != EntityTreeType.NONE»
            use Doctrine\ORM\Mapping\ClassMetadata;
        «ENDIF*/»
        use Doctrine\ORM\Query;
        use Doctrine\ORM\QueryBuilder;
        «IF hasOptimisticLock || hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
        «ENDIF»
        use Doctrine\ORM\Tools\Pagination\Paginator;
        use InvalidArgumentException;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\Request;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\UsersModule\Api\«IF app.targets('1.5')»ApiInterface\CurrentUserApiInterface«ELSE»CurrentUserApi«ENDIF»;
        «IF ownerPermission && app.targets('1.5')»
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        use «app.appNamespace»\Entity\«name.formatForCodeCapital»Entity;
        «IF hasTranslatableFields»
            use «app.appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        «IF app.hasUploads»
            use «app.appNamespace»\Helper\ImageHelper;
        «ENDIF»

    '''

    def private getViewQuickNavParameters(Entity it) '''
        /**
         * Returns an array of additional template variables for view quick navigation forms.
         *
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args    Additional arguments
         *
         * @return array List of template variables to be assigned
         */
        public function getViewQuickNavParameters($context = '', $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'actionHandler', 'block', 'contentType'])) {
                $context = 'controllerAction';
            }

            $parameters = [];
            «IF categorisable»
                $categoryHelper = \ServiceUtil::get('«app.appService».category_helper');
                $parameters['catId'] = $this->getRequest()->query->get('catId', '');
                $parameters['catIdList'] = $categoryHelper->retrieveCategoriesFromRequest('«name.formatForCode»', 'GET');
            «ENDIF»
            «IF !getBidirectionalIncomingJoinRelationsWithOneSource.empty»
                «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                    «val sourceAliasName = relation.getRelationAliasName(false)»
                    $parameters['«sourceAliasName»'] = $this->getRequest()->query->get('«sourceAliasName»', 0);
                «ENDFOR»
            «ENDIF»
            «IF hasListFieldsEntity»
                «FOR field : getListFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR field : getUserFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = (int) $this->getRequest()->query->get('«fieldName»', 0);
                «ENDFOR»
            «ENDIF»
            «IF hasCountryFieldsEntity»
                «FOR field : getCountryFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «FOR field : getLanguageFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasLocaleFieldsEntity»
                «FOR field : getLocaleFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                $parameters['q'] = $this->getRequest()->query->get('q', '');
            «ENDIF»
            «/* not needed as already handled in the controller
            $parameters['pageSize'] = (int) $this->getRequest()->query->get('pageSize', $pageSize);*/»
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»

            return $parameters;
        }
    '''

    def private truncateTable(Entity it) '''
        /**
         * Helper method for truncating the table.
         * Used during installation when inserting default data.
         *
         * @param LoggerInterface $logger Logger service instance
         */
        public function truncateTable(LoggerInterface $logger)
        {
            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«entityClassName('', false)»', 'tbl');
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»

                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»

            $query->execute();

            $logArgs = ['app' => '«application.appName»', 'entity' => '«name.formatForDisplay»'];
            $logger->debug('{app}: Truncated the {entity} entity table.', $logArgs);
        }
    '''

    def private selectById(Entity it) '''
        /**
         * Adds an array of id filters to given query instance.
         *
         * @param mixed        $idList The array of ids to use to retrieve the object
         * @param QueryBuilder $qb     Query builder to be enhanced
         *
         * @return QueryBuilder Enriched query builder instance
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        protected function addIdListFilter($idList, QueryBuilder $qb)
        {
            $orX = $qb->expr()->orX();

            foreach ($idList as $id) {
                // check id parameter
                if ($id == 0) {
                    throw new InvalidArgumentException('Invalid identifier received.');
                }

                if (is_array($id)) {
                    $andX = $qb->expr()->andX();
                    foreach ($id as $fieldName => $fieldValue) {
                        $andX->add($qb->expr()->eq('tbl.' . $fieldName, $fieldValue));
                    }
                    $orX->add($andX);
                } else {
                    $orX->add($qb->expr()->eq('tbl.«getFirstPrimaryKey.name.formatForCode»', $id));
                }
            }

            $qb->andWhere($orX);

            return $qb;
        }

        /**
         * Selects an object from the database.
         *
         * @param mixed   $id       The id (or array of ids) to use to retrieve the object (optional) (default=0)
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return array|«name.formatForCode»Entity Retrieved data array or «name.formatForCode»Entity instance
         */
        public function selectById($id = 0, $useJoins = true, $slimMode = false)
        {
            $results = $this->selectByIdList(is_array($id) ? $id : [$id], $useJoins, $slimMode);

            return count($results) > 0 ? $results[0] : null;
        }
        
        /**
         * Selects a list of objects with an array of ids
         *
         * @param mixed   $idList   The array of ids to use to retrieve the objects (optional) (default=0)
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return ArrayCollection Collection containing retrieved «name.formatForCode»Entity instances
         */
        public function selectByIdList($idList = [0], $useJoins = true, $slimMode = false)
        {
            $qb = $this->genericBaseQuery('', '', $useJoins, $slimMode);
            $qb = $this->addIdListFilter($idList, $qb);

            $query = $this->getQueryFromBuilder($qb);
        
            $results = $query->getResult();

            return count($results) > 0 ? $results : null;
        }
    '''

    def private selectBySlug(Entity it) '''
        /**
         * Selects an object by slug field.
         *
         * @param string  $slugTitle The slug value
         * @param boolean $useJoins  Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)
         * @param integer $excludeId Optional id to be excluded (used for unique validation)
         *
         * @return «entityClassName('', false)» Retrieved instance of «entityClassName('', false)»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function selectBySlug($slugTitle = '', $useJoins = true, $slimMode = false, $excludeId = 0)
        {
            // check input parameter
            if ($slugTitle == '') {
                throw new InvalidArgumentException('Invalid slug title received.');
            }

            $qb = $this->genericBaseQuery('', '', $useJoins, $slimMode);

            $qb->andWhere('tbl.slug = :slug')
               ->setParameter('slug', $slugTitle);

            $qb = $this->addExclusion($qb, $excludeId);

            $query = $this->getQueryFromBuilder($qb);

            $results = $query->getResult();

            return count($results) > 0 ? $results[0] : null;
        }
    '''

    def private addExclusion(Entity it) '''
        /**
         * Adds where clauses excluding desired identifiers from selection.
         *
         * @param QueryBuilder $qb           Query builder to be enhanced
         * @param array        $excludesions Array of ids to be excluded from selection
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function addExclusion(QueryBuilder $qb, array $exclusions = [])
        {
            «IF hasCompositeKeys»
                foreach ($exclusions as $fieldName => $fieldValue) {
                    $exclusion = is_array($fieldValue) ? $fieldValue : [$fieldValue];
                    if (count($exclusion) > 0) {
                        $qb->andWhere('tbl.' . $fieldName . ' NOT IN (:' . $fieldName . ')')
                           ->setParameter($fieldName, $exclusion);
                   }
                }
            «ELSE»
                if (count($exclusions) > 0) {
                    $qb->andWhere('tbl.«getFirstPrimaryKey.name.formatForCode» NOT IN (:excludedIdentifiers)')
                       ->setParameter('excludedIdentifiers', $exclusions);
                }
            «ENDIF»

            return $qb;
        }
    '''

    def private addCreatorFilter(Entity it) '''
        /**
         * Adds a filter for the createdBy field.
         *
         * @param QueryBuilder $qb Query builder to be enhanced
         * @param integer      $userId The user identifier used for filtering (optional)
         *
         * @return QueryBuilder Enriched query builder instance
         */
        public function addCreatorFilter(QueryBuilder $qb, $userId = null)
        {
            if (null === $userId) {
                $currentUserApi = \ServiceUtil::get('zikula_users_module.current_user');
                $userId = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uid') : «IF app.targets('1.5')»UsersConstant::USER_ID_ANONYMOUS«ELSE»1«ENDIF»;
            }

            if (is_array($userId)) {
                $qb->andWhere('tbl.createdBy IN (:userIds)')
                   ->setParameter('userIds', $userId);
            } else {
                $qb->andWhere('tbl.createdBy = :userId')
                   ->setParameter('userId', $userId);
            }

            return $qb;
        }
    '''

    def private selectWhere(Entity it) '''
        /**
         * Returns query builder for selecting a list of objects with a given where clause.
         *
         * @param string  $where    The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default='')
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return QueryBuilder Query builder for the given arguments
         */
        public function getListQueryBuilder($where = '', $orderBy = '', $useJoins = true, $slimMode = false)
        {
            $qb = $this->genericBaseQuery($where, $orderBy, $useJoins, $slimMode);
            if (!$useJoins || !$slimMode) {
                $qb = $this->addCommonViewFilters($qb);
            }

            return $qb;
        }

        /**
         * Selects a list of objects with a given where clause.
         *
         * @param string  $where    The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default='')
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return ArrayCollection Collection containing retrieved «name.formatForCode»Entity instances
         */
        public function selectWhere($where = '', $orderBy = '', $useJoins = true, $slimMode = false)
        {
            $qb = $this->getListQueryBuilder($where, $orderBy, $useJoins, $slimMode);

            $query = $this->getQueryFromBuilder($qb);

            return $this->retrieveCollectionResult($query, $orderBy, false);
        }
    '''

    def private selectWherePaginated(Entity it) '''
        /**
         * Returns query builder instance for retrieving a list of objects with a given where clause and pagination parameters.
         *
         * @param QueryBuilder $qb             Query builder to be enhanced
         * @param integer      $currentPage    Where to start selection
         * @param integer      $resultsPerPage Amount of items to select
         *
         * @return Query Created query instance
         */
        public function getSelectWherePaginatedQuery(QueryBuilder $qb, $currentPage = 1, $resultsPerPage = 25)
        {
            $query = $this->getQueryFromBuilder($qb);
            $offset = ($currentPage-1) * $resultsPerPage;

            $query->setFirstResult($offset)
                  ->setMaxResults($resultsPerPage);

            return $query;
        }

        /**
         * Selects a list of objects with a given where clause and pagination parameters.
         *
         * @param string  $where          The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='')
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode       If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return array Retrieved collection and amount of total records affected by this query
         */
        public function selectWherePaginated($where = '', $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true, $slimMode = false)
        {
            $qb = $this->getListQueryBuilder($where, $orderBy, $useJoins, $slimMode);
            $query = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);

            return $this->retrieveCollectionResult($query, $orderBy, true);
        }

        /**
         * Adds quick navigation related filter options as where clauses.
         *
         * @param QueryBuilder $qb Query builder to be enhanced
         *
         * @return QueryBuilder Enriched query builder instance
         */
        public function addCommonViewFilters(QueryBuilder $qb)
        {
            if (null === $this->getRequest()) {
                // if no request is set we return (#433)
                return $qb;
            }

            $routeName = $this->getRequest()->get('_route');
            if (false !== strpos($routeName, 'edit')) {«/* fix for #547 */»
                return $qb;
            }

            $parameters = $this->getViewQuickNavParameters('', []);
            foreach ($parameters as $k => $v) {
                «IF categorisable»
                    if ($k == 'catId') {
                        // single category filter
                        if ($v > 0) {
                            $qb->andWhere('tblCategories.category = :category')
                               ->setParameter('category', $v);
                        }
                    } elseif ($k == 'catIdList') {
                        // multi category filter
                        /* old
                        $qb->andWhere('tblCategories.category IN (:categories)')
                           ->setParameter('categories', $v);
                         */
                        $categoryHelper = \ServiceUtil::get('«app.appService».category_helper');
                        $qb = $categoryHelper->buildFilterClauses($qb, '«name.formatForCode»', $v);
                «ENDIF»
                «IF categorisable»} else«ENDIF»if (in_array($k, ['q', 'searchterm'])) {
                    // quick search
                    if (!empty($v)) {
                        $qb = $this->addSearchFilter($qb, $v);
                    }
                «IF hasBooleanFieldsEntity»
                } elseif (in_array($k, [«FOR field : getBooleanFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»])) {
                    // boolean filter
                    if ($v == 'no') {
                        $qb->andWhere('tbl.' . $k . ' = 0');
                    } elseif ($v == 'yes' || $v == '1') {
                        $qb->andWhere('tbl.' . $k . ' = 1');
                    }
                «ENDIF»
                } else if (!is_array($v)) {
                    // field filter
                    if ((!is_numeric($v) && $v != '') || (is_numeric($v) && $v > 0)) {
                        if ($k == 'workflowState' && substr($v, 0, 1) == '!') {
                            $qb->andWhere('tbl.' . $k . ' != :' . $k)
                               ->setParameter($k, substr($v, 1, strlen($v)-1));
                        } elseif (substr($v, 0, 1) == '%') {
                            $qb->andWhere('tbl.' . $k . ' LIKE :' . $k)
                               ->setParameter($k, '%' . $v . '%');
                        } else {
                            «IF hasUserFieldsEntity»
                                if (in_array($k, ['«getUserFieldsEntity.map[name.formatForCode].join('\', \'')»'])) {
                                    $qb->leftJoin('tbl.' . $k, 'tbl' . ucfirst($k))
                                       ->andWhere('tbl' . ucfirst($k) . '.uid = :' . $k)
                                       ->setParameter($k, $v);
                                } else {
                                    $qb->andWhere('tbl.' . $k . ' = :' . $k)
                                       ->setParameter($k, $v);
                                }
                            «ELSE»
                                $qb->andWhere('tbl.' . $k . ' = :' . $k)
                                   ->setParameter($k, $v);
                            «ENDIF»
                       }
                    }
                }
            }

            $qb = $this->applyDefaultFilters($qb, $parameters);

            return $qb;
        }

        /**
         * Adds default filters as where clauses.
         *
         * @param QueryBuilder $qb         Query builder to be enhanced
         * @param array        $parameters List of determined filter options
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function applyDefaultFilters(QueryBuilder $qb, $parameters = [])
        {
            «IF hasVisibleWorkflow»
                if (null === $this->getRequest()) {
                    $this->request = \ServiceUtil::get('request_stack')->getCurrentRequest();
                }
                $routeName = $this->request->get('_route');
                $isAdminArea = false !== strpos($routeName, '«app.appName.toLowerCase»_«name.formatForDisplay.toLowerCase»_admin');
                if ($isAdminArea) {
                    return $qb;
                }

                if (!in_array('workflowState', array_keys($parameters)) || empty($parameters['workflowState'])) {
                    // per default we show approved «nameMultiple.formatForDisplay» only
                    $onlineStates = ['approved'];
                    «IF ownerPermission»
                        «/*$variableApi = \ServiceUtil::get('zikula_extensions_module.api.variable');
                        $showOnlyOwnEntries = $this->getRequest()->query->getInt('own', $variableApi->get('«app.appName»', 'showOnlyOwnEntries', 0));*/»
                        $showOnlyOwnEntries = $this->getRequest()->query->getInt('own', 0);
                        if ($showOnlyOwnEntries == 1) {
                            // allow the owner to see his deferred «nameMultiple.formatForDisplay»
                            $onlineStates[] = 'deferred';
                        }
                    «ENDIF»
                    $qb->andWhere('tbl.workflowState IN (:onlineStates)')
                       ->setParameter('onlineStates', $onlineStates);
                }
            «ENDIF»
            «applyDefaultDateRangeFilter»

            return $qb;
        }
    '''

    def private applyDefaultDateRangeFilter(Entity it) '''
        «val startDateField = getStartDateField»
        «val endDateField = getEndDateField»
        «IF null !== startDateField»
            $startDate = null !== $this->getRequest() ? $this->getRequest()->query->get('«startDateField.name.formatForCode»', «startDateField.defaultValueForNow») : «startDateField.defaultValueForNow»;
            $qb->andWhere('«whereClauseForDateRangeFilter('<=', startDateField, 'startDate')»')
               ->setParameter('startDate', $startDate);
        «ENDIF»
        «IF null !== endDateField»
            $endDate = null !== $this->getRequest() ? $this->getRequest()->query->get('«endDateField.name.formatForCode»', «endDateField.defaultValueForNow») : «endDateField.defaultValueForNow»;
            $qb->andWhere('«whereClauseForDateRangeFilter('>=', endDateField, 'endDate')»')
               ->setParameter('endDate', $endDate);
        «ENDIF»
    '''

    def private dispatch defaultValueForNow(EntityField it) '''""'''

    def private dispatch defaultValueForNow(DatetimeField it) '''date('Y-m-d H:i:s')'''

    def private dispatch defaultValueForNow(DateField it) '''date('Y-m-d')'''

    def private whereClauseForDateRangeFilter(Entity it, String operator, DerivedField dateField, String paramName) {
        val dateFieldName = dateField.name.formatForCode
        if (dateField.mandatory)
            '''tbl.«dateFieldName» «operator» :«paramName»'''
        else
            '''(tbl.«dateFieldName» «operator» :«paramName» OR tbl.«dateFieldName» IS NULL)'''
    }

    def private selectSearch(Entity it) '''
        /**
         * Selects entities by a given search fragment.
         *
         * @param string  $fragment       The fragment to search for
         * @param array   $exclude        List with identifiers to be excluded from search
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='')
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true)
         *
         * @return array Retrieved collection and amount of total records affected by this query
         */
        public function selectSearch($fragment = '', $exclude = [], $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)
        {
            $qb = $this->getListQueryBuilder('', $orderBy, $useJoins);
            if (count($exclude) > 0) {
                $qb = $this->addExclusion($qb, $exclude);
            }

            $qb = $this->addSearchFilter($qb, $fragment);

            $query = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);

            return $this->retrieveCollectionResult($query, $orderBy, true);
        }

        /**
         * Adds where clause for search query.
         *
         * @param QueryBuilder $qb       Query builder to be enhanced
         * @param string       $fragment The fragment to search for
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function addSearchFilter(QueryBuilder $qb, $fragment = '')
        {
            if ($fragment == '') {
                return $qb;
            }

            $filters = [];
            $parameters = [];

            «val searchFields = getDisplayFields.filter[isContainedInSearch]»
            «FOR field : searchFields»
                $filters[] = 'tbl.«field.name.formatForCode» «IF field.isTextSearch»LIKE«ELSE»=«ENDIF» :search«field.name.formatForCodeCapital»';
                $parameters['search«field.name.formatForCodeCapital»'] = «IF field.isTextSearch»'%' . $fragment . '%'«ELSE»$fragment«ENDIF»;
            «ENDFOR»

            $qb->andWhere('(' . implode(' OR ', $filters) . ')');

            foreach ($parameters as $parameterName => $parameterValue) {
                $qb->setParameter($parameterName, $parameterValue);
            }

            return $qb;
        }
    '''

    def private retrieveCollectionResult(Entity it) '''
        /**
         * Performs a given database selection and post-processed the results.
         *
         * @param Query   $query       The Query instance to be executed
         * @param string  $orderBy     The order-by clause to use when retrieving the collection (optional) (default='')
         * @param boolean $isPaginated Whether the given query uses a paginator or not (optional) (default=false)
         *
         * @return array Retrieved collection and (for paginated queries) the amount of total records affected
         */
        public function retrieveCollectionResult(Query $query, $orderBy = '', $isPaginated = false)
        {
            $count = 0;
            if (!$isPaginated) {
                $result = $query->getResult();
            } else {
                «IF !(outgoing.filter(JoinRelationship).empty && incoming.filter(JoinRelationship).empty)»
                    $paginator = new Paginator($query, true);
                «ELSE»
                    $paginator = new Paginator($query, false);
                «ENDIF»

                $count = count($paginator);
                $result = $paginator;
            }

            if (!$isPaginated) {
                return $result;
            }

            return [$result, $count];
        }
    '''

    def private selectCount(Entity it) '''
        /**
         * Returns query builder instance for a count query.
         *
         * @param string  $where    The where clause to use when retrieving the object count (optional) (default='')
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=false)
         *
         * @return QueryBuilder Created query builder instance
         */
        protected function getCountQuery($where = '', $useJoins = false)
        {
            $selection = 'COUNT(tbl.«getFirstPrimaryKey.name.formatForCode») AS num«nameMultiple.formatForCodeCapital»';
            if (true === $useJoins) {
                $selection .= $this->addJoinsToSelection();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from('«entityClassName('', false)»', 'tbl');

            if (true === $useJoins) {
                $this->addJoinsToFrom($qb);
            }

            $this->genericBaseQueryAddWhere($qb, $where);

            return $qb;
        }

        /**
         * Selects entity count with a given where clause.
         *
         * @param string  $where      The where clause to use when retrieving the object count (optional) (default='')
         * @param boolean $useJoins   Whether to include joining related objects (optional) (default=false)
         * @param array   $parameters List of determined filter options
         *
         * @return integer Amount of affected records
         */
        public function selectCount($where = '', $useJoins = false, $parameters = [])
        {
            $qb = $this->getCountQuery($where, $useJoins);

            $qb = $this->applyDefaultFilters($qb, $parameters);

            $query = $qb->getQuery();
            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»

            return $query->getSingleScalarResult();
        }
    '''

    def private detectUniqueState(Entity it) '''
        /**
         * Checks for unique values.
         *
         * @param string  $fieldName  The name of the property to be checked
         * @param string  $fieldValue The value of the property to be checked
         * @param integer $excludeId  Id of «nameMultiple.formatForDisplay» to exclude (optional)
         *
         * @return boolean Result of this check, true if the given «name.formatForDisplay» does not already exist
         */
        public function detectUniqueState($fieldName, $fieldValue, $excludeId = 0)
        {
            $qb = $this->getCountQuery('', false);
            $qb->andWhere('tbl.' . $fieldName . ' = :' . $fieldName)
               ->setParameter($fieldName, $fieldValue);

            $qb = $this->addExclusion($qb, [$excludeId]);

            $query = $qb->getQuery();

            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»
            $count = $query->getSingleScalarResult();

            return ($count == 0);
        }
    '''

    def private genericBaseQuery(Entity it) '''
        /**
         * Builds a generic Doctrine query supporting WHERE and ORDER BY.
         *
         * @param string  $where    The where clause to use when retrieving the collection (optional) (default='')
         * @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default='')
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return QueryBuilder Query builder instance to be further processed
         */
        public function genericBaseQuery($where = '', $orderBy = '', $useJoins = true, $slimMode = false)
        {
            // normally we select the whole table
            $selection = 'tbl';

            if (true === $slimMode) {
                // but for the slim version we select only the basic fields, and no joins

                $selection = '«FOR pkField : getPrimaryKeyFields SEPARATOR ', '»tbl.«pkField.name.formatForCode»«ENDFOR»';
                «addSelectionPartsForDisplayPattern»
                «IF hasSluggableFields»
                    $selection .= ', tbl.slug';
                «ENDIF»
                $useJoins = false;
            }

            if (true === $useJoins) {
                $selection .= $this->addJoinsToSelection();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from('«entityClassName('', false)»', 'tbl');

            if (true === $useJoins) {
                $this->addJoinsToFrom($qb);
            }

            $this->genericBaseQueryAddWhere($qb, $where);
            $this->genericBaseQueryAddOrderBy($qb, $orderBy);

            return $qb;
        }
    '''

    def private addSelectionPartsForDisplayPattern(Entity it) '''
        «FOR patternPart : displayPatternParts»
            «/* check if patternPart equals a field name */»
            «var matchedFields = fields.filter[name == patternPart]»
            «IF (!matchedFields.empty || (geographical && (patternPart == 'latitude' || patternPart == 'longitude')))»
                $selection .= ', tbl.«patternPart.formatForCode»';
            «ENDIF»
        «ENDFOR»
    '''

    def private genericBaseQueryWhere(Entity it) '''
        /**
         * Adds WHERE clause to given query builder.
         *
         * @param QueryBuilder $qb    Given query builder instance
         * @param string       $where The where clause to use when retrieving the collection (optional) (default='')
         *
         * @return QueryBuilder Query builder instance to be further processed
         */
        protected function genericBaseQueryAddWhere(QueryBuilder $qb, $where = '')
        {
            «IF standardFields»

                if (null === $this->getRequest()) {
                    // if no request is set we return (#783)
                    return $qb;
                }

                «/*$variableApi = \ServiceUtil::get('zikula_extensions_module.api.variable');
                $showOnlyOwnEntries = $this->getRequest()->query->getInt('own', $variableApi->get('«app.appName»', 'showOnlyOwnEntries', 0));*/»
                $showOnlyOwnEntries = $this->getRequest()->query->getInt('own', 0);
                if ($showOnlyOwnEntries == 1) {
                    «/*$userId = \ServiceUtil::get('zikula_users_module.current_user')->get('uid');*/»
                    $userId = $this->getRequest()->getSession()->get('uid');
                    $qb->andWhere('tbl.createdBy = :creator')
                       ->setParameter('creator', $userId);
                }
            «ENDIF»

            return $qb;
        }
    '''

    def private genericBaseQueryOrderBy(Entity it) '''
        /**
         * Adds ORDER BY clause to given query builder.
         *
         * @param QueryBuilder $qb      Given query builder instance
         * @param string       $orderBy The order-by clause to use when retrieving the collection (optional) (default='')
         *
         * @return QueryBuilder Query builder instance to be further processed
         */
        protected function genericBaseQueryAddOrderBy(QueryBuilder $qb, $orderBy = '')
        {
            if ($orderBy == 'RAND()') {
                // random selection
                $qb->addSelect('MOD(tbl.«getFirstPrimaryKey.name.formatForCode», ' . mt_rand(2, 15) . ') AS HIDDEN randomIdentifiers')
                   ->add('orderBy', 'randomIdentifiers');

                return $qb;
            }

            if (empty($orderBy)) {
                $orderBy = $this->defaultSortingField;
            }

            if (empty($orderBy)) {
                return $qb;
            }

            // add order by clause
            if (false === strpos($orderBy, '.')) {
                $orderBy = 'tbl.' . $orderBy;
            }
            «IF standardFields»
                if (false !== strpos($orderBy, 'tbl.createdBy')) {
                    $qb->addSelect('tblCreator')
                       ->leftJoin('tbl.createdBy', 'tblCreator');
                    $orderBy = str_replace('tbl.createdBy', 'tblCreator.uname', $orderBy);
                }
                if (false !== strpos($orderBy, 'tbl.updatedBy')) {
                    $qb->addSelect('tblUpdater')
                       ->leftJoin('tbl.updatedBy', 'tblUpdater');
                    $orderBy = str_replace('tbl.updatedBy', 'tblUpdater.uname', $orderBy);
                }
            «ENDIF»
            $qb->add('orderBy', $orderBy);

            return $qb;
        }
    '''

    def private getQueryFromBuilder(Entity it) '''
        /**
         * Retrieves Doctrine query from query builder.
         *
         * @param QueryBuilder $qb Query builder instance
         *
         * @return Query Query instance to be further processed
         */
        public function getQueryFromBuilder(QueryBuilder $qb)
        {
            $query = $qb->getQuery();
            «IF hasTranslatableFields»

                $featureActivationHelper = \ServiceUtil::get('«app.appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, '«name.formatForCode»')) {
                    // set the translation query hint
                    $query->setHint(
                        Query::HINT_CUSTOM_OUTPUT_WALKER,
                        'Gedmo\\Translatable\\Query\\TreeWalker\\TranslationWalker'
                    );
                }
            «ENDIF»
            «IF hasPessimisticReadLock»

                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»

            return $query;
        }
    '''

    def private singleSortingField(EntityField it) {
        switch it {
            DerivedField : {
                val joins = entity.incoming.filter(JoinRelationship).filter[e|formatForDB(e.getSourceFields.head) == name.formatForDB]
                if (!joins.empty) '''
                     '«joins.head.source.name.formatForCode»',
                     '''
                else '''
                     '«name.formatForCode»',
                     '''
            }
            CalculatedField: '''
                     '«name.formatForCode»',
                     '''
        }
    }

    def private isContainedInSearch(DerivedField it) {
        switch it {
            BooleanField: false
            UserField: false
            ArrayField: false
            ObjectField: false
            default: true
        }
    }

    def private isTextSearch(DerivedField it) {
        switch it {
            StringField: true
            TextField: true
            default: false
        }
    }

    def private extensionSortingFields(Entity it) '''
        «IF geographical»
             'latitude',
             'longitude',
        «ENDIF»
        «IF standardFields»
             'createdBy',
             'createdDate',
             'updatedBy',
             'updatedDate',
        «ENDIF»
    '''

    def private modelRepositoryImpl(Entity it) '''
        namespace «app.appNamespace»\Entity\Repository;

        use «app.appNamespace»\Entity\Repository\«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»«ENDIF»Repository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «name.formatForDisplay» entities.
         */
        class «name.formatForCodeCapital»Repository extends «IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»«ENDIF»Repository
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
