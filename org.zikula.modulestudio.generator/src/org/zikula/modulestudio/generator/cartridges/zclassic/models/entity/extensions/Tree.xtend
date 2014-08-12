package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTreeType
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Tree extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
        «' '»* @Gedmo\Tree(type="«tree.literal.toLowerCase»")
        «IF tree == EntityTreeType.CLOSURE»
             «' '»* @Gedmo\TreeClosure(class="«IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('closure', false)»")
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
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @Gedmo\TreeLeft
         * @ORM\Column(type="integer")
         «IF !application.targets('1.3.5')»
         * @Assert\Type(type="integer")
         «ENDIF»
         * @var integer $lft.
         */
        protected $lft;

        /**
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @Gedmo\TreeLevel
         * @ORM\Column(type="integer")
         «IF !application.targets('1.3.5')»
         * @Assert\Type(type="integer")
         «ENDIF»
         * @var integer $lvl.
         */
        protected $lvl;

        /**
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @Gedmo\TreeRight
         * @ORM\Column(type="integer")
         «IF !application.targets('1.3.5')»
         * @Assert\Type(type="integer")
         «ENDIF»
         * @var integer $rgt.
         */
        protected $rgt;

        /**
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @Gedmo\TreeRoot
         * @ORM\Column(type="integer", nullable=true)
         * @var integer $root.
         */
        protected $root;

        /**
         * Bidirectional - Many children [«name.formatForDisplay»] are linked by one parent [«name.formatForDisplay»] (OWNING SIDE).
         *
         * @Gedmo\TreeParent
         * @ORM\ManyToOne(targetEntity="«IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", inversedBy="children")
         * @ORM\JoinColumn(name="parent_id", referencedColumnName="«getPrimaryKeyFields.head.name.formatForDisplay»", onDelete="SET NULL")
         * @var «IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)» $parent.
         */
        protected $parent;

        /**
         * Bidirectional - One parent [«name.formatForDisplay»] has many children [«name.formatForDisplay»] (INVERSE SIDE).
         *
         * @ORM\OneToMany(targetEntity="«IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)»", mappedBy="parent")
         * @ORM\OrderBy({"lft" = "ASC"})
         * @var «IF !application.targets('1.3.5')»\«ENDIF»«entityClassName('', false)» $children.
         */
        protected $children;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'lft', 'integer', false, false, '', '')»
        «fh.getterAndSetterMethods(it, 'lvl', 'integer', false, false, '', '')»
        «fh.getterAndSetterMethods(it, 'rgt', 'integer', false, false, '', '')»
        «fh.getterAndSetterMethods(it, 'root', 'integer', false, false, '', '')»
        «fh.getterAndSetterMethods(it, 'parent', (if (!application.targets('1.3.5')) '\\' else '') + entityClassName('', false), false, true, 'null', '')»
        «fh.getterAndSetterMethods(it, 'children', 'array', true, false, '', '')»
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        if (tree == EntityTreeType.CLOSURE) {
            'closure'
        } else {
            ''
        }
    }

    /**
     * Returns the extension class import statements.
     */
    override extensionClassImports(Entity it) '''
        use Gedmo\Tree\Entity\«IF !application.targets('1.3.5')»MappedSuperclass\«ENDIF»«extensionBaseClass»;
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        'AbstractClosure'
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        'Entity extension domain class storing ' + name.formatForDisplay + ' tree closures.'
    }
}
