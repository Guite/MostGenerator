package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.Utils

class Geographical extends AbstractExtension implements EntityExtensionInterface {

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

        /**
         * The coordinate's latitude part.
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @ORM\Column(type="decimal", precision=10, scale=7)
         «IF !application.targets('1.3.5')»
         * @Assert\Type(type="float")
         «ENDIF»
         * @var decimal $latitude.
         */
        protected $latitude = 0.00;

        /**
         * The coordinate's longitude part.
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @ORM\Column(type="decimal", precision=10, scale=7)
         «IF !application.targets('1.3.5')»
         * @Assert\Type(type="float")
         «ENDIF»
         * @var decimal $longitude.
         */
        protected $longitude = 0.00;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'latitude', 'decimal', false, false, '', '')»
        «fh.getterAndSetterMethods(it, 'longitude', 'decimal', false, false, '', '')»
    '''
}
