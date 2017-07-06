package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.ControllerExtensions
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ArchiveHelper {

    extension ControllerExtensions = new ControllerExtensions
    extension FormattingExtensions = new FormattingExtensions
    extension ModelBehaviourExtensions = new ModelBehaviourExtensions
    extension ModelExtensions = new ModelExtensions
    extension NamingExtensions = new NamingExtensions
    extension Utils = new Utils

    def generate(Application it, IFileSystemAccess fsa) {
        println('Generating helper class for automatic archiving')
        val fh = new FileHelper
        generateClassPair(fsa, getAppSourceLibPath + 'Helper/ArchiveHelper.php',
            fh.phpFileContent(it, archiveHelperBaseClass), fh.phpFileContent(it, archiveHelperImpl)
        )
    }

    def private archiveHelperBaseClass(Application it) '''
        namespace «appNamespace»\Helper\Base;

        use Doctrine\ORM\QueryBuilder;
        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\Request;
        use Symfony\Component\HttpFoundation\RequestStack;
        «IF hasHookSubscribers && targets('1.5')»
            use Zikula\Bundle\HookBundle\Category\UiHooksCategory;
        «ENDIF»
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\RouteUrl;
        use Zikula\PermissionsModule\Api\«IF targets('1.5')»ApiInterface\PermissionApiInterface«ELSE»PermissionApi«ENDIF»;
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
             * @var Request
             */
            protected $request;

            /**
             * @var LoggerInterface
             */
            protected $logger;

            /**
             * @var PermissionApi«IF targets('1.5')»Interface«ENDIF»
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
             * @param TranslatorInterface $translator     Translator service instance
             * @param RequestStack        $requestStack   RequestStack service instance
             * @param LoggerInterface     $logger         Logger service instance
             * @param PermissionApi«IF targets('1.5')»Interface«ENDIF»       $permissionApi  PermissionApi service instance
             * @param EntityFactory       $entityFactory  EntityFactory service instance
             * @param WorkflowHelper      $workflowHelper WorkflowHelper service instance
             «IF hasHookSubscribers»
             * @param HookHelper          $hookHelper     HookHelper service instance
             «ENDIF»
             */
            public function __construct(
                TranslatorInterface $translator,
                RequestStack $requestStack,
                LoggerInterface $logger,
                PermissionApi«IF targets('1.5')»Interface«ENDIF» $permissionApi,
                EntityFactory $entityFactory,
                WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
                HookHelper $hookHelper«ENDIF»
            ) {
                $this->translator = $translator;
                $this->request = $requestStack->getCurrentRequest();
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
            «IF endField instanceof DatetimeField»
                $today = date('Y-m-d H:i:s');
            «ELSEIF endField instanceof DateField»
                $today = date('Y-m-d') . ' 00:00:00';
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
         * @return bool True if everything worked successfully, false otherwise
         */
        protected function archiveSingleObject($entity)
        {
            «IF !targets('1.5')»
                $entity->initWorkflow();

            «ENDIF»
            «IF hasHookSubscribers»
                if ($entity->supportsHookSubscribers()) {
                    // Let any hooks perform additional validation actions
                    $validationHooksPassed = $this->hookHelper->callValidationHooks($entity, «IF targets('1.5')»UiHooksCategory::TYPE_VALIDATE_EDIT«ELSE»'validate_edit'«ENDIF»);
                    if (!$validationHooksPassed) {
                        return false;
                    }
                }

            «ENDIF»
            $success = false;
            try {
                // execute the workflow action
                $success = $this->workflowHelper->executeAction($entity, 'archive');
            } catch(\Exception $exception) {
                $flashBag = $this->request->getSession()->getFlashBag();
                $flashBag->add('error', $this->translator->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . '  ' . $exception->getMessage());
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
                        $urlArgs['_locale'] = $this->request->getLocale();
                        $url = new RouteUrl('«appName.formatForDB»_' . strtolower($objectType) . '_display', $urlArgs);
                	}
                    $this->hookHelper->callProcessHooks($entity, «IF targets('1.5')»UiHooksCategory::TYPE_PROCESS_EDIT«ELSE»'process_edit'«ENDIF», $url);
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
