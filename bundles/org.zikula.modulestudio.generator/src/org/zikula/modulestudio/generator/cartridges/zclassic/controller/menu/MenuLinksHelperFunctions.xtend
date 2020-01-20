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
        «IF needsConfig»
            if ('admin' === $routeArea && $this->permissionHelper->hasPermission(ACCESS_ADMIN)) {
                «IF targets('3.0')»
                    $menu->addChild(«translate('Settings')», [
                        'route' => '«appName.formatForDB»_config_config',
                    ])
                        ->setAttribute('icon', 'fas fa-wrench')
                        ->setLinkAttribute('title', «translate('Manage settings for this application')»)
                    ;
                «ELSE»
                    $links[] = [
                        'url' => $this->router->generate('«appName.formatForDB»_config_config'),
                        'text' => «translate('Settings')»,
                        'title' => «translate('Manage settings for this application')»,
                        'icon' => 'wrench'
                    ];
                «ENDIF»
            }
        «ENDIF»
    '''

    def private menuLinkToViewAction(Entity it) '''
        if (
            in_array('«name.formatForCode»', $allowedObjectTypes, true)
            && $this->permissionHelper->hasComponentPermission('«name.formatForCode»', $permLevel)
        ) {
            «IF application.targets('3.0')»
                $menu->addChild(«application.translate(nameMultiple.formatForDisplayCapital)», [
                    'route' => '«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . 'view'«/*IF tree != EntityTreeType.NONE»,
                    'routeParameters' => ['tpl' => 'tree']«ENDIF*/»
                ])
                    ->setLinkAttribute('title', «application.translate(nameMultiple.formatForDisplayCapital + ' list')»)
                ;
            «ELSE»
                $links[] = [
                    'url' => $this->router->generate('«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . 'view'«/*IF tree != EntityTreeType.NONE», ['tpl' => 'tree']«ENDIF*/»),
                    'text' => «application.translate(nameMultiple.formatForDisplayCapital)»,
                    'title' => «application.translate(nameMultiple.formatForDisplayCapital + ' list')»
                ];
            «ENDIF»
        }
    '''

    def private menuLinksBetweenControllers(Application it) '''
        if («IF targets('3.0')»self«ELSE»LinkContainerInterface«ENDIF»::TYPE_ADMIN === $type) {
            if ($this->permissionHelper->hasPermission(ACCESS_READ)) {
                «IF targets('3.0')»
                    $menu->addChild(«translate('Frontend')», [
                        'route' => '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_«getLeadingEntity.getPrimaryAction»',
                    ])
                        ->setAttribute('icon', 'fas fa-home')
                        ->setLinkAttribute('title', «translate('Switch to user area.')»)
                    ;
                «ELSE»
                    $links[] = [
                        'url' => $this->router->generate('«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_«getLeadingEntity.getPrimaryAction»'),
                        'text' => «translate('Frontend')»,
                        'title' => «translate('Switch to user area.')»,
                        'icon' => 'home'
                    ];
                «ENDIF»
            }
        } else {
            if ($this->permissionHelper->hasPermission(ACCESS_ADMIN)) {
                «IF targets('3.0')»
                    $menu->addChild(«translate('Backend')», [
                        'route' => '«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»',
                    ])
                        ->setAttribute('icon', 'fas fa-wrench')
                        ->setLinkAttribute('title', «translate('Switch to administration area.')»)
                    ;
                «ELSE»
                    $links[] = [
                        'url' => $this->router->generate('«appName.formatForDB»_«getLeadingEntity.name.formatForDB»_admin«getLeadingEntity.getPrimaryAction»'),
                        'text' => «translate('Backend')»,
                        'title' => «translate('Switch to administration area.')»,
                        'icon' => 'wrench'
                    ];
                «ENDIF»
            }
        }
    '''

    def private translate(Application it, String text) '''«IF targets('3.0')»'«text»'«ELSE»$this->__('«text»'«IF !isSystemModule», '«appName.formatForDB»'«ENDIF»)«ENDIF»'''
}
