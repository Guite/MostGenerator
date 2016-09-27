package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

abstract class AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    Application app
    String classType = ''
    FileHelper fh = new FileHelper
    protected IFileSystemAccess fsa

    /**
     * Generates separate extension classes.
     */
    override extensionClasses(Entity it, IFileSystemAccess fsa) {
        this.fsa = fsa
        if (extensionClassType != '') {
            extensionClasses(it, extensionClassType)
        }
    }

    /**
     * Single extension class.
     */
    def protected extensionClasses(Entity it, String classType) {
        this.app = application
        this.classType = classType

        val entityPath = app.getAppSourceLibPath + 'Entity/'
        val entitySuffix = if (app.targets('1.3.x')) '' else 'Entity'
        var classPrefix = name.formatForCodeCapital + classType.formatForCodeCapital
        val repositoryPath = entityPath + 'Repository/'
        var fileName = ''
        if (!isInheriting) {
            fileName = 'Base/Abstract' + classPrefix + entitySuffix + '.php'
            if (!app.shouldBeSkipped(entityPath + fileName)) {
                if (app.shouldBeMarked(entityPath + fileName)) {
                    fileName = 'Base/Abstract' + classPrefix + entitySuffix + '.generated.php'
                }
                fsa.generateFile(entityPath + fileName, fh.phpFileContent(app, extensionClassBaseImpl))
            }

            fileName = 'Base/Abstract' + classPrefix + '.php'
            if (classType != 'closure' && !app.shouldBeSkipped(repositoryPath + fileName)) {
                if (app.shouldBeMarked(repositoryPath + fileName)) {
                    fileName = 'Base/Abstract' + classPrefix + '.generated.php'
                }
                fsa.generateFile(repositoryPath + fileName, fh.phpFileContent(app, extensionClassRepositoryBaseImpl))
            }
        }
        if (!app.generateOnlyBaseClasses) {
            fileName = classPrefix + entitySuffix + '.php'
            if (!app.shouldBeSkipped(entityPath + fileName)) {
                if (app.shouldBeMarked(entityPath + fileName)) {
                    fileName = classPrefix + entitySuffix + '.generated.php'
                }
                fsa.generateFile(entityPath + fileName, fh.phpFileContent(app, extensionClassImpl))
            }

            fileName = classPrefix + '.php'
            if (classType != 'closure' && !app.shouldBeSkipped(repositoryPath + fileName)) {
                if (app.shouldBeMarked(repositoryPath + fileName)) {
                    fileName = classPrefix + '.generated.php'
                }
                fsa.generateFile(repositoryPath + fileName, fh.phpFileContent(app, extensionClassRepositoryImpl))
            }
        }
    }

    def protected extensionClassBaseImpl(Entity it) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity\Base;

        «ENDIF»
        «extensionClassImports»

        /**
         * «extensionClassDescription»
         *
         * This is the base «classType.formatForDisplay» class for «it.name.formatForDisplay» entities.
         */
        abstract class «IF !app.targets('1.3.x')»Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»Entity«ELSE»«entityClassName(classType, true)»«ENDIF» extends «extensionBaseClass»
        {
            «extensionClassBaseAnnotations»
        }
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        ''
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) {
        ''
    }

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        ''
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        ''
    }

    /**
     * Returns the extension base class ORM annotations.
     */
    override extensionClassBaseAnnotations(Entity it) {
        ''
    }

    def protected extensionClassEntityAccessors(Entity it) '''
        «val app = application»
        /**
         * Get reference to owning entity.
         *
         * @return «IF !app.targets('1.3.x')»\«ENDIF»«entityClassName('', false)»
         */
        public function getEntity()
        {
            return $this->entity;
        }

        /**
         * Set reference to owning entity.
         *
         * @param «IF !app.targets('1.3.x')»\«ENDIF»«entityClassName('', false)» $entity
         */
        public function setEntity(/*«IF !app.targets('1.3.x')»\«ENDIF»«entityClassName('', false)» */$entity)
        {
            $this->entity = $entity;
        }
    '''

    def protected extensionClassImpl(Entity it) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity;

            use «app.appNamespace»\Entity\«IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»Entity«ELSE»Base\Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»Entity«ENDIF» as BaseEntity;

        «ENDIF»
        use Doctrine\ORM\Mapping as ORM;

        /**
         * «extensionClassDescription»
         *
         * This is the concrete «classType.formatForDisplay» class for «it.name.formatForDisplay» entities.
        «extensionClassImplAnnotations»
         */
        «IF app.targets('1.3.x')»
        class «entityClassName(classType, false)» extends «IF isInheriting»«parentType.entityClassName(classType, false)»«ELSE»Abstract«entityClassName(classType, true)»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital»«classType.formatForCodeCapital»Entity extends BaseEntity
        «ENDIF»
        {
            // feel free to add your own methods here
        }
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) {
        ''
    }

    def protected repositoryClass(Entity it, String classType) {
        if (null === app) {
            app = application
        }
        (if (app.targets('1.3.x')) app.appName + '_Entity_Repository_' else app.appNamespace + '\\Entity\\Repository\\') + name.formatForCodeCapital + classType.formatForCodeCapital
    }

    def protected extensionClassRepositoryBaseImpl(Entity it) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity\Repository\Base;

        «ENDIF»
        «IF classType == 'translation'»
            use Gedmo\Translatable\Entity\Repository\TranslationRepository;
        «ELSEIF classType == 'logEntry'»
            use Gedmo\Loggable\Entity\Repository\LogEntryRepository;
        «ELSE»
            use Doctrine\ORM\EntityRepository;
        «ENDIF»

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «it.name.formatForDisplay» «classType.formatForDisplay» entities.
         */
        «IF app.targets('1.3.x')»
        abstract class «app.appName»_Entity_Repository_Base_Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital» extends «IF classType == 'translation'»Translation«ELSEIF classType == 'logEntry'»LogEntry«ELSE»Entity«ENDIF»Repository
        «ELSE»
        abstract class Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital» extends «IF classType == 'translation'»Translation«ELSEIF classType == 'logEntry'»LogEntry«ELSE»Entity«ENDIF»Repository
        «ENDIF»
        {
        }
    '''

    def protected extensionClassRepositoryImpl(Entity it) '''
        «IF !app.targets('1.3.x')»
            namespace «app.appNamespace»\Entity\Repository;

            use «app.appNamespace»\Entity\Repository\«IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»«ENDIF» as BaseRepository;

        «ENDIF»
        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «it.name.formatForDisplay» «classType.formatForDisplay» entities.
         */
        «IF app.targets('1.3.x')»
        class «app.appName»_Entity_Repository_«name.formatForCodeCapital»«classType.formatForCodeCapital» extends «IF isInheriting»«app.appName»_Entity_Repository_«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»«ELSE»«app.appName»_Entity_Repository_Base_Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital»«classType.formatForCodeCapital» extends BaseRepository
        «ENDIF»
        {
            // feel free to add your own methods here
        }
    '''
}
