package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import java.util.ArrayList

class SharedFormTypeHelper {

    def displayHelpMessages(Application it, ArrayList<String> messages, ArrayList<String> parameters) {
        if (!messages.empty) '''
            «IF messages.length > 1»
                /** @Ignore */
                'help' => [
                    «FOR message : messages»
                        /** @Translate */«message»«IF message != messages.tail»,«ENDIF»
                    «ENDFOR»
                ],
            «ELSE»
                'help' => «messages.head»,
            «ENDIF»
            «IF !parameters.empty»
                'help_translation_parameters' => [«parameters.join(', ')»],
            «ENDIF»
        '''
    }
}
