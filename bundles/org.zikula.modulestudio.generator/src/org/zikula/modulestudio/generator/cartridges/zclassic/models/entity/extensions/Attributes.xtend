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
         * @ORM\OneToMany(targetEntity="\«entityClassName('attribute', false)»", 
         *                mappedBy="entity", cascade={"all"}, 
         *                orphanRemoval=true, indexBy="name")
         * @var \«entityClassName('attribute', false)»
         */
        protected $attributes = null;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterMethod(it, 'attributes', 'array', true)»
        /**
         * Set attribute.
         *
         * @param string $name  Attribute name
         * @param string $value Attribute value
         *
         * @return void
         */
        public function setAttribute($name, $value)
        {
            if (isset($this->attributes[$name])) {
                if (null === $value) {
                    $this->attributes->remove($name);
                } else {
                    $this->attributes[$name]->setValue($value);
                }
            } else {
                $this->attributes[$name] = new \«entityClassName('attribute', false)»($name, $value, $this);
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
        use Zikula\Core\Doctrine\Entity\«extensionBaseClass»;
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
     * Returns the extension base class ORM annotations.
     */
    override extensionClassBaseAnnotations(Entity it) '''
        /**
         * @ORM\ManyToOne(targetEntity="\«entityClassName('', false)»", inversedBy="attributes")
         * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKeyFields.head.name.formatForCode»")
         * @var \«entityClassName('', false)»
         */
        protected $entity;

        «extensionClassEntityAccessors»
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»* @ORM\Entity(repositoryClass="\«repositoryClass(extensionClassType)»")
         «' '»* @ORM\Table(name="«fullEntityTableName»_attribute",
         «' '»*     uniqueConstraints={
         «' '»*         @ORM\UniqueConstraint(name="cat_unq", columns={"name", "entityId"})
         «' '»*     }
         «' '»* )
    '''
}
