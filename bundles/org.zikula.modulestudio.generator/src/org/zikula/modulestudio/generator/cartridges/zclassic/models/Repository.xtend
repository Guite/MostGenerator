package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.CalculatedField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
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
    FileHelper fh
    Application app

    Iterable<? extends JoinRelationship> sortRelationsIn
    Iterable<? extends JoinRelationship> sortRelationsOut

    /**
     * Entry point for Doctrine repository classes.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        app = it
        fh = new FileHelper(app)
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

        sortRelationsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]
        sortRelationsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]

        var fileName = 'Base/Abstract' + name.formatForCodeCapital + fileSuffix + '.php'
        val content = if (!isInheriting || parentType instanceof MappedSuperClass) modelRepositoryBaseImpl else modelChildRepositoryBaseImpl
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
            protected $mainEntityClass = «name.formatForCodeCapital»Entity::class;

            /**
             * @var string The default sorting field/expression
             */
            protected $defaultSortingField = '«getDefaultSortingField.name.formatForCode»';

            /**
             * @var CollectionFilterHelper
             */
            protected $collectionFilterHelper;
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
            public function getAllowedSortingFields()«IF app.targets('3.0')»: array«ENDIF»
            {
                return [
                    «sortingCriteria»
                ];
            }
            «fh.getterAndSetterMethods(it, 'defaultSortingField', 'string', false, true, app.targets('3.0'), '', '')»
            «fh.getterAndSetterMethods(it, 'collectionFilterHelper', 'CollectionFilterHelper', false, true, true, '', '')»
            «IF hasTranslatableFields»
                «fh.getterAndSetterMethods(it, 'translationsEnabled', 'bool', false, true, app.targets('3.0'), '', '')»
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
             * @return string[]
             */
            public function getAllowedSortingFields()
            {
                $parentFields = parent::getAllowedSortingFields();

                $additionalFields = [
                    «sortingCriteria»
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

        «IF !app.targets('3.0')»
            use Doctrine\Common\Collections\ArrayCollection;
        «ENDIF»
        «/*IF tree != EntityTreeType.NONE»
            use Doctrine\ORM\EntityManager;
        «ENDIF*/»«IF tree == EntityTreeType.NONE && !hasSortableFields»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»«/*IF tree != EntityTreeType.NONE»
            use Doctrine\ORM\Mapping\ClassMetadata;
        «ENDIF*/»
        use Doctrine\ORM\Query;
        use Doctrine\ORM\QueryBuilder;
        «IF hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
        «ENDIF»
        «IF !app.targets('3.0')»
            use Doctrine\ORM\Tools\Pagination\Paginator;
        «ENDIF»
        «IF tree == EntityTreeType.NONE && hasSortableFields»
            use Gedmo\Sortable\Entity\Repository\SortableRepository;
        «ENDIF»
        «IF tree != EntityTreeType.NONE»
            use Gedmo\Tree\Entity\Repository\«tree.literal.toLowerCase.toFirstUpper»TreeRepository;«/*
            use Gedmo\Tree\Traits\Repository\«tree.literal.toLowerCase.toFirstUpper»TreeRepositoryTrait; */»
        «ENDIF»
        «IF hasTranslatableFields»
            use Gedmo\Translatable\Query\TreeWalker\TranslationWalker;
        «ENDIF»
        use InvalidArgumentException;
        use Psr\Log\LoggerInterface;
        «IF app.targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
            use Zikula\Bundle\CoreBundle\Doctrine\Paginator;
            use Zikula\Bundle\CoreBundle\Doctrine\PaginatorInterface;
        «ELSE»
            use Zikula\Common\Translator\TranslatorInterface;
        «ENDIF»
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use «entityClassName('', false)»;
        use «app.appNamespace»\Helper\CollectionFilterHelper;

    '''

    def private selectById(Entity it) '''
        /**
         * Adds an array of id filters to given query instance.
         «IF !application.targets('3.0')»
         *
         * @param array $idList List of identifiers to use to retrieve the object
         * @param QueryBuilder $qb Query builder to be enhanced
         *
         * @return QueryBuilder Enriched query builder instance
         «ENDIF»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        protected function addIdListFilter(array $idList, QueryBuilder $qb)«IF application.targets('3.0')»: QueryBuilder«ENDIF»
        {
            $orX = $qb->expr()->orX();

            foreach ($idList as $key => $id) {
                if (0 === $id) {
                    throw new InvalidArgumentException('Invalid identifier received.');
                }

                $orX->add($qb->expr()->eq('tbl.«getPrimaryKey.name.formatForCode»', ':idListFilter_' . $key));
                $qb->setParameter('idListFilter_' . $key, $id);
            }

            $qb->andWhere($orX);

            return $qb;
        }

        /**
         * Selects an object from the database.
         *
         * @param mixed $id The id (or array of ids) to use to retrieve the object (optional) (default=0)
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         * @param bool $slimMode If activated only some basic fields are selected without using any joins
         *                       (optional) (default=false)
         *
         * @return array|«name.formatForCodeCapital»Entity Retrieved data array or «name.formatForCode»Entity instance
         */
        public function selectById(
            $id = 0,
            «IF application.targets('3.0')»bool «ENDIF»$useJoins = true,
            «IF application.targets('3.0')»bool «ENDIF»$slimMode = false
        ) {
            $results = $this->selectByIdList(is_array($id) ? $id : [$id], $useJoins, $slimMode);

            return null !== $results && 0 < count($results) ? $results[0] : null;
        }
        
        /**
         * Selects a list of objects with an array of ids.
         *
         * @param array $idList The array of ids to use to retrieve the objects (optional) (default=0)
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         * @param bool $slimMode If activated only some basic fields are selected without using any joins
         *                       (optional) (default=false)
         *
         * @return array Retrieved «name.formatForCodeCapital»Entity instances
         */
        public function selectByIdList(
            array $idList = [0],
            «IF application.targets('3.0')»bool «ENDIF»$useJoins = true,
            «IF application.targets('3.0')»bool «ENDIF»$slimMode = false
        )«IF application.targets('3.0')»: ?array«ENDIF» {
            $qb = $this->genericBaseQuery('', '', $useJoins, $slimMode);
            $qb = $this->addIdListFilter($idList, $qb);

            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->applyDefaultFilters('«name.formatForCode»', $qb);
            }

            $query = $this->getQueryFromBuilder($qb);
        
            $results = $query->getResult();

            return 0 < count($results) ? $results : null;
        }
    '''

    def private selectBySlug(Entity it) '''
        /**
         * Selects an object by slug field.
         «IF !application.targets('3.0')»
         *
         * @param string $slugTitle The slug value
         * @param bool $useJoins  Whether to include joining related objects (optional) (default=true)
         * @param bool $slimMode If activated only some basic fields are selected without using any joins
         *                       (optional) (default=false)
         * @param int $excludeId Optional id to be excluded (used for unique validation)
         *
         * @return «name.formatForCodeCapital»Entity
         «ENDIF»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function selectBySlug«IF application.targets('3.0')»(
            string $slugTitle = '',
            bool $useJoins = true,
            bool $slimMode = false,
            int $excludeId = 0
        ): ?«name.formatForCodeCapital»Entity {«ELSE»(
            $slugTitle = '',
            $useJoins = true,
            $slimMode = false,
            $excludeId = 0
        ) {«ENDIF»
            if ('' === $slugTitle) {
                throw new InvalidArgumentException('Invalid slug title received.');
            }

            $qb = $this->genericBaseQuery('', '', $useJoins, $slimMode);

            $qb->andWhere('tbl.slug = :slug')
               ->setParameter('slug', $slugTitle);

            if ($excludeId > 0) {
                $qb = $this->addExclusion($qb, [$excludeId]);
            }

            if (null !== $this->collectionFilterHelper) {
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
         «IF !application.targets('3.0')»
         *
         * @param QueryBuilder $qb Query builder to be enhanced
         * @param array $exclusions List of identifiers to be excluded from selection
         *
         * @return QueryBuilder Enriched query builder instance
         «ENDIF»
         */
        protected function addExclusion(QueryBuilder $qb, array $exclusions = [])«IF application.targets('3.0')»: QueryBuilder«ENDIF»
        {
            if (0 < count($exclusions)) {
                $qb->andWhere('tbl.«getPrimaryKey.name.formatForCode» NOT IN (:excludedIdentifiers)')
                   ->setParameter('excludedIdentifiers', $exclusions);
            }

            return $qb;
        }
    '''

    def private selectWhere(Entity it) '''
        /**
         * Returns query builder for selecting a list of objects with a given where clause.
         «IF !application.targets('3.0')»
         *
         * @param string $where The where clause to use when retrieving the collection (optional) (default='')
         * @param string $orderBy The order-by clause to use when retrieving the collection (optional) (default='')
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         * @param bool $slimMode If activated only some basic fields are selected without using any joins
         *                       (optional) (default=false)
         *
         * @return QueryBuilder Query builder for the given arguments
         «ENDIF»
         */
        public function getListQueryBuilder«IF application.targets('3.0')»(
            string $where = '',
            string $orderBy = '',
            bool $useJoins = true,
            bool $slimMode = false
        ): QueryBuilder {«ELSE»(
            $where = '',
            $orderBy = '',
            $useJoins = true,
            $slimMode = false
        ) {«ENDIF»
            $qb = $this->genericBaseQuery($where, $orderBy, $useJoins, $slimMode);
            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->addCommonViewFilters('«name.formatForCode»', $qb);
            }

            return $qb;
        }

        /**
         * Selects a list of objects with a given where clause.
         «IF !application.targets('3.0')»
         *
         * @param string $where The where clause to use when retrieving the collection (optional) (default='')
         * @param string $orderBy The order-by clause to use when retrieving the collection (optional) (default='')
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         * @param bool $slimMode If activated only some basic fields are selected without using any joins
         *                       (optional) (default=false)
         *
         * @return array List of retrieved «name.formatForCode»Entity instances
         «ENDIF»
         */
        public function selectWhere«IF application.targets('3.0')»(
            string $where = '',
            string $orderBy = '',
            bool $useJoins = true,
            bool $slimMode = false
        ): array {«ELSE»(
            $where = '',
            $orderBy = '',
            $useJoins = true,
            $slimMode = false
        ) {«ENDIF»
            $qb = $this->getListQueryBuilder($where, $orderBy, $useJoins, $slimMode);

            «IF application.targets('3.0')»
                return $this->retrieveCollectionResult($qb);
            «ELSE»
                $query = $this->getQueryFromBuilder($qb);

                return $this->retrieveCollectionResult($query);
            «ENDIF»
        }
    '''

    def private selectWherePaginated(Entity it) '''
        «IF !application.targets('3.0')»
            /**
             * Returns query builder instance for retrieving a list of objects with a given
             * where clause and pagination parameters.
             *
             * @param QueryBuilder $qb Query builder to be enhanced
             * @param int $currentPage Where to start selection
             * @param int $resultsPerPage Amount of items to select
             *
             * @return Query Created query instance
             */
            public function getSelectWherePaginatedQuery«IF application.targets('3.0')»(
                QueryBuilder $qb,
                int $currentPage = 1,
                int $resultsPerPage = 25
            ): Query {«ELSE»(
                QueryBuilder $qb,
                $currentPage = 1,
                $resultsPerPage = 25
            ) {«ENDIF»
                if (1 > $currentPage) {
                    $currentPage = 1;
                }
                if (1 > $resultsPerPage) {
                    $resultsPerPage = 25;
                }
                $query = $this->getQueryFromBuilder($qb);
                $offset = ($currentPage - 1) * $resultsPerPage;

                $query->setFirstResult($offset)
                      ->setMaxResults($resultsPerPage);

                return $query;
            }

        «ENDIF»
        /**
         * Selects a list of objects with a given where clause and pagination parameters.
         «IF !application.targets('3.0')»
         *
         * @param string $where The where clause to use when retrieving the collection (optional) (default='')
         * @param string $orderBy The order-by clause to use when retrieving the collection (optional) (default='')
         * @param int $currentPage Where to start selection
         * @param int $resultsPerPage Amount of items to select
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         * @param bool $slimMode If activated only some basic fields are selected without using any joins
         *                       (optional) (default=false)
         *
         * @return array Retrieved collection and the amount of total records affected
         «ENDIF»
         */
        public function selectWherePaginated«IF application.targets('3.0')»(
            string $where = '',
            string $orderBy = '',
            int $currentPage = 1,
            int $resultsPerPage = 25,
            bool $useJoins = true,
            bool $slimMode = false
        ): PaginatorInterface {«ELSE»(
            $where = '',
            $orderBy = '',
            $currentPage = 1,
            $resultsPerPage = 25,
            $useJoins = true,
            $slimMode = false
        ) {«ENDIF»
            $qb = $this->getListQueryBuilder($where, $orderBy, $useJoins, $slimMode);
            «IF application.targets('3.0')»

                return $this->retrieveCollectionResult($qb, true, $currentPage, $resultsPerPage);
            «ELSE»
                $query = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);

                return $this->retrieveCollectionResult($query, true);
            «ENDIF»
        }
    '''

    def private selectSearch(Entity it) '''
        /**
         * Selects entities by a given search fragment.
         «IF !application.targets('3.0')»
         *
         * @param string $fragment The fragment to search for
         * @param array $exclude List of identifiers to be excluded from search
         * @param string $orderBy The order-by clause to use when retrieving the collection (optional) (default='')
         * @param in $currentPage Where to start selection
         * @param in $resultsPerPage Amount of items to select
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         «ENDIF»
         *
         * @return array Retrieved collection and (for paginated queries) the amount of total records affected
         */
        public function selectSearch«IF application.targets('3.0')»(
            string $fragment = '',
            array $exclude = [],
            string $orderBy = '',
            int $currentPage = 1,
            int $resultsPerPage = 25,
            bool $useJoins = true
        ): \Traversable {«ELSE»(
            $fragment = '',
            array $exclude = [],
            $orderBy = '',
            $currentPage = 1,
            $resultsPerPage = 25,
            $useJoins = true
        ) {«ENDIF»
            $qb = $this->getListQueryBuilder('', $orderBy, $useJoins);
            if (0 < count($exclude)) {
                $qb = $this->addExclusion($qb, $exclude);
            }

            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->addSearchFilter('«name.formatForCode»', $qb, $fragment);
            }

            «IF application.targets('3.0')»
                $paginator = $this->retrieveCollectionResult($qb, true, $currentPage, $resultsPerPage);

                return $paginator->getResults();
            «ELSE»
                $query = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);

                return $this->retrieveCollectionResult($query, true);
            «ENDIF»
        }
    '''

    def private retrieveCollectionResult(Entity it) '''
        /**
         * Performs a given database selection and post-processed the results.
         «IF !application.targets('3.0')»
         *
         * @param Query $query The Query instance to be executed
         * @param bool $isPaginated Whether the given query uses a paginator or not (optional) (default=false)
         «ENDIF»
         *
         «IF application.targets('3.0')»
         * @return PaginatorInterface|array Paginator (for paginated queries) or retrieved collection
         «ELSE»
         * @return array Retrieved collection and (for paginated queries) the amount of total records affected
         «ENDIF»
         */
        public function retrieveCollectionResult(
            «IF application.targets('3.0')»
                QueryBuilder $qb,
                bool $isPaginated = false,
                int $currentPage = 1,
                int $resultsPerPage = 25
            «ELSE»
                Query $query,
                $isPaginated = false
            «ENDIF»
        ) {
            «IF application.targets('3.0')»
                if (!$isPaginated) {
                    $query = $this->getQueryFromBuilder($qb);

                    return $query->getResult();
                }

                return (new Paginator($qb, $resultsPerPage))->paginate($currentPage);
            «ELSE»
                $count = 0;
                if (!$isPaginated) {
                    $result = $query->getResult();
                } else {
                    «IF categorisable || !(outgoing.filter(JoinRelationship).empty && incoming.filter(JoinRelationship).empty)»
                        $paginator = new Paginator($query, true);
                    «ELSE»
                        $paginator = new Paginator($query, false);
                    «ENDIF»«/* this breaks searching for / filtering by translated fields (#1234)
                    IF hasTranslatableFields»
                        if (true === $this->translationsEnabled) {
                            $paginator->setUseOutputWalkers(true);
                        }
                    «ENDIF*/»

                    $count = count($paginator);
                    $result = $paginator;
                }

                if (!$isPaginated) {
                    return $result;
                }

                return [$result, $count];
            «ENDIF»
        }
    '''

    def private getCountQuery(Entity it) '''
        /**
         * Returns query builder instance for a count query.
         «IF !application.targets('3.0')»
         *
         * @param string $where The where clause to use when retrieving the object count (optional) (default='')
         * @param bool $useJoins Whether to include joining related objects (optional) (default=false)
         *
         * @return QueryBuilder Created query builder instance
         «ENDIF»
         */
        public function getCountQuery«IF application.targets('3.0')»(string $where = '', bool $useJoins = false): QueryBuilder«ELSE»($where = '', $useJoins = false)«ENDIF»
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
         «IF !application.targets('3.0')»
         *
         * @param string $where The where clause to use when retrieving the object count (optional) (default='')
         * @param bool $useJoins Whether to include joining related objects (optional) (default=false)
         * @param array $parameters List of determined filter options
         *
         * @return int Amount of affected records
         «ENDIF»
         */
        public function selectCount«IF application.targets('3.0')»(string $where = '', bool $useJoins = false, array $parameters = []): int«ELSE»($where = '', $useJoins = false, array $parameters = [])«ENDIF»
        {
            $qb = $this->getCountQuery($where, $useJoins);

            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->applyDefaultFilters('«name.formatForCode»', $qb, $parameters);
            }

            $query = $qb->getQuery();
            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»

            return (int) $query->getSingleScalarResult();
        }
    '''

    def private detectUniqueState(Entity it) '''
        /**
         * Checks for unique values.
         «IF !application.targets('3.0')»
         *
         * @param string $fieldName The name of the property to be checked
         * @param string $fieldValue The value of the property to be checked
         * @param int $excludeId Identifier of «nameMultiple.formatForDisplay» to exclude (optional)
         *
         * @return bool Result of this check, true if the given «name.formatForDisplay» does not already exist
         «ENDIF»
         */
        public function detectUniqueState«IF application.targets('3.0')»(string $fieldName, string $fieldValue, int $excludeId = 0): bool«ELSE»($fieldName, $fieldValue, $excludeId = 0)«ENDIF»
        {
            $qb = $this->getCountQuery();
            $qb->andWhere('tbl.' . $fieldName . ' = :' . $fieldName)
               ->setParameter($fieldName, $fieldValue);

            if ($excludeId > 0) {
                $qb = $this->addExclusion($qb, [$excludeId]);
            }

            $query = $qb->getQuery();

            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»
            $count = (int) $query->getSingleScalarResult();

            return 1 > $count;
        }
    '''

    def private genericBaseQuery(Entity it) '''
        /**
         * Builds a generic Doctrine query supporting WHERE and ORDER BY.
         «IF !application.targets('3.0')»
         *
         * @param string $where The where clause to use when retrieving the collection (optional) (default='')
         * @param string $orderBy The order-by clause to use when retrieving the collection (optional) (default='')
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         * @param bool $slimMode If activated only some basic fields are selected without using any joins
         *                       (optional) (default=false)
         *
         * @return QueryBuilder Query builder instance to be further processed
         «ENDIF»
         */
        public function genericBaseQuery«IF application.targets('3.0')»(
            string $where = '',
            string $orderBy = '',
            bool $useJoins = true,
            bool $slimMode = false
        ): QueryBuilder {«ELSE»(
            $where = '',
            $orderBy = '',
            $useJoins = true,
            $slimMode = false
        ) {«ENDIF»
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

            «IF !sortRelationsIn.empty || !sortRelationsOut.empty»
                if (true !== $useJoins) {
                    $orderByField = $orderBy;
                    if (false !== mb_strpos($orderByField, ' ')) {
                        list($orderByField, $direction) = explode(' ', $orderByField, 2);
                    }
                    if (
                        «IF !sortRelationsIn.empty»
                            in_array($orderByField, ['«sortRelationsIn.map[getRelationAliasName(false).formatForCode].join('\', \'')»'], true)
                        «ENDIF»
                        «IF !sortRelationsOut.empty»
                            «IF !sortRelationsIn.empty»|| «ENDIF»in_array($orderByField, ['«sortRelationsOut.map[getRelationAliasName(true).formatForCode].join('\', \'')»'], true)
                        «ENDIF»
                    ) {
                        $useJoins = true;
                    }
                }

            «ENDIF»
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
         «IF !application.targets('3.0')»
         *
         * @param QueryBuilder $qb Given query builder instance
         * @param string $orderBy The order-by clause to use when retrieving the collection (optional) (default='')
         *
         * @return QueryBuilder Query builder instance to be further processed
         «ENDIF»
         */
        protected function genericBaseQueryAddOrderBy(QueryBuilder $qb, «IF application.targets('3.0')»string «ENDIF»$orderBy = '')«IF application.targets('3.0')»: QueryBuilder«ENDIF»
        {
            if ('RAND()' === $orderBy) {
                // random selection
                $qb->addSelect('MOD(tbl.«getPrimaryKey.name.formatForCode», ' . «IF application.targets('3.0')»random_int«ELSE»mt_rand«ENDIF»(2, 15) . ') AS HIDDEN randomIdentifiers')
                   ->orderBy('randomIdentifiers');

                return $qb;
            }

            if (empty($orderBy)) {
                $orderBy = $this->defaultSortingField;
            }

            if (empty($orderBy)) {
                return $qb;
            }

            «IF !sortRelationsIn.empty || !sortRelationsOut.empty»
                $orderBy = $this->resolveOrderByForRelation($orderBy);

            «ENDIF»
            // add order by clause
            if (false === mb_strpos($orderBy, '.')) {
                $orderBy = 'tbl.' . $orderBy;
            }
            «IF hasUploadFieldsEntity»
                foreach (['«getUploadFieldsEntity.map[name.formatForCode].join('\', \'')»'] as $uploadField) {
                    $orderBy = str_replace('tbl.' . $uploadField, 'tbl.' . $uploadField . 'FileName', $orderBy);
                }
            «ENDIF»
            «IF standardFields»
                if (false !== mb_strpos($orderBy, 'tbl.createdBy')) {
                    $qb->addSelect('tblCreator')
                       ->leftJoin('tbl.createdBy', 'tblCreator');
                    $orderBy = str_replace('tbl.createdBy', 'tblCreator.uname', $orderBy);
                }
                if (false !== mb_strpos($orderBy, 'tbl.updatedBy')) {
                    $qb->addSelect('tblUpdater')
                       ->leftJoin('tbl.updatedBy', 'tblUpdater');
                    $orderBy = str_replace('tbl.updatedBy', 'tblUpdater.uname', $orderBy);
                }
            «ENDIF»
            $qb->add('orderBy', $orderBy);

            return $qb;
        }
        «IF !sortRelationsIn.empty || !sortRelationsOut.empty»

            /**
             * Resolves a given order by field to the corresponding relationship expression.
             «IF !application.targets('3.0')»
             *
             * @param string $orderBy
             *
             * @return string
             «ENDIF»
             */
            protected function resolveOrderByForRelation(«IF application.targets('3.0')»string «ENDIF»$orderBy)«IF application.targets('3.0')»: string«ENDIF»
            {
                if (false !== mb_strpos($orderBy, ' ')) {
                    list($orderBy, $direction) = explode(' ', $orderBy, 2);
                } else {
                    $direction = 'ASC';
                }

                switch ($orderBy) {
                    «FOR relation : sortRelationsIn»
                        «relation.orderByExpression(false)»
                    «ENDFOR»
                    «FOR relation : sortRelationsOut»
                        «relation.orderByExpression(true)»
                    «ENDFOR»
                }

                return $orderBy . ' ' . $direction;
            }
        «ENDIF»
    '''

    def private orderByExpression(JoinRelationship it, Boolean useTarget) '''
        case '«getRelationAliasName(useTarget).formatForCode»':
            $orderBy = 'tbl«getRelationAliasName(useTarget).formatForCodeCapital».«(if (useTarget) target else source).orderByFieldNameForRelatedEntity»';
            break;
    '''

    def private orderByFieldNameForRelatedEntity(DataObject it) {
        if (it instanceof Entity) {
            for (patternPart : displayPatternParts) {
                /* check if patternPart equals a field name */
                var matchedFields = fields.filter[name == patternPart]
                if ((!matchedFields.empty || (geographical && (patternPart == 'latitude' || patternPart == 'longitude')))) {
                    return patternPart.formatForCode
                }
            }
        }

        'id'
    }

    def private getQueryFromBuilder(Entity it) '''
        /**
         * Retrieves Doctrine query from query builder.
         «IF !application.targets('3.0')»
         *
         * @param QueryBuilder $qb Query builder instance
         *
         * @return Query Query instance to be further processed
         «ENDIF»
         */
        public function getQueryFromBuilder(QueryBuilder $qb)«IF application.targets('3.0')»: Query«ENDIF»
        {
            $query = $qb->getQuery();
            «IF hasTranslatableFields»

                if (true === $this->translationsEnabled) {
                    // set the translation query hint
                    $query->setHint(Query::HINT_CUSTOM_OUTPUT_WALKER, TranslationWalker::class);
                }
            «ENDIF»
            «IF hasPessimisticReadLock»

                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»

            return $query;
        }
    '''

    def private sortingCriteria(DataObject it) '''
        «FOR field : getSortingFields»«field.sortingCriteria»«ENDFOR»
        «val relationsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]»
        «val relationsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]»
        «FOR relation : relationsIn»«relation.sortingCriteria(false)»«ENDFOR»
        «FOR relation : relationsOut»«relation.sortingCriteria(true)»«ENDFOR»
        «IF it instanceof Entity»
            «extensionSortingFields»
        «ENDIF»
    '''

    def private sortingCriteria(Field it) {
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

    def private sortingCriteria(JoinRelationship it, Boolean useTarget) '''
        '«getRelationAliasName(useTarget).formatForCode»',
    '''

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
