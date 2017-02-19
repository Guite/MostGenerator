package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DecimalField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.FloatField
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TimeField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExampleData {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Entry point for example data used by the installer.
     */
    def generate(Application it) '''
        /**
         * Create the default data for «appName».
         *
        «IF hasCategorisableEntities»
            «' '»* @param array $categoryRegistryIdsPerEntity List of category registry ids
            «' '»*
        «ENDIF»
         * @return void
         */
        protected function createDefaultData(«IF hasCategorisableEntities»$categoryRegistryIdsPerEntity«ENDIF»)
        {
            «exampleRows»
        }
    '''

    def private exampleRows(Application it) '''
        $entityManager = $this->container->get('«entityManagerService»');
        $logger = $this->container->get('logger');
        $request = $this->container->get('request_stack')->getCurrentRequest();

        «FOR entity : getAllEntities.filter[tree == EntityTreeType.NONE]»«entity.truncateTable»«ENDFOR»
        «IF amountOfExampleRows > 0»
            «IF !getAllEntities.filter[tree != EntityTreeType.NONE].empty»
                $treeCounterRoot = 1;
            «ENDIF»
            «createExampleRows»
        «ENDIF»
    '''

    def private truncateTable(Entity it) '''
        «val app = application»
        $entityClass = '«app.vendor.formatForCodeCapital»\«app.name.formatForCodeCapital»Module\Entity\«name.formatForCodeCapital»Entity';
        $entityManager->getRepository($entityClass)->truncateTable($logger);
    '''

    def private createExampleRows(Application it) '''
        «initDateValues»
        «FOR entity : getAllEntities»«entity.initExampleObjects(it)»«ENDFOR»
        «FOR entity : getAllEntities»«entity.createExampleRows(it)»«ENDFOR»
        «persistExampleObjects»
    '''

    def private initDateValues(Application it) '''
        «val fields = getAllEntityFields.filter(AbstractDateField)»
        «IF !fields.filter[past].empty»
            $lastMonth = mktime(date('s'), date('H'), date('i'), date('m')-1, date('d'), date('Y'));
            $lastHour = mktime(date('s'), date('H')-1, date('i'), date('m'), date('d'), date('Y'));
        «ENDIF»
        «IF !fields.filter[future].empty»
            $nextMonth = mktime(date('s'), date('H'), date('i'), date('m')+1, date('d'), date('Y'));
            $nextHour = mktime(date('s'), date('H')+1, date('i'), date('m'), date('d'), date('Y'));
        «ENDIF»
        «IF !fields.filter(DatetimeField).empty»
            $dtNow = date('Y-m-d H:i:s');
            «IF !fields.filter(DatetimeField).filter[past].empty»
                $dtPast = date('Y-m-d H:i:s', $lastMonth);
            «ENDIF»
            «IF !fields.filter(DatetimeField).filter[future].empty»
                $dtFuture = date('Y-m-d H:i:s', $nextMonth);
            «ENDIF»
        «ENDIF»
        «IF !fields.filter(DateField).empty»
            $dNow = date('Y-m-d');
            «IF !fields.filter(DateField).filter[past].empty»
                $dPast = date('Y-m-d', $lastMonth);
            «ENDIF»
            «IF !fields.filter(DateField).filter[future].empty»
                $dFuture = date('Y-m-d', $nextMonth);
            «ENDIF»
        «ENDIF»
        «IF !fields.filter(TimeField).empty»
            $tNow = date('H:i:s');
            «IF !fields.filter(TimeField).filter[past].empty»
                $tPast = date('H:i:s', $lastHour);
            «ENDIF»
            «IF !fields.filter(TimeField).filter[future].empty»
                $tFuture = date('H:i:s', $nextHour);
            «ENDIF»
        «ENDIF»
    '''

    def private initExampleObjects(Entity it, Application app) '''
        «FOR number : 1..app.amountOfExampleRows»
            $«name.formatForCode»«number» = new \«app.vendor.formatForCodeCapital»\«app.name.formatForCodeCapital»Module\Entity\«name.formatForCodeCapital»Entity(«exampleRowsConstructorArguments(number)»);
        «ENDFOR»
        «/* this last line is on purpose */»
    '''

    def private createExampleRows(Entity it, Application app) '''
        «val entityName = name.formatForCode»
        «IF categorisable»
            $categoryId = 41; // Business and work
            $category = $entityManager->find('ZikulaCategoriesModule:CategoryEntity', $categoryId);
        «ENDIF»
        «FOR number : 1..app.amountOfExampleRows»
            «IF isInheriting»
                «FOR field : parentType.getFieldsForExampleData»«exampleRowAssignment(field, it, entityName, number)»«ENDFOR»
            «ENDIF»
            «FOR field : getFieldsForExampleData»«exampleRowAssignment(field, it, entityName, number)»«ENDFOR»
            «/*«IF hasTranslatableFields»
                $«entityName»«number»->setLocale($request->getLocale());
            «ENDIF»*/»
            «IF tree != EntityTreeType.NONE»
                $«entityName»«number»->setParent(«IF number == 1»null«ELSE»$«entityName»1«ENDIF»);
                $«entityName»«number»->setLvl(«IF number == 1»1«ELSE»2«ENDIF»);
                $«entityName»«number»->setLft(«IF number == 1»1«ELSE»«((number-1)*2)»«ENDIF»);
                $«entityName»«number»->setRgt(«IF number == 1»«app.amountOfExampleRows*2»«ELSE»«((number-1)*2)+1»«ENDIF»);
                $«entityName»«number»->setRoot($treeCounterRoot);
            «ENDIF»
            «FOR relation : outgoing.filter(OneToOneRelationship).filter[target.application == app]»«relation.exampleRowAssignmentOutgoing(entityName, number)»«ENDFOR» 
            «FOR relation : outgoing.filter(ManyToOneRelationship).filter[target.application == app]»«relation.exampleRowAssignmentOutgoing(entityName, number)»«ENDFOR»
            «FOR relation : outgoing.filter(ManyToManyRelationship).filter[target.application == app]»«relation.exampleRowAssignmentOutgoing(entityName, number)»«ENDFOR»
            «FOR relation : incoming.filter(OneToManyRelationship).filter[bidirectional].filter[source.application == app]»«relation.exampleRowAssignmentIncoming(entityName, number)»«ENDFOR»
            «IF categorisable»
                // create category assignment
                $«entityName»«number»->getCategories()->add(new \«app.vendor.formatForCodeCapital»\«app.name.formatForCodeCapital»Module\Entity\«name.formatForCodeCapital»CategoryEntity($categoryRegistryIdsPerEntity['«name.formatForCode»'], $category, $«entityName»«number»));
            «ENDIF»
            «IF attributable»
                // create example attributes
                $«entityName»«number»->setAttribute('field1', 'first value');
                $«entityName»«number»->setAttribute('field2', 'second value');
                $«entityName»«number»->setAttribute('field3', 'third value');
            «ENDIF»
        «ENDFOR»
        «IF tree != EntityTreeType.NONE»
            $treeCounterRoot++;
        «ENDIF»
        «/* this last line is on purpose */»
    '''

    def private persistExampleObjects(Application it) '''
        // execute the workflow action for each entity
        $action = 'submit';
        $workflowHelper = new \«appNamespace»\Helper\WorkflowHelper($this->container, $this->container->get('translator.default'));
        try {
            «FOR entity : getAllEntities»«entity.persistEntities(it)»«ENDFOR»
        } catch(\Exception $e) {
            $this->addFlash('error', $this->__('Exception during example data creation') . ': ' . $e->getMessage());
            $logger->error('{app}: Could not completely create example data during installation. Error details: {errorMessage}.', ['app' => '«appName»', 'errorMessage' => $e->getMessage()]);

            return false;
        }
    '''

    def private persistEntities(Entity it, Application app) '''
        «FOR number : 1..app.amountOfExampleRows»
            if ($«name.formatForCode»«number»->validate()) {
                $success = $workflowHelper->executeAction($«name.formatForCode»«number», $action);
            }
        «ENDFOR»
    '''

    def private exampleRowsConstructorArgumentsDefault(Entity it, Boolean hasPreviousArgs, Integer number) '''
        «IF hasCompositeKeys»
            «IF hasPreviousArgs», «ENDIF»«FOR pkField : getPrimaryKeyFields SEPARATOR ', '»$«pkField.name.formatForCode»«ENDFOR»
        «ENDIF»
    '''

    def private exampleRowsConstructorArguments(Entity it, Integer number) '''
        «IF isIndexByTarget»
            «val indexRelation = incoming.filter(JoinRelationship).filter[isIndexed].head»
            «val sourceAlias = getRelationAliasName(indexRelation, false)»
            «val indexBy = indexRelation.getIndexByField»
            «val indexByField = getDerivedFields.findFirst[name == indexBy]»
            «indexByField.exampleRowsConstructorArgument(number)», $«sourceAlias.formatForCode»«number»«exampleRowsConstructorArgumentsDefault(true, number)»
        «ELSEIF isAggregated»
            «FOR aggregator : getAggregators SEPARATOR ', '»
                «FOR relation : aggregator.getAggregatingRelationships SEPARATOR ', '»«relation.exampleRowsConstructorArgumentsAggregate(number)»«ENDFOR»«exampleRowsConstructorArgumentsDefault(true, number)»
            «ENDFOR»
        «ELSE»
            «exampleRowsConstructorArgumentsDefault(false, number)»
        «ENDIF»
    '''

    def private exampleRowsConstructorArgument(DerivedField it, Integer number) {
        switch it {
            IntegerField: if (it.defaultValue.length > 0) it.defaultValue else number
            default: '\'' + (if (it.defaultValue.length > 0) it.defaultValue else it.name.formatForDisplayCapital + ' ' + number) + '\''
        }
    }

    def private exampleRowsConstructorArgumentsAggregate(OneToManyRelationship it, Integer number) '''
        «val targetField = source.getAggregateFields.head.getAggregateTargetField»
        $«getRelationAliasName(false)»«number», «IF targetField.defaultValue != '' && targetField.defaultValue != '0'»«targetField.defaultValue»«ELSE»«number»«ENDIF»
    '''

    def private exampleRowAssignment(DerivedField it, Entity dataEntity, String entityName, Integer number) {
        switch it {
            IntegerField: '''
                «IF it.aggregateFor.length == 0»
                    $«entityName»«number»->set«name.formatForCodeCapital»(«exampleRowValue(dataEntity, number)»);
                «ENDIF»
            '''
            UploadField: ''
            default: '''
                $«entityName»«number»->set«name.formatForCodeCapital»(«exampleRowValue(dataEntity, number)»);
            '''
        }
    }

    def private dispatch exampleRowAssignmentOutgoing(JoinRelationship it, String entityName, Integer number) '''
            $«entityName»«number»->set«getRelationAliasName(true).formatForCodeCapital»($«target.name.formatForCode»«number»);
    '''
    def private dispatch exampleRowAssignmentOutgoing(ManyToManyRelationship it, String entityName, Integer number) '''
            $«entityName»«number»->add«getRelationAliasName(true).formatForCodeCapital»($«target.name.formatForCode»«number»);
    '''
    def private exampleRowAssignmentIncoming(JoinRelationship it, String entityName, Integer number) '''
            $«entityName»«number»->set«getRelationAliasName(false).formatForCodeCapital»($«source.name.formatForCode»«number»);
    '''

    def private exampleRowValueNumber(DerivedField it, Entity dataEntity, Integer number) '''«number»'''

    def private exampleRowValueTextLength(DerivedField it, Entity dataEntity, Integer number, Integer maxLength) '''
        «IF maxLength >= (entity.name.formatForDisplayCapital.length + 4 + name.formatForDisplay.length)»
            '«dataEntity.name.formatForDisplayCapital» «name.formatForDisplay» «number»'«ELSEIF !unique && maxLength >= (4 + name.formatForDisplay.length)»
            '«name.formatForDisplay» «number»'«ELSEIF maxLength < 4 && maxLength > 1»
            '«(number+dataEntity.name.length+dataEntity.fields.size)»'«ELSEIF maxLength == 1»
            '«if (number > 9) 1 else number»'«ELSE»
            substr('«dataEntity.name.formatForDisplayCapital» «name.formatForDisplay»', 0, «(maxLength-2)») . ' «number»'
        «ENDIF»'''

    def private exampleRowValueText(DerivedField it, Entity dataEntity, Integer number) {
        if (it instanceof AbstractStringField && (it as AbstractStringField).nospace) {
            exampleRowValueTextInternal(dataEntity, number).toString.replace(' ', '')
        } else {
            exampleRowValueTextInternal(dataEntity, number)
        }
    }

    def private exampleRowValueTextInternal(DerivedField it, Entity dataEntity, Integer number) {
        switch it {
            StringField: exampleRowValueTextLength(dataEntity, number, it.length)
            TextField: exampleRowValueTextLength(dataEntity, number, it.length)
            EmailField: exampleRowValueTextLength(dataEntity, number, it.length)
            UrlField: exampleRowValueTextLength(dataEntity, number, it.length)
            default: '\'' + entity.name.formatForDisplayCapital + ' ' + name.formatForDisplay + ' ' + number + '\''
        }
    }
    def private exampleRowValue(DerivedField it, Entity dataEntity, Integer number) {
        switch it {
            BooleanField: if (defaultValue == 'true') 'true' else 'false'
            IntegerField: exampleRowValueNumber(dataEntity, number)
            DecimalField: exampleRowValueNumber(dataEntity, number)
            StringField: if (it.country || it.language || it.locale) '''$request->getLocale()''' else if (it.currency) 'EUR' else if (it.htmlcolour) '\'#ff6600\'' else exampleRowValueText(dataEntity, number)
            TextField: exampleRowValueText(dataEntity, number)
            EmailField: '\'' + entity.application.email + '\''
            UrlField: '\'' + entity.application.url + '\''
            UploadField: exampleRowValueText(dataEntity, number)
            UserField: /* admin */2
            ArrayField: exampleRowValueNumber(dataEntity, number)
            ObjectField: exampleRowValueText(dataEntity, number)
            DatetimeField: '''«IF it.past»$dtPast«ELSEIF it.future»$dtFuture«ELSE»$dtNow«ENDIF»'''
            DateField: '''«IF it.past»$dPast«ELSEIF it.future»$dFuture«ELSE»$dNow«ENDIF»'''
            TimeField: '''«IF it.past»$tPast«ELSEIF it.future»$tFuture«ELSE»$tNow«ENDIF»'''
            FloatField: exampleRowValueNumber(dataEntity, number)
            ListField: ''''«IF it.multiple»###«FOR item : getDefaultItems SEPARATOR '###'»«item.exampleRowValue»«ENDFOR»###«ELSE»«FOR item : getDefaultItems»«item.exampleRowValue»«ENDFOR»«ENDIF»'«/**/»'''
            default: ''
        }
    }

    def private exampleRowValue(ListFieldItem it) {
        if (^default) value else ''
    }
}
