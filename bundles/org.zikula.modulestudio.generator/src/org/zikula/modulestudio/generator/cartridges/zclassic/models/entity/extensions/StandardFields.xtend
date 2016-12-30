package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.Utils

class StandardFields extends AbstractExtension implements EntityExtensionInterface {

    extension Utils = new Utils

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''
        «IF application.targets('1.3.x')»

            /**
             * @ORM\Column(type="integer")
             * @ZK\StandardFields(type="userid", on="create")
             * @var integer $createdUserId
             */
            protected $createdUserId;

            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @ORM\Column(type="integer")
             * @ZK\StandardFields(type="userid", on="update")
             * @var integer $updatedUserId
             */
            protected $updatedUserId;

            /**
             * @ORM\Column(type="datetime")
             * @Gedmo\Timestampable(on="create")
             «IF !application.targets('1.3.x')»
             * @Assert\DateTime()
             «ENDIF»
             * @var \DateTime $createdDate
             */
            protected $createdDate;

            /**
             «IF loggable»
                 * @Gedmo\Versioned
             «ENDIF»
             * @ORM\Column(type="datetime")
             * @Gedmo\Timestampable(on="update")
             «IF !application.targets('1.3.x')»
             * @Assert\DateTime()
             «ENDIF»
             * @var \DateTime $updatedDate
             */
            protected $updatedDate;
        «ENDIF»
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «IF application.targets('1.3.x')»
            «val fh = new FileHelper»
            «fh.getterAndSetterMethods(it, 'createdUserId', 'integer', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'updatedUserId', 'integer', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'createdDate', 'datetime', false, true, false, '', '')»
            «fh.getterAndSetterMethods(it, 'updatedDate', 'datetime', false, true, false, '', '')»
        «ENDIF»
    '''
}
