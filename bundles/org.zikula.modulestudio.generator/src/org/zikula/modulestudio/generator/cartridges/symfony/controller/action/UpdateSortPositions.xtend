package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class UpdateSortPositions extends AbstractAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions

    override name(Application it) {
        'UpdateSortPositions'
    }

    override requiredFor(Entity it) {
        hasSortableFields
    }

    override protected imports(Application it) {
        #[
            'Doctrine\\Persistence\\ManagerRegistry',
            'Symfony\\Bundle\\FrameworkBundle\\Controller\\ControllerHelper',
            'Symfony\\Component\\HttpFoundation\\JsonResponse',
            'Symfony\\Component\\Security\\Http\\Attribute\\IsGranted',
            'Symfony\\Contracts\\Translation\\TranslatorInterface'
        ]
    }

    override protected constructorArguments(Application it) {
        #[
            'ControllerHelper $controllerHelper',
            'ManagerRegistry $managerRegistry',
            'TranslatorInterface $translator'
        ]
    }

    override protected invocationArguments(Application it, Boolean call) {
        val result = <String>newArrayList
        result.add('Request $request')
        if (call) {
            result.add('string $objectType')
        }
        result
    }

    override protected docBlock(Application it) '''
        /**
         * Updates the sort positions for a given list of entities.
         */
    '''

    override protected returnType(Application it) { 'JsonResponse' }

    override protected controllerPreprocessing(Entity it) '''
        $objectType = '«name.formatForCode»';

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

        $itemIds = $request->request->get('identifiers', []);
        $min = $request->request->getInt('min');
        $max = $request->request->getInt('max');

        if (!is_array($itemIds) || 2 > count($itemIds) || 1 > $max || $max <= $min) {
            return $this->controllerHelper->json(
                $this->translator->trans('Error: invalid input.'),
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        «entityMatchBlock(entities.filter[hasSortableFields])»

        $entityManager = $this->managerRegistry->getManagerForClass($entityFqcn);
        $repository = $this->managerRegistry->getRepository($entityFqcn);
        $sortableField = match($objectType) {
            «FOR entity : entities.filter[hasSortableFields].sortBy[name]»
                '«entity.name.formatForCode»' => '«entity.getSortableFields.head.name.formatForCode»',
            «ENDFOR»
        };

        $sortFieldSetter = 'set' . ucfirst($sortableField);
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
        $entityManager->flush();

        // return response
        return $this->controllerHelper->json([
            'message' => $this->translator->trans('The setting has been successfully changed.'),
        ]);
    '''
}
