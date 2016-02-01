package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.BoolVar
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.ListVar
import de.guite.modulestudio.metamodel.ListVarItem
import de.guite.modulestudio.metamodel.Variable
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

/**
 * Utility methods for the installer.
 */
class ModVars {
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def dispatch CharSequence valDirect2Mod(Variable it) {
        switch it {
            BoolVar: '''«IF null !== value && value == 'true'»true«ELSE»false«ENDIF»'''
            IntVar: '''«IF null !== value && value != ''»«value»«ELSE»0«ENDIF»'''
            ListVar: '''«IF it.multiple»«IF container.application.targets('1.3.x')»array(«ELSE»[«ENDIF»«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«item.valDirect2Mod»«ENDFOR»«IF it.multiple»«IF container.application.targets('1.3.x')»)«ELSE»]«ENDIF»«ENDIF»'''
            default: '\'' + (if (null !== value) value else '') + '\''
        }
    }

    def dispatch CharSequence valDirect2Mod(ListVarItem it) ''' '«name.formatForCode»' '''
}
