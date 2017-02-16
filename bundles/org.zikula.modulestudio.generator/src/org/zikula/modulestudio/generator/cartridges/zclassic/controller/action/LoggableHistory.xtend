package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.UrlExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableHistory {

    extension FormattingExtensions = new FormattingExtensions
    extension UrlExtensions = new UrlExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''
        «loggableHistory(isBase, true)»

        «loggableHistory(isBase, false)»
    '''

    def private loggableHistory(Entity it, Boolean isBase, Boolean isAdmin) '''
        «loggableHistoryDocBlock(isBase, isAdmin)»
        public function «IF isAdmin»adminL«ELSE»l«ENDIF»oggableHistoryAction(Request $request, $id = 0)
        {
            «IF isBase»
                return $this->loggableHistoryActionInternal($request, $id, «isAdmin.displayBool»);
            «ELSE»
                return parent::«IF isAdmin»adminL«ELSE»l«ENDIF»oggableHistoryAction($request, $id);
            «ENDIF»
        }
        «IF isBase && !isAdmin»

            /**
             * This method includes the common implementation code for adminLoggableHistoryAction() and loggableHistoryAction().
             *
             * @param Request $request Current request instance
             * @param integer $id      Identifier of «name.formatForDisplay»
             * @param Boolean $isAdmin Whether the admin area is used or not
             */
            protected function loggableHistoryActionInternal(Request $request, $id = 0, $isAdmin = false)
            {
                «loggableHistoryBaseImpl»
            }
        «ENDIF»
    '''

    def private loggableHistoryDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        /**
         * This method provides a change history for a given «name.formatForDisplay».
         «IF !isBase»
         *
         * @Route("/«IF isAdmin»admin/«ENDIF»«name.formatForCode»/history/{id}",
         *        requirements = {"id" = "\d+"},
         *        defaults = {"id" = 0},
         *        methods = {"GET"}
         * )
         «IF isAdmin»
              * @Theme("admin")
         «ENDIF»
         «ENDIF»
         *
         * @param Request $request Current request instance
         * @param integer $id      Identifier of «name.formatForDisplay»
         *
         * @return Response Output
         *
         * @throws NotFoundHttpException Thrown if invalid identifier is given or the «name.formatForDisplay» isn't found
         */
    '''

    def private loggableHistoryBaseImpl(Entity it) '''
        if (empty($id)) {
            throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
        }

        $entityFactory = $this->get('«application.appService».entity_factory');
        $«name.formatForCode» = $entityFactory->getRepository('«name.formatForCode»')->selectById($id);
        if (null === $«name.formatForCode») {
            throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
        }

        $routeArea = $isAdmin ? 'admin' : '';
        $entityManager = $entityFactory->getObjectManager();
        $logEntriesRepository = $entityManager->getRepository('«application.appName»:«name.formatForCodeCapital»LogEntryEntity');
        $logEntries = $logEntriesRepository->getLogEntries($«name.formatForCode»);

        $revertToVersion = $request->query->getInt('revert', 0);
        if ($revertToVersion > 0 && count($logEntries) > 1) {
            // revert to requested version
            $logEntriesRepository->revert($«name.formatForCode», $revertToVersion);

            try {
                // execute the workflow action
                $workflowHelper = $this->get('«application.appService».workflow_helper');
                $success = $workflowHelper->executeAction($«name.formatForCode», 'update');

                if ($success) {
                    $this->addFlash('status', $this->__f('Done! Reverted «name.formatForDisplay» to version %version%.', ['%version%' => $revertToVersion]));
                } else {
                    $this->addFlash('error', $this->__f('Error! Reverting «name.formatForDisplay» to version %version% failed.', ['%version%' => $revertToVersion]));
                }
            } catch(\Exception $e) {
                $this->addFlash('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => 'update']) . '  ' . $e->getMessage());
            }

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
            $minVersion = $maxVersion = 0;
            if ($versions[0] < $versions[1]) {
                $minVersion = $versions[0];
                $maxVersion = $versions[1];
            } else {
                $minVersion = $versions[1];
                $maxVersion = $versions[0];
            }
            $logEntries = array_reverse($logEntries);

            $diffValues = [];
            foreach ($logEntries as $logEntry) {
                foreach ($logEntry->getData() as $field => $value) {
                    if (!isset($diffValues[$field])) {
                        $diffValues[$field] = [
                            'old' => '',
                            'new' => '',
                            'changed' => false
                        ];
                    }
                    if (is_array($value)) {
                        $value = implode(', ', $value);
                    }
                    if ($logEntry->getVersion() <= $minVersion) {
                        $diffValues[$field]['old'] = $value;
                        $diffValues[$field]['new'] = $value;
                    } elseif ($logEntry->getVersion() <= $maxVersion) {
                        $diffValues[$field]['new'] = $value;
                        $diffValues[$field]['changed'] = $diffValues[$field]['new'] != $diffValues[$field]['old'];
                    }
                }
            }
            $templateParameters['minVersion'] = $minVersion;
            $templateParameters['maxVersion'] = $maxVersion;
            $templateParameters['diffValues'] = $diffValues;
        }

        return $this->render('@«application.appName»/«name.formatForCode.toFirstUpper»/history.html.twig', $templateParameters);
    '''
}
