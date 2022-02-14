package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class Translatable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
         * @Gedmo\TranslationEntity(class=«name.formatForCodeCapital»TranslationEntity::class)
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
         * This is not a mapped field of entity metadata, just a simple property.
         *
         * @Gedmo\Locale«/*the same as @Gedmo\Language*/»
         */
        #[Assert\Locale]
        protected string $locale = '';

    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «(new FileHelper(application)).getterAndSetterMethods(it, 'locale', 'string', true, '', '')»
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
        use Doctrine\ORM\Mapping as ORM;
        use Gedmo\Translatable\Entity\MappedSuperclass\«extensionBaseClass»;
        use «repositoryClass(extensionClassType)»;
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
     * Returns the extension base class implementation.
     */
    override extensionClassBaseImplementation(Entity it) '''
        /**
         * Use a length of 140 instead of 255 to avoid too long keys for the indexes.
         *
         * @ORM\Column(name="object_class", type="string", length=140)
         */
        protected «/* no type allowed because we override a parent field */»$objectClass;

        «IF primaryKey instanceof AbstractIntegerField»
            /**
             * Use integer instead of string for increased performance.
             *
             * @see https://github.com/Atlantic18/DoctrineExtensions/issues/1512
             *
             * @ORM\Column(name="foreign_key", type="integer")
             */
            protected «/* no type allowed because we override a parent field */»$foreignKey;

        «ENDIF»
        /**
         * Clone interceptor implementation.
         * Performs a quite simple shallow copy.
         *
         * See also:
         * (1) http://docs.doctrine-project.org/en/latest/cookbook/implementing-wakeup-or-clone.html
         * (2) http://www.php.net/manual/en/language.oop5.cloning.php
         * (3) http://stackoverflow.com/questions/185934/how-do-i-create-a-copy-of-an-object-in-php
         */
        public function __clone()
        {
            // if the entity has no identity do nothing, do NOT throw an exception
            if (!$this->id) {
                return;
            }

            // unset identifier
            $this->id = 0;
        }
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»* @ORM\Entity(repositoryClass=«name.formatForCodeCapital»«extensionClassType.formatForCodeCapital»Repository::class)
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

    /**
     * Returns the extension repository interface base implementation.
     */
    override extensionRepositoryInterfaceBaseImplementation(Entity it) '''
        public function translate($entity, $field, $locale, $value);

        public function findTranslations($entity);

        public function findObjectByTranslatedField($field, $value, $class);

        public function findTranslationsByObjectId($id);
    '''
}
