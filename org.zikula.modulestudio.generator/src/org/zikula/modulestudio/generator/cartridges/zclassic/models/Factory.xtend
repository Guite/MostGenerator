package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.modulestudio.Application
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.ModelInheritanceExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Factory {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelInheritanceExtensions = new ModelInheritanceExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    IFileSystemAccess fsa
    FileHelper fh = new FileHelper
    Application app

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
        this.fsa = fsa
        app = it
        getAllEntities.filter[!mappedSuperClass].forEach(e|e.generate)
    }

    /**
     * Creates a factory class file for every Entity instance.
     */
    def private generate(Entity it) {
        println('Generating factory classes for entity "' + name.formatForDisplay + '"')
        val factoryPath = app.getAppSourceLibPath + 'Entity/Factory/'

        var fileName = 'Base/' + name.formatForCodeCapital + 'Factory.php'
        if (!isInheriting && !app.shouldBeSkipped(factoryPath + fileName)) {
            if (app.shouldBeMarked(factoryPath + fileName)) {
                fileName = 'Base/' + name.formatForCodeCapital + '.generated.php'
            }
            fsa.generateFile(factoryPath + fileName, fh.phpFileContent(app, modelFactoryBaseImpl))
        }

        fileName = name.formatForCodeCapital + 'Factory.php'
        if (!app.generateOnlyBaseClasses && !app.shouldBeSkipped(factoryPath + fileName)) {
            if (app.shouldBeMarked(factoryPath + fileName)) {
                fileName = name.formatForCodeCapital + '.generated.php'
            }
            fsa.generateFile(factoryPath + fileName, fh.phpFileContent(app, modelFactoryImpl))
        }
    }

    def private modelFactoryBaseImpl(Entity it) '''
        namespace «app.appNamespace»\Entity\Factory\Base;

        use Doctrine\Common\Persistence\ObjectManager;

        /**
         * Factory class used to retrieve entity and repository instances.
         *
         * This is the base factory class for «name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Factory_Base_«name.formatForCodeCapital»
        «ELSE»
        class «name.formatForCodeCapital»Factory
        «ENDIF»
        {
            /**
             * @var String Full qualified class name to be used for «nameMultiple.formatForDisplay».
             */
            protected $className;

            /**
             * @var ObjectManager The object manager to be used for determining the repository.
             */
            protected $objectManager;

            /**
             * @var EntityRepository The currently used repository.
             */
            protected $repository;

            /**
             * Constructor.
             *
             * @param ObjectManager $om        The object manager to be used for determining the repository.
             * @param String        $className Full qualified class name to be used for «nameMultiple.formatForDisplay».
             */
            public function __construct(ObjectManager $om, $className)
            {
                $this->className = $className;
                $this->om = $om;
                $this->repository = $this->om->getRepository($className);
            }

            public function create«name.formatForCodeCapital»()
            {
                $entityClass = $this->className;

                return new $entityClass(«/* TODO consider any arguments */»);
            }

            «fh.getterAndSetterMethods(it, 'className', 'string', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'objectManager', 'ObjectManager', false, false, '', '')»
            «fh.getterAndSetterMethods(it, 'repository', 'EntityRepository', false, false, '', '')»
        }
    '''

    def private modelFactoryImpl(Entity it) '''
        «IF !app.targets('1.3.5')»
            namespace «app.appNamespace»\Entity\Factory;

            use «app.appNamespace»\Entity\Factory\«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\«name.formatForCodeCapital»«ENDIF»Factory as Base«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»Factory;

        «ENDIF»
        /**
         * Factory class used to retrieve entity and repository instances.
         *
         * This is the concrete factory class for «name.formatForDisplay» entities.
         */
        «IF app.targets('1.3.5')»
        class «app.appName»_Entity_Factory_«name.formatForCodeCapital» extends «IF isInheriting»«app.appName»_Entity_Factory_«parentType.name.formatForCodeCapital»«ELSE»«app.appName»_Entity_Factory_Base_«name.formatForCodeCapital»«ENDIF»
        «ELSE»
        class «name.formatForCodeCapital»Factory extends Base«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»«name.formatForCodeCapital»«ENDIF»Factory
        «ENDIF»
        {
            // feel free to customise the manager
        }
    '''
}
