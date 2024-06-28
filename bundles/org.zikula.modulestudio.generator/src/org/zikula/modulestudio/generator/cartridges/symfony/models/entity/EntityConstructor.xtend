package org.zikula.modulestudio.generator.cartridges.symfony.models.entity

import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.JoinRelationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class EntityConstructor {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def constructor(DataObject it, Boolean isInheriting) '''
        /**
         * «name.formatForCodeCapital» constructor.
         *
         * Will not be called by Doctrine and can therefore be used
         * for own implementation purposes. It is also possible to add
         * arbitrary arguments as with every other class method.«/*IF isIndexByTarget»
         *
         * @param string $«getIndexByRelation.getIndexByField.formatForCode» Indexing field
         * @param «getIndexByRelation.source.name.formatForCodeCapital» $«getRelationAliasName(getIndexByRelation, false).formatForCode» Indexing relationship
         «ENDIF*/»
         */
        public function __construct(«constructorArguments(true)»)
        {
            «constructorImpl(isInheriting)»
        }
    '''

    def private constructorArguments(DataObject it, Boolean withTypeHints) '''
        «IF isIndexByTarget»
            «val indexRelation = getIndexByRelation»
            «val sourceAlias = getRelationAliasName(indexRelation, false)»
            «val indexBy = indexRelation.getIndexByField»
            string $«indexBy.formatForCode»,«IF withTypeHints» «indexRelation.source.name.formatForCodeCapital»Entity«ENDIF» $«sourceAlias.formatForCode»
        «ENDIF»
    '''

    def private getIndexByRelation(DataObject it) {
        getIncomingJoinRelations.filter[isIndexed].head
    }

    def private constructorImpl(DataObject it, Boolean isInheriting) '''
        «IF isInheriting»
            parent::__construct(«constructorArguments(false)»);
        «ENDIF»
        «IF isIndexByTarget»

            «val indexRelation = incoming.filter(JoinRelationship).filter[isIndexed].head»
            «val sourceAlias = getRelationAliasName(indexRelation, false)»
            «val targetAlias = getRelationAliasName(indexRelation, true)»
            «val indexBy = indexRelation.getIndexByField»
            $this->«indexBy.formatForCode» = $«indexBy.formatForCode»;
            $this->«sourceAlias.formatForCode» = $«sourceAlias.formatForCode»;
            $«sourceAlias.formatForCode»->add«targetAlias.formatForCodeCapital»($this);
        «ENDIF»
        «new Association().initCollections(it)»
    '''
}
