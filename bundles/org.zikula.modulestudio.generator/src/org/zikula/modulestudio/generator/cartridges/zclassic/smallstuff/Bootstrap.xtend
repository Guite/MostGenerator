package org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff

import de.guite.modulestudio.metamodel.Application
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class Bootstrap {
    extension FormattingExtensions = new FormattingExtensions
    extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    extension ModelExtensions = new ModelExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    FileHelper fh = new FileHelper

    def generate(Application it, IFileSystemAccess fsa) {
        val basePath = getAppSourcePath + 'Base/bootstrap.php'
        if (!shouldBeSkipped(basePath)) {
            if (shouldBeMarked(basePath)) {
                fsa.generateFile(basePath.replace('.php', '.generated.php'), fh.phpFileContent(it, bootstrapBaseImpl))
            } else {
                fsa.generateFile(basePath, fh.phpFileContent(it, bootstrapBaseImpl))
            }
        }

        val concretePath = getAppSourcePath + 'bootstrap.php'
        if (!generateOnlyBaseClasses && !shouldBeSkipped(concretePath)) {
            if (shouldBeMarked(concretePath)) {
                fsa.generateFile(concretePath.replace('.php', '.generated.php'), fh.phpFileContent(it, bootstrapImpl))
            } else {
                fsa.generateFile(concretePath, fh.phpFileContent(it, bootstrapImpl))
            }
        }
    }

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
        «initExtensions»
        «archiveObjectsCall»

    '''

    def private initExtensions(Application it) '''
        «IF hasLoggable»
            // set current user name to loggable listener
            $loggableListener = ServiceUtil::get('doctrine_extensions.listener.loggable');
            $currentUserApi = ServiceUtil::get('zikula_users_module.current_user');
            $userName = $currentUserApi->isLoggedIn() ? $currentUserApi->get('uname') : __('Guest');
            $loggableListener->setUsername($userName);
        «ENDIF»
    '''

    def private archiveObjectsCall(Application it) '''
        «val entitiesWithArchive = getAllEntities.filter[hasArchive && null !== getEndDateField]»
        «IF !entitiesWithArchive.empty»
            «prefix()»PerformRegularAmendments();

            /**
             * Performs regular amendments, like archiving obsolete data.
             */
            function «prefix()»PerformRegularAmendments()
            {
                $currentType = FormUtil::getPassedValue('type', 'user', 'GETPOST', FILTER_SANITIZE_STRING);
                $currentFunc = FormUtil::getPassedValue('func', 'index', 'GETPOST', FILTER_SANITIZE_STRING);
                if ($currentType == 'admin' || $currentFunc == 'edit' || $currentFunc == 'initialize') {
                    return;
                }

                $randProbability = mt_rand(1, 1000);

                if ($randProbability < 750) {
                    return;
                }

                PageUtil::registerVar('«appName»AutomaticArchiving', false, true);
                $serviceManager = ServiceUtil::getManager();
                // check if own services exist (which is not true if the module is not installed yet)
                if (!$serviceManager->has('«appService».workflow_helper')) {
                    return;
                }
                $workflowHelper = $serviceManager->get('«appService».workflow_helper');
                «IF hasHookSubscribers»

                    if (!$serviceManager->has('«appService».hook_helper')) {
                        return;
                    }
                    $hookHelper = $serviceManager->get('«appService».hook_helper');
                «ENDIF»

                $logger = $serviceManager->get('logger');
                $permissionApi = $serviceManager->get('zikula_permissions_module.api.permission');
                $session = $serviceManager->get('session');
                $translator = $serviceManager->get('translator.default');
                «FOR entity : entitiesWithArchive»

                    if (!$serviceManager->has('«appService».«entity.name.formatForCode»_factory')) {
                        return;
                    }

                    // perform update for «entity.nameMultiple.formatForDisplay» becoming archived
                    $logger->notice('{app}: Automatic archiving for the {entity} entity started.', ['app' => '«appName»', 'entity' => '«entity.name.formatForCode»']);
                    $repository = $serviceManager->get('«appService».«entity.name.formatForCode»_factory')->getRepository();
                    $repository->archiveObjects($permissionApi, $session, $translator, $workflowHelper«IF !entity.skipHookSubscribers», $hookHelper«ENDIF»);
                    $logger->notice('{app}: Automatic archiving for the {entity} entity completed.', ['app' => '«appName»', 'entity' => '«entity.name.formatForCode»']);
                «ENDFOR»
                PageUtil::setVar('«appName»AutomaticArchiving', false);
            }
        «ENDIF»
    '''

    def private bootstrapImpl(Application it) '''
        «bootstrapDocs»

        include_once 'Base/bootstrap.php';
    '''
}
