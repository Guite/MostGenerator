package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper

class StandardFields extends AbstractExtension implements EntityExtensionInterface {

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

        /**
         * @ORM\Column(type="integer")
         * @ZK\StandardFields(type="userid", on="create")
         * @var integer $createdUserId.
         */
        protected $createdUserId;

        /**
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @ORM\Column(type="integer")
         * @ZK\StandardFields(type="userid", on="update")
         * @var integer $updatedUserId.
         */
        protected $updatedUserId;

        /**
         * @ORM\Column(type="datetime")
         * @Gedmo\Timestampable(on="create")
         * @var datetime $createdDate.
         */
        protected $createdDate;

        /**
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @ORM\Column(type="datetime")
         * @Gedmo\Timestampable(on="update")
         * @var datetime $updatedDate.
         */
        protected $updatedDate;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'createdUserId', 'integer', false, false, '', '')»
        «fh.getterAndSetterMethods(it, 'updatedUserId', 'integer', false, false, '', '')»
        «fh.getterAndSetterMethods(it, 'createdDate', 'datetime', false, false, '', '')»
        «fh.getterAndSetterMethods(it, 'updatedDate', 'datetime', false, false, '', '')»
    '''
}
