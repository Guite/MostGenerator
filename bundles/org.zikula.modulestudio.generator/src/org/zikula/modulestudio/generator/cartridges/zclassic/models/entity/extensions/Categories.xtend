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
         * @ORM\OneToMany(targetEntity="\«entityClassName('category', false)»", 
         *                mappedBy="entity", cascade={"all"}, 
         *                orphanRemoval=true«/*commented out as this causes only one category to be selected (#349)   , indexBy="categoryRegistryId"*/»)
         * @var \«entityClassName('category', false)»
         */
        protected $categories = null;
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
        «val fh = new FileHelper»
        «fh.getterMethod(it, 'categories', 'ArrayCollection', true)»

        /**
         * Sets the categories.
         *
         * @param ArrayCollection $categories
         *
         * @return void
         */
        public function setCategories(ArrayCollection $categories)
        {
            foreach ($this->categories as $category) {
                if (false === $key = $this->collectionContains($categories, $category)) {
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
         * @param ArrayCollection $collection
         * @param \«entityClassName('category', false)» $element
         *
         * @return bool|int
         */
        private function collectionContains(ArrayCollection $collection, \«entityClassName('category', false)» $element)
        {
            foreach ($collection as $key => $category) {
                /** @var \«entityClassName('category', false)» $category */
                if ($category->getCategoryRegistryId() == $element->getCategoryRegistryId()
                    && $category->getCategory() == $element->getCategory()
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
     * Returns the extension base class ORM annotations.
     */
    override extensionClassBaseAnnotations(Entity it) '''
        /**
         * @ORM\ManyToOne(targetEntity="\«entityClassName('', false)»", inversedBy="categories")
         * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKey.name.formatForCode»")
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
         «' '»* @ORM\Table(name="«fullEntityTableName»_category",
         «' '»*     uniqueConstraints={
         «' '»*         @ORM\UniqueConstraint(name="cat_unq", columns={"registryId", "categoryId", "entityId"})
         «' '»*     }
         «' '»* )
    '''
}
