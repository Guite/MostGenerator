package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.CalculatedField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityField
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.EntityWorkflowType
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
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

class Repository {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

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

        if (targets('1.3.x')) {
            val paginatorSwitch = new LegacyPaginatorSwitch
            paginatorSwitch.generate(it, fsa)
        }
    }

    /**
     * Creates a repository class file for every Entity instance.
     */
    def private generate(Entity it) {
        println('Generating repository classes for entity "' + name.formatForDisplay + '"')
        val repositoryPath = app.getAppSourceLibPath + 'Entity/Repository/'
        var fileSuffix = if (app.targets('1.3.x')) '' else 'Repository'

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

    def private modelRepositoryBaseImpl(Entity it) '''
        «imports»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.x')»
        abstract class «app.appName»_Entity_Repository_Base_Abstract«name.formatForCodeCapital» extends «IF tree != EntityTreeType.NONE»«tree.literal.toLowerCase.toFirstUpper»TreeRepository«ELSEIF hasSortableFields»SortableRepository«ELSE»EntityRepository«ENDIF»
        «ELSE»
        abstract class Abstract«name.formatForCodeCapital»Repository extends «IF hasTranslatableFields»TranslationRepository«ELSEIF hasSortableFields»SortableRepository«ELSE»EntityRepository«ENDIF»
        «ENDIF»
        {
            «IF !app.targets('1.3.x') && tree != EntityTreeType.NONE»
                use «tree.literal.toLowerCase.toFirstUpper»TreeRepositoryTrait;

            «ENDIF»
            «val stringFields = fields.filter(StringField).filter[!password]»
            /**
             * @var string The default sorting field/expression
             */
            protected $defaultSortingField = '«(if (hasSortableFields) getSortableFields.head else if (!stringFields.empty) stringFields.head else getDerivedFields.head).name.formatForCode»';

            «IF app.targets('1.3.x')»
                /**
                 * @var array Additional arguments given by the calling controller
                 */
                protected $controllerArguments = array();
            «ELSE»
                /**
                 * @var Request The request object given by the calling controller
                 */
                protected $request;
            «ENDIF»
            «IF !app.targets('1.3.x') && tree != EntityTreeType.NONE»

                /**
                 * Constructor.
                 *
                 * @param EntityManager $em    The entity manager
                 * @param ClassMetadata $class The class meta data
                 */
                public function __construct(EntityManager $em, ClassMetadata $class)
                {
                    parent::__construct($em, $class);

                    $this->initializeTreeRepository($em, $class);
                }
                «IF tree == EntityTreeType.NESTED»

                    /**
                     * Call interceptor.
                     *
                     * @param string $method Name of called method
                     * @param array  $args   Additional arguments
                     *
                     * @return mixed $result
                     */
                    public function __call($method, $args)
                    {
                        $result = $this->callTreeUtilMethods($method, $args);

                        if (null !== $result) {
                            return $result;
                        }

                        return parent::__call($method, $args);
                    }
                «ENDIF»
            «ENDIF»

            /**
             * Retrieves an array with all fields which can be used for sorting instances.
             *
             * @return array Sorting fields array
             */
            public function getAllowedSortingFields()
            {
                return «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»
                    «FOR field : fields»«field.singleSortingField»«ENDFOR»
                    «extensionSortingFields»
                «IF app.targets('1.3.x')»)«ELSE»]«ENDIF»;
            }

            «fh.getterAndSetterMethods(it, 'defaultSortingField', 'string', false, true, false, '', '')»
            «IF app.targets('1.3.x')»
                «fh.getterAndSetterMethods(it, 'controllerArguments', 'array', false, true, true, 'Array()', '')»
            «ELSE»
                «fh.getterAndSetterMethods(it, 'request', 'Request', false, true, false, '', '')»
            «ENDIF»

            «fieldNameHelpers(stringFields)»

            «getAdditionalTemplateParameters»
            «getViewQuickNavParameters»

            «truncateTable»
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

            «selectCount»

            «new Tree().generate(it, app)»

            «detectUniqueState»

            «genericBaseQuery»

            «genericBaseQueryWhere»

            «genericBaseQueryOrderBy»

            «intGetQueryFromBuilder»

            «new Joins().generate(it, app)»
            «IF hasArchive && null !== getEndDateField»

                «archiveObjects(it)»
            «ENDIF»
        }
    '''

    def private imports(Entity it) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity\Repository\Base;

        «ENDIF»
        use Doctrine\Common\Collections\ArrayCollection;
        «IF tree != EntityTreeType.NONE»
            «IF app.targets('1.3.x')»
                use Gedmo\Tree\Entity\Repository\«tree.literal.toLowerCase.toFirstUpper»TreeRepository;
            «ELSE»
                use Gedmo\Tree\Traits\Repository\«tree.literal.toLowerCase.toFirstUpper»TreeRepositoryTrait;
            «ENDIF»
            use Doctrine\ORM\EntityManager;
        «ELSEIF !app.targets('1.3.x') && hasTranslatableFields»
            use Gedmo\Translatable\Entity\Repository\TranslationRepository;
        «ELSEIF hasSortableFields»
            use Gedmo\Sortable\Entity\Repository\SortableRepository;
        «ELSE»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»
        use Doctrine\ORM\Query;
        use Doctrine\ORM\QueryBuilder;
        «IF hasOptimisticLock || hasPessimisticReadLock || hasPessimisticWriteLock»
            use Doctrine\DBAL\LockMode;
        «ENDIF»
        «IF app.targets('1.3.x')»
        use DoctrineExtensions\Paginate\Paginate;
        «ELSE»
        use Doctrine\ORM\Tools\Pagination\Paginator;
        «ENDIF»
        «IF !app.targets('1.3.x')»
            use InvalidArgumentException;
            use Symfony\Component\HttpFoundation\Request;
            use Zikula\Component\FilterUtil\FilterUtil;
            use Zikula\Component\FilterUtil\Config as FilterConfig;
            use Zikula\Component\FilterUtil\PluginManager as FilterPluginManager;
            «IF categorisable»
                use Zikula\Core\FilterUtil\CategoryPlugin as CategoryFilter;
            «ENDIF»
            «IF !fields.filter(AbstractDateField).empty»
                use Zikula\Component\FilterUtil\Plugin\DatePlugin as DateFilter;
            «ENDIF»
            use ModUtil;
            use Psr\Log\LoggerInterface;
            use ServiceUtil;
            use System;
            use Zikula\Common\Translator\TranslatorInterface;
            «IF hasArchive && null !== getEndDateField»
                use Symfony\Component\HttpFoundation\Session\SessionInterface;
                use Zikula\Core\RouteUrl;
                use Zikula\PermissionsModule\Api\PermissionApi;
            «ENDIF»
            use Zikula\UsersModule\Api\CurrentUserApi;
            use «app.appNamespace»\Entity\«name.formatForCodeCapital»Entity;
            «IF hasArchive && null !== getEndDateField && !skipHookSubscribers»
                use «app.appNamespace»\Helper\HookHelper;
            «ENDIF»
            «IF app.hasUploads»
                use «app.appNamespace»\Helper\ImageHelper;
            «ENDIF»
            «IF hasArchive && null !== getEndDateField»
                use «app.appNamespace»\Helper\WorkflowHelper;
            «ENDIF»

        «ENDIF»
    '''

    def private fieldNameHelpers(Entity it, Iterable<StringField> stringFields) '''
        «getTitleFieldName(stringFields)»

        «getDescriptionFieldName(stringFields)»

        «getPreviewFieldName»

        «getStartDateFieldName»
    '''

    def private getTitleFieldName(Entity it, Iterable<StringField> stringFields) '''
        /**
         * Returns name of the field used as title / name for entities of this repository.
         *
         * @return string Name of field to be used as title
         */
        public function getTitleFieldName()
        {
            «IF !stringFields.empty»
                $fieldName = '«stringFields.head.name.formatForCode»';
            «ELSE»
                $fieldName = '';
            «ENDIF»

            return $fieldName;
        }
    '''

    def private getDescriptionFieldName(Entity it, Iterable<StringField> stringFields) '''
        /**
         * Returns name of the field used for describing entities of this repository.
         *
         * @return string Name of field to be used as description
         */
        public function getDescriptionFieldName()
        {
            «val textFields = fields.filter(TextField)»
            «IF !textFields.empty»
                $fieldName = '«textFields.head.name.formatForCode»';
            «ELSEIF !stringFields.empty»
                «IF stringFields.size > 1»
                    $fieldName = '«stringFields.get(1).name.formatForCode»';
                «ELSE»
                    $fieldName = '«stringFields.head.name.formatForCode»';
                «ENDIF»
            «ELSE»
                $fieldName = '';
            «ENDIF»

            return $fieldName;
        }
    '''

    def private getPreviewFieldName(Entity it) '''
        /**
         * Returns name of first upload field which is capable for handling images.
         *
         * @return string Name of field to be used for preview images
         */
        public function getPreviewFieldName()
        {
            $fieldName = '«IF hasImageFieldsEntity»«getImageFieldsEntity.head.name.formatForCode»«ENDIF»';

            return $fieldName;
        }
    '''

    def private getStartDateFieldName(Entity it) '''
        /**
         * Returns name of the date(time) field to be used for representing the start
         * of this object. Used for providing meta data to the tag module.
         *
         * @return string Name of field to be used as date
         */
        public function getStartDateFieldName()
        {
            $fieldName = '«IF null !== getStartDateField»«getStartDateField.name.formatForCode»«ELSEIF standardFields»createdDate«ENDIF»';

            return $fieldName;
        }
    '''

    def private getAdditionalTemplateParameters(Entity it) '''
        /**
         * Returns an array of additional template variables which are specific to the object type treated by this repository.
         *
         «IF app.targets('1.3.x') || !app.hasUploads»
         * @param string $context Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args    Additional arguments
         «ELSE»
         * @param ImageHelper $imageHelper ImageHelper service instance
         * @param string      $context     Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array       $args        Additional arguments
         «ENDIF»
         *
         * @return array List of template variables to be assigned
         */
        public function getAdditionalTemplateParameters(«IF !app.targets('1.3.x') && app.hasUploads»ImageHelper $imageHelper, «ENDIF»$context = '', $args = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»)
        {
            if (!in_array($context, «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»'controllerAction', 'api', 'actionHandler', 'block', 'contentType'«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                $context = 'controllerAction';
            }

            $templateParameters = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»;

            if ($context == 'controllerAction') {
                if (!isset($args['action'])) {
                    «IF app.targets('1.3.x')»
                        $args['action'] = FormUtil::getPassedValue('func', 'main', 'GETPOST');
                    «ELSE»
                        $args['action'] = $this->getRequest()->query->getAlpha('func', 'index');
                    «ENDIF»
                }
                if (in_array($args['action'], «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»'«IF app.targets('1.3.x')»main«ELSE»index«ENDIF»', 'view'«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                    $templateParameters = $this->getViewQuickNavParameters($context, $args);
                    «IF app.targets('1.3.x')»
                        «IF hasListFieldsEntity»
                            $listHelper = new «app.appName»_Util_ListEntries(ServiceUtil::getManager());
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
                    «ENDIF»
                }
                «IF app.hasUploads»

                    // initialise Imagine preset instances
                    «IF app.targets('1.3.x')»
                        $serviceManager = ServiceUtil::getManager();
                        $imageHelper = new «app.appName»_Util_Image($serviceManager);

                    «ENDIF»
                    «IF hasUploadFieldsEntity»
                        $objectType = '«name.formatForCode»';
                        «IF app.targets('1.3.x')»
                            «FOR uploadField : getUploadFieldsEntity»
                                $templateParameters[$objectType . 'ThumbPreset«uploadField.name.formatForCodeCapital»'] = $imageHelper->getPreset($objectType, '«uploadField.name.formatForCode»', $context, $args);
                            «ENDFOR»
                        «ELSE»
                            $thumbRuntimeOptions = [];
                            «FOR uploadField : getUploadFieldsEntity»
                                $thumbRuntimeOptions[$objectType . '«uploadField.name.formatForCodeCapital»'] = $imageHelper->getRuntimeOptions($objectType, '«uploadField.name.formatForCode»', $context, $args);
                            «ENDFOR»
                            $templateParameters['thumbRuntimeOptions'] = $thumbRuntimeOptions;
                        «ENDIF»
                    «ENDIF»
                    if (in_array($args['action'], «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»'display', 'view'«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                        // use separate preset for images in related items
                        $templateParameters['relationThumb«IF app.targets('1.3.x')»Preset«ELSE»RuntimeOptions«ENDIF»'] = $imageHelper->getCustom«IF app.targets('1.3.x')»Preset«ELSE»RuntimeOptions«ENDIF»('', '', '«app.appName»_relateditem', $context, $args);
                    }
                «ENDIF»
            }

            // in the concrete child class you could do something like
            // $parameters = parent::getAdditionalTemplateParameters(«IF !app.targets('1.3.x') && app.hasUploads»$imageHelper, «ENDIF»$context, $args);
            // $parameters['myvar'] = 'myvalue';
            // return $parameters;

            return $templateParameters;
        }
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
        protected function getViewQuickNavParameters($context = '', $args = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»)
        {
            if (!in_array($context, «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»'controllerAction', 'api', 'actionHandler', 'block', 'contentType'«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                $context = 'controllerAction';
            }

            $parameters = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»;
            «IF categorisable»
                «IF app.targets('1.3.x')»
                    $parameters['catIdList'] = ModUtil::apiFunc('«app.appName»', 'category', 'retrieveCategoriesFromRequest', array('ot' => '«name.formatForCode»', 'source' => 'GET'));
                «ELSE»
                    $categoryHelper = \ServiceUtil::get('«app.appService».category_helper');
                    $parameters['catIdList'] = $categoryHelper->retrieveCategoriesFromRequest('«name.formatForCode»', 'GET');
                «ENDIF»
            «ENDIF»
            «IF !getBidirectionalIncomingJoinRelationsWithOneSource.empty»
                «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                    «val sourceAliasName = relation.getRelationAliasName(false)»
                    «IF app.targets('1.3.x')»
                        $parameters['«sourceAliasName»'] = isset($this->controllerArguments['«sourceAliasName»']) ? $this->controllerArguments['«sourceAliasName»'] : FormUtil::getPassedValue('«sourceAliasName»', 0, 'GET');
                    «ELSE»
                        $parameters['«sourceAliasName»'] = $this->getRequest()->query->get('«sourceAliasName»', 0);
                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            «IF hasListFieldsEntity»
                «FOR field : getListFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    «IF app.targets('1.3.x')»
                        $parameters['«fieldName»'] = isset($this->controllerArguments['«fieldName»']) ? $this->controllerArguments['«fieldName»'] : FormUtil::getPassedValue('«fieldName»', '', 'GET');
                    «ELSE»
                        $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR field : getUserFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    «IF app.targets('1.3.x')»
                        $parameters['«fieldName»'] = isset($this->controllerArguments['«fieldName»']) ? $this->controllerArguments['«fieldName»'] : (int) FormUtil::getPassedValue('«fieldName»', 0, 'GET');
                    «ELSE»
                        $parameters['«fieldName»'] = (int) $this->getRequest()->query->get('«fieldName»', 0);
                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            «IF hasCountryFieldsEntity»
                «FOR field : getCountryFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    «IF app.targets('1.3.x')»
                        $parameters['«fieldName»'] = isset($this->controllerArguments['«fieldName»']) ? $this->controllerArguments['«fieldName»'] : FormUtil::getPassedValue('«fieldName»', '', 'GET');
                    «ELSE»
                        $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «FOR field : getLanguageFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    «IF app.targets('1.3.x')»
                        $parameters['«fieldName»'] = isset($this->controllerArguments['«fieldName»']) ? $this->controllerArguments['«fieldName»'] : FormUtil::getPassedValue('«fieldName»', '', 'GET');
                    «ELSE»
                        $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            «IF hasLocaleFieldsEntity»
                «FOR field : getLocaleFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    «IF app.targets('1.3.x')»
                        $parameters['«fieldName»'] = isset($this->controllerArguments['«fieldName»']) ? $this->controllerArguments['«fieldName»'] : FormUtil::getPassedValue('«fieldName»', '', 'GET');
                    «ELSE»
                        $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                    «ENDIF»
                «ENDFOR»
            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                «IF app.targets('1.3.x')»
                    $parameters['q'] = isset($this->controllerArguments['q']) ? $this->controllerArguments['q'] : 
                        (isset($this->controllerArguments['searchterm']) ? $this->controllerArguments['searchterm'] :
                            FormUtil::getPassedValue('q', FormUtil::getPassedValue('searchterm', '', 'GET'), 'GET')
                        );
                «ELSE»
                    $parameters['q'] = $this->getRequest()->query->get('q', '');
                «ENDIF»
            «ENDIF»
            «/* not needed as already handled in the controller
            $parameters['pageSize'] = (int) $this->getRequest()->query->get('pageSize', $pageSize);*/»
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    «IF app.targets('1.3.x')»
                        $parameters['«fieldName»'] = isset($this->controllerArguments['«fieldName»']) ? $this->controllerArguments['«fieldName»'] : FormUtil::getPassedValue('«fieldName»', '', 'GET');
                    «ELSE»
                        $parameters['«fieldName»'] = $this->getRequest()->query->get('«fieldName»', '');
                    «ENDIF»
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
         «IF !app.targets('1.3.x')»
         *
         * @param LoggerInterface $logger Logger service instance
         «ENDIF»
         *
         * @return void
         */
        public function truncateTable(«IF !app.targets('1.3.x')»LoggerInterface $logger«ENDIF»)
        {
            $qb = $this->getEntityManager()->createQueryBuilder();
            $qb->delete('«entityClassName('', false)»', 'tbl');
            $query = $qb->getQuery();
            «IF softDeleteable && !app.targets('1.3.x')»

                // set the softdeletable query hint
                $query->setHint(
                    Query::HINT_CUSTOM_OUTPUT_WALKER,
                    'Gedmo\\SoftDeleteable\\Query\\TreeWalker\\SoftDeleteableWalker'
                );
            «ENDIF»
            «IF hasPessimisticWriteLock»

                $query->setLockMode(LockMode::«lockType.lockTypeAsConstant»);
            «ENDIF»

            $query->execute();
            «IF !app.targets('1.3.x')»

                $logArgs = ['app' => '«application.appName»', 'entity' => '«name.formatForDisplay»'];
                $logger->debug('{app}: Truncated the {entity} entity table.', $logArgs);
            «ENDIF»
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
         */
        protected function addIdListFilter($idList, QueryBuilder $qb)
        {
            $orX = $qb->expr()->orX();

            foreach ($idList as $id) {
                // check id parameter
                if ($id == 0) {
                    «IF application.targets('1.3.x')»
                        $dom = ZLanguage::getModuleDomain($this->name);
                        throw new \InvalidArgumentException(__('Invalid identifier received.', $dom));
                    «ELSE»
                        throw new InvalidArgumentException('Invalid identifier received.');
                    «ENDIF»
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
         * @return array|«name.formatForCode»Entity retrieved data array or «name.formatForCode»Entity instance
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function selectById($id = 0, $useJoins = true, $slimMode = false)
        {
            $results = $this->selectByIdList(«IF app.targets('1.3.x')»array($id)«ELSE»[$id]«ENDIF», $useJoins, $slimMode);

            return (count($results) > 0) ? $results[0] : null;
        }
        
        /**
         * Selects a list of objects with an array of ids
         *
         * @param mixed   $idList   The array of ids to use to retrieve the objects (optional) (default=0)
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true)
         * @param boolean $slimMode If activated only some basic fields are selected without using any joins (optional) (default=false)
         *
         * @return ArrayCollection collection containing retrieved «name.formatForCode»Entity instances
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function selectByIdList($idList = «IF app.targets('1.3.x')»array(0)«ELSE»[0]«ENDIF», $useJoins = true, $slimMode = false)
        {
            $qb = $this->genericBaseQuery('', '', $useJoins, $slimMode);
            $qb = $this->addIdListFilter($idList, $qb);

            $query = $this->getQueryFromBuilder($qb);
        
            $results = $query->getResult();

            return (count($results) > 0) ? $results : null;
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
         * @return «entityClassName('', false)» retrieved instance of «entityClassName('', false)»
         *
         * @throws InvalidArgumentException Thrown if invalid parameters are received
         */
        public function selectBySlug($slugTitle = '', $useJoins = true, $slimMode = false, $excludeId = 0)
        {
            // check input parameter
            if ($slugTitle == '') {
                «IF application.targets('1.3.x')»
                    $dom = ZLanguage::getModuleDomain($this->name);
                    throw new \InvalidArgumentException(__('Invalid slug title received.', $dom));
                «ELSE»
                    throw new InvalidArgumentException('Invalid slug title received.');
                «ENDIF»
            }

            $qb = $this->genericBaseQuery('', '', $useJoins, $slimMode);

            $qb->andWhere('tbl.slug = :slug')
               ->setParameter('slug', $slugTitle);

            $qb = $this->addExclusion($qb, $excludeId);

            $query = $this->getQueryFromBuilder($qb);

            $results = $query->getResult();

            return (count($results) > 0) ? $results[0] : null;
        }
    '''

    def private addExclusion(Entity it) '''
        /**
         * Adds where clauses excluding desired identifiers from selection.
         *
         * @param QueryBuilder $qb        Query builder to be enhanced
         * @param «IF hasCompositeKeys»mixed  «ELSE»integer«ENDIF»      $excludeId The id (or array of ids) to be excluded from selection
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function addExclusion(QueryBuilder $qb, $excludeId)
        {
            «IF hasCompositeKeys»
                if (is_array($excludeId)) {
                    foreach ($id as $fieldName => $fieldValue) {
                        $qb->andWhere('tbl.' . $fieldName . ' != :' . $fieldName)
                           ->setParameter($fieldName, $fieldValue);
                    }
                } elseif ($excludeId > 0) {
            «ELSE»
                if ($excludeId > 0) {
            «ENDIF»
                $qb->andWhere('tbl.id != :excludeId')
                   ->setParameter('excludeId', $excludeId);
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
         * @return QueryBuilder query builder for the given arguments
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
         * @return ArrayCollection collection containing retrieved «name.formatForCode»Entity instances
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
         * @return array Created query instance and amount of affected items
         */
        public function getSelectWherePaginatedQuery(QueryBuilder $qb, $currentPage = 1, $resultsPerPage = 25)
        {
            $qb = $this->addCommonViewFilters($qb);

            $query = $this->getQueryFromBuilder($qb);
            $offset = ($currentPage-1) * $resultsPerPage;

            «IF app.targets('1.3.x')»
                $isLegacy = version_compare(\Zikula_Core::VERSION_NUM, '1.4.0') >= 0 ? false : true;
                $paginatorClass = '«app.appName»_Paginator_' . (!$isLegacy ? 'Paginator' : 'LegacyPaginator');

                if ($isLegacy) {
                    $hasRelationships = «IF !(outgoing.filter(JoinRelationship).empty && incoming.filter(JoinRelationship).empty)»true«ELSE»false«ENDIF»;
                    $paginator = new $paginatorClass($query, $hasRelationships);
                    list($query, $count) = $paginator->getResults($offset, $resultsPerPage);
                    if (!$hasRelationships) {
                        $query->setFirstResult($offset)
                              ->setMaxResults($resultsPerPage);
                    }
                } else {
                    $query->setFirstResult($offset)
                          ->setMaxResults($resultsPerPage);
                    $count = 0;
                }
            «ELSE»
                $query->setFirstResult($offset)
                      ->setMaxResults($resultsPerPage);
                $count = 0; // will be set at a later stage (in calling method)
                «/* TODO remove $count from this method together with 1.3.x support #260 */»
            «ENDIF»

            return «IF app.targets('1.3.x')»array($query, $count)«ELSE»[$query, $count]«ENDIF»;
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
         * @return array with retrieved collection and amount of total records affected by this query
         */
        public function selectWherePaginated($where = '', $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true, $slimMode = false)
        {
            $qb = $this->genericBaseQuery($where, $orderBy, $useJoins, $slimMode);

            $page = $currentPage;

            // check if we have any filters set
            $parameters = $this->getViewQuickNavParameters('', «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»);
            $hasFilters = false;
            foreach ($parameters as $k => $v) {
                if ((!is_numeric($v) && $v != '') || (is_numeric($v) && $v > 0)) {
                    $hasFilters = true;
                    break;
                }
            }

            «val sessionVar = app.appName + nameMultiple.formatForCodeCapital + 'CurrentPage'»
            if (!$hasFilters) {
                «IF !app.targets('1.3.x')»
                    $session = null !== $this->getRequest() ? $this->getRequest()->getSession() : null;
                «ENDIF»
                if ($page > 1 || isset($_GET['pos'])) {
                    // store current page in session
                    «IF app.targets('1.3.x')»
                        SessionUtil::setVar('«sessionVar»', $page);
                    «ELSE»
                        if (null !== $session) {
                            $session->set('«sessionVar»', $page);
                        }
                    «ENDIF»
                } else {
                    // restore current page from session
                    «IF app.targets('1.3.x')»
                        $page = SessionUtil::getVar('«sessionVar»', 1);
                        System::queryStringSetVar('pos', $page);
                    «ELSE»
                        if (null !== $session) {
                            $page = $session->get('«sessionVar»', 1);
                            if (null !== $this->getRequest()) {
                                $this->getRequest()->query->set('pos', $page);
                            }
                        }
                    «ENDIF»
                }
            }

            list($query, $count) = $this->getSelectWherePaginatedQuery($qb, $page, $resultsPerPage);

            «IF app.targets('1.3.x')»
                $result = $this->retrieveCollectionResult($query, $orderBy, true);

                return array($result, $count);
            «ELSE»
                return $this->retrieveCollectionResult($query, $orderBy, true);
            «ENDIF»
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
            «IF !app.targets('1.3.x')»
                if (null === $this->getRequest()) {
                    // if no request is set we return (#433)
                    return $qb;
                }

            «ENDIF»
            «IF app.targets('1.3.x')»
                $currentFunc = FormUtil::getPassedValue('func', 'main', 'GETPOST');
            «ELSE»
                $currentFunc = $this->getRequest()->query->getAlpha('func', 'index');
            «ENDIF»
            if ($currentFunc == 'edit') {«/* fix for #547 */»
                return $qb;
            }

            $parameters = $this->getViewQuickNavParameters('', «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»);
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
                        «IF app.targets('1.3.x')»
                            $qb = ModUtil::apiFunc('«app.appName»', 'category', 'buildFilterClauses', array('qb' => $qb, 'ot' => '«name.formatForCode»', 'catids' => $v));
                        «ELSE»
                            $categoryHelper = \ServiceUtil::get('«app.appService».category_helper');
                            $qb = $categoryHelper->buildFilterClauses($qb, '«name.formatForCode»', $v);
                        «ENDIF»
                «ENDIF»
                «IF categorisable»} else«ENDIF»if (in_array($k, «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»'q', 'searchterm'«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
                    // quick search
                    if (!empty($v)) {
                        $qb = $this->addSearchFilter($qb, $v);
                    }
                «IF hasBooleanFieldsEntity»
                } elseif (in_array($k, «IF app.targets('1.3.x')»array(«ELSE»[«ENDIF»«FOR field : getBooleanFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»«IF app.targets('1.3.x')»)«ELSE»]«ENDIF»)) {
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
                            $qb->andWhere('tbl.' . $k . ' = :' . $k)
                               ->setParameter($k, $v);
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
        protected function applyDefaultFilters(QueryBuilder $qb, $parameters = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»)
        {
            «IF workflow == EntityWorkflowType.STANDARD || workflow == EntityWorkflowType.ENTERPRISE»
                $currentModule = ModUtil::getName();
                «IF app.targets('1.3.x')»
                    $currentLegacyControllerType = FormUtil::getPassedValue('lct', 'user', 'GETPOST');
                «ELSE»
                    $currentLegacyControllerType = null !== $this->getRequest() ? $this->getRequest()->get('lct', 'user') : 'user';
                «ENDIF»
                if ($currentLegacyControllerType == 'admin' && $currentModule == '«app.appName»') {
                    return $qb;
                }

                if (!in_array('workflowState', array_keys($parameters)) || empty($parameters['workflowState'])) {
                    // per default we show approved «nameMultiple.formatForDisplay» only
                    $onlineStates = «IF app.targets('1.3.x')»array('approved')«ELSE»['approved']«ENDIF»;
                    «IF ownerPermission»
                        «IF app.targets('1.3.x')»
                            $showOnlyOwnEntries = (int) FormUtil::getPassedValue('own', ModUtil::getVar('«app.appName»', 'showOnlyOwnEntries', 0), 'GETPOST');
                        «ELSE»
                            «/*$serviceManager = ServiceUtil::getManager();
                            $variableApi = $serviceManager->get('zikula_extensions_module.api.variable');
                            $showOnlyOwnEntries = $this->getRequest()->query->getDigits('own', $variableApi->get('«app.appName»', 'showOnlyOwnEntries', 0));*/»
                            $showOnlyOwnEntries = $this->getRequest()->query->getDigits('own', 0);
                        «ENDIF»
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
            «IF application.targets('1.3.x')»
                $startDate = FormUtil::getPassedValue('«startDateField.name.formatForCode»', «startDateField.defaultValueForNow», 'GET');
            «ELSE»
                $startDate = null !== $this->getRequest() ? $this->getRequest()->query->get('«startDateField.name.formatForCode»', «startDateField.defaultValueForNow») : «startDateField.defaultValueForNow»;
            «ENDIF»
            $qb->andWhere('«whereClauseForDateRangeFilter('<=', startDateField, 'startDate')»')
               ->setParameter('startDate', $startDate);
        «ENDIF»
        «IF null !== endDateField»
            «IF application.targets('1.3.x')»
                $endDate = FormUtil::getPassedValue('«endDateField.name.formatForCode»', «endDateField.defaultValueForNow», 'GET');
            «ELSE»
                $endDate = null !== $this->getRequest() ? $this->getRequest()->query->get('«endDateField.name.formatForCode»', «endDateField.defaultValueForNow») : «endDateField.defaultValueForNow»;
            «ENDIF»
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
         * @param array   $exclude        Comma separated list with ids to be excluded from search
         * @param string  $orderBy        The order-by clause to use when retrieving the collection (optional) (default='')
         * @param integer $currentPage    Where to start selection
         * @param integer $resultsPerPage Amount of items to select
         * @param boolean $useJoins       Whether to include joining related objects (optional) (default=true)
         *
         * @return array with retrieved collection and amount of total records affected by this query
         */
        public function selectSearch($fragment = '', $exclude = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF», $orderBy = '', $currentPage = 1, $resultsPerPage = 25, $useJoins = true)
        {
            $qb = $this->genericBaseQuery('', $orderBy, $useJoins);
            if (count($exclude) > 0) {
                $qb->andWhere('tbl.«getFirstPrimaryKey.name.formatForCode» NOT IN (:excludeList)')«/* TODO fix composite keys */»
                   ->setParameter('excludeList', $exclude);
            }

            $qb = $this->addSearchFilter($qb, $fragment);

            list($query, $count) = $this->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);

            «IF app.targets('1.3.x')»
                $result = $this->retrieveCollectionResult($query, $orderBy, true);

                return array($result, $count);
            «ELSE»
                return $this->retrieveCollectionResult($query, $orderBy, true);
            «ENDIF»
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

            $fragment = str_replace('\'', '', \DataUtil::formatForStore($fragment));
            $fragmentIsNumeric = is_numeric($fragment);

            «val searchFields = getDisplayFields.filter[isContainedInTextualSearch]»
            «val searchFieldsNumeric = getDisplayFields.filter[isContainedInNumericSearch]»
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

    def private retrieveCollectionResult(Entity it) '''
        /**
         * Performs a given database selection and post-processed the results.
         *
         * @param Query   $query       The Query instance to be executed
         * @param string  $orderBy     The order-by clause to use when retrieving the collection (optional) (default='')
         * @param boolean $isPaginated Whether the given query uses a paginator or not (optional) (default=false)
         *
         * @return array with retrieved collection«IF !app.targets('1.3.x')» and (for paginated queries) the amount of total records affected«ENDIF»
         */
        public function retrieveCollectionResult(Query $query, $orderBy = '', $isPaginated = false)
        {
            «IF app.targets('1.3.x')»
                $isLegacy = version_compare(\Zikula_Core::VERSION_NUM, '1.4.0') >= 0 ? false : true;
                if ($isLegacy) {
                    $result = $query->getResult();
                } else {
                    if (!$isPaginated) {
                        $result = $query->getResult();
                    } else {
                        $paginatorClass = '«app.appName»_Paginator_Paginator';
                        $hasRelationships = «IF !(outgoing.filter(JoinRelationship).empty && incoming.filter(JoinRelationship).empty)»true«ELSE»false«ENDIF»;
                        $paginator = new $paginatorClass($query, $hasRelationships);
                        list($result, $count) = $paginator->getResults();
                    }
                }
            «ELSE»
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
            «ENDIF»

            «IF app.targets('1.3.x')»
                if ($orderBy == 'RAND()') {
                    // each entry in $result looks like array(0 => actualRecord, 'randomIdentifiers' => randomId)
                    $resRaw = array();
                    foreach ($result as $resultRow) {
                        $resRaw[] = $resultRow[0];
                    }
                    $result = $resRaw;
                }

                return $result;
            «ELSE»
                if (!$isPaginated) {
                    return $result;
                }

                return [$result, $count];
            «ENDIF»
        }
    '''

    def private selectCount(Entity it) '''
        /**
         * Returns query builder instance for a count query.
         *
         * @param string  $where    The where clause to use when retrieving the object count (optional) (default='')
         * @param boolean $useJoins Whether to include joining related objects (optional) (default=true)
         *
         * @return QueryBuilder Created query builder instance
         * @TODO fix usage of joins; please remove the first line and test
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

            $this->genericBaseQueryAddWhere($qb, $where);

            return $qb;
        }

        /**
         * Selects entity count with a given where clause.
         *
         * @param string  $where      The where clause to use when retrieving the object count (optional) (default='')
         * @param boolean $useJoins   Whether to include joining related objects (optional) (default=true)
         * @param array   $parameters List of determined filter options
         *
         * @return integer amount of affected records
         */
        public function selectCount($where = '', $useJoins = true, $parameters = «IF app.targets('1.3.x')»array()«ELSE»[]«ENDIF»)
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
         * @param string $fieldName  The name of the property to be checked
         * @param string $fieldValue The value of the property to be checked
         * @param int    $excludeId  Id of «nameMultiple.formatForDisplay» to exclude (optional)
         *
         * @return boolean result of this check, true if the given «name.formatForDisplay» does not already exist
         */
        public function detectUniqueState($fieldName, $fieldValue, $excludeId = 0)
        {
            $qb = $this->getCountQuery('', false);
            $qb->andWhere('tbl.' . $fieldName . ' = :' . $fieldName)
               ->setParameter($fieldName, $fieldValue);

            $qb = $this->addExclusion($qb, $excludeId);

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
         * @return QueryBuilder query builder instance to be further processed
         */
        public function genericBaseQuery($where = '', $orderBy = '', $useJoins = true, $slimMode = false)
        {
            // normally we select the whole table
            $selection = 'tbl';

            if ($slimMode === true) {
                // but for the slim version we select only the basic fields, and no joins

                $selection = '«FOR pkField : getPrimaryKeyFields SEPARATOR ', '»tbl.«pkField.name.formatForCode»«ENDFOR»';
                «addSelectionPartsForDisplayPattern»
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

            $this->genericBaseQueryAddWhere($qb, $where);
            $this->genericBaseQueryAddOrderBy($qb, $orderBy);

            return $qb;
        }
    '''

    def private addSelectionPartsForDisplayPattern(Entity it) '''
        «val patternParts = displayPattern.split('#')»
        «FOR patternPart : patternParts»
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
         * @return QueryBuilder query builder instance to be further processed
         */
        protected function genericBaseQueryAddWhere(QueryBuilder $qb, $where = '')
        {
            if (!empty($where)) {
            «IF app.targets('1.3.x')»
                $qb->where($where);
            «ELSE»
                // Use FilterUtil to support generic filtering.
                //$qb->where($where);

                // Create filter configuration.
                $filterConfig = new FilterConfig($qb);

                // Define plugins to be used during filtering.
                $filterPluginManager = new FilterPluginManager(
                    $filterConfig,

                    // Array of plugins to load.
                    // If no plugin with default = true given the compare plugin is loaded and used for unconfigured fields.
                    // Multiple objects of the same plugin with different configurations are possible.
                    [
                        «IF !fields.filter(AbstractDateField).empty»
                            new DateFilter([«FOR field : fields.filter(AbstractDateField) SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»/*, 'tblJoin.someJoinedField'*/])
                        «ENDIF»
                    ],

                    // Allowed operators per field.
                    // Array in the form "field name => operator array".
                    // If a field is not set in this array all operators are allowed.
                    []
                );
                «IF categorisable»

                    // add category plugins dynamically for all existing registry properties
                    // we need to create one category plugin instance for each one
                    $categoryHelper = \ServiceUtil::get('«app.appService».category_helper');
                    $categoryProperties = $categoryHelper->getAllProperties('«name.formatForCode»');
                    foreach ($categoryProperties as $propertyName => $registryId) {
                        $config['plugins'][] = new CategoryFilter('«app.appName»', $propertyName, 'categories' . ucfirst($propertyName));
                    }
                «ENDIF»

                // Request object to obtain the filter string (only needed if the filter is set via GET or it reads values from GET).
                // We do this not per default (for now) to prevent problems with explicite filters set by blocks or content types.
                // TODO readd automatic request processing (basically replacing applyDefaultFilters() and addCommonViewFilters()).
                $request = null;

                // Name of filter variable(s) (filterX).
                $filterKey = 'filter';

                // initialise FilterUtil and assign both query builder and configuration
                $filterUtil = new FilterUtil($filterPluginManager, $request, $filterKey);

                // set our given filter
                $filterUtil->setFilter($where);

                // you could add explicit filters at this point, something like
                // $filterUtil->addFilter('foo:eq:something,bar:gt:100');
                // read more at
                // https://github.com/zikula/core/blob/master/src/lib/Zikula/Component/FilterUtil/README.md
                // https://github.com/zikula/core/blob/master/src/lib/Zikula/Component/FilterUtil/Resources/docs/users.md

                // now enrich the query builder
                $filterUtil->enrichQuery();
            «ENDIF»
            }
            «IF standardFields»

                «IF app.targets('1.3.x')»
                    $showOnlyOwnEntries = (int) FormUtil::getPassedValue('own', ModUtil::getVar('«app.appName»', 'showOnlyOwnEntries', 0), 'GETPOST');
                «ELSE»
                    if (null === $this->getRequest()) {
                        // if no request is set we return (#783)
                        return $qb;
                    }

                    «/*$serviceManager = ServiceUtil::getManager();
                    $variableApi = $serviceManager->get('zikula_extensions_module.api.variable');
                    $showOnlyOwnEntries = $this->getRequest()->query->getDigits('own', $variableApi->get('«app.appName»', 'showOnlyOwnEntries', 0));*/»
                    $showOnlyOwnEntries = $this->getRequest()->query->getDigits('own', 0);
                «ENDIF»
                if ($showOnlyOwnEntries == 1) {
                    «IF app.targets('1.3.x')»
                        $uid = UserUtil::getVar('uid');
                    «ELSE»
                        «/*$uid = $serviceManager->get('zikula_users_module.current_user')->get('uid');*/»
                        $uid = $this->getRequest()->getSession()->get('uid');
                    «ENDIF»
                    $qb->andWhere('tbl.createdUserId = :creator')
                       ->setParameter('creator', $uid);
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
         * @return QueryBuilder query builder instance to be further processed
         */
        protected function genericBaseQueryAddOrderBy(QueryBuilder $qb, $orderBy = '')
        {
            if ($orderBy == 'RAND()') {
                // random selection
                $qb->addSelect('MOD(tbl.«getFirstPrimaryKey.name.formatForCode», ' . mt_rand(2, 15) . ') AS «IF !app.targets('1.3.x')»HIDDEN «ENDIF»randomIdentifiers')
                   ->add('orderBy', 'randomIdentifiers');
                $orderBy = '';
            } elseif (empty($orderBy)) {
                $orderBy = $this->defaultSortingField;
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

    def private intGetQueryFromBuilder(Entity it) '''
        /**
         * Retrieves Doctrine query from query builder, applying FilterUtil and other common actions.
         *
         * @param QueryBuilder $qb Query builder instance
         *
         * @return Query query instance to be further processed
         */
        public function getQueryFromBuilder(QueryBuilder $qb)
        {
            $query = $qb->getQuery();
            «IF hasTranslatableFields»«/* TODO decide whether this should be controlled by FeatureActivationHelper, too */»

                // set the translation query hint
                $query->setHint(
                    Query::HINT_CUSTOM_OUTPUT_WALKER,
                    'Gedmo\\Translatable\\Query\\TreeWalker\\TranslationWalker'
                );
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
        «IF softDeleteable && !app.targets('1.3.x')»
             'deletedAt',
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
         * @return bool If everything went right or not
         «IF !app.targets('1.3.x')»
         *
         * @param PermissionApi       $permissionApi  PermissionApi service instance
         * @param Session             $session        Session service instance
         * @param TranslatorInterface $translator     Translator service instance
         * @param WorkflowHelper      $workflowHelper WorkflowHelper service instance
         «IF !skipHookSubscribers»
         * @param HookHelper          $hookHelper     HookHelper service instance
         «ENDIF»
         *
         * @throws RuntimeException Thrown if workflow action execution fails
         «ENDIF»
         */
        public function archiveObjects(«IF !app.targets('1.3.x')»PermissionApi $permissionApi, SessionInterface $session, TranslatorInterface $translator, WorkflowHelper $workflowHelper«IF !skipHookSubscribers», HookHelper $hookHelper«ENDIF»«ENDIF»)
        {
            if (true !== \PageUtil::getVar('«app.appName»AutomaticArchiving', false) && !«IF app.targets('1.3.x')»SecurityUtil::check«ELSE»$permissionApi->has«ENDIF»Permission('«app.appName»', '.*', ACCESS_EDIT)) {
                // current user has no permission for executing the archive workflow action
                return true;
            }

            «IF !app.targets('1.3.x')»
                if (null == $this->getRequest()) {
                    // return as no request is given
                    return true;
                }

            «ENDIF»
            «val endField = getEndDateField»
            «IF endField instanceof DatetimeField»
                $today = date('Y-m-d H:i:s');
            «ELSEIF endField instanceof DateField»
                $today = date('Y-m-d') . ' 00:00:00';
            «ENDIF»

            $qb = $this->genericBaseQuery('', '', false);

            /*$qb->andWhere('tbl.workflowState != :archivedState')
               ->setParameter('archivedState', 'archived');*/
            $qb->andWhere('tbl.workflowState = :approvedState')
               ->setParameter('approvedState', 'approved');

            $qb->andWhere('tbl.«endField.name.formatForCode» < :today')
               ->setParameter('today', $today);

            $query = $this->getQueryFromBuilder($qb);

            $affectedEntities = $query->getResult();

            $action = 'archive';
            «IF app.targets('1.3.x')»
                $serviceManager = ServiceUtil::getManager();
                $workflowHelper = new «app.appName»_Util_Workflow($serviceManager);
                «IF !skipHookSubscribers»
                    $hookHelper = new «app.appName»_Util_Hook($serviceManager);
                «ENDIF»

            «ENDIF»
            foreach ($affectedEntities as $entity) {
                $entity->initWorkflow();

                «IF !skipHookSubscribers»
                    // Let any hooks perform additional validation actions
                    $hookType = 'validate_edit';
                    $validationHooksPassed = $hookHelper->callValidationHooks($entity, $hookType);
                    if (!$validationHooksPassed) {
                        continue;
                    }

                «ENDIF»
                $success = false;
                try {
                    if (!$entity->validate()) {
                        continue;
                    }
                    // execute the workflow action
                    $success = $workflowHelper->executeAction($entity, $action);
                } catch(\Exception $e) {
                    «IF app.targets('1.3.x')»
                        $dom = ZLanguage::getModuleDomain($this->name);
                        LogUtil::registerError(__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', array($action), $dom));
                    «ELSE»
                        $flashBag = $session->getFlashBag();
                        $flashBag->add('error', $translator->__f('Sorry, but an unknown error occured during the %s action. Please apply the changes again!', ['%s' => $action]));
                    «ENDIF»
                }

                if (!$success) {
                    continue;
                }
                «IF !skipHookSubscribers»

                    // Let any hooks know that we have updated an item
                    $hookType = 'process_edit';
                    $urlArgs = $entity->createUrlArgs();
                    «IF app.targets('1.3.x')»
                        $url = new Zikula_ModUrl($this->name, '«name.formatForCode»', 'display', ZLanguage::getLanguageCode(), $urlArgs);
                    «ELSE»
                        $urlArgs['_locale'] = $serviceManager->get('request_stack')->getMasterRequest()->getLocale();
                        $url = new RouteUrl('«app.appName.formatForDB»_«name.formatForCode»_display', $urlArgs);
                    «ENDIF»
                    $hookHelper->callProcessHooks($entity, $hookType, $url);
                «ENDIF»
                «IF app.targets('1.3.x')»

                    // An item was updated, so we clear all cached pages for this item.
                    $cacheArgs = array('ot' => $entity['_objectType'], 'item' => $entity);
                    ModUtil::apiFunc('«app.appName»', 'cache', 'clearItemCache', $cacheArgs);
                «ENDIF»
            }

            return true;
        }
    '''


    def private modelRepositoryImpl(Entity it) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity\Repository;

            use «app.appNamespace»\Entity\Repository\«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»«ENDIF»Repository;

        «ENDIF»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.x')»
        class «app.appName»_Entity_Repository_«name.formatForCodeCapital» extends «IF isInheriting»«app.appName»_Entity_Repository_«parentType.name.formatForCodeCapital»«ELSE»«app.appName»_Entity_Repository_Base_Abstract«name.formatForCodeCapital»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital»Repository extends «IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»«ENDIF»Repository
        «ENDIF»
        {
            // feel free to add your own methods here, like for example reusable DQL queries
        }
    '''
}
