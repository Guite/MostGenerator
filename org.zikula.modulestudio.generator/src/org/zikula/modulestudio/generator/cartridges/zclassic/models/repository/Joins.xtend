package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Joins {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Entity it, Application app) '''
        /**
         * Helper method to add join selections.
         *
         * @return String Enhancement for select clause.
         */
        protected function addJoinsToSelection()
        {
            $selection = '«FOR relation : getBidirectionalIncomingJoinRelations.filter[source.container.application == app]»«relation.addJoin(false, 'select')»«ENDFOR»«FOR relation : getOutgoingJoinRelations.filter[target.container.application == app]»«relation.addJoin(true, 'select')»«ENDFOR»';
            «FOR relation : getBidirectionalIncomingJoinRelations.filter[source.container.application != app]»
                if (ModUtil::available('«relation.source.container.application.name.formatForCodeCapital»')) {
                    $selection .= '«relation.addJoin(false, 'select')»';
                }
            «ENDFOR»
            «FOR relation : getOutgoingJoinRelations.filter[target.container.application != app]»
                if (ModUtil::available('«relation.target.container.application.name.formatForCodeCapital»')) {
                    $selection .= '«relation.addJoin(true, 'select')»';
                }
            «ENDFOR»
            «IF categorisable»

                $selection = ', tblCategories';
            «ENDIF»

            return $selection;
        }

        /**
         * Helper method to add joins to from clause.
         *
         * @param Doctrine\ORM\QueryBuilder $qb query builder instance used to create the query.
         *
         * @return String Enhancement for from clause.
         */
        protected function addJoinsToFrom(QueryBuilder $qb)
        {
            «FOR relation : getBidirectionalIncomingJoinRelations.filter[source.container.application == app]»«relation.addJoin(false, 'from')»«ENDFOR»
            «FOR relation : getOutgoingJoinRelations.filter[target.container.application == app]»«relation.addJoin(true, 'from')»«ENDFOR»
            «FOR relation : getBidirectionalIncomingJoinRelations.filter[source.container.application != app]»
                if (ModUtil::available('«relation.source.container.application.name.formatForCodeCapital»')) {
                    «relation.addJoin(false, 'from')»
                }
            «ENDFOR»
            «FOR relation : getOutgoingJoinRelations.filter[target.container.application != app]»
                if (ModUtil::available('«relation.target.container.application.name.formatForCodeCapital»')) {
                    «relation.addJoin(true, 'from')»
                }
            «ENDFOR»
            «IF categorisable»

                $qb->leftJoin('tbl.categories', 'tblCategories');
            «ENDIF»

            return $qb;
        }
    '''

    def private addJoin(JoinRelationship it, Boolean incoming, String target) {
        val relationAliasName = getRelationAliasName(incoming).formatForCodeCapital
        if (target == 'select') ''', tbl«relationAliasName»'''
        else if (target == 'from') '''
            $qb->leftJoin('tbl.«relationAliasName.toFirstLower»', 'tbl«relationAliasName»');
        '''
    }
}
