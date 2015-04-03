package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Categories extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
    '''

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''

        /**
         * @ORM\OneToMany(targetEntity="«IF !application.targets('1.3.x')»\«ENDIF»«entityClassName('category', false)»", 
         *                mappedBy="entity", cascade={"all"}, 
         *                orphanRemoval=true«/*commented out as this causes only one category to be selected (#349)   , indexBy="categoryRegistryId"*/»)
         * @var «IF !application.targets('1.3.x')»\«ENDIF»«entityClassName('category', false)»
         */
        protected $categories = null;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'categories', 'array', true, false, '', '')»
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        'category'
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) '''
        use Doctrine\ORM\Mapping as ORM;
        «IF !application.targets('1.3.x')»
            use Zikula\Core\Doctrine\Entity\«extensionBaseClass»;
        «ENDIF»
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        if (application.targets('1.3.x')) {
            'Zikula_Doctrine2_Entity_Entity' + extensionClassType.toFirstUpper
        } else {
            'AbstractEntity' + extensionClassType.toFirstUpper
        }
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        'Entity extension domain class storing ' + name.formatForDisplay + ' categories.'
    }

    /**
     * Returns the extension base class ORM annotations.
     */
    override extensionClassBaseAnnotations(Entity it) '''
        /**
         * @ORM\ManyToOne(targetEntity="«IF !application.targets('1.3.x')»\«ENDIF»«entityClassName('', false)»", inversedBy="categories")
         * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKeyFields.head.name.formatForCode»")
         * @var «IF !application.targets('1.3.x')»\«ENDIF»«entityClassName('', false)»
         */
        protected $entity;

        «extensionClassEntityAccessors»
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»* @ORM\Entity(repositoryClass="«IF !application.targets('1.3.x')»\«ENDIF»«repositoryClass(extensionClassType)»")
         «' '»* @ORM\Table(name="«fullEntityTableName»_category",
         «' '»*     uniqueConstraints={
         «' '»*         @ORM\UniqueConstraint(name="cat_unq", columns={"registryId", "categoryId", "entityId"})
         «' '»*     }
         «' '»* )
    '''
}
