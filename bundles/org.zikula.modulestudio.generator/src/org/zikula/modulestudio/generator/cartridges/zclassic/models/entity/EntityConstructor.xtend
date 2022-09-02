package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class EntityConstructor {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions

    def constructor(DataObject it, Boolean isInheriting) '''
        /**
         * «name.formatForCodeCapital»Entity constructor.
         *
         * Will not be called by Doctrine and can therefore be used
         * for own implementation purposes. It is also possible to add
         * arbitrary arguments as with every other class method.«/*IF isIndexByTarget || isAggregated»
         *
         «IF isIndexByTarget»
         * @param string $«getIndexByRelation.getIndexByField.formatForCode» Indexing field
         * @param «getIndexByRelation.source.name.formatForCodeCapital» $«getRelationAliasName(getIndexByRelation, false).formatForCode» Indexing relationship
         «ELSEIF isAggregated»
            «FOR aggregator : getAggregators SEPARATOR ', '»
                «FOR relation : aggregator.getAggregatingRelationships SEPARATOR ', '»
                    @param string $«relation.getRelationAliasName(false)» Aggregating relationship
                    @param «relation.source.name.formatForCodeCapital» $«relation.source.getAggregateFields.head.getAggregateTargetField.name.formatForCode» Aggregate target field
                «ENDFOR»
            «ENDFOR»
         «ENDIF»
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
        «ELSEIF isAggregated»
            «FOR aggregator : getAggregators SEPARATOR ', '»
                «FOR relation : aggregator.getAggregatingRelationships SEPARATOR ', '»
                    «relation.constructorArgumentsAggregate»
                «ENDFOR»
            «ENDFOR»
        «ENDIF»
    '''

    def private getIndexByRelation(DataObject it) {
        getIncomingJoinRelations.filter[isIndexed].head
    }

    def private constructorArgumentsAggregate(OneToManyRelationship it) '''
        «val targetField = source.getAggregateFields.head.getAggregateTargetField»
        «source.name.formatForCodeCapital» $«getRelationAliasName(false)», string $«targetField.name.formatForCode»
    '''

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
        «ELSEIF isAggregated»

            «FOR aggregator : getAggregators»
                «FOR relation : aggregator.getAggregatingRelationships»
                    «relation.constructorAssignmentAggregate»
                «ENDFOR»
            «ENDFOR»
        «ELSE»
        «ENDIF»
        «new Association().initCollections(it)»
    '''

    def private constructorAssignmentAggregate(OneToManyRelationship it) '''
        «val targetField = source.getAggregateFields.head.getAggregateTargetField»
        $this->«getRelationAliasName(false)» = $«getRelationAliasName(false)»;
        $this->«targetField.name.formatForCode» = $«targetField.name.formatForCode»;
    '''
}
