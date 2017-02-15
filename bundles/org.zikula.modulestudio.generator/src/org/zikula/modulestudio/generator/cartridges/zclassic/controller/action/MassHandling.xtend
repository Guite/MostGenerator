package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class MassHandling {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''
        «handleSelectedObjects(isBase, true)»
        «handleSelectedObjects(isBase, false)»
    '''

    def private handleSelectedObjects(Entity it, Boolean isBase, Boolean isAdmin) '''
        «handleSelectedObjectsDocBlock(isBase, isAdmin)»
        public function «IF isAdmin»adminH«ELSE»h«ENDIF»andleSelectedEntriesAction(Request $request)
        {
            «IF isBase»
                return $this->handleSelectedEntriesActionInternal($request, «isAdmin.displayBool»);
            «ELSE»
                return parent::«IF isAdmin»adminH«ELSE»h«ENDIF»andleSelectedEntriesAction($request);
            «ENDIF»
        }
        «IF isBase && !isAdmin»

            /**
             * This method includes the common implementation code for adminHandleSelectedEntriesAction() and handleSelectedEntriesAction().
             *
             * @param Request $request Current request instance
             * @param Boolean $isAdmin Whether the admin area is used or not
             */
            protected function handleSelectedEntriesActionInternal(Request $request, $isAdmin = false)
            {
                «handleSelectedObjectsBaseImpl»
            }
        «ENDIF»
    '''

    def private handleSelectedObjectsDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        /**
         * Process status changes for multiple items.
         *
         * This function processes the items selected in the admin view page.
         * Multiple items may have their state changed or be deleted.
         «IF !isBase»
         *
         * @Route("/«nameMultiple.formatForCode»/handleSelectedEntries",
         *        methods = {"POST"}
         * )
         «ENDIF»
        «IF isAdmin»
            «' '»* @Theme("admin")
        «ENDIF»
         *
         * @param Request $request Current request instance
         *
         * @return RedirectResponse
         *
         * @throws RuntimeException Thrown if executing the workflow action fails
         */
    '''

    def private handleSelectedObjectsBaseImpl(Entity it) '''
        $objectType = '«name.formatForCode»';

        // Get parameters
        $action = $request->request->get('action', null);
        $items = $request->request->get('items', null);

        $action = strtolower($action);

        $selectionHelper = $this->get('«application.appService».selection_helper');
        $workflowHelper = $this->get('«application.appService».workflow_helper');
        «IF !skipHookSubscribers»
            $hookHelper = $this->get('«application.appService».hook_helper');
        «ENDIF»
        $logger = $this->get('logger');
        $userName = $this->get('zikula_users_module.current_user')->get('uname');

        // process each item
        foreach ($items as $itemid) {
            // check if item exists, and get record instance
            $entity = $selectionHelper->getEntity($objectType, $itemid«IF application.hasSluggable», ''«ENDIF», false);
            if (null === $entity) {
                continue;
            }
            $entity->initWorkflow();

            // check if $action can be applied to this entity (may depend on it's current workflow state)
            $allowedActions = $workflowHelper->getActionsForObject($entity);
            $actionIds = array_keys($allowedActions);
            if (!in_array($action, $actionIds)) {
                // action not allowed, skip this object
                continue;
            }

            «IF !skipHookSubscribers»
                // Let any hooks perform additional validation actions
                $hookType = $action == 'delete' ? 'validate_delete' : 'validate_edit';
                $validationHooksPassed = $hookHelper->callValidationHooks($entity, $hookType);
                if (!$validationHooksPassed) {
                    continue;
                }

            «ENDIF»
            $success = false;
            try {
                if ($action != 'delete' && !$entity->validate()) {
                    continue;
                }
                // execute the workflow action
                $success = $workflowHelper->executeAction($entity, $action);
            } catch(\Exception $e) {
                $this->addFlash('error', $this->__f('Sorry, but an error occured during the %action% action.', ['%action%' => $action]) . '  ' . $e->getMessage());
                $logger->error('{app}: User {user} tried to execute the {action} workflow action for the {entity} with id {id}, but failed. Error details: {errorMessage}.', ['app' => '«application.appName»', 'user' => $userName, 'action' => $action, 'entity' => '«name.formatForDisplay»', 'id' => $itemid, 'errorMessage' => $e->getMessage()]);
            }

            if (!$success) {
                continue;
            }

            if ($action == 'delete') {
                $this->addFlash('status', $this->__('Done! Item deleted.'));
                $logger->notice('{app}: User {user} deleted the {entity} with id {id}.', ['app' => '«application.appName»', 'user' => $userName, 'entity' => '«name.formatForDisplay»', 'id' => $itemid]);
            } else {
                $this->addFlash('status', $this->__('Done! Item updated.'));
                $logger->notice('{app}: User {user} executed the {action} workflow action for the {entity} with id {id}.', ['app' => '«application.appName»', 'user' => $userName, 'action' => $action, 'entity' => '«name.formatForDisplay»', 'id' => $itemid]);
            }
            «IF !skipHookSubscribers»

                // Let any hooks know that we have updated or deleted an item
                $hookType = $action == 'delete' ? 'process_delete' : 'process_edit';
                $url = null;
                if ($action != 'delete') {
                    $urlArgs = $entity->createUrlArgs();
                    $urlArgs['_locale'] = $request->getLocale();
                    $url = new RouteUrl('«application.appName.formatForDB»_«name.formatForCode»_' . /*($isAdmin ? 'admin' : '') . */'display', $urlArgs);
                }
                $hookHelper->callProcessHooks($entity, $hookType, $url);
            «ENDIF»
        }

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_' . ($isAdmin ? 'admin' : '') . 'index');
    '''
}
