package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableUndelete {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Entity it, Boolean isBase) '''
        «undelete(isBase, true)»

        «undelete(isBase, false)»

        «IF isBase»
            «restoreDeletedEntity»

        «ENDIF»
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

        «IF hasDisplayAction»
            $preview = $request->query->getInt('preview', 0);
            if ($preview == 1) {
                return $this->displayInternal($request, $«name.formatForCode», $isAdmin);
            }

        «ENDIF»
        «undeletion»

        $routeArea = $isAdmin ? 'admin' : '';

        return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_' . $routeArea . '«IF hasDisplayAction»display', $«name.formatForCode»->createUrlArgs()«ELSEIF hasViewAction»view'«ELSE»index'«ENDIF»);
    '''

    def private undeletion(Entity it) '''
        try {
            $em = $this->get('doctrine.entitymanager');
            $metadata = $em->getClassMetaData(get_class($«name.formatForCode»));
            $metadata->setIdGeneratorType(\Doctrine\ORM\Mapping\ClassMetadata::GENERATOR_TYPE_NONE);
            $metadata->setIdGenerator(new \Doctrine\ORM\Id\AssignedGenerator());

            $versionField = $metadata->versionField;
            $metadata->setVersioned(false);
            $metadata->setVersionField(null);

            $em->persist($«name.formatForCode»);
            $em->flush($«name.formatForCode»);

            $this->addFlash('status', $this->__('Done! Undeleted «name.formatForDisplay».'));

            $metadata->setVersioned(true);
            $metadata->setVersionField($versionField);
        } catch (\Exception $exception) {
            $this->addFlash('error', $this->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => 'undelete']) . '  ' . $exception->getMessage());
        }
    '''

    def private restoreDeletedEntity(Entity it) '''
        /**
         * Resets a deleted «name.formatForDisplay» back to the last version before it's deletion.
         *
         * @return «name.formatForCodeCapital»Entity The restored entity
         *
         * @throws NotFoundHttpException Thrown if «name.formatForDisplay» isn't found
         */
        protected function restoreDeletedEntity($id = 0)
        {
            if (!$id) {
                throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
            }

            $entityFactory = $this->get('«application.appService».entity_factory');
            $«name.formatForCode» = $entityFactory->create«name.formatForCodeCapital»();
            $«name.formatForCode»->set«getPrimaryKey.name.formatForCodeCapital»($id);
            $entityManager = $entityFactory->getObjectManager();
            $logEntriesRepository = $entityManager->getRepository('«application.appName»:«name.formatForCodeCapital»LogEntryEntity');
            $logEntries = $logEntriesRepository->getLogEntries($«name.formatForCode»);
            $lastVersionBeforeDeletion = null;
            foreach ($logEntries as $logEntry) {
                if ('remove' != $logEntry->getAction()) {
                    $lastVersionBeforeDeletion = $logEntry->getVersion();
                    break;
                }
            }
            if (null === $lastVersionBeforeDeletion) {
                throw new NotFoundHttpException($this->__('No such «name.formatForDisplay» found.'));
            }

            $logEntriesRepository->revert($«name.formatForCode», $lastVersionBeforeDeletion);
            «IF null !== getVersionField»
                $«name.formatForCode»->set«getVersionField.name.formatForCodeCapital»($lastVersionBeforeDeletion + 2);
            «ENDIF»

            $eventArgs = new \Doctrine\Common\Persistence\Event\LifecycleEventArgs($«name.formatForCode», $entityManager);
            $this->get('«application.appService».entity_lifecycle_listener')->postLoad($eventArgs);

            return $«name.formatForCode»;
        }
    '''
}
