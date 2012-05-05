package org.zikula.modulestudio.generator.cartridges.zclassic.controller.installer

import com.google.inject.Inject
import de.guite.modulestudio.metamodel.modulestudio.Application
import org.zikula.modulestudio.generator.extensions.Utils

class EventListener {
    @Inject extension Utils = new Utils()

    /**
     * Entry point for event listeners registered by the installer.
     */
    def generate(Application it) '''
        /**
         * Register persistent event handlers.
         * These are listeners for external events of the core and other modules.
         */
        protected function registerPersistentEventHandlers()
        {
            // core -> «var callableClass = appName + '_Listener_Core'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'api.method_not_found', array('«callableClass»', 'apiMethodNotFound'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'core.preinit', array('«callableClass»', 'preInit'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'core.init', array('«callableClass»', 'init'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'core.postinit', array('«callableClass»', 'postInit'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'controller.method_not_found', array('«callableClass»', 'controllerMethodNotFound'));

            // installer -> «callableClass = appName + '_Listener_Installer'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'installer.module.installed', array('«callableClass»', 'moduleInstalled'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'installer.module.upgraded', array('«callableClass»', 'moduleUpgraded'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'installer.module.uninstalled', array('«callableClass»', 'moduleUninstalled'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'installer.subscriberarea.uninstalled', array('«callableClass»', 'subscriberAreaUninstalled'));

            // modules -> «callableClass = appName + '_Listener_ModuleDispatch'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.postloadgeneric', array('«callableClass»', 'postLoadGeneric'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.preexecute', array('«callableClass»', 'preExecute'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.postexecute', array('«callableClass»', 'postExecute'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module_dispatch.custom_classname', array('«callableClass»', 'customClassname'));

            // mailer -> «callableClass = appName + '_Listener_Mailer'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.mailer.api.sendmessage', array('«callableClass»', 'sendMessage'));

            // page -> «callableClass = appName + '_Listener_Page'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'pageutil.addvar_filter', array('«callableClass»', 'pageutilAddvarFilter'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'system.outputfilter', array('«callableClass»', 'systemOutputfilter'));

            // errors -> «callableClass = appName + '_Listener_Errors'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'setup.errorreporting', array('«callableClass»', 'setupErrorReporting'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'systemerror', array('«callableClass»', 'systemError'));

            // theme -> «callableClass = appName + '_Listener_Theme'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.preinit', array('«callableClass»', 'preInit'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.init', array('«callableClass»', 'init'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.load_config', array('«callableClass»', 'loadConfig'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.prefetch', array('«callableClass»', 'preFetch'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'theme.postfetch', array('«callableClass»', 'postFetch'));

            // view -> «callableClass = appName + '_Listener_View'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'view.init', array('«callableClass»', 'init'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'view.postfetch', array('«callableClass»', 'postFetch'));

            // user login -> «callableClass = appName + '_Listener_UserLogin'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.login.started', array('«callableClass»', 'started'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.login.veto', array('«callableClass»', 'veto'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.login.succeeded', array('«callableClass»', 'succeeded'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.login.failed', array('«callableClass»', 'failed'));

            // user logout -> «callableClass = appName + '_Listener_UserLogout'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.logout.succeeded', array('«callableClass»', 'succeeded'));

            // user -> «callableClass = appName + '_Listener_User'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.gettheme', array('«callableClass»', 'getTheme'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.account.create', array('«callableClass»', 'create'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.account.update', array('«callableClass»', 'update'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.account.delete', array('«callableClass»', 'delete'));

            // registration -> «callableClass = appName + '_Listener_UserRegistration'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.registration.started', array('«callableClass»', 'started'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.registration.succeeded', array('«callableClass»', 'succeeded'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.ui.registration.failed', array('«callableClass»', 'failed'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.registration.create', array('«callableClass»', 'create'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.registration.update', array('«callableClass»', 'update'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'user.registration.delete', array('«callableClass»', 'delete'));

            // users module -> «callableClass = appName + '_Listener_Users'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.users.config.updated', array('«callableClass»', 'configUpdated'));

            // group -> «callableClass = appName + '_Listener_Group'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.create', array('«callableClass»', 'create'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.update', array('«callableClass»', 'update'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.delete', array('«callableClass»', 'delete'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.adduser', array('«callableClass»', 'addUser'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'group.removeuser', array('«callableClass»', 'removeUser'));

            // special purposes and 3rd party api support -> «callableClass = appName + '_Listener_ThirdParty'»
            EventUtil::registerPersistentModuleHandler('«appName»', 'get.pending_content', array('«callableClass»', 'pendingContentListener'));
            EventUtil::registerPersistentModuleHandler('«appName»', 'module.content.gettypes', array('«callableClass»', 'contentGetTypes'));
        }
    '''
}
