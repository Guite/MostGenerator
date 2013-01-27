package org.zikula.modulestudio.generator.cartridges.zclassic.models

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.AdminController
import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Controller
import de.guite.modulestudio.metamodel.modulestudio.DateField
import de.guite.modulestudio.metamodel.modulestudio.DatetimeField
import de.guite.modulestudio.metamodel.modulestudio.DecimalField
import de.guite.modulestudio.metamodel.modulestudio.EmailField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.modulestudio.EntityIndex
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexItem
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.InheritanceRelationship
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.Validator
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Association
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Extensions
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Entities {
    @Inject extension ControllerExtensions = new ControllerExtensions()
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions()
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions()
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions()
    @Inject extension NamingExtensions = new NamingExtensions()
    @Inject extension UrlExtensions = new UrlExtensions()
    @Inject extension Utils = new Utils()

    FileHelper fh = new FileHelper()
    Association thAssoc = new Association()
    Extensions thExt = new Extensions()
    EventListener thEvLi = new EventListener()
    Property thProp = new Property()

    /**
     * Entry point for Doctrine entity classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        getAllEntities.forEach(e|e.generate(it, fsa))

        val validator = new Validator()
        validator.generateCommon(it, fsa)
        for (entity : getAllEntities) validator.generateWrapper(entity, it, fsa)

        thExt.extensionClasses(it, fsa)
    }

    /**
     * Creates an entity class file for every Entity instance.
     */
    def private generate(Entity it, Application app, IFileSystemAccess fsa) {
        println('Generating entity classes for entity "' + name.formatForDisplay + '"')
        val entityPath = app.getAppSourceLibPath + 'Entity/'
        val entityClassSuffix = if (!app.targets('1.3.5')) 'Entity' else ''
        val entityFileName = name.formatForCodeCapital + entityClassSuffix + '.php'
        if (!isInheriting) {
            if (app.targets('1.3.5')) {
            fsa.generateFile(entityPath + 'Base/' + entityFileName, modelEntityBaseFile(app))
            } else {
            fsa.generateFile(entityPath + 'Base/Abstract' + entityFileName, modelEntityBaseFile(app))
            }
        }
        fsa.generateFile(entityPath + entityFileName, modelEntityFile(app))
    }

    def private modelEntityBaseFile(Entity it, Application app) '''
        «fh.phpFileHeader(app)»
        «modelEntityBaseImpl(app)»
    '''

    def private modelEntityFile(Entity it, Application app) '''
        «fh.phpFileHeader(app)»
        «modelEntityImpl(app)»
    '''

    def private modelEntityBaseImpl(Entity it, Application app) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appName»\Entity\Base;

        «ENDIF»
        «imports»

        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the base entity class for «name.formatForDisplay» entities.
         *
         * @abstract
         */
        «IF app.targets('1.3.5')»
        abstract class «app.appName»_Entity_Base_«name.formatForCodeCapital» extends Zikula_EntityAccess«IF hasNotifyPolicy» implements NotifyPropertyChanged«ENDIF»
        «ELSE»
        abstract class Abstract«name.formatForCodeCapital» extends \Zikula_EntityAccess«IF hasNotifyPolicy» implements
            NotifyPropertyChanged«ENDIF»
        «ENDIF»
        {
            «entityInfo(app)»

            «thEvLi.generateBase(it)»

            «cloneImpl(app)»
        }
    '''

    def private imports(Entity it) '''
        use Doctrine\ORM\Mapping as ORM;
        «IF hasCollections || attributable || categorisable»
            use Doctrine\Common\Collections\ArrayCollection;
        «ENDIF»
        «thExt.imports(it)»
        «IF hasNotifyPolicy»
            use Doctrine\Common\NotifyPropertyChanged,
                Doctrine\Common\PropertyChangedListener;
        «ENDIF»
        «IF standardFields»
            use DoctrineExtensions\StandardFields\Mapping\Annotation as ZK;
        «ENDIF»
    '''

    def private index(EntityIndex it, String indexType) '''
         *         @ORM\«indexType.toFirstUpper»(name="«name.formatForDB»", columns={«FOR item : items SEPARATOR ','»«item.indexField»«ENDFOR»})
    '''
    def private indexField(EntityIndexItem it) '''"«name.formatForCode»"'''

    def private discriminatorInfo(InheritanceRelationship it) '''
        , "«source.name.formatForCode»" = "«source.entityClassName('', false)»"
    '''

    def private modelEntityImpl(Entity it, Application app) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appName»\Entity;

        «ENDIF»
        «imports»

        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the concrete entity class for «name.formatForDisplay» entities.
         «thExt.classExtensions(it)»
         «IF mappedSuperClass»
          * @ORM\MappedSuperclass
         «ELSE»
          * @ORM\Entity(repositoryClass="«IF app.targets('1.3.5')»«app.appName»_Entity_Repository_«name.formatForCodeCapital»«ELSE»«app.appName»\Entity\Repository\«name.formatForCodeCapital»«ENDIF»"«IF readOnly», readOnly=true«ENDIF»)
         «ENDIF»
         «IF indexes.isEmpty»
          * @ORM\Table(name="«fullEntityTableName»")
         «ELSE»
          * @ORM\Table(name="«fullEntityTableName»",
         «IF hasNormalIndexes»
          *     indexes={
         «FOR index : getNormalIndexes SEPARATOR ','»«index.index('Index')»«ENDFOR»
          *     }«IF hasUniqueIndexes»,«ENDIF»
         «ENDIF»
         «IF hasUniqueIndexes»
          *     uniqueConstraints={
         «FOR index : getUniqueIndexes SEPARATOR ','»«index.index('UniqueConstraint')»«ENDFOR»
          *     }
         «ENDIF»
          * )
         «ENDIF»
         «IF isTopSuperClass»
          * @ORM\InheritanceType("«getChildRelations.head.strategy.asConstant»")
          * @ORM\DiscriminatorColumn(name="«getChildRelations.head.discriminatorColumn.formatForCode»"«/*, type="string"*/»)
          * @ORM\DiscriminatorMap({"«name.formatForCode»" = "«entityClassName('', false)»"«FOR relation : getChildRelations»«relation.discriminatorInfo»«ENDFOR»})
         «ENDIF»
         «IF changeTrackingPolicy != EntityChangeTrackingPolicy::DEFERRED_IMPLICIT»
          * @ORM\ChangeTrackingPolicy("«changeTrackingPolicy.asConstant»")
         «ENDIF»
         * @ORM\HasLifecycleCallbacks
         */
        «IF app.targets('1.3.5')»
        class «entityClassName('', false)» extends «IF isInheriting»«parentType.entityClassName('', false)»«ELSE»«entityClassName('', true)»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital» extends «IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»«ENDIF»
        «ENDIF»
        {
            // feel free to add your own methods here
            «IF isInheriting»
                «FOR field : getDerivedFields»«thProp.persistentProperty(field)»«ENDFOR»
                «thExt.additionalProperties(it)»

                «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.generate(relation, false)»«ENDFOR»
                «FOR relation : getOutgoingJoinRelations»«thAssoc.generate(relation, true)»«ENDFOR»
                «constructor(true)»

                «FOR field : getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
                «thExt.additionalAccessors(it)»

                «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
                «FOR relation : getOutgoingJoinRelations»«thAssoc.relationAccessor(relation, true)»«ENDFOR»
            «ENDIF»

            «thEvLi.generateImpl(it)»
        }
    '''


    def private entityInfo(Entity it, Application app) '''
        /**
         * @var string The tablename this object maps to.
         */
        protected $_objectType = '«name.formatForCode»';

        /**
         * @var array List of primary key field names.
         */
        protected $_idFields = array();
        «val validatorClass = if (app.targets('1.3.5')) app.appName + '_Entity_Validator_' + name.formatForCodeCapital else app.appName + '\\Entity\\Validator\\' + name.formatForCodeCapital»
        /**
         * @var «validatorClass» The validator for this entity.
         */
        protected $_validator = null;

        /**
         * @var boolean Whether this entity supports unique slugs.
         */
        protected $_hasUniqueSlug = false;
        «IF hasNotifyPolicy»

            /**
             * @var array List of change notification listeners.
             */
            protected $_propertyChangedListeners = array();
        «ENDIF»

        /**
         * @var array List of available item actions.
         */
        protected $_actions = array();

        /**
         * @var array The current workflow data of this object.
         */
        protected $__WORKFLOW__ = array();

        «FOR field : getDerivedFields»«thProp.persistentProperty(field)»«ENDFOR»
        «thExt.additionalProperties(it)»

        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.generate(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.generate(relation, true)»«ENDFOR»

        «constructor(false)»

        «fh.getterAndSetterMethods(it, '_objectType', 'string', false, false, '', '')»
        «fh.getterAndSetterMethods(it, '_idFields', 'array', false, true, 'Array()', '')»
        «fh.getterAndSetterMethods(it, '_validator', validatorClass, false, true, 'null', '')»
        «fh.getterAndSetterMethods(it, '_hasUniqueSlug', 'boolean', false, false, '', '')»
        «fh.getterAndSetterMethods(it, '_actions', 'array', false, true, 'Array()', '')»
        «fh.getterAndSetterMethods(it, '__WORKFLOW__', 'array', false, true, 'Array()', '')»
        «propertyChangedListener»

        «FOR field : getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
        «thExt.additionalAccessors(it)»

        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.relationAccessor(relation, true)»«ENDFOR»

        /**
         * Initialise validator and return it's instance.
         *
         * @return «validatorClass» The validator for this entity.
         */
        public function initValidator()
        {
            if (!is_null($this->_validator)) {
                return $this->_validator;
            }
            $this->_validator = new «validatorClass»($this);
            return $this->_validator;
        }

        /**
         * Start validation and raise exception if invalid data is found.
         *
         * @return void.
         * @throws Zikula_Exception
         */
        public function validate()
        {
        «val emailFields = getDerivedFields().filter(typeof(EmailField))»
        «IF emailFields.size > 0»
                // decode possibly encoded mail addresses (#201)
            «FOR emailField : emailFields»
                if (strpos($this['«emailField.name.formatForCode»'], '&#') !== false) {
                    $this['«emailField.name.formatForCode»'] = html_entity_decode($this['«emailField.name.formatForCode»']);
                }
            «ENDFOR»
        «ENDIF»
            $result = $this->initValidator()->validateAll();
            if (is_array($result)) {
                throw new Zikula_Exception($result['message'], $result['code'], $result['debugArray']);
            }
        }

        /**
         * Return entity data in JSON format.
         *
         * @return string JSON-encoded data.
         */
        public function toJson()
        {
            return json_encode($this->toArray());
        }

        /**
         * Collect available actions for this entity.
         */
        protected function prepareItemActions()
        {
            if (!empty($this->_actions)) {
                return;
            }

            $currentType = \FormUtil::getPassedValue('type', 'user', 'GETPOST', FILTER_SANITIZE_STRING);
            $currentFunc = \FormUtil::getPassedValue('func', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'GETPOST', FILTER_SANITIZE_STRING);
            «val appName = app.appName»
            $dom = ZLanguage::getModuleDomain('«appName»');
            «FOR controller : app.getAdminAndUserControllers»
                if ($currentType == '«controller.formattedName»') {
                    «IF controller.hasActions('view')»
                        if (in_array($currentFunc, array('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'view'))) {
                            «IF controller.tempIsAdminController && container.application.hasUserController && container.application.getMainUserController.hasActions('display')»
                                $this->_actions[] = array(
                                    'url' => array('type' => 'user', 'func' => 'display', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false)»«IF hasSluggableFields», 'slug' => $this->slug«ENDIF»)),
                                    'icon' => 'preview',
                                    'linkTitle' => __('Open preview page', $dom),
                                    'linkText' => __('Preview', $dom)
                                );
                            «ENDIF»
                            «IF controller.hasActions('display')»
                                «val leadingField = getLeadingField»
                                $this->_actions[] = array(
                                    'url' => array('type' => '«controller.formattedName»', 'func' => 'display', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false)»«IF hasSluggableFields», 'slug' => $this->slug«ENDIF»)),
                                    'icon' => 'display',
                                    'linkTitle' => «IF leadingField != null»str_replace('"', '', $this['«leadingField.name.formatForCode»'])«ELSE»__('Open detail page', $dom)«ENDIF»,
                                    'linkText' => __('Details', $dom)
                                );
                            «ENDIF»
                        }
                    «ENDIF»
                    «IF controller.hasActions('view') || controller.hasActions('display')»
                        if (in_array($currentFunc, array('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'view', 'display'))) {
                            «IF controller.hasActions('edit')»
                                if (\SecurityUtil::checkPermission('«appName»:«name.formatForCodeCapital»:', «idFieldsAsParameterCode('this')» . '::', ACCESS_EDIT)) {
                            «IF !readOnly»«/*create is allowed, but editing not*/»
                                $this->_actions[] = array(
                                    'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false)»)),
                                    'icon' => 'edit',
                                    'linkTitle' => __('Edit', $dom),
                                    'linkText' => __('Edit', $dom)
                                );
                            «ENDIF»
                            «IF tree != EntityTreeType::NONE»
                                /*
                            «ENDIF»
                                    $this->_actions[] = array(
                                        'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false, 'astemplate')»)),
                                        'icon' => 'saveas',
                                        'linkTitle' => __('Reuse for new item', $dom),
                                        'linkText' => __('Reuse', $dom)
                                    );
                            «IF tree != EntityTreeType::NONE»
                                */
                            «ENDIF»
                                }
                            «ENDIF»
                            «IF controller.hasActions('delete')»
                                if (\SecurityUtil::checkPermission('«appName»:«name.formatForCodeCapital»:', «idFieldsAsParameterCode('this')» . '::', ACCESS_DELETE)) {
                                    $this->_actions[] = array(
                                        'url' => array('type' => '«controller.formattedName»', 'func' => 'delete', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false)»)),
                                        'icon' => 'delete',
                                        'linkTitle' => __('Delete', $dom),
                                        'linkText' => __('Delete', $dom)
                                    );
                                }
                            «ENDIF»
                        }
                    «ENDIF»
                    «IF controller.hasActions('display')»
                        if ($currentFunc == 'display') {
                            «IF controller.hasActions('view')»
                                $this->_actions[] = array(
                                    'url' => array('type' => '«controller.formattedName»', 'func' => 'view', 'arguments' => array('ot' => '«name.formatForCode»')),
                                    'icon' => 'back',
                                    'linkTitle' => __('Back to overview', $dom),
                                    'linkText' => __('Back to overview', $dom)
                                );
                            «ENDIF»
                        }
                    «ENDIF»
                }
            «ENDFOR»
        }

        /**
         * Create concatenated identifier string (for composite keys).
         *
         * @return String concatenated identifiers.
         */
        protected function createCompositeIdentifier()
        {
            «IF hasCompositeKeys»
                $itemId = '';
                «FOR pkField : getPrimaryKeyFields»
                    $itemId .= ((!empty($itemId)) ? '_' : '') . $this['«pkField.name.formatForCode»'];
                «ENDFOR»
            «ELSE»
                $itemId = $this['«getFirstPrimaryKey.name.formatForCode»'];
            «ENDIF»

            return $itemId;
        }

        /**
         * Return lower case name of multiple items needed for hook areas.
         *
         * @return string
         */
        public function getHookAreaPrefix()
        {
            return '«app.name.formatForDB».ui_hooks.«nameMultiple.formatForDB»';
        }
    '''

    def private tempIsAdminController(Controller it) {
        switch it {
            AdminController: true
            default: false
        }
    }

    def private constructor(Entity it, Boolean isInheriting) '''
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
            «val indexRelation = getIncomingJoinRelations.filter(e|e.isIndexed).head»
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
        «val mandatoryFields = getDerivedFields.filter(e|e.mandatory)»
        «FOR mandatoryField : mandatoryFields.filter(typeof(IntegerField)).filter(e|e.defaultValue == null || e.defaultValue == '' || e.defaultValue == '0')»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(typeof(UserField)).filter(e|e.defaultValue == null || e.defaultValue == '' || e.defaultValue == '0')»
            $this->«mandatoryField.name.formatForCode» = \UserUtil::getVar('uid');
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(typeof(DecimalField)).filter(e|e.defaultValue == null || e.defaultValue == '' || e.defaultValue == '0')»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(typeof(AbstractDateField)).filter(e|e.defaultValue == null || e.defaultValue == '' || e.defaultValue.length == 0)»
            $this->«mandatoryField.name.formatForCode» = «mandatoryField.defaultAssignment»;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(typeof(FloatField)).filter(e|e.defaultValue == null || e.defaultValue == '' || e.defaultValue == '0')»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        $this->workflowState = 'initial';
        «IF isIndexByTarget»
            «val indexRelation = incoming.filter(typeof(JoinRelationship)).filter(e|e.isIndexed).head»
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
        $this->_idFields = array(«FOR pkField : getPrimaryKeyFields SEPARATOR ', '»'«pkField.name.formatForCode»'«ENDFOR»);
        $this->initValidator();
        $this->_hasUniqueSlug = «IF hasSluggableFields && slugUnique»true«ELSE»false«ENDIF»;
        «thAssoc.initCollections(it)»
    '''

    def private constructorAssignmentAggregate(OneToManyRelationship it) '''
        «val targetField = source.getAggregateFields.head.getAggregateTargetField»
        $this->«getRelationAliasName(false)» = $«getRelationAliasName(false)»;
        $this->«targetField.name.formatForCode» = $«targetField.name.formatForCode»;
    '''

    def private defaultAssignment(AbstractDateField it) '''DateTime::createFromFormat('«defaultFormat»', date('«defaultFormat»'))'''
    def private dispatch defaultFormat(AbstractDateField it) {
    }
    def private dispatch defaultFormat(DatetimeField it) '''Y-m-d H:i:s'''
    def private dispatch defaultFormat(DateField it) '''Y-m-d'''
    def private dispatch defaultFormat(TimeField it) '''H:i:s'''

    def private propertyChangedListener(Entity it) '''
        «IF hasNotifyPolicy»

            /**
             * Adds a property change listener.
             *
             * @param PropertyChangedListener $listener The listener to be added
             */
            public function addPropertyChangedListener(PropertyChangedListener $listener)
            {
                $this->_propertyChangedListeners[] = $listener;
            }

            /**
             * Notify all registered listeners about a changed property.
             *
             * @param String $propName Name of property which has been changed
             * @param mixed  $oldValue The old property value
             * @param mixed  $newValue The new property value
             */
            protected function _onPropertyChanged($propName, $oldValue, $newValue)
            {
                if ($this->_propertyChangedListeners) {
                    foreach ($this->_propertyChangedListeners as $listener) {
                        $listener->propertyChanged($this, $propName, $oldValue, $newValue);
                    }
                }
            }
        «ENDIF»
    '''

    def private cloneImpl(Entity it, Application app) '''
        «val joinsIn = getBidirectionalIncomingJoinRelations»
        «val joinsOut = getOutgoingJoinRelations»
        /**
         * Clone interceptor implementation.
         * This method is for example called by the reuse functionality.
        «IF joinsIn.isEmpty && joinsOut.isEmpty»
         * Performs a quite simple shallow copy.
        «ELSE»
         * Performs a deep copy. 
        «ENDIF»
         *
         * See also:
         * (1) http://docs.doctrine-project.org/en/latest/cookbook/implementing-wakeup-or-clone.html
         * (2) http://www.sunilb.com/php/php5-oops-tutorial-magic-methods-__clone-method
         * (3) http://stackoverflow.com/questions/185934/how-do-i-create-a-copy-of-an-object-in-php
         */
        public function __clone()
        {
            // If the entity has an identity, proceed as normal.
            if («FOR field : primaryKeyFields SEPARATOR ' && '»$this->«field.name.formatForCode»«ENDFOR») {
                // create new instance
                «/* TODO: consider custom constructor arguments (indexed, aggregated - see above) */»
                $entity = new «entityClassName('', false)»();
                // unset identifiers
                «FOR field : primaryKeyFields»
                    $entity->set«field.name.formatForCodeCapital»(null);
                «ENDFOR»
                // copy simple fields
                «FOR field : getDerivedFields.filter(e|!e.primaryKey)»
                    $entity->set«field.name.formatForCodeCapital»($this->get«field.name.formatForCodeCapital»());
                «ENDFOR»

                «IF !joinsIn.isEmpty || !joinsOut.isEmpty»
                    // handle related objects
                    // prevent shared references by doing a deep copy - see (2) and (3) for more information
                    «FOR relation : joinsIn»
                        «var aliasName = relation.getRelationAliasName(false)»
                        $this->«aliasName» = clone $this->«aliasName»;
                        $entity->set«aliasName.toFirstUpper»($this->«aliasName»);
                    «ENDFOR»
                    «FOR relation : joinsOut»
                        «var aliasName = relation.getRelationAliasName(true)»
                        $this->«aliasName» = clone $this->«aliasName»;
                        $entity->set«aliasName.toFirstUpper»($this->«aliasName»);
                    «ENDFOR»
                «ENDIF»

                return $entity;
            }
            // otherwise do nothing, do NOT throw an exception!
        }
    '''
}
