package org.zikula.modulestudio.generator.cartridges.symfony.controller.config

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerMethodInterface
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelJoinExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ConfigureActions implements ControllerMethodInterface {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelJoinExtensions = new ModelJoinExtensions
    extension Utils = new Utils

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
        if (!getIncomingRelationsWithAutocomplete.empty || !getOutcomingRelationsWithAutocomplete.empty) {
            imports.addAll(#[
                'EasyCorp\\Bundle\\EasyAdminBundle\\Context\\AdminContext',
                'Symfony\\Component\\HttpFoundation\\JsonResponse'
            ])    
        }
        imports.add(application.appNamespace + '\\Security\\Permission')
        imports
    }

    override generateMethod(Entity it) '''
        public function configureActions(Actions $actions): Actions
        {
            $actions
                «standardActions»
            ;
            «IF hasEditAction»

                $canBeCreated = $this->modelHelper->canBeCreated('«name.formatForCode»');
                if (!$canBeCreated) {
                    $actions->disable(Action::NEW);
                }
            «ENDIF»
            «customActions»

            return $actions;
        }
    '''

    def private getDisallowedStandardActions(Entity it) {
        val actionNames = <String>newArrayList
        if (!hasIndexAction) {
            actionNames += 'INDEX'
        }
        if (!hasDetailAction) {
            actionNames += 'DETAIL'
        }
        if (!hasEditAction) {
            actionNames += 'EDIT'
            actionNames += 'NEW'
        }
        if (!hasDeleteAction) {
            actionNames += 'DELETE' // disables also batch delete
        }
        actionNames
    }

    def private standardActions(Entity it) '''
        «IF !disallowedStandardActions.empty»
            ->disable(«FOR actionName : disallowedStandardActions SEPARATOR ', '»Action::«actionName»«ENDFOR»)
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
            ->setPermission(Action::INDEX, Permission::LIST->value)
        «ENDIF»
        «IF hasDetailAction»
            ->setPermission(Action::DETAIL, Permission::DETAIL->value)
        «ENDIF»
        «IF hasEditAction»
            ->setPermission(Action::EDIT, Permission::EDIT->value)
            ->setPermission(Action::NEW, Permission::CREATE->value)
        «ENDIF»
        «IF hasDeleteAction»
            ->setPermission(Action::DELETE, Permission::DELETE->value)
            «IF hasIndexAction»
                ->setPermission(Action::BATCH_DELETE, Permission::DELETE->value)
            «ENDIF»
        «ENDIF»
        «IF hasEditAction»
            ->setPermission(Action::SAVE_AND_ADD_ANOTHER, Permission::CREATE->value)
            ->setPermission(Action::SAVE_AND_CONTINUE, Permission::EDIT->value)
            ->setPermission(Action::SAVE_AND_RETURN, Permission::EDIT->value)
        «ENDIF»
    '''

    def private customActions(Entity it) '''
        «IF hasIndexAction && (approval || hasArchive)»

            $actions
                «batchActions»
            ;
        «ENDIF»
        «IF loggable»

            $viewHistory = Action::new('history', t('History'), 'fa fa-history')
                ->linkToCrudAction('history')
                ->setIcon('fa fa-timeline')
            ;
            $actions->add(Crud::PAGE_DETAIL, $viewHistory)
                ->setPermission('history', Permission::HISTORY->value);
        «ENDIF»
    '''

    def private batchActions(Entity it) '''
        «IF approval»
            ->addBatchAction(Action::new('approve', t('Approve «nameMultiple.formatForDisplayCapital»'))
                ->linkToCrudAction('applyBulkOperation', ['action' => 'approve'])
                ->setIcon('fa fa-check-circle')
            )
            ->setPermission('approve', Permission::MODERATE->value)
            ->addBatchAction(Action::new('demote', t('Demote «nameMultiple.formatForDisplayCapital»'))
                ->linkToCrudAction('applyBulkOperation', ['action' => 'demote'])
                ->setIcon('fa fa-arrow-down')
            )
            ->setPermission('demote', Permission::MODERATE->value)
            «IF ownerPermission»
                ->addBatchAction(Action::new('reject', t('Reject «nameMultiple.formatForDisplayCapital»'))
                    ->linkToCrudAction('applyBulkOperation', ['action' => 'reject'])
                    ->setIcon('fa fa-times-circle')
                )
                ->setPermission('reject', Permission::MODERATE->value)
            «ENDIF»
        «ENDIF»
        «IF hasArchive»
            ->addBatchAction(Action::new('archive', t('Archive «nameMultiple.formatForDisplayCapital»'))
                ->linkToCrudAction('applyBulkOperation', ['action' => 'archive'])
                ->setIcon('fa fa-archive')
            )
            ->setPermission('archive', Permission::MODERATE->value)
            ->addBatchAction(Action::new('unarchive', t('Unarchive «nameMultiple.formatForDisplayCapital»'))
                ->linkToCrudAction('applyBulkOperation', ['action' => 'unarchive'])
                ->setIcon('fa fa-box-open')
            )
            ->setPermission('unarchive', Permission::MODERATE->value)
        «ENDIF»
    '''

    def private getIncomingRelationsWithAutocomplete(Entity it) {
        getCommonRelations(true).filter[usesAutoCompletion(false)]
    }

    def private getOutcomingRelationsWithAutocomplete(Entity it) {
        getCommonRelations(false).filter[usesAutoCompletion(true)]
    }
}
