package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Attributes extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

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
         * @ORM\OneToMany(targetEntity="«name.formatForCodeCapital»AttributeEntity::class",
         *                mappedBy="entity", cascade={"all"},
         *                orphanRemoval=true, indexBy="name")
         * @var Collection<string, «name.formatForCodeCapital»AttributeEntity>
         */
        protected ?Collection $attributes = null;

    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «(new FileHelper(application)).getterMethod(it, 'attributes', 'Collection<string, ' + name.formatForCodeCapital + 'AttributeEntity>', true)»
        public function setAttribute(string $name, string $value): void
        {
            if (isset($this->attributes[$name])) {
                if (null === $value) {
                    $this->attributes->remove($name);
                } else {
                    $this->attributes[$name]->setValue($value);
                }
            } else {
                $this->attributes[$name] = new «name.formatForCodeCapital»AttributeEntity($name, $value, $this);
            }
        }

    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        'attribute'
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) '''
        use Doctrine\ORM\Mapping as ORM;
        use Zikula\Bundle\CoreBundle\Doctrine\Entity\«extensionBaseClass»;
        use «entityClassName('', false)»;
        use «repositoryClass(extensionClassType)»;
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        'AbstractEntity' + extensionClassType.toFirstUpper
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        'Entity extension domain class storing ' + name.formatForDisplay + ' attributes.'
    }

    /**
     * Returns the extension base class implementation.
     */
    override extensionClassBaseImplementation(Entity it) '''
        /**
         * @ORM\ManyToOne(targetEntity="«name.formatForCodeCapital»Entity::class", inversedBy="attributes")
         * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKey.name.formatForCode»")
         */
        protected «name.formatForCodeCapital»Entity $entity;
        «extensionClassEntityAccessors»
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»* @ORM\Entity(repositoryClass="«name.formatForCodeCapital»«extensionClassType.formatForCodeCapital»Repository::class")
         «' '»* @ORM\Table(name="«fullEntityTableName»_attribute",
         «' '»*     uniqueConstraints={
         «' '»*         @ORM\UniqueConstraint(name="cat_unq", columns={"name", "entityId"})
         «' '»*     }
         «' '»* )
    '''
}
