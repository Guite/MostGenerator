package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.BooleanField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EmailField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.IntegerField
import de.guite.modulestudio.metamodel.JoinRelationship
import de.guite.modulestudio.metamodel.ListField
import de.guite.modulestudio.metamodel.ListFieldItem
import de.guite.modulestudio.metamodel.ManyToManyRelationship
import de.guite.modulestudio.metamodel.ManyToOneRelationship
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.ObjectField
import de.guite.modulestudio.metamodel.OneToManyRelationship
import de.guite.modulestudio.metamodel.OneToOneRelationship
import de.guite.modulestudio.metamodel.StringField
import de.guite.modulestudio.metamodel.StringRole
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.UploadField
import de.guite.modulestudio.metamodel.UrlField
import de.guite.modulestudio.metamodel.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExampleDataHelper {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (amountOfExampleRows < 1) {
            return
        }
        println('Generating helper class for inserting example data')
        val fh = new FileHelper
        generateClassPair(fsa, 'Helper/ExampleDataHelper.php',
            fh.phpFileContent(it, exampleDataHelperBaseClass), fh.phpFileContent(it, exampleDataHelperImpl)
        )
    }

    def private exampleDataHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasUserFields || hasStandardFieldEntities»
            use Zikula\UsersModule\Constant as UsersConstant;
            use Zikula\UsersModule\Entity\RepositoryInterface\UserRepositoryInterface;
        «ENDIF»
        use «appNamespace»\Entity\Factory\EntityFactory;
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«name.formatForCodeCapital»Entity;
            «IF entity.categorisable»
                use «appNamespace»\Entity\«name.formatForCodeCapital»CategoryEntity;
            «ENDIF»
        «ENDFOR»
        use «appNamespace»\Helper\WorkflowHelper;

        /**
         * Example data helper base class.
         */
        abstract class AbstractExampleDataHelper
        {
            /**
             * @var Request
             */
            protected $request;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * @var EntityFactory
             */
            protected $entityFactory;

            /**
             * @var WorkflowHelper
             */
            protected $workflowHelper;
            «IF hasUserFields || hasStandardFieldEntities»

                /**
                 * @var UserRepositoryInterface
                 */
                protected $userRepository;
            «ENDIF»

            /**
             * ExampleDataHelper constructor.
             *
             * @param RequestStack    $requestStack   RequestStack service instance
             * @param LoggerInterface $logger         Logger service instance
             * @param EntityFactory   $entityFactory  EntityFactory service instance
             * @param WorkflowHelper  $workflowHelper WorkflowHelper service instance
             «IF hasUserFields || hasStandardFieldEntities»
             * @param UserRepositoryInterface $userRepository UserRepository service instance
             «ENDIF»
             */
            public function __construct(
                RequestStack $requestStack,
                LoggerInterface $logger,
                EntityFactory $entityFactory,
                WorkflowHelper $workflowHelper«IF hasUserFields || hasStandardFieldEntities»,
                UserRepositoryInterface $userRepository«ENDIF»
            ) {
                $this->request = $requestStack->getCurrentRequest();
                $this->logger = $logger;
                $this->entityFactory = $entityFactory;
                $this->workflowHelper = $workflowHelper;
                «IF hasUserFields || hasStandardFieldEntities»
                    $this->userRepository = $userRepository;
                «ENDIF»
            }

            «exampleDataHelperBaseImpl»
        }
    '''

    def private exampleDataHelperBaseImpl(Application it) '''
        /**
         * Create the default data for «appName».
         *
         * @return void
         */
        public function createDefaultData()
        {
            «IF hasUserFields || hasStandardFieldEntities»
                $adminUser = $this->userRepository->find(UsersConstant::USER_ID_ADMIN);
            «ENDIF»
            «IF !getAllEntities.filter[tree != EntityTreeType.NONE].empty»
                $treeCounterRoot = 1;
            «ENDIF»
            «initDateValues»
            «IF hasCategorisableEntities»
                // example category
                $categoryId = 41; // Business and work
                $category = $this->entityFactory->getObjectManager()->find('ZikulaCategoriesModule:CategoryEntity', $categoryId);

                // determine category registry identifiers
                $registryRepository = $this->entityFactory->getObjectManager()->getRepository('ZikulaCategoriesModule:CategoryRegistryEntity');
                $categoryRegistries = $registryRepository->findBy(['modname' => '«appName»']);

            «ENDIF»

            «createExampleRows»
        }
    '''

    def private createExampleRows(Application it) '''
        «FOR entity : getAllEntities»«entity.initExampleObjects(it)»«ENDFOR»
        «FOR entity : getAllEntities»«entity.createExampleRows(it)»«ENDFOR»
        «persistExampleObjects»
    '''

    def private initDateValues(Application it) '''
        «val fields = getAllEntityFields.filter(DatetimeField)»
        «IF !fields.filter[past].empty»
            $lastMonth = mktime(date('s'), date('H'), date('i'), date('m')-1, date('d'), date('Y'));
            $lastHour = mktime(date('s'), date('H')-1, date('i'), date('m'), date('d'), date('Y'));
        «ENDIF»
        «IF !fields.filter[future].empty»
            $nextMonth = mktime(date('s'), date('H'), date('i'), date('m')+1, date('d'), date('Y'));
            $nextHour = mktime(date('s'), date('H')+1, date('i'), date('m'), date('d'), date('Y'));
        «ENDIF»
        «IF !fields.filter[isDateTimeField].empty»
            $dtNow = date('Y-m-d H:i:s');
            «IF !fields.filter[isDateTimeField].filter[past].empty»
                $dtPast = date('Y-m-d H:i:s', $lastMonth);
            «ENDIF»
            «IF !fields.filter[isDateTimeField].filter[future].empty»
                $dtFuture = date('Y-m-d H:i:s', $nextMonth);
            «ENDIF»
        «ENDIF»
        «IF !fields.filter[isDateField].empty»
            $dNow = date('Y-m-d');
            «IF !fields.filter[isDateField].filter[past].empty»
                $dPast = date('Y-m-d', $lastMonth);
            «ENDIF»
            «IF !fields.filter[isDateField].filter[future].empty»
                $dFuture = date('Y-m-d', $nextMonth);
            «ENDIF»
        «ENDIF»
        «IF !fields.filter[isTimeField].empty»
            $tNow = date('H:i:s');
            «IF !fields.filter[isTimeField].filter[past].empty»
                $tPast = date('H:i:s', $lastHour);
            «ENDIF»
            «IF !fields.filter[isTimeField].filter[future].empty»
                $tFuture = date('H:i:s', $nextHour);
            «ENDIF»
        «ENDIF»
    '''

    def private initExampleObjects(Entity it, Application app) '''
        «FOR number : 1..app.amountOfExampleRows»
            $«name.formatForCode»«number» = new «name.formatForCodeCapital»Entity(«exampleRowsConstructorArguments(number)»);
        «ENDFOR»
        «/* this last line is on purpose */»
    '''

    def private createExampleRows(Entity it, Application app) '''
        «val entityName = name.formatForCode»
        «IF categorisable»
            $categoryRegistry = null;
            foreach ($categoryRegistries as $registry) {
                if ($registry->getEntityname() == '«name.formatForCodeCapital»Entity') {
                    $categoryRegistry = $registry;
                    break;
                }
            }
        «ENDIF»
        «FOR number : 1..app.amountOfExampleRows»
            «IF isInheriting»
                «FOR field : parentType.getFieldsForExampleData»«exampleRowAssignment(field, it, entityName, number)»«ENDFOR»
            «ENDIF»
            «FOR field : getFieldsForExampleData»«exampleRowAssignment(field, it, entityName, number)»«ENDFOR»
            «/*«IF hasTranslatableFields»
                $«entityName»«number»->setLocale($this->request->getLocale());
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
                $«entityName»«number»->getCategories()->add(new «name.formatForCodeCapital»CategoryEntity($categoryRegistry, $category, $«entityName»«number»));
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
        try {
            «FOR entity : getAllEntities»«entity.persistEntities(it)»«ENDFOR»
        } catch (\Exception $exception) {
            $this->request->getSession()->getFlashBag()->add('error', $this->__('Exception during example data creation') . ': ' . $exception->getMessage());
            $this->logger->error('{app}: Could not completely create example data after installation. Error details: {errorMessage}.', ['app' => '«appName»', 'errorMessage' => $exception->getMessage()]);

            return false;
        }
    '''

    def private persistEntities(Entity it, Application app) '''
        «FOR number : 1..app.amountOfExampleRows»
            $success = $this->workflowHelper->executeAction($«name.formatForCode»«number», $action);
        «ENDFOR»
    '''

    def private exampleRowsConstructorArguments(Entity it, Integer number) '''
        «IF isIndexByTarget»
            «val indexRelation = incoming.filter(JoinRelationship).filter[isIndexed].head»
            «val sourceAlias = getRelationAliasName(indexRelation, false)»
            «val indexBy = indexRelation.getIndexByField»
            «val indexByField = getDerivedFields.findFirst[name == indexBy]»
            «indexByField.exampleRowsConstructorArgument(number)», $«sourceAlias.formatForCode»«number»
        «ELSEIF isAggregated»
            «FOR aggregator : getAggregators SEPARATOR ', '»
                «FOR relation : aggregator.getAggregatingRelationships SEPARATOR ', '»«relation.exampleRowsConstructorArgumentsAggregate(number)»«ENDFOR»
            «ENDFOR»
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
            NumberField: exampleRowValueNumber(dataEntity, number)
            StringField: if (#[StringRole.COUNTRY, StringRole.LANGUAGE, StringRole.LOCALE].contains(role)) '''$this->request->getLocale()''' else if (it.role == StringRole.CURRENCY) 'EUR' else if (it.role == StringRole.COLOUR) '\'#ff6600\'' else exampleRowValueText(dataEntity, number)
            TextField: exampleRowValueText(dataEntity, number)
            EmailField: '\'' + application.email + '\''
            UrlField: '\'' + application.url + '\''
            UploadField: exampleRowValueText(dataEntity, number)
            UserField: '$adminUser'
            ArrayField: exampleRowValueNumber(dataEntity, number)
            ObjectField: exampleRowValueText(dataEntity, number)
            DatetimeField: '''«IF isDateTimeField»«IF it.past»$dtPast«ELSEIF it.future»$dtFuture«ELSE»$dtNow«ENDIF»«ELSEIF isDateField»«IF it.past»$dPast«ELSEIF it.future»$dFuture«ELSE»$dNow«ENDIF»«ELSEIF isTimeField»«IF it.past»$tPast«ELSEIF it.future»$tFuture«ELSE»$tNow«ENDIF»«ENDIF»'''
            ListField: ''''«IF it.multiple»###«FOR item : getDefaultItems SEPARATOR '###'»«item.exampleRowValue»«ENDFOR»###«ELSE»«FOR item : getDefaultItems»«item.exampleRowValue»«ENDFOR»«ENDIF»'«/**/»'''
            default: ''
        }
    }

    def private exampleRowValue(ListFieldItem it) {
        if (^default) value else ''
    }

    def private exampleDataHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractExampleDataHelper;

        /**
         * Example data helper implementation class.
         */
        class ExampleDataHelper extends AbstractExampleDataHelper
        {
            // feel free to extend the example data helper here
        }
    '''
}
