package org.zikula.modulestudio.generator.cartridges.symfony.controller.action

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

        «undelete(isBase)»
    '''

    def private undelete(Entity it, Boolean isBase) '''
        «undeleteDocBlock(isBase)»
        public function undelete(
            «undeleteArguments»
        ): Response {
            «IF isBase»
                «loggableUndeleteBaseImpl»
            «ELSE»
                return parent::undelete($request, $loggableHelper«IF hasTranslatableFields», $translatableHelper«ENDIF», $id);
            «ENDIF»
        }
    '''

    def private undeleteDocBlock(Entity it, Boolean isBase) '''
        «IF isBase»
            /**
             * «IF hasDetailAction»Displays or undeletes«ELSE»Undeletes«ENDIF» a deleted «name.formatForDisplay».
             *
             * @throws AccessDeniedException Thrown if the user doesn't have required permissions
             * @throws NotFoundHttpException Thrown if «name.formatForDisplay» to be displayed isn't found
             */
        «/*ELSE»
            #[Route('/«name.formatForCode»/deleted/{id}.{_format}',
                name: '«application.appName.formatForDB»_«name.formatForDB»_deleted',
                requirements: ['id' => '\d+', '_format' => 'html'],
                defaults: ['_format' => 'html'],
                methods: ['GET']
            )]
        */»«ENDIF»
    '''

    def private undeleteArguments(Entity it) '''
        Request $request,
        PermissionHelper $permissionHelper,
        ControllerHelper $controllerHelper,
        ViewHelper $viewHelper,
        «name.formatForCodeCapital»RepositoryInterface $repository,
        LoggableHelper $loggableHelper,
        «IF hasTranslatableFields»
            TranslatableHelper $translatableHelper,
        «ENDIF»
        int $id = 0
    '''

    def private loggableUndeleteBaseImpl(Entity it) '''
        $«name.formatForCode» = $loggableHelper->restoreDeletedEntity('«name.formatForCode»', $id);
        if (null === $«name.formatForCode») {
            throw new NotFoundHttpException(
                $this->trans(
                    'No such «name.formatForDisplay» found.',
                    [],
                    '«name.formatForCode»'
                )
            );
        }

        $isAdminArea = $request->attributes->get('isAdminArea', false);
        $permLevel = $isAdminArea ? ACCESS_ADMIN : ACCESS_EDIT;
        if (!$permissionHelper->hasEntityPermission($«name.formatForCode»/*, $permLevel*/)) {
            throw new AccessDeniedException();
        }

        «IF hasDetailAction»
            $preview = $request->query->getInt('preview');
            if (1 === $preview) {
                return $this->detail(
                    $request,
                    $permissionHelper,
                    $controllerHelper,
                    $viewHelper,
                    $repository,
                    $loggableHelper,
                    $«name.formatForCode»,
                    null
                );
            }

        «ENDIF»
        «undeletion»
        «IF hasTranslatableFields»

            $translatableHelper->refreshTranslationsFromLogData($«name.formatForCode»);
        «ENDIF»

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_«IF hasDetailAction»detail', $«name.formatForCode»->createUrlArgs()«ELSEIF hasIndexAction»index'«ELSE»«primaryAction»'«ENDIF»);
    '''

    def private undeletion(Entity it) '''
        try {
            $loggableHelper->undelete($«name.formatForCode»);
            $this->addFlash(
                'status',
                $this->trans(
                    'Done! «name.formatForDisplayCapital» undeleted.',
                    [],
                    '«name.formatForCode»'
                )
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
