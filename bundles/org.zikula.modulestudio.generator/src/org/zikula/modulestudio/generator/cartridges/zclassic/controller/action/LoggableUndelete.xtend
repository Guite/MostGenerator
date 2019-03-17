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
        «IF !isBase»
            «undeleteDocBlock(isBase, isAdmin)»
            public function «IF isAdmin»adminU«ELSE»u«ENDIF»ndeleteAction(
                «undeleteArguments(false)»
            ) {
                «IF application.targets('3.0')»
                    return $this->undeleteActionInternal($request, $loggableHelper, «IF hasTranslatableFields»$translatableHelper, «ENDIF»$id, «isAdmin.displayBool»);
                «ELSE»
                    return $this->undeleteActionInternal($request, $id, «isAdmin.displayBool»);
                «ENDIF»
            }
        «ELSEIF isBase && !isAdmin»
            «undeleteDocBlock(isBase, isAdmin)»
            protected function undeleteActionInternal(
                «undeleteArguments(true)»
            ) {
                «loggableUndeleteBaseImpl»
            }
        «ENDIF»
    '''

    def private undeleteDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        /**
         «IF isBase»
         * «IF hasDisplayAction»Displays or undeletes«ELSE»Undeletes«ENDIF» a deleted «name.formatForDisplay».
         *
         * @param Request $request
         «IF application.targets('3.0')»
         * @param LoggableHelper $loggableHelper
         «IF hasTranslatableFields»
         * @param TranslatableHelper $translatableHelper
         «ENDIF»
         «ENDIF»
         * @param integer $id Identifier of entity
         * @param boolean $isAdmin Whether the admin area is used or not
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

    def private undeleteArguments(Entity it, Boolean internalMethod) '''
        «IF application.targets('3.0')»
            Request $request,
            LoggableHelper $loggableHelper,
            «IF hasTranslatableFields»
                TranslatableHelper $translatableHelper,
            «ENDIF»
            $id = 0«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ELSE»
            Request $request,
            $id = 0«IF internalMethod»,
            $isAdmin = false«ENDIF»
        «ENDIF»
    '''

    def private loggableUndeleteBaseImpl(Entity it) '''
        «IF !application.targets('3.0')»
            $loggableHelper = $this->get('«application.appService».loggable_helper');
        «ENDIF»
        $«name.formatForCode» = $loggableHelper->restoreDeletedEntity('«name.formatForCode»', $id);
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

            «IF application.targets('3.0')»$translatableHelper«ELSE»$this->get('«application.appService».translatable_helper')«ENDIF»->refreshTranslationsFromLogData($«name.formatForCode»);
        «ENDIF»

        $routeArea = $isAdmin ? 'admin' : '';

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . '«IF hasDisplayAction»display', $«name.formatForCode»->createUrlArgs()«ELSEIF hasViewAction»view'«ELSE»index'«ENDIF»);
    '''

    def private undeletion(Entity it) '''
        try {
            $loggableHelper->undelete($«name.formatForCode»);
            $this->addFlash('status', $this->__('Done! Undeleted «name.formatForDisplay».'));
        } catch (\Exception $exception) {
            $this->addFlash('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => 'undelete']) . '  ' . $exception->getMessage());
        }
    '''
}
