package org.zikula.modulestudio.generator.cartridges.zclassic.controller.action

import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class LoggableDeleted {

    extension FormattingExtensions = new FormattingExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Entity it) '''
        «displayDeletedSingleAction(true)»

        «displayDeletedSingleAction(false)»

        «restoreDeletedEntity»

    '''

    def private displayDeletedSingleAction(Entity it, Boolean isAdmin) '''
        /**
         * Displays a deleted «name.formatForDisplay».
         *
         * @Route("/«IF isAdmin»admin/«ENDIF»«name.formatForCode»/deleted/{id}.{_format}",
         *        requirements = {"id" = "\d+", "_format" = "html"},
         *        defaults = {"_format" = "html"},
         *        methods = {"GET"}
         * )
         «IF isAdmin»
         * @Theme("admin")
         «ENDIF»
         *
         * @param Request $request Current request instance
         * @param integer $id      Identifier of entity
         *
         * @return Response Output
         *
         * @throws AccessDeniedException Thrown if the user doesn't have required permissions
         * @throws NotFoundHttpException Thrown if «name.formatForDisplay» to be displayed isn't found
         */
        public function «IF isAdmin»adminD«ELSE»d«ENDIF»isplayDeletedAction(Request $request, $id = 0)
        {
            $«name.formatForCode» = $this->restoreDeletedEntity($id);

            $undelete = $request->query->getInt('undelete', 0);
            if ($undelete == 1) {
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

                $request->query->set('«getPrimaryKey.name.formatForCode»', $«name.formatForCode»->get«getPrimaryKey.name.formatForCodeCapital»());
                $request->query->remove('undelete');

                return $this->redirectToRoute('«application.appName.formatForDB»_«name.formatForDB»_«IF isAdmin»admin«ENDIF»display', $request->query->all());
            }

            return parent::«IF isAdmin»adminD«ELSE»d«ENDIF»isplayAction($request, $«name.formatForCode»);
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
                if ($logEntry->getAction() != 'remove') {
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

            return $«name.formatForCode»;
        }
    '''
}
