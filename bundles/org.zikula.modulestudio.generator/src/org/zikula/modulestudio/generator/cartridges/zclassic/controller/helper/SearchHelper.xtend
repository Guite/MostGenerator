package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.cartridges.zclassic.view.additions.SearchView
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SearchHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for search integration')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/SearchHelper.php',
            fh.phpFileContent(it, searchHelperBaseClass), fh.phpFileContent(it, searchHelperImpl)
        )
        new SearchView().generate(it, fsa)
    }

    def private searchHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use Doctrine\ORM\Query\Expr\Composite;
        «IF targets('1.5')»
            use Symfony\Component\Form\Extension\Core\Type\CheckboxType;
            use Symfony\Component\Form\Extension\Core\Type\HiddenType;
            use Symfony\Component\Form\FormBuilderInterface;
        «ELSE»
            use Symfony\Bundle\FrameworkBundle\Templating\EngineInterface;
        «ENDIF»
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Component\HttpFoundation\Session\SessionInterface;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\RouteUrl;
        use Zikula\PermissionsModule\Api\«IF targets('1.5')»ApiInterface\PermissionApiInterface«ELSE»PermissionApi«ENDIF»;
        use Zikula\SearchModule\Entity\SearchResultEntity;
        «IF targets('1.5')»
            use Zikula\SearchModule\SearchableInterface;
        «ELSE»
            use Zikula\SearchModule\AbstractSearchable;
        «ENDIF»
        use «appNamespace»\Entity\Factory\EntityFactory;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\CategoryHelper;
        «ENDIF»
        use «appNamespace»\Helper\ControllerHelper;
        use «appNamespace»\Helper\EntityDisplayHelper;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Search helper base class.
         */
        abstract class AbstractSearchHelper «IF targets('1.5')»implements SearchableInterface«ELSE»extends AbstractSearchable«ENDIF»
        {
            «searchHelperBaseImpl»
        }
    '''

    def private searchHelperBaseImpl(Application it) '''
        use TranslatorTrait;

        /**
         * @var PermissionApi«IF targets('1.5')»Interface«ENDIF»
         */
        protected $permissionApi;
        «IF !targets('1.5')»

            /**
             * @var EngineInterface
             */
            private $templateEngine;
        «ENDIF»

        /**
         * @var SessionInterface
         */
        private $session;

        /**
         * @var Request
         */
        private $request;

        /**
         * @var EntityFactory
         */
        private $entityFactory;

        /**
         * @var ControllerHelper
         */
        private $controllerHelper;

        /**
         * @var EntityDisplayHelper
         */
        protected $entityDisplayHelper;
        «IF hasCategorisableEntities»

            /**
             * @var FeatureActivationHelper
             */
            private $featureActivationHelper;

            /**
             * @var CategoryHelper
             */
            private $categoryHelper;
        «ENDIF»

        /**
         * SearchHelper constructor.
         *
         * @param TranslatorInterface $translator          Translator service instance
         * @param PermissionApi«IF targets('1.5')»Interface«ENDIF»    $permissionApi   PermissionApi service instance
         «IF !targets('1.5')»
         * @param EngineInterface     $templateEngine      Template engine service instance
         «ENDIF»
         * @param SessionInterface    $session             Session service instance
         * @param RequestStack        $requestStack        RequestStack service instance
         * @param EntityFactory       $entityFactory       EntityFactory service instance
         * @param ControllerHelper    $controllerHelper    ControllerHelper service instance
         * @param EntityDisplayHelper $entityDisplayHelper EntityDisplayHelper service instance
         «IF hasCategorisableEntities»
         * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
         * @param CategoryHelper      $categoryHelper      CategoryHelper service instance
         «ENDIF»
         */
        public function __construct(
            TranslatorInterface $translator,
            PermissionApi«IF targets('1.5')»Interface«ENDIF» $permissionApi,
            «IF !targets('1.5')»
                EngineInterface $templateEngine,
            «ENDIF»
            SessionInterface $session,
            RequestStack $requestStack,
            EntityFactory $entityFactory,
            ControllerHelper $controllerHelper,
            EntityDisplayHelper $entityDisplayHelper«IF hasCategorisableEntities»,
            FeatureActivationHelper $featureActivationHelper,
            CategoryHelper $categoryHelper
            «ENDIF»
        ) {
            $this->setTranslator($translator);
            $this->permissionApi = $permissionApi;
            «IF !targets('1.5')»
                $this->templateEngine = $templateEngine;
            «ENDIF»
            $this->session = $session;
            $this->request = $requestStack->getCurrentRequest();
            $this->entityFactory = $entityFactory;
            $this->controllerHelper = $controllerHelper;
            $this->entityDisplayHelper = $entityDisplayHelper;
            «IF hasCategorisableEntities»
                $this->featureActivationHelper = $featureActivationHelper;
                $this->categoryHelper = $categoryHelper;
            «ENDIF»
        }

        «setTranslatorMethod»

        «IF targets('1.5')»
            «amendForm»
        «ELSE»
            «getOptions»
        «ENDIF»

        «getResults»

        «val entitiesWithStrings = getAllEntities.filter[hasAbstractStringFieldsEntity]»
        /**
         * Returns list of supported search types.
         *
         * @return array
         */
        protected function getSearchTypes()
        {
            $searchTypes = [
                «FOR entity : entitiesWithStrings»
                    '«appName.toFirstLower»«entity.nameMultiple.formatForCodeCapital»' => [
                        'value' => '«entity.name.formatForCode»',
                        'label' => $this->__('«entity.nameMultiple.formatForDisplayCapital»')
                    ]«IF entity != entitiesWithStrings.last»,«ENDIF»
                «ENDFOR»
            ];

            $allowedTypes = $this->controllerHelper->getObjectTypes('helper', ['helper' => 'search', 'action' => 'getSearchTypes']);
            $allowedSearchTypes = [];
            foreach ($searchTypes as $searchType => $typeInfo) {
                if (!in_array($typeInfo['value'], $allowedTypes)) {
                    continue;
                }
                $allowedSearchTypes[$searchType] = $typeInfo;
            }

            return $allowedSearchTypes;
        }

        «getErrors»

        «formatWhere»
    '''

    def private amendForm(Application it) '''
        /**
         * @inheritDoc
         */
        public function amendForm(FormBuilderInterface $builder)
        {
            if (!$this->permissionApi->hasPermission('«appName»::', '::', ACCESS_READ)) {
                return '';
            }

            $builder->add('active', HiddenType::class, [
                'data' => true
            ]);

            $searchTypes = $this->getSearchTypes();

            foreach ($searchTypes as $searchType => $typeInfo) {
                $builder->add('active_' . $searchType, CheckboxType::class, [
                    'value' => $typeInfo['value'],
                    'label' => $typeInfo['label'],
                    'label_attr' => ['class' => 'checkbox-inline'],
                    'required' => false
                ]);
            }
        }
    '''

    def private getOptions(Application it) '''
        /**
         * @inheritDoc
         */
        public function getOptions($active, $modVars = null)
        {
            if (!$this->permissionApi->hasPermission('«appName»::', '::', ACCESS_READ)) {
                return '';
            }

            $templateParameters = [];

            $searchTypes = $this->getSearchTypes();

            foreach ($searchTypes as $searchType => $typeInfo) {
                $templateParameters['active_' . $typeInfo['value']] = true;
            }

            return $this->templateEngine->renderResponse('@«appName»/Search/options.html.twig', $templateParameters)->getContent();
        }
    '''

    def private getResults(Application it) '''
        /**
         * @inheritDoc
         */
        public function getResults(array $words, $searchType = 'AND', $modVars = null)
        {
            if (!$this->permissionApi->hasPermission('«appName»::', '::', ACCESS_READ)) {
                return [];
            }

            // initialise array for results
            $results = [];

            // retrieve list of activated object types
            «IF targets('1.5')»
                $searchTypes = $this->getSearchTypes();
            «ELSE»
                $searchTypes = isset($modVars['objectTypes']) ? (array)$modVars['objectTypes'] : [];
                if (!is_array($searchTypes) || !count($searchTypes)) {
                    if ($this->request->isMethod('GET')) {
                        $searchTypes = $this->request->query->get('«appName.toFirstLower»SearchTypes', []);
                    } elseif ($this->request->isMethod('POST')) {
                        $searchTypes = $this->request->request->get('«appName.toFirstLower»SearchTypes', []);
                    }
                }
            «ENDIF»

            foreach ($searchTypes as «IF targets('1.5')»$searchTypeCode => $typeInfo«ELSE»$objectType«ENDIF») {
                «IF targets('1.5')»
                    $objectType = $typeInfo['value'];
                    $isActivated = false;
                    if ($this->request->isMethod('GET')) {
                        $isActivated = $this->request->query->get('active_' . $searchTypeCode, false);
                    } elseif ($this->request->isMethod('POST')) {
                        $isActivated = $this->request->request->get('active_' . $searchTypeCode, false);
                    }
                    if (!$isActivated) {
                        continue;
                    }
                «ENDIF»
                $whereArray = [];
                $languageField = null;
                switch ($objectType) {
                    «FOR entity : entities.filter[hasAbstractStringFieldsEntity]»
                        case '«entity.name.formatForCode»':
                            «FOR field : entity.getAbstractStringFieldsEntity»
                                $whereArray[] = 'tbl.«field.name.formatForCode»';
                            «ENDFOR»
                            «IF entity.hasLanguageFieldsEntity»
                                $languageField = '«entity.getLanguageFieldsEntity.head.name.formatForCode»';
                            «ENDIF»
                            break;
                    «ENDFOR»
                }

                $repository = $this->entityFactory->getRepository($objectType);

                // build the search query without any joins
                $qb = $repository->genericBaseQuery('', '', false);

                // build where expression for given search type
                $whereExpr = $this->formatWhere($qb, $words, $whereArray, $searchType);
                $qb->andWhere($whereExpr);

                $query = $qb->getQuery();

                // set a sensitive limit
                $query->setFirstResult(0)
                      ->setMaxResults(250);

                // fetch the results
                $entities = $query->getResult();

                if (count($entities) == 0) {
                    continue;
                }

                $descriptionFieldName = $this->entityDisplayHelper->getDescriptionFieldName($objectType);

                $entitiesWithDisplayAction = ['«getAllEntities.filter[hasDisplayAction].map[name.formatForCode].join('\', \'')»'];

                foreach ($entities as $entity) {
                    $urlArgs = $entity->createUrlArgs();
                    $hasDisplayAction = in_array($objectType, $entitiesWithDisplayAction);

                    $instanceId = $entity->createCompositeIdentifier();
                    // perform permission check
                    if (!$this->permissionApi->hasPermission('«appName»:' . ucfirst($objectType) . ':', $instanceId . '::', ACCESS_OVERVIEW)) {
                        continue;
                    }
                    «IF hasCategorisableEntities»

                        if (in_array($objectType, ['«getCategorisableEntities.map[e|e.name.formatForCode].join('\', \'')»'])) {
                            if ($this->featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                                if (!$this->categoryHelper->hasPermission($entity)) {
                                    continue;
                                }
                            }
                        }
                    «ENDIF»

                    $description = !empty($descriptionFieldName) ? $entity[$descriptionFieldName] : '';
                    $created = isset($entity['createdDate']) ? $entity['createdDate'] : null;

                    $urlArgs['_locale'] = (null !== $languageField && !empty($entity[$languageField])) ? $entity[$languageField] : $this->request->getLocale();

                    $formattedTitle = $this->entityDisplayHelper->getFormattedTitle($entity);
                    $displayUrl = $hasDisplayAction ? new RouteUrl('«appName.formatForDB»_' . $objectType . '_display', $urlArgs) : '';

                    $result = new SearchResultEntity();
                    $result->setTitle($formattedTitle)
                        ->setText($description)
                        ->setModule('«appName»')
                        ->setCreated($created)
                        ->setSesid($this->session->getId())
                        ->setUrl($displayUrl);
                    $results[] = $result;
                }
            }

            return $results;
        }
    '''

    def private getErrors(Application it) '''
        /**
         * @inheritDoc
         */
        public function getErrors()
        {
            return [];
        }
    '''

    def private formatWhere(Application it) '''
        /**
         * Construct a QueryBuilder Where orX|andX Expr instance.
         *
         * @param QueryBuilder $qb
         * @param array $words the words to query for
         * @param array $fields
         * @param string $searchtype AND|OR|EXACT
         *
         * @return null|Composite
         */
        protected function formatWhere(QueryBuilder $qb, array $words, array $fields, $searchtype = 'AND')
        {
            if (empty($words) || empty($fields)) {
                return null;
            }

            $method = ($searchtype == 'OR') ? 'orX' : 'andX';
            /** @var $where Composite */
            $where = $qb->expr()->$method();
            $i = 1;
            foreach ($words as $word) {
                $subWhere = $qb->expr()->orX();
                foreach ($fields as $field) {
                    $expr = $qb->expr()->like($field, "?$i");
                    $subWhere->add($expr);
                    $qb->setParameter($i, '%' . $word . '%');
                    $i++;
                }
                $where->add($subWhere);
            }

            return $where;
        }
    '''

    def private searchHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractSearchHelper;

        /**
         * Search helper implementation class.
         */
        class SearchHelper extends AbstractSearchHelper
        {
            // feel free to extend the search helper here
        }
    '''
}
