package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EntityConstructor {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def constructor(Entity it, Boolean isInheriting) '''
        /**
         * Constructor.
         * Will not be called by Doctrine and can therefore be used
         * for own implementation purposes. It is also possible to add
         * arbitrary arguments as with every other class method.
         *
         * @param TODO
         */
        public function __construct(«constructorArguments(true)»)
        {
            «constructorImpl(isInheriting)»
        }
    '''

    def private constructorArgumentsDefault(Entity it, Boolean hasPreviousArgs) '''
        «IF hasCompositeKeys»
            «IF hasPreviousArgs», «ENDIF»«FOR pkField : getPrimaryKeyFields SEPARATOR ', '»$«pkField.name.formatForCode»«ENDFOR»
        «ENDIF»
    '''

    def private constructorArguments(Entity it, Boolean withTypeHints) '''
        «IF isIndexByTarget»
            «val indexRelation = getIncomingJoinRelations.filter[isIndexed].head»
            «val sourceAlias = getRelationAliasName(indexRelation, false)»
            «val indexBy = indexRelation.getIndexByField»
            $«indexBy.formatForCode»,«IF withTypeHints» «indexRelation.source.entityClassName('', false)»«ENDIF» $«sourceAlias.formatForCode»«constructorArgumentsDefault(true)»
        «ELSEIF isAggregated»
            «FOR aggregator : getAggregators SEPARATOR ', '»
                «FOR relation : aggregator.getAggregatingRelationships SEPARATOR ', '»
                    «relation.constructorArgumentsAggregate»
                «ENDFOR»
            «ENDFOR»
            «constructorArgumentsDefault(true)»
        «ELSE»
            «constructorArgumentsDefault(false)»
        «ENDIF»
    '''

    def private constructorArgumentsAggregate(OneToManyRelationship it) '''
        «val targetField = source.getAggregateFields.head.getAggregateTargetField»
        $«getRelationAliasName(false)», $«targetField.name.formatForCode»
    '''

    def private constructorImpl(Entity it, Boolean isInheriting) '''
        «IF isInheriting»
            parent::__construct(«constructorArguments(false)»);
        «ENDIF»
        «IF hasCompositeKeys»
            «FOR pkField : getPrimaryKeyFields»
                $this->«pkField.name.formatForCode» = $«pkField.name.formatForCode»;
            «ENDFOR»
        «ENDIF»
        «val mandatoryFields = getDerivedFields.filter[mandatory && !primaryKey]»
        «IF !getListFieldsEntity.filter[name != 'workflowState' && (null === defaultValue || defaultValue.length == 0)].empty
        	|| !mandatoryFields.filter(UserField).filter[null === defaultValue || defaultValue == '' || defaultValue == '0'].empty»
            $serviceManager = ServiceUtil::getManager();
    	«ENDIF»
        «FOR mandatoryField : mandatoryFields.filter(IntegerField).filter[null === defaultValue || defaultValue == '' || defaultValue == '0']»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(UserField).filter[null === defaultValue || defaultValue == '' || defaultValue == '0']»
            «IF application.targets('1.3.x')»
                $this->«mandatoryField.name.formatForCode» = UserUtil::getVar('uname');
            «ELSE»
                $this->«mandatoryField.name.formatForCode» = $serviceManager->get('zikula_users_module.current_user')->get('uname');
            «ENDIF»
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(DecimalField).filter[null === defaultValue || defaultValue == '' || defaultValue == '0']»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(AbstractDateField).filter[null === defaultValue || defaultValue == '' || defaultValue.length == 0]»
            $this->«mandatoryField.name.formatForCode» = «mandatoryField.defaultAssignment»;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(FloatField).filter[null === defaultValue || defaultValue == '' || defaultValue == '0']»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        «IF !getListFieldsEntity.filter[name != 'workflowState' && (null === defaultValue || defaultValue.length == 0)].empty»

            «IF application.targets('1.3.x')»
                $listHelper = new «application.appName»_Util_ListEntries(ServiceUtil::getManager());
            «ELSE»
                $listHelper = $serviceManager->get('«application.appService».listentries_helper');
            «ENDIF»
            «FOR listField : getListFieldsEntity.filter[name != 'workflowState' && (null === defaultValue || defaultValue.length == 0)]»

                $items = «IF application.targets('1.3.x')»array()«ELSE»[]«ENDIF»;
                $listEntries = $listHelper->get«listField.name.formatForCodeCapital»EntriesFor«name.formatForCodeCapital»();
                foreach ($listEntries as $listEntry) {
                    if ($listEntry['default'] === true) {
                        $items[] = $listEntry['value'];
                    }
                }
                $this->«listField.name.formatForCode» = implode('###', $items);
            «ENDFOR»

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
        «IF application.targets('1.3.x')»
            $this->initValidator();
        «ENDIF»
        $this->initWorkflow();
        «new Association().initCollections(it)»
    '''

    def private constructorAssignmentAggregate(OneToManyRelationship it) '''
        «val targetField = source.getAggregateFields.head.getAggregateTargetField»
        $this->«getRelationAliasName(false)» = $«getRelationAliasName(false)»;
        $this->«targetField.name.formatForCode» = $«targetField.name.formatForCode»;
    '''

    def private defaultAssignment(AbstractDateField it) '''\DateTime::createFromFormat('«defaultFormat»', date('«defaultFormat»'))'''
    def private dispatch defaultFormat(AbstractDateField it) {
    }
    def private dispatch defaultFormat(DatetimeField it) '''Y-m-d H:i:s'''
    def private dispatch defaultFormat(DateField it) '''Y-m-d'''
    def private dispatch defaultFormat(TimeField it) '''H:i:s'''
}
