package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CalculatedField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Joins
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.LinkTable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Tree
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.UserDeletion
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Repository {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    IMostFileSystemAccess fsa
    FileHelper fh = new FileHelper
    Application app

    /**
     * Entry point for Doctrine repository classes.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        app = it
        getAllEntities.forEach(e|e.generate)

        val linkTable = new LinkTable
        for (relation : getJoinRelations.filter(ManyToManyRelationship)) {
            linkTable.generate(relation, it, fsa)
        }
    }

    /**
     * Creates a repository class file for every Entity instance.
     */
    def private generate(Entity it) {
        ('Generating repository classes for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        val repositoryPath = 'Entity/Repository/'
        var fileSuffix = 'Repository'

        var fileName = 'Base/Abstract' + name.formatForCodeCapital + fileSuffix + '.php'
        val content = if (!isInheriting) modelRepositoryBaseImpl else modelChildRepositoryBaseImpl
        fsa.generateFile(repositoryPath + fileName, content)

        if (!app.generateOnlyBaseClasses) {
            fileName = name.formatForCodeCapital + fileSuffix + '.php'
            fsa.generateFile(repositoryPath + fileName, modelRepositoryImpl)
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
            val stringFields = fields.filter(StringField).filter[role != StringRole.PASSWORD]
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

            «ENDIF*/»/**
             * @var string The main entity class
             */
            protected $mainEntityClass = '«entityClassName('', false)»';

            /**
             * @var string The default sorting field/expression
             */
            protected $defaultSortingField = '«getDefaultSortingField.name.formatForCode»';

            /**
             * @var CollectionFilterHelper
             */
            protected $collectionFilterHelper = null;
            «IF hasTranslatableFields»

                /**
                 * @var bool Whether translations are enabled or not
                 */
                protected $translationsEnabled = true;
            «ENDIF»«/*IF tree != EntityTreeType.NONE»

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
                     * @param array  $args   List of additional arguments
                     *
                     * @return mixed $result
                     * /
                    public function __call($method, array $args = [])
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
             * @return string[] List of sorting field names
             */
            public function getAllowedSortingFields()
            {
                return [
                    «FOR field : getSortingFields»«field.singleSortingField»«ENDFOR»
                    «extensionSortingFields»
                ];
            }

            «fh.getterAndSetterMethods(it, 'defaultSortingField', 'string', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'collectionFilterHelper', 'CollectionFilterHelper', false, true, true, '', '')»
            «IF hasTranslatableFields»
                «fh.getterAndSetterMethods(it, 'translationsEnabled', 'bool', false, false, false, '', '')»
            «ENDIF»

            «new UserDeletion().generate(it)»

            «selectById»
            «IF hasSluggableFields && slugUnique»

                «selectBySlug»
            «ENDIF»

            «addExclusion»

            «selectWhere»

            «selectWherePaginated»

            «selectSearch»

            «retrieveCollectionResult»

            «getCountQuery»

            «selectCount»

            «new Tree().generate(it, app)»

            «detectUniqueState»

            «genericBaseQuery»

            «genericBaseQueryOrderBy»

            «getQueryFromBuilder»

            «new Joins().generate(it, app)»
        }
    '''

    def private modelChildRepositoryBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Entity\Repository\Base;

        «IF !incoming.empty || !outgoing.empty»
            use Doctrine\ORM\QueryBuilder;
        «ENDIF»
        use «app.appNamespace»\Entity\Repository\«parentType.name.formatForCodeCapital»Repository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «name.formatForDisplay» entities.
         */
        abstract class Abstract«name.formatForCodeCapital»Repository extends «parentType.name.formatForCodeCapital»Repository
        {
            /**
             * @var string The main entity class
             */
            protected $mainEntityClass = '«entityClassName('', false)»';

            /**
             * @inheritDoc
             */
            public function getAllowedSortingFields()
            {
                $parentFields = parent::getAllowedSortingFields();

                $additionalFields = [
                    «FOR field : getSortingFields»«field.singleSortingField»«ENDFOR»
                    «extensionSortingFields»
                ];

                return array_unique(array_merge($parentFields, $additionalFields));
            }
            «IF !incoming.empty || !outgoing.empty»

                «new Joins().generate(it, app)»
            «ENDIF»
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
        «IF hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
        «ENDIF»
        use Doctrine\ORM\Tools\Pagination\Paginator;
        use InvalidArgumentException;
        use Psr\Log\LoggerInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use «app.appNamespace»\Entity\«name.formatForCodeCapital»Entity;
        use «app.appNamespace»\Helper\CollectionFilterHelper;

    '''

    def private selectById(Entity it) '''
        /**
         * Adds an array of id filters to given query instance.
         *
         * @param array        $idList List of identifiers to use to retrieve the object
         * @param QueryBuilder $qb     Query builder to be enhanced
         *
         * @return QueryBuilder Enriched query builder instance
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        protected function addIdListFilter(array $idList, QueryBuilder $qb)
        {
            $orX = $qb->expr()->orX();

            foreach ($idList as $id) {
                // check id parameter
                if ($id == 0) {
                    throw new InvalidArgumentException('Invalid identifier received.');
                }

                $orX->add($qb->expr()->eq('tbl.«getPrimaryKey.name.formatForCode»', $id));
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

            return null !== $results && count($results) > 0 ? $results[0] : null;
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

            if (!$slimMode && null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->applyDefaultFilters('«name.formatForCode»', $qb);
            }

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

            if ($excludeId > 0) {
                $qb = $this->addExclusion($qb, [$excludeId]);
            }

            if (!$slimMode && null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->applyDefaultFilters('«name.formatForCode»', $qb);
            }

            $query = $this->getQueryFromBuilder($qb);

            $results = $query->getResult();

            return null !== $results && count($results) > 0 ? $results[0] : null;
        }
    '''

    def private addExclusion(Entity it) '''
        /**
         * Adds where clauses excluding desired identifiers from selection.
         *
         * @param QueryBuilder $qb         Query builder to be enhanced
         * @param array        $exclusions List of identifiers to be excluded from selection
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function addExclusion(QueryBuilder $qb, array $exclusions = [])
        {
            if (count($exclusions) > 0) {
                $qb->andWhere('tbl.«getPrimaryKey.name.formatForCode» NOT IN (:excludedIdentifiers)')
                   ->setParameter('excludedIdentifiers', $exclusions);
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
            if (!$slimMode && null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->addCommonViewFilters('«name.formatForCode»', $qb);
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

            return $this->retrieveCollectionResult($query, false);
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
            if ($currentPage < 1) {
                $currentPage = 1;
            }
            if ($resultsPerPage < 1) {
                $resultsPerPage = 25;
            }
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

            return $this->retrieveCollectionResult($query, true);
        }
    '''

    def private selectSearch(Entity it) '''
        /**
         * Selects entities by a given search fragment.
         *
         * @param string  $fragment       The fragment to search for
         * @param array   $exclude        List of identifiers to be excluded from search
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='')
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true)
         *
         * @return array Retrieved collection and amount of total records affected by this query
         */
        public function selectSearch($fragment = '', array $exclude = [], $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)
        {
            $qb = $this->getListQueryBuilder('', $orderBy, $useJoins);
            if (count($exclude) > 0) {
                $qb = $this->addExclusion($qb, $exclude);
            }

            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->addSearchFilter('«name.formatForCode»', $qb, $fragment);
            }

            $query = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);

            return $this->retrieveCollectionResult($query, true);
        }
    '''

    def private retrieveCollectionResult(Entity it) '''
        /**
         * Performs a given database selection and post-processed the results.
         *
         * @param Query   $query       The Query instance to be executed
         * @param boolean $isPaginated Whether the given query uses a paginator or not (optional) (default=false)
         *
         * @return array Retrieved collection and (for paginated queries) the amount of total records affected
         */
        public function retrieveCollectionResult(Query $query, $isPaginated = false)
        {
            $count = 0;
            if (!$isPaginated) {
                $result = $query->getResult();
            } else {
                «IF categorisable || !(outgoing.filter(JoinRelationship).empty && incoming.filter(JoinRelationship).empty)»
                    $paginator = new Paginator($query, true);
                «ELSE»
                    $paginator = new Paginator($query, false);
                «ENDIF»
                «IF hasTranslatableFields»
                    if (true === $this->translationsEnabled) {
                        $paginator->setUseOutputWalkers(true);
                    }
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

    def private getCountQuery(Entity it) '''
        /**
         * Returns query builder instance for a count query.
         *
         * @param string  $where    The where clause to use when retrieving the object count (optional) (default='')
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=false)
         *
         * @return QueryBuilder Created query builder instance
         */
        public function getCountQuery($where = '', $useJoins = false)
        {
            $selection = 'COUNT(tbl.«getPrimaryKey.name.formatForCode») AS num«nameMultiple.formatForCodeCapital»';

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from($this->mainEntityClass, 'tbl');

            if (true === $useJoins) {
                $this->addJoinsToFrom($qb);
            }

            if (!empty($where)) {
                $qb->andWhere($where);
            }

            return $qb;
        }
    '''

    def private selectCount(Entity it) '''
        /**
         * Selects entity count with a given where clause.
         *
         * @param string  $where      The where clause to use when retrieving the object count (optional) (default='')
         * @param boolean $useJoins   Whether to include joining related objects (optional) (default=false)
         * @param array   $parameters List of determined filter options
         *
         * @return integer Amount of affected records
         */
        public function selectCount($where = '', $useJoins = false, array $parameters = [])
        {
            $qb = $this->getCountQuery($where, $useJoins);

            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->applyDefaultFilters('«name.formatForCode»', $qb, $parameters);
            }

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

            if ($excludeId > 0) {
                $qb = $this->addExclusion($qb, [$excludeId]);
            }

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

                $selection = 'tbl.«getPrimaryKey.name.formatForCode»';
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
               ->from($this->mainEntityClass, 'tbl');

            if (true === $useJoins) {
                $this->addJoinsToFrom($qb);
            }

            if (!empty($where)) {
                $qb->andWhere($where);
            }

            $this->genericBaseQueryAddOrderBy($qb, $orderBy);

            return $qb;
        }
    '''

    def private addSelectionPartsForDisplayPattern(Entity it) '''
        «FOR patternPart : displayPatternParts»
            «/* check if patternPart equals a field name */»«var matchedFields = fields.filter[name == patternPart]»
            «IF (!matchedFields.empty || (geographical && (patternPart == 'latitude' || patternPart == 'longitude')))»
                $selection .= ', tbl.«patternPart.formatForCode»';
            «ENDIF»
        «ENDFOR»
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
                $qb->addSelect('MOD(tbl.«getPrimaryKey.name.formatForCode», ' . mt_rand(2, 15) . ') AS HIDDEN randomIdentifiers')
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
            «IF hasUploadFieldsEntity»
                foreach (['«getUploadFieldsEntity.map[name.formatForCode].join('\', \'')»'] as $uploadField) {
                    $orderBy = str_replace('tbl.' . $uploadField, 'tbl.' . $uploadField . 'FileName', $orderBy);
                }
            «ENDIF»
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

                if (true === $this->translationsEnabled) {
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

    def private singleSortingField(Field it) {
        switch it {
            DerivedField : {
                val joins = if (null !== entity) entity.incoming.filter(JoinRelationship).filter[e|formatForDB(e.getSourceFields.head) == name.formatForDB] else #[]
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

        use «app.appNamespace»\Entity\Repository\Base\Abstract«name.formatForCodeCapital»Repository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «name.formatForDisplay» entities.
         */
        class «name.formatForCodeCapital»Repository extends Abstract«name.formatForCodeCapital»Repository
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
