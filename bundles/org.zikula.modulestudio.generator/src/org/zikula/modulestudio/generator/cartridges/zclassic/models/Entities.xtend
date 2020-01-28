package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.EntityIndex
import de.guite.modulestudio.metamodel.EntityIndexItem
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.InheritanceRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Association
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityConstructor
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.EntityMethods
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ExtensionManager
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.GeographicalTrait
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions.StandardFieldsTrait
import org.zikula.modulestudio.generator.cartridges.zclassic.models.event.LifecycleListener
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Entities {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh
    Association thAssoc = new Association
    ExtensionManager extMan
    Property thProp

    /**
     * Entry point for Doctrine entity classes.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fh = new FileHelper(it)
        entities.forEach(e|e.generate(it, fsa))

        new LifecycleListener().generate(it, fsa)
        if (hasGeographical) {
            if (!getGeographicalEntities.filter[loggable].empty) {
                new GeographicalTrait().generate(it, fsa, true)
            }
            if (!getGeographicalEntities.filter[!loggable].empty) {
                new GeographicalTrait().generate(it, fsa, false)
            }
        }
        if (hasStandardFieldEntities) {
            if (!getStandardFieldEntities.filter[loggable].empty) {
                new StandardFieldsTrait().generate(it, fsa, true)
            }
            if (!getStandardFieldEntities.filter[!loggable].empty) {
                new StandardFieldsTrait().generate(it, fsa, false)
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
    def private generate(DataObject it, Application app, IMostFileSystemAccess fsa) {
        ('Generating entity classes for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        if (it instanceof Entity) {
            extMan = new ExtensionManager(it)
        }
        thProp = new Property(app, extMan)
        val entityPath = 'Entity/'
        val entityClassSuffix = 'Entity'
        val entityFileName = name.formatForCodeCapital + entityClassSuffix
        var fileName = ''
        if (!isInheriting) {
            fileName = 'Abstract' + entityFileName + '.php'
            fsa.generateFile(entityPath + 'Base/' + fileName, modelEntityBaseImpl(app))
        }
        if (!app.generateOnlyBaseClasses) {
            fileName = entityFileName + '.php'
            fsa.generateFile(entityPath + fileName, modelEntityImpl(app))
        }
    }

    def private dispatch imports(MappedSuperClass it, Boolean isBase) '''
        use Doctrine\ORM\Mapping as ORM;
        «IF isBase && hasCollections»
            use Doctrine\Common\Collections\ArrayCollection;
        «ENDIF»
        «IF isBase/* || loggable || hasTranslatableFields || tree != EntityTreeType.NONE*/»
            use Gedmo\Mapping\Annotation as Gedmo;
        «ENDIF»
        «IF isBase»
            «IF hasCollections»
                use InvalidArgumentException;
            «ENDIF»
            «IF hasUploadFieldsEntity»
                use RuntimeException;
                use Symfony\Component\HttpFoundation\File\File;
            «ENDIF»
            use Symfony\Component\Validator\Constraints as Assert;
        «ENDIF»
        «IF !getUniqueDerivedFields.filter[!primaryKey].empty || !getIncomingJoinRelations.filter[unique].empty || !getOutgoingJoinRelations.filter[unique].empty»
            use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
        «ENDIF»
        «IF isBase»
            «IF hasUserFieldsEntity»
                use Zikula\UsersModule\Entity\UserEntity;
            «ENDIF»
            «IF hasListFieldsEntity»
                use «application.appNamespace»\Validator\Constraints as «application.name.formatForCodeCapital»Assert;
            «ENDIF»
        «ENDIF»
    '''

    def private dispatch imports(Entity it, Boolean isBase) '''
        use Doctrine\ORM\Mapping as ORM;
        «IF isBase»
            «IF hasCollections || attributable || categorisable»
                use Doctrine\Common\Collections\ArrayCollection;
            «ENDIF»
            «IF attributable || categorisable || EntityTreeType.NONE != tree»
                use Doctrine\Common\Collections\Collection;
            «ENDIF»
        «ENDIF»
        «IF isBase && hasNotifyPolicy»
            use Doctrine\Common\NotifyPropertyChanged;
            use Doctrine\Common\PropertyChangedListener;
        «ENDIF»
        «IF isBase || loggable || hasTranslatableFields || tree != EntityTreeType.NONE»
            use Gedmo\Mapping\Annotation as Gedmo;
        «ENDIF»
        «IF isBase»
            «IF hasTranslatableFields»
                use Gedmo\Translatable\Translatable;
            «ENDIF»
            «IF hasUploadFieldsEntity»
                «IF loggable»
                    use ReflectionClass;
                «ENDIF»
                use RuntimeException;
                use Symfony\Component\HttpFoundation\File\File;
            «ENDIF»
            use Symfony\Component\Validator\Constraints as Assert;
        «ENDIF»
        «IF !getUniqueDerivedFields.filter[!primaryKey].empty || (hasSluggableFields && slugUnique) || !getIncomingJoinRelations.filter[unique].empty || !getOutgoingJoinRelations.filter[unique].empty || !getUniqueIndexes.empty»
            use Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity;
        «ENDIF»
        «IF isBase»
            «IF application.targets('3.0')»
                use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            «ELSE»
                use Zikula\Core\Doctrine\EntityAccess;
            «ENDIF»
            «IF hasUserFieldsEntity»
                use Zikula\UsersModule\Entity\UserEntity;
            «ENDIF»
            «IF geographical»
                use «application.appNamespace»\Traits\«IF loggable»Loggable«ENDIF»GeographicalTrait;
            «ENDIF»
            «IF standardFields»
                use «application.appNamespace»\Traits\«IF loggable»Loggable«ENDIF»StandardFieldsTrait;
            «ENDIF»
            «IF hasListFieldsEntity»
                use «application.appNamespace»\Validator\Constraints as «application.name.formatForCodeCapital»Assert;
            «ENDIF»
        «ENDIF»
    '''

    def private modelEntityBaseImpl(DataObject it, Application app) '''
        namespace «app.appNamespace»\Entity\Base;

        «imports(true)»

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
         */
        abstract class Abstract«name.formatForCodeCapital»Entity extends EntityAccess«IF it instanceof Entity && ((it as Entity).hasNotifyPolicy || (it as Entity).hasTranslatableFields)» implements«IF (it as Entity).hasNotifyPolicy» NotifyPropertyChanged«ENDIF»«IF (it as Entity).hasTranslatableFields»«IF (it as Entity).hasNotifyPolicy»,«ENDIF» Translatable«ENDIF»«ENDIF»
        {
            «IF it instanceof Entity && (it as Entity).geographical»
                /**
                 * Hook geographical behaviour embedding latitude and longitude fields.
                 */
                use «IF (it as Entity).loggable»Loggable«ENDIF»GeographicalTrait;

            «ENDIF»
            «IF it instanceof Entity && (it as Entity).standardFields»
                /**
                 * Hook standard fields behaviour embedding createdBy, updatedBy, createdDate, updatedDate fields.
                 */
                use «IF (it as Entity).loggable»Loggable«ENDIF»StandardFieldsTrait;

            «ENDIF»
            «modelEntityBaseImplBody(app)»
        }
    '''

    def private modelEntityBaseImplBody(DataObject it, Application app) '''
        «memberVars»
        «IF it instanceof Entity»

            «new EntityConstructor().constructor(it, false)»
        «ENDIF»
        «accessors»
        «new EntityMethods().generate(it, app, thProp)»
    '''

    def private memberVars(DataObject it) '''
        /**
         * @var string The tablename this object maps to
         */
        protected $_objectType = '«name.formatForCode»';
        «IF it instanceof Entity && (it as Entity).hasNotifyPolicy»

            /**
             * @Assert\Type(type="array")
             * @var array List of change notification listeners
             */
            protected $_propertyChangedListeners = [];
        «ENDIF»
        «IF hasUploadFieldsEntity»

            «IF application.targets('3.0')»
                /**
                 * @var string Relative path to upload base folder
                 */
                protected $_uploadBasePathRelative = '';

                /**
                 * @var string Absolute path to upload base folder
                 */
                protected $_uploadBasePathAbsolute = '';
            «ELSE»
                /**
                 * @var string Path to upload base folder
                 */
                protected $_uploadBasePath = '';
            «ENDIF»

            /**
             * @var string Base URL to upload files
             */
            protected $_uploadBaseUrl = '';
        «ENDIF»

        «FOR field : getDerivedFields»«thProp.persistentProperty(field)»«ENDFOR»
        «extMan.additionalProperties»

        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.generate(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.generate(relation, true)»«ENDFOR»
        «IF it instanceof Entity && (it as Entity).loggable && (it as Entity).hasTranslatableFields && getDerivedFields.filter(ArrayField).filter[name.equals('translationData')].empty»
            /**
             * @Assert\Type(type="array")
             * @var array Log data for refreshing translations during revert to another revision
             */
            protected $translationData = [];
        «ENDIF»
    '''

    def private accessors(DataObject it) '''
        «fh.getterAndSetterMethods(it, '_objectType', 'string', false, false, application.targets('3.0'), '', '')»
        «IF hasUploadFieldsEntity»
            «IF application.targets('3.0')»
                «fh.getterAndSetterMethods(it, '_uploadBasePathRelative', 'string', false, false, application.targets('3.0'), '', '')»
                «fh.getterAndSetterMethods(it, '_uploadBasePathAbsolute', 'string', false, false, application.targets('3.0'), '', '')»
            «ELSE»
                «fh.getterAndSetterMethods(it, '_uploadBasePath', 'string', false, false, application.targets('3.0'), '', '')»
            «ENDIF»
            «fh.getterAndSetterMethods(it, '_uploadBaseUrl', 'string', false, false, application.targets('3.0'), '', '')»
        «ENDIF»
        «FOR field : getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
        «extMan.additionalAccessors»
        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.relationAccessor(relation, true)»«ENDFOR»
        «IF it instanceof Entity && (it as Entity).loggable && (it as Entity).hasTranslatableFields && getDerivedFields.filter(ArrayField).filter[name.equals('translationData')].empty»
            «fh.getterAndSetterMethods(it, 'translationData', 'array', true, true, true, '[]', '')»
        «ENDIF»
    '''

    def private modelEntityImpl(DataObject it, Application app) '''
        namespace «app.appNamespace»\Entity;

        use «app.appNamespace»\Entity\«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»«ENDIF»Entity as BaseEntity;
        «imports(isInheriting)»

        «entityImplClassDocblock(app)»
        class «name.formatForCodeCapital»Entity extends BaseEntity
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
        }
    '''

    def private entityImplClassDocblock(DataObject it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the concrete entity class for «name.formatForDisplay» entities.
         «extMan.classAnnotations»
        «classAnnotation»
        «IF it instanceof Entity»
            «entityImplClassDocblockAdditions(app)»
        «ENDIF»
        «new ValidationConstraints().classAnnotations(it)»
         */
    '''

    def dispatch private classAnnotation(DataObject it) '''
    '''

    def dispatch private classAnnotation(MappedSuperClass it) '''
        «' '»* @ORM\MappedSuperclass
        «IF isTopSuperClass»
        «' '»* @ORM\InheritanceType("«getChildRelations.head.strategy.literal»")
        «' '»* @ORM\DiscriminatorColumn(name="«getChildRelations.head.discriminatorColumn.formatForCode»"«/*, type="string"*/»)
        «' '»* @ORM\DiscriminatorMap({«FOR relation : getChildRelations SEPARATOR ', '»«relation.discriminatorInfo»«ENDFOR»})
        «ENDIF»
    '''

    def dispatch private classAnnotation(Entity it) '''
        «' '»* @ORM\Entity(repositoryClass="«application.appNamespace»\Entity\Repository\«name.formatForCodeCapital»Repository"«IF readOnly», readOnly=true«ENDIF»)
    '''

    def private entityImplClassDocblockAdditions(Entity it, Application app) '''
         «IF indexes.empty»
         «' '»* @ORM\Table(name="«fullEntityTableName»")
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
         «' '»* @ORM\InheritanceType("«getChildRelations.head.strategy.literal»")
         «' '»* @ORM\DiscriminatorColumn(name="«getChildRelations.head.discriminatorColumn.formatForCode»"«/*, type="string"*/»)
         «' '»* @ORM\DiscriminatorMap({"«name.formatForCode»" = "«entityClassName('', false)»"«FOR relation : getChildRelations», «relation.discriminatorInfo»«ENDFOR»})
         «ENDIF»
         «IF changeTrackingPolicy != EntityChangeTrackingPolicy::DEFERRED_IMPLICIT»
         «' '»* @ORM\ChangeTrackingPolicy("«changeTrackingPolicy.literal»")
         «ENDIF»
    '''

    def private index(EntityIndex it, String indexType) '''
         «' '»*         @ORM\«indexType.toFirstUpper»(name="«name.formatForDB»", columns={«FOR item : items SEPARATOR ','»«item.indexField»«ENDFOR»})
    '''
    def private indexField(EntityIndexItem it) '''"«name.formatForCode»"'''

    def private discriminatorInfo(InheritanceRelationship it) '''
        "«source.name.formatForCode»" = "«source.entityClassName('', false)»"
    '''
}
