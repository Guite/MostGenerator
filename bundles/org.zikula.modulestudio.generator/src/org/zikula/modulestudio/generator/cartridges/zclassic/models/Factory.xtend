package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.AbstractDateField
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.TimeField
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
        println('Generating entity initialiser class')
        generateClassPair(fsa, getAppSourceLibPath + 'Entity/Factory/EntityInitialiser.php',
            fh.phpFileContent(it, initialiserBaseImpl), fh.phpFileContent(it, initialiserImpl)
        )
    }

    def private modelFactoryBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        use Doctrine\Common\Persistence\ObjectManager;
        use Doctrine\ORM\EntityRepository;
        use InvalidArgumentException;
        use «appNamespace»\Entity\Factory\EntityInitialiser;

        /**
         * Factory class used to create entities and receive entity repositories.
         */
        abstract class Abstract«name.formatForCodeCapital»Factory
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
             * «name.formatForCodeCapital»Factory constructor.
             *
             * @param ObjectManager     $objectManager     The object manager to be used for determining the repositories
             * @param EntityInitialiser $entityInitialiser The entity initialiser for dynamical application of default values
             */
            public function __construct(ObjectManager $objectManager, EntityInitialiser $entityInitialiser)
            {
                $this->objectManager = $objectManager;
                $this->entityInitialiser = $entityInitialiser;
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

                return $this->objectManager->getRepository($entityClass);
            }
            «FOR entity : getAllEntities»

                /**
                 * Creates a new «entity.name.formatForCode» instance.
                 *
                 * @return «appNamespace»\Entity\«entity.name.formatForCode»Entity The newly created entity instance
                 */
                public function create«entity.name.formatForCodeCapital»()
                {
                    $entityClass = '«vendor.formatForCodeCapital»\\«name.formatForCodeCapital»Module\\Entity\\«entity.name.formatForCodeCapital»Entity';

                    $entity = new $entityClass(«/* TODO provide entity constructor arguments if required */»);

                    $this->entityInitialiser->init«entity.name.formatForCodeCapital»($entity);

                    return $entity;
                }
            «ENDFOR»

            «getIdFields»

            «hasCompositeKeys»

            «fh.getterAndSetterMethods(it, 'objectManager', 'ObjectManager', false, true, false, '', '')»

            «fh.getterAndSetterMethods(it, 'entityInitialiser', 'EntityInitialiser', false, true, false, '', '')»
        }
    '''

    def private getIdFields(Application it) '''
        /**
         * Gets the list of identifier fields for a given object type.
         *
         * @param string $objectType The object type to be treated
         *
         * @return array List of identifier field names
         */
        public function getIdFields($objectType = '')
        {
            if (empty($objectType)) {
                throw new InvalidArgumentException('Invalid object type received.');
            }
            $entityClass = '«vendor.formatForCodeCapital»«name.formatForCodeCapital»Module:' . ucfirst($objectType) . 'Entity';

            $meta = $this->getObjectManager()->getClassMetadata($entityClass);

            if ($this->hasCompositeKeys($objectType)) {
                $idFields = $meta->getIdentifierFieldNames();
            } else {
                $idFields = [$meta->getSingleIdentifierFieldName()];
            }

            return $idFields;
        }
    '''

    def private hasCompositeKeys(Application it) '''
        /**
         * Checks whether a certain entity type uses composite keys or not.
         *
         * @param string $objectType The object type to retrieve
         *
         * @return Boolean Whether composite keys are used or not
         */
        public function hasCompositeKeys($objectType)
        {
            «IF entities.filter[hasCompositeKeys].empty»
                return false;
            «ELSE»
                return in_array($objectType, ['«entities.filter[hasCompositeKeys].map[name.formatForCode].join('\', \'')»']);
            «ENDIF»
        }
    '''

    def private modelFactoryImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory;

        use «appNamespace»\Entity\Factory\Base\Abstract«name.formatForCodeCapital»Factory;

        /**
         * Factory class used to create entities and receive entity repositories.
         */
        class «name.formatForCodeCapital»Factory extends Abstract«name.formatForCodeCapital»Factory
        {
            // feel free to customise the factory
        }
    '''

    def private initialiserBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory\Base;

        «FOR entity : getAllEntities»
            use «appNamespace»\Entity\«entity.name.formatForCodeCapital»Entity;
        «ENDFOR»
        «IF !getAllListFields.filter[name != 'workflowState'].empty»
            use «appNamespace»\Helper\ListEntriesHelper;
        «ENDIF»

        /**
         * Entity initialiser class used to dynamically apply default values to newly created entities.
         */
        abstract class AbstractEntityInitialiser
        {
            «IF !getAllListFields.filter[name != 'workflowState'].empty»
                /**
                 * @var ListEntriesHelper Helper service for managing list entries
                 */
                protected $listEntriesHelper;

                /**
                 * EntityInitialiser constructor.
                 *
                 * @param ListEntriesHelper $listEntriesHelper Helper service for managing list entries
                 */
                public function __construct(ListEntriesHelper $listEntriesHelper)
                {
                    $this->listEntriesHelper = $listEntriesHelper;
                }

            «ENDIF»
            «FOR entity : getAllEntities»
                /**
                 * Initialises a given «entity.name.formatForCode» instance.
                 *
                 * @param «entity.name.formatForCodeCapital»Entity $entity The newly created entity instance
                 *
                 * @return «entity.name.formatForCodeCapital»Entity The updated entity instance
                 */
                public function init«entity.name.formatForCodeCapital»(«entity.name.formatForCodeCapital»Entity $entity)
                {
                    «FOR field : entity.getDerivedFields.filter(AbstractDateField)»
                        «field.setDefaultValue»
                    «ENDFOR»
                    «IF !entity.getListFieldsEntity.filter[name != 'workflowState'].empty»
                        «FOR listField : entity.getListFieldsEntity.filter[name != 'workflowState']»
                            $listEntries = $this->listEntriesHelper->get«listField.name.formatForCodeCapital»EntriesFor«entity.name.formatForCodeCapital»();
                            «IF listField.multiple»
                                foreach ($listEntries as $listEntry) {
                                    if (true === $listEntry['default']) {
                                        $entity->set«listField.name.formatForCodeCapital»($listEntry['value']);
                                        break;
                                    }
                                }
                            «ELSE»
                                $items = [];
                                foreach ($listEntries as $listEntry) {
                                    if (true === $listEntry['default']) {
                                        $items[] = $listEntry['value'];
                                    }
                                }
                                $entity->set«listField.name.formatForCodeCapital»(implode('###', $items));
                            «ENDIF»

                        «ENDFOR»

                    «ENDIF»
                    return $entity;
                }

            «ENDFOR»
            «IF !getAllListFields.filter[name != 'workflowState'].empty»
                «fh.getterAndSetterMethods(it, 'listEntriesHelper', 'ListEntriesHelper', false, true, false, '', '')»
            «ENDIF»
        }
    '''

    def private setDefaultValue(AbstractDateField it) {
        if (it.defaultValue !== null && it.defaultValue != '' && it.defaultValue.length > 0) {
            if (it.defaultValue != 'now') {
                '''$entity->set«name.formatForCodeCapital»(new \DateTime('«it.defaultValue»'));'''
            } else {
                '''$entity->set«name.formatForCodeCapital»(\DateTime::createFromFormat('«defaultFormat»'));'''
            }
        }
    }

    def private dispatch defaultFormat(DatetimeField it) '''Y-m-d H:i:s'''
    def private dispatch defaultFormat(DateField it) '''Y-m-d'''
    def private dispatch defaultFormat(TimeField it) '''H:i:s'''

    def private initialiserImpl(Application it) '''
        namespace «appNamespace»\Entity\Factory;

        use «appNamespace»\Entity\Factory\Base\AbstractEntityInitialiser;

        /**
         * Entity initialiser class used to dynamically apply default values to newly created entities.
         */
        class EntityInitialiser extends AbstractEntityInitialiser
        {
            // feel free to customise the initialiser
        }
    '''
}
