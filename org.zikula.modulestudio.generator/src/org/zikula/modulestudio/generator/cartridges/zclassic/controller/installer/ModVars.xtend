package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Variable
import de.guite.modulestudio.metamodel.modulestudio.BoolVar
import de.guite.modulestudio.metamodel.modulestudio.IntVar
import de.guite.modulestudio.metamodel.modulestudio.ListVar
import de.guite.modulestudio.metamodel.modulestudio.ListVarItem
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

/**
 * Utility methods for the installer.
 */
class ModVars {
    @Inject extension FormattingExtensions = new FormattingExtensions()
    @Inject extension ModelExtensions = new ModelExtensions()

    def valFromSession(Variable it) {
    	switch it {
    	    ListVar: '''«IF it.multiple»serialize(«ENDIF»$sessionValue«IF it.multiple»)«ENDIF»'''
    	    default: '''$sessionValue'''
    	}
    }

    def dispatch valSession2Mod(Variable it) {
        switch (it) {
            BoolVar: '''«IF value == 'true'»true«ELSE»false«ENDIF»'''
            IntVar: value
            ListVar: '''«IF it.multiple»array(«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«item.valSession2Mod»«ENDFOR»«IF it.multiple»)«ENDIF»'''
            default: '\'' + value + '\''
    	}
    }

    def dispatch valSession2Mod(ListVarItem it) '''«IF it.^default == true»'«name.formatForCode»'«ENDIF»'''

    def dispatch valDirect2Mod(Variable it) {
        switch (it) {
            BoolVar: '''«IF value != null && value == 'true'»true«ELSE»false«ENDIF»'''
            IntVar: value
            ListVar: '''«IF it.multiple»array(«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«item.valDirect2Mod»«ENDFOR»«IF it.multiple»)«ENDIF»'''
            default: '\'' + (if (value != null) value else '') + '\''
    	}
    }

    def dispatch valDirect2Mod(ListVarItem it) ''' '«name.formatForCode»' '''

    // for interactive installer
    def dispatch valForm2SessionDefault(Variable it) {
        switch (it) {
            ListVar: '''«IF it.multiple»serialize(array(«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«item.valForm2SessionDefault»«ENDFOR»«IF it.multiple»))«ENDIF»'''
            default: '\'' + value.formatForCode + '\''
    	}
    }

    def dispatch valForm2SessionDefault(ListVarItem it) ''' '«name.formatForCode»' '''
}
