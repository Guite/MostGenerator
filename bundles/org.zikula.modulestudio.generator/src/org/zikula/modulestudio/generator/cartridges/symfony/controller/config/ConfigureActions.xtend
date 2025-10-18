package org.zikula.modulestudio.generator.cartridges.symfony.controller.config

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerMethodInterface
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions

class ConfigureActions implements ControllerMethodInterface {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions

    override void init(Entity it) {}

    override imports(Entity it) {
        val imports = newArrayList
        imports.addAll(#[
            'EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Action',
            'EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Actions',
            'EasyCorp\\Bundle\\EasyAdminBundle\\Config\\Crud'
        ])
        if (hasIndexAction) {
            imports.add('EasyCorp\\Bundle\\EasyAdminBundle\\Dto\\BatchActionDto')
        }
        imports
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
        «IF hasIndexAction»
            «batchActions»
        «ENDIF»

    '''

    def private batchActions(Entity it) '''
        «/* TODO permission checks */»
        «IF approval»
            ->addBatchAction(Action::new('approve', t('Approve «nameMultiple.formatForDisplayCapital»'))
                ->linkToCrudAction('handleSelectedEntries', ['action' => 'approve'])
                ->setIcon('fa fa-check-circle')
            )
            ->addBatchAction(Action::new('demote', t('Demote «nameMultiple.formatForDisplayCapital»'))
                ->linkToCrudAction('handleSelectedEntries', ['action' => 'demote'])
                ->setIcon('fa fa-arrow-down')
            )
            «IF ownerPermission»
                ->addBatchAction(Action::new('reject', t('Reject «nameMultiple.formatForDisplayCapital»'))
                    ->linkToCrudAction('handleSelectedEntries', ['action' => 'reject'])
                    ->setIcon('fa fa-times-circle')
                )
            «ENDIF»
        «ENDIF»
        «IF hasArchive»
            ->addBatchAction(Action::new('archive', t('Archive «nameMultiple.formatForDisplayCapital»'))
                ->linkToCrudAction('handleSelectedEntries', ['action' => 'archive'])
                ->setIcon('fa fa-archive')
            )
            ->addBatchAction(Action::new('unarchive', t('Unarchive «nameMultiple.formatForDisplayCapital»'))
                ->linkToCrudAction('handleSelectedEntries', ['action' => 'unarchive'])
                ->setIcon('fa fa-box-open')
            )
        «ENDIF»
    '''
}
