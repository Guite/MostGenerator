package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ApplyBulkOperation extends AbstractAction {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    override name(Application it) {
        'ApplyBulkOperation'
    }

    override requiredFor(Entity it) {
        hasIndexAction
    }

    override protected imports(Application it) {
        #[
            'Doctrine\\Persistence\\ManagerRegistry',
            'EasyCorp\\Bundle\\EasyAdminBundle\\Dto\\BatchActionDto',
            'Psr\\Log\\LoggerInterface',
            'Symfony\\Bundle\\FrameworkBundle\\Controller\\ControllerHelper',
            'Symfony\\Component\\HttpFoundation\\RedirectResponse',
            'Symfony\\Component\\HttpFoundation\\Request',
            'Symfony\\Component\\Security\\Core\\User\\UserInterface',
            'Symfony\\Component\\Security\\Http\\Attribute\\CurrentUser',
            'function Symfony\\Component\\Translation\\t',
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            appNamespace + '\\Helper\\WorkflowHelper'
        ]
    }

    override protected constructorArguments(Application it) {
        #[
            'ControllerHelper $controllerHelper',
            'ManagerRegistry $managerRegistry',
            'WorkflowHelper $workflowHelper',
            'TranslatorInterface $translator',
            'LoggerInterface $logger'
        ]
    }

    override protected Iterable<String> invocationArguments(Application it, Boolean call) {
        val result = <String>newArrayList
        result.addAll(#[
            'BatchActionDto $batchActionDto',
            'Request $request',
            '#[CurrentUser] ?UserInterface $currentUser'
        ])
        if (call) {
            result.add('string $objectType')
            result.add('string $entityDisplayName')
            result.add('string $redirectRoute')
        }
        result
    }

    override protected docBlock(Application it) '''
        /**
         * Process status changes for multiple entities.
         *
         * This function processes the entities selected on the index page.
         * Multiple entities may have their state changed or be deleted.
         *
         * @throws \RuntimeException Thrown if executing the workflow action fails
         */
    '''

    override protected returnType(Application it) { 'RedirectResponse' }

    override protected controllerPreprocessing(Entity it) '''
        $objectType = '«name.formatForCode»';
        $entityDisplayName = '«name.formatForDisplay»';
        $redirectRoute = '«application.routePrefix»_«nameMultiple.formatForDB»_«getPrimaryAction»';

    '''

    override protected routeMethods(Entity it) '''['POST']'''

    override protected implBody(Application it) '''
        $entityIds = $batchActionDto->getEntityIds();
        if (!count($entityIds)) {
            return $this->controllerHelper->redirectToRoute($redirectRoute);
        }

        $action = mb_strtolower($request->request->get('action'));
        $entityFqcn = $batchActionDto->getEntityFqcn();
        $repository = $this->managerRegistry->getRepository($entityFqcn);

        $userName = $currentUser?->getUserIdentifier();

        // process each entity
        foreach ($entityIds as $entityId) {
            // check if entity exists
            $entity = $repository->selectById($entityId, false);
            if (null === $entity) {
                continue;
            }

            // check if $action can be applied to this entity (may depend on it's current workflow state)
            $allowedActions = $this->workflowHelper->getActionsForObject($entity);
            $actionIds = array_keys($allowedActions);
            if (!in_array($action, $actionIds, true)) {
                // action not allowed, skip this object
                continue;
            }

            $success = false;
            try {
                // execute the workflow action
                $success = $this->workflowHelper->executeAction($entity, $action);
            } catch (\Exception $exception) {
                $this->controllerHelper->addFlash(
                    'error',
                    $this->translator->trans(
                        'Sorry, but an error occured during the %action% action.',
                        ['%action%' => $action]
                    ) . '  ' . $exception->getMessage()
                );
                $this->logger->error(
                    '{app}: User {user} tried to execute the {action} workflow action for the {entity} with id {id},'
                        . ' but failed. Error details: {errorMessage}.',
                    [
                        'app' => '«appName»',
                        'user' => $userName,
                        'action' => $action,
                        'entity' => $entityDisplayName,
                        'id' => $entityId,
                        'errorMessage' => $exception->getMessage(),
                    ]
                );
            }

            if (!$success) {
                continue;
            }

            if ('delete' === $action) {
                $status = t('Done! ' . ucfirst($entityDisplayName) . ' deleted.');
                $logMsg = '{app}: User {user} deleted the {entity} with id {id}.';
            } else {
                $status = t('Done! ' . ucfirst($entityDisplayName) . ' updated.');
                $logMsg = '{app}: User {user} applied the {action} action for the {entity} with id {id}.';
            }

            $this->controllerHelper->addFlash(
                'status',
                $this->translator->trans($status, [], $objectType)
            );
            $this->logger->notice(
                $logMsg,
                [
                    'app' => '«appName»',
                    'user' => $userName,
                    'action' => $action,
                    'entity' => $entityDisplayName,
                    'id' => $entityId,
                ]
            );
        }

        return $this->controllerHelper->redirectToRoute($redirectRoute);
    '''
}
