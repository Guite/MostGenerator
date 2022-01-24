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
import org.zikula.modulestudio.generator.extensions.EntityIndexExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Entities {

    extension EntityIndexExtensions = new EntityIndexExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
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

        fileName = 'Abstract' + entityFileName + '.php'
        fsa.generateFile(entityPath + 'Base/' + fileName, modelEntityBaseImpl(app))

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
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
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
            «IF !isInheriting»
                use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
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
            «IF isInheriting»
                use «application.appNamespace»\Entity\«parentType.name.formatForCodeCapital»Entity as BaseEntity;
            «ENDIF»
            «IF attributable»
                use «application.appNamespace»\Entity\«name.formatForCodeCapital»AttributeEntity;
            «ENDIF»
            «IF categorisable»
                use «application.appNamespace»\Entity\«name.formatForCodeCapital»CategoryEntity;
            «ENDIF»
            «IF tree !== EntityTreeType.NONE»
                «IF tree === EntityTreeType.CLOSURE»
                    use «application.appNamespace»\Entity\«name.formatForCodeCapital»ClosureEntity;
                «ENDIF»
                use «application.appNamespace»\Entity\«name.formatForCodeCapital»Entity;
            «ENDIF»
            «IF loggable»
                use «application.appNamespace»\Entity\«name.formatForCodeCapital»LogEntryEntity;
            «ENDIF»
            «IF hasTranslatableFields»
                use «application.appNamespace»\Entity\«name.formatForCodeCapital»TranslationEntity;
            «ENDIF»
            use «application.appNamespace»\Entity\Repository\«name.formatForCodeCapital»Repository;
            «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.importRelatedEntity(relation, false)»«ENDFOR»
            «FOR relation : getOutgoingJoinRelations»«thAssoc.importRelatedEntity(relation, true)»«ENDFOR»
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
        abstract class Abstract«name.formatForCodeCapital»Entity extends «IF isInheriting»BaseEntity«ELSE»EntityAccess«ENDIF»«IF it instanceof Entity && ((it as Entity).hasNotifyPolicy || (it as Entity).hasTranslatableFields)» implements«IF (it as Entity).hasNotifyPolicy» NotifyPropertyChanged«ENDIF»«IF (it as Entity).hasTranslatableFields»«IF (it as Entity).hasNotifyPolicy»,«ENDIF» Translatable«ENDIF»«ENDIF»
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
        «new EntityConstructor().constructor(it, false)»
        «accessors»
        «new EntityMethods().generate(it, app, thProp)»
    '''

    def private memberVars(DataObject it) '''
        /**
         * The tablename this object maps to
         */
        protected string $_objectType = '«name.formatForCode»';
        «IF it instanceof Entity && (it as Entity).hasNotifyPolicy»

            /**
             * List of change notification listeners
             */
            protected array $_propertyChangedListeners = [];
        «ENDIF»
        «IF hasUploadFieldsEntity»

            /**
             * Relative path to upload base folder
             */
            protected string $_uploadBasePathRelative = '';

            /**
             * Absolute path to upload base folder
             */
            protected string $_uploadBasePathAbsolute = '';

            /**
             * Base URL to upload files
             */
            protected string $_uploadBaseUrl = '';
        «ENDIF»

        «FOR field : getDerivedFields»«thProp.persistentProperty(field)»«ENDFOR»
        «extMan.additionalProperties»
        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.generate(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.generate(relation, true)»«ENDFOR»
        «IF it instanceof Entity && (it as Entity).loggable && (it as Entity).hasTranslatableFields && getDerivedFields.filter(ArrayField).filter[name.equals('translationData')].empty»
            /**
             * Log data for refreshing translations during revert to another revision
             */
            protected array $translationData = [];

        «ENDIF»
    '''

    def private accessors(DataObject it) '''
        «fh.getterAndSetterMethods(it, '_objectType', 'string', false, '', '')»
        «IF hasUploadFieldsEntity»
            «fh.getterAndSetterMethods(it, '_uploadBasePathRelative', 'string', false, '', '')»
            «fh.getterAndSetterMethods(it, '_uploadBasePathAbsolute', 'string', false, '', '')»
            «fh.getterAndSetterMethods(it, '_uploadBaseUrl', 'string', false, '', '')»
        «ENDIF»
        «FOR field : getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
        «extMan.additionalAccessors»
        «FOR relation : getBidirectionalIncomingJoinRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
        «FOR relation : getOutgoingJoinRelations»«thAssoc.relationAccessor(relation, true)»«ENDFOR»
        «IF it instanceof Entity && (it as Entity).loggable && (it as Entity).hasTranslatableFields && getDerivedFields.filter(ArrayField).filter[name.equals('translationData')].empty»
            «fh.getterAndSetterMethods(it, 'translationData', 'array', true, '[]', '')»
        «ENDIF»
    '''

    def private modelEntityImpl(DataObject it, Application app) '''
        namespace «app.appNamespace»\Entity;

        use «app.appNamespace»\Entity\Base\Abstract«name.formatForCodeCapital»Entity as BaseEntity;
        «imports(false)»

        «entityImplClassDocblock(app)»
        class «name.formatForCodeCapital»Entity extends BaseEntity
        {
            // feel free to add your own methods here
        }
    '''

    def private entityImplClassDocblock(DataObject it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the concrete entity class for «name.formatForDisplay» entities.
         *
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
        «' '»* @ORM\MappedSuperclass«/*IF isTopSuperClass»
        «' '»* @ORM\InheritanceType("«getChildRelations.head.strategy.literal»")
        «' '»* @ORM\DiscriminatorColumn(name="«getChildRelations.head.discriminatorColumn.formatForCode»"«/*, type="string"* /»)
        «' '»* @ORM\DiscriminatorMap({«FOR relation : getChildRelations SEPARATOR ', '»«relation.discriminatorInfo»«ENDFOR»})
        «ENDIF*/»
    '''

    def dispatch private classAnnotation(Entity it) '''
        «' '»* @ORM\Entity(repositoryClass="«name.formatForCodeCapital»Repository::class"«IF readOnly», readOnly=true«ENDIF»)
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
         «' '»* @ORM\DiscriminatorMap({"«name.formatForCode»" = "«name.formatForCodeCapital»Entity::class"«FOR relation : getChildRelations», «relation.discriminatorInfo»«ENDFOR»})
         «ENDIF»
         «IF changeTrackingPolicy != EntityChangeTrackingPolicy::DEFERRED_IMPLICIT»
         «' '»* @ORM\ChangeTrackingPolicy("«changeTrackingPolicy.literal»")
         «ENDIF»
    '''

    def private index(EntityIndex it, String indexType) '''
         «' '»*         @ORM\«indexType.toFirstUpper»(name="«name.formatForDB»", columns={«FOR item : items SEPARATOR ','»«item.indexField»«ENDFOR»})
    '''
    def private indexField(EntityIndexItem it) '''"«indexItemForEntity»"'''

    def private discriminatorInfo(InheritanceRelationship it) '''
        "«source.name.formatForCode»" = "«source.name.formatForCodeCapital»Entity::class"
    '''
}
