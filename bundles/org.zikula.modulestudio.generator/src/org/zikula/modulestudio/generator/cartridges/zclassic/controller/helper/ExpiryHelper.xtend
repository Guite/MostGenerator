package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.Entity
import org.zikula.modulestudio.generator.application.IMostFileSystemAccess
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.DateTimeExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ExpiryHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
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
        «IF targets('3.0')»
            use Symfony\Contracts\Translation\TranslatorInterface;
            use Zikula\Bundle\CoreBundle\Doctrine\EntityAccess;
            use Zikula\Bundle\CoreBundle\RouteUrl;
        «ENDIF»
        «IF hasHookSubscribers»
            use Zikula\Bundle\HookBundle\Category\UiHooksCategory;
        «ENDIF»
        «IF !targets('3.0')»
            use Zikula\Common\Translator\TranslatorInterface;
            use Zikula\Core\Doctrine\EntityAccess;
            use Zikula\Core\RouteUrl;
        «ENDIF»
        use «appNamespace»\Entity\Factory\EntityFactory;
        «IF hasHookSubscribers»
            use «appNamespace»\Helper\HookHelper;
        «ENDIF»
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
        /**
         * @var TranslatorInterface
         */
        protected $translator;

        /**
         * @var RequestStack
         */
        protected $requestStack;

        /**
         * @var LoggerInterface
         */
        protected $logger;

        /**
         * @var EntityFactory
         */
        protected $entityFactory;

        /**
         * @var PermissionHelper
         */
        protected $permissionHelper;

        /**
         * @var WorkflowHelper
         */
        protected $workflowHelper;
        «IF hasHookSubscribers»

            /**
             * @var HookHelper
             */
            protected $hookHelper;
        «ENDIF»

        public function __construct(
            TranslatorInterface $translator,
            RequestStack $requestStack,
            LoggerInterface $logger,
            EntityFactory $entityFactory,
            PermissionHelper $permissionHelper,
            WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
            HookHelper $hookHelper«ENDIF»
        ) {
            $this->translator = $translator;
            $this->requestStack = $requestStack;
            $this->logger = $logger;
            $this->entityFactory = $entityFactory;
            $this->permissionHelper = $permissionHelper;
            $this->workflowHelper = $workflowHelper;
            «IF hasHookSubscribers»
                $this->hookHelper = $hookHelper;
            «ENDIF»
        }

        /**
         * Handles obsolete data bv either moving into the archive or deleting.
         «IF !targets('3.0')»
         *
         * @param int $probabilityPercent Execution probability
         «ENDIF»
         */
        public function handleObsoleteObjects(«IF targets('3.0')»int «ENDIF»$probabilityPercent = 75)«IF targets('3.0')»: void«ENDIF»
        {
            $randProbability = «IF targets('3.0')»random_int«ELSE»mt_rand«ENDIF»(1, 100);
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
        protected function archive«nameMultiple.formatForCodeCapital»()«IF application.targets('3.0')»: void«ENDIF»
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
        protected function delete«nameMultiple.formatForCodeCapital»()«IF application.targets('3.0')»: void«ENDIF»
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
         *
         «IF !targets('3.0')»
         * @param string $objectType Name of treated entity type
         * @param string $endField Name of field storing the end date
         «ENDIF»
         * @param mixed $endDate Datetime or date string for the threshold date
         *
         * @return array List of affected entities
         */
        protected function getExpiredObjects(«IF targets('3.0')»string «ENDIF»$objectType = '', «IF targets('3.0')»string «ENDIF»$endField = '', $endDate = '')
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
            } catch (TableNotFoundException $exception) {
                // module has just been uninstalled
                return [];
            }
        }
        «IF hasAutomaticArchiving»

            /**
             * Archives a single entity.
             «IF !targets('3.0')»
             *
             * @param EntityAccess $entity The given entity instance
             *
             * @return bool True if everything worked successfully, false otherwise
             «ENDIF»
             */
            protected function archiveSingleObject(«IF targets('3.0')»EntityAccess «ENDIF»$entity)«IF targets('3.0')»: bool«ENDIF»
            {
                return $this->handleSingleObject($entity, 'archive');
            }
        «ENDIF»
        «IF hasAutomaticExpiryDeletion»

            /**
             * Deletes a single entity.
             «IF !targets('3.0')»
             *
             * @param EntityAccess $entity The given entity instance
             *
             * @return bool True if everything worked successfully, false otherwise
             «ENDIF»
             */
            protected function deleteSingleObject(«IF targets('3.0')»EntityAccess «ENDIF»$entity)«IF targets('3.0')»: bool«ENDIF»
            {
                return $this->handleSingleObject($entity, 'delete');
            }
        «ENDIF»

        /**
         * Archives or deletes a single entity.
         «IF !targets('3.0')»
         *
         * @param EntityAccess $entity The given entity instance
         * @param string $action Name of workflow action to be executed
         *
         * @return bool True if everything worked successfully, false otherwise
         «ENDIF»
         */
        protected function handleSingleObject(«IF targets('3.0')»EntityAccess «ENDIF»$entity, «IF targets('3.0')»string «ENDIF»$action)«IF targets('3.0')»: bool«ENDIF»
        {
            $request = $this->requestStack->getCurrentRequest();
            $session = $request->hasSession() ? $request->getSession() : null;
            «IF hasHookSubscribers»
                if ($entity->supportsHookSubscribers()) {
                    // let any hooks perform additional validation actions
                    $hookType = 'delete' === $action
                        ? UiHooksCategory::TYPE_VALIDATE_DELETE
                        : UiHooksCategory::TYPE_VALIDATE_EDIT
                    ;
                    $validationErrors = $this->hookHelper->callValidationHooks($entity, $hookType);
                    if (0 < count($validationErrors)) {
                        if (null !== $session) {
                            foreach ($validationErrors as $message) {
                                $session->getFlashBag()->add('error', $message);
                            }
                        }

                        return false;
                    }
                }

            «ENDIF»
            $success = false;
            try {
                // execute the workflow action
                $success = $this->workflowHelper->executeAction($entity, $action);
            } catch (Exception $exception) {
                if (null !== $session) {
                    $session->getFlashBag()->add(
                        'error',
                        $this->translator->«IF targets('3.0')»trans«ELSE»__f«ENDIF»(
                            'Sorry, but an error occured during the %action% action. Please apply the changes again!',
                            ['%action%' => $action]
                        ) . '  ' . $exception->getMessage()
                    );
                }
            }

            if (!$success) {
                return false;
            }
            «IF hasHookSubscribers»

                if ($entity->supportsHookSubscribers()) {
                    // let any hooks know that we have updated an item
                    $objectType = $entity->get_objectType();
                    $url = null;

                    $hasDisplayPage = in_array($objectType, ['«getAllEntities.filter[hasDisplayAction].map[name.formatForCode].join('\', \'')»']);
                    if ($hasDisplayPage) {
                        $urlArgs = $entity->createUrlArgs();
                        if (null !== $request) {
                            $urlArgs['_locale'] = $request->getLocale();
                        }
                        $url = new RouteUrl('«appName.formatForDB»_' . strtolower($objectType) . '_display', $urlArgs);
                    }
                    $hookType = 'delete' === $action
                        ? UiHooksCategory::TYPE_PROCESS_DELETE
                        : UiHooksCategory::TYPE_PROCESS_EDIT
                    ;
                    $this->hookHelper->callProcessHooks($entity, $hookType, $url);
                }
            «ENDIF»

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
