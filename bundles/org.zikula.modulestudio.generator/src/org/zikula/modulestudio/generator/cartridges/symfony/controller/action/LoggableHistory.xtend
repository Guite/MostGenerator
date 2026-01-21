package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.cartridges.symfony.controller.ControllerHelperFunctions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableHistory extends AbstractAction {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    override name(Application it) {
        'History'
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
            appNamespace + '\\Helper\\WorkflowHelper'
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
            'WorkflowHelper $workflowHelper',
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
         * Provides a change history for a given loggable entity.
         *
         * @throws NotFoundHttpException Thrown if invalid identifier is given or the entity isn't found
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         */
    '''

    override protected returnType(Application it) { 'Response' }

    override protected controllerPreprocessing(Entity it) '''
        $objectType = '«name.formatForCode»';
        $entityDisplayName = '«name.formatForDisplay»';
        $redirectRoute = '«application.routePrefix»_«nameMultiple.formatForDB»_history';

    '''

    override protected routeMethods(Entity it) '''['GET']'''

    override protected implBody(Application it) '''
        «new ControllerHelperFunctions().determineEntityId(it, true)»

        «entityMatchBlock(entities.filter[loggable])»

        $repository = $this->managerRegistry->getRepository($entityFqcn);
        «IF hasSluggable»
            $entity = null;
            if ($hasSlug) {
                $entity = $repository->selectBySlug($id);
            }
            if (null === $entity) {
                $entity = $repository->selectById($id);
            }
        «ELSE»
            $entity = $repository->selectById($id);
        «ENDIF»
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

        $logEntryRepository = $this->loggableHelper->getLogEntryRepository($objectType);
        $logEntries = $logEntryRepository->getLogEntries($entity);

        $revertToVersion = $request->query->getInt('revert');
        if (0 < $revertToVersion && 1 < count($logEntries)) {
            // revert to requested version
            «IF hasSluggable»
                if ($hasSlug) {
                    $entityId = $entity->getId();
                }
            «ENDIF»
            $entity = $this->loggableHelper->revert($entity, $revertToVersion);

            try {
                // execute the workflow action
                $success = $this->workflowHelper->executeAction($entity, 'update');
                «IF hasLoggableTranslatable»

                    if (in_array($objectType, ['«getLoggableTranslatableEntities.map[name.formatForCode].join('\', \'')»'], true)) {
                        $this->translatableHelper->refreshTranslationsFromLogData($entity);
                    }
                «ENDIF»

                if ($success) {
                    $this->controllerHelper->addFlash(
                        'status',
                        $this->translator->trans(
                            'Done! Reverted «name.formatForDisplay» to version %version%.',
                            ['%version%' => $revertToVersion],
                            $objectType
                        )
                    );
                } else {
                    $this->controllerHelper->addFlash(
                        'error',
                        $this->translator->trans(
                            'Error! Reverting «name.formatForDisplay» to version %version% failed.',
                            ['%version%' => $revertToVersion],
                            $objectType
                        )
                    );
                }
            } catch (Exception $exception) {
                $this->controllerHelper->addFlash(
                    'error',
                    $this->translator->trans(
                        'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                        ['%action%' => 'update']
                    ) . '  ' . $exception->getMessage()
                );
            }
            «IF hasSluggable»

                if ($hasSlug) {
                    $entity = $repository->selectById($entityId);
                }
            «ENDIF»

            return $this->controllerHelper->redirectToRoute(
                $redirectRoute,
                $entity->getRouteParameters()
            );
        }

        $isDiffView = false;
        $versions = $request->query->get('versions', []);
        if (is_array($versions) && 2 === count($versions)) {
            $isDiffView = true;
            $allVersionsExist = true;
            foreach ($versions as $versionNumber) {
                $versionExists = false;
                foreach ($logEntries as $logEntry) {
                    if ($versionNumber == $logEntry->getVersion()) {
                        $versionExists = true;
                        break;
                    }
                }
                if (!$versionExists) {
                    $allVersionsExist = false;
                    break;
                }
            }
            if (!$allVersionsExist) {
                $isDiffView = false;
            }
        }

        $templateParameters = [
            $objectType => $entity,
            'logEntries' => $logEntries,
            'isDiffView' => $isDiffView,
        ];

        if (true === $isDiffView) {
            [
                $minVersion,
                $maxVersion,
                $diffValues
            ] = $this->loggableHelper->determineDiffViewParameters($logEntries, $versions);
            $templateParameters['minVersion'] = $minVersion;
            $templateParameters['maxVersion'] = $maxVersion;
            $templateParameters['diffValues'] = $diffValues;
        }

        return $this->controllerHelper->render('@«vendorAndName»/' . ucfirst($objectType) . '/history.html.twig', $templateParameters);
    '''
}
