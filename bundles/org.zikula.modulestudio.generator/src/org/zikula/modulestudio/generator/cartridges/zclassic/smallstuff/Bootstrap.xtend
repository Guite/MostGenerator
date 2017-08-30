package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions

class Bootstrap {

    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        val basePath = getAppSourcePath + 'Base/bootstrap.php'
        if (!shouldBeSkipped(basePath)) {
            if (shouldBeMarked(basePath)) {
                fsa.generateFile(basePath.replace('.php', '.generated.php'), bootstrapFile(true))
            } else {
                fsa.generateFile(basePath, bootstrapFile(true))
            }
        }

        val concretePath = getAppSourcePath + 'bootstrap.php'
        if (!generateOnlyBaseClasses && !shouldBeSkipped(concretePath)) {
            if (shouldBeMarked(concretePath)) {
                fsa.generateFile(concretePath.replace('.php', '.generated.php'), bootstrapFile(false))
            } else {
                fsa.generateFile(concretePath, bootstrapFile(false))
            }
        }
    }

    def private bootstrapFile(Application it, Boolean isBase) '''
        «fh.phpFileHeaderBootstrapFile(it)»
        «IF isBase»
            «bootstrapBaseImpl»
        «ELSE»
            «bootstrapImpl»
        «ENDIF»
    '''

    def private bootstrapDocs() '''
        /**
         * Bootstrap called when application is first initialised at runtime.
         *
         * This is only called once, and only if the core has reason to initialise this module,
         * usually to dispatch a controller request or API.
         */
    '''

    def private bootstrapBaseImpl(Application it) '''
        «bootstrapDocs»
        «IF needsComposerInstall»

            require_once __DIR__ . '/vendor/autoload.php';
        «ENDIF»
    '''

    def private bootstrapImpl(Application it) '''
        «bootstrapDocs»

        include_once 'Base/bootstrap.php';
    '''
}
