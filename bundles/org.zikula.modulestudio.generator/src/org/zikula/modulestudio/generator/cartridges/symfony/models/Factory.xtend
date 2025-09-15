package org.zikula.modulestudio.generator.cartridges.symfony.models

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.cartridges.symfony.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Factory {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    FileHelper fh

    /**
     * Creates a factory class file for easy entity creation.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        fh = new FileHelper(it)
        'Generating entity factory class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Entity/Factory/EntityFactory.php', modelFactoryBaseImpl, modelFactoryImpl)
        new EntityInitializer().generate(it, fsa)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Doctrine\\ORM\\EntityManagerInterface',
            'Doctrine\\ORM\\EntityRepository',
            'InvalidArgumentException',
            appNamespace + '\\Entity\\Factory\\EntityInitializer',
            appNamespace + '\\Helper\\CollectionFilterHelper'
        ])
        for (entity : entities) {
            imports.add(appNamespace + '\\Entity\\' + entity.name.formatForCodeCapital)
        }
        if (hasTranslatable) {
            imports.add(appNamespace + '\\Helper\\FeatureActivationHelper')
        }
        imports
    }

    def private modelFactoryBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        «collectBaseImports.print»

        /**
         * Factory class used to create entities and receive entity repositories.
         */
        abstract class AbstractEntityFactory
        {
            public function __construct(
                protected readonly EntityManagerInterface $entityManager,
                protected readonly EntityInitializer $entityInitializer,
                protected readonly CollectionFilterHelper $collectionFilterHelper«IF hasTranslatable»,
                protected readonly FeatureActivationHelper $featureActivationHelper«ENDIF»
            ) {
            }

            /**
             * Returns a repository for a given object type.
             */
            public function getRepository(string $objectType): EntityRepository
            {
                $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucfirst($objectType) . 'Entity';

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
            «FOR entity : entities»

                /**
                 * Creates a new «entity.name.formatForCode» instance.
                 */
                public function create«entity.name.formatForCodeCapital»(): «entity.name.formatForCodeCapital»
                {
                    $entity = new «entity.name.formatForCodeCapital»(«/* TODO provide entity constructor arguments if required */»);

                    $this->entityInitializer->init«entity.name.formatForCodeCapital»($entity);

                    return $entity;
                }
            «ENDFOR»

            «getIdField»
            «fh.getterMethod(it, 'entityManager', 'EntityManagerInterface', false)»
            «fh.getterMethod(it, 'entityInitializer', 'EntityInitializer', false)»
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
            $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Bundle:' . ucfirst($objectType);

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
