package org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions

import de.guite.modulestudio.metamodel.AbstractIntegerField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity

class Sortable extends AbstractExtension implements EntityExtensionInterface {

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
        «IF sortableGroup»
            #[Gedmo\SortableGroup]
        «ENDIF»
        «IF it instanceof AbstractIntegerField && (it as AbstractIntegerField).sortablePosition»
            #[Gedmo\SortablePosition]
        «ENDIF»
    '''

    /**
     * Generates additional entity properties.
     */
    override properties(Entity it) '''
    '''

    /**
     * Generates additional accessor methods.
     */
    override accessors(Entity it) '''
    '''
}
