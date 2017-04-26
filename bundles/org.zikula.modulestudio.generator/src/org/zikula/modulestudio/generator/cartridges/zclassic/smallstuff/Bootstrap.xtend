package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Bootstrap {

    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

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
        «IF hasLoggable || hasAutomaticArchiving»
            $container = \ServiceUtil::get('service_container');

        «ENDIF»
        «initExtensions»
        «archiveObjectsCall»

    '''

    def private initExtensions(Application it) '''
        «IF hasLoggable»
            $currentUserApi = $container->get('zikula_users_module.current_user');
            $userName = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uname') : __('Guest');

            // set current user name to loggable listener
            $loggableListener = $container->get('doctrine_extensions.listener.loggable');
            $loggableListener->setUsername($userName);
        «ENDIF»
    '''

    def private archiveObjectsCall(Application it) '''
        «IF hasAutomaticArchiving»

            // check if own service exists (which is not true if the module is not installed yet)
            if ($container->has('«appService».archive_helper')) {
                $container->get('«appService».archive_helper')->archiveObsoleteObjects();
            }
        «ENDIF»
    '''

    def private bootstrapImpl(Application it) '''
        «bootstrapDocs»

        include_once 'Base/bootstrap.php';
    '''
}
