package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableUndelete extends AbstractAction {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    override name(Application it) {
        'Deleted'
    }

    override requiredFor(Entity it) {
        loggable
    }

    override protected imports(Application it) {
        val result = <String>newArrayList
        result.addAll(#[
            'Doctrine\\Persistence\\ManagerRegistry',
            'Symfony\\Bundle\\FrameworkBundle\\Controller\\ControllerHelper',
            'Symfony\\Component\\HttpFoundation\\Request',
            'Symfony\\Component\\HttpFoundation\\Response',
            'Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException',
            'Symfony\\Component\\Security\\Core\\Exception\\AccessDeniedException',
            'Symfony\\Contracts\\Translation\\TranslatorInterface',
            appNamespace + '\\Helper\\LoggableHelper',
            appNamespace + '\\Helper\\PermissionHelper',
            appNamespace + '\\Helper\\ViewHelper'
        ])
        if (hasLoggableTranslatable) {
            result.add(appNamespace + '\\Helper\\TranslatableHelper')
        }
        result
    }

    override protected constructorArguments(Application it) {
        val result = <String>newArrayList
        result.addAll(#[
            'ControllerHelper $controllerHelper',
            'ManagerRegistry $managerRegistry',
            'PermissionHelper $permissionHelper',
            'LoggableHelper $loggableHelper',
            'ViewHelper $viewHelper',
            'TranslatorInterface $translator'
        ])
        if (hasLoggableTranslatable) {
            result.add('TranslatableHelper $translatableHelper')
        }
        result
    }

    override protected invocationArguments(Application it, Boolean call) {
        val result = <String>newArrayList
        result.add('Request $request')
        if (call) {
            result.add('string $objectType')
            result.add('string $entityDisplayName')
            result.add('string $redirectRoute')
        }
        result
    }


    override protected docBlock(Application it) '''
        /**
         * «IF hasDetailActions»Displays or undeletes«ELSE»Undeletes«ENDIF» a deleted loggable entity.
         *
         * @throws NotFoundHttpException Thrown if invalid identifier is given or the entity isn't found
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         */
    '''

    override protected returnType(Application it) { 'Response' }

    override protected controllerPreprocessing(Entity it) '''
        $objectType = '«name.formatForCode»';
        $entityDisplayName = '«name.formatForDisplay»';
        «IF hasDetailAction»
            «/* TODO use EAB action */»
            $redirectRoute = '«application.routePrefix»_«nameMultiple.formatForDB»_detail';
        «ELSE»
            $redirectRoute = '«application.routePrefix»_«nameMultiple.formatForDB»_«primaryAction»';
        «ENDIF»

    '''

    override protected routeMethods(Entity it) '''['GET']'''

    override protected implBody(Application it) '''
        «new ControllerHelperFunctions().determineEntityId(it, false)»

        $entity = $loggableHelper->restoreDeletedEntity($objectType, $id);
        if (null === $entity) {
            throw new NotFoundHttpException(
                $this->translator->trans(
                    'No such {entity} found.',
                    ['entity' => $entityDisplayName],
                    $objectType
                )
            );
        }

        $dashboard = $request->attributes->get('dashboardControllerFqcn');
        $isAdminArea = 'Zikula\ThemeBundle\Controller\Dashboard\AdminDashboardController' === $dashboard;
        $permLevel = $isAdminArea ? ACCESS_ADMIN : ACCESS_EDIT;
        if (!$this->permissionHelper->hasEntityPermission($entity/*, $permLevel*/)) {
            throw new AccessDeniedException();
        }

        «IF !loggableEntities.filter[hasDetailAction].empty»
            if (in_array($objectType, ['«loggableEntities.filter[hasDetailAction].map[name.formatForCode].join('\', \'')»'], true)) {
                $preview = $request->query->getInt('preview');
                if (1 === $preview) {
                    «/* TODO use EAB action */»
                    return $this->detail(
                        $request,
                        $permissionHelper,
                        $controllerHelper,
                        $viewHelper,
                        $repository,
                        $loggableHelper,
                        $entity,
                        null
                    );
                }
            }

        «ENDIF»
        «undeletion»
        «IF hasLoggableTranslatable»

            if (in_array($objectType, ['«getLoggableTranslatableEntities.map[name.formatForCode].join('\', \'')»'], true)) {
                $this->translatableHelper->refreshTranslationsFromLogData($entity);
            }
        «ENDIF»

        $redirectRouteParameters = [];
        if (str_ends_with($redirectRoute, 'detail')) {
            $redirectRouteParameters = $entity->getRouteParameters();
        }

        return $this->redirectToRoute($redirectRoute, $redirectRouteParameters);
    '''

    def private undeletion(Application it) '''
        try {
            $this->loggableHelper->undelete($entity);
            $this->controllerHelper->addFlash(
                'status',
                $this->trans(
                    'Done! {entity} undeleted.',
                    ['entity' => ucfirst($entityDisplayName)],
                    $objectType
                )
            );
        } catch (\Exception $exception) {
            $this->controllerHelper->addFlash(
                'error',
                $this->translator->trans(
                    'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                    ['%action%' => 'undelete']
                ) . '  ' . $exception->getMessage()
            );
        }
    '''
}
