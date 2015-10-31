package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.EntityIndex
import de.guite.modulestudio.metamodel.EntityIndexItem
import de.guite.modulestudio.metamodel.InheritanceRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidatorLegacy
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Association
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityConstructor
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityMethods
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ExtensionManager
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Entities {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper
    Association thAssoc = new Association
    ExtensionManager extMan
    EventListener thEvLi = new EventListener
    Property thProp

    /**
     * Entry point for Doctrine entity classes.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        entities.forEach(e|e.generate(it, fsa))

        if (targets('1.3.x')) {
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
    def private generate(DataObject it, Application app, IFileSystemAccess fsa) {
        println('Generating entity classes for entity "' + name.formatForDisplay + '"')
        if (it instanceof Entity) {
            extMan = new ExtensionManager(it)
        }
        thProp = new Property(extMan)
        val entityPath = app.getAppSourceLibPath + 'Entity/'
        val entityClassSuffix = if (!app.targets('1.3.x')) 'Entity' else ''
        val entityFileName = name.formatForCodeCapital + entityClassSuffix
        var fileName = ''
        if (!isInheriting) {
            fileName = entityFileName + '.php'
            if (app.targets('1.3.x') && !app.shouldBeSkipped(entityPath + 'Base/' + fileName)) {
                if (app.shouldBeMarked(entityPath + 'Base/' + fileName)) {
                    fileName = entityFileName + '.generated.php'
                }
                fsa.generateFile(entityPath + 'Base/' + fileName, fh.phpFileContent(app, modelEntityBaseImpl(app)))
            } else if (!app.shouldBeSkipped(entityPath + 'Base/Abstract' + fileName)) {
                if (app.shouldBeMarked(entityPath + 'Base/Abstract' + fileName)) {
                    fileName = entityFileName + '.generated.php'
                }
                fsa.generateFile(entityPath + 'Base/Abstract' + fileName, fh.phpFileContent(app, modelEntityBaseImpl(app)))
            }
        }
        fileName = entityFileName + '.php'
        if (!app.generateOnlyBaseClasses && !app.shouldBeSkipped(entityPath + fileName)) {
            if (app.shouldBeMarked(entityPath + fileName)) {
                fileName = entityFileName + '.generated.php'
            }
            fsa.generateFile(entityPath + fileName, fh.phpFileContent(app, modelEntityImpl(app)))
        }
    }

    def private dispatch imports(MappedSuperClass it) '''
        use Doctrine\ORM\Mapping as ORM;
        «IF hasCollections»
            use Doctrine\Common\Collections\ArrayCollection;
        «ENDIF»
        use Gedmo\Mapping\Annotation as Gedmo;
        «IF !application.targets('1.3.x')»
            use Symfony\Component\Validator\Constraints as Assert;
            «IF !getListFieldsEntity.filter[multiple].empty»
                use Symfony\Component\Validator\Context\ExecutionContextInterface;
            «ENDIF»
            «IF !getUniqueDerivedFields.filter[!primaryKey].empty || !getIncomingJoinRelations.filter[unique].empty || !getOutgoingJoinRelations.filter[unique].empty»
                use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch imports(Entity it) '''
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
        «IF !application.targets('1.3.x')»
            use Symfony\Component\Validator\Constraints as Assert;
            «IF !getListFieldsEntity.filter[multiple].empty»
                use Symfony\Component\Validator\Context\ExecutionContextInterface;
            «ENDIF»
            «IF !getUniqueDerivedFields.filter[!primaryKey].empty || (hasSluggableFields && slugUnique) || !getIncomingJoinRelations.filter[unique].empty || !getOutgoingJoinRelations.filter[unique].empty || !getUniqueIndexes.empty»
                use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
            «ENDIF»
        «ENDIF»
    '''

    def private modelEntityBaseImpl(DataObject it, Application app) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity\Base;

            use «app.appNamespace»\«app.name.formatForCodeCapital»Events;
            use «app.appNamespace»\Event\Filter«name.formatForCodeCapital»Event;
        «ENDIF»
        «imports»
        «IF !app.targets('1.3.x')»

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

        «modelEntityBaseImplClass(app)»
    '''

    def private modelEntityBaseImplClass(DataObject it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the base entity class for «name.formatForDisplay» entities.
         * The following annotation marks it as a mapped superclass so subclasses
         * inherit orm properties.
         *
         * @ORM\MappedSuperclass
         *
         * @abstract
         */
        «IF app.targets('1.3.x')»
        abstract class «app.appName»_Entity_Base_«name.formatForCodeCapital» extends Zikula_EntityAccess«IF it instanceof Entity && (it as Entity).hasNotifyPolicy» implements NotifyPropertyChanged«ENDIF»
        «ELSE»
        abstract class Abstract«name.formatForCodeCapital»Entity extends Zikula_EntityAccess«IF it instanceof Entity && (it as Entity).hasNotifyPolicy» implements NotifyPropertyChanged«ENDIF»
        «ENDIF»
        {
            «modelEntityBaseImplBody(app)»
        }
    '''

    def private modelEntityBaseImplBody(DataObject it, Application app) '''
        «val validatorClassLegacy = if (app.targets('1.3.x')) app.appName + '_Entity_Validator_' + name.formatForCodeCapital else '\\' + app.vendor.formatForCodeCapital + '\\' + app.name.formatForCodeCapital + 'Module\\Entity\\Validator\\' + name.formatForCodeCapital + 'Validator'»
        «memberVars(validatorClassLegacy)»

        «IF it instanceof Entity»
            «new EntityConstructor().constructor(it, false)»

        «ENDIF»
        «accessors(validatorClassLegacy)»

        «IF it instanceof Entity»
            «thEvLi.generateBase(it)»

        «ENDIF»
        «new EntityMethods().generate(it, app, thProp)»
    '''

    def private memberVars(DataObject it, String validatorClassLegacy) '''
        /**
         * @var string The tablename this object maps to.
         */
        protected $_objectType = '«name.formatForCode»';
        «IF application.targets('1.3.x')»

            /**
             * @var «validatorClassLegacy» The validator for this entity.
             */
            protected $_validator = null;
        «ENDIF»

        /**
         «IF !application.targets('1.3.x')»
         * @Assert\Type(type="bool")
         «ENDIF»
         * @var boolean Option to bypass validation if needed.
         */
        protected $_bypassValidation = false;
        «IF it instanceof Entity && (it as Entity).hasNotifyPolicy»

            /**
             «IF !application.targets('1.3.x')»
             * @Assert\Type(type="array")
             «ENDIF»
             * @var array List of change notification listeners.
             */
            protected $_propertyChangedListeners = array();
        «ENDIF»

        /**
         «IF !application.targets('1.3.x')»
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

    def private accessors(DataObject it, String validatorClassLegacy) '''
        «fh.getterAndSetterMethods(it, '_objectType', 'string', false, false, '', '')»
        «IF application.targets('1.3.x')»
            «fh.getterAndSetterMethods(it, '_validator', validatorClassLegacy, false, true, 'null', '')»
        «ENDIF»
        «fh.getterAndSetterMethods(it, '_bypassValidation', 'boolean', false, false, '', '')»
        «fh.getterAndSetterMethods(it, '_actions', 'array', false, true, 'Array()', '')»
        «fh.getterAndSetterMethods(it, '__WORKFLOW__', 'array', false, true, 'Array()', '')»

        «FOR field : getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
        «extMan.additionalAccessors»

        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.relationAccessor(relation, true)»«ENDFOR»
    '''

    def private modelEntityImpl(DataObject it, Application app) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity;

            use «app.appNamespace»\Entity\«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»Entity«ENDIF» as Base«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»Entity«ENDIF»;

        «ENDIF»
        «imports»

        «entityImplClassDocblock(app)»
        «IF app.targets('1.3.x')»
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
                «IF it instanceof Entity»
                    «new EntityConstructor().constructor(it, true)»

                «ENDIF»
                «FOR field : getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
                «extMan.additionalAccessors»

                «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
                «FOR relation : getOutgoingJoinRelations»«thAssoc.relationAccessor(relation, true)»«ENDFOR»
            «ENDIF»
            «IF it instanceof Entity»

                «thEvLi.generateImpl(it)»
            «ENDIF»
        }
    '''

    def private entityImplClassDocblock(DataObject it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the concrete entity class for «name.formatForDisplay» entities.
         «extMan.classAnnotations»
         «IF it instanceof MappedSuperClass»
          * @ORM\MappedSuperclass
         «ELSEIF it instanceof Entity»
          * @ORM\Entity(repositoryClass="«IF app.targets('1.3.x')»«app.appName»_Entity_Repository_«name.formatForCodeCapital»«ELSE»\«app.appNamespace»\Entity\Repository\«name.formatForCodeCapital»«ENDIF»"«IF (it as Entity).readOnly», readOnly=true«ENDIF»)
         «ENDIF»
        «IF it instanceof Entity»
            «entityImplClassDocblockAdditions(app)»
        «ENDIF»
        «IF !app.targets('1.3.x')»
            «new ValidationConstraints().classAnnotations(it)»
        «ENDIF»
         */
    '''

    def private entityImplClassDocblockAdditions(Entity it, Application app) '''
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
    '''

    def private index(EntityIndex it, String indexType) '''
         *         @ORM\«indexType.toFirstUpper»(name="«name.formatForDB»", columns={«FOR item : items SEPARATOR ','»«item.indexField»«ENDFOR»})
    '''
    def private indexField(EntityIndexItem it) '''"«name.formatForCode»"'''

    def private discriminatorInfo(InheritanceRelationship it) '''
        , "«source.name.formatForCode»" = "«source.entityClassName('', false)»"
    '''
}
