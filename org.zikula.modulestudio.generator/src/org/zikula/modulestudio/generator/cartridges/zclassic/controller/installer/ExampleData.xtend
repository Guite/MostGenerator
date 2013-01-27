package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.ArrayField
import de.guite.modulestudio.metamodel.modulestudio.BooleanField
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ListFieldItem
import de.guite.modulestudio.metamodel.modulestudio.ManyToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.Models
import de.guite.modulestudio.metamodel.modulestudio.ObjectField
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToOneRelationship
import de.guite.modulestudio.metamodel.modulestudio.StringField
import de.guite.modulestudio.metamodel.modulestudio.TextField
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UploadField
import de.guite.modulestudio.metamodel.modulestudio.UrlField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExampleData {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension Utils = new Utils()

    /**
     * Entry point for example data used by the installer.
     */
    def generate(Application it) '''
        /**
         * Create the default data for «appName».
         *
         * @return void
         */
        protected function createDefaultData()
        {
            // Ensure that tables are cleared
            $this->entityManager->transactional(function($entityManager) {
                «getDefaultDataSource.exampleRowImpl»
            });
        }
    '''

    def private exampleRowImpl(Models it) '''
        «FOR entity : entities»«entity.truncateTable»«ENDFOR»
        «IF numExampleRows > 0»
            «IF !entities.filter(e|e.tree != EntityTreeType::NONE).isEmpty»
                $treeCounterRoot = 1;
            «ENDIF»
            «createExampleRows»
        «ENDIF»
    '''

    def private truncateTable(Entity it) '''
        «val app = container.application»
        «IF app.targets('1.3.5')»
        $entityManager->getRepository('«app.appName»_Entity_«name.formatForCodeCapital»')->truncateTable();
        «ELSE»
        $entityManager->getRepository('«app.appName»\Entity\«name.formatForCodeCapital»Entity')->truncateTable();
        «ENDIF»
    '''

    def private createExampleRows(Models it) '''
        «initDateValues»
        «FOR entity : entities»«entity.initExampleObjects(application)»«ENDFOR»
        «FOR entity : entities»«entity.createExampleRows(application)»«ENDFOR»
    '''

    def private initDateValues(Models it) '''
        «val fields = getModelEntityFields.filter(typeof(AbstractDateField))»
        «IF !fields.filter(e|e.past).isEmpty»
            $lastMonth = mktime(date('s'), date('H'), date('i'), date('m')-1, date('d'), date('Y'));
            $lastHour = mktime(date('s'), date('H')-1, date('i'), date('m'), date('d'), date('Y'));
        «ENDIF»
        «IF !fields.filter(e|e.future).isEmpty»
            $nextMonth = mktime(date('s'), date('H'), date('i'), date('m')+1, date('d'), date('Y'));
            $nextHour = mktime(date('s'), date('H')+1, date('i'), date('m'), date('d'), date('Y'));
        «ENDIF»
        «IF !fields.filter(typeof(DatetimeField)).isEmpty»
            $dtNow = date('Y-m-d H:i:s');
            «IF !fields.filter(typeof(DatetimeField)).filter(e|e.past).isEmpty»
                $dtPast = date('Y-m-d H:i:s', $lastMonth);
            «ENDIF»
            «IF !fields.filter(typeof(DatetimeField)).filter(e|e.future).isEmpty»
                $dtFuture = date('Y-m-d H:i:s', $nextMonth);
            «ENDIF»
        «ENDIF»
        «IF !fields.filter(typeof(DateField)).isEmpty»
            $dNow = date('Y-m-d');
            «IF !fields.filter(typeof(DateField)).filter(e|e.past).isEmpty»
                $dPast = date('Y-m-d', $lastMonth);
            «ENDIF»
            «IF !fields.filter(typeof(DateField)).filter(e|e.future).isEmpty»
                $dFuture = date('Y-m-d', $nextMonth);
            «ENDIF»
        «ENDIF»
        «IF !fields.filter(typeof(TimeField)).isEmpty»
            $tNow = date('H:i:s');
            «IF !fields.filter(typeof(TimeField)).filter(e|e.past).isEmpty»
                $tPast = date('H:i:s', $lastHour);
            «ENDIF»
            «IF !fields.filter(typeof(TimeField)).filter(e|e.future).isEmpty»
                $tFuture = date('H:i:s', $nextHour);
            «ENDIF»
        «ENDIF»
    '''

    def private initExampleObjects(Entity it, Application app) '''
        «var exampleNumbers = getListForCounter(container.numExampleRows)»
        «FOR number : exampleNumbers»
            $«name.formatForCode»«number» = new «app.appName»«IF app.targets('1.3.5')»_Entity_«name.formatForCodeCapital»«ELSE»\Entity\«name.formatForCodeCapital»Entity«ENDIF»(«exampleRowsConstructorArguments(number)»);
        «ENDFOR»
        «/* this last line is on purpose */»
    '''

    def private createExampleRows(Entity it, Application app) '''
        «val entityName = name.formatForCode»
        «var exampleNumbers = getListForCounter(container.numExampleRows)»
        «FOR number : exampleNumbers»
            «IF isInheriting»
                «FOR field : parentType.getFieldsForExampleData»«exampleRowAssignment(field, it, entityName, number)»«ENDFOR»
            «ENDIF»
            «FOR field : getFieldsForExampleData»«exampleRowAssignment(field, it, entityName, number)»«ENDFOR»
            «/*«IF hasTranslatableFields»
                $«entityName»«number»->setLocale(ZLanguage::getLanguageCode());
            «ENDIF»*/»
            «IF tree != EntityTreeType::NONE»
                $«entityName»«number»->setParent(«IF number == 1»null«ELSE»$«entityName»1«ENDIF»);
                $«entityName»«number»->setLvl(«IF number == 1»1«ELSE»2«ENDIF»);
                $«entityName»«number»->setLft(«IF number == 1»1«ELSE»«((number-1)*2)»«ENDIF»);
                $«entityName»«number»->setRgt(«IF number == 1»«container.numExampleRows*2»«ELSE»«((number-1)*2)+1»«ENDIF»);
                $«entityName»«number»->setRoot($treeCounterRoot);
            «ENDIF»
            «FOR relation : outgoing.filter(typeof(OneToOneRelationship)).filter(e|e.target.container.application == app)»«relation.exampleRowAssignmentOutgoing(entityName, number)»«ENDFOR» 
            «FOR relation : outgoing.filter(typeof(ManyToOneRelationship)).filter(e|e.target.container.application == app)»«relation.exampleRowAssignmentOutgoing(entityName, number)»«ENDFOR»
            «FOR relation : incoming.filter(typeof(OneToManyRelationship)).filter(e|e.bidirectional).filter(e|e.source.container.application == app)»«relation.exampleRowAssignmentIncoming(entityName, number)»«ENDFOR»
        «ENDFOR»
        «persistExampleObjects(app)»
        «IF tree != EntityTreeType::NONE»
            $treeCounterRoot++;
        «ENDIF»
        «/* this last line is on purpose */»
    '''

    def private persistExampleObjects(Entity it, Application app) '''
        «var exampleNumbers = getListForCounter(container.numExampleRows)»
        «FOR number : exampleNumbers»
            $entityManager->persist($«name.formatForCode»«number»);
        «ENDFOR»
    '''

    def private exampleRowsConstructorArgumentsDefault(Entity it, Boolean hasPreviousArgs, Integer number) '''
        «IF hasCompositeKeys»
            «IF hasPreviousArgs», «ENDIF»«FOR pkField : getPrimaryKeyFields SEPARATOR ', '»$«pkField.name.formatForCode»«ENDFOR»
        «ENDIF»
    '''

    def private exampleRowsConstructorArguments(Entity it, Integer number) '''
        «IF isIndexByTarget»
            «val indexRelation = incoming.filter(typeof(JoinRelationship)).filter(e|e.isIndexed).head»
            «val sourceAlias = getRelationAliasName(indexRelation, false)»
            «val indexBy = indexRelation.getIndexByField»
            «val indexByField = getDerivedFields.findFirst(e|e.name == indexBy)»
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

    def private exampleRowAssignmentOutgoing(JoinRelationship it, String entityName, Integer number) '''
            $«entityName»«number»->set«getRelationAliasName(true).formatForCodeCapital»($«target.name.formatForCode»«number»);
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
        	BooleanField: if (defaultValue == true || defaultValue == 'true') 'true' else 'false'
        	IntegerField: exampleRowValueNumber(dataEntity, number)
        	DecimalField: exampleRowValueNumber(dataEntity, number)
        	StringField: if (it.country || it.language) 'ZLanguage::getLanguageCode()' else if (it.htmlcolour) '\'#ff6600\'' else exampleRowValueText(dataEntity, number)
        	TextField: exampleRowValueText(dataEntity, number)
        	EmailField: '\'' + entity.container.application.email + '\''
        	UrlField: '\'' + entity.container.application.url + '\''
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
