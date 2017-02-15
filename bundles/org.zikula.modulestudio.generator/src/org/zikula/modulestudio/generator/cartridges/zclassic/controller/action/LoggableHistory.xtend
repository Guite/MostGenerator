package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableHistory {

    extension FormattingExtensions = new FormattingExtensions
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
         «ENDIF»
         «IF isAdmin»
              * @Theme("admin")
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
        $entity = $entityFactory->getRepository('«name.formatForCode»')->selectById($id);
        if (null === $entity) {
            throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
        }

        $logEntriesRepo = $entityFactory->getObjectManager()->getRepository('«application.appName»:«name.formatForCodeCapital»LogEntryEntity');
        $logEntries = $logEntriesRepo->getLogEntries($entity);

        $templateParameters = [
            'routeArea' => $isAdmin ? 'admin' : '',
            '«name.formatForCode»' => $entity,
            'logEntries' => $logEntries
        ];

        return $this->render('@«application.appName»/«name.formatForCode.toFirstUpper»/history.html.twig', $templateParameters);
    '''
}
