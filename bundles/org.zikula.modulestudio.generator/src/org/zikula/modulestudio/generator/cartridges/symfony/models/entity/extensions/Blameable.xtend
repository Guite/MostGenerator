package org.zikula.modulestudio.generator.cartridges.symfony.models.entity.extensions

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityBlameableType
import de.guite.modulestudio.metamodel.Field
import de.guite.modulestudio.metamodel.UserField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class Blameable extends AbstractExtension implements EntityExtensionInterface {

    extension FormattingExtensions = new FormattingExtensions

    /**
     * Generates additional annotations on class level.
     */
    override classAnnotations(Entity it) '''
    '''

    /**
     * Additional field annotations.
     */
    override columnAnnotations(Field it) '''
        «IF it instanceof UserField && (it as UserField).blameable != EntityBlameableType.NONE»
            #[Gedmo\Blameable(on: '«(it as UserField).blameable.literal.toLowerCase»'«(it as UserField).blameableDetails»)]
        «ENDIF»
    '''

    def private blameableDetails(UserField it) '''«IF blameable == EntityBlameableType.CHANGE», field: '«blameableChangeTriggerField.formatForCode»'«IF null !== blameableChangeTriggerValue && !blameableChangeTriggerValue.empty», value: '«blameableChangeTriggerValue.formatForCode»'«ENDIF»«ENDIF»'''

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
