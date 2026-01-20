package org.zikula.modulestudio.generator.cartridges.symfony.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions

class ControllerHelperFunctions {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions

    def determineEntityId(Application it, Boolean considerSlug) '''
        «IF hasSluggable && considerSlug»
            $hasSlug = in_array($objectType, ['«entities.filter[hasSluggableFields].map[name.formatForCode].join('\', \'')»'], true);
            if ($hasSlug) {
                $id = $request->query->get('slug');
            } else {
                $id = $request->query->get('id');
            }
        «ELSE»
            $id = $request->query->get('id');
        «ENDIF»

        if (null === $id || '' === $id) {
            throw new NotFoundHttpException(
                $this->translator->trans(
                    'No such {entity} found.',
                    ['entity' => $entityDisplayName],
                    $objectType
                )
            );
        }
    '''

    def defaultSorting(Application it) '''
        $sort = $request->query->get('sort', '');
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields(), true)) {
            $sort = $repository->getDefaultSortingField();
            $request->query->set('sort', $sort);
            // set default sorting in route parameters (e.g. for the pager)
            $routeParams = $request->attributes->get('_route_params');
            $routeParams['sort'] = $sort;
            $request->attributes->set('_route_params', $routeParams);
        }
    '''
}
