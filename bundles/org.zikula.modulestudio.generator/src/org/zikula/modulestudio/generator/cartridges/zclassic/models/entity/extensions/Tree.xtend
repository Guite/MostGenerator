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
        #[Gedmo\Tree(type: '«tree.literal.toLowerCase»')]
        «IF tree == EntityTreeType.CLOSURE»
             #[Gedmo\TreeClosure(class: «name.formatForCodeCapital»Closure::class)]
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
        #[ORM\Column]
        #[Gedmo\TreeLeft]
        protected int $lft;

        #[ORM\Column]
        #[Gedmo\TreeLevel]
        protected int $lvl;

        #[ORM\Column]
        #[Gedmo\TreeRight]
        protected int $rgt;

        #[ORM\Column(nullable: true)]
        #[Gedmo\TreeRoot]
        protected int $root;

        /**
         * Bidirectional - Many children [«name.formatForDisplay»] are linked by one parent [«name.formatForDisplay»] (OWNING SIDE).
         */
        #[ORM\ManyToOne(targetEntity: «name.formatForCodeCapital»::class, inversedBy: 'children')]
        #[ORM\JoinColumn(name: 'parent_id', referencedColumnName: '«getPrimaryKey.name.formatForDisplay»', onDelete: 'SET NULL')]
        #[Gedmo\TreeParent]
        «IF loggable»
            #[Gedmo\Versioned]
        «ENDIF»
        protected ?self $parent = null;

        /**
         * Bidirectional - One parent [«name.formatForDisplay»] has many children [«name.formatForDisplay»] (INVERSE SIDE).
         */
        #[ORM\OneToMany(targetEntity: «name.formatForCodeCapital»::class, mappedBy: 'parent')]
        #[ORM\OrderBy(['lft' => 'ASC'])]
        /**
         * @var Collection<int, «name.formatForCodeCapital»>
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
        «fh.getterAndSetterMethods(it, 'parent', name.formatForCodeCapital, true, 'null', '')»
        «fh.getterAndSetterMethods(it, 'children', 'Collection<int, ' + name.formatForCodeCapital + '>', true, '', '')»
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
