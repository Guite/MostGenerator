package org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.extensions

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityIpTraceableType
import de.guite.modulestudio.metamodel.StringField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class IpTraceable extends AbstractExtension implements EntityExtensionInterface {

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
        «IF it instanceof StringField && (it as StringField).ipTraceable != EntityIpTraceableType.NONE»
            #[Gedmo\IpTraceable(on: '«(it as StringField).ipTraceable.literal.toLowerCase»'«(it as StringField).ipTraceableDetails»)]
        «ENDIF»
    '''

    def private ipTraceableDetails(StringField it) '''«IF ipTraceable == EntityIpTraceableType.CHANGE», field: '«ipTraceableChangeTriggerField.formatForCode»'«IF null !== ipTraceableChangeTriggerValue && !ipTraceableChangeTriggerValue.empty», value: '«ipTraceableChangeTriggerValue.formatForCode»'«ENDIF»«ENDIF»'''

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
