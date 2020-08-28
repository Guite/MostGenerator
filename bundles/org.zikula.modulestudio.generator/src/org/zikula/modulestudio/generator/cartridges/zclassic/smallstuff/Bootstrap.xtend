package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions

class Bootstrap {

    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    def generate(Application it, IMostFileSystemAccess fsa) {
        fsa.generateFile('Base/bootstrap.php', bootstrapBaseImpl)
        fsa.generateFile('bootstrap.php', bootstrapImpl)
    }

    def private bootstrapDocs() '''
        /*
         * Bootstrap called when application is first initialised at runtime.
         *
         * This is only called once, and only if the core has reason to initialise this module,
         * usually to dispatch a controller request or API.
         */
    '''

    def private bootstrapBaseImpl(Application it) '''
        «bootstrapDocs»
        «IF needsComposerInstall»

            require_once __DIR__ . '/../vendor/autoload.php';
        «ENDIF»
    '''

    def private bootstrapImpl(Application it) '''
        «bootstrapDocs»

        include_once 'Base/bootstrap.php';
    '''
}
