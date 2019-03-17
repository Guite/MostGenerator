package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import de.guite.modulestudio.metamodel.EntityTreeType
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableHistory {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''
        «loggableHistory(isBase, true)»

        «loggableHistory(isBase, false)»

    '''

    def private loggableHistory(Entity it, Boolean isBase, Boolean isAdmin) '''
        «IF !isBase»
            «loggableHistoryDocBlock(isBase, isAdmin)»
            public function «IF isAdmin»adminL«ELSE»l«ENDIF»oggableHistoryAction(
                «loggableHistoryArguments(false)»
            ) {
                «IF application.targets('3.0')»
                    return $this->loggableHistoryActionInternal($request, $permissionHelper, $entityFactory, $loggableHelper, «IF hasTranslatableFields»$translatableHelper, «ENDIF»$workflowHelper, «IF hasSluggableFields && slugUnique»$slug«ELSE»$id«ENDIF», «isAdmin.displayBool»);
                «ELSE»
                    return $this->loggableHistoryActionInternal($request, «IF hasSluggableFields && slugUnique»$slug«ELSE»$id«ENDIF», «isAdmin.displayBool»);
                «ENDIF»
            }
        «ELSEIF isBase && !isAdmin»
            «loggableHistoryDocBlock(isBase, isAdmin)»
            protected function loggableHistoryActionInternal(
                «loggableHistoryArguments(true)»
            ) {
                «loggableHistoryBaseImpl»
            }
        «ENDIF»
    '''

    def private loggableHistoryDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        /**
         «IF isBase»
         * This method provides a change history for a given «name.formatForDisplay».
         *
         * @param Request $request
         * @param PermissionHelper $permissionHelper
         * @param EntityFactory $entityFactory
         «IF application.targets('3.0')»
         * @param LoggableHelper $loggableHelper
         «IF hasTranslatableFields»
         * @param TranslatableHelper $translatableHelper
         «ENDIF»
         * @param WorkflowHelper $workflowHelper
         «ENDIF»
         * @param integer «IF hasSluggableFields && slugUnique»$slug«ELSE»$id«ENDIF» Identifier of «name.formatForDisplay»
         * @param boolean $isAdmin Whether the admin area is used or not
         *
         * @return Response Output
         *
         * @throws NotFoundHttpException Thrown if invalid identifier is given or the «name.formatForDisplay» isn't found
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         «ELSE»
         * @inheritDoc
         * @Route("/«IF isAdmin»admin/«ENDIF»«name.formatForCode»/history/{«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»}",
         «IF hasSluggableFields && slugUnique»
         *        requirements = {"slug" = "«IF tree != EntityTreeType.NONE»[^.]+«ELSE»[^/.]+«ENDIF»"},
         «ELSE»
         *        requirements = {"id" = "\d+"},
         *        defaults = {"id" = 0},
         «ENDIF»
         *        methods = {"GET"}
         * )
         «IF isAdmin»
              * @Theme("admin")
         «ENDIF»
         «ENDIF»
         */
    '''

    def private loggableHistoryArguments(Entity it, Boolean internalMethod) '''
        «IF application.targets('3.0')»
            Request $request,
            PermissionHelper $permissionHelper,
            EntityFactory $entityFactory,
            LoggableHelper $loggableHelper,
            «IF hasTranslatableFields»
                TranslatableHelper $translatableHelper,
            «ENDIF»
            WorkflowHelper $workflowHelper,
            «IF hasSluggableFields && slugUnique»$slug = ''«ELSE»$id = 0«ENDIF»«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ELSE»
            Request $request,
            «IF hasSluggableFields && slugUnique»$slug = ''«ELSE»$id = 0«ENDIF»«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ENDIF»
    '''

    def private loggableHistoryBaseImpl(Entity it) '''
        if (empty(«IF hasSluggableFields && slugUnique»$slug«ELSE»$id«ENDIF»)) {
            throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
        }

        «IF !application.targets('3.0')»
            $entityFactory = $this->get('«application.appService».entity_factory');
        «ENDIF»
        $«name.formatForCode» = $entityFactory->getRepository('«name.formatForCode»')->selectBy«IF hasSluggableFields && slugUnique»Slug($slug)«ELSE»Id($id)«ENDIF»;
        if (null === $«name.formatForCode») {
            throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
        }

        «IF !application.targets('3.0')»
            $permissionHelper = $this->get('«application.appService».permission_helper');
        «ENDIF»
        $permLevel = $isAdmin ? ACCESS_ADMIN : ACCESS_EDIT;
        if (!$permissionHelper->hasEntityPermission($«name.formatForCode», $permLevel)) {
            throw new AccessDeniedException();
        }

        $routeArea = $isAdmin ? 'admin' : '';
        $entityManager = $entityFactory->getEntityManager();
        $logEntriesRepository = $entityManager->getRepository('«application.appName»:«name.formatForCodeCapital»LogEntryEntity');
        $logEntries = $logEntriesRepository->getLogEntries($«name.formatForCode»);

        $revertToVersion = $request->query->getInt('revert', 0);
        if ($revertToVersion > 0 && count($logEntries) > 1) {
            // revert to requested version
            «IF hasSluggableFields && slugUnique»
                $«name.formatForCode»Id = $«name.formatForCode»->getId();
            «ENDIF»
            $«name.formatForCode» = «IF application.targets('3.0')»$loggableHelper«ELSE»$this->get('«application.appService».loggable_helper')«ENDIF»->revert($«name.formatForCode», $revertToVersion);

            try {
                // execute the workflow action
                «IF !application.targets('3.0')»
                    $workflowHelper = $this->get('«application.appService».workflow_helper');
                «ENDIF»
                $success = $workflowHelper->executeAction($«name.formatForCode», 'update'«IF !application.targets('2.0')» . $«name.formatForCode»->getWorkflowState()«ENDIF»);
                «IF hasTranslatableFields»

                    «IF application.targets('3.0')»$translatableHelper«ELSE»$this->get('«application.appService».translatable_helper')«ENDIF»->refreshTranslationsFromLogData($«name.formatForCode»);
                «ENDIF»

                if ($success) {
                    $this->addFlash('status', $this->__f('Done! Reverted «name.formatForDisplay» to version %version%.', ['%version%' => $revertToVersion]));
                } else {
                    $this->addFlash('error', $this->__f('Error! Reverting «name.formatForDisplay» to version %version% failed.', ['%version%' => $revertToVersion]));
                }
            } catch (\Exception $exception) {
                $this->addFlash('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => 'update']) . '  ' . $exception->getMessage());
            }
            «IF hasSluggableFields && slugUnique»

                $«name.formatForCode» = $entityFactory->getRepository('«name.formatForCode»')->selectById($«name.formatForCode»Id);
            «ENDIF»

            return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . 'loggablehistory', [«routeParams(name.formatForCode, false)»]);
        }

        $isDiffView = false;
        $versions = $request->query->get('versions', []);
        if (is_array($versions) && count($versions) == 2) {
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
            'routeArea' => $routeArea,
            '«name.formatForCode»' => $«name.formatForCode»,
            'logEntries' => $logEntries,
            'isDiffView' => $isDiffView
        ];

        if (true === $isDiffView) {
            list ($minVersion, $maxVersion, $diffValues) = «IF application.targets('3.0')»$loggableHelper«ELSE»$this->get('«application.appService».loggable_helper')«ENDIF»->determineDiffViewParameters($logEntries, $versions);
            $templateParameters['minVersion'] = $minVersion;
            $templateParameters['maxVersion'] = $maxVersion;
            $templateParameters['diffValues'] = $diffValues;
        }

        return $this->render('@«application.appName»/«name.formatForCode.toFirstUpper»/«IF application.separateAdminTemplates»' . ($isAdmin ? 'Admin/' : '') . '«ENDIF»history.html.twig', $templateParameters);
    '''
}
