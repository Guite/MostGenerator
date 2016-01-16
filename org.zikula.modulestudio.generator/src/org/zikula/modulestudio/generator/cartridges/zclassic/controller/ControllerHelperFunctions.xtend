package org.zikula.modulestudio.generator.cartridges.zclassic.controller

import de.guite.modulestudio.metamodel.Application
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ControllerHelperFunctions {
    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    // 1.3.x only
    def controllerPostInitialize(Object it, Boolean caching, String additionalCommands) '''
        /**
         * Post initialise.
         *
         * Run after construction.
         *
         * @return void
         */
        protected function postInitialize()
        {
            // Set caching to «caching.displayBool» by default.
            $this->view->setCaching(Zikula_View::CACHE_«IF caching»ENABLED«ELSE»DISABLED«ENDIF»);
            «IF additionalCommands != ''»
                «additionalCommands»
            «ENDIF»
        }
    '''

    def defaultSorting(Object it, Application app) '''
        if (empty($sort) || !in_array($sort, $repository->getAllowedSortingFields())) {
            $sort = $repository->getDefaultSortingField();
            «IF !app.targets('1.3.x')»
                System::queryStringSetVar('sort', $sort);
                $request->query->set('sort', $sort);
                // set default sorting in route parameters (e.g. for the pager)
                $routeParams = $request->attributes->get('_route_params');
                $routeParams['sort'] = $sort;
                $request->attributes->set('_route_params', $routeParams);
            «ENDIF»
        }
    '''
}
