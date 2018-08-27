package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableUndelete {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''
        «undelete(isBase, true)»

        «undelete(isBase, false)»

    '''

    def private undelete(Entity it, Boolean isBase, Boolean isAdmin) '''
        «undeleteDocBlock(isBase, isAdmin)»
        public function «IF isAdmin»adminU«ELSE»u«ENDIF»ndeleteAction(Request $request, $id = 0)
        {
            «IF isBase»
                return $this->undeleteActionInternal($request, $id, «isAdmin.displayBool»);
            «ELSE»
                return parent::«IF isAdmin»adminU«ELSE»u«ENDIF»ndeleteAction($request, $id);
            «ENDIF»
        }
        «IF isBase && !isAdmin»

            /**
             * This method includes the common implementation code for adminUndeleteAction() and undeleteAction().
             *
             * @param Request $request Current request instance
             * @param integer $id      Identifier of «name.formatForDisplay»
             * @param boolean $isAdmin Whether the admin area is used or not
             */
            protected function undeleteActionInternal(Request $request, $id = 0, $isAdmin = false)
            {
                «loggableUndeleteBaseImpl»
            }
        «ENDIF»
    '''

    def private undeleteDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        /**
         «IF isBase»
         * «IF hasDisplayAction»Displays or undeletes«ELSE»Undeletes«ENDIF» a deleted «name.formatForDisplay».
         *
         * @param Request $request Current request instance
         * @param integer $id      Identifier of entity
         *
         * @return Response Output
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         * @throws NotFoundHttpException Thrown if «name.formatForDisplay» to be displayed isn't found
         «ELSE»
         * @inheritDoc
         * @Route("/«IF isAdmin»admin/«ENDIF»«name.formatForCode»/deleted/{id}.{_format}",
         *        requirements = {"id" = "\d+", "_format" = "html"},
         *        defaults = {"_format" = "html"},
         *        methods = {"GET"}
         * )
         «IF isAdmin»
         * @Theme("admin")
         «ENDIF»
         «ENDIF»
         */
    '''

    def private loggableUndeleteBaseImpl(Entity it) '''
        $«name.formatForCode» = $this->restoreDeletedEntity($id);
        if (null === $«name.formatForCode») {
            throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
        }

        «IF hasDisplayAction»
            $preview = $request->query->getInt('preview', 0);
            if ($preview == 1) {
                return $this->displayInternal($request, $«name.formatForCode», $isAdmin);
            }

        «ENDIF»
        «undeletion»
        «IF hasTranslatableFields»

            $this->get('«application.appService».translatable_helper')->refreshTranslationsFromLogData($«name.formatForCode»);
        «ENDIF»

        $routeArea = $isAdmin ? 'admin' : '';

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . '«IF hasDisplayAction»display', $«name.formatForCode»->createUrlArgs()«ELSEIF hasViewAction»view'«ELSE»index'«ENDIF»);
    '''

    def private undeletion(Entity it) '''
        try {
            $this->get('«application.appService».loggable_helper')->undelete($«name.formatForCode»);
            $this->addFlash('status', $this->__('Done! Undeleted «name.formatForDisplay».'));
        } catch (\Exception $exception) {
            $this->addFlash('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => 'undelete']) . '  ' . $exception->getMessage());
        }
    '''
}
