package org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.NumberField
import de.guite.modulestudio.metamodel.NumberRole

class Sortable extends AbstractExtension implements EntityExtensionInterface {

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(Field it) '''
        «IF sortableGroup»
            #[Gedmo\SortableGroup]
        «ENDIF»
        «IF it instanceof NumberField && (it as NumberField).role == NumberRole.SORTABLE_POSITION»
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
