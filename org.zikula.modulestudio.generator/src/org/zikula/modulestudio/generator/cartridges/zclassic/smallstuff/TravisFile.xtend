package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class TravisFile {
    @Inject extension NamingExtensions = new NamingExtensions
    @Inject extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        if (targets('1.3.5')) {
            return
        }
        if (!shouldBeSkipped(getAppSourcePath + '.travis.yml')) {
            fsa.generateFile(getAppSourcePath + '.travis.yml', travisFile)
        }
    }

    def private travisFile(Application it) '''
        language: php
        
        before_script: composer install --dev --prefer-source
        
        php:
          - 5.3
          - 5.4
          - 5.5
    '''
}
