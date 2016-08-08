package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TravisFile {
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.x')) {
            return
        }
        var fileName = '.travis.yml'
        if (!shouldBeSkipped(getAppSourcePath + fileName)) {
            if (shouldBeMarked(getAppSourcePath + fileName)) {
                fileName = '.travis.generated.yml'
            }
            fsa.generateFile(getAppSourcePath + fileName, travisFile)
        }
    }

    def private travisFile(Application it) '''
        language: php
        
        before_script: composer install --dev --prefer-source
        
        php:
          - 5.4
          - 5.5
    '''
}
