package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Factory {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Creates a factory class file for easy entity creation.
     */
    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating entity factory class')
        generateClassPair(fsa, getAppSourceLibPath + 'Entity/Factory/' + name.formatForCodeCapital + 'Factory.php',
            fh.phpFileContent(it, modelFactoryBaseImpl), fh.phpFileContent(it, modelFactoryImpl)
        )
    }

    def private modelFactoryBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        use Doctrine\Common\Persistence\ObjectManager;
        use Doctrine\ORM\EntityRepository;

        /**
         * Factory class used to create entities and receive entity repositories.
         *
         * This is the base factory class.
         */
        abstract class Abstract«name.formatForCodeCapital»Factory
        {
            /**
             * @var ObjectManager The object manager to be used for determining the repository
             */
            protected $objectManager;

            /**
             * «name.formatForCodeCapital»Factory constructor.
             *
             * @param ObjectManager $objectManager The object manager to be used for determining the repositories
             */
            public function __construct(ObjectManager $objectManager)
            {
                $this->objectManager = $objectManager;
            }

            /**
             * Returns a repository for a given object type.
             *
             * @param string $objectType Name of desired entity type
             *
             * @return EntityRepository The repository responsible for the given object type
             */
            public function getRepository($objectType)
            {
                $entityClass = '«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucfirst($objectType) . 'Entity';

                return $this->objectManager->getRepository($className);
            }
            «FOR entity : getAllEntities»

                /**
                 * Creates a new «entity.name.formatForCode» instance.
                 *
                 * @return «appNamespace»\Entity\«entity.name.formatForCode»Entity The newly created entity instance
                 */
                public function create«entity.name.formatForCodeCapital»()
                {
                    $entityClass = '«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\«entity.name.formatForCode»Entity';

                    return new $entityClass(«/* TODO constructor arguments if required */»);
                }
            «ENDFOR»

            «fh.getterAndSetterMethods(it, 'objectManager', 'ObjectManager', false, true, false, '', '')»
        }
    '''

    def private modelFactoryImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory;

        use «appNamespace»\Entity\Factory\Base\Abstract«name.formatForCodeCapital»Factory;

        /**
         * Factory class used to create entities and receive entity repositories.
         *
         * This is the concrete factory class.
         */
        class «name.formatForCodeCapital»Factory extends Abstract«name.formatForCodeCapital»Factory
        {
            // feel free to customise the factory
        }
    '''
}
