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
    '''

    def private menuLinkToViewAction(Entity it, Controller controller) '''
        if (in_array('«name.formatForCode»', $allowedObjectTypes)
            && $this->permissionApi->hasPermission($this->getBundleName() . ':«name.formatForCodeCapital»:', '::', $permLevel)) {
            $links[] = [
                'url' => $this->router->generate('«app.appName.formatForDB»_«name.formatForDB»_«IF controller instanceof AdminController»admin«ENDIF»view'«IF tree != EntityTreeType.NONE», array('tpl' => 'tree')«ENDIF»),
                'text' => $this->__('«nameMultiple.formatForDisplayCapital»'),
                'title' => $this->__('«name.formatForDisplayCapital» list')
            ];
        }
    '''

    def private menuLinksBetweenControllers(Controller it) {
        switch it {
            AdminController case !application.getAllUserControllers.empty: '''
                    «val userController = application.getAllUserControllers.head»
                    if ($this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_READ)) {
                        $links[] = [
                            'url' => $this->router->generate('«app.appName.formatForDB»_«userController.formattedName»_«userController.indexUrlDetails»),«/* end quote missing here on purpose */»
                            'text' => $this->__('Frontend'),
                            'title' => $this->__('Switch to user area.'),
                            'icon' => 'home'
                        ];
                    }
                    '''
            UserController case !application.getAllAdminControllers.empty: '''
                    «val adminController = application.getAllAdminControllers.head»
                    if ($this->permissionApi->hasPermission($this->getBundleName() . '::', '::', ACCESS_ADMIN)) {
                        $links[] = [
                            'url' => $this->router->generate('«app.appName.formatForDB»_«adminController.formattedName»_«adminController.indexUrlDetails»),«/* end quote missing here on purpose */»
                            'text' => $this->__('Backend'),
                            'title' => $this->__('Switch to administration area.'),
                            'icon' => 'wrench'
                        ];
                    }
                    '''
        }
    }

    def private indexUrlDetails(Controller it) {
        if (hasActions('index')) 'index\''
        else if (hasActions('view')) 'view\', [\'ot\' => \'' + application.getLeadingEntity.name.formatForCode + '\']'
        else if (application.needsConfig && isConfigController) 'config\''
        else 'hooks\''
    }
}
