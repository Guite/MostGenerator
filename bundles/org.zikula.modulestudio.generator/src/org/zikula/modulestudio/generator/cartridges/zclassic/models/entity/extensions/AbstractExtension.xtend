package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

abstract class AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
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

        fileName = 'Base/Abstract' + classPrefix + entitySuffix + '.php'
        fsa.generateFile(entityPath + fileName, extensionClassBaseImpl)

        if (classType != 'closure') {
            fileName = 'Base/Abstract' + classPrefix + repositorySuffix + 'Interface.php'
            fsa.generateFile(repositoryPath + fileName, extensionClassRepositoryInterfaceBaseImpl)
            fileName = 'Base/Abstract' + classPrefix + repositorySuffix + '.php'
            fsa.generateFile(repositoryPath + fileName, extensionClassRepositoryBaseImpl)
        }

        if (!app.generateOnlyBaseClasses) {
            fileName = classPrefix + entitySuffix + '.php'
            fsa.generateFile(entityPath + fileName, extensionClassImpl)

            if (classType != 'closure') {
                fileName = classPrefix + repositorySuffix + 'Interface.php'
                fsa.generateFile(repositoryPath + fileName, extensionClassRepositoryInterfaceImpl)
                fileName = classPrefix + repositorySuffix + '.php'
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
        «(new FileHelper(application)).getterAndSetterMethods(it, 'entity', name.formatForCodeCapital + 'Entity', false, '', '')»
    '''

    def protected extensionClassImpl(Entity it) '''
        namespace «app.appNamespace»\Entity;

        use «app.appNamespace»\Entity\Base\Abstract«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»«classType.formatForCodeCapital»Entity as BaseEntity;
        use Doctrine\ORM\Mapping as ORM;

        /**
         * «extensionClassDescription»
         *
         * This is the concrete «classType.formatForDisplay» class for «it.name.formatForDisplay» entities.
         *
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
        app.appNamespace + '\\Repository\\' + name.formatForCodeCapital + classType.formatForCodeCapital + 'Repository'
    }

    def protected extensionClassRepositoryInterfaceBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Repository\Base;

        use Doctrine\Persistence\ObjectRepository;
        use «entityClassName(classType, false)»;

        /**
         * Repository interface for «it.name.formatForDisplay» «classType.formatForDisplay» entities.
         *
        «methodAnnotations»
         */
        interface Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»RepositoryInterface extends ObjectRepository
        {
            «extensionRepositoryInterfaceBaseImplementation»
        }
    '''

    def private methodAnnotations(Entity it) '''
        «' '»* @method «name.formatForCodeCapital»«classType.formatForCodeCapital»Entity|null find($id, $lockMode = null, $lockVersion = null)
        «' '»* @method «name.formatForCodeCapital»«classType.formatForCodeCapital»Entity[] findAll()
        «' '»* @method «name.formatForCodeCapital»«classType.formatForCodeCapital»Entity[] findBy(array $criteria, ?array $orderBy = null, $limit = null, $offset = null)
        «' '»* @method «name.formatForCodeCapital»«classType.formatForCodeCapital»Entity|null findOneBy(array $criteria, ?array $orderBy = null)
        «' '»* @method int count(array $criteria)
    '''

    def protected extensionClassRepositoryBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Repository\Base;

        «IF 'translation' == classType»
            use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepositoryInterface;
            use Doctrine\ORM\EntityManagerInterface;
            use Gedmo\Translatable\Entity\Repository\TranslationRepository;
        «ELSEIF 'logEntry' == classType»
            use DateInterval;
            use DateTime;
            use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepositoryInterface;
            use Doctrine\ORM\EntityManagerInterface;
            use Gedmo\Loggable\Entity\Repository\LogEntryRepository;
            use Gedmo\Loggable\LoggableListener;
        «ELSE»
            use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
            use Doctrine\Persistence\ManagerRegistry;
        «ENDIF»
        use «entityClassName(classType, false)»;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the base repository class for «it.name.formatForDisplay» «classType.formatForDisplay» entities.
         *
        «methodAnnotations»
         */
        abstract class Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»Repository extends «IF classType == 'translation'»Translation«ELSEIF classType == 'logEntry'»LogEntry«ELSE»ServiceEntity«ENDIF»Repository implements Abstract«name.formatForCodeCapital»«classType.formatForCodeCapital»RepositoryInterface«IF classType == 'translation' || classType == 'logEntry'», ServiceEntityRepositoryInterface«ENDIF»
        {
            «IF classType == 'translation' || classType == 'logEntry'»
                public function __construct(EntityManagerInterface $manager)
                {
                    parent::__construct($manager, $manager->getClassMetadata(«name.formatForCodeCapital»«classType.formatForCodeCapital»Entity::class));
                }
            «ELSE»
                public function __construct(ManagerRegistry $registry)
                {
                    parent::__construct($registry, «name.formatForCodeCapital»«classType.formatForCodeCapital»Entity::class);
                }
            «ENDIF»

            «extensionRepositoryClassBaseImplementation»
        }
    '''

    /**
     * Returns the extension repository interface base implementation.
     */
    override extensionRepositoryInterfaceBaseImplementation(Entity it) {
        ''
    }

    /**
     * Returns the extension repository class base implementation.
     */
    override extensionRepositoryClassBaseImplementation(Entity it) {
        ''
    }

    def protected extensionClassRepositoryInterfaceImpl(Entity it) '''
        namespace «app.appNamespace»\Repository;

        use «app.appNamespace»\Repository\Base\Abstract«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»«classType.formatForCodeCapital»RepositoryInterface;

        /**
         * Repository interface for «it.name.formatForDisplay» «classType.formatForDisplay» entities.
         */
        interface «name.formatForCodeCapital»«classType.formatForCodeCapital»RepositoryInterface extends Abstract«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»«classType.formatForCodeCapital»RepositoryInterface
        {
            // feel free to add your own interface methods
        }
    '''

    def protected extensionClassRepositoryImpl(Entity it) '''
        namespace «app.appNamespace»\Repository;

        use «app.appNamespace»\Repository\Base\Abstract«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»«classType.formatForCodeCapital»Repository;

        /**
         * Repository class used to implement own convenience methods for performing certain DQL queries.
         *
         * This is the concrete repository class for «it.name.formatForDisplay» «classType.formatForDisplay» entities.
         */
        class «name.formatForCodeCapital»«classType.formatForCodeCapital»Repository extends Abstract«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»«classType.formatForCodeCapital»Repository implements «name.formatForCodeCapital»«classType.formatForCodeCapital»RepositoryInterface
        {
            // feel free to add your own methods here
        }
    '''
}
