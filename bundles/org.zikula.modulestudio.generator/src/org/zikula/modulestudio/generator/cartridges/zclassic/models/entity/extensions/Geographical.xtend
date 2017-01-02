package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper

class Geographical extends AbstractExtension implements EntityExtensionInterface {

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
         * The coordinate's latitude part.
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @ORM\Column(type="decimal", precision=12, scale=7)
         * @Assert\Type(type="float")
         * @var decimal $latitude
         */
        protected $latitude = 0.00;

        /**
         * The coordinate's longitude part.
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @ORM\Column(type="decimal", precision=12, scale=7)
         * @Assert\Type(type="float")
         * @var decimal $longitude
         */
        protected $longitude = 0.00;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'latitude', 'decimal', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'longitude', 'decimal', false, true, false, '', '')»
    '''
}
