package org.zikula.modulestudio.generator.cartridges.zclassic.models

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractIntegerField
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.CalculatedField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Joins
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.LinkTable
import org.zikula.modulestudio.generator.cartridges.zclassic.models.repository.Tree
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Repository {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    IFileSystemAccess fsa
    FileHelper fh = new FileHelper()
    Application app

    /**
     * Entry point for Doctrine repository classes.
     */

    def generate(Application it, IFileSystemAccess fsa) {
        this.fsa = fsa
        app = it
        getAllEntities.filter(e|!e.mappedSuperClass).forEach(e|e.generate)

        val linkTable = new LinkTable()
        for (relation : getJoinRelations.filter(typeof(ManyToManyRelationship))) linkTable.generate(relation, it, fsa)
    }

    /**
     * Creates a repository class file for every Entity instance.
     */
    def private generate(Entity it) {
        println('Generating repository classes for entity "' + name.formatForDisplay + '"')
        val repositoryPath = app.getAppSourceLibPath + 'Entity/Repository/'
        val repositoryFileName = name.formatForCodeCapital + '.php'
        if (!isInheriting) {
            fsa.generateFile(repositoryPath + 'Base/' + repositoryFileName, modelRepositoryBaseFile)
        }
        fsa.generateFile(repositoryPath + repositoryFileName, modelRepositoryFile)
    }

    def private modelRepositoryBaseFile(Entity it) '''
        «fh.phpFileHeader(app)»
        «modelRepositoryBaseImpl»
    '''

    def private modelRepositoryFile(Entity it) '''
        «fh.phpFileHeader(app)»
        «modelRepositoryImpl»
    '''

    def private modelRepositoryBaseImpl(Entity it) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appName»\Entity\Repository\Base;

        «ENDIF»
        «IF tree != EntityTreeType::NONE»
            use Gedmo\Tree\Entity\Repository\«tree.asConstant.toFirstUpper»TreeRepository;
        «ELSE»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»
        use Doctrine\ORM\Query;
        use Doctrine\ORM\QueryBuilder;
        «IF hasOptimisticLock || hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
        «ENDIF»

        use DoctrineExtensions\Paginate\Paginate;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Repository_Base_«name.formatForCodeCapital» extends «IF tree != EntityTreeType::NONE»«tree.asConstant.toFirstUpper»TreeRepository«ELSE»EntityRepository«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital» extends \«IF tree != EntityTreeType::NONE»«tree.asConstant.toFirstUpper»TreeRepository«ELSE»EntityRepository«ENDIF»
        «ENDIF»
        {
            /**
             * @var string The default sorting field/expression.
             */
            protected $defaultSortingField = '«(if (hasSortableFields) getSortableFields.head else getLeadingField).name.formatForCode»';

            /**
             * Retrieves an array with all fields which can be used for sorting instances.
             *
             * @return array
             */
            public function getAllowedSortingFields()
            {
                return array(
                    «FOR field : fields»«field.singleSortingField»«ENDFOR»
                    «extensionSortingFields»
                );
            }

            «fh.getterAndSetterMethods(it, 'defaultSortingField', 'string', false, false, '', '')»

            /**
             * Returns name of the field used as title / name for entities of this repository.
             *
             * @return string Name of field to be used as title.
             */
            public function getTitleFieldName()
            {
                «val leadingField = getLeadingField»
                $fieldName = '«IF leadingField != null»«leadingField.name.formatForCode»«ENDIF»';

                return $fieldName;
            }

            /**
             * Returns name of the field used for describing entities of this repository.
             *
             * @return string Name of field to be used as description.
             */
            public function getDescriptionFieldName()
           {
                «val textFields = fields.filter(typeof(TextField)).filter(e|!e.leading)»
                «val stringFields = fields.filter(typeof(StringField)).filter(e|!e.leading && !e.password)»
                «IF !textFields.isEmpty»
                    $fieldName = '«textFields.head.name.formatForCode»';
                «ELSEIF !stringFields.isEmpty»
                    $fieldName = '«stringFields.head.name.formatForCode»';
                «ELSE»
                    $fieldName = '';
                «ENDIF»

                return $fieldName;
            }

            /**
             * Returns name of the first upload field which is capable for handling images.
             *
             * @return string Name of field to be used for preview images.
             */
            public function getPreviewFieldName()
            {
                $fieldName = '«IF hasImageFieldsEntity»«getImageFieldsEntity.head.name.formatForCode»«ENDIF»';

                return $fieldName;
            }

            /**
             * Returns name of the the date(time) field to be used for representing the start
             * of this object. Used for providing meta data to the tag module.
             *
             * @return string Name of field to be used as date.
             */
            public function getStartDateFieldName()
            {
                $fieldName = '«IF getStartDateField != null»«getStartDateField.name.formatForCode»«ELSEIF standardFields»createdDate«ENDIF»';

                return $fieldName;
            }

            «getAdditionalTemplateParameters»

            «truncateTable»
            «IF standardFields || hasUserFieldsEntity»

                «userDeleteFunctions»
            «ENDIF»

            «selectById»
            «IF hasSluggableFields && slugUnique»

                «selectBySlug»
            «ENDIF»

            «addExclusion»

            «selectWhere»

            «selectWherePaginated»

            «selectSearch»
            «IF !getUniqueDerivedFields.isEmpty»

                «selectCount»
            «ENDIF»

            «new Tree().generate(it, app)»

            «detectUniqueState»

            «intBaseQuery»

            «intBaseQueryWhere»

            «intBaseQueryOrderBy»

            «IF !hasCompositeKeys»«/* id list shuffling is not supported for composite keys yet */»
                «getIdentifierListForRandomSorting»

            «ENDIF»
            «intGetQueryFromBuilder»

            «new Joins().generate(it, app)»
            «IF hasArchive && getEndDateField != null»

                «archiveObjects(it)»
            «ENDIF»
        }
    '''

    def private getAdditionalTemplateParameters(Entity it) '''
        /**
         * Returns an array of additional template variables which are specific to the object type treated by this repository.
         *
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
         * @param array  $args    Additional arguments.
         *
         * @return array List of template variables to be assigned.
         */
        public function getAdditionalTemplateParameters($context = '', $args = array())
        {
            if (!in_array($context, array('controllerAction', 'api', 'actionHandler', 'block', 'contentType'))) {
                $context = 'controllerAction';
            }

            $templateParameters = array();

            if ($context == 'controllerAction') {
                if (!isset($args['action'])) {
                    $args['action'] = FormUtil::getPassedValue('func', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'GETPOST');
                }
                if (in_array($args['action'], array('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'view'))) {
                    $templateParameters = $this->getViewQuickNavParameters($context, $args);
                    «IF hasListFieldsEntity»
                        $serviceManager = ServiceUtil::getManager();
                        $listHelper = new «container.application.appName»«IF app.targets('1.3.5')»_Util_«ELSE»\Util\«ENDIF»ListEntries($serviceManager);
                        «FOR field : getListFieldsEntity»
                            «var fieldName = field.name.formatForCode»
                            $templateParameters['«fieldName»Items'] = $listHelper->getEntries('«name.formatForCode»', '«fieldName»');
                        «ENDFOR»
                    «ENDIF»
                    «IF hasBooleanFieldsEntity»
                        $booleanSelectorItems = array(
                            array('value' => 'no', 'text' => __('No')),
                            array('value' => 'yes', 'text' => __('Yes'))
                        );
                        «FOR field : getBooleanFieldsEntity»
                            «val fieldName = field.name.formatForCode»
                            $templateParameters['«fieldName»Items'] = $booleanSelectorItems;
                        «ENDFOR»
                    «ENDIF»
                }

                // initialise Imagine preset manager instances
                $imageHelper = new «container.application.appName»«IF app.targets('1.3.5')»_Util_«ELSE»\Util\«ENDIF»Image(ServiceUtil::getManager());
                «IF hasUploadFieldsEntity»

                    $objectType = '«name.formatForCode»';
                    «FOR uploadField : getUploadFieldsEntity»
                        $parameters[$objectType . 'ThumbManager«uploadField.name.formatForCodeCapital»'] = $imageHelper->getManager($objectType, '«uploadField.name.formatForCode»', $context, $args);
                    «ENDFOR»
                «ENDIF»
                if (in_array($args['action'], array('display', 'view'))) {
                    // use seperate preset for images in related items
                    $parameters['relationThumbPreset'] = $imageHelper->getPreset('', '', '«container.application.appName»_relateditem', $context, $args);
                }
            }

            // in the concrete child class you could do something like
            // $parameters = parent::getAdditionalTemplateParameters($context, $args);
            // $parameters['myvar'] = 'myvalue';
            // return $parameters;

            return $templateParameters;
        }

        /**
         * Returns an array of additional template variables for view quick navigation forms.
         *
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType).
         * @param array  $args    Additional arguments.
         *
         * @return array List of template variables to be assigned.
         */
        protected function getViewQuickNavParameters($context = '', $args = array())
        {
            if (!in_array($context, array('controllerAction', 'api', 'actionHandler', 'block', 'contentType'))) {
                $context = 'controllerAction';
            }

            $parameters = array();
            «IF categorisable»
                $parameters['catIdList'] = ModUtil::apiFunc('«container.application.appName»', 'category', 'retrieveCategoriesFromRequest', array('ot' => '«name.formatForCode»', 'source' => 'GET'));
            «ENDIF»
            «IF !getBidirectionalIncomingJoinRelationsWithOneSource.isEmpty»
                «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                    «val sourceAliasName = relation.getRelationAliasName(false)»
                    $parameters['«sourceAliasName»'] = FormUtil::getPassedValue('«sourceAliasName»', 0, 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasListFieldsEntity»
                «FOR field : getListFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = FormUtil::getPassedValue('«fieldName»', '', 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR field : getUserFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = (int) FormUtil::getPassedValue('«fieldName»', 0, 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasCountryFieldsEntity»
                «FOR field : getCountryFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = FormUtil::getPassedValue('«fieldName»', '', 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «FOR field : getLanguageFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = FormUtil::getPassedValue('«fieldName»', '', 'GET');
                «ENDFOR»
            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                $parameters['searchterm'] = FormUtil::getPassedValue('searchterm', '', 'GET');
            «ENDIF»
            «/* not needed as already handled in the controller $pageSize = ModUtil::getVar('«container.application.appName»', 'pageSize', 10);
            $parameters['pageSize'] = (int) FormUtil::getPassedValue('pageSize', $pageSize, 'GET');*/»
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = FormUtil::getPassedValue('«fieldName»', '', 'GET');
                «ENDFOR»
            «ENDIF»

            // in the concrete child class you could do something like
            // $parameters = parent::getViewQuickNavParameters($context, $args);
            // $parameters['myvar'] = 'myvalue';
            // return $parameters;

            return $parameters;
        }
    '''

    def private truncateTable(Entity it) '''
        /**
         * Helper method for truncating the table.
         * Used during installation when inserting default data.
         *
         * @return void
         */
        public function truncateTable()
        {
            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«entityClassName('', false)»', 'tbl');
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }
    '''

    def private userDeleteFunctions(Entity it) '''
        «IF standardFields»
        /**
         * Deletes all objects created by a certain user.
         *
         * @param integer $userId The userid of the creator to be removed.
         *
         * @return void
         */
        public function deleteCreator($userId)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«entityClassName('', false)»', 'tbl')
               ->where('tbl.createdUserId = :creator')
               ->setParameter('creator', DataUtil::formatForStore($userId));
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }

        /**
         * Deletes all objects updated by a certain user.
         *
         * @param integer $userId The userid of the last editor to be removed.
         *
         * @return void
         */
        public function deleteLastEditor($userId)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«entityClassName('', false)»', 'tbl')
               ->where('tbl.updatedUserId = :editor')
               ->setParameter('editor', DataUtil::formatForStore($userId));
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }

        /**
         * Updates the creator of all objects created by a certain user.
         *
         * @param integer $userId    The userid of the creator to be replaced.
         * @param integer $newUserId The new userid of the creator as replacement.
         *
         * @return void
         */
        public function updateCreator($userId, $newUserId)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«entityClassName('', false)»', 'tbl')
               ->set('tbl.createdUserId', $newUserId)
               ->where('tbl.createdUserId = :creator')
               ->setParameter('creator', DataUtil::formatForStore($userId));
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }

        /**
         * Updates the last editor of all objects updated by a certain user.
         *
         * @param integer $userId    The userid of the last editor to be replaced.
         * @param integer $newUserId The new userid of the last editor as replacement.
         *
         * @return void
         */
        public function updateLastEditor($userId, $newUserId)
        {
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«entityClassName('', false)»', 'tbl')
               ->set('tbl.updatedUserId', $newUserId)
               ->where('tbl.updatedUserId = :editor')
               ->setParameter('editor', DataUtil::formatForStore($userId));
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }
        «ENDIF»
        «IF hasUserFieldsEntity»
        «IF standardFields»

        «ENDIF»
        /**
         * Updates a user field value of all objects affected by a certain user.
         *
         * @param string  $fieldName The name of the user field.
         * @param integer $userId    The userid to be replaced.
         * @param integer $newUserId The new userid as replacement.
         *
         * @return void
         */
        public function updateUserField($userFieldName, $userId, $newUserId)
        {
            // check field parameter
            if (empty($userFieldName) || !in_array($userFieldName, array(«FOR field : getUserFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»))) {
                return LogUtil::registerArgsError();
            }
            // check id parameter
            if ($userId == 0 || !is_numeric($userId)
             || $newUserId == 0 || !is_numeric($newUserId)) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->update('«entityClassName('', false)»', 'tbl')
               ->set('tbl.' . $userFieldName, $newUserId)
               ->where('tbl.' . $userFieldName . ' = :user')
               ->setParameter('user', DataUtil::formatForStore($userId));
            $query = $qb->getQuery();
            «IF hasPessimisticWriteLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $query->execute();
        }
        «ENDIF»
    '''

    def private selectById(Entity it) '''
        /**
         * Adds id filters to given query instance.
         *
         * @param mixed                     $id The id (or array of ids) to use to retrieve the object.
         * @param Doctrine\ORM\QueryBuilder $qb Query builder to be enhanced.
         *
         * @return Doctrine\ORM\QueryBuilder Enriched query builder instance.
         */
        protected function addIdFilter($id, Doctrine\ORM\QueryBuilder $qb)
        {
            if (is_array($id)) {
                foreach ($id as $fieldName => $fieldValue) {
                    $qb->andWhere('tbl.' . $fieldName . ' = :' . $fieldName)
                       ->setParameter($fieldName, DataUtil::formatForStore($fieldValue));
                }
            } else {
                $qb->andWhere('tbl.«getFirstPrimaryKey.name.formatForCode» = :id')
                   ->setParameter('id', DataUtil::formatForStore($id));
            }
            return $qb;
        }

        /**
         * Selects an object from the database.
         *
         * @param mixed   $id       The id (or array of ids) to use to retrieve the object (optional) (default=0).
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false).
         *
         * @return array|«entityClassName('', false)» retrieved data array or «entityClassName('', false)» instance
         */
        public function selectById($id = 0, $useJoins = true, $slimMode = false)
        {
            // check id parameter
            if ($id == 0) {
                return LogUtil::registerArgsError();
            }

            $qb = $this->_intBaseQuery('', '', $useJoins, $slimMode);

            $qb = $this->addIdFilter($id, $qb);

            $query = $this->getQueryFromBuilder($qb);

            $results = $query->getResult();//OneOrNullResult();
            return (count($results) > 0) ? $results[0] : null;
        }
    '''

    def private selectBySlug(Entity it) '''
        /**
         * Selects an object by slug field.
         *
         * @param string  $slugTitle The slug value
         * @param boolean $useJoins  Whether to include joining related objects (optional) (default=true).
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false).
         * @param integer $excludeId Optional id to be excluded (used for unique validation).
         *
         * @return «entityClassName('', false)» retrieved instance of «entityClassName('', false)»
         */
        public function selectBySlug($slugTitle = '', $useJoins = true, $slimMode = false, $excludeId = 0)
        {
            // check input parameter
            if ($slugTitle == '') {
                return LogUtil::registerArgsError();
            }

            $qb = $this->_intBaseQuery('', '', $useJoins, $slimMode);

            $qb->andWhere('tbl.slug = :slug')
               ->setParameter('slug', DataUtil::formatForStore($slugTitle));

            $qb = $this->addExclusion($qb, $excludeId);

            $query = $this->getQueryFromBuilder($qb);

            $results = $query->getResult();//OneOrNullResult();
            return (count($results) > 0) ? $results[0] : null;
        }
    '''

    def private addExclusion(Entity it) '''
        /**
         * Adds where clauses excluding desired identifiers from selection.
         *
         * @param Doctrine\ORM\QueryBuilder $qb        Query builder to be enhanced.
         * @param «IF hasCompositeKeys»mixed  «ELSE»integer«ENDIF»                   $excludeId The id (or array of ids) to be excluded from selection.
         *
         * @return Doctrine\ORM\QueryBuilder Enriched query builder instance.
         */
        protected function addExclusion(Doctrine\ORM\QueryBuilder $qb, $excludeId)
        {
            «IF hasCompositeKeys»
                if (is_array($excludeId)) {
                    foreach ($id as $fieldName => $fieldValue) {
                        $qb->andWhere('tbl.' . $fieldName . ' != :' . $fieldName)
                           ->setParameter($fieldName, DataUtil::formatForStore($fieldValue));
                    }
                } elseif ($excludeId > 0) {
            «ELSE»
                if ($excludeId > 0) {
            «ENDIF»
                $qb->andWhere('tbl.id != :excludeId')
                   ->setParameter('excludeId', DataUtil::formatForStore($excludeId));
            }
            return $qb;
        }
    '''

    def private selectWhere(Entity it) '''
        /**
         * Selects a list of objects with a given where clause.
         *
         * @param string  $where    The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default='').
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false).
         *
         * @return ArrayCollection collection containing retrieved «entityClassName('', false)» instances
         */
        public function selectWhere($where = '', $orderBy = '', $useJoins = true, $slimMode = false)
        {
            $qb = $this->_intBaseQuery($where, $orderBy, $useJoins, $slimMode);
            $qb = $this->addCommonViewFilters($qb);

            $query = $this->getQueryFromBuilder($qb);

            return $query->getResult();
        }
    '''

    def private selectWherePaginated(Entity it) '''
        /**
         * Returns query builder instance for retrieving a list of objects with a given where clause and pagination parameters.
         *
         * @param Doctrine\ORM\QueryBuilder $qb             Query builder to be enhanced.
         * @param integer                   $currentPage    Where to start selection
         * @param integer                   $resultsPerPage Amount of items to select
         *
         * @return array Created query instance and amount of affected items.
         */
        protected function getSelectWherePaginatedQuery(Doctrine\ORM\QueryBuilder $qb, $currentPage = 1, $resultsPerPage = 25)
        {
            $qb = $this->addCommonViewFilters($qb);

            $query = $this->getQueryFromBuilder($qb);
            $offset = ($currentPage-1) * $resultsPerPage;

            // count the total number of affected items
            $count = Paginate::getTotalQueryResults($query);

            «IF !(outgoing.filter(typeof(JoinRelationship)).isEmpty && incoming.filter(typeof(JoinRelationship)).isEmpty)»
                // prefetch unique relationship ids for given pagination frame
                $query = Paginate::getPaginateQuery($query, $offset, $resultsPerPage);
            «ELSE»
                $query->setFirstResult($offset)
                      ->setMaxResults($resultsPerPage);
            «ENDIF»
            return array($query, $count);
        }

        /**
         * Selects a list of objects with a given where clause and pagination parameters.
         *
         * @param string  $where          The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='').
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true).
         *
         * @return Array with retrieved collection and amount of total records affected by this query.
         */
        public function selectWherePaginated($where = '', $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)
        {
            $qb = $this->_intBaseQuery($where, $orderBy, $useJoins);
            list($query, $count) = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);

            $result = $query->getResult();

            return array($result, $count);
        }

        /**
         * Adds quick navigation related filter options as where clauses.
         *
         * @param Doctrine\ORM\QueryBuilder $qb Query builder to be enhanced.
         *
         * @return Doctrine\ORM\QueryBuilder Enriched query builder instance.
         */
        protected function addCommonViewFilters(Doctrine\ORM\QueryBuilder $qb)
        {
            $currentFunc = FormUtil::getPassedValue('func', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'GETPOST');
            if ($currentFunc != 'view' && $currentFunc != 'finder') {
                return $qb;
            }

            $parameters = $this->getViewQuickNavParameters('', array());
            foreach ($parameters as $k => $v) {
                if ($k == 'catId') {
                    // single category filter
                    if ($v > 0) {
                        $qb->andWhere('tblCategories.category = :category')
                           ->setParameter('category', DataUtil::formatForStore($v));
                    }
                } elseif ($k == 'catIdList') {
                    // multi category filter
                    /* old
                    $qb->andWhereIn('tblCategories.category IN (:categories)')
                       ->setParameter('categories', DataUtil::formatForStore($v));
                     */
                    $categoryFiltersPerRegistry = ModUtil::apiFunc('«container.application.appName»', 'category', 'buildFilterClauses', array('ot' => '«name.formatForDisplay»', 'catids' => $v));
                    if (count($categoryFiltersPerRegistry) > 0) {
                        $qb->andWhere('(' . implode(' OR ', $categoryFiltersPerRegistry) . ')');
                    }
                } elseif ($k == 'searchterm') {
                    // quick search
                    if (!empty($v)) {
                        $qb = $this->addSearchFilter($qb, $v);
                    }
                «IF hasBooleanFieldsEntity»
                } elseif (in_array($k, array(«FOR field : getBooleanFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»))) {
                    // boolean filter
                    if ($v == 'no') {
                        $qb->andWhere('tbl.' . $k . ' = 0');
                    } elseif ($v == 'yes' || $v == '1') {
                        $qb->andWhere('tbl.' . $k . ' = 1');
                    }
                «ENDIF»
                } else {
                    // field filter
                    if ($v != '' || (is_numeric($v) && $v > 0)) {
                        if ($k == 'workflowState' && substr($v, 0, 1) == '!') {
                            $qb->andWhere('tbl.' . $k . ' != :' . $k)
                               ->setParameter($k, DataUtil::formatForStore(substr($v, 1, strlen($v)-1)));
                        } else {
                            $qb->andWhere('tbl.' . $k . ' = :' . $k)
                               ->setParameter($k, DataUtil::formatForStore($v));
                       }
                    }
                }
            }

            // apply default filters
            $currentType = FormUtil::getPassedValue('type', 'user', 'GETPOST');
            if ($currentType != 'admin') {
                if (!in_array('workflowState', array_keys($parameters))) {
                    $qb->andWhere('tbl.workflowState = :onlineState')
                       ->setParameter('onlineState', 'approved');
                }
                «applyDefaultDateRangeFilter»
            }

            return $qb;
        }
    '''

    def private applyDefaultDateRangeFilter(Entity it) '''
        «val startDateField = getStartDateField»
        «val endDateField = getEndDateField»
        «IF startDateField != null»
            $startDate = FormUtil::getPassedValue('«startDateField.name.formatForCode»', «startDateField.defaultValueForNow», 'GET');
            $qb->andWhere('«whereClauseForDateRangeFilter('>=', startDateField, 'startDate')»')
               ->setParameter('startDate', $startDate);
        «ENDIF»
        «IF endDateField != null»
            $endDate = FormUtil::getPassedValue('«endDateField.name.formatForCode»', «endDateField.defaultValueForNow», 'GET');
            $qb->andWhere('«whereClauseForDateRangeFilter('<=', endDateField, 'endDate')»')
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
         * @param string  $fragment       The fragment to search for.
         * @param array   $exclude        Comma separated list with ids to be excluded from search.
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='').
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true).
         *
         * @return Array with retrieved collection and amount of total records affected by this query.
         */
        public function selectSearch($fragment = '', $exclude = array(), $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)
        {
            $qb = $this->_intBaseQuery('', $orderBy, $useJoins);
            if (count($exclude) > 0) {
                $exclude = implode(', ', $exclude);
                $qb->andWhere('tbl.«getFirstPrimaryKey.name.formatForCode» NOT IN (:excludeList)')«/* TODO fix composite keys */»
                   ->setParameter('excludeList', DataUtil::formatForStore($exclude));
            }

            $qb = $this->addSearchFilter($qb, $fragment);

            list($query, $count) = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);

            $result = $query->getResult();

            return array($result, $count);
        }

        /**
         * Adds where clause for search query.
         *
         * @param Doctrine\ORM\QueryBuilder $qb       Query builder to be enhanced.
         * @param string                    $fragment The fragment to search for.
         *
         * @return Doctrine\ORM\QueryBuilder Enriched query builder instance.
         */
        protected function addSearchFilter(Doctrine\ORM\QueryBuilder $qb, $fragment = '')
        {
            if ($fragment == '') {
                return $qb;
            }

            $fragment = DataUtil::formatForStore($fragment);
            $fragmentIsNumeric = is_numeric($fragment);

            «val searchFields = getDisplayFields.filter(e|e.isContainedInTextualSearch)»
            «val searchFieldsNumeric = getDisplayFields.filter(e|e.isContainedInNumericSearch)»
            $where = '';
            if (!$fragmentIsNumeric) {
            «FOR field : searchFields»
                $where .= ((!empty($where)) ? ' OR ' : '');
                $where .= 'tbl.«field.name.formatForCode» «IF field.isTextSearch»LIKE \'%' . $fragment . '%\''«ELSE»= \'' . $fragment . '\''«ENDIF»;
            «ENDFOR»
            } else {
            «FOR field : searchFieldsNumeric»
                $where .= ((!empty($where)) ? ' OR ' : '');
                $where .= 'tbl.«field.name.formatForCode» «IF field.isTextSearch»LIKE \'%' . $fragment . '%\''«ELSE»= \'' . $fragment . '\''«ENDIF»;
            «ENDFOR»
            }
            $where = '(' . $where . ')';

            $qb->andWhere($where);

            return $qb;
        }
    '''

    def private selectCount(Entity it) '''
        /**
         * Returns query builder instance for a count query.
         *
         * @param string  $where    The where clause to use when retrieving the object count (optional) (default='').
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return Doctrine\ORM\QueryBuilder Created query builder instance.
         * @TODO fix usage of joins; please remove the first line and test.
         */
        protected function getCountQuery($where = '', $useJoins = true)
        {
            $useJoins = false;

            $selection = 'COUNT(tbl.«getFirstPrimaryKey.name.formatForCode») AS num«nameMultiple.formatForCodeCapital»';
            if ($useJoins === true) {
                $selection .= $this->addJoinsToSelection();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from('«entityClassName('', false)»', 'tbl');

            if ($useJoins === true) {
                $this->addJoinsToFrom($qb);
            }

            if (!empty($where)) {
                $qb->where($where);
            }

            return $qb;
        }

        /**
         * Selects entity count with a given where clause.
         *
         * @param string  $where    The where clause to use when retrieving the object count (optional) (default='').
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         *
         * @return integer amount of affected records
         */
        public function selectCount($where = '', $useJoins = true)
        {
            $qb = $this->getCountQuery($where, $useJoins);
            $query = $qb->getQuery();
            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            return $query->getSingleScalarResult();
        }
    '''

    def private detectUniqueState(Entity it) '''
        /**
         * Checks for unique values.
         *
         * @param string $fieldName  The name of the property to be checked
         * @param string $fieldValue The value of the property to be checked
         * @param int    $excludeId  Id of «nameMultiple.formatForDisplay» to exclude (optional).
         *
         * @return boolean result of this check, true if the given «name.formatForDisplay» does not already exist
         */
        public function detectUniqueState($fieldName, $fieldValue, $excludeId = 0)
        {
            $qb = $this->getCountQuery('', false);
            $qb->andWhere('tbl.' . $fieldName . ' = :' . $fieldName)
               ->setParameter($fieldName, DataUtil::formatForStore($fieldValue));

            $qb = $this->addExclusion($qb, $excludeId);

            $query = $qb->getQuery();

            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»
            $count = $query->getSingleScalarResult();

            return ($count == 0);
        }
    '''

    def private intBaseQuery(Entity it) '''
        /**
         * Builds a generic Doctrine query supporting WHERE and ORDER BY.
         *
         * @param string  $where    The where clause to use when retrieving the collection (optional) (default='').
         * @param string  $orderBy  The order-by clause to use when retrieving the collection (optional) (default='').
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true).
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false).
         *
         * @return Doctrine\ORM\QueryBuilder query builder instance to be further processed
         */
        protected function _intBaseQuery($where = '', $orderBy = '', $useJoins = true, $slimMode = false)
        {
            // normally we select the whole table
            $selection = 'tbl';

            if ($slimMode === true) {
                // but for the slim version we select only the basic fields, and no joins

                $titleField = $this->getTitleFieldName();
                $selection = '«FOR pkField : getPrimaryKeyFields SEPARATOR ', '»tbl.«pkField.name.formatForCode»«ENDFOR»';
                if ($titleField != '') {
                    $selection .= ', tbl.' . $titleField;
                }
                «IF hasSluggableFields»
                    $selection .= ', tbl.slug';
                «ENDIF»
                $useJoins = false;
            }

            if ($useJoins === true) {
                $selection .= $this->addJoinsToSelection();
            }

            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->select($selection)
               ->from('«entityClassName('', false)»', 'tbl');

            if ($useJoins === true) {
                $this->addJoinsToFrom($qb);
            }

            $this->_intBaseQueryAddWhere($qb, $where);
            $this->_intBaseQueryAddOrderBy($qb, $orderBy);

            return $qb;
        }
    '''

    def private intBaseQueryWhere(Entity it) '''
        /**
         * Adds WHERE clause to given query builder.
         *
         * @param Doctrine\ORM\QueryBuilder $qb    Given query builder instance.
         * @param string                    $where The where clause to use when retrieving the collection (optional) (default='').
         *
         * @return Doctrine\ORM\QueryBuilder query builder instance to be further processed
         */
        protected function _intBaseQueryAddWhere(QueryBuilder $qb, $where = '')
        {
            if (!empty($where)) {
                $qb->where($where);
            }
            «IF standardFields»

                $onlyOwn = (int) FormUtil::getPassedValue('own', 0, 'GETPOST');
                if ($onlyOwn == 1) {
                    $uid = UserUtil::getVar('uid');
                    $qb->andWhere('tbl.createdUserId = :creator')
                       ->setParameter('creator', DataUtil::formatForStore($uid));
                }
            «ENDIF»

            return $qb;
        }
    '''

    def private intBaseQueryOrderBy(Entity it) '''
        /**
         * Adds ORDER BY clause to given query builder.
         *
         * @param Doctrine\ORM\QueryBuilder $qb      Given query builder instance.
         * @param string                    $orderBy The order-by clause to use when retrieving the collection (optional) (default='').
         *
         * @return Doctrine\ORM\QueryBuilder query builder instance to be further processed
         */
        protected function _intBaseQueryAddOrderBy(QueryBuilder $qb, $orderBy = '')
        {
            if ($orderBy == 'RAND()') {
                // random selection
                «IF hasCompositeKeys»
                    // not supported for composite keys yet
                «ELSE»
                    $idValues = $this->getIdentifierListForRandomSorting();
                    $qb->andWhere('tbl.«getFirstPrimaryKey.name.formatForCode» IN (:idValues)')
                       ->setParameter('idValues', DataUtil::formatForStore($idValues));
                «ENDIF»

                // no specific ordering in the main query for random items
                $orderBy = '';
            }

            // add order by clause
            if (!empty($orderBy)) {
                if (strpos($orderBy, '.') === false) {
                    $orderBy = 'tbl.' . $orderBy;
                }
                $qb->add('orderBy', $orderBy);
            }

            return $qb;
        }
    '''

    def private getIdentifierListForRandomSorting(Entity it) '''
        /**
         * Retrieves a random list of identifiers.
         *
         * @return array Collected identifiers.
         */
        protected function getIdentifierListForRandomSorting()
        {
            $idList = array();

            // query all primary keys in slim mode without any joins
            $allEntities = $this->selectWhere('', '', false, true);

            if (!$allEntities || !is_array($allEntities) || !count($allEntities)) {
                return $idList;
            }

            foreach ($allEntities as $entity) {
                $idList[] = $entity['«getFirstPrimaryKey.name.formatForCode»'];
            }

            // shuffle the id array
            shuffle($idList);

            return $idList;
        }
    '''

    def private intGetQueryFromBuilder(Entity it) '''
        /**
         * Retrieves Doctrine query from query builder, applying FilterUtil and other common actions.
         *
         * @param Doctrine\ORM\QueryBuilder $qb Query builder instance
         *
         * @return Doctrine\ORM\Query query instance to be further processed
         */
        protected function getQueryFromBuilder(Doctrine\ORM\QueryBuilder $qb)
        {
            $query = $qb->getQuery();

            // TODO - see https://github.com/zikula/core/issues/118
            // use FilterUtil to support generic filtering
            //$fu = new FilterUtil('«container.application.appName»', $this);

            // you could set explicit filters at this point, something like
            // $fu->setFilter('type:eq:' . $args['type'] . ',id:eq:' . $args['id']);
            // supported operators: eq, ne, like, lt, le, gt, ge, null, notnull

            // process request input filters and add them to the query.
            //$fu->enrichQuery($query);

            «IF hasTranslatableFields»
                // set the translation query hint
                $query->setHint(
                    \Doctrine\ORM\Query::HINT_CUSTOM_OUTPUT_WALKER,
                    'Gedmo\\Translatable\\Query\\TreeWalker\\TranslationWalker'
                );

            «ENDIF»
            «IF hasPessimisticReadLock»
                $query->setLockMode(LockMode::«lockType.asConstant»);
            «ENDIF»

            return $query;
        }
    '''

    def private singleSortingField(EntityField it) {
        switch it {
            DerivedField : {
                val joins = entity.incoming.filter(typeof(JoinRelationship)).filter(e|formatForDB(e.getSourceFields.head) == name.formatForDB)
                if (!joins.isEmpty) '''
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

    def private isContainedInTextualSearch(DerivedField it) {
        switch it {
            BooleanField: false
            AbstractIntegerField: false
            DecimalField: false
            FloatField: false
            ArrayField: false
            ObjectField: false
            default: true
        }
    }

    def private isContainedInNumericSearch(DerivedField it) {
        switch it {
            AbstractIntegerField: true
            DecimalField: true
            FloatField: true
            default: isContainedInTextualSearch(it)
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
             'createdUserId',
             'updatedUserId',
             'createdDate',
             'updatedDate',
        «ENDIF»
    '''

    def private archiveObjects(Entity it) '''
        /**
         * Update for «nameMultiple.formatForDisplay» becoming archived.
         *
         * @return bool If everything went right or not.
         */
        public function archiveObjects()
        {
            «val endField = getEndDateField»
            «IF endField instanceof DatetimeField»
                $today = date('Y-m-d H:i:s');
            «ELSEIF endField instanceof DateField»
                $today = date('Y-m-d') . ' 00:00:00';
            «ENDIF»

            $qb = $this->_intBaseQuery('', '', false);

            /*$qb->andWhere('tbl.workflowState != :archivedState')
               ->setParameter('archivedState', 'archived');*/
            $qb->andWhere('tbl.workflowState = :approvedState')
               ->setParameter('approvedState', 'approved');

            $qb->andWhere('tbl.«endField.name.formatForCode» < :today')
               ->setParameter('today', $today);

            $query = $this->getQueryFromBuilder($qb);

            $affectedEntities = $query->getResult();

            $currentType = FormUtil::getPassedValue('type', 'user', 'GETPOST');
            $action = 'archive';
            $workflowHelper = new «app.appName»«IF app.targets('1.3.5')»_Util_«ELSE»\Util\«ENDIF»Workflow(ServiceUtil::getManager());

            foreach ($affectedEntities as $entity) {
                $hookAreaPrefix = $entity->getHookAreaPrefix();

                // Let any hooks perform additional validation actions
                $hookType = 'validate_edit';
                «IF app.targets('1.3.5')»
                $hook = new Zikula_ValidationHook($hookAreaPrefix . '.' . $hookType, new Zikula_Hook_ValidationProviders());
                $validators = $this->notifyHooks($hook)->getValidators();
                «ELSE»
                $hook = new Zikula\Core\Hook\ValidationHook(new Zikula\Core\Hook\ValidationProviders());
                $validators = $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook)->getValidators();
                «ENDIF»
                if ($validators->hasErrors()) {
                    continue;
                }

                $success = false;
                try {
                    // execute the workflow action
                    $success = $workflowHelper->executeAction($entity, $action);
                } catch(Exception $e) {
                    LogUtil::registerError($this->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action)));
                }

                if (!$success) {
                    continue;
                }

                // Let any hooks know that we have updated an item
                $hookType = 'process_edit';
                $urlArgs = array('ot' => $entity['_objectType']);
                $urlArgs = $this->addIdentifiersToUrlArgs($urlArgs);
                if (isset($this->entityRef['slug'])) {
                    $urlArgs['slug'] = $this->entityRef['slug'];
                }
                $url = new Zikula_ModUrl($this->name, $currentType, 'display', ZLanguage::getLanguageCode(), $urlArgs);
                «IF app.targets('1.3.5')»
                $hook = new Zikula_ProcessHook($hookAreaPrefix . '.' . $hookType, $entity->createCompositeIdentifier(), $url);
                $this->notifyHooks($hook);
                «ELSE»
                $hook = new \Zikula\Core\Hook\ProcessHook($entity->createCompositeIdentifier(), $url);
                $this->dispatchHooks($hookAreaPrefix . '.' . $hookType, $hook);
                «ENDIF»

                // An item was updated, so we clear all cached pages for this item.
                $cacheArgs = array('ot' => $entity['_objectType'], 'item' => $entity);
                ModUtil::apiFunc('«app.appName»', 'cache', 'clearItemCache', $cacheArgs);
            }

            return true;
        }
    '''


    def private modelRepositoryImpl(Entity it) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appName»\Entity\Repository;

        «ENDIF»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Repository_«name.formatForCodeCapital» extends «IF isInheriting»«app.appName»_Entity_Repository_«parentType.name.formatForCodeCapital»«app.appName»_Entity_Repository_Base_«name.formatForCodeCapital»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital» extends «IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\«name.formatForCodeCapital»«ENDIF»
        «ENDIF»
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
