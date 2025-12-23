package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MassHandling {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''

        «handleSelectedObjects(isBase)»
    '''

    def private handleSelectedObjects(Entity it, Boolean isBase) '''
        «handleSelectedObjectsDocBlock(isBase)»
        public function handleSelectedEntries(
            «handleSelectedObjectsArguments»
        ): RedirectResponse {
            «IF isBase»
                «handleSelectedObjectsBaseImpl»
            «ELSE»
                return $this->handleSelectedEntries(
                    $batchActionDto,
                    $request,
                    $repository,
                    $workflowHelper,
                    $currentUser,
                    $logger
                );
            «ENDIF»
        }
    '''

    def private handleSelectedObjectsDocBlock(Entity it, Boolean isBase) '''
        «IF isBase»
            /**
             * Process status changes for multiple entities.
             *
             * This function processes the entities selected in the admin view page.
             * Multiple entities may have their state changed or be deleted.
             *
             * @throws RuntimeException Thrown if executing the workflow action fails
             */
        «/*ELSE»
            #[Route('/admin/«nameMultiple.formatForCode»/handleSelectedEntries',
                name: '«application.appName.formatForDB»_admin_«name.formatForDB»_handleselectedentries',
                methods: ['POST']
            )]
        */»«ENDIF»
    '''

    def private handleSelectedObjectsArguments(Entity it) '''
        BatchActionDto $batchActionDto,
        Request $request,
        «name.formatForCodeCapital»RepositoryInterface $repository,
        WorkflowHelper $workflowHelper,
        #[CurrentUser] ?UserInterface $currentUser,
        LoggerInterface $logger
    '''

    def private handleSelectedObjectsBaseImpl(Entity it) '''
        // get parameters
        «/* TODO for later $className = $batchActionDto->getEntityFqcn(); */»
        $action = $request->request->get('action');
        $entityIds = $batchActionDto->getEntityIds();
        if (!count($entityIds)) {
            return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_«getPrimaryAction»');
        }

        $action = mb_strtolower($action);

        $userName = $currentUser?->getUserIdentifier();

        // process each entity
        foreach ($entityIds as $entityId) {
            // check if entity exists
            $entity = $repository->selectById($entityId, false);
            if (null === $entity) {
                continue;
            }

            // check if $action can be applied to this entity (may depend on it's current workflow state)
            $allowedActions = $workflowHelper->getActionsForObject($entity);
            $actionIds = array_keys($allowedActions);
            if (!in_array($action, $actionIds, true)) {
                // action not allowed, skip this object
                continue;
            }

            $success = false;
            try {
                // execute the workflow action
                $success = $workflowHelper->executeAction($entity, $action);
            } catch (Exception $exception) {
                $this->addFlash(
                    'error',
                    $this->trans(
                        'Sorry, but an error occured during the %action% action.',
                        ['%action%' => $action]
                    ) . '  ' . $exception->getMessage()
                );
                $logger->error(
                    '{app}: User {user} tried to execute the {action} workflow action for the {entity} with id {id},'
                        . ' but failed. Error details: {errorMessage}.',
                    [
                        'app' => '«application.appName»',
                        'user' => $userName,
                        'action' => $action,
                        'entity' => '«name.formatForDisplay»',
                        'id' => $entityId,
                        'errorMessage' => $exception->getMessage(),
                    ]
                );
            }

            if (!$success) {
                continue;
            }

            if ('delete' === $action) {
                $status = t('Done! «name.formatForDisplayCapital» deleted.');
                $logMsg = '{app}: User {user} deleted the {entity} with id {id}.';
            } else {
                $status = t('Done! «name.formatForDisplayCapital» updated.');
                $logMsg = '{app}: User {user} applied the {action} action for the {entity} with id {id}.';
            }

            $this->addFlash(
                'status',
                $this->trans($status, [], '«name.formatForCode»')
            );
            $logger->notice(
                $logMsg,
                [
                    'app' => '«application.appName»',
                    'user' => $userName,
                    'action' => $action,
                    'entity' => '«name.formatForDisplay»',
                    'id' => $entityId,
                ]
            );
        }

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_«getPrimaryAction»');
    '''
}
