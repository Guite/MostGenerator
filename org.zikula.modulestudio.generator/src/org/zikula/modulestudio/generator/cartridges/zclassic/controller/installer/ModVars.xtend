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

    def valSession2Mod(Variable it) {
        switch (it) {
            BoolVar: '''«IF value == 'true'»true«ELSE»false«ENDIF»'''
            IntVar: value
            ListVar: '''«IF it.multiple»array(«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«valSession2Mod»«ENDFOR»«IF it.multiple»)«ENDIF»'''
            ListVarItem: '''«IF it.^default == true»'«name.formatForCode»'«ENDIF»'''
            default: '\'' + value + '\''
    	}
    }

    def valDirect2Mod(Variable it) {
        switch (it) {
            BoolVar: '''«IF value == 'true'»true«ELSE»false«ENDIF»'''
            IntVar: value
            ListVar: '''«IF it.multiple»array(«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«valDirect2Mod»«ENDFOR»«IF it.multiple»)«ENDIF»'''
            ListVarItem: '\'' + name.formatForCode + '\''
            default: '\'' + value + '\''
    	}
    }

    // for interactive installer
    def valForm2SessionDefault(Variable it) {
        switch (it) {
            ListVar: '''«IF it.multiple»serialize(array(«ENDIF»«FOR item : it.getDefaultItems SEPARATOR ', '»«valForm2SessionDefault»«ENDFOR»«IF it.multiple»))«ENDIF»'''
            ListVarItem: '\'' + name.formatForCode + '\''
            default: '\'' + value.formatForCode + '\''
    	}
    }
}
