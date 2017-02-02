package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper

class SoftDeleteable extends AbstractExtension implements EntityExtensionInterface {

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
        * @Gedmo\SoftDeleteable(fieldName="deletedAt")
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
         * Date of when this item has been marked as deleted.
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @ORM\Column(type="datetime", nullable=true)
         * @Assert\DateTime()
         * @var \DateTime $deletedAt
         */
        protected $deletedAt;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'deletedAt', 'datetime', false, true, false, '', '')»
    '''
}
