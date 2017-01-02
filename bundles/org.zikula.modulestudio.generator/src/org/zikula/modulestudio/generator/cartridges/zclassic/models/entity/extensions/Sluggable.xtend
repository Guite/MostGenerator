package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions

class Sluggable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

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
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         «IF hasTranslatableSlug»
             * @Gedmo\Translatable
         «ENDIF»
         * @Gedmo\Slug(fields={«FOR field : getSluggableFields SEPARATOR ', '»"«field.name.formatForCode»"«ENDFOR»}, updatable=«slugUpdatable.displayBool», unique=«slugUnique.displayBool», separator="«slugSeparator»", style="«slugStyle.slugStyleAsConstant»")
         * @ORM\Column(type="string", length=«slugLength», unique=«slugUnique.displayBool»)
         * @Assert\NotBlank()
         * @Assert\Length(min="1", max="«slugLength»")
         * @var string $slug
         */
        protected $slug;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'slug', 'string', false, true, false, '', '')»
    '''
}
