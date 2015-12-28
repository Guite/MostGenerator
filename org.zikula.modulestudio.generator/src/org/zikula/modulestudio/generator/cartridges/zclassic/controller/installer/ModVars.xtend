package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.Variable
import de.guite.modulestudio.metamodel.BoolVar
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.ListVar
import de.guite.modulestudio.metamodel.ListVarItem
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

/**
 * Utility methods for the installer.
 */
class ModVars {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    def dispatch CharSequence valDirect2Mod(Variable it) {
        switch it {
            BoolVar: '''«IF value !== null && value == 'true'»true«ELSE»false«ENDIF»'''
            IntVar: '''«IF value !== null && value != ''»«value»«ELSE»0«ENDIF»'''
            ListVar: '''«IF it.multiple»array(«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«item.valDirect2Mod»«ENDFOR»«IF it.multiple»)«ENDIF»'''
            default: '\'' + (if (value !== null) value else '') + '\''
        }
    }

    def dispatch CharSequence valDirect2Mod(ListVarItem it) ''' '«name.formatForCode»' '''
}
