package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Tree extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
        * @Gedmo\Tree(type="«tree.literal.toLowerCase»")
        «IF tree == EntityTreeType.CLOSURE»
             * @Gedmo\TreeClosure(class="\«entityClassName('closure', false)»")
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
         * @Gedmo\TreeLeft
         * @ORM\Column(type="integer")
         * @Assert\Type(type="integer")
         * @var integer $lft
         */
        protected $lft;

        /**
         * @Gedmo\TreeLevel
         * @ORM\Column(type="integer")
         * @Assert\Type(type="integer")
         * @var integer $lvl
         */
        protected $lvl;

        /**
         * @Gedmo\TreeRight
         * @ORM\Column(type="integer")
         * @Assert\Type(type="integer")
         * @var integer $rgt
         */
        protected $rgt;

        /**
         * @Gedmo\TreeRoot
         * @ORM\Column(type="integer", nullable=true)
         * @var integer $root
         */
        protected $root;

        /**
         * Bidirectional - Many children [«name.formatForDisplay»] are linked by one parent [«name.formatForDisplay»] (OWNING SIDE).
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @Gedmo\TreeParent
         * @ORM\ManyToOne(targetEntity="\«entityClassName('', false)»", inversedBy="children")
         * @ORM\JoinColumn(name="parent_id", referencedColumnName="«getPrimaryKey.name.formatForDisplay»", onDelete="SET NULL")
         * @var \«entityClassName('', false)» $parent
         */
        protected $parent;

        /**
         * Bidirectional - One parent [«name.formatForDisplay»] has many children [«name.formatForDisplay»] (INVERSE SIDE).
         *
         * @ORM\OneToMany(targetEntity="\«entityClassName('', false)»", mappedBy="parent")
         * @ORM\OrderBy({"lft" = "ASC"})
         * @var \«entityClassName('', false)» $children
         */
        protected $children;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterAndSetterMethods(it, 'lft', 'integer', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'lvl', 'integer', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'rgt', 'integer', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'root', 'integer', false, true, false, '', '')»
        «fh.getterAndSetterMethods(it, 'parent', '\\' + entityClassName('', false), false, true, true, 'null', '')»
        «fh.getterAndSetterMethods(it, 'children', 'array', true, true, false, '', '')»
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
        use Gedmo\Tree\Entity\MappedSuperclass\«extensionBaseClass»;
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
