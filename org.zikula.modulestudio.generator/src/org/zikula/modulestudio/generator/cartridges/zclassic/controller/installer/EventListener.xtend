package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.GeneratorSettingsExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class EventListener {
    @Inject extension ControllerExtensions = new ControllerExtensions
    @Inject extension GeneratorSettingsExtensions = new GeneratorSettingsExtensions
    @Inject extension Utils = new Utils

    /**
     * Entry point for event listeners registered by the installer.
     * Used for 1.3.5 target only, in 1.3.7 it is replaced by service definition used by the DependencyInjection component.
     */
    def generate(Application it) '''
        /**
         * Register persistent event handlers.
         * These are listeners for external events of the core and other modules.
         */
        protected function registerPersistentEventHandlers()
        {
            «val listenerBase = appName + '_Listener_'»
            // core -> «var callableClass = listenerBase + 'Core'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'api.method_not_found', array('«callableClass»', 'apiMethodNotFound'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'core.preinit', array('«callableClass»', 'preInit'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'core.init', array('«callableClass»', 'init'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'core.postinit', array('«callableClass»', 'postInit'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'controller.method_not_found', array('«callableClass»', 'controllerMethodNotFound'));

            // front controller -> «callableClass = listenerBase + 'FrontController'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'frontcontroller.predispatch', array('«callableClass»', 'preDispatch'));

            // installer -> «callableClass = listenerBase + 'Installer'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'installer.module.installed', array('«callableClass»', 'moduleInstalled'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'installer.module.upgraded', array('«callableClass»', 'moduleUpgraded'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'installer.module.uninstalled', array('«callableClass»', 'moduleUninstalled'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'installer.subscriberarea.uninstalled', array('«callableClass»', 'subscriberAreaUninstalled'));

            // modules -> «callableClass = listenerBase + 'ModuleDispatch'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.postloadgeneric', array('«callableClass»', 'postLoadGeneric'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.preexecute', array('«callableClass»', 'preExecute'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.postexecute', array('«callableClass»', 'postExecute'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.custom_classname', array('«callableClass»', 'customClassname'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.service_links', array('«callableClass»', 'serviceLinks'));

            // mailer -> «callableClass = listenerBase + 'Mailer'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.mailer.api.sendmessage', array('«callableClass»', 'sendMessage'));

            // page -> «callableClass = listenerBase + 'Page'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'pageutil.addvar_filter', array('«callableClass»', 'pageutilAddvarFilter'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'system.outputfilter', array('«callableClass»', 'systemOutputfilter'));

            // errors -> «callableClass = listenerBase + 'Errors'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'setup.errorreporting', array('«callableClass»', 'setupErrorReporting'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'systemerror', array('«callableClass»', 'systemError'));

            // theme -> «callableClass = listenerBase + 'Theme'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.preinit', array('«callableClass»', 'preInit'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.init', array('«callableClass»', 'init'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.load_config', array('«callableClass»', 'loadConfig'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.prefetch', array('«callableClass»', 'preFetch'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.postfetch', array('«callableClass»', 'postFetch'));

            // view -> «callableClass = listenerBase + 'View'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'view.init', array('«callableClass»', 'init'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'view.postfetch', array('«callableClass»', 'postFetch'));

            // user login -> «callableClass = listenerBase + 'UserLogin'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.login.started', array('«callableClass»', 'started'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.login.veto', array('«callableClass»', 'veto'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.login.succeeded', array('«callableClass»', 'succeeded'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.login.failed', array('«callableClass»', 'failed'));

            // user logout -> «callableClass = listenerBase + 'UserLogout'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.logout.succeeded', array('«callableClass»', 'succeeded'));

            // user -> «callableClass = listenerBase + 'User'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.gettheme', array('«callableClass»', 'getTheme'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.account.create', array('«callableClass»', 'create'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.account.update', array('«callableClass»', 'update'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.account.delete', array('«callableClass»', 'delete'));

            // registration -> «callableClass = listenerBase + 'UserRegistration'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.registration.started', array('«callableClass»', 'started'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.registration.succeeded', array('«callableClass»', 'succeeded'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.registration.failed', array('«callableClass»', 'failed'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.registration.create', array('«callableClass»', 'create'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.registration.update', array('«callableClass»', 'update'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.registration.delete', array('«callableClass»', 'delete'));

            // users module -> «callableClass = listenerBase + 'Users'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.config.updated', array('«callableClass»', 'configUpdated'));

            // group -> «callableClass = listenerBase + 'Group'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.create', array('«callableClass»', 'create'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.update', array('«callableClass»', 'update'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.delete', array('«callableClass»', 'delete'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.adduser', array('«callableClass»', 'addUser'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.removeuser', array('«callableClass»', 'removeUser'));

            «val needsDetailContentType = generateDetailContentType && hasUserController && getMainUserController.hasActions('display')»
            «IF generatePendingContentSupport || generateListContentType || needsDetailContentType»
                // special purposes and 3rd party api support -> «callableClass = listenerBase + 'ThirdParty'»
                «IF generatePendingContentSupport»
                    EventUtil::registerPersistentModuleHandler('«appName»', 'get.pending_content', array('«callableClass»', 'pendingContentListener'));
                «ENDIF»
                «IF generateListContentType || needsDetailContentType»
                    EventUtil::registerPersistentModuleHandler('«appName»', 'module.content.gettypes', array('«callableClass»', 'contentGetTypes'));
                «ENDIF»
            «ENDIF»
        }
    '''
}
