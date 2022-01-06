package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableUndelete {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
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
            public function «IF isAdmin»adminU«ELSE»u«ENDIF»ndelete«IF !application.targets('3.1')»Action«ENDIF»(
                «undeleteArguments(false)»
            ): Response {
                return $this->undeleteInternal(
                    $request,
                    $loggableHelper,«IF hasTranslatableFields»
                    $translatableHelper,«ENDIF»
                    $id,
                    «isAdmin.displayBool»
                );
            }
        «ELSEIF isBase && !isAdmin»
            «undeleteDocBlock(isBase, isAdmin)»
            protected function undeleteInternal(
                «undeleteArguments(true)»
            ): Response {
                «loggableUndeleteBaseImpl»
            }
        «ENDIF»
    '''

    def private undeleteDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        /**
         * «IF hasDisplayAction»Displays or undeletes«ELSE»Undeletes«ENDIF» a deleted «name.formatForDisplay».
         *
         «IF isBase»
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         * @throws NotFoundHttpException Thrown if «name.formatForDisplay» to be displayed isn't found
         «ELSE»
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
        Request $request,
        PermissionHelper $permissionHelper,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        EntityFactory $entityFactory,
        «IF categorisable»
            CategoryHelper $categoryHelper,
            FeatureActivationHelper $featureActivationHelper,
        «ENDIF»
        LoggableHelper $loggableHelper,
        «IF application.generateIcsTemplates && hasStartAndEndDateField»
            EntityDisplayHelper $entityDisplayHelper,
        «ENDIF»
        «IF hasTranslatableFields»
            TranslatableHelper $translatableHelper,
        «ENDIF»
        int $id = 0«IF internalMethod»,
        bool $isAdmin = false«ENDIF»
    '''

    def private loggableUndeleteBaseImpl(Entity it) '''
        $«name.formatForCode» = $loggableHelper->restoreDeletedEntity('«name.formatForCode»', $id);
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

        «IF hasDisplayAction»
            $preview = $request->query->getInt('preview');
            if (1 === $preview) {
                return $this->displayInternal(
                    $request,
                    $permissionHelper,
                    $controllerHelper,
                    $viewHelper,
                    $entityFactory,
                    «IF categorisable»
                        $categoryHelper,
                        $featureActivationHelper,
                    «ENDIF»
                    $loggableHelper,
                    «IF application.generateIcsTemplates && hasStartAndEndDateField»
                        $entityDisplayHelper,
                    «ENDIF»
                    $«name.formatForCode»,
                    null,
                    $isAdmin
                );
            }

        «ENDIF»
        «undeletion»
        «IF hasTranslatableFields»

            $translatableHelper->refreshTranslationsFromLogData($«name.formatForCode»);
        «ENDIF»

        $routeArea = $isAdmin ? 'admin' : '';

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . '«IF hasDisplayAction»display', $«name.formatForCode»->createUrlArgs()«ELSEIF hasViewAction»view'«ELSE»index'«ENDIF»);
    '''

    def private undeletion(Entity it) '''
        try {
            $loggableHelper->undelete($«name.formatForCode»);
            $this->addFlash(
                'status',
                «IF application.isSystemModule»
                    'Done! «name.formatForDisplayCapital» undeleted.'
                «ELSE»
                    $this->trans(
                        'Done! «name.formatForDisplayCapital» undeleted.',
                        [],
                        '«name.formatForCode»'
                    )
                «ENDIF»
            );
        } catch (Exception $exception) {
            $this->addFlash(
                'error',
                $this->trans(
                    'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                    ['%action%' => 'undelete']
                ) . '  ' . $exception->getMessage()
            );
        }
    '''
}
