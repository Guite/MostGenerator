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
        «val fh = new FileHelper(application)»
        «IF application.targets('3.0')»
            «fh.getterMethod(it, 'categories', 'Collection', true, true, true)»
        «ELSE»
            «fh.getterMethod(it, 'categories', 'Collection', true, true, false)»
        «ENDIF»

        /**
         * Sets the categories.
         «IF !application.targets('3.0')»
         *
         * @return void
         «ENDIF»
         */
        public function setCategories(Collection $categories)«IF application.targets('3.0')»: void«ENDIF»
        {
            foreach ($this->categories as $category) {
                if (false === ($key = $this->collectionContains($categories, $category))) {
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
         «IF !application.targets('3.0')»
         *
         * @param Collection $collection Given collection
         * @param \«entityClassName('category', false)» $element Element to search for
         «ENDIF»
         *
         * @return bool|int
         */
        private function collectionContains(Collection $collection, \«entityClassName('category', false)» $element)
        {
            foreach ($collection as $key => $category) {
                /** @var \«entityClassName('category', false)» $category */
                if ($category->getCategoryRegistryId() === $element->getCategoryRegistryId()
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
         * @ORM\ManyToOne(targetEntity="\«entityClassName('', false)»", inversedBy="categories")
         * @ORM\JoinColumn(name="entityId", referencedColumnName="«getPrimaryKey.name.formatForCode»")
         * @var «name.formatForCodeCapital»Entity
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
