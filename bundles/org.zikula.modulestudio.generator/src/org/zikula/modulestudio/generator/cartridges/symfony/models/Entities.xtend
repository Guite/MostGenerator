package org.zikula.modulestudio.generator.cartridges.symfony.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.ArrayField
import de.guite.modulestudio.metamodel.Entity
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
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils
import de.guite.modulestudio.metamodel.TextField
import de.guite.modulestudio.metamodel.TextRole

class Entities {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
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

        for (entity : entities) {
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
    def private generate(Entity it, Application app, IMostFileSystemAccess fsa) {
        ('Generating entity classes for entity "' + name.formatForDisplay + '"').printIfNotTesting(fsa)
        extMan = new ExtensionManager(it)
        thProp = new Property(app, extMan)
        thAssoc.resetImports
        fsa.generateClassPair('Entity/' + name.formatForCodeCapital + '.php', modelEntityBaseImpl(app), modelEntityImpl(app))
    }

    def private collectBaseImports(Entity it, Boolean isBase) {
        val imports = new ImportList
        imports.add('Doctrine\\DBAL\\Types\\Types')
        imports.add('Doctrine\\ORM\\Mapping as ORM')
        if (isBase) {
            if (hasCollections || tree) {
                imports.add('Doctrine\\Common\\Collections\\ArrayCollection')
                imports.add('Doctrine\\Common\\Collections\\Collection')
            }
        }
        if (isBase || loggable || hasTranslatableFields || tree) {
            imports.add('Gedmo\\Mapping\\Annotation as Gedmo')
        }
        if (hasSluggableFields) {
            if (tree) {
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
                imports.add('Vich\\UploaderBundle\\Entity\\File as EmbeddedFile')
                imports.add('Vich\\UploaderBundle\\Mapping\\Annotation as Vich')
                if (!getUploadFieldsEntity.filter[mandatory].empty) {
                    imports.add('Vich\\UploaderBundle\\Validator\\Constraints as VichAssert')
                }
            }
            imports.add('Symfony\\Component\\Validator\\Constraints as Assert')
            if (!fields.filter(TextField).filter[role == TextRole.CODE_TWIG].empty) {
                imports.add('Symfony\\Bridge\\Twig\\Validator\\Constraints\\Twig')
            }
        }
        if (!getUniqueFields.empty || !incoming.filter[unique].empty || !outgoing.filter[unique].empty) {
            imports.add('Symfony\\Bridge\\Doctrine\\Validator\\Constraints\\UniqueEntity')
        }
        val nsApp = application.appNamespace
        if (!isBase) {
            if (loggable) {
                imports.add(nsApp + '\\Entity\\' + name.formatForCodeCapital + 'LogEntry')
            }
            if (hasTranslatableFields) {
                imports.add(nsApp + '\\Entity\\' + name.formatForCodeCapital + 'Translation')
            }
            imports.add(nsApp + '\\Repository\\' + name.formatForCodeCapital + 'Repository')
        } else {
            imports.add('Symfony\\Component\\Uid\\Uuid')
            imports.add(nsApp + '\\Helper\\Doctrine\\UuidStringGenerator')
            if (hasUserFieldsEntity) {
                imports.add('Zikula\\UsersBundle\\Entity\\User')
            }
            imports.add(nsApp + '\\Entity\\EntityInterface')
            if (tree) {
                imports.add(nsApp + '\\Entity\\' + name.formatForCodeCapital)
            }
            for (relation : getBidirectionalIncomingRelations) {
                imports.addAll(thAssoc.importRelatedEntity(relation, false))
            }
            for (relation : outgoing) {
                imports.addAll(thAssoc.importRelatedEntity(relation, true))
            }
            imports.add(nsApp + '\\Repository\\' + name.formatForCodeCapital + 'Repository')
            if (hasListFieldsEntity) {
                imports.add(nsApp + '\\Validator\\Constraints as ' + application.name.formatForCodeCapital + 'Assert')
            }
        }
        if (!isBase) {
            imports.add(nsApp + '\\Entity\\Base\\Abstract' + name.formatForCodeCapital + ' as BaseEntity')
        }
        imports
    }

    def private modelEntityBaseImpl(Entity it, Application app) '''
        namespace «app.appNamespace»\Entity\Base;

        «collectBaseImports(true).print»

        «modelEntityBaseImplClass(app)»
    '''

    def private modelEntityBaseImplClass(Entity it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the base entity class for «name.formatForDisplay» entities.
         * The following annotation marks it as a mapped superclass so subclasses
         * inherit orm properties.
         */
        #[ORM\MappedSuperclass]
        «IF hasUploadFieldsEntity»
            #[Vich\Uploadable]
        «ENDIF»
        abstract class Abstract«name.formatForCodeCapital» implements \Stringable, AbstractEntityInterface«IF it.hasTranslatableFields», Translatable«ENDIF»
        {
            «modelEntityBaseImplBody(app)»
        }
    '''

    def private modelEntityBaseImplBody(Entity it, Application app) '''
        «memberVars»

        «new EntityConstructor().constructor(it)»
        «accessors»
        «new EntityMethods().generate(it, app, thProp)»
    '''

    def private memberVars(Entity it) '''
        /**
         * The tablename this object maps to
         */
        protected string $_objectType = '«name.formatForCode»';

        «FOR field : fields»«thProp.persistentProperty(field)»«ENDFOR»
        «extMan.additionalProperties»
        «FOR relation : getBidirectionalIncomingRelations»«thAssoc.generate(relation, false)»«ENDFOR»
        «FOR relation : outgoing»«thAssoc.generate(relation, true)»«ENDFOR»
        «IF loggable && hasTranslatableFields && fields.filter(ArrayField).filter[name.equals('translationData')].empty»
            /**
             * Log data for refreshing translations during revert to another revision
             */
            protected array $translationData = [];

        «ENDIF»
    '''

    def private accessors(Entity it) '''
        «fh.getterAndSetterMethods(it, '_objectType', 'string', false, '', '')»
        «FOR field : fields»«thProp.fieldAccessor(field)»«ENDFOR»
        «extMan.additionalAccessors»
        «FOR relation : getBidirectionalIncomingRelations»«thAssoc.relationAccessor(relation, false)»«ENDFOR»
        «FOR relation : outgoing»«thAssoc.relationAccessor(relation, true)»«ENDFOR»
        «IF loggable && hasTranslatableFields && fields.filter(ArrayField).filter[name.equals('translationData')].empty»
            «fh.getterAndSetterMethods(it, 'translationData', 'array', true, '[]', '')»
        «ENDIF»
    '''

    def private modelEntityImpl(Entity it, Application app) '''
        namespace «app.appNamespace»\Entity;

        «collectBaseImports(false).print»

        «entityImplClassDocblock(app)»
        class «name.formatForCodeCapital» extends BaseEntity implements EntityInterface
        {
            // feel free to add your own methods here
        }
    '''

    def private entityImplClassDocblock(Entity it, Application app) '''
        /**
         * Entity class that defines the entity structure and behaviours.
         *
         * This is the concrete entity class for «name.formatForDisplay» entities.
         */
        «extMan.classAnnotations»
        #[ORM\Entity(repositoryClass: «name.formatForCodeCapital»Repository::class)]
        «entityImplClassAdditionalAttributes(app)»
        «new ValidationConstraints().classAnnotations(it)»
    '''

    def private entityImplClassAdditionalAttributes(Entity it, Application app) '''
        #[ORM\Table(name: '«fullEntityTableName»')]
        «workflowIndex('Index')»
    '''

    def private workflowIndex(Entity it, String indexType) '''
        #[ORM\«indexType.toFirstUpper»(name: '«'workflowStateIndex'.formatForDB»', fields: ['workflowState'])]
    '''
}
