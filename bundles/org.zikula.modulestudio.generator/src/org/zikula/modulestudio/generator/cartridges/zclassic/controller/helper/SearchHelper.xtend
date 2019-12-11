package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.UploadField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class SearchHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for search integration'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/SearchHelper.php', searchHelperBaseClass, searchHelperImpl)
    }

    def private searchHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use Doctrine\ORM\Query\Expr\Composite;
        use Symfony\Component\Form\Extension\Core\Type\CheckboxType;
        use Symfony\Component\Form\Extension\Core\Type\HiddenType;
        use Symfony\Component\Form\FormBuilderInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Common\Translator\TranslatorTrait;
        use Zikula\Core\RouteUrl;
        use Zikula\SearchModule\Entity\SearchResultEntity;
        use Zikula\SearchModule\SearchableInterface;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\ControllerHelper;
        use «appNamespace»\Helper\EntityDisplayHelper;
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Search helper base class.
         */
        abstract class AbstractSearchHelper implements SearchableInterface
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        use TranslatorTrait;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var EntityFactory
         */
        protected $entityFactory;

        /**
         * @var ControllerHelper
         */
        protected $controllerHelper;

        /**
         * @var EntityDisplayHelper
         */
        protected $entityDisplayHelper;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;

        public function __construct(
            TranslatorInterface $translator,
            RequestStack $requestStack,
            EntityFactory $entityFactory,
            ControllerHelper $controllerHelper,
            EntityDisplayHelper $entityDisplayHelper,
            PermissionHelper $permissionHelper
        ) {
            $this->setTranslator($translator);
            $this->requestStack = $requestStack;
            $this->entityFactory = $entityFactory;
            $this->controllerHelper = $controllerHelper;
            $this->entityDisplayHelper = $entityDisplayHelper;
            $this->permissionHelper = $permissionHelper;
        }

        «setTranslatorMethod»

        «amendForm»

        «getResults»

        «val entitiesWithStrings = getAllEntities.filter[hasAbstractStringFieldsEntity]»
        /**
         * Returns list of supported search types.
         «IF !targets('3.0')»
         *
         * @return array List of search types
         «ENDIF»
         */
        protected function getSearchTypes()«IF targets('3.0')»: array«ENDIF»
        {
            $searchTypes = [
                «FOR entity : entitiesWithStrings»
                    '«appName.toFirstLower»«entity.nameMultiple.formatForCodeCapital»' => [
                        'value' => '«entity.name.formatForCode»',
                        'label' => $this->__('«entity.nameMultiple.formatForDisplayCapital»'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)
                    ]«IF entity != entitiesWithStrings.last»,«ENDIF»
                «ENDFOR»
            ];

            $allowedTypes = $this->controllerHelper->getObjectTypes(
                'helper',
                ['helper' => 'search', 'action' => 'getSearchTypes']
            );
            $allowedSearchTypes = [];
            foreach ($searchTypes as $searchType => $typeInfo) {
                if (!in_array($typeInfo['value'], $allowedTypes, true)) {
                    continue;
                }
                if (!$this->permissionHelper->hasComponentPermission($typeInfo['value'], ACCESS_READ)) {
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
        public function amendForm(FormBuilderInterface $builder)«IF targets('3.0')»: void«ENDIF»
        {
            if (!$this->permissionHelper->hasPermission(ACCESS_READ)) {
                return;
            }

            $builder->add('active', HiddenType::class, [
                'data' => true
            ]);

            $searchTypes = $this->getSearchTypes();

            foreach ($searchTypes as $searchType => $typeInfo) {
                $builder->add('active_' . $searchType, CheckboxType::class, [
                    'data' => true,
                    'value' => $typeInfo['value'],
                    'label' => $typeInfo['label'],
                    'label_attr' => ['class' => 'checkbox-inline'],
                    'required' => false
                ]);
            }
        }
    '''

    def private getResults(Application it) '''
        public function getResults(array $words, «IF targets('3.0')»string «ENDIF»$searchType = 'AND', «IF targets('3.0')»array «ENDIF»$modVars = null)«IF targets('3.0')»: array«ENDIF»
        {
            if (!$this->permissionHelper->hasPermission(ACCESS_READ)) {
                return [];
            }

            // initialise array for results
            $results = [];

            // retrieve list of activated object types
            $searchTypes = $this->getSearchTypes();
            $entitiesWithDisplayAction = ['«getAllEntities.filter[hasDisplayAction].map[name.formatForCode].join('\', \'')»'];
            $request = $this->requestStack->getCurrentRequest();

            foreach ($searchTypes as $searchTypeCode => $typeInfo) {
                $isActivated = false;
                $searchSettings = $request->query->get('zikulasearchmodule_search', []);
                $moduleActivationInfo = $searchSettings['modules'];
                if (isset($moduleActivationInfo['«appName»'])) {
                    $moduleActivationInfo = $moduleActivationInfo['«appName»'];
                    $isActivated = isset($moduleActivationInfo['active_' . $searchTypeCode]);
                }
                if (!$isActivated) {
                    continue;
                }

                $objectType = $typeInfo['value'];
                $whereArray = [];
                $languageField = null;
                switch ($objectType) {
                    «FOR entity : entities.filter[hasAbstractStringFieldsEntity]»
                        case '«entity.name.formatForCode»':
                            «FOR field : entity.getAbstractStringFieldsEntity»
                                $whereArray[] = 'tbl.«field.name.formatForCode»«IF field instanceof UploadField»FileName«ENDIF»';
                            «ENDFOR»
                            «IF entity.hasLanguageFieldsEntity»
                                $languageField = '«entity.getLanguageFieldsEntity.head.name.formatForCode»';
                            «ENDIF»
                            break;
                    «ENDFOR»
                }

                $repository = $this->entityFactory->getRepository($objectType);

                // build the search query without any joins
                $qb = $repository->getListQueryBuilder('', '', false);

                // build where expression for given search type
                $whereExpr = $this->formatWhere($qb, $words, $whereArray, $searchType);
                $qb->andWhere($whereExpr);

                $query = $repository->getQueryFromBuilder($qb);

                // set a sensitive limit
                $query->setFirstResult(0)
                      ->setMaxResults(250);

                // fetch the results
                $entities = $query->getResult();

                if (0 === count($entities)) {
                    continue;
                }

                $descriptionFieldName = $this->entityDisplayHelper->getDescriptionFieldName($objectType);
                $hasDisplayAction = in_array($objectType, $entitiesWithDisplayAction, true);

                $session = $request->getSession();
                foreach ($entities as $entity) {
                    if (!$this->permissionHelper->mayRead($entity)) {
                        continue;
                    }

                    $description = !empty($descriptionFieldName) ? strip_tags($entity[$descriptionFieldName]) : '';
                    «IF targets('3.0')»
                        $created = $entity['createdDate'] ?? null;
                    «ELSE»
                        $created = isset($entity['createdDate']) ? $entity['createdDate'] : null;
                    «ENDIF»

                    $formattedTitle = $this->entityDisplayHelper->getFormattedTitle($entity);
                    $displayUrl = null;
                    if ($hasDisplayAction) {
                        $urlArgs = $entity->createUrlArgs();
                        $urlArgs['_locale'] = null !== $languageField && !empty($entity[$languageField])
                            ? $entity[$languageField]
                            : $request->getLocale()
                        ;
                        $displayUrl = new RouteUrl('«appName.formatForDB»_' . strtolower($objectType) . '_display', $urlArgs);
                    }

                    $result = new SearchResultEntity();
                    $result->setTitle($formattedTitle)
                        ->setText($description)
                        ->setModule(«IF targets('3.0')»$this->getBundleName()«ELSE»'«appName»'«ENDIF»)
                        ->setCreated($created)
                        ->setSesid($session->getId())
                    ;
                    if (null !== $displayUrl) {
                        $result->setUrl($displayUrl);
                    }
                    $results[] = $result;
                }
            }

            return $results;
        }
    '''

    def private getErrors(Application it) '''
        public function getErrors()«IF targets('3.0')»: array«ENDIF»
        {
            return [];
        }
    '''

    def private formatWhere(Application it) '''
        /**
         * Construct a QueryBuilder Where orX|andX Expr instance.
         «IF !targets('3.0')»
         *
         * @param QueryBuilder $qb
         * @param string[] $words List of words to query for
         * @param string[] $fields List of fields to include into query
         * @param string $searchtype AND|OR|EXACT
         *
         * @return null|Composite
         «ENDIF»
         */
        protected function formatWhere(
            QueryBuilder $qb,
            array $words = [],
            array $fields = [],
            «IF targets('3.0')»string «ENDIF»$searchtype = 'AND'
        )«IF targets('3.0')»: ?Composite«ENDIF» {
            if (empty($words) || empty($fields)) {
                return null;
            }

            $method = 'OR' === $searchtype ? 'orX' : 'andX';
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
        «IF targets('3.0')»

            public function getBundleName(): string
            {
                return '«appName»';
            }
        «ENDIF»
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
