package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Categories extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions

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
         * @ORM\OneToMany(targetEntity=«name.formatForCodeCapital»CategoryEntity::class,
         *                mappedBy="entity", cascade={"all"},
         *                orphanRemoval=true«/*commented out as this causes only one category to be selected (#349)   , indexBy="categoryRegistryId"*/»)
         * @var Collection<int, «name.formatForCodeCapital»CategoryEntity>
         */
        protected ?Collection $categories = null;

    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «(new FileHelper(application)).getterMethod(it, 'categories', 'Collection<int, ' + name.formatForCodeCapital + 'CategoryEntity>', true)»

        /**
         * @param Collection<int, «name.formatForCodeCapital»CategoryEntity> $categories
         */
        public function setCategories(Collection $categories): void
        {
            foreach ($this->categories as $category) {
                if (false === ($key = $this->categoryCollectionContains($categories, $category))) {
                    $this->categories->removeElement($category);
                } else {
                    $categories->remove($key);
                }
            }
            foreach ($categories as $category) {
                $this->categories->add($category);
            }
        }

        /**
         * Checks if a collection contains an element based only on two criteria (categoryRegistryId, category).
         *
         * @param Collection<int, «name.formatForCodeCapital»CategoryEntity> $collection
         */
        private function categoryCollectionContains(Collection $collection, «name.formatForCodeCapital»CategoryEntity $element): bool|int
        {
            foreach ($collection as $key => $category) {
                if (
                    $category->getCategoryRegistryId() === $element->getCategoryRegistryId()
                    && $category->getCategory() === $element->getCategory()
                ) {
                    return $key;
                }
            }

            return false;
        }
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
        use Zikula\CategoriesModule\Entity\«extensionBaseClass»;
        use «entityClassName('', false)»;
        use «repositoryClass(extensionClassType)»;
    '''

    /**
     * Returns the extension base class.
     */
    override extensionBaseClass(Entity it) {
        'AbstractCategoryAssignment'
    }

    /**
     * Returns the extension class description.
     */
    override extensionClassDescription(Entity it) {
        'Entity extension domain class storing ' + name.formatForDisplay + ' categories.'
    }

    /**
     * Returns the extension base class implementation.
     */
    override extensionClassBaseImplementation(Entity it) '''
        /**
         * @ORM\ManyToOne(targetEntity=«name.formatForCodeCapital»Entity::class, inversedBy="categories")
         * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKey.name.formatForCode»")
         */
        protected «name.formatForCodeCapital»Entity $entity;
        «extensionClassEntityAccessors»
    '''

    /**
     * Returns the extension implementation class ORM annotations.
     */
    override extensionClassImplAnnotations(Entity it) '''
         «' '»* @ORM\Entity(repositoryClass=«name.formatForCodeCapital»«extensionClassType.formatForCodeCapital»Repository::class)
         «' '»* @ORM\Table(name="«fullEntityTableName»_category",
         «' '»*     uniqueConstraints={
         «' '»*         @ORM\UniqueConstraint(name="cat_unq", columns={"registryId", "categoryId", "entityId"})
         «' '»*     }
         «' '»* )
    '''
}
