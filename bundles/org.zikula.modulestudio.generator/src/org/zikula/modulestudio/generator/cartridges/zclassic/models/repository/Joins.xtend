package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Joins {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, Application app) '''
        /**
         * Helper method to add join selections.
         *
         * @return String Enhancement for select clause
         */
        protected function addJoinsToSelection()
        {
            $selection = '«FOR relation : getBidirectionalIncomingJoinRelations.filter[source.application == app]»«relation.addJoin(false, 'select')»«ENDFOR»«FOR relation : getOutgoingJoinRelations.filter[target.application == app]»«relation.addJoin(true, 'select')»«ENDFOR»';
            «IF hasJoinsToOtherApplications(app)»
                $kernel = \ServiceUtil::get('kernel');
                «FOR relation : getBidirectionalIncomingJoinRelations.filter[source.application != app]»
                    if ($kernel->isBundle('«relation.source.application.appName»')) {
                        $selection .= '«relation.addJoin(false, 'select')»';
                    }
                «ENDFOR»
                «FOR relation : getOutgoingJoinRelations.filter[target.application != app]»
                    if ($kernel->isBundle('«relation.target.application.appName»')) {
                        $selection .= '«relation.addJoin(true, 'select')»';
                    }
                «ENDFOR»
            «ENDIF»
            «IF categorisable»

                $selection = ', tblCategories';
            «ENDIF»

            return $selection;
        }

        /**
         * Helper method to add joins to from clause.
         *
         * @param QueryBuilder $qb Query builder instance used to create the query
         *
         * @return QueryBuilder The query builder enriched by additional joins
         */
        protected function addJoinsToFrom(QueryBuilder $qb)
        {
            «FOR relation : getBidirectionalIncomingJoinRelations.filter[source.application == app]»«relation.addJoin(false, 'from')»«ENDFOR»
            «FOR relation : getOutgoingJoinRelations.filter[target.application == app]»«relation.addJoin(true, 'from')»«ENDFOR»
            «IF hasJoinsToOtherApplications(app)»
                $kernel = \ServiceUtil::get('kernel');
                «FOR relation : getBidirectionalIncomingJoinRelations.filter[source.application != app]»
                    if ($kernel->isBundle('«relation.source.application.appName»')) {
                        «relation.addJoin(false, 'from')»
                    }
                «ENDFOR»
                «FOR relation : getOutgoingJoinRelations.filter[target.application != app]»
                    if ($kernel->isBundle('«relation.target.application.appName»')) {
                        «relation.addJoin(true, 'from')»
                    }
                «ENDFOR»
            «ENDIF»
            «IF categorisable»

                $qb->leftJoin('tbl.categories', 'tblCategories');
            «ENDIF»

            return $qb;
        }
    '''

    def private hasJoinsToOtherApplications(Entity it, Application app) {
        !getBidirectionalIncomingJoinRelations.filter[source.application != app].empty
        || !getOutgoingJoinRelations.filter[target.application != app].empty
    }

    def private addJoin(JoinRelationship it, Boolean incoming, String target) {
        val relationAliasName = getRelationAliasName(incoming).formatForCodeCapital
        if (target == 'select') ''', tbl«relationAliasName»'''
        else if (target == 'from') '''
            $qb->leftJoin('tbl.«relationAliasName.toFirstLower»', 'tbl«relationAliasName»');
        '''
    }
}
