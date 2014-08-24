package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Attributes extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
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
         * @ORM\OneToMany(targetEntity="«IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('attribute', false)»", 
         *                mappedBy="entity", cascade={"all"}, 
         *                orphanRemoval=true, indexBy="name")
         * @var «IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('attribute', false)»
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
         * @param string $name.
         * @param string $value.
         *
         * @return void
         */
        public function setAttribute($name, $value)
        {
            if(isset($this->attributes[$name])) {
                if($value == null) {
                    $this->attributes->remove($name);
                } else {
                    $this->attributes[$name]->setValue($value);
                }
            } else {
                $this->attributes[$name] = new «IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('attribute', false)»($name, $value, $this);
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
        «IF !application.targets('1.3.5')»
            use Zikula\Core\Doctrine\Entity\«extensionBaseClass»;
        «ENDIF»
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        if (application.targets('1.3.5')) {
            'Zikula_Doctrine2_Entity_Entity' + extensionClassType.toFirstUpper
        } else {
            'AbstractEntity' + extensionClassType.toFirstUpper
        }
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
         * @ORM\ManyToOne(targetEntity="«IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", inversedBy="attributes")
         * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKeyFields.head.name.formatForCode»")
         * @var «IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»
         */
        protected $entity;

        «extensionClassEntityAccessors»
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»* @ORM\Entity(repositoryClass="«IF !application.targets('1.3.5')»\«ENDIF»«repositoryClass(extensionClassType)»")
         «' '»* @ORM\Table(name="«fullEntityTableName»_attribute",
         «' '»*     uniqueConstraints={
         «' '»*         @ORM\UniqueConstraint(name="cat_unq", columns={"name", "entityId"})
         «' '»*     }
         «' '»* )
    '''
}
