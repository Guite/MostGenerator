package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

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
                    $request,
                    $repository,
                    $workflowHelper,
                    $currentUserApi,
                    $logger
                );
            «ENDIF»
        }
    '''

    def private handleSelectedObjectsDocBlock(Entity it, Boolean isBase) '''
        «IF isBase»
            /**
             * Process status changes for multiple items.
             *
             * This function processes the items selected in the admin view page.
             * Multiple items may have their state changed or be deleted.
             *
             * @throws RuntimeException Thrown if executing the workflow action fails
             */
        «ELSE»
            #[Route('/«nameMultiple.formatForCode»/handleSelectedEntries',
                name: '«application.name.formatForDB»_«name.formatForDB»_handleselectedentries',
                methods: ['POST']
            )]
        «ENDIF»
    '''

    def private handleSelectedObjectsArguments(Entity it) '''
        Request $request,
        «name.formatForCodeCapital»RepositoryInterface $repository,
        WorkflowHelper $workflowHelper,
        CurrentUserApiInterface $currentUserApi,
        LoggerInterface $logger
    '''

    def private handleSelectedObjectsBaseImpl(Entity it) '''
        // get parameters
        $action = $request->request->get('action');
        $items = $request->request->get('items');
        if (!is_array($items) || !count($items)) {
            return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_«getPrimaryAction»');
        }

        $action = mb_strtolower($action);

        $userName = $currentUserApi->get('uname');

        // process each item
        foreach ($items as $itemId) {
            // check if item exists, and get record instance
            $entity = $repository->selectById($itemId, false);
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
                        'id' => $itemId,
                        'errorMessage' => $exception->getMessage(),
                    ]
                );
            }

            if (!$success) {
                continue;
            }

            if ('delete' === $action) {
                $this->addFlash(
                    'status',
                    $this->trans(
                        'Done! «name.formatForDisplayCapital» deleted.',
                        [],
                        '«name.formatForCode»'
                    )
                );
                $logger->notice(
                    '{app}: User {user} deleted the {entity} with id {id}.',
                    [
                        'app' => '«application.appName»',
                        'user' => $userName,
                        'entity' => '«name.formatForDisplay»',
                        'id' => $itemId,
                    ]
                );
            } else {
                $this->addFlash(
                    'status',
                    $this->trans(
                        'Done! «name.formatForDisplayCapital» updated.',
                        [],
                        '«name.formatForCode»'
                    )
                );
                $logger->notice(
                    '{app}: User {user} executed the {action} workflow action for the {entity} with id {id}.',
                    [
                        'app' => '«application.appName»',
                        'user' => $userName,
                        'action' => $action,
                        'entity' => '«name.formatForDisplay»',
                        'id' => $itemId,
                    ]
                );
            }
        }

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_«getPrimaryAction»');
    '''
}
