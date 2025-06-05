package org.zikula.modulestudio.generator.cartridges.symfony.models

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.Utils

class UuidStringGenerator {

    extension Utils = new Utils

    /**
     * Creates a custom Doctrine id generator using string representation of UUIDs.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating Doctrine id generator class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/Doctrine/UuidStringGenerator.php', idGeneratorBaseImpl, idGeneratorImpl)
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Doctrine\\ORM\\EntityManagerInterface',
            'Doctrine\\ORM\\Id\\AbstractIdGenerator',
            'Symfony\\Component\\Uid\\Uuid'
        ])
        imports
    }

    def private idGeneratorBaseImpl(Application it) '''
        namespace «appNamespace»\Helper\Doctrine\Base;

        «collectBaseImports.print»

        /**
         * Doctrine id generator using string representation of UUIDs.
         */
        abstract class AbstractUuidStringGenerator extends AbstractIdGenerator
        {
            public function generateId(EntityManagerInterface $em, $entity): string
            {
                $idField = $em->getClassMetadata($entity::class)->getSingleIdentifierFieldName();

                $idGetter = 'get' . ucfirst($idField);
                if (method_exists($entity, $idGetter)) {
                    return ($entity->$idGetter() ?? Uuid::v4())->toRfc4122();
                }

                return Uuid::v4()->toRfc4122();
            }
        }
    '''

    def private idGeneratorImpl(Application it) '''
        namespace «appNamespace»\Helper\Doctrine;

        use «appNamespace»\Helper\Doctrine\Base\AbstractUuidStringGenerator;

        /**
         * Doctrine id generator using string representation of UUIDs.
         */
        class UuidStringGenerator extends AbstractUuidStringGenerator
        {
            // feel free to customise the id generator
        }
    '''
}
