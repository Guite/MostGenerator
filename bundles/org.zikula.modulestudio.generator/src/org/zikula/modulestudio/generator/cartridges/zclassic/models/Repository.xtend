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
            public function getAllowedSortingFields(): array
            {
                return [
                    «sortingCriteria»
                ];
            }
            «fh.getterAndSetterMethods(it, 'defaultSortingField', 'string', false, true, true, '', '')»
            «fh.getterAndSetterMethods(it, 'collectionFilterHelper', 'CollectionFilterHelper', false, true, true, '', '')»
            «IF hasTranslatableFields»
                «fh.getterAndSetterMethods(it, 'translationsEnabled', 'bool', false, true, true, '', '')»
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
        use Symfony\Contracts\Translation\TranslatorInterface;
        use Zikula\Bundle\CoreBundle\Doctrine\Paginator;
        use Zikula\Bundle\CoreBundle\Doctrine\PaginatorInterface;
        use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
        use «entityClassName('', false)»;
        use «app.appNamespace»\Helper\CollectionFilterHelper;

    '''

    def private selectById(Entity it) '''
        /**
         * Adds an array of id filters to given query instance.
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        protected function addIdListFilter(array $idList, QueryBuilder $qb): QueryBuilder
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
            bool $useJoins = true,
            bool $slimMode = false
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
            bool $useJoins = true,
            bool $slimMode = false
        ): ?array {
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
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function selectBySlug(
            string $slugTitle = '',
            bool $useJoins = true,
            bool $slimMode = false,
            int $excludeId = 0
        ): ?«name.formatForCodeCapital»Entity {
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
         */
        protected function addExclusion(QueryBuilder $qb, array $exclusions = []): QueryBuilder
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
         */
        public function getListQueryBuilder(
            string $where = '',
            string $orderBy = '',
            bool $useJoins = true,
            bool $slimMode = false
        ): QueryBuilder {
            $qb = $this->genericBaseQuery($where, $orderBy, $useJoins, $slimMode);
            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->addCommonViewFilters('«name.formatForCode»', $qb);
            }

            return $qb;
        }

        /**
         * Selects a list of objects with a given where clause.
         */
        public function selectWhere(
            string $where = '',
            string $orderBy = '',
            bool $useJoins = true,
            bool $slimMode = false
        ): array {
            $qb = $this->getListQueryBuilder($where, $orderBy, $useJoins, $slimMode);

            return $this->retrieveCollectionResult($qb);
        }
    '''

    def private selectWherePaginated(Entity it) '''
        /**
         * Selects a list of objects with a given where clause and pagination parameters.
         */
        public function selectWherePaginated(
            string $where = '',
            string $orderBy = '',
            int $currentPage = 1,
            int $resultsPerPage = 25,
            bool $useJoins = true,
            bool $slimMode = false
        ): PaginatorInterface {
            $qb = $this->getListQueryBuilder($where, $orderBy, $useJoins, $slimMode);

            return $this->retrieveCollectionResult($qb, true, $currentPage, $resultsPerPage);
        }
    '''

    def private selectSearch(Entity it) '''
        /**
         * Selects entities by a given search fragment.
         *
         * @return array Retrieved collection and (for paginated queries) the amount of total records affected
         */
        public function selectSearch(
            string $fragment = '',
            array $exclude = [],
            string $orderBy = '',
            int $currentPage = 1,
            int $resultsPerPage = 25,
            bool $useJoins = true
        ): \Traversable {
            $qb = $this->getListQueryBuilder('', $orderBy, $useJoins);
            if (0 < count($exclude)) {
                $qb = $this->addExclusion($qb, $exclude);
            }

            // $fragment is currently not used because getListQueryBuilder calls CollectionFilterHelper
            // which processes the search term given in the request automatically

            $paginator = $this->retrieveCollectionResult($qb, true, $currentPage, $resultsPerPage);

            return $paginator->getResults();
        }
    '''

    def private retrieveCollectionResult(Entity it) '''
        /**
         * Performs a given database selection and post-processed the results.
         *
         * @return PaginatorInterface|array Paginator (for paginated queries) or retrieved collection
         */
        public function retrieveCollectionResult(
            QueryBuilder $qb,
            bool $isPaginated = false,
            int $currentPage = 1,
            int $resultsPerPage = 25
        ) {
            if (!$isPaginated) {
                $query = $this->getQueryFromBuilder($qb);

                return $query->getResult();
            }

            return (new Paginator($qb, $resultsPerPage))->paginate($currentPage);
        }
    '''

    def private getCountQuery(Entity it) '''
        /**
         * Returns query builder instance for a count query.
         */
        public function getCountQuery(string $where = '', bool $useJoins = false): QueryBuilder
        {
            $selection = 'COUNT(tbl.«getPrimaryKey.name.formatForCode») AS num«nameMultiple.formatForCodeCapital»';

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from($this->_entityName, 'tbl');

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
         */
        public function selectCount(string $where = '', bool $useJoins = false, array $parameters = []): int
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
         */
        public function detectUniqueState(string $fieldName, string $fieldValue, int $excludeId = 0): bool
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
         */
        public function genericBaseQuery(
            string $where = '',
            string $orderBy = '',
            bool $useJoins = true,
            bool $slimMode = false
        ): QueryBuilder {
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
               ->from($this->_entityName, 'tbl');

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
         */
        protected function genericBaseQueryAddOrderBy(QueryBuilder $qb, string $orderBy = ''): QueryBuilder
        {
            if ('RAND()' === $orderBy) {
                // random selection
                $qb->addSelect('MOD(tbl.«getPrimaryKey.name.formatForCode», ' . random_int(2, 15) . ') AS HIDDEN randomIdentifiers')
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
             */
            protected function resolveOrderByForRelation(string $orderBy): string
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
         */
        public function getQueryFromBuilder(QueryBuilder $qb): Query
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
