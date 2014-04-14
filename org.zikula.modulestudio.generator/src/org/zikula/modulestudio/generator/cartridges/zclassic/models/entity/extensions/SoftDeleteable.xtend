package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.Utils

class SoftDeleteable extends AbstractExtension implements EntityExtensionInterface {

    @Inject extension Utils = new Utils

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
         «IF !container.application.targets('1.3.5')»
            «' '»* @Gedmo\SoftDeleteable(fieldName="deletedAt")
         «ENDIF»
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
         * @var datetime $deletedAt.
         */
        protected $deletedAt;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'deletedAt', 'datetime', false, false, '', '')»
    '''
}
