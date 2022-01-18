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

    FileHelper fh

    /**
     * Creates a factory class file for easy entity creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fh = new FileHelper(it)
        'Generating entity factory class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Entity/Factory/EntityFactory.php', modelFactoryBaseImpl, modelFactoryImpl)
        new EntityInitialiser().generate(it, fsa)
    }

    def private modelFactoryBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        use Doctrine\ORM\EntityManagerInterface;
        use Doctrine\ORM\EntityRepository;
        use InvalidArgumentException;
        use «appNamespace»\Entity\Factory\EntityInitialiser;
        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        use «appNamespace»\Helper\CollectionFilterHelper;
        «IF hasTranslatable»
            use «appNamespace»\Helper\FeatureActivationHelper;
        «ENDIF»

        /**
         * Factory class used to create entities and receive entity repositories.
         */
        abstract class AbstractEntityFactory
        {
            public function __construct(
                protected EntityManagerInterface $entityManager,
                protected EntityInitialiser $entityInitialiser,
                protected CollectionFilterHelper $collectionFilterHelper«IF hasTranslatable»,
                protected FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
            }

            /**
             * Returns a repository for a given object type.
             */
            public function getRepository(string $objectType): EntityRepository
            {
                $entityClass = '«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\' . ucfirst($objectType) . 'Entity';

                /** @var EntityRepository $repository */
                $repository = $this->getEntityManager()->getRepository($entityClass);
                $repository->setCollectionFilterHelper($this->collectionFilterHelper);
                «IF hasTranslatable»

                    if (in_array($objectType, ['«getTranslatableEntities.map[name.formatForCode].join('\', \'')»'], true)) {
                        $repository->setTranslationsEnabled(
                            $this->featureActivationHelper->isEnabled(FeatureActivationHelper::TRANSLATIONS, $objectType)
                        );
                    }
                «ENDIF»

                return $repository;
            }
            «FOR entity : getAllEntities»

                /**
                 * Creates a new «entity.name.formatForCode» instance.
                 */
                public function create«entity.name.formatForCodeCapital»(): «entity.name.formatForCodeCapital»Entity
                {
                    $entity = new «entity.name.formatForCodeCapital»Entity(«/* TODO provide entity constructor arguments if required */»);

                    $this->entityInitialiser->init«entity.name.formatForCodeCapital»($entity);

                    return $entity;
                }
            «ENDFOR»

            «getIdField»
            «fh.getterMethod(it, 'entityManager', 'EntityManagerInterface', false)»
            «fh.getterMethod(it, 'entityInitialiser', 'EntityInitialiser', false)»
        }
    '''

    def private getIdField(Application it) '''
        /**
         * Returns the identifier field's name for a given object type.
         */
        public function getIdField(string $objectType = ''): string
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException('Invalid object type received.');
            }
            $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucfirst($objectType) . 'Entity';

            $meta = $this->getEntityManager()->getClassMetadata($entityClass);

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
