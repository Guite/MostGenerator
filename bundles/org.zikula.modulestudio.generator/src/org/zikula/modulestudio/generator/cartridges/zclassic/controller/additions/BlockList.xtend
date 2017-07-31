package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.ListBlock
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.BlocksView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class BlockList {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating block for multiple objects')
        generateClassPair(fsa, getAppSourceLibPath + 'Block/ItemListBlock.php',
            fh.phpFileContent(it, listBlockBaseClass), fh.phpFileContent(it, listBlockImpl)
        )
        new BlocksView().generate(it, fsa)
        // form type class
        new ListBlock().generate(it, fsa)
    }

    def private listBlockBaseClass(Application it) '''
        namespace «appNamespace»\Block\Base;

        use Zikula\BlocksModule\AbstractBlockHandler;
        use Zikula\Core\AbstractBundle;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»
        use «appNamespace»\Block\Form\Type\ItemListBlockType;

        /**
         * Generic item list block base class.
         */
        abstract class AbstractItemListBlock extends AbstractBlockHandler
        {
            «listBlockBaseImpl»
        }
    '''

    def private listBlockBaseImpl(Application it) '''
        «IF hasCategorisableEntities»
            /**
             * List of object types allowing categorisation.
             *
             * @var array
             */
            protected $categorisableObjectTypes;

        «ENDIF»
        «IF hasCategorisableEntities»
            /**
             * ItemListBlock constructor.
             *
             * @param AbstractBundle $bundle An AbstractBundle instance
             *
             * @throws \InvalidArgumentException
             */
            public function __construct(AbstractBundle $bundle)
            {
                parent::__construct($bundle);

                $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
            }

        «ENDIF»
        «display»

        «getDisplayTemplate»

        «modify»

        /**
         * Returns default settings for this block.
         *
         * @return array The default settings
         */
        protected function getDefaults()
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 5,
                'template' => 'itemlist_display.html.twig',
                'customTemplate' => '',
                'filter' => ''
            ];
        }

        «IF hasCategorisableEntities»

            /**
             * Resolves category filter ids.
             *
             * @param array $properties The block properties array
             *
             * @return array The updated block properties
             */
            protected function resolveCategoryIds(array $properties)
            {
                if (!isset($properties['catIds'])) {
                    $categoryHelper = $this->get('«appService».category_helper');
                    $primaryRegistry = $categoryHelper->getPrimaryProperty($properties['objectType']);
                    $properties['catIds'] = [$primaryRegistry => []];
                } elseif (!is_array($properties['catIds'])) {
                    $properties['catIds'] = explode(',', $properties['catIds']);
                }

                return $properties;
            }
        «ENDIF»
    '''

    def private display(Application it) '''
        /**
         * Display the block content.
         *
         * @param array $properties The block properties array
         *
         * @return array|string
         */
        public function display(array $properties)
        {
            // only show block content if the user has the required permissions
            if (!$this->hasPermission('«appName»:ItemListBlock:', "$properties[title]::", ACCESS_OVERVIEW)) {
                return false;
            }

            // set default values for all params which are not properly set
            $defaults = $this->getDefaults();
            $properties = array_merge($defaults, $properties);
            «IF hasCategorisableEntities»

                $featureActivationHelper = $this->get('«appService».feature_activation_helper');
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties['objectType'])) {
                    $properties = $this->resolveCategoryIds($properties);
                }
            «ENDIF»

            $controllerHelper = $this->get('«appService».controller_helper');
            $contextArgs = ['name' => 'list'];
            if (!isset($properties['objectType']) || !in_array($properties['objectType'], $controllerHelper->getObjectTypes('block', $contextArgs))) {
                $properties['objectType'] = $controllerHelper->getDefaultObjectType('block', $contextArgs);
            }

            $objectType = $properties['objectType'];

            $repository = $this->get('«appService».entity_factory')->getRepository($objectType);

            // create query
            $orderBy = $this->get('«appService».model_helper')->resolveSortParameter($objectType, $properties['sorting']);
            $qb = $repository->genericBaseQuery($properties['filter'], $orderBy);
            «IF hasCategorisableEntities»

                // fetch category registries
                $catProperties = null;
                if (in_array($objectType, $this->categorisableObjectTypes)) {
                    if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties['objectType'])) {
                        $categoryHelper = $this->get('«appService».category_helper');
                        $catProperties = $categoryHelper->getAllProperties($objectType);
                        // apply category filters
                        if (is_array($properties['catIds']) && count($properties['catIds']) > 0) {
                            $qb = $categoryHelper->buildFilterClauses($qb, $objectType, $properties['catIds']);
                        }
                    }
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = $properties['amount'];
            $query = $repository->getSelectWherePaginatedQuery($qb, $currentPage, $resultsPerPage);
            try {
                list($entities, $objectCount) = $repository->retrieveCollectionResult($query, true);
            } catch (\Exception $exception) {
                $entities = [];
                $objectCount = 0;
            }
            «IF hasCategorisableEntities»

                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                    $entities = $this->get('«appService».category_helper')->filterEntitiesByPermission($entities);
                }
            «ENDIF»

            // set a block title
            if (empty($properties['title'])) {
                $properties['title'] = $this->__('«appName» items');
            }

            $template = $this->getDisplayTemplate($properties);

            $templateParameters = [
                'vars' => $properties,
                'objectType' => $objectType,
                'items' => $entities
            ];
            «IF hasCategorisableEntities»
                if ($featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $properties['objectType'])) {
                    $templateParameters['properties'] = $properties;
                }
            «ENDIF»

            $templateParameters = $this->get('«appService».controller_helper')->addTemplateParameters($properties['objectType'], $templateParameters, 'block', []);

            return $this->renderView($template, $templateParameters);
        }
    '''

    def private getDisplayTemplate(Application it) '''
        /**
         * Returns the template used for output.
         *
         * @param array $properties The block properties array
         *
         * @return string the template path
         */
        protected function getDisplayTemplate(array $properties)
        {
            $templateFile = $properties['template'];
            if ($templateFile == 'custom') {
                $templateFile = $properties['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $properties['objectType'] . '_', $templateFile);
            $templating = $this->get('templating');

            $templateOptions = [
                'ContentType/' . $templateForObjectType,
                'Block/' . $templateForObjectType,
                'ContentType/' . $templateFile,
                'Block/' . $templateFile,
                'Block/itemlist.html.twig'
            ];

            $template = '';
            foreach ($templateOptions as $templatePath) {
                if ($templating->exists('@«appName»/' . $templatePath)) {
                    $template = '@«appName»/' . $templatePath;
                    break;
                }
            }

            return $template;
        }
    '''

    def private modify(Application it) '''
        /**
         * Returns the fully qualified class name of the block's form class.
         *
         * @return string Template path
         */
        public function getFormClassName()
        {
            return ItemListBlockType::class;
        }

        /**
         * Returns any array of form options.
         *
         * @return array Options array
         */
        public function getFormOptions()
        {
            $objectType = '«leadingEntity.name.formatForCode»';

            $request = $this->get('request_stack')->getCurrentRequest();
            if ($request->attributes->has('blockEntity')) {
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
                'is_categorisable' => in_array($objectType, $this->categorisableObjectTypes),
                'category_helper' => $this->get('«appService».category_helper'),
                'feature_activation_helper' => $this->get('«appService».feature_activation_helper')«ENDIF»
            ];
        }

        /**
         * Returns the template used for rendering the editing form.
         *
         * @return string Template path
         */
        public function getFormTemplate()
        {
            return '@«appName»/Block/itemlist_modify.html.twig';
        }
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
