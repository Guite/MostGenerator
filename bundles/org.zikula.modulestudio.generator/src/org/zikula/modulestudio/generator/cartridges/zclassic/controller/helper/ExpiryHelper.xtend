package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExpiryHelper {

    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for automatic expiry handling'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ExpiryHelper.php', expiryHelperBaseClass, expiryHelperImpl)
    }

    def private expiryHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\DBAL\Exception\TableNotFoundException;
        use Exception;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Symfony\Contracts\Translation\TranslatorInterface;
        use «appNamespace»\Entity\EntityInterface;
        use «appNamespace»\Entity\Factory\EntityFactory;
        use «appNamespace»\Helper\PermissionHelper;
        use «appNamespace»\Helper\WorkflowHelper;

        /**
         * Expiry helper base class.
         */
        abstract class AbstractExpiryHelper
        {
            «helperBaseImpl»
        }
    '''

    def private helperBaseImpl(Application it) '''
        public function __construct(
            protected TranslatorInterface $translator,
            protected RequestStack $requestStack,
            protected LoggerInterface $logger,
            protected EntityFactory $entityFactory,
            protected PermissionHelper $permissionHelper,
            protected WorkflowHelper $workflowHelper
        ) {
        }

        /**
         * Handles obsolete data bv either moving into the archive or deleting.
         */
        public function handleObsoleteObjects(int $probabilityPercent = 75): void
        {
            $randProbability = random_int(1, 100);
            if ($randProbability < $probabilityPercent) {
                return;
            }

            «IF hasAutomaticArchiving»
                if ($this->permissionHelper->hasPermission(ACCESS_EDIT)) {
                    «FOR entity : getArchivingEntities»
                        // perform update for «entity.nameMultiple.formatForDisplay» becoming archived
                        $logArgs = ['app' => '«appName»', 'entity' => '«entity.name.formatForCode»'];
                        $this->logger->notice('{app}: Automatic archiving for the {entity} entity started.', $logArgs);
                        $this->archive«entity.nameMultiple.formatForCodeCapital»();
                        $this->logger->notice('{app}: Automatic archiving for the {entity} entity completed.', $logArgs);
                    «ENDFOR»
                }
            «ENDIF»
            «IF hasAutomaticExpiryDeletion»
                if ($this->permissionHelper->hasPermission(ACCESS_DELETE)) {
                    «FOR entity : getArchivingEntities»
                        // perform deletion for expired «entity.nameMultiple.formatForDisplay»
                        $logArgs = ['app' => '«appName»', 'entity' => '«entity.name.formatForCode»'];
                        $this->logger->notice('{app}: Automatic deletion for the {entity} entity started.', $logArgs);
                        $this->delete«entity.nameMultiple.formatForCodeCapital»();
                        $this->logger->notice('{app}: Automatic deletion for the {entity} entity completed.', $logArgs);
                    «ENDFOR»
                }
            «ENDIF»
        }
        «FOR entity : getArchivingEntities»

            «entity.archiveObjects»
        «ENDFOR»
        «FOR entity : getExpiryDeletionEntities»

            «entity.deleteObjects»
        «ENDFOR»

        «helperMethods»
    '''

    def private archiveObjects(Entity it) '''
        /**
         * Moves «nameMultiple.formatForDisplay» into the archive which reached their end date.
         *
         * @throws RuntimeException Thrown if workflow action execution fails
         */
        protected function archive«nameMultiple.formatForCodeCapital»(): void
        {
            «val endField = getEndDateField»
            «IF endField.isDateTimeField»
                $today = «endField.defaultValueForNow»;
            «ELSEIF endField.isDateField»
                $today = «endField.defaultValueForNow» . ' 00:00:00';
            «ENDIF»

            $affectedEntities = $this->getExpiredObjects('«name.formatForCode»', '«endField.name.formatForCode»', $today);
            foreach ($affectedEntities as $entity) {
                $this->archiveSingleObject($entity);
            }
        }
    '''

    def private deleteObjects(Entity it) '''
        /**
         * Deletes «nameMultiple.formatForDisplay» which reached their end date.
         *
         * @throws RuntimeException Thrown if workflow action execution fails
         */
        protected function delete«nameMultiple.formatForCodeCapital»(): void
        {
            «val endField = getEndDateField»
            «IF endField.isDateTimeField»
                $today = «endField.defaultValueForNow»;
            «ELSEIF endField.isDateField»
                $today = «endField.defaultValueForNow» . ' 00:00:00';
            «ENDIF»

            $affectedEntities = $this->getExpiredObjects('«name.formatForCode»', '«endField.name.formatForCode»', $today);
            foreach ($affectedEntities as $entity) {
                $this->deleteSingleObject($entity);
            }
        }
    '''

    def private helperMethods(Application it) '''
        /**
         * Returns the list of expired entities.
         */
        protected function getExpiredObjects(string $objectType = '', string $endField = '', $endDate = ''): array
        {
            $repository = $this->entityFactory->getRepository($objectType);
            $qb = $repository->genericBaseQuery('', '', false);
            «/*$qb->andWhere('tbl.workflowState != :archivedState')
               ->setParameter('archivedState', 'archived');*/»
            $qb->andWhere('tbl.workflowState = :approvedState')
               ->setParameter('approvedState', 'approved');

            $qb->andWhere('tbl.' . $endField . ' < :endThreshold')
               ->setParameter('endThreshold', $endDate);

            $query = $repository->getQueryFromBuilder($qb);

            try {
                return $query->getResult();
            } catch (TableNotFoundException) {
                // module has just been uninstalled
                return [];
            }
        }
        «IF hasAutomaticArchiving»

            /**
             * Archives a single entity.
             */
            protected function archiveSingleObject(EntityInterface $entity): bool
            {
                return $this->handleSingleObject($entity, 'archive');
            }
        «ENDIF»
        «IF hasAutomaticExpiryDeletion»

            /**
             * Deletes a single entity.
             */
            protected function deleteSingleObject(EntityInterface $entity): bool
            {
                return $this->handleSingleObject($entity, 'delete');
            }
        «ENDIF»

        /**
         * Archives or deletes a single entity.
         */
        protected function handleSingleObject(EntityInterface $entity, string $action): bool
        {
            $request = $this->requestStack->getCurrentRequest();
            $session = $request->hasSession() ? $request->getSession() : null;
            $success = false;
            try {
                // execute the workflow action
                $success = $this->workflowHelper->executeAction($entity, $action);
            } catch (Exception $exception) {
                if (null !== $session) {
                    $session->getFlashBag()->add(
                        'error',
                        $this->translator->trans(
                            'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                            ['%action%' => $action]
                        ) . '  ' . $exception->getMessage()
                    );
                }
            }

            if (!$success) {
                return false;
            }

            return $success;
        }
    '''

    def private expiryHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractExpiryHelper;

        /**
         * Expiry helper implementation class.
         */
        class ExpiryHelper extends AbstractExpiryHelper
        {
            // feel free to extend the expiry helper here
        }
    '''
}
