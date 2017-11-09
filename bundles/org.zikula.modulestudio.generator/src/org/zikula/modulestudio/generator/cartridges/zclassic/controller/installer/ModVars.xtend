package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Field
import org.zikula.modulestudio.generator.cartridges.zclassic.models.entity.Property
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

/**
 * Utility methods for the installer.
 */
class ModVars {

    extension FormattingExtensions = new FormattingExtensions

    def init(Application it) '''
        «FOR varContainer : variables»
            «IF varContainer.composite»
                $this->setVar('«varContainer.name.formatForCode»', [
                    «FOR field : varContainer.fields»
                        '«field.name.formatForCode»' => «field.initialValue»«IF field != varContainer.fields.last»,«ENDIF»
                    «ENDFOR»
                ]);
            «ELSE»
                «FOR field : varContainer.fields»
                    $this->setVar('«field.name.formatForCode»', «field.initialValue»);
                «ENDFOR»
            «ENDIF»
        «ENDFOR»
    '''

    def private initialValue(Field it) {
        Property.defaultFieldData(it)
    }
}
