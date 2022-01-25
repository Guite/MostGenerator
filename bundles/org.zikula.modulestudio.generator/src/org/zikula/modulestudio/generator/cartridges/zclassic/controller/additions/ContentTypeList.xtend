package org.zikula.modulestudio.generator.cartridges.zclassic.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype.ContentTypeListType
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.ContentTypeListView
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ContentTypeList {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        if (!generateListContentType) {
            return
        }
        'Generating content type for multiple objects'.printIfNotTesting(fsa)
        fsa.generateClassPair('ContentType/ItemListType.php', contentTypeBaseClass, contentTypeImpl)
        new ContentTypeListType().generate(it, fsa)
        new ContentTypeListView().generate(it, fsa)
    }

    def private contentTypeBaseClass(Application it) '''
        namespace «appNamespace»\ContentType\Base;

        use Zikula\ExtensionsModule\ModuleInterface\Content\AbstractContentType;
        use «appNamespace»\ContentType\Form\Type\ItemListType as FormType;
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
         * Generic item list content type base class.
         */
        abstract class AbstractItemListType extends AbstractContentType
        {
            «contentTypeBaseImpl»
        }
    '''

    def private contentTypeBaseImpl(Application it) '''
        protected ControllerHelper $controllerHelper;

        protected ModelHelper $modelHelper;

        protected PermissionHelper $modulePermissionHelper;

        protected EntityFactory $entityFactory;

        «IF hasCategorisableEntities»
            protected FeatureActivationHelper $featureActivationHelper;

            protected CategoryHelper $categoryHelper;

            /**
             * List of object types allowing categorisation.
             */
            protected array $categorisableObjectTypes;

        «ENDIF»
        public function getIcon(): string
        {
            return 'th-list';
        }

        public function getTitle(): string
        {
            return $this->translator->trans('«name.formatForDisplayCapital» list');
        }

        public function getDescription(): string
        {
            return $this->translator->trans('Display a list of «name.formatForDisplay» objects.');
        }

        public function getDefaultData(): array
        {
            return [
                'objectType' => '«getLeadingEntity.name.formatForCode»',
                'sorting' => 'default',
                'amount' => 1,
                'template' => 'itemlist_display.html.twig',
                'customTemplate' => null,
                'filter' => '',
            ];
        }

        public function getData(): array
        {
            $data = parent::getData();

            «IF !isSystemModule»
                $contextArgs = ['name' => 'list'];
            «ENDIF»
            $allowedObjectTypes = $this->controllerHelper->getObjectTypes('contentType'«IF !isSystemModule», $contextArgs«ENDIF»);
            if (
                !isset($data['objectType'])
                || !in_array($data['objectType'], $allowedObjectTypes, true)
            ) {
                $data['objectType'] = $this->controllerHelper->getDefaultObjectType('contentType'«IF !isSystemModule», $contextArgs«ENDIF»);
            }

            if (!isset($data['template'])) {
                $data['template'] = 'itemlist_' . $data['objectType'] . '_display.html.twig';
            }
            «IF hasCategorisableEntities»

                $objectType = $data['objectType'];
                $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                    $primaryRegistry = $this->categoryHelper->getPrimaryProperty($objectType);
                    if (!isset($data['categories'])) {
                        $data['categories'] = [$primaryRegistry => []];
                    } else {
                        if (!is_array($data['categories'])) {
                            $data['categories'] = explode(',', $data['categories']);
                        }
                        if (count($data['categories']) > 0) {
                            $firstCategories = reset($data['categories']);
                            if (!is_array($firstCategories)) {
                                $firstCategories = [$firstCategories];
                            }
                            $data['categories'] = [$primaryRegistry => $firstCategories];
                        }
                    }
                }
            «ENDIF»
            $this->data = $data;

            return $data;
        }

        public function displayView(): string
        {
            $objectType = $this->data['objectType'];
            $repository = $this->entityFactory->getRepository($objectType);

            // create query
            $orderBy = $this->modelHelper->resolveSortParameter($this->data['objectType'], $this->data['sorting']);
            $qb = $repository->getListQueryBuilder($this->data['filter'] ?? '', $orderBy);
            «IF hasCategorisableEntities»

                $this->getData();
                if (in_array($objectType, $this->categorisableObjectTypes, true)) {
                    if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                        // apply category filters
                        if (is_array($this->data['categories']) && 0 < count($this->data['categories'])) {
                            $this->categoryHelper->applyFilters($qb, $objectType, $this->data['categories']);
                        }
                    }
                }
            «ENDIF»

            // get objects from database
            $currentPage = 1;
            $resultsPerPage = isset($this->data['amount']) ? $this->data['amount'] : 1;
            $paginator = $repository->retrieveCollectionResult($qb, true, $currentPage, $resultsPerPage);
            $entities = $paginator->getResults();

            // filter by permissions
            $entities = $this->modulePermissionHelper->filterCollection(«IF !isSystemModule»$objectType, «ENDIF»$entities, ACCESS_READ);

            $data = $this->data;
            $data['items'] = $entities;

            $data = $this->controllerHelper->addTemplateParameters($objectType, $data, 'contentType', []);
            $this->data = $data;

            return parent::displayView();
        }

        public function getViewTemplatePath(string $suffix = ''): string
        {
            $templateFile = $this->data['template'];
            if (
                'custom' === $templateFile
                && null !== $this->data['customTemplate']
                && '' !== $this->data['customTemplate']
            ) {
                $templateFile = $this->data['customTemplate'];
            }

            $templateForObjectType = str_replace('itemlist_', 'itemlist_' . $this->data['objectType'] . '_', $templateFile);

            $templateOptions = [
                'ContentType/' . $templateForObjectType,
                'ContentType/' . $templateFile,
                'ContentType/itemlist_display.html.twig',
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

        public function getEditFormClass(): string
        {
            return FormType::class;
        }

        public function getEditFormOptions($context): array
        {
            $options = parent::getEditFormOptions($context);
            $data = $this->getData();
            $options['object_type'] = $data['objectType'];
            «IF hasCategorisableEntities»
                $this->categorisableObjectTypes = [«FOR entity : getCategorisableEntities SEPARATOR ', '»'«entity.name.formatForCode»'«ENDFOR»];
                $options['is_categorisable'] = in_array($this->data['objectType'], $this->categorisableObjectTypes);
                $options['category_helper'] = $this->categoryHelper;
                $options['feature_activation_helper'] = $this->featureActivationHelper;
            «ENDIF»

            return $options;
        }

        #[Required]
        public function setControllerHelper(ControllerHelper $controllerHelper): void
        {
            $this->controllerHelper = $controllerHelper;
        }

        #[Required]
        public function setModelHelper(ModelHelper $modelHelper): void
        {
            $this->modelHelper = $modelHelper;
        }

        #[Required]
        public function setModulePermissionHelper(PermissionHelper $modulePermissionHelper): void
        {
            $this->modulePermissionHelper = $modulePermissionHelper;
        }

        #[Required]
        public function setEntityFactory(EntityFactory $entityFactory): void
        {
            $this->entityFactory = $entityFactory;
        }
        «IF hasCategorisableEntities»

            #[Required]
            public function setCategoryDependencies(
                CategoryHelper $categoryHelper,
                FeatureActivationHelper $featureActivationHelper
            ): void {
                $this->categoryHelper = $categoryHelper;
                $this->featureActivationHelper = $featureActivationHelper;
            }
        «ENDIF»
    '''

    def private contentTypeImpl(Application it) '''
        namespace «appNamespace»\ContentType;

        use «appNamespace»\ContentType\Base\AbstractItemListType;

        /**
         * Generic item list content type implementation class.
         */
        class ItemListType extends AbstractItemListType
        {
            // feel free to extend the content type here
        }
    '''
}
