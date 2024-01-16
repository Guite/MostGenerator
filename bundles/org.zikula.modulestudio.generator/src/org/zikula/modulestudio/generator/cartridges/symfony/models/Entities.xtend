package org.zikula.modulestudio.generator.cartridges.symfony.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.DataObject
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityChangeTrackingPolicy
import de.guite.modulestudio.metamodel.EntityIndex
import de.guite.modulestudio.metamodel.EntityIndexItem
import de.guite.modulestudio.metamodel.EntityIndexType
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.InheritanceRelationship
import de.guite.modulestudio.metamodel.MappedSuperClass
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.symfony.models.business.ValidationConstraints
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.Association
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.EntityConstructor
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.EntityMethods
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.ExtensionManager
import org.zikula.modulestudio.generator.cartridges.symfony.models.entity.Property
import org.zikula.modulestudio.generator.cartridges.symfony.models.event.LifecycleListener
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
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
        fsa.generateClassPair('Entity/EntityInterface.php', entityInterfaceBaseImpl, entityInterfaceImpl)
        entities.forEach(e|e.generate(it, fsa))

        new LifecycleListener().generate(it, fsa)

        for (entity : getAllEntities) {
            extMan = new ExtensionManager(entity)
            extMan.extensionClasses(fsa)
        }
    }

    def private entityInterfaceBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Base;

        /**
         * Entity interface for the «name.formatForDisplay» application.
         */
        interface AbstractEntityInterface
        {
            // nothing
        }
    '''

    def private entityInterfaceImpl(Application it) '''
        namespace «appNamespace»\Entity;

        use «appNamespace»\Entity\Base\AbstractEntityInterface;

        /**
         * Entity interface for the «name.formatForDisplay» application.
         */
        interface EntityInterface extends AbstractEntityInterface
        {
            // feel free to add your own interface methods
        }
    '''

    /**
     * Creates an entity class file for every Entity instance.
     */
    def private generate(DataObject it, Application app, IMostFileSystemAccess fsa) {
        ('Generating entity classes for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        if (it instanceof Entity) {
            extMan = new ExtensionManager(it)
        }
        thProp = new Property(app, extMan)
        thAssoc.resetImports
        fsa.generateClassPair('Entity/' + name.formatForCodeCapital + '.php', modelEntityBaseImpl(app), modelEntityImpl(app))
    }

    def private dispatch collectBaseImports(MappedSuperClass it, Boolean isBase) {
        val imports = new ImportList
        imports.add('Doctrine\\ORM\\Mapping as ORM')
        if (isBase && hasCollections) {
            imports.add('Doctrine\\Common\\Collections\\ArrayCollection')
        }
        if (isBase/* || loggable || hasTranslatableFields || tree != EntityTreeType.NONE*/) {
            imports.add('Gedmo\\Mapping\\Annotation as Gedmo')
        }
        if (isBase) {
            if (hasCollections) {
                imports.add('InvalidArgumentException')
            }
            if (hasUploadFieldsEntity) {
                imports.add('RuntimeException')
                imports.add('Symfony\\Component\\HttpFoundation\\File\\File')
            }
            imports.add('Symfony\\Component\\Validator\\Constraints as Assert')
        }
        if (!getUniqueDerivedFields.filter[!primaryKey].empty || !getIncomingJoinRelations.filter[unique].empty || !getOutgoingJoinRelations.filter[unique].empty) {
            imports.add('Symfony\\Bridge\\Doctrine\\Validator\\Constraints\\UniqueEntity')
        }
        if (isBase) {
            if (hasUserFieldsEntity) {
                imports.add('Zikula\\UsersBundle\\Entity\\User')
            }
            imports.add(application.appNamespace + '\\Entity\\EntityInterface')
            if (hasListFieldsEntity) {
                imports.add(application.appNamespace + '\\Validator\\Constraints as ' + application.name.formatForCodeCapital + 'Assert')
            }
        } else {
            imports.add(application.appNamespace + '\\Entity\\Base\\Abstract' + name.formatForCodeCapital + ' as BaseEntity')
        }
        imports
    }

    def private dispatch collectBaseImports(Entity it, Boolean isBase) {
        val imports = new ImportList
        imports.add('Doctrine\\DBAL\\Types\\Types')
        imports.add('Doctrine\\ORM\\Mapping as ORM')
        if (isBase) {
            if (hasCollections || categorisable || EntityTreeType.NONE != tree) {
                imports.add('Doctrine\\Common\\Collections\\ArrayCollection')
                imports.add('Doctrine\\Common\\Collections\\Collection')
            }
        }
        if (isBase || loggable || hasTranslatableFields || tree != EntityTreeType.NONE) {
            imports.add('Gedmo\\Mapping\\Annotation as Gedmo')
        }
        if (hasSluggableFields) {
            if (tree != EntityTreeType.NONE) {
                imports.add('Gedmo\\Sluggable\\Handler\\TreeSlugHandler')
            } else if (needsRelativeOrInversedRelativeSlugHandler) {
                imports.add('Gedmo\\Sluggable\\Handler\\InversedRelativeSlugHandler')
                imports.add('Gedmo\\Sluggable\\Handler\\RelativeSlugHandler')
            }
        }
        if (isBase) {
            if (hasTranslatableFields) {
                imports.add('Gedmo\\Translatable\\Translatable')
            }
            if (hasUploadFieldsEntity) {
                if (loggable) {
                    imports.add('ReflectionClass')
                }
                imports.add('RuntimeException')
                imports.add('Symfony\\Component\\HttpFoundation\\File\\File')
            }
            imports.add('Symfony\\Component\\Validator\\Constraints as Assert')
        }
        if (!getUniqueDerivedFields.filter[!primaryKey].empty || (hasSluggableFields && slugUnique) || !getIncomingJoinRelations.filter[unique].empty || !getOutgoingJoinRelations.filter[unique].empty || !getUniqueIndexes.empty) {
            imports.add('Symfony\\Bridge\\Doctrine\\Validator\\Constraints\\UniqueEntity')
        }
        if (!isBase) {
            if (tree === EntityTreeType.CLOSURE) {
                imports.add(application.appNamespace + '\\Entity\\' + name.formatForCodeCapital + 'Closure')
            }
            if (loggable) {
                imports.add(application.appNamespace + '\\Entity\\' + name.formatForCodeCapital + 'LogEntry')
            }
            if (hasTranslatableFields) {
                imports.add(application.appNamespace + '\\Entity\\' + name.formatForCodeCapital + 'Translation')
            }
            imports.add(application.appNamespace + '\\Repository\\' + name.formatForCodeCapital + 'Repository')
        } else {
            if (hasUserFieldsEntity) {
                imports.add('Zikula\\UsersBundle\\Entity\\User')
            }
            if (!isInheriting) {
                imports.add(application.appNamespace + '\\Entity\\EntityInterface')
            } else {
                imports.add(application.appNamespace + '\\Entity\\' + parentType.name.formatForCodeCapital + ' as BaseEntity')
            }
            if (categorisable) {
                imports.add(application.appNamespace + '\\Entity\\' + name.formatForCodeCapital + 'Category')
            }
            if (tree !== EntityTreeType.NONE) {
                imports.add(application.appNamespace + '\\Entity\\' + name.formatForCodeCapital)
            }
            for (relation : getBidirectionalIncomingJoinRelations) {
                imports.addAll(thAssoc.importRelatedEntity(relation, false))
            }
            for (relation : getOutgoingJoinRelations) {
                imports.addAll(thAssoc.importRelatedEntity(relation, true))
            }
            imports.add(application.appNamespace + '\\Repository\\' + name.formatForCodeCapital + 'Repository')
            if (hasListFieldsEntity) {
                imports.add(application.appNamespace + '\\Validator\\Constraints as ' + application.name.formatForCodeCapital + 'Assert')
            }
        }
        if (!isBase) {
            imports.add(application.appNamespace + '\\Entity\\Base\\Abstract' + name.formatForCodeCapital + ' as BaseEntity')
        }
        imports
    }

    def private modelEntityBaseImpl(DataObject it, Application app) '''
        namespace «app.appNamespace»\Entity\Base;

        «collectBaseImports(true).print»

        «modelEntityBaseImplClass(app)»
    '''

    def private modelEntityBaseImplClass(DataObject it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the base entity class for «name.formatForDisplay» entities.
         * The following annotation marks it as a mapped superclass so subclasses
         * inherit orm properties.
         */
        #[ORM\MappedSuperclass]
        abstract class Abstract«name.formatForCodeCapital»«IF isInheriting» extends BaseEntity«ENDIF» implements AbstractEntityInterface«IF it instanceof Entity»«IF it.hasTranslatableFields», Translatable«ENDIF»«ENDIF»
        {
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

        «collectBaseImports(false).print»

        «entityImplClassDocblock(app)»
        class «name.formatForCodeCapital» extends BaseEntity implements EntityInterface
        {
            // feel free to add your own methods here
        }
    '''

    def private entityImplClassDocblock(DataObject it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the concrete entity class for «name.formatForDisplay» entities.
         */
        «extMan.classAnnotations»
        «classAnnotation»
        «IF it instanceof Entity»
            «entityImplClassAdditionalAttributes(app)»
        «ENDIF»
        «new ValidationConstraints().classAnnotations(it)»
    '''

    def dispatch private classAnnotation(DataObject it) '''
    '''

    def dispatch private classAnnotation(MappedSuperClass it) '''
        #[ORM\MappedSuperclass]«/*IF isTopSuperClass»
        #[ORM\InheritanceType('«getChildRelations.head.strategy.literal»')]
        #[ORM\DiscriminatorColumn(name: '«getChildRelations.head.discriminatorColumn.formatForCode»'«/*, type: 'string'* /»)]
        #[ORM\DiscriminatorMap([«FOR relation : getChildRelations SEPARATOR ', '»«relation.discriminatorInfo»«ENDFOR»])]
        «ENDIF*/»
    '''

    def dispatch private classAnnotation(Entity it) '''
        #[ORM\Entity(repositoryClass: «name.formatForCodeCapital»Repository::class«IF readOnly», readOnly: true«ENDIF»)]
    '''

    def private entityImplClassAdditionalAttributes(Entity it, Application app) '''
        #[ORM\Table(name: '«fullEntityTableName»')]
        «IF !indexes.empty»
        «IF hasNormalIndexes»
            «FOR index : getNormalIndexes»
                «index.index('Index')»
            «ENDFOR»
        «ENDIF»
        «IF hasUniqueIndexes»
            «FOR index : getUniqueIndexes»
                «index.index('UniqueConstraint')»
            «ENDFOR»
        «ENDIF»
        «ENDIF»
        «IF isTopSuperClass»
            #[ORM\InheritanceType('«getChildRelations.head.strategy.literal»')]
            #[ORM\DiscriminatorColumn(name: '«getChildRelations.head.discriminatorColumn.formatForCode»'«/*, type: 'string'*/»)]
            #[ORM\DiscriminatorMap(['«name.formatForCode»' => «name.formatForCodeCapital»::class«FOR relation : getChildRelations», «relation.discriminatorInfo»«ENDFOR»])]
        «ENDIF»
        «IF changeTrackingPolicy != EntityChangeTrackingPolicy::DEFERRED_IMPLICIT»
            #[ORM\ChangeTrackingPolicy('«changeTrackingPolicy.literal»')]
        «ENDIF»
    '''

    def private index(EntityIndex it, String indexType) '''
        #[ORM\«indexType.toFirstUpper»(name: '«name.formatForDB»', fields: [«FOR item : items SEPARATOR ','»«item.indexField»«ENDFOR»]«IF type == EntityIndexType.FULLTEXT», flags: ['fulltext']«ENDIF»)]
    '''
    def private indexField(EntityIndexItem it) '''«''»'«indexItemForEntity»'«''»'''

    def private discriminatorInfo(InheritanceRelationship it) '''
        '«source.name.formatForCode»' => «source.name.formatForCodeCapital»::class
    '''
}
