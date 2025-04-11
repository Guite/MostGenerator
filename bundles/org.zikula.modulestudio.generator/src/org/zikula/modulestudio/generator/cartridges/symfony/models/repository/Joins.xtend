package org.zikula.modulestudio.generator.cartridges.symfony.models.repository

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Relationship
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
         */
        protected function addJoinsToSelection(): string
        {
            $selection = '«FOR relation : getBidirectionalIncomingRelations»«relation.addJoin(false, 'select')»«ENDFOR»«FOR relation : outgoing»«relation.addJoin(true, 'select')»«ENDFOR»';

            return $selection;
        }

        /**
         * Adds joins to from clause.
         */
        protected function addJoinsToFrom(QueryBuilder $qb): void
        {
            «IF !getBidirectionalIncomingRelations.empty || !outgoing.empty»
                «FOR relation : getBidirectionalIncomingRelations»«relation.addJoin(false, 'from')»«ENDFOR»
                «FOR relation : outgoing»«relation.addJoin(true, 'from')»«ENDFOR»
            «ENDIF»
        }
    '''

    def private addJoin(Relationship it, Boolean useTarget, String target) {
        val relationAliasName = getRelationAliasName(useTarget).formatForCodeCapital
        if (target == 'select') ''', tbl«relationAliasName»'''
        else if (target == 'from') '''
            $qb->leftJoin('tbl.«relationAliasName.toFirstLower»', 'tbl«relationAliasName»');
        '''
    }
}
