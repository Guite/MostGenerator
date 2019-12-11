package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.Utils

abstract class AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension Utils = new Utils

    Application app
    String classType = ''
    protected IMostFileSystemAccess fsa

    /**
     * Generates separate extension classes.
     */
    override extensionClasses(Entity it, IMostFileSystemAccess fsa) {
        this.fsa = fsa
        if (!extensionClassType.empty) {
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
            fsa.generateFile(entityPath + fileName, extensionClassBaseImpl)

            fileName = 'Base/Abstract' + classPrefix + repositorySuffix + '.php'
            if (classType != 'closure') {
                fsa.generateFile(repositoryPath + fileName, extensionClassRepositoryBaseImpl)
            }
        }
        if (!app.generateOnlyBaseClasses) {
            fileName = classPrefix + entitySuffix + '.php'
            fsa.generateFile(entityPath + fileName, extensionClassImpl)

            fileName = classPrefix + repositorySuffix + '.php'
            if (classType != 'closure') {
                fsa.generateFile(repositoryPath + fileName, extensionClassRepositoryImpl)
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
            «extensionClassBaseImplementation»
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
     * Returns the extension base class implementation.
     */
    override extensionClassBaseImplementation(Entity it) {
        ''
    }

    def protected extensionClassEntityAccessors(Entity it) '''
        «(new FileHelper(application)).getterMethod(it, 'entity', name.formatForCodeCapital + 'Entity', false, false, app.targets('3.0'))»
        «(new FileHelper(application)).setterMethod(it, 'entity', name.formatForCodeCapital + 'Entity', false, false, false, '', '')»
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

        «IF 'translation' == classType»
            use Gedmo\Translatable\Entity\Repository\TranslationRepository;
        «ELSEIF 'logEntry' == classType»
            «IF application.targets('2.0')»
                use DateInterval;
                use DateTime;
            «ENDIF»
            use Doctrine\Common\Collections\ArrayCollection;
            use Gedmo\Loggable\Entity\Repository\LogEntryRepository;
            use Gedmo\Loggable\LoggableListener;
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
            «extensionRepositoryClassBaseImplementation»
        }
    '''

    /**
     * Returns the extension repository base class implementation.
     */
    override extensionRepositoryClassBaseImplementation(Entity it) {
        ''
    }

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
