package org.zikula.modulestudio.generator.cartridges.zclassic.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.JoinRelationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Joins {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Entity it, Application app) '''
        /**
         * Helper method to add join selections.
         «IF !app.targets('3.0')»
         *
         * @return string Enhancement for select clause
         «ENDIF»
         */
        protected function addJoinsToSelection()«IF app.targets('3.0')»: string«ENDIF»
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
         «IF !app.targets('3.0')»
         *
         * @param QueryBuilder $qb Query builder instance used to create the query
         *
         * @return QueryBuilder The query builder enriched by additional joins
         «ENDIF»
         */
        protected function addJoinsToFrom(QueryBuilder $qb)«IF app.targets('3.0')»: QueryBuilder«ENDIF»
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
