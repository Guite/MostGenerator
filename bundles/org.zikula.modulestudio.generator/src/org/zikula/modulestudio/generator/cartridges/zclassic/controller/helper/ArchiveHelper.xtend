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

class ArchiveHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension DateTimeExtensions = new DateTimeExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension Utils = new Utils

    def generate(Application it, IMostFileSystemAccess fsa) {
        'Generating helper class for automatic archiving'.printIfNotTesting(fsa)
        fsa.generateClassPair('Helper/ArchiveHelper.php', archiveHelperBaseClass, archiveHelperImpl)
    }

    def private archiveHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasHookSubscribers»
            use Zikula\Bundle\HookBundle\Category\UiHooksCategory;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\RouteUrl;
        use Zikula\PermissionsModule\Api\ApiInterface\PermissionApiInterface;
        use «appNamespace»\Entity\Factory\EntityFactory;
        «IF hasHookSubscribers»
            use «appNamespace»\Helper\HookHelper;
        «ENDIF»
        use «appNamespace»\Helper\WorkflowHelper;

        /**
         * Archive helper base class.
         */
        abstract class AbstractArchiveHelper
        {
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
             * @var PermissionApiInterface
             */
            protected $permissionApi;

            /**
             * @var EntityFactory
             */
            protected $entityFactory;

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

            /**
             * ArchiveHelper constructor.
             *
             * @param TranslatorInterface    $translator     Translator service instance
             * @param RequestStack           $requestStack   RequestStack service instance
             * @param LoggerInterface        $logger         Logger service instance
             * @param PermissionApiInterface $permissionApi  PermissionApi service instance
             * @param EntityFactory          $entityFactory  EntityFactory service instance
             * @param WorkflowHelper         $workflowHelper WorkflowHelper service instance
             «IF hasHookSubscribers»
             * @param HookHelper             $hookHelper     HookHelper service instance
             «ENDIF»
             */
            public function __construct(
                TranslatorInterface $translator,
                RequestStack $requestStack,
                LoggerInterface $logger,
                PermissionApiInterface $permissionApi,
                EntityFactory $entityFactory,
                WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
                HookHelper $hookHelper«ENDIF»
            ) {
                $this->translator = $translator;
                $this->requestStack = $requestStack;
                $this->logger = $logger;
                $this->permissionApi = $permissionApi;
                $this->entityFactory = $entityFactory;
                $this->workflowHelper = $workflowHelper;
                «IF hasHookSubscribers»
                    $this->hookHelper = $hookHelper;
                «ENDIF»
            }

            «archiveHelperBaseImpl»
        }
    '''

    def private archiveHelperBaseImpl(Application it) '''
        /**
         * Moves obsolete data into the archive.
         */
        public function archiveObsoleteObjects()
        {
            $randProbability = mt_rand(1, 1000);
            if ($randProbability < 750) {
                return;
            }

            if (!$this->permissionApi->hasPermission('«appName»', '.*', ACCESS_EDIT)) {
                // abort if current user has no permission for executing the archive workflow action
                return;
            }
            «FOR entity : getArchivingEntities»

                // perform update for «entity.nameMultiple.formatForDisplay» becoming archived
                $logArgs = ['app' => '«appName»', 'entity' => '«entity.name.formatForCode»'];
                $this->logger->notice('{app}: Automatic archiving for the {entity} entity started.', $logArgs);
                $this->archive«entity.nameMultiple.formatForCodeCapital»();
                $this->logger->notice('{app}: Automatic archiving for the {entity} entity completed.', $logArgs);
            «ENDFOR»
        }
        «FOR entity : getArchivingEntities»

            «entity.archiveObjects»
        «ENDFOR»

        «helperMethods»
    '''

    def private archiveObjects(Entity it) '''
        /**
         * Moves «nameMultiple.formatForDisplay» into the archive which reached their end date.
         *
         * @throws RuntimeException Thrown if workflow action execution fails
         */
        protected function archive«nameMultiple.formatForCodeCapital»()
        {
            «val endField = getEndDateField»
            «IF endField.isDateTimeField»
                $today = «endField.defaultValueForNow»;
            «ELSEIF endField.isDateField»
                $today = «endField.defaultValueForNow» . ' 00:00:00';
            «ENDIF»

            $affectedEntities = $this->getObjectsToBeArchived('«name.formatForCode»', '«endField.name.formatForCode»', $today);
            foreach ($affectedEntities as $entity) {
                $this->archiveSingleObject($entity);
            }
        }
    '''

    def private helperMethods(Application it) '''
        /**
         * Returns the list of entities which should be archived.
         *
         * @param string $objectType Name of treated entity type
         * @param string $endField   Name of field storing the end date
         * @param mixed  $endDate    Datetime or date string for the threshold date
         *
         * @return array List of affected entities
         */
        protected function getObjectsToBeArchived($objectType = '', $endField = '', $endDate = '')
        {
            $repository = $this->entityFactory->getRepository($objectType);
            $qb = $repository->genericBaseQuery('', '', false);

            /*$qb->andWhere('tbl.workflowState != :archivedState')
               ->setParameter('archivedState', 'archived');*/
            $qb->andWhere('tbl.workflowState = :approvedState')
               ->setParameter('approvedState', 'approved');

            $qb->andWhere('tbl.' . $endField . ' < :endThreshold')
               ->setParameter('endThreshold', $endDate);

            $query = $repository->getQueryFromBuilder($qb);

            return $query->getResult();
        }

        /**
         * Archives a single entity.
         *
         * @param object $entity The given entity instance
         *
         * @return boolean True if everything worked successfully, false otherwise
         */
        protected function archiveSingleObject($entity)
        {
            $request = $this->requestStack->getCurrentRequest();
            «IF hasHookSubscribers»
                if ($entity->supportsHookSubscribers()) {
                    // Let any hooks perform additional validation actions
                    $validationErrors = $this->hookHelper->callValidationHooks($entity, UiHooksCategory::TYPE_VALIDATE_EDIT);
                    if (count($validationErrors) > 0) {
                        if (null !== $request) {
                            $flashBag = $request->getSession()->getFlashBag();
                            foreach ($validationErrors as $message) {
                                $flashBag->add('error', $message);
                            }
                        }

                        return false;
                    }
                }

            «ENDIF»
            $success = false;
            try {
                // execute the workflow action
                $success = $this->workflowHelper->executeAction($entity, 'archive');
            } catch (\Exception $exception) {
                if (null !== $request) {
                    $flashBag = $request->getSession()->getFlashBag();
                    $flashBag->add('error', $this->translator->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . '  ' . $exception->getMessage());
                }
            }

            if (!$success) {
                return false;
            }
            «IF hasHookSubscribers»

                if ($entity->supportsHookSubscribers()) {
                    // Let any hooks know that we have updated an item
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
                    $this->hookHelper->callProcessHooks($entity, UiHooksCategory::TYPE_PROCESS_EDIT, $url);
                }
            «ENDIF»
        }
    '''

    def private archiveHelperImpl(Application it) '''
        namespace «appNamespace»\Helper;

        use «appNamespace»\Helper\Base\AbstractArchiveHelper;

        /**
         * Archive helper implementation class.
         */
        class ArchiveHelper extends AbstractArchiveHelper
        {
            // feel free to extend the archive helper here
        }
    '''
}
