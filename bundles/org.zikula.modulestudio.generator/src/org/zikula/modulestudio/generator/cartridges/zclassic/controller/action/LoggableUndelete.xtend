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
            public function «IF isAdmin»adminU«ELSE»u«ENDIF»ndeleteAction(
                «undeleteArguments(false)»
            )«IF application.targets('3.0')»: Response«ENDIF» {
                «IF application.targets('3.0')»
                    return $this->undeleteActionInternal(
                        $request,
                        $loggableHelper,«IF hasTranslatableFields»
                        $translatableHelper,«ENDIF»
                        $id,
                        «isAdmin.displayBool»
                    );
                «ELSE»
                    return $this->undeleteActionInternal($request, $id, «isAdmin.displayBool»);
                «ENDIF»
            }
        «ELSEIF isBase && !isAdmin»
            «undeleteDocBlock(isBase, isAdmin)»
            protected function undeleteActionInternal(
                «undeleteArguments(true)»
            )«IF application.targets('3.0')»: Response«ENDIF» {
                «loggableUndeleteBaseImpl»
            }
        «ENDIF»
    '''

    def private undeleteDocBlock(Entity it, Boolean isBase, Boolean isAdmin) '''
        /**
         * «IF hasDisplayAction»Displays or undeletes«ELSE»Undeletes«ENDIF» a deleted «name.formatForDisplay».
         *
         «IF isBase»
         «IF !application.targets('3.0')»
         * @param Request $request
         * @param int $id Identifier of entity
         * @param boolean $isAdmin Whether the admin area is used or not
         *
         * @return Response Output
         *
         «ENDIF»
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
        «IF application.targets('3.0')»
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
            throw new NotFoundHttpException(
                $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»(
                    'No such «name.formatForDisplay» found.'«IF application.targets('3.0') && !application.isSystemModule»,
                    [],
                    '«name.formatForCode»'«ENDIF»
                )
            );
        }

        «IF hasDisplayAction»
            $preview = $request->query->getInt('preview');
            if (1 === $preview) {
                return $this->displayInternal(
                    «IF application.targets('3.0')»
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
                    «ELSE»
                        $request, $«name.formatForCode», null, $isAdmin
                    «ENDIF»
                );
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
            $this->addFlash(
                'status',
                $this->«IF application.targets('3.0')»trans«ELSE»__«ENDIF»(
                    'Done! «name.formatForDisplayCapital» undeleted.'«IF application.targets('3.0') && !application.isSystemModule»,
                    [],
                    '«name.formatForCode»'«ENDIF»
                )
            );
        } catch (Exception $exception) {
            $this->addFlash(
                'error',
                $this->«IF application.targets('3.0')»trans«ELSE»__f«ENDIF»(
                    'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                    ['%action%' => 'undelete']
                ) . '  ' . $exception->getMessage()
            );
        }
    '''
}
