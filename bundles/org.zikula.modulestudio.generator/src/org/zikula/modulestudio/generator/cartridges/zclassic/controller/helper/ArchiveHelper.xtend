package org.zikula.modulestudio.generator.cartridges.zclassic.controller.helper

import de.guite.modulestudio.metamodel.Application
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
        use Zikula\Common\Translator\TranslatorInterface;
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
                LoggerInterface $logger,
                PermissionApi«IF targets('1.5')»Interface«ENDIF» $permissionApi,
                «name.formatForCodeCapital»Factory $entityFactory,
                WorkflowHelper $workflowHelper«IF hasHookSubscribers»,
                HookHelper $hookHelper«ENDIF»)
            {
                $this->translator = $translator;
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
        public function archiveObjects()
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
                $repository = $this->entityFactory->getRepository('«entity.name.formatForCode»');
                $repository->archiveObjects($this->translator, $this->workflowHelper«IF !entity.skipHookSubscribers», $this->hookHelper«ENDIF»);
                $this->logger->notice('{app}: Automatic archiving for the {entity} entity completed.', $logArgs);
            «ENDFOR»
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
