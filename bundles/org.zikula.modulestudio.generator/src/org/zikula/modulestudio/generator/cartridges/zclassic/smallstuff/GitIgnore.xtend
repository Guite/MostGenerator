package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess

class GitIgnore {

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('.gitignore', gitIgnoreContent)
    }

    def private gitIgnoreContent(Application it) '''
        vendor/
    '''
}
