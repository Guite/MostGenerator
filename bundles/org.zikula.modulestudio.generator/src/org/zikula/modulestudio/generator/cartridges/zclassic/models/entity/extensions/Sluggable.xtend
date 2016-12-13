package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.AbstractStringField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Sluggable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
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
        «IF it instanceof AbstractStringField && (it as AbstractStringField).sluggablePosition > 0 && entity.application.targets('1.3.x')» * @Gedmo\Sluggable(slugField="slug", position=«(it as AbstractStringField).sluggablePosition»)
        «ENDIF»
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
         «IF application.targets('1.3.x')»
         * @Gedmo\Slug(style="«slugStyle.slugStyleAsConstant»", separator="«slugSeparator»", unique=«slugUnique.displayBool», updatable=«slugUpdatable.displayBool»)
         «ELSE»
         * @Gedmo\Slug(fields={«FOR field : getSluggableFields SEPARATOR ', '»"«field.name.formatForCode»"«ENDFOR»}, updatable=«slugUpdatable.displayBool», unique=«slugUnique.displayBool», separator="«slugSeparator»", style="«slugStyle.slugStyleAsConstant»")
         «ENDIF»
         * @ORM\Column(type="string", length=«slugLength», unique=«slugUnique.displayBool»)
         «IF !application.targets('1.3.x')»
         * @Assert\NotBlank()
         * @Assert\Length(min="1", max="«slugLength»")
         «ENDIF»
         * @var string $slug
         */
        protected $slug;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «IF application.targets('1.3.x')»
            «fh.getterMethod(it, 'slug', 'string', false)»
        «ELSE»
            «fh.getterAndSetterMethods(it, 'slug', 'string', false, true, false, '', '')»
        «ENDIF»
    '''
}
