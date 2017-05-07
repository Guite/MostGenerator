package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.BoolVar
import de.guite.modulestudio.metamodel.IntVar
import de.guite.modulestudio.metamodel.ListVar
import de.guite.modulestudio.metamodel.ListVarItem
import de.guite.modulestudio.metamodel.Variable
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

/**
 * Utility methods for the installer.
 */
class ModVars {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    def init(Application it) '''
        «FOR varContainer : variables»
            «IF varContainer.composite»
                $this->setVar('«varContainer.name.formatForCode»', [
                    «FOR modvar : varContainer.vars»
                        '«modvar.name.formatForCode»' => «modvar.initialValue»«IF modvar != varContainer.vars.last»,«ENDIF»
                    «ENDFOR»
                ]);
            «ELSE»
                «FOR modvar : varContainer.vars»
                    $this->setVar('«modvar.name.formatForCode»', «modvar.initialValue»);
                «ENDFOR»
            «ENDIF»
        «ENDFOR»
    '''

    def private dispatch CharSequence initialValue(Variable it) {
        switch it {
            BoolVar: '''«IF null !== value && value == 'true'»true«ELSE»false«ENDIF»'''
            IntVar: '''«IF null !== value && value != ''»'«value»'«ELSE»0«ENDIF»'''
            ListVar: '''«IF it.multiple»[«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«item.initialValue»«ENDFOR»«IF it.multiple»]«ELSEIF !it.multiple && it.getDefaultItems.empty»''«ENDIF»'''
            default: '\'' + (if (null !== value) value else '') + '\''
        }
    }

    def private dispatch CharSequence initialValue(ListVarItem it) ''' '«name.formatForCode»' '''
}
