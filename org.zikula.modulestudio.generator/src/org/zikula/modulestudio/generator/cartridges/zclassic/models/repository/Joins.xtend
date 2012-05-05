package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Joins {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()

    def generate(Entity it, Application app) '''
        /**
         * Helper method to add join selections.
         *
         * @return String Enhancement for select clause.
         */
        protected function addJoinsToSelection()
        {
            $selection = '«FOR relation : getBidirectionalIncomingJoinRelations»«relation.addJoin(false, 'select')»«ENDFOR»«FOR relation : getOutgoingJoinRelations»«relation.addJoin(true, 'select')»«ENDFOR»';
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
            «FOR relation : getBidirectionalIncomingJoinRelations»«relation.addJoin(false, 'from')»«ENDFOR»
            «FOR relation : getOutgoingJoinRelations»«relation.addJoin(true, 'from')»«ENDFOR»
            return $qb;
        }
    '''

    def private addJoin(JoinRelationship it, Boolean incoming, String target) {
        val relationAliasName = getRelationAliasName(incoming).formatForCodeCapital.toFirstUpper
        if (target == 'select') ''', tbl«relationAliasName»'''
        else if (target == 'from') '''
            $qb->leftJoin('tbl.«relationAliasName.toFirstLower»', 'tbl«relationAliasName»');
        '''
    }
}
