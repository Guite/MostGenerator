package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ZikulaManifest {

    extension FormattingExtensions = new FormattingExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        var fileName = 'zikula.manifest.json'
        if (!shouldBeSkipped(fileName)) {
            if (shouldBeMarked(fileName)) {
                fileName = 'zikula.manifest.generated.json'
            }
            fsa.generateFile(fileName, manifestFile)
        }
    }

    def private manifestFile(Application it) '''
        {
            «manifestContent»
        }
    '''

    def private manifestContent(Application it) '''
        "vendor": {
            "title": "«vendor»",
            "url": "«url»",
            "logo": ""
        },
        "extension": {
            "name": "«name.formatForDisplayCapital»",
            "url": "«url»",
            "icon": ""
        },
        "version": {
            "semver": "«version»",
            "compatibility": ">=«targetSemVer(true)» <3.0.0",
            "composerpath": "composer.json",
            "description": "«appDescription»",
            "keywords": [
            ]
        },
        "urls": {
            "version": "",
            "docs": "",
            "demo": "",
            "download": "",
            "issues": ""
        },
        "dependencies": [
        ]
    '''
}
