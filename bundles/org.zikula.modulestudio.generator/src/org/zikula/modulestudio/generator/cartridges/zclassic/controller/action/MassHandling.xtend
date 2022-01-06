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

        «handleSelectedObjects(isBase, true)»

        «handleSelectedObjects(isBase, false)»
    '''

    def private handleSelectedObjects(Entity it, Boolean isBase, Boolean isAdmin) '''
        «IF !isBase»
            «handleSelectedObjectsDocBlock(isBase, isAdmin)»
            public function «IF isAdmin»adminH«ELSE»h«ENDIF»andleSelectedEntries«IF !application.targets('3.1')»Action«ENDIF»(
                «handleSelectedObjectsArguments(false)»
            ): RedirectResponse {
                return $this->handleSelectedEntriesInternal(
                    $request,
                    $logger,
                    $entityFactory,
                    $workflowHelper,«IF !skipHookSubscribers»
                    $hookHelper,«ENDIF»
                    $currentUserApi,
                    «isAdmin.displayBool»
                );
            }
        «ELSEIF isBase && !isAdmin»
            «handleSelectedObjectsDocBlock(isBase, isAdmin)»
            protected function handleSelectedEntriesInternal(
                «handleSelectedObjectsArguments(true)»
            ): RedirectResponse {
                «handleSelectedObjectsBaseImpl»
            }
        «ENDIF»
    '''

    def private handleSelectedObjectsDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        /**
         * Process status changes for multiple items.
         *
         «IF isBase»
         * This function processes the items selected in the admin view page.
         * Multiple items may have their state changed or be deleted.
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         «ELSE»
         * @Route("/«IF isAdmin»admin/«ENDIF»«nameMultiple.formatForCode»/handleSelectedEntries",
         *        methods = {"POST"}
         * )
         «IF isAdmin»
              * @Theme("admin")
         «ENDIF»
         «ENDIF»
         */
    '''

    def private handleSelectedObjectsArguments(Entity it, Boolean internalMethod) '''
        Request $request,
        LoggerInterface $logger,
        EntityFactory $entityFactory,
        WorkflowHelper $workflowHelper,
        «IF !skipHookSubscribers»
            HookHelper $hookHelper,
        «ENDIF»
        CurrentUserApiInterface $currentUserApi«IF internalMethod»,
        bool $isAdmin = false«ENDIF»
    '''

    def private handleSelectedObjectsBaseImpl(Entity it) '''
        $objectType = '«name.formatForCode»';

        // get parameters
        $action = $request->request->get('action');
        $items = $request->request->get('items');
        if (!is_array($items) || !count($items)) {
            return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . '«getPrimaryAction»');
        }

        $action = mb_strtolower($action);

        $repository = $entityFactory->getRepository($objectType);
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

            «IF !skipHookSubscribers»
                if ($entity->supportsHookSubscribers()) {
                    // let any ui hooks perform additional validation actions
                    $hookType = 'delete' === $action
                        ? UiHooksCategory::TYPE_VALIDATE_DELETE
                        : UiHooksCategory::TYPE_VALIDATE_EDIT
                    ;
                    $validationErrors = $hookHelper->callValidationHooks($entity, $hookType);
                    if (count($validationErrors) > 0) {
                        foreach ($validationErrors as $message) {
                            $this->addFlash('error', $message);
                        }
                        continue;
                    }
                }

            «ENDIF»
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
                    «IF application.isSystemModule»
                        'Done! «name.formatForDisplayCapital» deleted.'
                    «ELSE»
                        $this->trans(
                            'Done! «name.formatForDisplayCapital» deleted.',
                            [],
                            '«name.formatForCode»'
                        )
                    «ENDIF»
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
                    «IF application.isSystemModule»
                        'Done! «name.formatForDisplayCapital» updated.'
                    «ELSE»
                        $this->trans(
                            'Done! «name.formatForDisplayCapital» updated.',
                            [],
                            '«name.formatForCode»'
                        )
                    «ENDIF»
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
            «IF !skipHookSubscribers»

                if ($entity->supportsHookSubscribers()) {
                    // let any ui hooks know that we have updated or deleted an item
                    $hookType = 'delete' === $action
                        ? UiHooksCategory::TYPE_PROCESS_DELETE
                        : UiHooksCategory::TYPE_PROCESS_EDIT
                    ;
                    $url = null;
                    «IF hasDisplayAction»
                        if ('delete' !== $action) {
                            $urlArgs = $entity->createUrlArgs();
                            $urlArgs['_locale'] = $request->getLocale();
                            $url = new RouteUrl('«application.appName.formatForDB»_«name.formatForDB»_display', $urlArgs);
                        }
                    «ENDIF»
                    $hookHelper->callProcessHooks($entity, $hookType, $url);
                }
            «ENDIF»
        }

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . '«getPrimaryAction»');
    '''
}
