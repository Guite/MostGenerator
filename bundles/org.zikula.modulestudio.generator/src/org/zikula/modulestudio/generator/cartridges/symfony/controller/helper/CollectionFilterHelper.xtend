package org.zikula.modulestudio.generator.cartridges.symfony.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import org.zikula.modulestudio.generator.application.ImportList

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

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Doctrine\\ORM\\QueryBuilder',
            'Symfony\\Component\\HttpFoundation\\RequestStack',
            appNamespace + '\\Helper\\PermissionHelper'
        ])
        if (hasStandardFieldEntities) {
            imports.addAll(#[
                'Zikula\\UsersBundle\\Api\\ApiInterface\\CurrentUserApiInterface',
                'Zikula\\UsersBundle\\UsersConstant',
                appNamespace + '\\Helper\\CategoryHelper'
            ])
        }
        if (hasUserFields) {
            imports.addAll(#[
                'Zikula\\UsersBundle\\Entity\\User',
                'Zikula\\UsersBundle\\Repository\\UserRepositoryInterface'
            ])
        }
        imports
    }

    def private collectionFilterHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        «collectBaseImports.print»

        /**
         * Entity collection filter helper base class.
         */
        abstract class AbstractCollectionFilterHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        public function __construct(
            protected readonly RequestStack $requestStack,
            protected readonly PermissionHelper $permissionHelper,
            «IF hasStandardFieldEntities»
                protected readonly CurrentUserApiInterface $currentUserApi,
            «ENDIF»
            «IF hasUserFields»
                protected readonly UserRepositoryInterface $userRepository,
            «ENDIF»
            «IF hasCategorisableEntities»
                protected readonly CategoryHelper $categoryHelper,
            «ENDIF»
            protected readonly array $listViewConfig
        ) {
        }

        /**
         * Returns an array of additional template variables for view quick navigation forms.
         */
        public function getViewQuickNavParameters(string $objectType = '', string $context = '', array $args = []): array
        {
            if (!in_array($context, ['controllerAction', 'api', 'actionHandler'], true)) {
                $context = 'controllerAction';
            }

            «FOR entity : getAllEntities»
                if ('«entity.name.formatForCode»' === $objectType) {
                    return $this->getViewQuickNavParametersFor«entity.name.formatForCodeCapital»($context, $args);
                }
            «ENDFOR»

            return [];
        }

        /**
         * Adds quick navigation related filter options as where clauses.
         */
        public function addCommonViewFilters(string $objectType, QueryBuilder $qb): QueryBuilder
        {
            «FOR entity : getAllEntities»
                if ('«entity.name.formatForCode»' === $objectType) {
                    return $this->addCommonViewFiltersFor«entity.name.formatForCodeCapital»($qb);
                }
            «ENDFOR»

            return $qb;
        }

        /**
         * Adds default filters as where clauses.
         */
        public function applyDefaultFilters(string $objectType, QueryBuilder $qb, array $parameters = []): QueryBuilder
        {
            «FOR entity : getAllEntities»
                if ('«entity.name.formatForCode»' === $objectType) {
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
        «IF hasStandardFieldEntities»

            «addCreatorFilter»
        «ENDIF»
    '''

    def private getViewQuickNavParameters(Entity it) '''
        /**
         * Returns an array of additional template variables for view quick navigation forms.
         */
        protected function getViewQuickNavParametersFor«name.formatForCodeCapital»(string $context = '', array $args = []): array
        {
            $parameters = [];
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return $parameters;
            }
            «IF hasUserFieldsEntity»

                «FOR field : getUserFieldsEntity»
                    «val fieldName = field.name.formatForCode»
                    $«fieldName» = $request->query->getInt('«fieldName»', 0);
                «ENDFOR»
            «ENDIF»

            «IF categorisable»
                $parameters['catId'] = $request->query->get('catId', '');
                $parameters['catIdList'] = $this->categoryHelper->retrieveCategoriesFromRequest('«name.formatForCode»', 'GET');
            «ENDIF»
            «IF !getBidirectionalIncomingJoinRelations.filter[source instanceof Entity].empty»
                «FOR relation: getBidirectionalIncomingJoinRelations.filter[source instanceof Entity]»
                    «val sourceAliasName = relation.getRelationAliasName(false)»
                    $parameters['«sourceAliasName»'] = $request->query->get('«sourceAliasName»', 0);
                    if (is_object($parameters['«sourceAliasName»'])) {
                        $parameters['«sourceAliasName»'] = $parameters['«sourceAliasName»']->getId();
                    }
                «ENDFOR»
            «ENDIF»
            «IF !getOutgoingJoinRelations.filter[target instanceof Entity].empty»
                «FOR relation: getOutgoingJoinRelations.filter[target instanceof Entity]»
                    «val targetAliasName = relation.getRelationAliasName(true)»
                    $parameters['«targetAliasName»'] = $request->query->get('«targetAliasName»', 0);
                    if (is_object($parameters['«targetAliasName»'])) {
                        $parameters['«targetAliasName»'] = $parameters['«targetAliasName»']->getId();
                    }
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
                    $parameters['«fieldName»'] = 0 < $«fieldName» ? $this->userRepository->find($«fieldName») : null;
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
         */
        protected function addCommonViewFiltersFor«name.formatForCodeCapital»(QueryBuilder $qb): QueryBuilder
        {
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return $qb;
            }
            $routeName = $request->get('_route', '');
            if (str_ends_with($routeName, 'edit')) {«/* fix for #547 */»
                return $qb;
            }

            $parameters = $this->getViewQuickNavParametersFor«name.formatForCodeCapital»();
            foreach ($parameters as $k => $v) {
                if (null === $v) {
                    continue;
                }
                «IF categorisable»
                    if ('catId' === $k) {
                        if (0 < (int) $v) {
                            // single category filter
                            $qb->andWhere('tblCategories.category = :category')
                               ->setParameter('category', $v);
                        }
                        continue;
                    }
                    if ('catIdList' === $k) {
                        // multi category filter«/* old 
                        $qb->andWhere('tblCategories.category IN (:categories)')
                           ->setParameter('categories', $v);*/»
                        $this->categoryHelper->applyFilters($qb, '«name.formatForCode»', $v);
                        continue;
                    }
                «ENDIF»
                «IF hasBooleanFieldsEntity»
                    if (in_array($k, ['«getBooleanFieldsEntity.map[name.formatForCode].join('\', \'')»'], true)) {
                        // boolean filter
                        if ('no' === $v) {
                            $qb->andWhere('tbl.' . $k . ' = 0');
                        } elseif ('yes' === $v || '1' === $v) {
                            $qb->andWhere('tbl.' . $k . ' = 1');
                        }
                        continue;
                    }
                «ENDIF»
                «IF !getBidirectionalIncomingJoinRelations.filter[source instanceof Entity].filter[isManySide(false)].empty»
                    if (in_array($k, ['«getBidirectionalIncomingJoinRelations.filter[source instanceof Entity].filter[isManySide(false)].map[getRelationAliasName(false)].join('\', \'')»']) && !empty($v)) {
                        // multi-valued source of incoming relation (many2many)
                        $qb->andWhere(
                            $qb->expr()->isMemberOf(':' . $k, 'tbl.' . $k)
                        )
                            ->setParameter($k, $v)
                        ;
                        continue;
                    }
                «ENDIF»
                «IF !getOutgoingJoinRelations.filter[source instanceof Entity].filter[isManySide(true)].empty»
                    if (in_array($k, ['«getOutgoingJoinRelations.filter[source instanceof Entity].filter[isManySide(true)].map[getRelationAliasName(true)].join('\', \'')»']) && !empty($v)) {
                        // multi-valued target of outgoing relation (one2many or many2many)
                        $qb->andWhere(
                            $qb->expr()->isMemberOf(':' . $k, 'tbl.' . $k)
                        )
                            ->setParameter($k, $v)
                        ;
                        continue;
                    }
                «ENDIF»

                if (is_array($v)) {
                    continue;
                }

                // field filter
                if ((!is_numeric($v) && '' !== $v) || (is_numeric($v) && 0 < $v)) {
                    «IF hasUserFieldsEntity»
                        if ($v instanceof User) {
                            $v = $v->getUid();
                        } else {
                            $v = (string) $v;
                        }
                    «ELSE»
                        $v = (string) $v;
                    «ENDIF»
                    if ('workflowState' === $k && 0 === mb_strpos($v, '!')) {
                        $qb->andWhere('tbl.' . $k . ' != :' . $k)
                           ->setParameter($k, mb_substr($v, 1));
                    } elseif (0 === mb_strpos($v, '%')) {
                        $qb->andWhere('tbl.' . $k . ' LIKE :' . $k)
                           ->setParameter($k, '%' . mb_substr($v, 1) . '%');
                    «IF !getListFieldsEntity.filter[multiple].empty»
                        } elseif (in_array($k, [«FOR field : getListFieldsEntity.filter[multiple] SEPARATOR ', '»'«field.name.formatForCode»'«ENDFOR»], true)) {
                            // multi list filter
                            $qb->andWhere('tbl.' . $k . ' LIKE :' . $k)
                               ->setParameter($k, '%' . $v . '%');
                    «ENDIF»
                    } else {
                        «IF hasUserFieldsEntity»
                            if (in_array($k, ['«getUserFieldsEntity.map[name.formatForCode].join('\', \'')»'], true)) {
                                if (!in_array('tbl' . ucfirst($k), $qb->getAllAliases(), true)) {
                                    $qb->leftJoin('tbl.' . $k, 'tbl' . ucfirst($k));
                                }
                                $qb->andWhere('tbl' . ucfirst($k) . '.uid = :' . $k)
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

            return $this->applyDefaultFiltersFor«name.formatForCodeCapital»($qb, $parameters);
        }
    '''

    def private applyDefaultFilters(Entity it) '''
        /**
         * Adds default filters as where clauses.
         */
        protected function applyDefaultFiltersFor«name.formatForCodeCapital»(QueryBuilder $qb, array $parameters = []): QueryBuilder
        {
            $request = $this->requestStack->getCurrentRequest();
            if (null === $request) {
                return $qb;
            }

            $routeName = $request->get('_route', '');
            $isAdminArea = false !== mb_strpos($routeName, '«application.appName.toLowerCase»_«name.formatForDB»_admin');
            «IF ownerPermission || standardFields»

                «IF standardFields»
                    $showOnlyOwnDefault = $isAdminArea ? false : $this->listViewConfig['show_only_own_entries'];
                    $showOnlyOwnEntries = (bool) $request->query->getInt('own', (int) $showOnlyOwnDefault);
                «ENDIF»
                «IF ownerPermission»
                    if (!$isAdminArea) {
                        $privateMode = $this->listViewConfig['«name.formatForSnakeCase»_private_mode'];
                        if ($privateMode) {
                            $showOnlyOwnEntries = true;
                        }
                    }
                «ENDIF»
                if ($showOnlyOwnEntries) {
                    $this->addCreatorFilter($qb);
                }
            «ENDIF»

            if ($isAdminArea) {
                return $qb;
            }

            if (!array_key_exists('workflowState', $parameters) || empty($parameters['workflowState'])) {
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
            «IF hasLanguageFieldsEntity || hasLocaleFieldsEntity»

                if ($this->listViewConfig['filter_data_by_locale']) {
                    $allowedLocales = ['', $request->getLocale()];
                    «FOR field : getLanguageFieldsEntity»
                        «val fieldName = field.name.formatForCode»
                        if (!array_key_exists('«fieldName»', $parameters) || empty($parameters['«fieldName»'])) {
                            $qb->andWhere('tbl.«fieldName» IN (:current«fieldName.toFirstUpper»)')
                               ->setParameter('current«fieldName.toFirstUpper»', $allowedLocales);
                        }
                    «ENDFOR»
                    «FOR field : getLocaleFieldsEntity»
                        «val fieldName = field.name.formatForCode»
                        if (!array_key_exists('«fieldName»', $parameters) || empty($parameters['«fieldName»'])) {
                            $qb->andWhere('tbl.«fieldName» IN (:current«fieldName.toFirstUpper»)')
                               ->setParameter('current«fieldName.toFirstUpper»', $allowedLocales);
                        }
                    «ENDFOR»
                }
            «ENDIF»
            «IF hasStartOrEndDateField»

                $this->applyDateRangeFilterFor«name.formatForCodeCapital»($qb);
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
                if (in_array('«aliasName»', $qb->getAllAliases(), true)) {
                    $this->applyDateRangeFilterFor«relatedEntity.name.formatForCodeCapital»($qb, '«aliasName»');
                }
            '''
        }
    }

    def private applyDateRangeFilter(Entity it) '''
        /**
         * Applies «IF hasStartDateField»start «IF hasEndDateField»and «ENDIF»«ENDIF»«IF hasEndDateField»end «ENDIF»date filters for selecting «nameMultiple.formatForDisplay».
         */
        protected function applyDateRangeFilterFor«name.formatForCodeCapital»(QueryBuilder $qb, string $alias = 'tbl'): void
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
        }
    '''

    def private addCreatorFilter(Application it) '''
        /**
         * Adds a filter for the createdBy field.
         */
        public function addCreatorFilter(QueryBuilder $qb, ?int $userId = null): void
        {
            if (null === $userId) {
                $userId = $this->currentUserApi->isLoggedIn()
                    ? (int) $this->currentUserApi->get('uid')
                    : UsersConstant::USER_ID_ANONYMOUS
                ;
            }

            $qb->andWhere('tbl.createdBy = :userId')
               ->setParameter('userId', $userId);
        }
    '''

    def private whereClauseForDateRangeFilter(DerivedField it, String operator, String paramName) {
        val fieldName = name.formatForCode
        if (mandatory)
            '''$alias . '.«fieldName» «operator» :«paramName»'«''»'''
        else
            '''«''»'(' . $alias . '.«fieldName» «operator» :«paramName» OR ' . $alias . '.«fieldName» IS NULL)'«''»'''
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
