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
            public function «IF isAdmin»adminL«ELSE»l«ENDIF»oggableHistory«IF !application.targets('3.1')»Action«ENDIF»(
                «loggableHistoryArguments(false)»
            ): Response {
                return $this->loggableHistoryInternal(
                    $request,
                    $permissionHelper,
                    $entityFactory,
                    $loggableHelper,«IF hasTranslatableFields»
                    $translatableHelper,«ENDIF»
                    $workflowHelper,
                    «IF hasSluggableFields && slugUnique»$slug«ELSE»$id«ENDIF»,
                    «isAdmin.displayBool»
                );
            }
        «ELSEIF isBase && !isAdmin»
            «loggableHistoryDocBlock(isBase, isAdmin)»
            protected function loggableHistoryInternal(
                «loggableHistoryArguments(true)»
            ): Response {
                «loggableHistoryBaseImpl»
            }
        «ENDIF»
    '''

    def private loggableHistoryDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        «IF isBase»
            /**
             * This method provides a change history for a given «name.formatForDisplay».
             *
             * @throws NotFoundHttpException Thrown if invalid identifier is given or the «name.formatForDisplay» isn't found
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             */
        «ELSE»
            «IF isAdmin»
                /**
                 * @Theme("admin")
                 */
            «ENDIF»
            #[Route('/«IF isAdmin»admin/«ENDIF»«name.formatForCode»/history/{«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»}',
                «IF hasSluggableFields && slugUnique»
                requirements: ['slug' => '«IF tree != EntityTreeType.NONE»[^.]+«ELSE»[^/.]+«ENDIF»'],
                «ELSE»
                requirements: ['id' => '\d+'],
                defaults: ['id' => 0],
                «ENDIF»
                methods: ['GET']
            )]
        «ENDIF»
    '''

    def private loggableHistoryArguments(Entity it, Boolean internalMethod) '''
        Request $request,
        PermissionHelper $permissionHelper,
        EntityFactory $entityFactory,
        LoggableHelper $loggableHelper,
        «IF hasTranslatableFields»
            TranslatableHelper $translatableHelper,
        «ENDIF»
        WorkflowHelper $workflowHelper,
        «IF hasSluggableFields && slugUnique»string $slug = ''«ELSE»int $id = 0«ENDIF»«IF internalMethod»,
        bool $isAdmin = false«ENDIF»
    '''

    def private loggableHistoryBaseImpl(Entity it) '''
        if (empty(«IF hasSluggableFields && slugUnique»$slug«ELSE»$id«ENDIF»)) {
            throw new NotFoundHttpException(
                $this->trans(
                    'No such «name.formatForDisplay» found.'«IF !application.isSystemModule»,
                    [],
                    '«name.formatForCode»'«ENDIF»
                )
            );
        }

        $«name.formatForCode» = $entityFactory->getRepository('«name.formatForCode»')->selectBy«IF hasSluggableFields && slugUnique»Slug($slug)«ELSE»Id($id)«ENDIF»;
        if (null === $«name.formatForCode») {
            throw new NotFoundHttpException(
                $this->trans(
                    'No such «name.formatForDisplay» found.'«IF !application.isSystemModule»,
                    [],
                    '«name.formatForCode»'«ENDIF»
                )
            );
        }

        $permLevel = $isAdmin ? ACCESS_ADMIN : ACCESS_EDIT;
        if (!$permissionHelper->hasEntityPermission($«name.formatForCode», $permLevel)) {
            throw new AccessDeniedException();
        }

        $routeArea = $isAdmin ? 'admin' : '';
        $entityManager = $entityFactory->getEntityManager();
        $logEntriesRepository = $entityManager->getRepository(«name.formatForCodeCapital»LogEntryEntity::class);
        $logEntries = $logEntriesRepository->getLogEntries($«name.formatForCode»);

        $revertToVersion = $request->query->getInt('revert');
        if (0 < $revertToVersion && 1 < count($logEntries)) {
            // revert to requested version
            «IF hasSluggableFields && slugUnique»
                $«name.formatForCode»Id = $«name.formatForCode»->getId();
            «ENDIF»
            $«name.formatForCode» = $loggableHelper->revert($«name.formatForCode», $revertToVersion);

            try {
                // execute the workflow action
                $success = $workflowHelper->executeAction($«name.formatForCode», 'update');
                «IF hasTranslatableFields»

                    $translatableHelper->refreshTranslationsFromLogData($«name.formatForCode»);
                «ENDIF»

                if ($success) {
                    $this->addFlash(
                        'status',
                        $this->trans(
                            'Done! Reverted «name.formatForDisplay» to version %version%.',
                            ['%version%' => $revertToVersion]«IF !application.isSystemModule»,
                            '«name.formatForCode»'«ENDIF»
                        )
                    );
                } else {
                    $this->addFlash(
                        'error',
                        $this->trans(
                            'Error! Reverting «name.formatForDisplay» to version %version% failed.',
                            ['%version%' => $revertToVersion]«IF !application.isSystemModule»,
                            '«name.formatForCode»'«ENDIF»
                        )
                    );
                }
            } catch (Exception $exception) {
                $this->addFlash(
                    'error',
                    $this->trans(
                        'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                        ['%action%' => 'update']
                    ) . '  ' . $exception->getMessage()
                );
            }
            «IF hasSluggableFields && slugUnique»

                $«name.formatForCode» = $entityFactory->getRepository('«name.formatForCode»')->selectById($«name.formatForCode»Id);
            «ENDIF»

            return $this->redirectToRoute(
                '«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . 'loggablehistory',
                [«routeParams(name.formatForCode, false)»]
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
            'routeArea' => $routeArea,
            '«name.formatForCode»' => $«name.formatForCode»,
            'logEntries' => $logEntries,
            'isDiffView' => $isDiffView,
        ];

        if (true === $isDiffView) {
            list(
                $minVersion,
                $maxVersion,
                $diffValues
            ) = $loggableHelper->determineDiffViewParameters($logEntries, $versions);
            $templateParameters['minVersion'] = $minVersion;
            $templateParameters['maxVersion'] = $maxVersion;
            $templateParameters['diffValues'] = $diffValues;
        }

        return $this->render('@«application.appName»/«name.formatForCode.toFirstUpper»/«IF application.separateAdminTemplates»' . ($isAdmin ? 'Admin/' : '') . '«ENDIF»history.html.twig', $templateParameters);
    '''
}
