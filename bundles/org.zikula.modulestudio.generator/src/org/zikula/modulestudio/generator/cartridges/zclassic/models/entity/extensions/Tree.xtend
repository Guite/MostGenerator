package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class Tree extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
        * @Gedmo\Tree(type="«tree.literal.toLowerCase»")
        «IF tree == EntityTreeType.CLOSURE»
             * @Gedmo\TreeClosure(class=«name.formatForCodeCapital»ClosureEntity::class)
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
         */
        protected int $lft;

        /**
         * @Gedmo\TreeLevel
         * @ORM\Column(type="integer")
         */
        protected int $lvl;

        /**
         * @Gedmo\TreeRight
         * @ORM\Column(type="integer")
         */
        protected int $rgt;

        /**
         * @Gedmo\TreeRoot
         * @ORM\Column(type="integer", nullable=true)
         */
        protected int $root;

        /**
         * Bidirectional - Many children [«name.formatForDisplay»] are linked by one parent [«name.formatForDisplay»] (OWNING SIDE).
         *
         «IF loggable»
             * @Gedmo\Versioned
         «ENDIF»
         * @Gedmo\TreeParent
         * @ORM\ManyToOne(targetEntity=«name.formatForCodeCapital»Entity::class, inversedBy="children")
         * @ORM\JoinColumn(name="parent_id", referencedColumnName="«getPrimaryKey.name.formatForDisplay»", onDelete="SET NULL")
         */
        protected ?self $parent = null;

        /**
         * Bidirectional - One parent [«name.formatForDisplay»] has many children [«name.formatForDisplay»] (INVERSE SIDE).
         *
         * @ORM\OneToMany(targetEntity=«name.formatForCodeCapital»Entity::class, mappedBy="parent")
         * @ORM\OrderBy({"lft" = "ASC"})
         * @var Collection<int, «name.formatForCodeCapital»Entity>
         */
        protected ?Collection $children = null;

    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper(application)»
        «fh.getterAndSetterMethods(it, 'lft', 'int', false, '', '')»
        «fh.getterAndSetterMethods(it, 'lvl', 'int', false, '', '')»
        «fh.getterAndSetterMethods(it, 'rgt', 'int', false, '', '')»
        «fh.getterAndSetterMethods(it, 'root', 'int', false, '', '')»
        «fh.getterAndSetterMethods(it, 'parent', name.formatForCodeCapital + 'Entity', true, 'null', '')»
        «fh.getterAndSetterMethods(it, 'children', 'Collection<int, ' + name.formatForCodeCapital + 'Entity>', true, '', '')»
    '''

    /**
     * Returns the extension class type.
     */
    override extensionClassType(Entity it) {
        if (EntityTreeType.CLOSURE === tree) {
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
