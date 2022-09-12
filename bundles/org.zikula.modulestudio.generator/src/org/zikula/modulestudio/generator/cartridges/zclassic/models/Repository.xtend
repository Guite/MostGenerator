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
import org.zikula.modulestudio.generator.application.ImportList

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
        fh = new FileHelper(it)
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
        val repositoryPath = 'Repository/'
        var fileSuffix = 'Repository'

        sortRelationsIn = incoming.filter(OneToManyRelationship).filter[bidirectional && source instanceof Entity]
        sortRelationsOut = outgoing.filter(OneToOneRelationship).filter[target instanceof Entity]

        var fileName = 'Base/Abstract' + name.formatForCodeCapital + fileSuffix + 'Interface.php'
        var content = if (!isInheriting || parentType instanceof MappedSuperClass) modelRepositoryInterfaceBaseImpl else modelChildRepositoryInterfaceBaseImpl
        fsa.generateFile(repositoryPath + fileName, content)

        fileName = 'Base/Abstract' + name.formatForCodeCapital + fileSuffix + '.php'
        content = if (!isInheriting || parentType instanceof MappedSuperClass) modelRepositoryBaseImpl else modelChildRepositoryBaseImpl
        fsa.generateFile(repositoryPath + fileName, content)

        if (!app.generateOnlyBaseClasses) {
            fileName = name.formatForCodeCapital + fileSuffix + 'Interface.php'
            fsa.generateFile(repositoryPath + fileName, modelRepositoryInterfaceImpl)

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

    def private modelRepositoryInterfaceBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Repository\Base;

        «collectBaseImports(true).print»

        /**
         * Repository interface for «name.formatForDisplay» entities.
         *
        «methodAnnotations»
         */
        interface Abstract«name.formatForCodeCapital»RepositoryInterface extends ObjectRepository
        {
            /**
             * Retrieves an array with all fields which can be used for sorting instances.
             *
             * @return string[] List of sorting field names
             */
            public function getAllowedSortingFields(): array;

            public function getDefaultSortingField(): string;

            public function setDefaultSortingField(string $defaultSortingField): self;

            public function getCollectionFilterHelper(): ?CollectionFilterHelper;

            public function setCollectionFilterHelper(?CollectionFilterHelper $collectionFilterHelper): self;
            «IF hasTranslatableFields»

                public function getTranslationsEnabled(): bool;

                public function setTranslationsEnabled(bool $translationsEnabled): self;
            «ENDIF»
            «new UserDeletion().generateInterface(it)»

            public function selectById(
                $id = 0,
                bool $useJoins = true,
                bool $slimMode = false
            ): ?«name.formatForCodeCapital»;

            public function selectByIdList(
                array $idList = [0],
                bool $useJoins = true,
                bool $slimMode = false
            ): ?array;
            «IF hasSluggableFields && slugUnique»

                public function selectBySlug(
                    string $slugTitle = '',
                    bool $useJoins = true,
                    bool $slimMode = false,
                    int $excludeId = 0
                ): ?«name.formatForCodeCapital»;
            «ENDIF»

            public function getListQueryBuilder(
                string $where = '',
                string $orderBy = '',
                bool $useJoins = true,
                bool $slimMode = false
            ): QueryBuilder;

            public function selectWhere(
                string $where = '',
                string $orderBy = '',
                bool $useJoins = true,
                bool $slimMode = false
            ): array;

            public function selectWherePaginated(
                string $where = '',
                string $orderBy = '',
                int $currentPage = 1,
                int $resultsPerPage = 25,
                bool $useJoins = true,
                bool $slimMode = false
            ): PaginatorInterface;

            public function selectSearch(
                string $fragment = '',
                array $exclude = [],
                string $orderBy = '',
                int $currentPage = 1,
                int $resultsPerPage = 25,
                bool $useJoins = true
            ): \Traversable;

            public function retrieveCollectionResult(
                QueryBuilder $qb,
                bool $isPaginated = false,
                int $currentPage = 1,
                int $resultsPerPage = 25
            ): PaginatorInterface|array;

            public function getCountQuery(string $where = '', bool $useJoins = false): QueryBuilder;

            public function selectCount(string $where = '', bool $useJoins = false, array $parameters = []): int;
            «new Tree().generateInterface(it, app)»

            public function detectUniqueState(string $fieldName, string $fieldValue, int $excludeId = 0): bool;

            public function genericBaseQuery(
                string $where = '',
                string $orderBy = '',
                bool $useJoins = true,
                bool $slimMode = false
            ): QueryBuilder;

            /**
             * Retrieves Doctrine query from query builder.
             */
            public function getQueryFromBuilder(QueryBuilder $qb): Query;
        }
    '''

    def private collectChildRepositoryInterfaceBaseImports(Entity it) {
        val imports = new ImportList
        imports.add(app.appNamespace + '\\Repository\\' + parentType.name.formatForCodeCapital + 'RepositoryInterface')
        if (!incoming.empty || !outgoing.empty) {
            imports.add('Doctrine\\ORM\\QueryBuilder')
        }
        imports
    }

    def private modelChildRepositoryInterfaceBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Repository\Base;

        «collectChildRepositoryInterfaceBaseImports.print»

        /**
         * Repository interface for «name.formatForDisplay» entities.
         */
        interface Abstract«name.formatForCodeCapital»RepositoryInterface extends «parentType.name.formatForCodeCapital»RepositoryInterface
        {
            // nothing additional
        }
    '''

    def private modelRepositoryBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Repository\Base;

        «collectBaseImports(false).print»

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «name.formatForDisplay» entities.
         *
        «methodAnnotations»
         */
        abstract class Abstract«name.formatForCodeCapital»Repository extends «IF tree != EntityTreeType.NONE»«tree.literal.toLowerCase.toFirstUpper»TreeRepository«ELSEIF hasSortableFields»SortableRepository«ELSE»ServiceEntityRepository«ENDIF» implements Abstract«name.formatForCodeCapital»RepositoryInterface«IF tree != EntityTreeType.NONE || hasSortableFields», ServiceEntityRepositoryInterface«ENDIF»
        {
            «IF tree != EntityTreeType.NONE || hasSortableFields»
                public function __construct(EntityManagerInterface $manager)
                {
                    parent::__construct($manager, $manager->getClassMetadata(«name.formatForCodeCapital»::class));
                }
            «ELSE»
                public function __construct(ManagerRegistry $registry)
                {
                    parent::__construct($registry, «name.formatForCodeCapital»::class);
                }
            «ENDIF»

            /**
             * The default sorting field/expression
             */
            protected string $defaultSortingField = '«getDefaultSortingField.name.formatForCode»';

            protected ?CollectionFilterHelper $collectionFilterHelper = null;
            «IF hasTranslatableFields»

                protected bool $translationsEnabled = true;
            «ENDIF»

            public function getAllowedSortingFields(): array
            {
                return [
                    «sortingCriteria»
                ];
            }
            «fh.getterAndSetterMethods(it, 'defaultSortingField', 'string', false, '', '')»
            «fh.getterAndSetterMethods(it, 'collectionFilterHelper', 'CollectionFilterHelper', true, '', '')»
            «IF hasTranslatableFields»
                «fh.getterAndSetterMethods(it, 'translationsEnabled', 'bool', false, '', '')»
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

    def private collectChildRepositoryBaseImports(Entity it) {
        val imports = new ImportList
        imports.add(app.appNamespace + '\\Repository\\' + parentType.name.formatForCodeCapital + 'Repository')
        if (!incoming.empty || !outgoing.empty) {
            imports.add('Doctrine\\ORM\\QueryBuilder')
        }
        imports
    }

    def private modelChildRepositoryBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Repository\Base;

        «collectChildRepositoryBaseImports.print»

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
            public function getAllowedSortingFields(): array
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

    def private canDirectlyExtendServiceRepo(Entity it) {
        tree == EntityTreeType.NONE && !hasSortableFields
    }

    def private collectBaseImports(Entity it, Boolean isInterface) {
        val imports = new ImportList
        imports.addAll(#[
            'InvalidArgumentException',
            'Psr\\Log\\LoggerInterface',
            'Zikula\\Bundle\\CoreBundle\\Doctrine\\Paginator',
            'Zikula\\Bundle\\CoreBundle\\Doctrine\\PaginatorInterface',
            'Zikula\\UsersBundle\\Api\\ApiInterface\\CurrentUserApiInterface',
            entityClassName('', false),
            app.appNamespace + '\\Helper\\CollectionFilterHelper'
        ])
        if (isInterface) {
            imports.addAll(#[
                'Doctrine\\ORM\\Query',
                'Doctrine\\ORM\\QueryBuilder',
                'Doctrine\\Persistence\\ObjectRepository'
            ])
        } else {
            imports.addAll(#[
                'Doctrine\\ORM\\Query',
                'Doctrine\\ORM\\QueryBuilder'
            ])
            if (canDirectlyExtendServiceRepo) {
                imports.addAll(#[
                    'Doctrine\\Bundle\\DoctrineBundle\\Repository\\ServiceEntityRepository',
                    'Doctrine\\Persistence\\ManagerRegistry'
                ])
            } else {
                imports.addAll(#[
                    'Doctrine\\Bundle\\DoctrineBundle\\Repository\\ServiceEntityRepositoryInterface',
                    'Doctrine\\ORM\\EntityManagerInterface'
                ])
            }
            if (hasPessimisticReadLock || hasPessimisticWriteLock) {
                imports.add('Doctrine\\DBAL\\LockMode')
            }
            if (tree == EntityTreeType.NONE && hasSortableFields) {
                imports.add('Gedmo\\Sortable\\Entity\\Repository\\SortableRepository')
            }
            if (tree != EntityTreeType.NONE) {
                imports.add('Gedmo\\Tree\\Entity\\Repository\\' + tree.literal.toLowerCase.toFirstUpper + 'TreeRepository')
            }
            if (hasTranslatableFields) {
                imports.add('Gedmo\\Translatable\\Query\\TreeWalker\\TranslationWalker')
            }
        }
        imports
    }

    def private methodAnnotations(Entity it) '''
        «' '»* @method «name.formatForCodeCapital»|null find($id, $lockMode = null, $lockVersion = null)
        «' '»* @method «name.formatForCodeCapital»[] findAll()
        «' '»* @method «name.formatForCodeCapital»[] findBy(array $criteria, ?array $orderBy = null, $limit = null, $offset = null)
        «' '»* @method «name.formatForCodeCapital»|null findOneBy(array $criteria, ?array $orderBy = null)
        «' '»* @method int count(array $criteria)
    '''

    def private selectById(Entity it) '''
        /**
         * Adds a list of identifier filters to given query builder.
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        protected function addIdListFilter(QueryBuilder $qb, array $idList): void
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
        }

        /**
         * Selects an object from the database.
         *
         * @param mixed $id The id (or array of ids) to use to retrieve the object (optional) (default=0)
         * @param bool $useJoins Whether to include joining related objects (optional) (default=true)
         * @param bool $slimMode If activated only some basic fields are selected without using any joins
         *                       (optional) (default=false)
         */
        public function selectById(
            $id = 0,
            bool $useJoins = true,
            bool $slimMode = false
        ): ?«name.formatForCodeCapital» {
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
         * @return array Retrieved «name.formatForCodeCapital» instances
         */
        public function selectByIdList(
            array $idList = [0],
            bool $useJoins = true,
            bool $slimMode = false
        ): ?array {
            $qb = $this->genericBaseQuery('', '', $useJoins, $slimMode);
            $this->addIdListFilter($qb, $idList);

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
        ): ?«name.formatForCodeCapital» {
            if ('' === $slugTitle) {
                throw new InvalidArgumentException('Invalid slug title received.');
            }

            $qb = $this->genericBaseQuery('', '', $useJoins, $slimMode);

            $qb->andWhere('tbl.slug = :slug')
               ->setParameter('slug', $slugTitle);

            if (0 < $excludeId) {
                $this->addExclusion($qb, [$excludeId]);
            }

            if (null !== $this->collectionFilterHelper) {
                $qb = $this->collectionFilterHelper->applyDefaultFilters('«name.formatForCode»', $qb);
            }

            $query = $this->getQueryFromBuilder($qb);

            $results = $query->getResult();

            return null !== $results && 0 < count($results) ? $results[0] : null;
        }
    '''

    def private addExclusion(Entity it) '''
        /**
         * Adds a filter excluding desired identifiers from selection.
         */
        protected function addExclusion(QueryBuilder $qb, array $exclusions = []): void
        {
            if (0 < count($exclusions)) {
                $qb->andWhere('tbl.«getPrimaryKey.name.formatForCode» NOT IN (:excludedIdentifiers)')
                   ->setParameter('excludedIdentifiers', $exclusions);
            }
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
                $this->addExclusion($qb, $exclude);
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
        ): PaginatorInterface|array {
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

            if (0 < $excludeId) {
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
                        [$orderByField, $direction] = explode(' ', $orderByField, 2);
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
            «IF (!matchedFields.empty)»
                $selection .= ', tbl.«patternPart.formatForCode»';
            «ENDIF»
        «ENDFOR»
    '''

    def private genericBaseQueryOrderBy(Entity it) '''
        /**
         * Adds ORDER BY clause to given query builder.
         */
        protected function genericBaseQueryAddOrderBy(QueryBuilder $qb, string $orderBy = ''): void
        {
            if ('RAND()' === $orderBy) {
                // random selection
                $qb->addSelect('MOD(tbl.«getPrimaryKey.name.formatForCode», ' . random_int(2, 15) . ') AS HIDDEN randomIdentifiers')
                   ->orderBy('randomIdentifiers');

                return;
            }

            if (empty($orderBy)) {
                $orderBy = $this->defaultSortingField;
            }

            if (empty($orderBy)) {
                return;
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

            return;
        }
        «IF !sortRelationsIn.empty || !sortRelationsOut.empty»

            /**
             * Resolves a given order by field to the corresponding relationship expression.
             */
            protected function resolveOrderByForRelation(string $orderBy): string
            {
                if (false !== mb_strpos($orderBy, ' ')) {
                    [$orderBy, $direction] = explode(' ', $orderBy, 2);
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
                if (!matchedFields.empty) {
                    return patternPart.formatForCode
                }
            }
        }

        'id'
    }

    def private getQueryFromBuilder(Entity it) '''
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
        «IF it instanceof Entity && (it as Entity).standardFields»«/* add two user fields which are rejected in getSortingFields otherwise */»
             'createdBy',
             'updatedBy',
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

    def private modelRepositoryInterfaceImpl(Entity it) '''
        namespace «app.appNamespace»\Repository;

        use «app.appNamespace»\Repository\Base\Abstract«name.formatForCodeCapital»RepositoryInterface;

        /**
         * Repository interface for «name.formatForDisplay» entities.
         */
        interface «name.formatForCodeCapital»RepositoryInterface extends Abstract«name.formatForCodeCapital»RepositoryInterface
        {
            // feel free to add your own interface methods
        }
    '''

    def private modelRepositoryImpl(Entity it) '''
        namespace «app.appNamespace»\Repository;

        use «app.appNamespace»\Repository\Base\Abstract«name.formatForCodeCapital»Repository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «name.formatForDisplay» entities.
         */
        class «name.formatForCodeCapital»Repository extends Abstract«name.formatForCodeCapital»Repository implements «name.formatForCodeCapital»RepositoryInterface
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
