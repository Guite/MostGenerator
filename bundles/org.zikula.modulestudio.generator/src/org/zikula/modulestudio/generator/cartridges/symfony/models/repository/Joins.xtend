package org.zikula.modulestudio.generator.cartridges.symfony.models.repository

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
         */
        protected function addJoinsToSelection(): string
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
         * Adds joins to from clause.
         */
        protected function addJoinsToFrom(QueryBuilder $qb): void
        {
            «IF isInheriting || !getBidirectionalIncomingJoinRelations.empty || !getOutgoingJoinRelations.empty || categorisable»
                «IF isInheriting»
                    parent::addJoinsToFrom($qb);
                «ENDIF»
                «FOR relation : getBidirectionalIncomingJoinRelations»«relation.addJoin(false, 'from')»«ENDFOR»
                «FOR relation : getOutgoingJoinRelations»«relation.addJoin(true, 'from')»«ENDFOR»
                «IF categorisable»
                    $qb->leftJoin('tbl.categories', 'tblCategories');
                «ENDIF»
            «ENDIF»
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
