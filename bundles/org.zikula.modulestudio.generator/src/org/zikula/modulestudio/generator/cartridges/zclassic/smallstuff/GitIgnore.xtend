package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class GitIgnore {
    extension NamingExtensions = new NamingExtensions

    def generate(Application it, IFileSystemAccess fsa) {
        if (!shouldBeSkipped(getAppSourcePath + '.gitignore')) {
            fsa.generateFile(getAppSourcePath + '.gitignore', gitIgnoreContent)
        }
    }

    def private gitIgnoreContent(Application it) '''
        vendor/
        composer.lock
        phpunit.xml
    '''
}
