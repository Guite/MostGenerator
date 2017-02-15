package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableHistory {

    extension FormattingExtensions = new FormattingExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''
        «loggableHistoryDocBlock(isBase)»
        public function loggableHistoryAction(Request $request, $id = 0)
        {
            «IF isBase»
                «loggableHistoryBaseImpl»
            «ELSE»
                return parent::loggableHistoryAction($request, $id);
            «ENDIF»
        }
    '''

    def private loggableHistoryDocBlock(Entity it, Boolean isBase) '''
        /**
         * This method provides a change history for a given «name.formatForDisplay».
         «IF !isBase»
         *
         * @Route("/«name.formatForCode»/history/{id}",
         *        requirements = {"id" = "\d+"},
         *        defaults = {"id" = 0},
         *        methods = {"GET"}
         * )
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
            '«name.formatForCode»' => $entity,
            'logEntries' => $logEntries
        ];

        return $this->render('@«application.appName»/«name.formatForCode.toFirstUpper»/history.html.twig', $templateParameters);
    '''
}
