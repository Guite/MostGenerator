package org.zikula.modulestudio.generator.cartridges.zclassic.controller.menu

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MenuLinksHelperFunctions {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it) '''
        «menuLinksBetweenControllers»

        «FOR entity : getAllEntities.filter[hasViewAction]»
            «entity.menuLinkToViewAction»
        «ENDFOR»
    '''

    def private menuLinkToViewAction(Entity it) '''
        if (
            in_array('«name.formatForCode»', $allowedObjectTypes, true)
            && $this->permissionHelper->hasComponentPermission('«name.formatForCode»', $permLevel)
        ) {
            yield MenuItem::linktoRoute('«nameMultiple.formatForDisplayCapital»', null, '«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . 'view'«/*IF tree != EntityTreeType.NONE», ['tpl' => 'tree']«ENDIF*/»);
        }
    '''

    def private menuLinksBetweenControllers(Application it) '''
        if (self::TYPE_ADMIN === $type) {
            if ($this->permissionHelper->hasPermission(ACCESS_READ)) {
                yield MenuItem::linktoRoute('Frontend', 'fas fa-home', '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_«getLeadingEntity.getPrimaryAction»');
            }
        } else {
            if ($this->permissionHelper->hasPermission(ACCESS_ADMIN)) {
                yield MenuItem::linktoRoute('Backend', 'fas fa-wrench', '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»');
            }
        }
    '''
}
