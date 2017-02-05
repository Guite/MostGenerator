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

        «IF targets('1.4-dev')»
            use Doctrine\ORM\QueryBuilder;
            use Doctrine\ORM\Query\Expr\Composite;
            use Symfony\Bundle\FrameworkBundle\Templating\EngineInterface;
            use Symfony\Component\HttpFoundation\Request;
            use Symfony\Component\HttpFoundation\RequestStack;
            use Symfony\Component\HttpFoundation\Session\SessionInterface;
        «ENDIF»
        use Zikula\Core\RouteUrl;
        «IF targets('1.4-dev')»
            use Zikula\PermissionsModule\Api\PermissionApi;
            use Zikula\SearchModule\Entity\SearchResultEntity;
            use Zikula\SearchModule\SearchableInterface;
            use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;
        «ELSE»
            use Zikula\SearchModule\AbstractSearchable;
        «ENDIF»
        «IF targets('1.4-dev')»
            «IF hasCategorisableEntities»
                use «appNamespace»\Helper\CategoryHelper;
            «ENDIF»
            use «appNamespace»\Helper\ControllerHelper;
        «ENDIF»
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Search helper base class.
         */
        abstract class AbstractSearchHelper «IF targets('1.4-dev')»implements SearchableInterface«ELSE»extends AbstractSearchable«ENDIF»
        {
            «searchHelperBaseImpl»
        }
    '''

    def private searchHelperBaseImpl(Application it) '''
        «IF targets('1.4-dev')»
            /**
             * @var PermissionApi
             */
            protected $permissionApi;

            /**
             * @var EngineInterface
             */
            private $templateEngine;

            /**
             * @var SessionInterface
             */
            private $session;

            /**
             * @var Request
             */
            private $request;

            /**
             * @var «name.formatForCodeCapital»Factory
             */
            private $entityFactory;

            /**
             * @var ControllerHelper
             */
            private $controllerHelper;
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
             * @param PermissionApi    $permissionApi   PermissionApi service instance
             * @param EngineInterface  $templateEngine  Template engine service instance
             * @param SessionInterface $session         Session service instance
             * @param RequestStack     $requestStack    RequestStack service instance
             * @param «name.formatForCodeCapital»Factory $entityFactory EntityFactory service instance
             * @param ControllerHelper $controllerHelper ControllerHelper service instance
             «IF hasCategorisableEntities»
             * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
             * @param CategoryHelper   $categoryHelper CategoryHelper service instance
             «ENDIF»
             */
            public function __construct(
                PermissionApi $permissionApi,
                EngineInterface $templateEngine,
                SessionInterface $session,
                RequestStack $requestStack,
                «name.formatForCodeCapital»Factory $entityFactory,
                ControllerHelper $controllerHelper«IF hasCategorisableEntities»,
                FeatureActivationHelper $featureActivationHelper,
                CategoryHelper $categoryHelper
                «ENDIF»
            ) {
                $this->permissionApi = $permissionApi;
                $this->templateEngine = $templateEngine;
                $this->session = $session;
                $this->request = $requestStack->getCurrentRequest();
                $this->entityFactory = $entityFactory;
                $this->controllerHelper = $controllerHelper;
                «IF hasCategorisableEntities»
                    $this->featureActivationHelper = $featureActivationHelper;
                    $this->categoryHelper = $categoryHelper;
                «ENDIF»
            }

        «ENDIF»
        «getOptions»

        «getResults»
        «IF targets('1.4-dev')»

            «getErrors»

            «formatWhere»
        «ENDIF»
    '''

    def private getOptions(Application it) '''
        «val entitiesWithStrings = entities.filter[hasAbstractStringFieldsEntity]»
        /**
         * {@inheritdoc}
         */
        public function getOptions($active, $modVars = null)
        {
            «IF !targets('1.4-dev')»
                $permissionApi = $this->container->get('zikula_permissions_module.api.permission');

            «ENDIF»
            if (!$«IF targets('1.4-dev')»this->«ENDIF»permissionApi->hasPermission('«appName»::', '::', ACCESS_READ)) {
                return '';
            }

            $templateParameters = [];

            $searchTypes = ['«entitiesWithStrings.map[name.formatForCode].join('\', \'')»'];
            foreach ($searchTypes as $searchType) {
                $templateParameters['active_' . $searchType] = !isset($args['«appName.toFirstLower»SearchTypes']) || in_array($searchType, $args['«appName.toFirstLower»SearchTypes']);
            }

            «IF targets('1.4-dev')»
                return $this->templateEngine->renderResponse('@«appName»/Search/options.html.twig', $templateParameters)->getContent();
            «ELSE»
                return $this->getContainer()->get('twig')->render('@«appName»/Search/options.html.twig', $templateParameters);
            «ENDIF»
        }
    '''

    def private getResults(Application it) '''
        /**
         * {@inheritdoc}
         */
        public function getResults(array $words, $searchType = 'AND', $modVars = null)
        {
            «IF !targets('1.4-dev')»
                $permissionApi = $this->container->get('zikula_permissions_module.api.permission');
                «IF hasCategorisableEntities»
                    $featureActivationHelper = $this->container->get('«appService».feature_activation_helper');
                «ENDIF»
                $request = $this->container->get('request_stack')->getCurrentRequest();

            «ENDIF»
            if (!$«IF targets('1.4-dev')»this->«ENDIF»permissionApi->hasPermission('«appName»::', '::', ACCESS_READ)) {
                return [];
            }
            «IF !targets('1.4-dev')»

                // save session id as it is used when inserting search results below
                $sessionId = $this->container->get('session')->getId();
            «ENDIF»

            // initialise array for results
            $results = [];

            // retrieve list of activated object types
            $searchTypes = isset($modVars['objectTypes']) ? (array)$modVars['objectTypes'] : [];
            if (!is_array($searchTypes) || !count($searchTypes)) {
                if ($this->request->isMethod('GET')) {
                    $searchTypes = $this->request->query->get('«appName.toFirstLower»SearchTypes', []);
                } elseif ($this->request->isMethod('POST')) {
                    $searchTypes = $this->request->request->get('«appName.toFirstLower»SearchTypes', []);
                }
            }

            «IF !targets('1.4-dev')»
                $controllerHelper = $this->container->get('«appService».controller_helper');
            «ENDIF»
            $allowedTypes = $«IF targets('1.4-dev')»this->«ENDIF»controllerHelper->getObjectTypes('helper', ['helper' => 'search', 'action' => 'getResults']);

            foreach ($searchTypes as $objectType) {
                if (!in_array($objectType, $allowedTypes)) {
                    continue;
                }

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

                $repository = $this->«IF targets('1.4-dev')»entityFactory«ELSE»container->get('«appService».entity_factory')«ENDIF»->getRepository($objectType);

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

                $descriptionField = $repository->getDescriptionFieldName();

                $entitiesWithDisplayAction = ['«getAllEntities.filter[hasDisplayAction].map[name.formatForCode].join('\', \'')»'];

                foreach ($entities as $entity) {
                    $urlArgs = $entity->createUrlArgs();
                    $hasDisplayAction = in_array($objectType, $entitiesWithDisplayAction);

                    $instanceId = $entity->createCompositeIdentifier();
                    // perform permission check
                    if (!$«IF targets('1.4-dev')»this->«ENDIF»permissionApi->hasPermission('«appName»:' . ucfirst($objectType) . ':', $instanceId . '::', ACCESS_OVERVIEW)) {
                        continue;
                    }
                    «IF hasCategorisableEntities»
                        if (in_array($objectType, ['«getCategorisableEntities.map[e|e.name.formatForCode].join('\', \'')»'])) {
                            if ($«IF targets('1.4-dev')»this->«ENDIF»featureActivationHelper->isEnabled(FeatureActivationHelper::CATEGORIES, $objectType)) {
                                if (!$this->«IF targets('1.4-dev')»categoryHelper«ELSE»container->get('«appService».category_helper')«ENDIF»->hasPermission($entity)) {
                                    continue;
                                }
                            }
                        }
                    «ENDIF»

                    $description = !empty($descriptionField) ? $entity[$descriptionField] : '';
                    $created = isset($entity['createdBy']) ? $entity['createdBy'] : null;

                    $urlArgs['_locale'] = (null !== $languageField && !empty($entity[$languageField])) ? $entity[$languageField] : $this->request->getLocale();

                    $displayUrl = $hasDisplayAction ? new RouteUrl('«appName.formatForDB»_' . $objectType . '_display', $urlArgs) : '';

                    «IF targets('1.4-dev')»
                        $result = new SearchResultEntity();
                        $result->setTitle($entity->getTitleFromDisplayPattern())
                            ->setText($description)
                            ->setModule('«appName»')
                            ->setCreated($created)
                            ->setSesid($this->session->getId())
                            ->setUrl($displayUrl);
                        $results[] = $result;
                    «ELSE»
                        $results[] = [
                            'title' => $entity->getTitleFromDisplayPattern(),
                            'text' => $description,
                            'module' => '«appName»',
                            'sesid' => $sessionId,
                            'created' => $created,
                            'url' => $displayUrl
                        ];
                    «ENDIF»
                }
            }

            return $results;
        }
    '''

    def private getErrors(Application it) '''
        /**
         * {@inheritdoc}
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
