package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Joins {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def generate(Entity it, Application app) '''
        /**
         * Helper method to add join selections.
         *
         * @return String Enhancement for select clause
         */
        protected function addJoinsToSelection()
        {
            «IF isInheriting»
                $selection = parent::addJoinsToSelection();
            «ENDIF»
            $selection «IF isInheriting».«ENDIF»= '«FOR relation : getBidirectionalIncomingJoinRelations»«relation.addJoin(false, 'select')»«ENDFOR»«FOR relation : getOutgoingJoinRelations»«relation.addJoin(true, 'select')»«ENDFOR»';
            «IF categorisable»

                $selection .= ', tblCategories';
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
            «IF isInheriting»
                $qb = parent::addJoinsToFrom($qb);
            «ENDIF»
            «FOR relation : getBidirectionalIncomingJoinRelations»«relation.addJoin(false, 'from')»«ENDFOR»
            «FOR relation : getOutgoingJoinRelations»«relation.addJoin(true, 'from')»«ENDFOR»
            «IF categorisable»

                $qb->leftJoin('tbl.categories', 'tblCategories');
            «ENDIF»

            return $qb;
        }
    '''

    def private addJoin(JoinRelationship it, Boolean useTarget, String target) {
        val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital
        if (target == 'select') ''', tbl«relationAliasName»'''
        else if (target == 'from') '''
            $qb->leftJoin('tbl.«relationAliasName.toFirstLower»', 'tbl«relationAliasName»');
        '''
    }
}
