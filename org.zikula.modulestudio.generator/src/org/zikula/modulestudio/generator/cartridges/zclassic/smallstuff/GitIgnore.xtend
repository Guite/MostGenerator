package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GitIgnore {
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
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
