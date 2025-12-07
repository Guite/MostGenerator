package org.zikula.modulestudio.generator.cartridges.symfony.controller.additions

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.application.ImportList
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class AjaxController {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating ajax controller class'.printIfNotTesting(fsa)
        fsa.generateClassPair('Controller/AjaxController.php', ajaxControllerBaseClass, ajaxControllerImpl)
    }

    def private commonSystemImports(Application it, Boolean isBase) {
        val imports = newArrayList
        if (hasTrees) {
            imports.addAll(#[
                'Psr\\Log\\LoggerInterface',
                'Symfony\\Component\\Routing\\RouterInterface',
                'Symfony\\Component\\Security\\Core\\User\\UserInterface',
                'Symfony\\Component\\Security\\Http\\Attribute\\CurrentUser'
            ])
        }
        if (isBase) {
            imports.addAll(#[
                'Symfony\\Contracts\\Translation\\TranslatorInterface',
                'Zikula\\CoreBundle\\Translation\\TranslatorTrait'
            ])
        }
        imports
    }

    def private commonAppImports(Application it) {
        val imports = newArrayList
        if (needsDuplicateCheck || hasTrees || hasSortable) {
            imports.add(appNamespace + '\\Entity\\Factory\\EntityFactory')
            for (entity : entities) {
                imports.add(appNamespace + '\\Repository\\' + entity.name.formatForCodeCapital + 'RepositoryInterface')
            }
        }
        if (needsDuplicateCheck) {
            imports.add(appNamespace + '\\Helper\\ControllerHelper')
        }
        if (hasTrees) {
            imports.add(appNamespace + '\\Helper\\EntityDisplayHelper')
        }
        if (hasTrees) {
            imports.add(appNamespace + '\\Helper\\WorkflowHelper')
        }
        imports
    }

    def private collectBaseImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Bundle\\FrameworkBundle\\Controller\\AbstractController',
            'Symfony\\Component\\HttpFoundation\\JsonResponse',
            'Symfony\\Component\\HttpFoundation\\Request',
            'Symfony\\Component\\HttpFoundation\\Response'
        ])
        if (hasTrees) {
            imports.add('Exception')
        }
        if (hasTrees && hasEditActions) {
            imports.add('Symfony\\Component\\Routing\\Generator\\UrlGeneratorInterface')
        }
        if (needsDuplicateCheck || hasTrees || hasSortable) {
            imports.add('Symfony\\Component\\Security\\Http\\Attribute\\IsGranted')
        }
        imports.addAll(commonSystemImports(true))
        imports.addAll(commonAppImports)
        imports
    }

    def private ajaxControllerBaseClass(Application it) '''
        namespace «appNamespace»\Controller\Base;

        «collectBaseImports.print»

        /**
         * Ajax controller base class.
         */
        abstract class AbstractAjaxController extends AbstractController
        {
            public function __construct(
                TranslatorInterface $translator,
                «FOR entity : entities.sortBy[name]»
                    protected readonly «entity.name.formatForCodeCapital»RepositoryInterface $«entity.name.formatForCode»Repository,
                «ENDFOR»
            ) {
                $this->setTranslator($translator);
            }

            «additionalAjaxFunctionsBase»
        }
    '''

    def additionalAjaxFunctionsBase(Application it) '''
        «IF needsDuplicateCheck»

            «checkForDuplicateBase»
        «ENDIF»
        «IF hasTrees»

            «handleTreeOperationBase»
        «ENDIF»
        «IF hasSortable»

            «updateSortPositionsBase»
        «ENDIF»
    '''

    def private checkForDuplicateBase(Application it) '''
        «checkForDuplicateDocBlock(true)»
        «checkForDuplicateSignature» {
            «checkForDuplicateBaseImpl»
        }
    '''

    def private checkForDuplicateDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Checks whether a field value is a duplicate or not.
             */
            #[IsGranted('ROLE_EDITOR')]
        «ELSE»
            #[Route('/checkForDuplicate',
                name: '«appName.formatForDB»_ajax_checkforduplicate',
                methods: ['GET'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private checkForDuplicateSignature(Application it) '''
        public function checkForDuplicate(
            Request $request,
            ControllerHelper $controllerHelper
        ): JsonResponse'''

    def private checkForDuplicateBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        «prepareDuplicateCheckParameters»

        «repositoryMatchBlock(entities.filter[!getUniqueFields.empty])»

        $uniqueFields = match ($objectType) {
            «FOR entity : entities.filter[!getUniqueFields.empty]»
                '«entity.name.formatForCode»' => ['«entity.getUniqueFields.map[name.formatForCode].join('\', \'')»'],
            «ENDFOR»
            default => [],
        };

        $result = false;
        if (null !== $repository && in_array($fieldName, $uniqueFields, true)) {
            $result = !$repository->detectUniqueState($fieldName, $value, $exclude);
        }

        // return response
        return $this->json(['isDuplicate' => $result]);
    '''

    def private prepareDuplicateCheckParameters(Application it) '''
        $objectType = $request->query->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $contextArgs = ['controller' => 'ajax', 'action' => 'checkForDuplicate'];
        if (!in_array($objectType, $controllerHelper->getObjectTypes('controllerAction', $contextArgs), true)) {
            $objectType = $controllerHelper->getDefaultObjectType('controllerAction', $contextArgs);
        }

        $fieldName = $request->query->getAlnum('fn');
        $value = $request->query->get('v');

        if (empty($fieldName) || empty($value)) {
            return $this->json($this->trans('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        // check if the given field is existing and unique
        $uniqueFields = [];
        switch ($objectType) {
            «FOR entity : entities»
                «val uniqueFields = entity.getUniqueFields»
                «IF !uniqueFields.empty»
                    case '«entity.name.formatForCode»':
                        $uniqueFields = [«FOR uniqueField : uniqueFields SEPARATOR ', '»'«uniqueField.name.formatForCode»'«ENDFOR»];
                        break;
                «ENDIF»
            «ENDFOR»
        }
        if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields, true)) {
            return $this->json($this->trans('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        $exclude = $request->query->getInt('ex');
    '''

    def private handleTreeOperationBase(Application it) '''
        «handleTreeOperationDocBlock(true)»
        «handleTreeOperationSignature» {
            «handleTreeOperationBaseImpl»
        }
    '''

    def private handleTreeOperationDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Performs different operations on tree hierarchies.
             */
            #[IsGranted('ROLE_EDITOR')]
        «ELSE»
            #[Route('/handleTreeOperation',
                name: '«appName.formatForDB»_ajax_handletreeoperation',
                methods: ['POST'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private handleTreeOperationSignature(Application it) '''
        public function handleTreeOperation(
            Request $request,
            RouterInterface $router,
            LoggerInterface $logger,
            EntityFactory $entityFactory,
            EntityDisplayHelper $entityDisplayHelper,
            #[CurrentUser] ?UserInterface $currentUser,
            WorkflowHelper $workflowHelper
        ): JsonResponse'''

    def private handleTreeOperationBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        «val treeEntities = getTreeEntities»
        // parameter specifying which type of objects we are treating
        $objectType = $request->request->getAlnum('ot', '«treeEntities.head.name.formatForCode»');
        // ensure that we use only object types with tree extension enabled
        if (!in_array($objectType, [«FOR treeEntity : treeEntities SEPARATOR ", "»'«treeEntity.name.formatForCode»'«ENDFOR»], true)) {
            $objectType = '«treeEntities.head.name.formatForCode»';
        }

        $returnValue = [
            'data' => [],
            'result' => 'success',
            'message' => '',
        ];

        «prepareTreeOperationParameters»

        $createMethod = 'create' . ucfirst($objectType);
        «repositoryMatchBlock(treeEntities)»

        $rootId = 1;
        if (!in_array($op, ['addRootNode'], true)) {
            $rootId = $request->request->getInt('root');
            if (!$rootId) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->trans('Error: invalid root node.');

                return $this->json($returnValue);
            }
        }

        $entityManager = $entityFactory->getEntityManager();
        $titleFieldName = $entityDisplayHelper->getTitleFieldName($objectType);
        $descriptionFieldName = $entityDisplayHelper->getDescriptionFieldName($objectType);

        «treeOperationSwitch»

        $returnValue['message'] = $this->trans('The operation was successful.');

        // Renew tree
        /* postponed, for now we do a page reload.
         * $returnValue['data'] = $repository->selectTree($rootId);
         */

        return $this->json($returnValue);
    '''

    def private prepareTreeOperationParameters(Application it) '''
        $op = $request->request->getAlpha('op');
        if (!in_array($op, ['addRootNode', 'addChildNode', 'deleteNode', 'moveNode', 'moveNodeTo'], true)) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid operation.');

            return $this->json($returnValue);
        }

        // Get id of treated node
        $id = 0;
        if (!in_array($op, ['addRootNode', 'addChildNode'], true)) {
            $id = $request->request->getInt('id');
            if (!$id) {
                $returnValue['result'] = 'failure';
                $returnValue['message'] = $this->trans('Error: invalid node.');

                return $this->json($returnValue);
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
        $entity = $entityFactory->$createMethod();
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
            $success = $workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $returnValue['result'] = 'failure';
            }
        } catch (Exception $exception) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->json($returnValue);
        }
    '''

    def private treeOperationAddChildNode(Application it) '''
        $parentId = $request->request->getInt('pid');
        if (!$parentId) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid parent node.');

            return $this->json($returnValue);
        }

        $childEntity = $entityFactory->$createMethod();
        $setter = 'set' . ucfirst($titleFieldName);
        $childEntity->$setter($this->trans('New child node'));
        if (!empty($descriptionFieldName)) {
            $setter = 'set' . ucfirst($descriptionFieldName);
            $childEntity->$setter($this->trans('This is a new child node'));
        }
        «IF hasStandardFieldEntities»
            if (method_exists($childEntity, 'setCreatedBy')) {
                $childEntity->setCreatedBy($currentUser);
                $childEntity->setUpdatedBy($currentUser);
            }
        «ENDIF»
        $parentEntity = $repository->selectById($parentId, false);
        if (null === $parentEntity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('No such item.');

            return $this->json($returnValue);
        }
        $childEntity->setParent($parentEntity);

        // save new object
        $action = 'submit';
        try {
            // execute the workflow action
            $success = $workflowHelper->executeAction($childEntity, $action);
            «IF hasEditActions && !entitiesWithEditableTree.empty»
                if (!$success) {
                    $returnValue['result'] = 'failure';
                } elseif (in_array($objectType, ['«entitiesWithEditableTree.map[name.formatForCode].join('\', \'')»'], true)) {
                    $routeName = '«appName.formatForDB»_' . mb_strtolower($objectType) . '_edit';
                    «IF !entities.filter[tree && hasEditAction && hasSluggableFields].empty»
                        $needsArg = in_array($objectType, ['«entitiesWithEditableTree.filter[hasSluggableFields].map[name.formatForCode].join('\', \'')»'], true);
                        $urlArgs = $needsArg ? $childEntity->createUrlArgs(true) : $childEntity->createUrlArgs();
                    «ELSE»
                        $urlArgs = $childEntity->createUrlArgs();
                    «ENDIF»
                    $returnValue['returnUrl'] = $router->generate(
                        $routeName,
                        $urlArgs,
                        UrlGeneratorInterface::ABSOLUTE_URL
                    );
                }
            «ELSE»
                if (!$success) {
                    $returnValue['result'] = 'failure';
                }
            «ENDIF»
        } catch (Exception $exception) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->json($returnValue);
        }
    '''

    def private entitiesWithEditableTree(Application it) {
        entities.filter[tree && hasEditAction]
    }

    def private treeOperationDeleteNode(Application it) '''
        // remove node from tree and reparent all children
        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('No such item.');

            return $this->json($returnValue);
        }

        // delete the object
        $action = 'delete';
        try {
            // execute the workflow action
            $success = $workflowHelper->executeAction($entity, $action);
            if (!$success) {
                $returnValue['result'] = 'failure';
            }
        } catch (Exception $exception) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans(
                'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                ['%action%' => $action]
            ) . '  ' . $exception->getMessage();

            return $this->json($returnValue);
        }

        $repository->removeFromTree($entity);
        $entityManager->clear(); // clear cached nodes
    '''

    def private treeOperationMoveNode(Application it) '''
        $moveDirection = $request->request->getAlpha('direction');
        if (!in_array($moveDirection, ['top', 'up', 'down', 'bottom'], true)) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid direction.');

            return $this->json($returnValue);
        }

        $entity = $repository->selectById($id, false);
        if (null === $entity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('No such item.');

            return $this->json($returnValue);
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
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid direction.');

            return $this->json($returnValue);
        }

        $destId = $request->request->getInt('destid');
        if (!$destId) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('Error: invalid destination node.');

            return $this->json($returnValue);
        }

        $entity = $repository->selectById($id, false);
        $destEntity = $repository->selectById($destId, false);
        if (null === $entity || null === $destEntity) {
            $returnValue['result'] = 'failure';
            $returnValue['message'] = $this->trans('No such item.');

            return $this->json($returnValue);
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

    def private updateSortPositionsBase(Application it) '''
        «updateSortPositionsDocBlock(true)»
        «updateSortPositionsSignature» {
            «updateSortPositionsBaseImpl»
        }
    '''

    def private updateSortPositionsDocBlock(Application it, Boolean isBase) '''
        «IF isBase»
            /**
             * Updates the sort positions for a given list of entities.
             */
            #[IsGranted('ROLE_EDITOR')]
        «ELSE»
            #[Route('/updateSortPositions',
                name: '«appName.formatForDB»_ajax_updatesortpositions',
                methods: ['POST'],
                options: ['expose' => true]
            )]
        «ENDIF»
    '''

    def private updateSortPositionsSignature(Application it) '''
        public function updateSortPositions(
            Request $request,
            EntityFactory $entityFactory
        ): JsonResponse'''

    def private updateSortPositionsBaseImpl(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->json($this->trans('Only ajax access is allowed!'), Response::HTTP_BAD_REQUEST);
        }

        $objectType = $request->request->getAlnum('ot', '«getLeadingEntity.name.formatForCode»');
        $itemIds = $request->request->get('identifiers', []);
        $min = $request->request->getInt('min');
        $max = $request->request->getInt('max');

        if (!is_array($itemIds) || 2 > count($itemIds) || 1 > $max || $max <= $min) {
            return $this->json($this->trans('Error: invalid input.'), JsonResponse::HTTP_BAD_REQUEST);
        }

        «repositoryMatchBlock(entities.filter[hasSortableFields])»
        $sortableFieldMap = [
            «FOR entity : entities.filter[hasSortableFields]»
                '«entity.name.formatForCode»' => '«entity.getSortableFields.head.name.formatForCode»',
            «ENDFOR»
        ];

        $sortFieldSetter = 'set' . ucfirst($sortableFieldMap[$objectType]);
        $sortCounter = $min;

        // update sort values
        foreach ($itemIds as $itemId) {
            if (empty($itemId) || !is_numeric($itemId)) {
                continue;
            }
            $entity = $repository->selectById($itemId);
            $entity->$sortFieldSetter($sortCounter);
            ++$sortCounter;
        }

        // save entities back to database
        $entityFactory->getEntityManager()->flush();

        // return response
        return $this->json([
            'message' => $this->trans('The setting has been successfully changed.'),
        ]);
    '''

    def additionalAjaxFunctions(Application it) '''
        «IF needsDuplicateCheck»

            «checkForDuplicateImpl»
        «ENDIF»
        «IF hasTrees»

            «handleTreeOperationImpl»
        «ENDIF»
        «IF hasSortable»

            «updateSortPositionsImpl»
        «ENDIF»
    '''

    def private checkForDuplicateImpl(Application it) '''
        «checkForDuplicateDocBlock(false)»
        «checkForDuplicateSignature» {
            return parent::checkForDuplicate(
                $request,
                $controllerHelper
            );
        }
    '''

    def private handleTreeOperationImpl(Application it) '''
        «handleTreeOperationDocBlock(false)»
        «handleTreeOperationSignature» {
            return parent::handleTreeOperation(
                $request,
                $router,
                $logger,
                $entityFactory,
                $entityDisplayHelper,
                $currentUser,
                $workflowHelper
            );
        }
    '''

    def private updateSortPositionsImpl(Application it) '''
        «updateSortPositionsDocBlock(false)»
        «updateSortPositionsSignature» {
            return parent::updateSortPositions(
                $request,
                $entityFactory
            );
        }
    '''

    def private collectImplImports(Application it) {
        val imports = new ImportList
        imports.addAll(#[
            'Symfony\\Component\\HttpFoundation\\JsonResponse',
            'Symfony\\Component\\HttpFoundation\\Request',
            'Symfony\\Component\\Routing\\Annotation\\Route',
            appNamespace + '\\Controller\\Base\\AbstractAjaxController'
        ])
        imports.addAll(commonSystemImports(false))
        imports.addAll(commonAppImports)
        imports
    }

    def private ajaxControllerImpl(Application it) '''
        namespace «appNamespace»\Controller;

        «collectImplImports.print»

        /**
         * Ajax controller implementation class.
         */
        #[Route('/«name.formatForDB»/ajax')]
        class AjaxController extends AbstractAjaxController
        {
            «additionalAjaxFunctions»

            // feel free to add your own ajax controller methods here
        }
    '''

    def private needsDuplicateCheck(Application it) {
        entities.exists[!getUniqueFields.empty]
    }
}
