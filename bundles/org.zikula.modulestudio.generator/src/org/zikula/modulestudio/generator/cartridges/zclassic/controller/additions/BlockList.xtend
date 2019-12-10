package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.BlockListType
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlockListView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockList {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateListBlock) {
            return
        }
        'Generating block for multiple objects'.printIfNotTesting(fsa)
        fsa.generateClassPair('Block/ItemListBlock.php', listBlockBaseClass, listBlockImpl)
        new BlockListType().generate(it, fsa)
        new BlockListView().generate(it, fsa)
    }

    def private listBlockBaseClass(Application it) '''
        namespace «appNamespace»\Block\Base;

        use Exception;
        «IF targets('3.0')»
            use Twig\Loader\FilesystemLoader;
        «ENDIF»
        use Zikula\BlocksModule\AbstractBlockHandler;
        use «appNamespace»\Block\Form\Type\ItemListBlockType;
        «IF targets('3.0')»
            use «appNamespace»\Entity\Factory\EntityFactory;
            «IF hasCategorisableEntities»
                use «appNamespace»\Helper\CategoryHelper;
            «ENDIF»
            use «appNamespace»\Helper\ControllerHelper;
        «ENDIF»
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        «IF targets('3.0')»
            use «appNamespace»\Helper\ModelHelper;
            use «appNamespace»\Helper\PermissionHelper;
        «ENDIF»

        /**
         * Generic item list block base class.
         */
        abstract class AbstractItemListBlock extends AbstractBlockHandler
        {
            «listBlockBaseImpl»
        }
    '''

    def private listBlockBaseImpl(Application it) '''
        «IF targets('3.0')»
            /**
             * @var FilesystemLoader
             */
            protected $twigLoader;

            /**
             * @var ControllerHelper
             */
            protected $controllerHelper;

            /**
             * @var ModelHelper
             */
            protected $modelHelper;

            /**
             * @var PermissionHelper
             */
            protected $permissionHelper;

            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            «IF hasCategorisableEntities»
                /**
                 * @var categoryHelper
                 */
                protected $categoryHelper;

                /**
                 * @var FeatureActivationHelper
                 */
                protected $featureActivationHelper;

            «ENDIF»
        «ENDIF»
        «IF hasCategorisableEntities»
            /**
             * List of object types allowing categorisation.
             *
             * @var array
             */
            protected $categorisableObjectTypes;

        «ENDIF»
        public function getType()«IF targets('3.0')»: string«ENDIF»
        {
            return $this->__('«name.formatForDisplayCapital» list', '«appName.formatForDB»');
        }

        «display»

        «getDisplayTemplate»

        «modify»

        /**
         * Returns default settings for this block.
         «IF !targets('3.0')»
         *
         * @return array The default settings
         «ENDIF»
         */
        protected function getDefaults()«IF targets('3.0')»: array«ENDIF»
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 5,
                'template' => 'itemlist_display.html.twig',
                'customTemplate' => null,
                'filter' => ''
            ];
        }
        «IF hasCategorisableEntities»

            /**
             * Resolves category filter ids.
             «IF !targets('3.0')»
             *
             * @param array $properties The block properties
             *
             * @return array The updated block properties
             «ENDIF»
             */
            protected function resolveCategoryIds(array $properties = [])«IF targets('3.0')»: array«ENDIF»
            {
                «IF targets('3.0')»
                    $primaryRegistry = $this->categoryHelper->getPrimaryProperty($properties['objectType']);
                «ELSE»
                    $categoryHelper = $this->get('«appService».category_helper');
                    $primaryRegistry = $categoryHelper->getPrimaryProperty($properties['objectType']);
                «ENDIF»
                if (!isset($properties['categories'])) {
                    $properties['categories'] = [$primaryRegistry => []];
                } else {
                    if (!is_array($properties['categories'])) {
                        $properties['categories'] = explode(',', $properties['categories']);
                    }
                    if (count($properties['categories']) > 0) {
                        $firstCategories = reset($properties['categories']);
                        if (!is_array($firstCategories)) {
                            $firstCategories = [$firstCategories];
                        }
                        $properties['categories'] = [$primaryRegistry => $firstCategories];
                    }
                }

                return $properties;
            }
        «ENDIF»
        «IF targets('3.0')»

            /**
             * @required
             */
            public function setTwigLoader(FilesystemLoader $twigLoader): void
            {
                $this->twigLoader = $twigLoader;
            }

            /**
             * @required
             */
            public function setControllerHelper(ControllerHelper $controllerHelper): void
            {
                $this->controllerHelper = $controllerHelper;
            }

            /**
             * @required
             */
            public function setModelHelper(ModelHelper $modelHelper): void
            {
                $this->modelHelper = $modelHelper;
            }

            /**
             * @required
             */
            public function setPermissionHelper(PermissionHelper $permissionHelper): void
            {
                $this->permissionHelper = $permissionHelper;
            }

            /**
             * @required
             */
            public function setEntityFactory(EntityFactory $entityFactory): void
            {
                $this->entityFactory = $entityFactory;
            }
            «IF hasCategorisableEntities»

                /**
                 * @required
                 */
                public function setCategoryDependencies(
                    CategoryHelper $categoryHelper,
                    FeatureActivationHelper $featureActivationHelper
                ): void {
                    $this->categoryHelper = $categoryHelper;
                    $this->featureActivationHelper = $featureActivationHelper;
                }
            «ENDIF»
        «ENDIF»
    '''

    def private display(Application it) '''
        public function display(array $properties = [])«IF targets('3.0')»: string«ENDIF»
        {
            // only show block content if the user has the required permissions
            if (!$this->hasPermission('«appName»:ItemListBlock:', $properties['title'] . '::', ACCESS_OVERVIEW)) {
                return '';
            }

            «IF hasCategorisableEntities»
                «initListOfCategorisableEntities»

            «ENDIF»
            // set default values for all params which are not properly set
            $defaults = $this->getDefaults();
            $properties = array_merge($defaults, $properties);

            «IF targets('3.0')»
                $contextArgs = ['name' => 'list'];
                if (!isset($properties['objectType']) || !in_array($properties['objectType'], $this->controllerHelper->getObjectTypes('block', $contextArgs), true)) {
                    $properties['objectType'] = $this->controllerHelper->getDefaultObjectType('block', $contextArgs);
                }
            «ELSE»
                $controllerHelper = $this->get('«appService».controller_helper');
                $contextArgs = ['name' => 'list'];
                if (!isset($properties['objectType']) || !in_array($properties['objectType'], $controllerHelper->getObjectTypes('block', $contextArgs), true)) {
                    $properties['objectType'] = $controllerHelper->getDefaultObjectType('block', $contextArgs);
                }
            «ENDIF»

            $objectType = $properties['objectType'];
            «IF hasCategorisableEntities»

                «IF !targets('3.0')»
                    $featureActivationHelper = $this->get('«appService».feature_activation_helper');
                «ENDIF»
                $hasCategories = in_array($objectType, $this->categorisableObjectTypes, true)
                    && $«IF targets('3.0')»this->«ENDIF»featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties['objectType']);
                if ($hasCategories) {
                    $categoryProperties = $this->resolveCategoryIds($properties);
                }
            «ENDIF»

            «IF targets('3.0')»
                $repository = $this->entityFactory->getRepository($objectType);

                // create query
                $orderBy = $this->modelHelper->resolveSortParameter($objectType, $properties['sorting']);
            «ELSE»
                $repository = $this->get('«appService».entity_factory')->getRepository($objectType);

                // create query
                $orderBy = $this->get('«appService».model_helper')->resolveSortParameter($objectType, $properties['sorting']);
            «ENDIF»
            $qb = $repository->getListQueryBuilder($properties['filter'], $orderBy);
            «IF hasCategorisableEntities»

                if ($hasCategories) {
                    «IF targets('3.0')»
                        // apply category filters
                        if (is_array($properties['categories']) && count($properties['categories']) > 0) {
                            $qb = $this->categoryHelper->buildFilterClauses($qb, $objectType, $properties['categories']);
                        }
                    «ELSE»
                        $categoryHelper = $this->get('«appService».category_helper');
                        // apply category filters
                        if (is_array($properties['categories']) && count($properties['categories']) > 0) {
                            $qb = $categoryHelper->buildFilterClauses($qb, $objectType, $properties['categories']);
                        }
                    «ENDIF»
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = $properties['amount'];
            $query = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            try {
                list($entities, $objectCount) = $repository->retrieveCollectionResult($query, true);
            } catch (Exception $exception) {
                $entities = [];
                $objectCount = 0;
            }

            // filter by permissions
            $entities = «IF targets('3.0')»$this->permissionHelper«ELSE»$this->get('«appService».permission_helper')«ENDIF»->filterCollection($objectType, $entities, ACCESS_READ);

            // set a block title
            if (empty($properties['title'])) {
                $properties['title'] = $this->__('«name.formatForDisplayCapital» list', '«appName.formatForDB»');
            }

            $template = $this->getDisplayTemplate($properties);

            $templateParameters = [
                'vars' => $properties,
                'objectType' => $objectType,
                'items' => $entities
            ];
            «IF hasCategorisableEntities»
                if ($hasCategories) {
                    $templateParameters['properties'] = $categoryProperties;
                }
            «ENDIF»

            $templateParameters = $this->«IF targets('3.0')»controllerHelper«ELSE»get('«appService».controller_helper')«ENDIF»->addTemplateParameters($properties['objectType'], $templateParameters, 'block');

            return $this->renderView($template, $templateParameters);
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         «IF !targets('3.0')»
         *
         * @param array $properties The block properties
         *
         * @return string the template path
         «ENDIF»
         */
        protected function getDisplayTemplate(array $properties = [])«IF targets('3.0')»: string«ENDIF»
        {
            $templateFile = $properties['template'];
            if ('custom' === $templateFile && null !== $properties['customTemplate'] && '' !== $properties['customTemplate']) {
                $templateFile = $properties['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $properties['objectType'] . '_', $templateFile);
            «IF !targets('3.0')»
                $templating = $this->get('templating');
            «ENDIF»

            $templateOptions = [
                «IF generateListContentType && !targets('2.0')»
                    'ContentType/' . $templateForObjectType,
                «ENDIF»
                'Block/' . $templateForObjectType,
                «IF generateListContentType && !targets('2.0')»
                    'ContentType/' . $templateFile,
                «ENDIF»
                'Block/' . $templateFile,
                'Block/itemlist.html.twig'
            ];

            $template = '';
            foreach ($templateOptions as $templatePath) {
                if («IF targets('3.0')»$this->twigLoader«ELSE»$templating«ENDIF»->exists('@«appName»/' . $templatePath)) {
                    $template = '@«appName»/' . $templatePath;
                    break;
                }
            }

            return $template;
        }
    '''

    def private modify(Application it) '''
        public function getFormClassName()«IF targets('3.0')»: string«ENDIF»
        {
            return ItemListBlockType::class;
        }

        public function getFormOptions()«IF targets('3.0')»: array«ENDIF»
        {
            $objectType = '«leadingEntity.name.formatForCode»';
            «IF hasCategorisableEntities»
                «initListOfCategorisableEntities»
            «ENDIF»

            $request = $this->«IF targets('3.0')»requestStack«ELSE»get('request_stack')«ENDIF»->getCurrentRequest();
            if (null !== $request && $request->attributes->has('blockEntity')) {
                $blockEntity = $request->attributes->get('blockEntity');
                if (is_object($blockEntity) && method_exists($blockEntity, 'getProperties')) {
                    $blockProperties = $blockEntity->getProperties();
                    if (isset($blockProperties['objectType'])) {
                        $objectType = $blockProperties['objectType'];
                    } else {
                        // set default options for new block creation
                        $blockEntity->setProperties($this->getDefaults());
                    }
                }
            }

            return [
                'object_type' => $objectType«IF hasCategorisableEntities»,
                'is_categorisable' => in_array($objectType, $this->categorisableObjectTypes, true),
                'category_helper' => $this->«IF targets('3.0')»categoryHelper«ELSE»get('«appService».category_helper')«ENDIF»,
                'feature_activation_helper' => $this->«IF targets('3.0')»featureActivationHelper«ELSE»get('«appService».feature_activation_helper')«ENDIF»«ENDIF»
            ];
        }

        public function getFormTemplate()«IF targets('3.0')»: string«ENDIF»
        {
            return '@«appName»/Block/itemlist_modify.html.twig';
        }
    '''

    def private initListOfCategorisableEntities(Application it) '''
        $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
    '''

    def private listBlockImpl(Application it) '''
        namespace «appNamespace»\Block;

        use «appNamespace»\Block\Base\AbstractItemListBlock;

        /**
         * Generic item list block implementation class.
         */
        class ItemListBlock extends AbstractItemListBlock
        {
            // feel free to extend the item list block here
        }
    '''
}
