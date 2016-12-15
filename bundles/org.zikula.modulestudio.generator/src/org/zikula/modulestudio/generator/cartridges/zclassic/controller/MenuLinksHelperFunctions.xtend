package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.AdminController
import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Controller
import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import de.guite.modulestudio.metamodel.UserController
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MenuLinksHelperFunctions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    Application app

    def generate(Controller it) {
        app = application

        getLinksBody
    }

    def private getLinksBody(Controller it) '''
        «menuLinksBetweenControllers»

        «IF it instanceof AdminController || it instanceof UserController»
            «FOR entity : app.getAllEntities.filter[hasActions('view')]»
                «entity.menuLinkToViewAction(it)»
            «ENDFOR»
            «IF app.needsConfig»
                «IF isLegacy»
                    if (SecurityUtil::checkPermission($this->name . '::', '::', ACCESS_ADMIN)) {
                        $links[] = array(
                            'url' => ModUtil::url($this->name, '«app.configController.formatForDB»', 'config'),
                            'text' => $this->__('Configuration'),
                            'title' => $this->__('Manage settings for this application')
                        );
                    }
                «ELSE»
                    if ($this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_ADMIN)) {
                        $links[] = [
                            'url' => $this->router->generate('«app.appName.formatForDB»_«app.configController.formatForDB»_config'),
                            'text' => $this->__('Configuration'),
                            'title' => $this->__('Manage settings for this application'),
                            'icon' => 'wrench'
                        ];
                    }
                «ENDIF»
            «ENDIF»
        «ENDIF»
    '''

    def private menuLinkToViewAction(Entity it, Controller controller) '''
        if (in_array('«name.formatForCode»', $allowedObjectTypes)
            && «IF isLegacy»SecurityUtil::check«ELSE»$this->permissionApi->has«ENDIF»Permission(«IF isLegacy»$this->name«ELSE»$this->getBundleName()«ENDIF» . ':«name.formatForCodeCapital»:', '::', $permLevel)) {
            «IF isLegacy»
                $links[] = array(
                    'url' => ModUtil::url($this->name, '«controller.formattedName»', 'view', array('ot' => '«name.formatForCode»'«IF tree != EntityTreeType.NONE», 'tpl' => 'tree'«ENDIF»)),
            «ELSE»
                $links[] = [
                    'url' => $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»view'«IF tree != EntityTreeType.NONE», array('tpl' => 'tree')«ENDIF»),
            «ENDIF»
                 'text' => $this->__('«nameMultiple.formatForDisplayCapital»'),
                 'title' => $this->__('«name.formatForDisplayCapital» list')
             «IF isLegacy»)«ELSE»]«ENDIF»;
        }
    '''

    def private menuLinksBetweenControllers(Controller it) {
        switch it {
            AdminController case !application.getAllUserControllers.empty: '''
                    «val userController = application.getAllUserControllers.head»
                    if («IF isLegacy»SecurityUtil::check«ELSE»$this->permissionApi->has«ENDIF»Permission(«IF isLegacy»$this->name«ELSE»$this->getBundleName()«ENDIF» . '::', '::', ACCESS_READ)) {
                        «IF isLegacy»
                            $links[] = array(
                                'url' => ModUtil::url($this->name, '«userController.formattedName»', «userController.indexUrlDetails13»),
                        «ELSE»
                            $links[] = [
                                'url' => $this->router->generate('«app.appName.formatForDB»_«userController.formattedName»_«userController.indexUrlDetails14»),«/* end quote missing here on purpose */»
                        «ENDIF»
                            'text' => $this->__('Frontend'),
                            'title' => $this->__('Switch to user area.'),
                            «IF isLegacy»'class' => 'z-icon-es-home'«ELSE»'icon' => 'home'«ENDIF»
                        «IF isLegacy»)«ELSE»]«ENDIF»;
                    }
                    '''
            UserController case !application.getAllAdminControllers.empty: '''
                    «val adminController = application.getAllAdminControllers.head»
                    if («IF isLegacy»SecurityUtil::check«ELSE»$this->permissionApi->has«ENDIF»Permission(«IF isLegacy»$this->name«ELSE»$this->getBundleName()«ENDIF» . '::', '::', ACCESS_ADMIN)) {
                        «IF isLegacy»
                            $links[] = array(
                                'url' => ModUtil::url($this->name, '«adminController.formattedName»', «adminController.indexUrlDetails13»),
                        «ELSE»
                            $links[] = [
                                'url' => $this->router->generate('«app.appName.formatForDB»_«adminController.formattedName»_«adminController.indexUrlDetails14»),«/* end quote missing here on purpose */»
                        «ENDIF»
                            'text' => $this->__('Backend'),
                            'title' => $this->__('Switch to administration area.'),
                            «IF isLegacy»'class' => 'z-icon-es-options'«ELSE»'icon' => 'wrench'«ENDIF»
                        «IF isLegacy»)«ELSE»]«ENDIF»;
                    }
                    '''
        }
    }

    def private indexUrlDetails14(Controller it) {
        if (hasActions('index')) 'index\''
        else if (hasActions('view')) 'view\', [\'ot\' => \'' + application.getLeadingEntity.name.formatForCode + '\']'
        else if (application.needsConfig && isConfigController) 'config\''
        else 'hooks\''
    }

    def private indexUrlDetails13(Controller it) {
        if (hasActions('index')) '\'main\''
        else if (hasActions('view')) '\'view\', array(\'ot\' => \'' + application.getLeadingEntity.name.formatForCode + '\')'
        else if (application.needsConfig && isConfigController) '\'config\''
        else '\'hooks\''
    }

    def private isLegacy() {
        app.targets('1.3.x')
    }
}
