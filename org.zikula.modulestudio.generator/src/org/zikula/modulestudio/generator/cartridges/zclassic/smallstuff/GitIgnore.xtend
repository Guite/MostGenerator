package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class GitIgnore {
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

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
