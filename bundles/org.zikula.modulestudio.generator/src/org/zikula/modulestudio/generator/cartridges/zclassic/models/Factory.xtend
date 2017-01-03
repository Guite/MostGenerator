package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
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
        this.fsa = fsa
        app = it
        getAllEntities.forEach(e|e.generate)
    }

    /**
     * Creates a factory class file for every Entity instance.
     */
    def private generate(Entity it) {
        println('Generating factory classes for entity "' + name.formatForDisplay + '"')
        val factoryPath = app.getAppSourceLibPath + 'Entity/Factory/'

        var fileName = 'Base/Abstract' + name.formatForCodeCapital + 'Factory.php'
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
        use Doctrine\ORM\EntityRepository;

        /**
         * Factory class used to retrieve entity and repository instances.
         *
         * This is the base factory class for «name.formatForDisplay» entities.
         */
        abstract class Abstract«name.formatForCodeCapital»Factory
        {
            /**
             * @var String Full qualified class name to be used for «nameMultiple.formatForDisplay».
             */
            protected $className;

            /**
             * @var ObjectManager The object manager to be used for determining the repository
             */
            protected $objectManager;

            /**
             * @var EntityRepository The currently used repository
             */
            protected $repository;

            /**
             * «name.formatForCodeCapital»Factory constructor.
             *
             * @param ObjectManager $objectManager The object manager to be used for determining the repository
             * @param String        $className     Full qualified class name to be used for «nameMultiple.formatForDisplay»
             */
            public function __construct(ObjectManager $objectManager, $className)
            {
                $this->className = $className;
                $this->objectManager = $objectManager;
                $this->repository = $this->objectManager->getRepository($className);
            }

            public function create«name.formatForCodeCapital»()
            {
                $entityClass = $this->className;

                return new $entityClass(«/* TODO constructor arguments if required */»);
            }

            «fh.getterAndSetterMethods(it, 'className', 'string', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'objectManager', 'ObjectManager', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'repository', 'EntityRepository', false, true, false, '', '')»
        }
    '''

    def private modelFactoryImpl(Entity it) '''
        namespace «app.appNamespace»\Entity\Factory;

        use «app.appNamespace»\Entity\Factory\«IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Base\Abstract«name.formatForCodeCapital»«ENDIF»Factory;

        /**
         * Factory class used to retrieve entity and repository instances.
         *
         * This is the concrete factory class for «name.formatForDisplay» entities.
         */
        class «name.formatForCodeCapital»Factory extends «IF isInheriting»«parentType.name.formatForCodeCapital»«ELSE»Abstract«name.formatForCodeCapital»«ENDIF»Factory
        {
            // feel free to customise the manager
        }
    '''
}
