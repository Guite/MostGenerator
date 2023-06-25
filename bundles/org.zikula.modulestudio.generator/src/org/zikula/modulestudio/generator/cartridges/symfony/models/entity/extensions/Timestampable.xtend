package org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions

import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTimestampableType
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class Timestampable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(DerivedField it) '''
        «IF it instanceof DatetimeField && (it as DatetimeField).timestampable != EntityTimestampableType.NONE»
            #[Gedmo\Timestampable(on: '«(it as DatetimeField).timestampable.literal.toLowerCase»'«(it as DatetimeField).timestampableDetails»)]
        «ENDIF»
    '''

    def private timestampableDetails(DatetimeField it) '''«IF timestampable == EntityTimestampableType.CHANGE», field: '«timestampableChangeTriggerField.formatForCode»'«IF null !== timestampableChangeTriggerValue && !timestampableChangeTriggerValue.empty», value: '«timestampableChangeTriggerValue.formatForCode»'«ENDIF»«ENDIF»'''

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
