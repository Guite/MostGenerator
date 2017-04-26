package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
import de.guite.modulestudio.metamodel.DateField
import de.guite.modulestudio.metamodel.DatetimeField
import de.guite.modulestudio.metamodel.Entity
import org.eclipse.xtext.generator.IFileSystemAccess
import org.zikula.modulestudio.generator.cartridges.zclassic.smallstuff.FileHelper
import org.zikula.modulestudio.generator.extensions.FormattingExtensions
import org.zikula.modulestudio.generator.extensions.ModelBehaviourExtensions
import org.zikula.modulestudio.generator.extensions.ModelExtensions
import org.zikula.modulestudio.generator.extensions.NamingExtensions
import org.zikula.modulestudio.generator.extensions.Utils

class ArchiveHelper {

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

        use Psr\Log\LoggerInterface;
        use Symfony\Component\HttpFoundation\RequestStack;
        use Zikula\Common\Translator\TranslatorInterface;
        use Zikula\Core\RouteUrl;
        use Zikula\PermissionsModule\Api\«IF targets('1.5')»ApiInterface\PermissionApiInterface«ELSE»PermissionApi«ENDIF»;
        use «appNamespace»\Entity\Factory\«name.formatForCodeCapital»Factory;
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
             * @var «name.formatForCodeCapital»Factory
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
             * @param «name.formatForCodeCapital»Factory $entityFactory «name.formatForCodeCapital»Factory service instance
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
                «name.formatForCodeCapital»Factory $entityFactory,
                WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
                HookHelper $hookHelper«ENDIF»)
            {
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
    '''

    def private archiveObjects(Entity it) '''
        /**
         * Moves «nameMultiple.formatForDisplay» into the archive which reached their end date.
         *
         * @throws RuntimeException Thrown if workflow action execution fails
         */
        public function archive«nameMultiple.formatForCodeCapital»()
        {
            «val endField = getEndDateField»
            «IF endField instanceof DatetimeField»
                $today = date('Y-m-d H:i:s');
            «ELSEIF endField instanceof DateField»
                $today = date('Y-m-d') . ' 00:00:00';
            «ENDIF»

            $repository = $this->entityFactory->getRepository('«name.formatForCode»');
            $qb = $repository->genericBaseQuery('', '', false);

            /*$qb->andWhere('tbl.workflowState != :archivedState')
               ->setParameter('archivedState', 'archived');*/
            $qb->andWhere('tbl.workflowState = :approvedState')
               ->setParameter('approvedState', 'approved');

            $qb->andWhere('tbl.«endField.name.formatForCode» < :today')
               ->setParameter('today', $today);

            $query = $repository->getQueryFromBuilder($qb);

            $affectedEntities = $query->getResult();

            $action = 'archive';
            foreach ($affectedEntities as $entity) {
                «IF !application.targets('1.5')»
                    $entity->initWorkflow();

                «ENDIF»
                «IF !skipHookSubscribers»
                    // Let any hooks perform additional validation actions
                    $validationHooksPassed = $this->hookHelper->callValidationHooks($entity, 'validate_edit');
                    if (!$validationHooksPassed) {
                        continue;
                    }

                «ENDIF»
                $success = false;
                try {
                    // execute the workflow action
                    $success = $this->workflowHelper->executeAction($entity, $action);
                } catch(\Exception $exception) {
                    $flashBag = $this->request->getSession()->getFlashBag();
                    $flashBag->add('error', $this->translator->__f('Sorry, but an error occured during the %action% action. Please apply the changes again!', ['%action%' => $action]) . '  ' . $exception->getMessage());
                }

                if (!$success) {
                    continue;
                }
                «IF !skipHookSubscribers»

                    // Let any hooks know that we have updated an item
                    $urlArgs = $entity->createUrlArgs();
                    $urlArgs['_locale'] = $this->request->getLocale();
                    $url = new RouteUrl('«application.appName.formatForDB»_«name.formatForCode»_display', $urlArgs);
                    $this->hookHelper->callProcessHooks($entity, 'process_edit', $url);
                «ENDIF»
            }
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
