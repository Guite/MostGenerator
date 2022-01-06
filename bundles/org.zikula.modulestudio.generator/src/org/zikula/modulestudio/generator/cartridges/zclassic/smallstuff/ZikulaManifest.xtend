package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ZikulaManifest {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('zikula.manifest.json', manifestFile)
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
            "compatibility": ">=«targetSemVer(true)» <«IF targets('4.0')»5«ELSE»4«ENDIF».0.0",
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
