package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Translatable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
         * @Gedmo\TranslationEntity(class="«entityClassName('translation', false)»")
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
        «IF translatable» * @Gedmo\Translatable
        «ENDIF»
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''

        /**
         * Used locale to override Translation listener's locale.
         * this is not a mapped field of entity metadata, just a simple property.
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @Assert\Locale()
         * @Gedmo\Locale«/*the same as @Gedmo\Language*/»
         * @var string $locale
         */
        protected $locale;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'locale', 'string', false, true, false, '', '')»
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        'translation'
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) '''
        use Gedmo\Translatable\Entity\MappedSuperclass\«extensionBaseClass»;
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        'AbstractTranslation'
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        'Entity extension domain class storing ' + name.formatForDisplay + ' translations.'
    }

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»*
         «' '»* @ORM\Entity(repositoryClass="«repositoryClass(extensionClassType)»")
         «' '»* @ORM\Table(
         «' '»*     name="«fullEntityTableName»_translation",
         «' '»*     options={"row_format":"DYNAMIC"},
         «' '»*     indexes={
         «' '»*         @ORM\Index(name="translations_lookup_idx", columns={
         «' '»*             "locale", "object_class", "foreign_key"
         «' '»*         })
         «' '»*     },
         «' '»*     uniqueConstraints={
         «' '»*         @ORM\UniqueConstraint(name="lookup_unique_idx", columns={
         «' '»*             "locale", "object_class", "field", "foreign_key"
         «' '»*         })
         «' '»*     }
         «' '»* )
    '''
}
