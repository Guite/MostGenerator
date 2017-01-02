package org.zikula.modulestudio.generator.cartridges.zclassic.view.formcomponents

import de.guite.modulestudio.metamodel.DerivedField
import de.guite.modulestudio.metamodel.EntityField
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class SimpleFields {
    extension FormattingExtensions = new FormattingExtensions

    def formRow(DerivedField it, String groupSuffix, String idSuffix) '''
        «fieldRow(groupSuffix, idSuffix)»
    '''

    def private fieldRow(EntityField it, String groupSuffix, String idSuffix) {
        if (groupSuffix != '' || idSuffix != '') {
            '''{{ form_row(attribute(form, «IF groupSuffix != ''»«groupSuffix» ~ «ENDIF»'«name.formatForCode»'«IF idSuffix != ''» ~ «idSuffix»«ENDIF»)) }}'''
        } else {
            '''{{ form_row(form.«name.formatForCode») }}'''
        }
    }
}
