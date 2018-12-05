package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class CollectionFilterHelper {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for filtering entity collections'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/CollectionFilterHelper.php', collectionFilterHelperBaseClass, collectionFilterHelperImpl)
    }

    def private collectionFilterHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasStandardFieldEntities»
            use Zikula\UsersModule\Api\ApiInterface\CurrentUserApiInterface;
            use Zikula\UsersModule\Constant as UsersConstant;
        «ENDIF»
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        «IF hasCategorisableEntities»
            use «appNamespace»\Helper\CategoryHelper;
        «ENDIF»
        use «appNamespace»\Helper\PermissionHelper;

        /**
         * Entity collection filter helper base class.
         */
        abstract class AbstractCollectionFilterHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;
        «IF hasStandardFieldEntities»

            /**
             * @var CurrentUserApiInterface
             */
            protected $currentUserApi;
        «ENDIF»
        «IF hasCategorisableEntities»

            /**
             * @var CategoryHelper
             */
            protected $categoryHelper;
        «ENDIF»

        /**
         * @var bool Fallback value to determine whether only own entries should be selected or not
         */
        protected $showOnlyOwnEntries = false;
        «IF supportLocaleFilter»

            /**
             * @var bool Whether to apply a locale-based filter or not
             */
            protected $filterDataByLocale = false;
        «ENDIF»

        /**
         * CollectionFilterHelper constructor.
         *
         * @param RequestStack $requestStack RequestStack service instance
         * @param PermissionHelper $permissionHelper PermissionHelper service instance
         «IF hasStandardFieldEntities»
         * @param CurrentUserApiInterface $currentUserApi CurrentUserApi service instance
         «ENDIF»
         «IF hasCategorisableEntities»
         * @param CategoryHelper $categoryHelper CategoryHelper service instance
         «ENDIF»
         * @param boolean $showOnlyOwnEntries Fallback value to determine whether only own entries should be selected or not
         «IF supportLocaleFilter»
         * @param boolean $filterDataByLocale Whether to apply a locale-based filter or not
         «ENDIF»
         */
        public function __construct(
            RequestStack $requestStack,
            PermissionHelper $permissionHelper,
            «IF hasStandardFieldEntities»
                CurrentUserApiInterface $currentUserApi,
            «ENDIF»
            «IF hasCategorisableEntities»
                CategoryHelper $categoryHelper,
            «ENDIF»
            $showOnlyOwnEntries«IF supportLocaleFilter»,
            $filterDataByLocale«ENDIF»
        ) {
            $this->requestStack = $requestStack;
            $this->permissionHelper = $permissionHelper;
            «IF hasStandardFieldEntities»
                $this->currentUserApi = $currentUserApi;
            «ENDIF»
            «IF hasCategorisableEntities»
                $this->categoryHelper = $categoryHelper;
            «ENDIF»
            $this->showOnlyOwnEntries = $showOnlyOwnEntries;
            «IF supportLocaleFilter»
                $this->filterDataByLocale = $filterDataByLocale;
            «ENDIF»
        }

        /**
         * Returns an array of additional template variables for view quick navigation forms.
         *
         * @param string $objectType Name of treated entity type
         * @param string $context    Usage context (allowed values: controllerAction, api, actionHandler, block, contentType)
         * @param array  $args       Additional arguments
         *
         * @return array List of template variables to be assigned
         */
        public function getViewQuickNavParameters($objectType = '', $context = '', array $args = [])
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
        public function addCommonViewFilters($objectType, QueryBuilder $qb)
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
        public function applyDefaultFilters($objectType, QueryBuilder $qb, array $parameters = [])
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
        «FOR entity : getAllEntities.filter[hasStartOrEndDateField]»

            «entity.applyDateRangeFilter»
        «ENDFOR»

        «addSearchFilter»
        «IF hasStandardFieldEntities»

            «addCreatorFilter»
        «ENDIF»
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
        protected function getViewQuickNavParametersFor«name.formatForCodeCapital»($context = '', array $args = [])
        {
            $parameters = [];
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return $parameters;
            }

            «IF categorisable»
                $parameters['catId'] = $request->query->get('catId', '');
                $parameters['catIdList'] = $this->categoryHelper->retrieveCategoriesFromRequest('«name.formatForCode»', 'GET');
            «ENDIF»
            «IF !getBidirectionalIncomingJoinRelationsWithOneSource.empty»
                «FOR relation: getBidirectionalIncomingJoinRelationsWithOneSource»
                    «val sourceAliasName = relation.getRelationAliasName(false)»
                    $parameters['«sourceAliasName»'] = $request->query->get('«sourceAliasName»', 0);
                «ENDFOR»
            «ENDIF»
            «IF hasListFieldsEntity»
                «FOR field : getListFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR field : getUserFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $request->query->getInt('«fieldName»', 0);
                «ENDFOR»
            «ENDIF»
            «IF hasCountryFieldsEntity»
                «FOR field : getCountryFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasLanguageFieldsEntity»
                «FOR field : getLanguageFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasLocaleFieldsEntity»
                «FOR field : getLocaleFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $request->query->get('«fieldName»', '');
                «ENDFOR»
            «ENDIF»
            «IF hasAbstractStringFieldsEntity»
                $parameters['q'] = $request->query->get('q', '');
            «ENDIF»
            «IF hasBooleanFieldsEntity»
                «FOR field : getBooleanFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $parameters['«fieldName»'] = $request->query->get('«fieldName»', '');
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
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return $qb;
            }
            $routeName = $request->get('_route');
            if (false !== strpos($routeName, 'edit')) {«/* fix for #547 */»
                return $qb;
            }

            $parameters = $this->getViewQuickNavParametersFor«name.formatForCodeCapital»();
            foreach ($parameters as $k => $v) {
                «IF categorisable»
                    if ($k == 'catId') {
                        if (intval($v) > 0) {
                            // single category filter
                            $qb->andWhere('tblCategories.category = :category')
                               ->setParameter('category', $v);
                        }
                        continue;
                    }
                    if ($k == 'catIdList') {
                        // multi category filter«/* old 
                        $qb->andWhere('tblCategories.category IN (:categories)')
                           ->setParameter('categories', $v);*/»
                        $qb = $this->categoryHelper->buildFilterClauses($qb, '«name.formatForCode»', $v);
                        continue;
                    }
                «ENDIF»
                if (in_array($k, ['q', 'searchterm'])) {
                    // quick search
                    if (!empty($v)) {
                        $qb = $this->addSearchFilter('«name.formatForCode»', $qb, $v);
                    }
                    continue;
                }
                «IF hasBooleanFieldsEntity»
                    if (in_array($k, [«FOR field : getBooleanFieldsEntity SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»])) {
                        // boolean filter
                        if ($v == 'no') {
                            $qb->andWhere('tbl.' . $k . ' = 0');
                        } elseif ($v == 'yes' || $v == '1') {
                            $qb->andWhere('tbl.' . $k . ' = 1');
                        }
                        continue;
                    }
                «ENDIF»

                if (is_array($v)) {
                    continue;
                }

                // field filter
                if ((!is_numeric($v) && $v != '') || (is_numeric($v) && $v > 0)) {
                    if ($k == 'workflowState' && substr($v, 0, 1) == '!') {
                        $qb->andWhere('tbl.' . $k . ' != :' . $k)
                           ->setParameter($k, substr($v, 1, strlen($v)-1));
                    } elseif (substr($v, 0, 1) == '%') {
                        $qb->andWhere('tbl.' . $k . ' LIKE :' . $k)
                           ->setParameter($k, '%' . substr($v, 1) . '%');
                    «IF !getListFieldsEntity.filter[multiple].empty»
                        } elseif (in_array($k, [«FOR field : getListFieldsEntity.filter[multiple] SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»])) {
                            // multi list filter
                            $qb->andWhere('tbl.' . $k . ' LIKE :' . $k)
                               ->setParameter($k, '%' . $v . '%');
                    «ENDIF»
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
        protected function applyDefaultFiltersFor«name.formatForCodeCapital»(QueryBuilder $qb, array $parameters = [])
        {
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return $qb;
            }
            $routeName = $request->get('_route');
            $isAdminArea = false !== strpos($routeName, '«application.appName.toLowerCase»_«name.formatForDB»_admin');
            if ($isAdminArea) {
                return $qb;
            }
            «IF ownerPermission || standardFields»

                $showOnlyOwnEntries = (bool)$request->query->getInt('own', $this->showOnlyOwnEntries);
            «ENDIF»

            if (!in_array('workflowState', array_keys($parameters)) || empty($parameters['workflowState'])) {
                // per default we show approved «nameMultiple.formatForDisplay» only
                $onlineStates = ['approved'];
                «IF ownerPermission»
                    if ($showOnlyOwnEntries) {
                        // allow the owner to see his «nameMultiple.formatForDisplay»
                        $onlineStates[] = 'deferred';
                        $onlineStates[] = 'trashed';
                    }
                «ENDIF»
                $qb->andWhere('tbl.workflowState IN (:onlineStates)')
                   ->setParameter('onlineStates', $onlineStates);
            }
            «IF standardFields»

                if ($showOnlyOwnEntries) {
                    $qb = $this->addCreatorFilter($qb);
                }
            «ENDIF»
            «IF hasLanguageFieldsEntity || hasLocaleFieldsEntity»

                if (true === (bool)$this->filterDataByLocale) {
                    $allowedLocales = ['', $request->getLocale()];
                    «FOR field : getLanguageFieldsEntity»
                        «val fieldName = field.name.formatForCode»
                        if (!in_array('«fieldName»', array_keys($parameters)) || empty($parameters['«fieldName»'])) {
                            $qb->andWhere('tbl.«fieldName» IN (:current«fieldName.toFirstUpper»)')
                               ->setParameter('current«fieldName.toFirstUpper»', $allowedLocales);
                        }
                    «ENDFOR»
                    «FOR field : getLocaleFieldsEntity»
                        «val fieldName = field.name.formatForCode»
                        if (!in_array('«fieldName»', array_keys($parameters)) || empty($parameters['«fieldName»'])) {
                            $qb->andWhere('tbl.«fieldName» IN (:current«fieldName.toFirstUpper»)')
                               ->setParameter('current«fieldName.toFirstUpper»', $allowedLocales);
                        }
                    «ENDFOR»
                }
            «ENDIF»
            «IF hasStartOrEndDateField»

                $qb = $this->applyDateRangeFilterFor«name.formatForCodeCapital»($qb);
            «ENDIF»
            «FOR relation : getBidirectionalIncomingJoinRelations»«relation.addDateRangeFilterForJoin(false)»«ENDFOR»
            «FOR relation : getOutgoingJoinRelations»«relation.addDateRangeFilterForJoin(true)»«ENDFOR»

            return $qb;
        }
    '''

    def addDateRangeFilterForJoin(JoinRelationship it, Boolean useTarget) {
        val relatedEntity = if (useTarget) target else source
        if (relatedEntity instanceof Entity && (relatedEntity as Entity).hasStartOrEndDateField) {
            val aliasName = 'tbl' + getRelationAliasName(useTarget).formatForCodeCapital
            '''
                if (in_array('«aliasName»', $qb->getAllAliases())) {
                    $qb = $this->applyDateRangeFilterFor«relatedEntity.name.formatForCodeCapital»($qb, '«aliasName»');
                }
            '''
        }
    }

    def private applyDateRangeFilter(Entity it) '''
        /**
         * Applies «IF hasStartDateField»start «IF hasEndDateField»and «ENDIF»«ENDIF»«IF hasEndDateField»end «ENDIF»date filters for selecting «nameMultiple.formatForDisplay».
         *
         * @param QueryBuilder $qb    Query builder to be enhanced
         * @param string       $alias Table alias
         *
         * @return QueryBuilder Enriched query builder instance
         */
        protected function applyDateRangeFilterFor«name.formatForCodeCapital»(QueryBuilder $qb, $alias = 'tbl')
        {
            $request = $this->requestStack->getCurrentRequest();
            «IF hasStartDateField»
                $startDate = $request->query->get('«startDateField.name.formatForCode»', «startDateField.defaultValueForNow»);
                $qb->andWhere(«startDateField.whereClauseForDateRangeFilter('<=', 'startDate')»)
                   ->setParameter('startDate', $startDate);
                «IF null !== endDateField»

                «ENDIF»
            «ENDIF»
            «IF hasEndDateField»
                $endDate = $request->query->get('«endDateField.name.formatForCode»', «endDateField.defaultValueForNow»);
                $qb->andWhere(«endDateField.whereClauseForDateRangeFilter('>=', 'endDate')»)
                   ->setParameter('endDate', $endDate);
            «ENDIF»

            return $qb;
        }
    '''

    def private addSearchFilter(Application it) '''
        /**
         * Adds a where clause for search query.
         *
         * @param string       $objectType Name of treated entity type
         * @param QueryBuilder $qb         Query builder to be enhanced
         * @param string       $fragment   The fragment to search for
         *
         * @return QueryBuilder Enriched query builder instance
         */
        public function addSearchFilter($objectType, QueryBuilder $qb, $fragment = '')
        {
            if ($fragment == '') {
                return $qb;
            }

            $filters = [];
            $parameters = [];

            «FOR entity : getAllEntities»
                if ($objectType == '«entity.name.formatForCode»') {
                    «val searchFields = entity.getDisplayFields.filter[isContainedInSearch]»
                    «FOR field : searchFields»
                        $filters[] = 'tbl.«field.name.formatForCode»«IF field instanceof UploadField»FileName«ENDIF» «IF field.isTextSearch»LIKE«ELSE»=«ENDIF» :search«field.name.formatForCodeCapital»';
                        $parameters['search«field.name.formatForCodeCapital»'] = «IF field.isTextSearch»'%' . $fragment . '%'«ELSE»$fragment«ENDIF»;
                    «ENDFOR»
                }
            «ENDFOR»

            $qb->andWhere('(' . implode(' OR ', $filters) . ')');

            foreach ($parameters as $parameterName => $parameterValue) {
                $qb->setParameter($parameterName, $parameterValue);
            }

            return $qb;
        }
    '''

    def private addCreatorFilter(Application it) '''
        /**
         * Adds a filter for the createdBy field.
         *
         * @param QueryBuilder $qb     Query builder to be enhanced
         * @param integer      $userId The user identifier used for filtering
         *
         * @return QueryBuilder Enriched query builder instance
         */
        public function addCreatorFilter(QueryBuilder $qb, $userId = null)
        {
            if (null === $userId) {
                $userId = $this->currentUserApi->isLoggedIn() ? $this->currentUserApi->get('uid') : UsersConstant::USER_ID_ANONYMOUS;
            }

            if (is_array($userId)) {
                $qb->andWhere('tbl.createdBy IN (:userIds)')
                   ->setParameter('userIds', $userId);
            } else {
                $qb->andWhere('tbl.createdBy = :userId')
                   ->setParameter('userId', $userId);
            }

            return $qb;
        }
    '''

    def private whereClauseForDateRangeFilter(DerivedField it, String operator, String paramName) {
        val fieldName = name.formatForCode
        if (mandatory)
            '''$alias . '.«fieldName» «operator» :«paramName»'«''»'''
        else
            '''«''»'(' . $alias . '.«fieldName» «operator» :«paramName» OR ' . $alias . '.«fieldName» IS NULL)'«''»'''
    }

    def private isContainedInSearch(DerivedField it) {
        switch it {
            BooleanField: false
            UserField: false
            ArrayField: false
            ObjectField: false
            default: true
        }
    }

    def private isTextSearch(DerivedField it) {
        switch it {
            StringField: true
            TextField: true
            default: false
        }
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
