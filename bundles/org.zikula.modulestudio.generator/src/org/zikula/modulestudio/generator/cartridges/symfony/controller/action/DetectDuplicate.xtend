package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions

class DetectDuplicate extends AbstractAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions

    override name(Application it) {
        'DetectDuplicate'
    }

    override requiredFor(Entity it) {
        !getUniqueFields.empty
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
         * Checks whether a field value is a duplicate or not.
         */
    '''

    override protected returnType(Application it) { 'JsonResponse' }

    override protected controllerPreprocessing(Entity it) '''
        $objectType = '«name.formatForCode»';

    '''

    override protected controllerAttributes(Application it, Entity entity) '''
        #[IsGranted('ROLE_EDITOR')]
    '''

    override protected routeMethods(Entity it) '''['GET']'''

    override protected routeOptions(Entity it) '''options: ['expose' => true]'''

    override protected implBody(Application it) '''
        if (!$request->isXmlHttpRequest()) {
            return $this->controllerHelper->json(
                $this->translator->trans('Only ajax access is allowed!'),
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        «prepareDuplicateCheckParameters»

        «entityMatchBlock(entities.filter[!getUniqueFields.empty])»

        $repository = $this->managerRegistry->getRepository($entityFqcn);
        $result = !$repository->detectUniqueState($fieldName, $value, $exclude);

        // return response
        return $this->json(['isDuplicate' => $result]);
    '''

    def private prepareDuplicateCheckParameters(Application it) '''
        $fieldName = $request->query->getAlnum('fn');
        $value = $request->query->get('v');

        if (empty($fieldName) || empty($value)) {
            return $this->controllerHelper->json(
                $this->translator->trans('Error: invalid input.'),
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        // check if the given field is unique
        $uniqueFields = match ($objectType) {
            «FOR entity : entities.filter[!getUniqueFields.empty]»
                '«entity.name.formatForCode»' => ['«entity.getUniqueFields.map[name.formatForCode].join('\', \'')»'],
            «ENDFOR»
            default => [],
        };
        if (!count($uniqueFields) || !in_array($fieldName, $uniqueFields, true)) {
            return $this->controllerHelper->json(
                $this->translator->trans('Error: invalid input.'),
                JsonResponse::HTTP_BAD_REQUEST
            );
        }

        $exclude = $request->query->getInt('ex');
    '''
}
