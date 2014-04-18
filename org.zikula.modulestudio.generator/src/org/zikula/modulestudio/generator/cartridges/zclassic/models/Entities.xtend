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
import de.guite.modulestudio.metamodel.modulestudio.EntityField
import de.guite.modulestudio.metamodel.modulestudio.EntityIndex
import de.guite.modulestudio.metamodel.modulestudio.EntityIndexItem
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import de.guite.modulestudio.metamodel.modulestudio.FloatField
import de.guite.modulestudio.metamodel.modulestudio.InheritanceRelationship
import de.guite.modulestudio.metamodel.modulestudio.IntegerField
import de.guite.modulestudio.metamodel.modulestudio.JoinRelationship
import de.guite.modulestudio.metamodel.modulestudio.ListField
import de.guite.modulestudio.metamodel.modulestudio.ManyToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.OneToManyRelationship
import de.guite.modulestudio.metamodel.modulestudio.TimeField
import de.guite.modulestudio.metamodel.modulestudio.UserField
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidatorLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Association
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ExtensionManager
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Entities {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension FormattingExtensions = new FormattingExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension ModelExtensions = new ModelExtensions
    @Inject extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    @Inject extension ModelJoinExtensions = new ModelJoinExtensions
    @Inject extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension UrlExtensions = new UrlExtensions
    @Inject extension Utils = new Utils

    FileHelper fh = new FileHelper
    Association thAssoc = new Association
    ExtensionManager extMan
    EventListener thEvLi = new EventListener
    Property thProp

    /**
     * Entry point for Doctrine entity classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        getAllEntities.forEach(e|e.generate(it, fsa))

        if (targets('1.3.5')) {
            val validator = new ValidatorLegacy()
            validator.generateCommon(it, fsa)
            for (entity : getAllEntities) {
                validator.generateWrapper(entity, fsa)
            }
        }

        for (entity : getAllEntities) {
            extMan = new ExtensionManager(entity)
            extMan.extensionClasses(fsa)
        }
    }

    /**
     * Creates an entity class file for every Entity instance.
     */
    def private generate(Entity it, Application app, IFileSystemAccess fsa) {
        println('Generating entity classes for entity "' + name.formatForDisplay + '"')
        extMan = new ExtensionManager(it)
        thProp = new Property(extMan)
        val entityPath = app.getAppSourceLibPath + 'Entity/'
        val entityClassSuffix = if (!app.targets('1.3.5')) 'Entity' else ''
        val entityFileName = name.formatForCodeCapital + entityClassSuffix
        var fileName = ''
        if (!isInheriting) {
            fileName = entityFileName + '.php'
            if (app.targets('1.3.5') && !app.shouldBeSkipped(entityPath + 'Base/' + fileName)) {
                if (app.shouldBeMarked(entityPath + 'Base/' + fileName)) {
                    fileName = entityFileName + '.generated.php'
                }
                fsa.generateFile(entityPath + 'Base/' + fileName, modelEntityBaseFile(app))
            } else if (!app.shouldBeSkipped(entityPath + 'Base/Abstract' + fileName)) {
                if (app.shouldBeMarked(entityPath + 'Base/Abstract' + fileName)) {
                    fileName = entityFileName + '.generated.php'
                }
                fsa.generateFile(entityPath + 'Base/Abstract' + fileName, modelEntityBaseFile(app))
            }
        }
        fileName = entityFileName + '.php'
        if (!app.generateOnlyBaseClasses && !app.shouldBeSkipped(entityPath + fileName)) {
            if (app.shouldBeMarked(entityPath + fileName)) {
                fileName = entityFileName + '.generated.php'
            }
            fsa.generateFile(entityPath + fileName, modelEntityFile(app))
        }
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
            namespace «app.appNamespace»\Entity\Base;

        «ENDIF»
        «imports»
        «IF !app.targets('1.3.5')»

            «IF hasUploadFieldsEntity»
                use «app.appNamespace»\UploadHandler;
                use «app.appNamespace»\Util\ControllerUtil;
            «ENDIF»
            use «app.appNamespace»\Util\WorkflowUtil;

            use DataUtil;
            use FormUtil;
            use ModUtil;
            use SecurityUtil;
            use ServiceUtil;
            use System;
            use UserUtil;
            use Zikula_EntityAccess;
            use Zikula_Exception;
            use Zikula_Workflow_Util;
            use ZLanguage;
        «ENDIF»

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
        abstract class Abstract«name.formatForCodeCapital»Entity extends Zikula_EntityAccess«IF hasNotifyPolicy» implements
            NotifyPropertyChanged«ENDIF»
        «ENDIF»
        {
            «entityInfo(app)»

            «relatedObjectsImpl(app)»

            «thEvLi.generateBase(it)»

            «getTitleFromDisplayPattern(app)»
            «val thVal = new ValidationConstraints»
            «IF hasListFieldsEntity»
                «FOR listField : getListFieldsEntity»

                    «thVal.validationMethods(listField)»
                «ENDFOR»
            «ENDIF»
            «IF hasUserFieldsEntity»
                «FOR userField : getUserFieldsEntity»

                    «thVal.validationMethods(userField)»
                «ENDFOR»
            «ENDIF»
            «val dateTimeFields = fields.filter(AbstractDateField)»
            «IF !dateTimeFields.empty»
                «FOR dateField : dateTimeFields»

                    «thVal.validationMethods(dateField)»
                «ENDFOR»
            «ENDIF»

            «toStringImpl(app)»

            «cloneImpl(app)»
        }
    '''

    def private imports(Entity it) '''
        use Doctrine\ORM\Mapping as ORM;
        «IF hasCollections || attributable || categorisable»
            use Doctrine\Common\Collections\ArrayCollection;
        «ENDIF»
        use Gedmo\Mapping\Annotation as Gedmo;
        «IF hasNotifyPolicy»
            use Doctrine\Common\NotifyPropertyChanged;
            use Doctrine\Common\PropertyChangedListener;
        «ENDIF»
        «IF standardFields»
            use DoctrineExtensions\StandardFields\Mapping\Annotation as ZK;
        «ENDIF»
        «IF !container.application.targets('1.3.5')»
            use Symfony\Component\Validator\Constraints as Assert;
            «IF !getUniqueDerivedFields.filter[!primaryKey].empty || (hasSluggableFields && slugUnique) || !getIncomingJoinRelations.filter[unique].empty || !getOutgoingJoinRelations.filter[unique].empty»
                use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
            «ENDIF»
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
            namespace «app.appNamespace»\Entity;

            use «app.appNamespace»\Entity\«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»Entity«ENDIF» as Base«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»Entity«ENDIF»;

        «ENDIF»
        «imports»

        «entityImplClassDocblock(app)»
        «IF app.targets('1.3.5')»
        class «entityClassName('', false)» extends «IF isInheriting»«parentType.entityClassName('', false)»«ELSE»«entityClassName('', true)»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital»Entity extends Base«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»Entity«ENDIF»
        «ENDIF»
        {
            // feel free to add your own methods here
            «IF isInheriting»
                «FOR field : getDerivedFields»«thProp.persistentProperty(field)»«ENDFOR»
                «extMan.additionalProperties»

                «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.generate(relation, false)»«ENDFOR»
                «FOR relation : getOutgoingJoinRelations»«thAssoc.generate(relation, true)»«ENDFOR»
                «constructor(true)»

                «FOR field : getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
                «extMan.additionalAccessors»

                «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
                «FOR relation : getOutgoingJoinRelations»«thAssoc.relationAccessor(relation, true)»«ENDFOR»
            «ENDIF»

            «thEvLi.generateImpl(it)»
        }
    '''

    def private entityImplClassDocblock(Entity it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the concrete entity class for «name.formatForDisplay» entities.
         «extMan.classAnnotations»
         «IF mappedSuperClass»
          * @ORM\MappedSuperclass
         «ELSE»
          * @ORM\Entity(repositoryClass="«IF app.targets('1.3.5')»«app.appName»_Entity_Repository_«name.formatForCodeCapital»«ELSE»\«app.appNamespace»\Entity\Repository\«name.formatForCodeCapital»«ENDIF»"«IF readOnly», readOnly=true«ENDIF»)
         «ENDIF»
         «IF indexes.empty»
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
          * @ORM\InheritanceType("«getChildRelations.head.strategy.literal»")
          * @ORM\DiscriminatorColumn(name="«getChildRelations.head.discriminatorColumn.formatForCode»"«/*, type="string"*/»)
          * @ORM\Discriminatormap[{"«name.formatForCode»" = "«entityClassName('', false)»"«FOR relation : getChildRelations»«relation.discriminatorInfo»«ENDFOR»})
         «ENDIF»
         «IF changeTrackingPolicy != EntityChangeTrackingPolicy::DEFERRED_IMPLICIT»
          * @ORM\ChangeTrackingPolicy("«changeTrackingPolicy.literal»")
         «ENDIF»
         * @ORM\HasLifecycleCallbacks
        «IF !app.targets('1.3.5')»
            «val thVal = new ValidationConstraints»
            «thVal.classAnnotations(it)»
        «ENDIF»
         */
    '''


    def private entityInfo(Entity it, Application app) '''
        «val validatorClass = if (app.targets('1.3.5')) app.appName + '_Entity_Validator_' + name.formatForCodeCapital else '\\' + app.vendor.formatForCodeCapital + '\\' + app.name.formatForCodeCapital + 'Module\\Entity\\Validator\\' + name.formatForCodeCapital + 'Validator'»
        «memberVars(validatorClass)»

        «constructor(false)»

        «accessors(validatorClass)»
        «IF app.targets('1.3.5')»

            «initValidator(validatorClass)»
        «ENDIF»

        «initWorkflow(app)»

        «resetWorkflow(app)»

        «validate»

        «toJson»

        «prepareItemActions(app)»

        «createUrlArgs»

        «createCompositeIdentifier»

        «getHookAreaPrefix»
    '''

    def private memberVars(Entity it, String validatorClass) '''
        /**
         * @var string The tablename this object maps to.
         */
        protected $_objectType = '«name.formatForCode»';
        «IF container.application.targets('1.3.5')»

            /**
             * @var «validatorClass» The validator for this entity.
             */
            protected $_validator = null;
        «ENDIF»

        /**
         «IF !container.application.targets('1.3.5')»
         * @Assert\Type(type="bool")
         «ENDIF»
         * @var boolean Option to bypass validation if needed.
         */
        protected $_bypassValidation = false;
        «IF hasNotifyPolicy»

            /**
             «IF !container.application.targets('1.3.5')»
             * @Assert\Type(type="array")
             «ENDIF»
             * @var array List of change notification listeners.
             */
            protected $_propertyChangedListeners = array();
        «ENDIF»

        /**
         «IF !container.application.targets('1.3.5')»
         * @Assert\Type(type="array")
         «ENDIF»
         * @var array List of available item actions.
         */
        protected $_actions = array();

        /**
         * @var array The current workflow data of this object.
         */
        protected $__WORKFLOW__ = array();

        «FOR field : getDerivedFields»«thProp.persistentProperty(field)»«ENDFOR»
        «extMan.additionalProperties»

        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.generate(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.generate(relation, true)»«ENDFOR»
    '''

    def private accessors(Entity it, String validatorClass) '''
        «fh.getterAndSetterMethods(it, '_objectType', 'string', false, false, '', '')»
        «IF container.application.targets('1.3.5')»
            «fh.getterAndSetterMethods(it, '_validator', validatorClass, false, true, 'null', '')»
        «ENDIF»
        «fh.getterAndSetterMethods(it, '_bypassValidation', 'boolean', false, false, '', '')»
        «fh.getterAndSetterMethods(it, '_actions', 'array', false, true, 'Array()', '')»
        «fh.getterAndSetterMethods(it, '__WORKFLOW__', 'array', false, true, 'Array()', '')»
        «propertyChangedListener»

        «FOR field : getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
        «extMan.additionalAccessors»

        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.relationAccessor(relation, true)»«ENDFOR»
    '''

    /**
     * Initialises the validator instance. Used for 1.3.x target only, replaced by Symfony Validator in 1.4.x.
     */
    def private initValidator(Entity it, String validatorClass) '''
        /**
         * Initialises the validator and return it's instance.
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
    '''

    def private initWorkflow(Entity it, Application app) '''
        /**
         * Sets/retrieves the workflow details.
         *
         * @param boolean $forceLoading load the workflow record.
         «IF !app.targets('1.3.5')»
         *
         * @throws RuntimeException Thrown if retrieving the workflow object fails
         «ENDIF»
         */
        public function initWorkflow($forceLoading = false)
        {
            $currentFunc = FormUtil::getPassedValue('func', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'GETPOST', FILTER_SANITIZE_STRING);
            $isReuse = FormUtil::getPassedValue('astemplate', '', 'GETPOST', FILTER_SANITIZE_STRING);

            «loadWorkflow»
        }
    '''

    def private resetWorkflow(Entity it, Application app) '''
        /**
         * Resets workflow data back to initial state.
         * To be used after cloning an entity object.
         */
        public function resetWorkflow()
        {
            $this->setWorkflowState('initial');
            $workflowHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Workflow«ELSE»WorkflowUtil«ENDIF»(ServiceUtil::getManager()«IF !app.targets('1.3.5')», ModUtil::getModule('«app.appName»')«ENDIF»);
            $schemaName = $workflowHelper->getWorkflowName($this['_objectType']);
            $this['__WORKFLOW__'] = array(
                'module' => '«app.appName»',
                'state' => $this['workflowState'],
                'obj_table' => $this['_objectType'],
                'obj_idcolumn' => '«primaryKeyFields.head.name.formatForCode»',
                'obj_id' => 0,
                'schemaname' => $schemaName);
        }
    '''

    /**
     * Performs validation.
     */
    def private validate(Entity it) '''
        /**
         * Start validation and raise exception if invalid data is found.
         *
         * @return void.
         *
         * @throws Zikula_Exception Thrown if a validation error occurs
         */
        public function validate()
        {
            if ($this->_bypassValidation === true) {
                return;
            }

        «val emailFields = getDerivedFields.filter(EmailField)»
        «IF emailFields.size > 0»
                // decode possibly encoded mail addresses (#201)
            «FOR emailField : emailFields»
                if (strpos($this['«emailField.name.formatForCode»'], '&#') !== false) {
                    $this['«emailField.name.formatForCode»'] = html_entity_decode($this['«emailField.name.formatForCode»']);
                }
            «ENDFOR»
        «ENDIF»
        «IF container.application.targets('1.3.5')»
            $result = $this->initValidator()->validateAll();
            if (is_array($result)) {
                throw new Zikula_Exception($result['message'], $result['code'], $result['debugArray']);
            }
        «ELSE»
            $serviceManager = ServiceUtil::getManager();

            $validator = $serviceManager->get('validator');
            $errors = $validator->validate($this);

            if (count($errors) > 0) {
                $session = $serviceManager->get('session');
                foreach ($errors as $error) {
                    $session->getFlashBag()->add('error', $error['message']);
                }
            }
        «ENDIF»
        }
    '''

    def private toJson(Entity it) '''
        /**
         * Return entity data in JSON format.
         *
         * @return string JSON-encoded data.
         */
        public function toJson()
        {
            return json_encode($this->toArray());
        }
    '''

    def private prepareItemActions(Entity it, Application app) '''
        /**
         * Collect available actions for this entity.
         */
        protected function prepareItemActions()
        {
            if (!empty($this->_actions)) {
                return;
            }

            $currentType = FormUtil::getPassedValue('type', 'user', 'GETPOST', FILTER_SANITIZE_STRING);
            $currentFunc = FormUtil::getPassedValue('func', '«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'GETPOST', FILTER_SANITIZE_STRING);
            «val appName = app.appName»
            $dom = ZLanguage::getModuleDomain('«appName»');
            «FOR controller : app.getAdminAndUserControllers»
                if ($currentType == '«controller.formattedName»') {
                    «itemActionsTargetingDisplay(app, controller)»
                    «itemActionsTargetingEdit(app, controller)»
                    «itemActionsTargetingView(app, controller)»
                    «itemActionsForAddingRelatedItems(app, controller)»
                }
            «ENDFOR»
        }
    '''

    def private itemActionsTargetingDisplay(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('view')»
            if (in_array($currentFunc, array('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'view'))) {
                «IF controller.tempIsAdminController && container.application.hasUserController && container.application.getMainUserController.hasActions('display')»
                    $this->_actions[] = array(
                        'url' => array('type' => 'user', 'func' => 'display', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false)»«IF hasSluggableFields», 'slug' => $this->slug«ENDIF»)),
                        'icon' => '«IF app.targets('1.3.5')»preview«ELSE»search-plus«ENDIF»',
                        'linkTitle' => __('Open preview page', $dom),
                        'linkText' => __('Preview', $dom)
                    );
                «ENDIF»
                «IF controller.hasActions('display')»
                    $this->_actions[] = array(
                        'url' => array('type' => '«controller.formattedName»', 'func' => 'display', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false)»«IF hasSluggableFields», 'slug' => $this->slug«ENDIF»)),
                        'icon' => '«IF app.targets('1.3.5')»display«ELSE»eye«ENDIF»',
                        'linkTitle' => str_replace('"', '', $this->getTitleFromDisplayPattern())«/*__('Open detail page', $dom)*/»,
                        'linkText' => __('Details', $dom)
                    );
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingEdit(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('view') || controller.hasActions('display')»
            if (in_array($currentFunc, array('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'view', 'display'))) {
                «IF controller.hasActions('edit') || controller.hasActions('delete')»
                     $component = '«app.appName»:«name.formatForCodeCapital»:';
                     $instance = «idFieldsAsParameterCode('this')» . '::';
                «ENDIF»
                «IF controller.hasActions('edit')»
                    if (SecurityUtil::checkPermission($component, $instance, ACCESS_EDIT)) {
                        «IF ownerPermission && standardFields»
                            // only allow editing for the owner or people with higher permissions
                            if ($this['createdUserId'] == UserUtil::getVar('uid') || SecurityUtil::checkPermission($component, $instance, ACCESS_ADD)) {
                                «itemActionsForEditAction(controller)»
                            }
                        «ELSE»
                            «itemActionsForEditAction(controller)»
                        «ENDIF»
                    }
                «ENDIF»
                «IF controller.hasActions('delete')»
                    if (SecurityUtil::checkPermission($component, $instance, ACCESS_DELETE)) {
                        $this->_actions[] = array(
                            'url' => array('type' => '«controller.formattedName»', 'func' => 'delete', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false)»)),
                            'icon' => '«IF app.targets('1.3.5')»delete«ELSE»trash-o«ENDIF»',
                            'linkTitle' => __('Delete', $dom),
                            'linkText' => __('Delete', $dom)
                        );
                    }
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsTargetingView(Entity it, Application app, Controller controller) '''
        «IF controller.hasActions('display')»
            if ($currentFunc == 'display') {
                «IF controller.hasActions('view')»
                    $this->_actions[] = array(
                        'url' => array('type' => '«controller.formattedName»', 'func' => 'view', 'arguments' => array('ot' => '«name.formatForCode»')),
                        'icon' => '«IF app.targets('1.3.5')»back«ELSE»reply«ENDIF»',
                        'linkTitle' => __('Back to overview', $dom),
                        'linkText' => __('Back to overview', $dom)
                    );
                «ENDIF»
            }
        «ENDIF»
    '''

    def private itemActionsForAddingRelatedItems(Entity it, Application app, Controller controller) '''
        «val refedElems = getOutgoingJoinRelations.filter[e|e.target.container.application == it.container.application] + incoming.filter(ManyToManyRelationship).filter[e|e.source.container.application == it.container.application]»
        «IF !refedElems.empty && controller.hasActions('edit')»

            // more actions for adding new related items
            $authAdmin = SecurityUtil::checkPermission($component, $instance, ACCESS_ADMIN);
            «/* TODO review the permission levels and maybe define them for each related entity
              * ACCESS_ADMIN for admin controllers else: «IF relatedEntity.workflow == EntityWorkflowType::NONE»EDIT«ELSE»COMMENT«ENDIF»
              */»
            $uid = UserUtil::getVar('uid');
            if ($authAdmin || (isset($uid) && isset($this->createdUserId) && $this->createdUserId == $uid)) {
                «FOR elem : refedElems»

                    «val useTarget = (elem.source == it)»
                    «val relationAliasName = elem.getRelationAliasName(useTarget).formatForCode.toFirstLower»
                    «val relationAliasNameParam = elem.getRelationAliasName(!useTarget).formatForCodeCapital»
                    «val otherEntity = (if (!useTarget) elem.source else elem.target)»
                    «val many = elem.isManySideDisplay(useTarget)»
                    «IF !many»
                        if (!isset($this->«relationAliasName») || $this->«relationAliasName» == null) {
                            $urlArgs = array('ot' => '«otherEntity.name.formatForCode»',
                                             '«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»);
                            if ($currentFunc == 'view') {
                                $urlArgs['returnTo'] = '«controller.formattedName»View«name.formatForCodeCapital»';
                            } elseif ($currentFunc == 'display') {
                                $urlArgs['returnTo'] = '«controller.formattedName»Display«name.formatForCodeCapital»';
                            }
                            $this->_actions[] = array(
                                'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => $urlArgs),
                                'icon' => '«IF app.targets('1.3.5')»add«ELSE»plus«ENDIF»',
                                'linkTitle' => __('Create «otherEntity.name.formatForDisplay»', $dom),
                                'linkText' => __('Create «otherEntity.name.formatForDisplay»', $dom)
                            );
                        }
                    «ELSE»
                        $urlArgs = array('ot' => '«otherEntity.name.formatForCode»',
                                         '«relationAliasNameParam.formatForDB»' => «idFieldsAsParameterCode('this')»);
                        if ($currentFunc == 'view') {
                            $urlArgs['returnTo'] = '«controller.formattedName»View«name.formatForCodeCapital»';
                        } elseif ($currentFunc == 'display') {
                            $urlArgs['returnTo'] = '«controller.formattedName»Display«name.formatForCodeCapital»';
                        }
                        $this->_actions[] = array(
                            'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => $urlArgs),
                            'icon' => '«IF app.targets('1.3.5')»add«ELSE»plus«ENDIF»',
                            'linkTitle' => __('Create «otherEntity.name.formatForDisplay»', $dom),
                            'linkText' => __('Create «otherEntity.name.formatForDisplay»', $dom)
                        );
                    «ENDIF»
                «ENDFOR»
            }
        «ENDIF»
    '''

    def private createUrlArgs(Entity it) '''
        /**
         * Creates url arguments array for easy creation of display urls.
         *
         * @return Array The resulting arguments list.
         */
        public function createUrlArgs()
        {
            $args = array('ot' => $this['_objectType']);

            «IF hasCompositeKeys»
                «FOR pkField : getPrimaryKeyFields»
                    $args['«pkField.name.formatForCode»'] = $this['«pkField.name.formatForCode»'];
                «ENDFOR»
            «ELSE»
                $args['«getFirstPrimaryKey.name.formatForCode»'] = $this['«getFirstPrimaryKey.name.formatForCode»'];
            «ENDIF»

            if (isset($this['slug'])) {
                $args['slug'] = $this['slug'];
            }

            return $args;
        }
    '''

    def private createCompositeIdentifier(Entity it) '''
        /**
         * Create concatenated identifier string (for composite keys).
         *
         * @return String concatenated identifiers.
         */
        public function createCompositeIdentifier()
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
    '''

    def private getHookAreaPrefix(Entity it) '''
        /**
         * Return lower case name of multiple items needed for hook areas.
         *
         * @return string
         */
        public function getHookAreaPrefix()
        {
            return '«container.application.name.formatForDB».ui_hooks.«nameMultiple.formatForDB»';
        }
    '''

    def private tempIsAdminController(Controller it) {
        switch it {
            AdminController: true
            default: false
        }
    }

    def private itemActionsForEditAction(Entity it, Controller controller) '''
        «IF !readOnly»«/*create is allowed, but editing not*/»
            $this->_actions[] = array(
                'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false)»)),
                'icon' => '«IF container.application.targets('1.3.5')»edit«ELSE»pencil-square-o«ENDIF»',
                'linkTitle' => __('Edit', $dom),
                'linkText' => __('Edit', $dom)
            );
        «ENDIF»
        «IF tree == EntityTreeType::NONE»
                $this->_actions[] = array(
                    'url' => array('type' => '«controller.formattedName»', 'func' => 'edit', 'arguments' => array('ot' => '«name.formatForCode»'«modUrlPrimaryKeyParams('this', false, 'astemplate')»)),
                    'icon' => '«IF container.application.targets('1.3.5')»saveas«ELSE»files-o«ENDIF»',
                    'linkTitle' => __('Reuse for new item', $dom),
                    'linkText' => __('Reuse', $dom)
                );
        «ENDIF»
    '''

    def private loadWorkflow(Entity it) '''
        «val app = container.application»
        // apply workflow with most important information
        $idColumn = '«primaryKeyFields.head.name.formatForCode»';
        $workflowHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_Workflow«ELSE»WorkflowUtil«ENDIF»(ServiceUtil::getManager()«IF !app.targets('1.3.5')», ModUtil::getModule('«app.appName»')«ENDIF»);
        $schemaName = $workflowHelper->getWorkflowName($this['_objectType']);
        $this['__WORKFLOW__'] = array(
            'module' => '«app.appName»',
            'state' => $this['workflowState'],
            'obj_table' => $this['_objectType'],
            'obj_idcolumn' => $idColumn,
            'obj_id' => $this[$idColumn],
            'schemaname' => $schemaName);

        // load the real workflow only when required (e. g. when func is edit or delete)
        if ((!in_array($currentFunc, array('«IF app.targets('1.3.5')»main«ELSE»index«ENDIF»', 'view', 'display')) && empty($isReuse)) || $forceLoading) {
            $result = Zikula_Workflow_Util::getWorkflowForObject($this, $this['_objectType'], $idColumn, '«app.appName»');
            if (!$result) {
                $dom = ZLanguage::getModuleDomain('«app.appName»');
                «IF app.targets('1.3.5')»
                    LogUtil::registerError(__('Error! Could not load the associated workflow.', $dom));
                «ELSE»
                    $serviceManager = ServiceUtil::getManager();
                    $session = $serviceManager->get('session');
                    $session->getFlashBag()->add('error', __('Error! Could not load the associated workflow.', $dom));
                «ENDIF»
            }
        }

        if (!is_object($this['__WORKFLOW__']) && !isset($this['__WORKFLOW__']['schemaname'])) {
            $workflow = $this['__WORKFLOW__'];
            $workflow['schemaname'] = $schemaName;
            $this['__WORKFLOW__'] = $workflow;
        }
    '''

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
        «FOR mandatoryField : mandatoryFields.filter(IntegerField).filter[defaultValue === null || defaultValue == '' || defaultValue == '0']»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(UserField).filter[defaultValue === null || defaultValue == '' || defaultValue == '0']»
            $this->«mandatoryField.name.formatForCode» = UserUtil::getVar('uid');
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(DecimalField).filter[defaultValue === null || defaultValue == '' || defaultValue == '0']»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(AbstractDateField).filter[defaultValue === null || defaultValue == '' || defaultValue.length == 0]»
            $this->«mandatoryField.name.formatForCode» = «mandatoryField.defaultAssignment»;
        «ENDFOR»
        «FOR mandatoryField : mandatoryFields.filter(FloatField).filter[defaultValue === null || defaultValue == '' || defaultValue == '0']»
            $this->«mandatoryField.name.formatForCode» = 1;
        «ENDFOR»
        «IF !getListFieldsEntity.filter[name != 'workflowState' && (defaultValue === null || defaultValue.length == 0)].empty»

            $serviceManager = ServiceUtil::getManager();
            $listHelper = new «IF container.application.targets('1.3.5')»«container.application.appName»_Util_ListEntries«ELSE»\«container.application.appNamespace»\Util\ListEntriesUtil«ENDIF»($serviceManager«IF !container.application.targets('1.3.5')», ModUtil::getModule('«container.application.appName»')«ENDIF»);
            «FOR listField : getListFieldsEntity.filter[name != 'workflowState' && (defaultValue === null || defaultValue.length == 0)]»

                $items = array();
                $listEntries = $listHelper->get«listField.name.formatForCodeCapital»EntriesFor«name.formatForCodeCapital»();
                foreach ($listEntries as $listEntry) {
                    if ($listEntry['default'] === true) {
                        $items[] = $listEntry['value'];
                    }
                }
                $this->«listField.name.formatForCode» = implode('###', $items);
            «ENDFOR»

        «ENDIF»
        $this->workflowState = 'initial';
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
        «IF container.application.targets('1.3.5')»
            $this->initValidator();
        «ENDIF»
        $this->initWorkflow();
        «thAssoc.initCollections(it)»
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

    def private getTitleFromDisplayPattern(Entity it, Application app) '''
        /**
         * Returns the formatted title conforming to the display pattern
         * specified for this entity.
         */
        public function getTitleFromDisplayPattern()
        {
            «IF displayPattern === null || displayPattern == ''»
                «val leadingField = getLeadingField»
                «IF leadingField !== null»
                    $formattedTitle = $this->get«leadingField.name.formatForCodeCapital»();
                «ELSE»
                    $dom = ZLanguage::getModuleDomain('«app.appName»');
                    $formattedTitle = __('«name.formatForDisplayCapital»', $dom);
                «ENDIF»
            «ELSE»
                «IF hasListFieldsEntity»
                    $serviceManager = ServiceUtil::getManager();
                    $listHelper = new «IF app.targets('1.3.5')»«app.appName»_Util_ListEntries«ELSE»\«app.appNamespace»\Util\ListEntriesUtil«ENDIF»($serviceManager«IF !app.targets('1.3.5')», ModUtil::getModule('«app.appName»')«ENDIF»);

                «ENDIF»
                $formattedTitle = «parseDisplayPattern»;
            «ENDIF»

            return $formattedTitle;
        }
    '''

    def private parseDisplayPattern(Entity it) {
        var result = ''
        val patternParts = displayPattern.split('#')
        for (patternPart : patternParts) {
            if (result != '') {
                result = result.concat("\n" + '        . ')
            }

            var CharSequence formattedPart = ''
            // check if patternPart equals a field name
            var matchedFields = fields.filter[name == patternPart]
            if (!matchedFields.empty) {
                // field referencing part
                formattedPart = formatFieldValue(matchedFields.head, '$this->get' + patternPart.toFirstUpper + '()')
            } else if (geographical && (patternPart == 'latitude' || patternPart == 'longitude')) {
                // geo field referencing part
                formattedPart = 'number_format($this->get' + patternPart.toFirstUpper + '(), 7, \'.\', \'\')'
            } else {
                // static part
                formattedPart = '\'' + patternPart.replace('\'', '') + '\''
            }
            result = result.concat(formattedPart.toString)
        }
        result
    }

    def private formatFieldValue(EntityField it, CharSequence value) {
        switch it {
            DecimalField: '''DataUtil::format«IF currency»Currency(«value»)«ELSE»Number(«value», 2)«ENDIF»'''
            FloatField: '''DataUtil::format«IF currency»Currency(«value»)«ELSE»Number(«value», 2)«ENDIF»'''
            ListField: '''$listHelper->resolve(«value», '«entity.name.formatForCode»', '«name.formatForCode»')'''
            DateField: '''DateUtil::formatDatetime(«value», 'datebrief')'''
            DatetimeField: '''DateUtil::formatDatetime(«value», 'datetimebrief')'''
            TimeField: '''DateUtil::formatDatetime(«value», 'timebrief')'''
            default: value
        }
    }

    def private toStringImpl(Entity it, Application app) '''
        /**
         * ToString interceptor implementation.
         * This method is useful for debugging purposes.
         */
        public function __toString()
        {
            «IF hasCompositeKeys»
                $output = '';
                «FOR field : primaryKeyFields»
                    if (!empty($output)) {
                        $output .= "\n";
                    }
                    $output .= $this->get«field.name.formatForCodeCapital»();
                «ENDFOR»

                return $output;
            «ELSE»
                return $this->get«primaryKeyFields.head.name.formatForCodeCapital»();
            «ENDIF»
        }
    '''

    def private relatedObjectsImpl(Entity it, Application app) '''
        /**
         * Returns an array of all related objects that need to be persited after clone.
         * 
         * @param array $objects The objects are added to this array. Default: array()
         * 
         * @return array of entity objects.
         */
        public function getRelatedObjectsToPersist(&$objects = array()) {
            «val joinsIn = incomingJoinRelationsForCloning.filter[!(it instanceof ManyToManyRelationship)]»
            «val joinsOut = outgoingJoinRelationsForCloning.filter[!(it instanceof ManyToManyRelationship)]»
            «IF !joinsIn.empty || !joinsOut.empty»
                «FOR out : newArrayList(false, true)»
                    «FOR relation : if (out) joinsOut else joinsIn»
                        «var aliasName = relation.getRelationAliasName(out)»
                        foreach ($this->«aliasName» as $rel) {
                            if (!in_array($rel, $objects, true)) {
                                $objects[] = $rel;
                                $rel->getRelatedObjectsToPersist($objects);
                            }
                        }
                    «ENDFOR»
                «ENDFOR»

                return $objects;
             «ELSE»
                return array();
             «ENDIF»
         }
    '''

    def private cloneImpl(Entity it, Application app) '''
        «val joinsIn = incomingJoinRelationsForCloning»
        «val joinsOut = outgoingJoinRelationsForCloning»
        /**
         * Clone interceptor implementation.
         * This method is for example called by the reuse functionality.
         «IF joinsIn.empty && joinsOut.empty»
         * Performs a quite simple shallow copy.
         «ELSE»
         * Performs a deep copy.
         «ENDIF»
         *
         * See also:
         * (1) http://docs.doctrine-project.org/en/latest/cookbook/implementing-wakeup-or-clone.html
         * (2) http://www.php.net/manual/en/language.oop5.cloning.php
         * (3) http://stackoverflow.com/questions/185934/how-do-i-create-a-copy-of-an-object-in-php
         * (4) http://www.pantovic.com/article/26/doctrine2-entity-cloning
         */
        public function __clone()
        {
            // If the entity has an identity, proceed as normal.
            if («FOR field : primaryKeyFields SEPARATOR ' && '»$this->«field.name.formatForCode»«ENDFOR») {
                // unset identifiers
                «FOR field : primaryKeyFields»
                    $this->set«field.name.formatForCodeCapital»(«thProp.defaultFieldData(field)»);
                «ENDFOR»
                «IF app.targets('1.3.5')»

                    // init validator
                    $this->initValidator();
                «ENDIF»

                // reset Workflow
                $this->resetWorkflow();
                «IF hasUploadFieldsEntity»

                    // reset upload fields
                    «FOR field : getUploadFieldsEntity»
                        $this->set«field.name.formatForCodeCapital»('');
                        $this->set«field.name.formatForCodeCapital»Meta(array());
                    «ENDFOR»
                «ENDIF»
                «IF standardFields»

                    $this->setCreatedDate(null);
                    $this->setCreatedUserId(null);
                    $this->setUpdatedDate(null);
                    $this->setUpdatedUserId(null);
                «ENDIF»

                «IF !joinsIn.empty || !joinsOut.empty»
                    // handle related objects
                    // prevent shared references by doing a deep copy - see (2) and (3) for more information
                    // clone referenced objects only if a new record is necessary
                    «FOR out: newArrayList(false, true)»
                        «FOR relation : if (out) joinsOut else joinsIn»
                            «var aliasName = relation.getRelationAliasName(out)»
                            $collection = $this->«aliasName»;
                            $this->«aliasName» = new ArrayCollection();
                            foreach ($collection as $rel) {
                                $this->add«aliasName.formatForCodeCapital»(«IF !(relation instanceof ManyToManyRelationship)» clone«ENDIF» $rel);
                            }
                        «ENDFOR»
                    «ENDFOR»
                «ENDIF»
                «IF categorisable»

                    // clone categories
                    $categories = $this->categories;
                    $this->categories = new ArrayCollection();
                    foreach ($categories as $c) {
                        $newCat = clone $c;
                        $this->categories->add($newCat);
                        $newCat->setEntity($this);
                    }
                «ENDIF»
                «IF attributable»

                    // clone attributes
                    $attributes = $this->attributes;
                    $this->attributes = new ArrayCollection();
                    foreach ($attributes as $a) {
                        $newAttr = clone $a;
                        $this->attributes->add($newAttr);
                        $newAttr->setEntity($this);
                    }
                «ENDIF»
                «/* TODO consider other extensions here (meta data, translatable, loggable, maybe more) */»
            }
            // otherwise do nothing, do NOT throw an exception!
        }
    '''
}
