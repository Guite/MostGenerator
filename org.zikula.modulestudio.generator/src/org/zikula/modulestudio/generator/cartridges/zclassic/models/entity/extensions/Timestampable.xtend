package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.modulestudio.AbstractDateField
import de.guite.modulestudio.metamodel.modulestudio.DerivedField
import de.guite.modulestudio.metamodel.modulestudio.Entity
import de.guite.modulestudio.metamodel.modulestudio.EntityTimestampableType
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
        «IF it instanceof AbstractDateField && (it as AbstractDateField).timestampable != EntityTimestampableType.NONE»
            «' '»* @Gedmo\Timestampable(on="«(it as AbstractDateField).timestampable.literal»"«(it as AbstractDateField).timestampableDetails»)
        «ENDIF»
    '''

    def private timestampableDetails(AbstractDateField it) '''«IF timestampable == EntityTimestampableType::CHANGE», field="«timestampableChangeTriggerField.formatForCode»"«IF timestampableChangeTriggerValue !== null && timestampableChangeTriggerValue != ''», value="«timestampableChangeTriggerValue.formatForCode»"«ENDIF»«ENDIF»'''

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
