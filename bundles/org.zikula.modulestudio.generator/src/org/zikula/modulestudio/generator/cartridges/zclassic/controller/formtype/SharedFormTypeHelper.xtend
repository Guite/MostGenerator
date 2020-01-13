package org.zikula.modulestudio.generator.cartridges.zclassic.controller.formtype

import de.guite.modulestudio.metamodel.Application
import java.util.ArrayList
import org.zikula.modulestudio.generator.extensions.Utils

class SharedFormTypeHelper {

    extension Utils = new Utils

    def displayHelpMessages(Application it, ArrayList<String> messages, ArrayList<String> parameters) {
        if (!messages.empty) '''
            «IF targets('3.0')»
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
            «ELSE»
                'help' => «IF messages.length > 1»[«ENDIF»«messages.join(', ')»«IF messages.length > 1»]«ENDIF»,
            «ENDIF»
        '''
    }
}
