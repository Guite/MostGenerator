package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ApplyTreeOperation extends AbstractAction {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    override name(Application it) {
        'ApplyTreeOperation'
    }

    override requiredFor(Entity it) {
        tree
    }

    override protected imports(Application it) {
        val imports = <String>newArrayList
        imports.addAll(#[
            'Doctrine\\Persistence\\ManagerRegistry',
            'Psr\\Log\\LoggerInterface',
            'Symfony\\Bundle\\FrameworkBundle\\Controller\\ControllerHelper',
            'Symfony\\Component\\HttpFoundation\\JsonResponse',
            'Symfony\\Component\\Security\\Core\\User\\UserInterface',
            'Symfony\\Component\\Security\\Http\\Attribute\\CurrentUser',
            'Symfony\\Component\\Security\\Http\\Attribute\\IsGranted',
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            appNamespace + '\\Entity\\Initializer\\EntityInitializer',
            appNamespace + '\\Helper\\EntityDisplayHelper',
            appNamespace + '\\Helper\\WorkflowHelper'
        ])
        if (!entitiesWithEditableTree.empty) {
            imports.add('Symfony\\Component\\Routing\\Generator\\UrlGeneratorInterface')
            imports.add('Symfony\\Component\\Routing\\RouterInterface')
        }
        imports
    }

    override protected constructorArguments(Application it) {
        val result = <String>newArrayList
        result.addAll(#[
            'ControllerHelper $controllerHelper',
            'ManagerRegistry $managerRegistry',
            'TranslatorInterface $translator',
            'EntityInitializer $entityInitializer',
            'EntityDisplayHelper $entityDisplayHelper',
            'WorkflowHelper $workflowHelper',
            'LoggerInterface $logger'
        ])
        if (!entitiesWithEditableTree.empty) {
            result.add('RouterInterface $router')
        }
        result
    }

    override protected invocationArguments(Application it, Boolean call) {
        val result = <String>newArrayList
        result.add('Request $request')
        result.add('#[CurrentUser] ?UserInterface $currentUser')
        if (call) {
            result.add('string $objectType')
            result.add('string $redirectRoute')
            result.add('bool $isSluggable')
        }
        result
    }

    override protected docBlock(Application it) '''
        /**
         * Performs different operations on tree hierarchies.
         */
    '''

    override protected returnType(Application it) { 'JsonResponse' }

    override protected controllerPreprocessing(Entity it) '''
        $objectType = '«name.formatForCode»';
        $redirectRoute = «IF hasEditAction»'«application.routePrefix»_«nameMultiple.formatForDB»_edit'«ELSE»null«ENDIF»;
        $isSluggable = «IF hasSluggableFields»true«ELSE»false«ENDIF»;

    '''

    override protected controllerAttributes(Application it, Entity entity) '''
        #[IsGranted('ROLE_EDITOR')]
    '''

    override protected routeMethods(Entity it) '''['POST']'''

    override protected routeOptions(Entity it) '''options: ['expose' => true]'''

    override protected implBody(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->controllerHelper->json(
                $this->translator->trans('Only ajax access is allowed!'),
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $data = [
            'data' => [],
            'result' => 'success',
            'message' => '',
        ];

        «prepareTreeOperationParameters»

        «entityMatchBlock(treeEntities)»

        $entityManager = $this->managerRegistry->getManagerForClass($entityFqcn);
        $repository = $this->managerRegistry->getRepository($entityFqcn);
        $initMethod = 'init' . ucfirst($objectType);

        $rootId = 1;
        if (!in_array($op, ['addRootNode'], true)) {
            $rootId = $request->request->get('root');
            if (!$rootId) {
                $data['result'] = 'failure';
                $data['message'] = $this->translator->trans('Error: invalid root node.');

                return $this->controllerHelper->json($data);
            }
        }

        $titleFieldName = $entityDisplayHelper->getTitleFieldName($objectType);
        $descriptionFieldName = $entityDisplayHelper->getDescriptionFieldName($objectType);

        «treeOperationSwitch»

        $data['message'] = $this->translator->trans('The operation was successful.');

        // renew tree
        /* postponed, for now we do a page reload.
         * $data['data'] = $repository->selectTree($rootId);
         */

        return $this->controllerHelper->json($data);
    '''

    def private prepareTreeOperationParameters(Application it) '''
        $op = $request->request->getAlpha('op');
        if (!in_array($op, ['addRootNode', 'addChildNode', 'deleteNode', 'moveNode', 'moveNodeTo'], true)) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('Error: invalid operation.');

            return $this->controllerHelper->json($data);
        }

        // Get id of treated node
        $id = 0;
        if (!in_array($op, ['addRootNode', 'addChildNode'], true)) {
            $id = $request->request->get('id');
            if (!$id) {
                $data['result'] = 'failure';
                $data['message'] = $this->translator->trans('Error: invalid node.');

                return $this->controllerHelper->json($data);
            }
        }
    '''

    def private treeOperationSwitch(Application it) '''
        $logArgs = ['app' => '«appName»', 'user' => $currentUser?->getUserIdentifier(), 'entity' => $objectType];

        switch ($op) {
            case 'addRootNode':
                «treeOperationAddRootNode»

                $logger->notice('{app}: User {user} added a new root node in the {entity} tree.', $logArgs);
                break;
            case 'addChildNode':
                «treeOperationAddChildNode»

                $logger->notice('{app}: User {user} added a new child node in the {entity} tree.', $logArgs);
                break;
            case 'deleteNode':
                «treeOperationDeleteNode»

                $logger->notice('{app}: User {user} deleted a node from the {entity} tree.', $logArgs);
                break;
            case 'moveNode':
                «treeOperationMoveNode»

                $logger->notice('{app}: User {user} moved a node in the {entity} tree.', $logArgs);
                break;
            case 'moveNodeTo':
                «treeOperationMoveNodeTo»

                $logger->notice('{app}: User {user} moved a node in the {entity} tree.', $logArgs);
                break;
        }
    '''

    def private treeOperationAddRootNode(Application it) '''
        $entity = new $entityFqcn();
        $entityInitializer->$initMethod($entity);
        if (!empty($titleFieldName)) {
            $setter = 'set' . ucfirst($titleFieldName);
            $entity->$setter($this->trans('New root node'));
        }
        if (!empty($descriptionFieldName)) {
            $setter = 'set' . ucfirst($descriptionFieldName);
            $entity->$setter($this->trans('This is a new root node'));
        }
        «IF hasStandardFieldEntities»
            if (method_exists($entity, 'setCreatedBy')) {
                $entity->setCreatedBy($currentUser);
                $entity->setUpdatedBy($currentUser);
            }
        «ENDIF»«/*IF hasTranslatableFields»
            $entity->setLocale($request->getLocale());
        «ENDIF*/»

        // save new object to set the root id
        $action = 'submit';
        try {
            // execute the workflow action
            $success = $this->workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $data['result'] = 'failure';
            }
        } catch (\Throwable $exception) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->controllerHelper->json($data);
        }
    '''

    def private treeOperationAddChildNode(Application it) '''
        $parentId = $request->request->get('pid');
        if (!$parentId) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('Error: invalid parent node.');

            return $this->controllerHelper->json($data);
        }

        $childEntity = new $entityFqcn();
        $entityInitializer->$initMethod($childEntity);
        $setter = 'set' . ucfirst($titleFieldName);
        $childEntity->$setter($this->translator->trans('New child node'));
        if (!empty($descriptionFieldName)) {
            $setter = 'set' . ucfirst($descriptionFieldName);
            $childEntity->$setter($this->translator->trans('This is a new child node'));
        }
        «IF hasStandardFieldEntities»
            if (method_exists($childEntity, 'setCreatedBy')) {
                $childEntity->setCreatedBy($currentUser);
                $childEntity->setUpdatedBy($currentUser);
            }
        «ENDIF»
        $parentEntity = $repository->selectById($parentId, false);
        if (null === $parentEntity) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('No such item.');

            return $this->controllerHelper->json($data);
        }
        $childEntity->setParent($parentEntity);

        // save new object
        $action = 'submit';
        try {
            // execute the workflow action
            $success = $this->workflowHelper->executeAction($childEntity, $action);
            «IF !entitiesWithEditableTree.empty»
                if (!$success) {
                    $data['result'] = 'failure';
                } elseif (in_array($objectType, ['«entitiesWithEditableTree.map[name.formatForCode].join('\', \'')»'], true)) {
                    «IF !treeEntities.filter[hasEditAction && hasSluggableFields].empty»
                        $urlArgs = $isSluggable ? $childEntity->getRouteParameters(includeId: true) : $childEntity->getRouteParameters();
                    «ELSE»
                        $urlArgs = $childEntity->getRouteParameters();
                    «ENDIF»
                    $data['returnUrl'] = $this->router->generate(
                        $redirectRoute,
                        $urlArgs,
                        UrlGeneratorInterface::ABSOLUTE_URL
                    );
                }
            «ELSE»
                if (!$success) {
                    $data['result'] = 'failure';
                }
            «ENDIF»
        } catch (Exception $exception) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->controllerHelper->json($data);
        }
    '''

    def private entitiesWithEditableTree(Application it) {
        entities.filter[tree && hasEditAction]
    }

    def private treeOperationDeleteNode(Application it) '''
        // remove node from tree and reparent all children
        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('No such item.');

            return $this->controllerHelper->json($data);
        }

        // delete the object
        $action = 'delete';
        try {
            // execute the workflow action
            $success = $this->workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $data['result'] = 'failure';
            }
        } catch (Exception $exception) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->controllerHelper->json($data);
        }

        $repository->removeFromTree($entity);
        $entityManager->clear(); // clear cached nodes
    '''

    def private treeOperationMoveNode(Application it) '''
        $moveDirection = $request->request->getAlpha('direction');
        if (!in_array($moveDirection, ['top', 'up', 'down', 'bottom'], true)) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('Error: invalid direction.');

            return $this->controllerHelper->json($data);
        }

        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('No such item.');

            return $this->controllerHelper->json($data);
        }

        if ('top' === $moveDirection) {
            $repository->moveUp($entity, true);
        } elseif ('up' === $moveDirection) {
            $repository->moveUp($entity, 1);
        } elseif ('down' === $moveDirection) {
            $repository->moveDown($entity, 1);
        } elseif ('bottom' === $moveDirection) {
            $repository->moveDown($entity, true);
        }
        $entityManager->flush();
    '''

    def private treeOperationMoveNodeTo(Application it) '''
        $moveDirection = $request->request->getAlpha('direction');
        if (!in_array($moveDirection, ['after', 'before', 'bottom'], true)) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('Error: invalid direction.');

            return $this->controllerHelper->json($data);
        }

        $destId = $request->request->get('destId');
        if (!$destId) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('Error: invalid destination node.');

            return $this->controllerHelper->json($data);
        }

        $entity = $repository->selectById($id, false);
        $destEntity = $repository->selectById($destId, false);
        if (null === $entity || null === $destEntity) {
            $data['result'] = 'failure';
            $data['message'] = $this->translator->trans('No such item.');

            return $this->controllerHelper->json($data);
        }

        if ('after' === $moveDirection) {
            $repository->persistAsNextSiblingOf($entity, $destEntity);
        } elseif ('before' === $moveDirection) {
            $repository->persistAsPrevSiblingOf($entity, $destEntity);
        } elseif ('bottom' === $moveDirection) {
            $repository->persistAsLastChildOf($entity, $destEntity);
        }

        $entityManager->flush();
    '''
}
