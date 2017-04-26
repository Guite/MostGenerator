package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.extensions.WorkflowExtensions

class CollectionFilterHelper {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils
    extension WorkflowExtensions = new WorkflowExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for filtering entity collections')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/CollectionFilterHelper.php',
            fh.phpFileContent(it, collectionFilterHelperBaseClass), fh.phpFileContent(it, collectionFilterHelperImpl)
        )
    }

    def private collectionFilterHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasStandardFieldEntities»
            use Zikula\UsersModule\Api\«IF targets('1.5')»ApiInterface\CurrentUserApiInterface«ELSE»CurrentUserApi«ENDIF»;
            «IF targets('1.5')»
                use Zikula\UsersModule\Constant as UsersConstant;
            «ENDIF»
        «ENDIF»
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\CategoryHelper;
        «ENDIF»

        /**
         * Entity collection filter helper base class.
         */
        abstract class AbstractCollectionFilterHelper
        {
            /**
             * @var Request
             */
            protected $request;
            «IF hasStandardFieldEntities»

                /**
                 * @var CurrentUserApi«IF targets('1.5')»Interface«ENDIF»
                 */
                protected $currentUserApi;
            «ENDIF»

            /**
             * @var «name.formatForCodeCapital»Factory
             */
            protected $entityFactory;
            «IF hasCategorisableEntities»

                /**
                 * @var CategoryHelper
                 */
                private $categoryHelper;
            «ENDIF»

            /**
             * @var bool
             */
            protected $showOnlyOwnEntries = false;

            /**
             * CollectionFilterHelper constructor.
             *
             * @param RequestStack «IF hasCategorisableEntities»  «ENDIF»$requestStack «IF hasCategorisableEntities»       «ENDIF»RequestStack service instance
             «IF hasStandardFieldEntities»
             * @param CurrentUserApi«IF targets('1.5')»Interface«ELSE»       «ENDIF» $currentUserApi        CurrentUserApi service instance
             «ENDIF»
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
             «IF hasCategorisableEntities»
             * @param CategoryHelper $categoryHelper      CategoryHelper service instance
             «ENDIF»
             * @param bool           $showOnlyOwnEntries  Fallback value to determine whether only own entries should be selected or not
             */
            public function __construct(
                RequestStack $requestStack,
                «IF hasStandardFieldEntities»
                    CurrentUserApi«IF targets('1.5')»Interface«ENDIF» $currentUserApi,
                «ENDIF»
                «name.formatForCodeCapital»Factory $entityFactory,
                «IF hasCategorisableEntities»
                    CategoryHelper $categoryHelper,
                «ENDIF»
                $showOnlyOwnEntries)
            {
                $this->request = $requestStack->getCurrentRequest();
                «IF hasStandardFieldEntities»
                    $this->currentUserApi = $currentUserApi;
                «ENDIF»
                $this->entityFactory = $entityFactory;
                «IF hasCategorisableEntities»
                    $this->categoryHelper = $categoryHelper;
                «ENDIF»
                $this->showOnlyOwnEntries = $showOnlyOwnEntries;
            }

            «collectionFilterHelperBaseImpl»
        }
    '''

    def private collectionFilterHelperBaseImpl(Application it) '''
        /**
         * Returns an array of additional template variables for view quick navigation forms.
         *
         * @param string $objectType Name of treated entity type
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args       Additional arguments
         *
         * @return array List of template variables to be assigned
         */
        public function getViewQuickNavParameters($objectType = '', $context = '', $args = [])
        {
            if (!in_array($context, ['controllerAction', 'api', 'actionHandler', 'block', 'contentType'])) {
                $context = 'controllerAction';
            }

            «FOR entity : getAllEntities»
                if ($objectType == '«entity.name.formatForCode»') {
                    return $this->getViewQuickNavParametersFor«entity.name.formatForCodeCapital»($context, $args);
                }
            «ENDFOR»

            return [];
        }

        /**
         * Adds quick navigation related filter options as where clauses.
         *
         * @param string       $objectType Name of treated entity type
         * @param QueryBuilder $qb         Query builder to be enhanced
         *
         * @return QueryBuilder Enriched query builder instance
         */
        public function addCommonViewFilters($objectType = '', QueryBuilder $qb)
        {
            «FOR entity : getAllEntities»
                if ($objectType == '«entity.name.formatForCode»') {
                    return $this->addCommonViewFiltersFor«entity.name.formatForCodeCapital»($qb);
                }
            «ENDFOR»

            return $qb;
        }

        /**
         * Adds default filters as where clauses.
         *
         * @param string       $objectType Name of treated entity type
         * @param QueryBuilder $qb         Query builder to be enhanced
         * @param array        $parameters List of determined filter options
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function applyDefaultFilters($objectType = '', QueryBuilder $qb, $parameters = [])
        {
            «FOR entity : getAllEntities»
                if ($objectType == '«entity.name.formatForCode»') {
                    return $this->applyDefaultFiltersFor«entity.name.formatForCodeCapital»($qb, $parameters);
                }
            «ENDFOR»

            return $qb;
        }
        «FOR entity : getAllEntities»

            «entity.getViewQuickNavParameters»
        «ENDFOR»
        «FOR entity : getAllEntities»

            «entity.addCommonViewFilters»
        «ENDFOR»
        «FOR entity : getAllEntities»

            «entity.applyDefaultFilters»
        «ENDFOR»
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
        protected function getViewQuickNavParametersFor«name.formatForCodeCapital»($context = '', $args = [])
        {
            $parameters = [];

            «IF categorisable»
                $parameters['catId'] = $this->request->query->get('catId', '');
                $parameters['catIdList'] = $this->categoryHelper->retrieveCategoriesFromRequest('«name.formatForCode»', 'GET');
            «ENDIF»
            «IF !getBidirectionalIncomingJoinRelationsWithOneSource.empty»
                «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                    «val sourceAliasName = relation.getRelationAliasName(false)»
                    $parameters['«sourceAliasName»'] = $this->request->query->get('«sourceAliasName»', 0);
                «ENDFOR»
            «ENDIF»
            «IF hasListFieldsEntity»
                «FOR field : getListFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR field : getUserFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = (int) $this->request->query->get('«fieldName»', 0);
                «ENDFOR»
            «ENDIF»
            «IF hasCountryFieldsEntity»
                «FOR field : getCountryFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «FOR field : getLanguageFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasLocaleFieldsEntity»
                «FOR field : getLocaleFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                $parameters['q'] = $this->request->query->get('q', '');
            «ENDIF»
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $this->request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»

            return $parameters;
        }
    '''

    def private addCommonViewFilters(Entity it) '''
        /**
         * Adds quick navigation related filter options as where clauses.
         *
         * @param QueryBuilder $qb Query builder to be enhanced
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function addCommonViewFiltersFor«name.formatForCodeCapital»(QueryBuilder $qb)
        {
            $routeName = $this->request->get('_route');
            if (false !== strpos($routeName, 'edit')) {«/* fix for #547 */»
                return $qb;
            }

            $parameters = $this->getViewQuickNavParametersFor«name.formatForCodeCapital»();
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
                        $qb = $this->categoryHelper->buildFilterClauses($qb, '«name.formatForCode»', $v);
                «ENDIF»
                «IF categorisable»} else«ENDIF»if (in_array($k, ['q', 'searchterm'])) {
                    // quick search
                    if (!empty($v)) {
                        $qb = $this->addSearchFilter($qb, $v);
                    }
                «IF hasBooleanFieldsEntity»
                } elseif (in_array($k, [«FOR field : getBooleanFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»])) {
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
                            «IF hasUserFieldsEntity»
                                if (in_array($k, ['«getUserFieldsEntity.map[name.formatForCode].join('\', \'')»'])) {
                                    $qb->leftJoin('tbl.' . $k, 'tbl' . ucfirst($k))
                                       ->andWhere('tbl' . ucfirst($k) . '.uid = :' . $k)
                                       ->setParameter($k, $v);
                                } else {
                                    $qb->andWhere('tbl.' . $k . ' = :' . $k)
                                       ->setParameter($k, $v);
                                }
                            «ELSE»
                                $qb->andWhere('tbl.' . $k . ' = :' . $k)
                                   ->setParameter($k, $v);
                            «ENDIF»
                       }
                    }
                }
            }

            $qb = $this->applyDefaultFiltersFor«name.formatForCodeCapital»($qb, $parameters);

            return $qb;
        }
    '''

    def private applyDefaultFilters(Entity it) '''
        /**
         * Adds default filters as where clauses.
         *
         * @param QueryBuilder $qb         Query builder to be enhanced
         * @param array        $parameters List of determined filter options
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function applyDefaultFiltersFor«name.formatForCodeCapital»(QueryBuilder $qb, $parameters = [])
        {
            «IF ownerPermission || standardFields»
                $showOnlyOwnEntries = (bool)$this->request->query->getInt('own', $this->showOnlyOwnEntries);

            «ENDIF»
            «IF hasVisibleWorkflow»
                $routeName = $this->request->get('_route');
                $isAdminArea = false !== strpos($routeName, '«application.appName.toLowerCase»_«name.formatForDisplay.toLowerCase»_admin');
                if ($isAdminArea) {
                    return $qb;
                }

                if (!in_array('workflowState', array_keys($parameters)) || empty($parameters['workflowState'])) {
                    // per default we show approved «nameMultiple.formatForDisplay» only
                    $onlineStates = ['approved'];
                    «IF ownerPermission»
                        if ($showOnlyOwnEntries) {
                            // allow the owner to see his deferred «nameMultiple.formatForDisplay»
                            $onlineStates[] = 'deferred';
                        }
                    «ENDIF»
                    $qb->andWhere('tbl.workflowState IN (:onlineStates)')
                       ->setParameter('onlineStates', $onlineStates);
                }
            «ENDIF»
            «IF standardFields»

                if ($showOnlyOwnEntries) {
                    $repository = $this->entityFactory->getRepository('«name.formatForCode»');
                    $userId = $this->currentUserApi->isLoggedIn() ? $this->currentUserApi->get('uid') : «IF application.targets('1.5')»UsersConstant::USER_ID_ANONYMOUS«ELSE»1«ENDIF»;
                    $qb = $repository->addCreatorFilter($qb, $userId);
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
            $startDate = $this->request->query->get('«startDateField.name.formatForCode»', «startDateField.defaultValueForNow»);
            $qb->andWhere('«whereClauseForDateRangeFilter('<=', startDateField, 'startDate')»')
               ->setParameter('startDate', $startDate);
        «ENDIF»
        «IF null !== endDateField»
            $endDate = $this->request->query->get('«endDateField.name.formatForCode»', «endDateField.defaultValueForNow»);
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

    def private collectionFilterHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractCollectionFilterHelper;

        /**
         * Entity collection filter helper implementation class.
         */
        class CollectionFilterHelper extends AbstractCollectionFilterHelper
        {
            // feel free to extend the collection filter helper here
        }
    '''
}
