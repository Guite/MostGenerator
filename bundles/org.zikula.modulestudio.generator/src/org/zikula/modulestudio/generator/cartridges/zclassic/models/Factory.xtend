package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Factory {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    /**
     * Creates a factory class file for easy entity creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating entity factory class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Entity/Factory/EntityFactory.php', modelFactoryBaseImpl, modelFactoryImpl)
        new EntityInitialiser().generate(it, fsa)
    }

    def private modelFactoryBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        use Doctrine\Common\Persistence\ObjectManager;
        use Doctrine\ORM\EntityRepository;
        use InvalidArgumentException;
        use «appNamespace»\Entity\Factory\EntityInitialiser;
        use «appNamespace»\Helper\CollectionFilterHelper;
        «IF hasTranslatable»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Factory class used to create entities and receive entity repositories.
         */
        abstract class AbstractEntityFactory
        {
            /**
             * @var ObjectManager The object manager to be used for determining the repository
             */
            protected $objectManager;

            /**
             * @var EntityInitialiser The entity initialiser for dynamical application of default values
             */
            protected $entityInitialiser;

            /**
             * @var CollectionFilterHelper
             */
            protected $collectionFilterHelper;
            «IF hasTranslatable»

                /**
                 * @var FeatureActivationHelper
                 */
                protected $featureActivationHelper;
            «ENDIF»

            /**
             * EntityFactory constructor.
             *
             * @param ObjectManager          $objectManager          The object manager to be used for determining the repositories
             * @param EntityInitialiser      $entityInitialiser      The entity initialiser for dynamical application of default values
             * @param CollectionFilterHelper $collectionFilterHelper CollectionFilterHelper service instance
             «IF hasTranslatable»
             * @param FeatureActivationHelper $featureActivationHelper FeatureActivationHelper service instance
             «ENDIF»
             */
            public function __construct(
                ObjectManager $objectManager,
                EntityInitialiser $entityInitialiser,
                CollectionFilterHelper $collectionFilterHelper«IF hasTranslatable»,
                FeatureActivationHelper $featureActivationHelper«ENDIF»)
            {
                $this->objectManager = $objectManager;
                $this->entityInitialiser = $entityInitialiser;
                $this->collectionFilterHelper = $collectionFilterHelper;
                «IF hasTranslatable»
                    $this->featureActivationHelper = $featureActivationHelper;
                «ENDIF»
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

                $repository = $this->objectManager->getRepository($entityClass);
                $repository->setCollectionFilterHelper($this->collectionFilterHelper);
                «IF hasTranslatable»

                    if (in_array($objectType, ['«getTranslatableEntities.map[name.formatForCode].join('\', \'')»'])) {
                        $repository->setTranslationsEnabled($this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $objectType));
                    }
                «ENDIF»

                return $repository;
            }
            «FOR entity : getAllEntities»

                /**
                 * Creates a new «entity.name.formatForCode» instance.
                 *
                 * @return \«appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity The newly created entity instance
                 */
                public function create«entity.name.formatForCodeCapital»()
                {
                    $entityClass = '«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\«entity.name.formatForCodeCapital»Entity';

                    $entity = new $entityClass(«/* TODO provide entity constructor arguments if required */»);

                    $this->entityInitialiser->init«entity.name.formatForCodeCapital»($entity);

                    return $entity;
                }
            «ENDFOR»

            «getIdField»

            «fh.getterAndSetterMethods(it, 'objectManager', 'ObjectManager', false, true, false, '', '')»

            «fh.getterAndSetterMethods(it, 'entityInitialiser', 'EntityInitialiser', false, true, false, '', '')»
        }
    '''

    def private getIdField(Application it) '''
        /**
         * Returns the identifier field's name for a given object type.
         *
         * @param string $objectType The object type to be treated
         *
         * @return string Primary identifier field name
         */
        public function getIdField($objectType = '')
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException('Invalid object type received.');
            }
            $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucfirst($objectType) . 'Entity';

            $meta = $this->getObjectManager()->getClassMetadata($entityClass);

            return $meta->getSingleIdentifierFieldName();
        }
    '''

    def private modelFactoryImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory;

        use «appNamespace»\Entity\Factory\Base\AbstractEntityFactory;

        /**
         * Factory class used to create entities and receive entity repositories.
         */
        class EntityFactory extends AbstractEntityFactory
        {
            // feel free to customise the factory
        }
    '''
}
