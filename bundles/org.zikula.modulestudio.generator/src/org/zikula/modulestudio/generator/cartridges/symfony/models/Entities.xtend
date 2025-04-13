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
            }
            imports.add('Symfony\\Component\\Validator\\Constraints as Assert')
        }
        if (!getUniqueFields.empty || (hasSluggableFields && slugUnique) || !incoming.filter[unique].empty || !outgoing.filter[unique].empty) {
            imports.add('Symfony\\Bridge\\Doctrine\\Validator\\Constraints\\UniqueEntity')
        }
        if (!isBase) {
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
            imports.add(application.appNamespace + '\\Entity\\EntityInterface')
            if (tree) {
                imports.add(application.appNamespace + '\\Entity\\' + name.formatForCodeCapital)
            }
            for (relation : getBidirectionalIncomingRelations) {
                imports.addAll(thAssoc.importRelatedEntity(relation, false))
            }
            for (relation : outgoing) {
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
        abstract class Abstract«name.formatForCodeCapital» implements AbstractEntityInterface«IF it.hasTranslatableFields», Translatable«ENDIF»
        {
            «modelEntityBaseImplBody(app)»
        }
    '''

    def private modelEntityBaseImplBody(Entity it, Application app) '''
        «memberVars»

        «new EntityConstructor().constructor(it, false)»
        «accessors»
        «new EntityMethods().generate(it, app, thProp)»
    '''

    def private memberVars(Entity it) '''
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
        «IF hasUploadFieldsEntity»
            «fh.getterAndSetterMethods(it, '_uploadBasePathRelative', 'string', false, '', '')»
            «fh.getterAndSetterMethods(it, '_uploadBasePathAbsolute', 'string', false, '', '')»
            «fh.getterAndSetterMethods(it, '_uploadBaseUrl', 'string', false, '', '')»
        «ENDIF»
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
