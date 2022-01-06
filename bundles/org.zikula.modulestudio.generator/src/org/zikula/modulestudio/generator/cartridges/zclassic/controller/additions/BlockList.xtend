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

        use Twig\Loader\LoaderInterface;
        use Zikula\BlocksModule\AbstractBlockHandler;
        use «appNamespace»\Block\Form\Type\ItemListBlockType;
        use «appNamespace»\Entity\Factory\EntityFactory;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\CategoryHelper;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        use «appNamespace»\Helper\ModelHelper;
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Generic item list block base class.
         */
        abstract class AbstractItemListBlock extends AbstractBlockHandler
        {
            «listBlockBaseImpl»
        }
    '''

    def private listBlockBaseImpl(Application it) '''
        /**
         * @var LoaderInterface
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
        «IF hasCategorisableEntities»
            /**
             * List of object types allowing categorisation.
             *
             * @var array
             */
            protected $categorisableObjectTypes;

        «ENDIF»
        public function getType(): string
        {
            return $this->trans('«name.formatForDisplayCapital» list');
        }

        «display»

        «getDisplayTemplate»

        «modify»

        public function getPropertyDefaults(): array
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 5,
                'template' => 'itemlist_display.html.twig',
                'customTemplate' => null,
                'filter' => '',
            ];
        }
        «IF hasCategorisableEntities»

            /**
             * Resolves category filter ids.
             */
            protected function resolveCategoryIds(array $properties = []): array
            {
                $primaryRegistry = $this->categoryHelper->getPrimaryProperty($properties['objectType']);
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

        /**
         * @required
         */
        public function setTwigLoader(LoaderInterface $twigLoader): void
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
    '''

    def private display(Application it) '''
        public function display(array $properties = []): string
        {
            «displayImpl»
        }
    '''

    def private displayImpl(Application it) '''
        // only show block content if the user has the required permissions
        if (!$this->hasPermission('«appName»:ItemListBlock:', $properties['title'] . '::', ACCESS_OVERVIEW)) {
            return '';
        }

        «IF hasCategorisableEntities»
            «initListOfCategorisableEntities»

        «ENDIF»
        «IF !isSystemModule»
            $contextArgs = ['name' => 'list'];
        «ENDIF»
        $allowedObjectTypes = $this->controllerHelper->getObjectTypes('block'«IF !isSystemModule», $contextArgs«ENDIF»);
        if (
            !isset($properties['objectType'])
            || !in_array($properties['objectType'], $allowedObjectTypes, true)
        ) {
            $properties['objectType'] = $this->controllerHelper->getDefaultObjectType('block'«IF !isSystemModule», $contextArgs«ENDIF»);
        }

        $objectType = $properties['objectType'];
        «IF hasCategorisableEntities»

            $hasCategories = in_array($objectType, $this->categorisableObjectTypes, true)
                && $this->featureActivationHelper->isEnabled(
                    FeatureActivationHelper::CATEGORIES,
                    $properties['objectType']
                )
            ;
            if ($hasCategories) {
                $categoryProperties = $this->resolveCategoryIds($properties);
            }
        «ENDIF»

        $repository = $this->entityFactory->getRepository($objectType);

        // create query
        $orderBy = $this->modelHelper->resolveSortParameter($objectType, $properties['sorting']);
        $qb = $repository->getListQueryBuilder($properties['filter'] ?? '', $orderBy);
        «IF hasCategorisableEntities»

            if ($hasCategories) {
                // apply category filters
                if (is_array($properties['categories']) && 0 < count($properties['categories'])) {
                    $qb = $this->categoryHelper->buildFilterClauses($qb, $objectType, $properties['categories']);
                }
            }
        «ENDIF»

        // get objects from database
        $currentPage = 1;
        $resultsPerPage = $properties['amount'];
        $paginator = $repository->retrieveCollectionResult($qb, true, $currentPage, $resultsPerPage);
        $entities = $paginator->getResults();

        // filter by permissions
        $entities = $this->permissionHelper->filterCollection(«IF !isSystemModule»$objectType, «ENDIF»$entities, ACCESS_READ);

        // set a block title
        if (empty($properties['title'])) {
            $properties['title'] = $this->trans('«name.formatForDisplayCapital» list');
        }

        $template = $this->getDisplayTemplate($properties);

        $templateParameters = [
            'vars' => $properties,
            'objectType' => $objectType,
            'items' => $entities,
        ];
        «IF hasCategorisableEntities»
            if ($hasCategories) {
                $templateParameters['properties'] = $categoryProperties;
            }
        «ENDIF»

        $templateParameters = $this->controllerHelper->addTemplateParameters(
            $properties['objectType'],
            $templateParameters,
            'block'
        );

        return $this->renderView($template, $templateParameters);
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         */
        protected function getDisplayTemplate(array $properties = []): string
        {
            $templateFile = $properties['template'];
            if (
                'custom' === $templateFile
                && null !== $properties['customTemplate']
                && '' !== $properties['customTemplate']
            ) {
                $templateFile = $properties['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $properties['objectType'] . '_', $templateFile);

            $templateOptions = [
                'Block/' . $templateForObjectType,
                'Block/' . $templateFile,
                'Block/itemlist.html.twig',
            ];

            $template = '';
            foreach ($templateOptions as $templatePath) {
                if ($this->twigLoader->exists('@«appName»/' . $templatePath)) {
                    $template = '@«appName»/' . $templatePath;
                    break;
                }
            }

            return $template;
        }
    '''

    def private modify(Application it) '''
        public function getFormClassName(): string
        {
            return ItemListBlockType::class;
        }

        public function getFormOptions(): array
        {
            $objectType = '«leadingEntity.name.formatForCode»';
            «IF hasCategorisableEntities»
                «initListOfCategorisableEntities»
            «ENDIF»
            «/* TODO remove the following block */»
            $request = $this->requestStack->getCurrentRequest();
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
                'category_helper' => $this->categoryHelper,
                'feature_activation_helper' => $this->featureActivationHelper«ENDIF»,
            ];
        }

        public function getFormTemplate(): string
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
