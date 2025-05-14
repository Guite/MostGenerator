package org.zikula.modulestudio.generator.cartridges.symfony.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess

class Phpstan {

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('phpstan.neon', phpstanConfig)
    }

    def private phpstanConfig(Application it) '''
        parameters:
            level: 1
            paths:
              - src
              - tests
    '''
}
