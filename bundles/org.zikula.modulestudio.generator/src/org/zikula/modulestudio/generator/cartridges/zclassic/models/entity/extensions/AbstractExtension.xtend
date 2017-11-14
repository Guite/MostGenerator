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

        val entityPath = 'Entity/'
        val entitySuffix = 'Entity'
        val repositorySuffix = 'Repository'
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

            fileName = 'Base/Abstract' + classPrefix + repositorySuffix + '.php'
            if (classType != 'closure' && !app.shouldBeSkipped(repositoryPath + fileName)) {
                if (app.shouldBeMarked(repositoryPath + fileName)) {
                    fileName = 'Base/Abstract' + classPrefix + repositorySuffix + '.generated.php'
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

            fileName = classPrefix + repositorySuffix + '.php'
            if (classType != 'closure' && !app.shouldBeSkipped(repositoryPath + fileName)) {
                if (app.shouldBeMarked(repositoryPath + fileName)) {
                    fileName = classPrefix + repositorySuffix + '.generated.php'
                }
                fsa.generateFile(repositoryPath + fileName, fh.phpFileContent(app, extensionClassRepositoryImpl))
            }
        }
    }

    def protected extensionClassBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Entity\Base;

        «extensionClassImports»

        /**
         * «extensionClassDescription»
         *
         * This is the base «classType.formatForDisplay» class for «it.name.formatForDisplay» entities.
         */
        abstract class Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»Entity extends «extensionBaseClass»
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
        /**
         * Get reference to owning entity.
         *
         * @return \«entityClassName('', false)»
         */
        public function getEntity()
        {
            return $this->entity;
        }

        /**
         * Set reference to owning entity.
         *
         * @param \«entityClassName('', false)» $entity
         */
        public function setEntity(/*\«entityClassName('', false)» */$entity)
        {
            $this->entity = $entity;
        }
    '''

    def protected extensionClassImpl(Entity it) '''
        namespace «app.appNamespace»\Entity;

        use «app.appNamespace»\Entity\«IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»Entity«ELSE»Base\Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»Entity«ENDIF» as BaseEntity;

        use Doctrine\ORM\Mapping as ORM;

        /**
         * «extensionClassDescription»
         *
         * This is the concrete «classType.formatForDisplay» class for «it.name.formatForDisplay» entities.
        «extensionClassImplAnnotations»
         */
        class «name.formatForCodeCapital»«classType.formatForCodeCapital»Entity extends BaseEntity
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
        app.appNamespace + '\\Entity\\Repository\\' + name.formatForCodeCapital + classType.formatForCodeCapital + 'Repository'
    }

    def protected extensionClassRepositoryBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Entity\Repository\Base;

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
        abstract class Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»Repository extends «IF classType == 'translation'»Translation«ELSEIF classType == 'logEntry'»LogEntry«ELSE»Entity«ENDIF»Repository
        {
        }
    '''

    def protected extensionClassRepositoryImpl(Entity it) '''
        namespace «app.appNamespace»\Entity\Repository;

        use «app.appNamespace»\Entity\Repository\«IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»«ENDIF»Repository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «it.name.formatForDisplay» «classType.formatForDisplay» entities.
         */
        class «name.formatForCodeCapital»«classType.formatForCodeCapital»Repository extends «IF isInheriting»«parentType.name.formatForCodeCapital»«classType.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»«ENDIF»Repository
        {
            // feel free to add your own methods here
        }
    '''
}
