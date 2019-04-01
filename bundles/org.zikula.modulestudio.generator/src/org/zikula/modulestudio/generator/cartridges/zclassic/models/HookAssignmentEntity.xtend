package org.zikula.modulestudio.generator.cartridges.zclassic.models

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.ModuleStudioFactory
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.ExtensionManager
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class HookAssignmentEntity {

    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Entity entity
    ExtensionManager extMan
    Property thProp

    /**
     * Creates an entity class for storing hook object assignments.
     */
    def generate(Application it, IMostFileSystemAccess fsa) {
        createEntity
        'Generating hook assignments entity class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Entity/HookAssignmentEntity.php', entityBaseImpl, entityImpl)
        entities -= entity
    }

    def private createEntity(Application it) {
        val factory = ModuleStudioFactory.eINSTANCE
        entity = factory.createEntity => [
            name = 'hookAssignment'
            nameMultiple = 'hookAssignments'
        ]
        entity.fields += factory.createIntegerField => [
            name = 'id'
            length = 9
            primaryKey = true
            unique = true
        ]
        entity.fields += factory.createStringField => [
            name = 'subscriberOwner'
        ]
        entity.fields += factory.createStringField => [
            name = 'subscriberAreaId'
        ]
        entity.fields += factory.createIntegerField => [
            name = 'subscriberObjectId'
        ]
        entity.fields += factory.createArrayField => [
            name = 'subscriberUrl'
            mandatory = false
        ]
        entity.fields += factory.createStringField => [
            name = 'assignedEntity'
        ]
        entity.fields += factory.createStringField => [
            name = 'assignedId'
        ]
        entity.fields += factory.createDatetimeField => [
            name = 'updatedDate'
        ]

        entity.standardFields = false
        entities += entity
        extMan = new ExtensionManager(entity)
        thProp = new Property(it, extMan)
    }

    def private entityBaseImpl(Application it) '''
        namespace «appNamespace»\Entity\Base;

        use Doctrine\ORM\Mapping as ORM;
        use Gedmo\Mapping\Annotation as Gedmo;
        use Symfony\Component\Validator\Constraints as Assert;
        use Zikula\Core\Doctrine\EntityAccess;

        /**
         * Entity base class for hooked object assignments.
         *
         * The following annotation marks it as a mapped superclass so subclasses
         * inherit orm properties.
         *
         * @ORM\MappedSuperclass
         */
        abstract class AbstractHookAssignmentEntity extends EntityAccess
        {
            «FOR field : entity.getDerivedFields»«thProp.persistentProperty(field)»«ENDFOR»

            «FOR field : entity.getDerivedFields»«thProp.fieldAccessor(field)»«ENDFOR»
        }
    '''

    def private entityImpl(Application it) '''
        namespace «appNamespace»\Entity;

        use «appNamespace»\Entity\Base\AbstractHookAssignmentEntity;
        use Doctrine\ORM\Mapping as ORM;

        /**
         * Entity implementation class for hooked object assignments.
         *
         * @ORM\Entity()
         * @ORM\Table(name="«entity.fullEntityTableName»")
         */
        class HookAssignmentEntity extends AbstractHookAssignmentEntity
        {
            // feel free to add your own methods here
        }
    '''
}
