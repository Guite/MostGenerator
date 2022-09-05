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

        «loggableHistory(isBase)»
    '''

    def private loggableHistory(Entity it, Boolean isBase) '''
        «loggableHistoryDocBlock(isBase)»
        public function loggableHistory(
            «loggableHistoryArguments»
        ): Response {
            «IF isBase»
                «loggableHistoryBaseImpl»
            «ELSE»
                return parent::loggableHistory(
                    $request,
                    $permissionHelper,
                    $repository,
                    $logEntryRepository,
                    $loggableHelper,«IF hasTranslatableFields»
                    $translatableHelper,«ENDIF»
                    $workflowHelper,
                    «IF hasSluggableFields && slugUnique»$slug«ELSE»$id«ENDIF»
                );
            «ENDIF»
        }
    '''

    def private loggableHistoryDocBlock(Entity it, Boolean isBase) '''
        «IF isBase»
            /**
             * This method provides a change history for a given «name.formatForDisplay».
             *
             * @throws NotFoundHttpException Thrown if invalid identifier is given or the «name.formatForDisplay» isn't found
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             */
        «ELSE»
            #[Route('/«name.formatForCode»/history/{«IF hasSluggableFields && slugUnique»slug«ELSE»id«ENDIF»}',
                name: '«application.appName.formatForDB»_«name.formatForDB»_loggablehistory',
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

    def private loggableHistoryArguments(Entity it) '''
        Request $request,
        PermissionHelper $permissionHelper,
        «name.formatForCodeCapital»RepositoryInterface $repository,
        «name.formatForCodeCapital»LogEntryRepositoryInterface $logEntryRepository,
        LoggableHelper $loggableHelper,
        «IF hasTranslatableFields»
            TranslatableHelper $translatableHelper,
        «ENDIF»
        WorkflowHelper $workflowHelper,
        «IF hasSluggableFields && slugUnique»string $slug = ''«ELSE»int $id = 0«ENDIF»
    '''

    def private loggableHistoryBaseImpl(Entity it) '''
        if (empty(«IF hasSluggableFields && slugUnique»$slug«ELSE»$id«ENDIF»)) {
            throw new NotFoundHttpException(
                $this->trans(
                    'No such «name.formatForDisplay» found.',
                    [],
                    '«name.formatForCode»'
                )
            );
        }

        $«name.formatForCode» = $repository->selectBy«IF hasSluggableFields && slugUnique»Slug($slug)«ELSE»Id($id)«ENDIF»;
        if (null === $«name.formatForCode») {
            throw new NotFoundHttpException(
                $this->trans(
                    'No such «name.formatForDisplay» found.',
                    [],
                    '«name.formatForCode»'
                )
            );
        }

        $isAdmin = false;«/*TODO*/»
        $permLevel = $isAdmin ? ACCESS_ADMIN : ACCESS_EDIT;
        if (!$permissionHelper->hasEntityPermission($«name.formatForCode», $permLevel)) {
            throw new AccessDeniedException();
        }

        $logEntries = $logEntryRepository->getLogEntries($«name.formatForCode»);

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
                            ['%version%' => $revertToVersion],
                            '«name.formatForCode»'
                        )
                    );
                } else {
                    $this->addFlash(
                        'error',
                        $this->trans(
                            'Error! Reverting «name.formatForDisplay» to version %version% failed.',
                            ['%version%' => $revertToVersion],
                            '«name.formatForCode»'
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

                $«name.formatForCode» = $repository->selectById($«name.formatForCode»Id);
            «ENDIF»

            return $this->redirectToRoute(
                '«application.appName.formatForDB»_«name.formatForDB»_loggablehistory',
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
            '«name.formatForCode»' => $«name.formatForCode»,
            'logEntries' => $logEntries,
            'isDiffView' => $isDiffView,
        ];

        if (true === $isDiffView) {
            [
                $minVersion,
                $maxVersion,
                $diffValues
            ] = $loggableHelper->determineDiffViewParameters($logEntries, $versions);
            $templateParameters['minVersion'] = $minVersion;
            $templateParameters['maxVersion'] = $maxVersion;
            $templateParameters['diffValues'] = $diffValues;
        }

        return $this->render('@«application.vendorAndName»/«name.formatForCode.toFirstUpper»/history.html.twig', $templateParameters);
    '''
}
