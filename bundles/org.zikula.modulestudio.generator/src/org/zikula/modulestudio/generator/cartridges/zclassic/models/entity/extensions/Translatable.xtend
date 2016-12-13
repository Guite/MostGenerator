package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Translatable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
         «' '»* @Gedmo\TranslationEntity(class="«IF !application.targets('1.3.x')»\«ENDIF»«entityClassName('translation', false)»")
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
         * Field for storing the locale of this entity.
         * Overrides the locale set in translationListener (as pointed out in https://github.com/l3pp4rd/DoctrineExtensions/issues/130#issuecomment-1790206 ).
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         «IF !application.targets('1.3.x')»
             * Assert\Locale()
         «ENDIF»
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
        «fh.getterAndSetterMethods(it, 'locale', 'string', true, false, false, '', '')»
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
        use Gedmo\Translatable\Entity\«extensionBaseClass»;
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        if (application.targets('1.3.x')) 'AbstractTranslation' else 'Translation'
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
         «' '»* @ORM\Table(name="«fullEntityTableName»_translation",
         «' '»*     indexes={
         «' '»*         @ORM\Index(name="translations_lookup_idx", columns={
         «' '»*             "locale", "object_class", "foreign_key"
         «' '»*         })
         «' '»*     }«/*,commented out because the length of these four fields * 3 is more than 1000 bytes with UTF-8 (requiring 3 bytes per char)
         «' '»*     uniqueConstraints={
         «' '»*         @ORM\UniqueConstraint(name="lookup_unique_idx", columns={
         «' '»*             "locale", "object_class", "field", "foreign_key"
         «' '»*         })
         «' '»*     }*/»
         «' '»* )
    '''
}
