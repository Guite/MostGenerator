package org.zikula.modulestudio.generator.cartridges.zclassic.controller.config

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.cartridges.zclassic.controller.ControllerMethodInterface

class ConfigureActions implements ControllerMethodInterface {

    extension ControllerExtensions = new ControllerExtensions

    override void init(Entity it) {}

    override imports(Entity it) {
        #[
            'EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Action',
            'EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Actions',
            'EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Crud'
        ]
    }

    override generateMethod(Entity it) '''
        public function configureActions(Actions $actions): Actions
        {
            return $actions
                «methodBody»
            ;
        }
    '''

    def private methodBody(Entity it) '''
        «IF !hasIndexAction»
            ->disable(Action::INDEX«IF !hasDeleteAction», Action::DELETE«/* disables also batch delete */»«ENDIF»)
        «ENDIF»
        «IF !hasDetailAction»
            ->disable(Action::DETAIL)
        «ENDIF»
        «IF !hasEditAction»
            ->disable(Action::EDIT, Action::NEW)
        «ENDIF»
        «IF hasIndexAction»
            «IF hasDetailAction»
                ->add(Crud::PAGE_INDEX, Action::DETAIL)
            «ENDIF»
        «ENDIF»
        «IF hasEditAction»
            «IF hasIndexAction»
                ->add(Crud::PAGE_EDIT, Action::INDEX)
                ->add(Crud::PAGE_NEW, Action::INDEX)
            «ENDIF»
            «IF hasDetailAction»
                ->add(Crud::PAGE_EDIT, Action::DETAIL)
            «ENDIF»
            «IF hasDeleteAction»
                ->add(Crud::PAGE_EDIT, Action::DELETE)
            «ENDIF»
            ->add(Crud::PAGE_NEW, Action::SAVE_AND_CONTINUE)
        «ENDIF»
    '''
}
